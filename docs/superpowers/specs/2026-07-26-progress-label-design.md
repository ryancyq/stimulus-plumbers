# Progress labelling — value readout + form-field name

Reference: https://flowbite.com/docs/components/progress/#with-label-outside

## Problem

`sp_progress_bar` renders a bare `<div role="progressbar">` with an empty fill. There is no way to
show the current value on screen, and no way to give the bar a visible name. Flowbite offers two
shapes for this — "label inside" (value drawn on the track) and "label outside" (a caption row
above the track).

## Prior art

Every major library builds progress from a plain `div` with `role="progressbar"`; none uses the
native `<progress>` element. Bootstrap states the reason outright: the native element cannot be
stacked, animated, or have text placed over it.

| Library    | Element                                                    | Label placement          | Name via                    | `aria-valuetext`          |
| ---------- | ---------------------------------------------------------- | ------------------------ | --------------------------- | ------------------------- |
| Bootstrap  | `.progress` div = `role=progressbar`; inner `.progress-bar` | inside the fill          | `aria-label`/`-labelledby`  | not used                  |
| Radix      | `div` + `Indicator` child                                  | none shipped             | author-supplied             | **always**, defaults `n%` |
| MUI        | `div role=progressbar`                                     | none shipped             | `aria-label`/`-labelledby`  | non-percentages only      |
| Carbon     | wrapper → label div + track div + helper div               | **outside, above track** | `aria-labelledby`           | determinate only          |
| Flowbite   | wrapper + fill div                                         | inside fill or outside   | `aria-label`                | not used                  |

Two findings drove decisions here:

- **Carbon independently arrived at this design** — a label element carrying an id, a track with
  `role="progressbar"` + `aria-labelledby`, and `aria-describedby` for helper text. It also wraps
  status text in an `aria-live="polite"` region; noted for later, out of scope now.
- **Bootstrap's inside-the-fill label clips**, and their docs acknowledge it (`overflow: hidden`
  caps long labels, with an `.overflow-visible` opt-out). This is why the readout is centered over
  the track instead.
- **`aria-valuetext` for percentages is contested.** Radix sets it unconditionally; MUI's docs say
  to use it only when the value is not a percentage. We follow MUI: `aria-valuenow` +
  `aria-valuemin/max` already lets AT announce a localized percentage, and `aria-valuetext` would
  override that with a hardcoded string. Not settled practice — revisit if AT testing disagrees.

## Decided model

The two Flowbite shapes are two *different* concerns, not two variants of one option:

| Concern                | Source                                                | Exposed as                                     |
| ---------------------- | ----------------------------------------------------- | ---------------------------------------------- |
| What the progress is for | `form_field_label` (form) / caller markup (standalone) | `aria-labelledby`                              |
| Value, machine-readable  | `value:`                                              | `aria-valuenow` (+ `aria-valuetext`, see below) |
| Value, on screen         | `format:`                                             | visual only — `aria-hidden="true"`             |

The name and the readout are independent: a field labelled "Upload progress" says nothing about
whether the readout shows `45%` or `45 / 100`. So the readout is **not** suppressed in forms.

### Label outside → the form builder owns it

No caption-row wrapper is added to `sp_progress_bar`. The outside label is the form field's own
label, rendered through the existing `Form::Field` / `Fields::Label` / `Fields::Group` machinery:

```erb
<%= f.field(:completion, as: :progress, format: :percent) %>
```

`sp_progress_bar`'s no-label output is unchanged, byte for byte. Standalone callers who want a
caption write their own markup and point `aria: { labelledby: }` at it — documented, not shipped.

### Label inside → centered over the track, on an opaque pill

The readout is a `<span>` sibling of the fill, absolutely centered over the track and sized to its
own text — not inside the fill. Flowbite puts it inside the fill, where it clips below ~10%.
Centering keeps it readable at every value.

Centering means the text crosses the fill edge, and **no single token clears WCAG AA on both
sides** (approximate ratios against the default palette):

| Text colour             | Over track (`muted` 95%) | Over fill (`primary` 50%) |
| ----------------------- | ------------------------ | ------------------------- |
| `--sp-color-fg`         | 15.0:1 ✓                 | 2.9:1 ✗                   |
| `--sp-color-primary-fg` | 1.1:1 ✗                  | 5.7:1 ✓                   |

So the readout carries its own opaque background — `bg-(--sp-color-bg)` with
`text-(--sp-color-fg)`, a constant ~15:1 regardless of what is underneath. Blend modes
(`mix-blend-difference`) were rejected: the result is per-channel RGB arithmetic that cannot be
asserted in a unit test, is unverified on any renderer, and approximates the backdrop when the
source is dark.

### Component / form composition

Mirrors `Combobox` exactly (`helpers/combobox_helper.rb:7`, `form/fields/inputs/combobox.rb:17`):
one component class owns its theme keys; the form path calls the *same* component and layers a
form-context theme key on top.

```
Components::ProgressBar          ← progress_bar, progress_bar_fill, progress_bar_value,
  ↑                    ↑            progress_segmented, progress_segment
sp_progress_bar   Fields::Inputs::Progress#render_progress
(standalone)        + theme.resolve(:form_field_input_progress)
```

## Scope

- **Bar** — readout (inside) + form field (outside).
- **Segmented** — form field only. A readout inside one slot is meaningless.
- **Ring** — excluded. It renders as a single registry SVG (`progress_ring.rb:23`); a centered
  `<text>` would mean changing the icon contract.
- **Meter** — excluded. `<meter>` takes no children.

## API

```erb
<%= sp_progress_bar(value: 45, format: :percent, aria: { label: "Upload" }) %>
<%= f.field(:completion, as: :progress, format: :percent) %>
<%= f.field(:strength, as: :progress, segments: 5, max: 5) %>
```

`format:` — `:percent` | `:value` | `:value_max`; `nil` (default) renders no readout.

**Anything else raises `ArgumentError`.** The allowed set is closed:

```ruby
FORMATS = %i[percent value value_max].freeze
raise ArgumentError, "unknown format: #{format.inspect}" unless format.nil? || FORMATS.include?(format.to_sym)
```

Silently accepting an unknown symbol would render a readout span with empty text and a taller
track — visibly wrong, with no indication why. Presence is tested with `format.nil?`, never
truthiness, so `format: false` is rejected by validation rather than slipping through a `if format`
check into inconsistent markup.

Strings are accepted and coerced (`format: "percent"`), so `params[:format]` works without the
caller remembering `to_sym`. Anything that cannot be coerced — `false`, numbers — is rejected.

Chosen over `value_format:` for consistency with the existing `format:` option on the time
combobox (`form/fields/inputs/datetime.rb:59`). No collision: `Form::Base::OPTIONS` is
`label hint error required layout floating` (`form/base.rb:6`), so `format:` passes through
`**kwargs` to the renderer.

### `format:` is rejected on segmented

Segmented takes no readout, so combining it with `format:` is a caller error, not a silent no-op.
`sp_progress_segmented` and the `:progress` field renderer both **raise `ArgumentError`** when
`segments:` and a non-nil `format:` are given together. Tested with `.nil?`, not truthiness:

```ruby
raise ArgumentError, "format: is not supported with segments:" unless format.nil?
```

Without this the option would fall through `**kwargs` into `merge_html_options` and render as a
stray `format="percent"` attribute on the container.

### Rendered output

| `format:`    | On screen  | `aria-valuetext` |
| ------------ | ---------- | ---------------- |
| `:percent`   | `45%`      | unset — AT already announces `aria-valuenow` as a percentage in its own locale |
| `:value`     | `45`       | `45`             |
| `:value_max` | `45 / 100` | `45 / 100`       |
| `nil`        | —          | unset            |

Indeterminate suppresses the readout text and `aria-valuetext`, as it already suppresses
`aria-valuenow`.

### Normative formatting

The initial text is server-rendered and the controller updates it thereafter — a deliberate
duplication (see the tradeoff note below). Because the same string is produced twice in two
languages, the rules are normative, not illustrative. Ruby and JS must agree for every input.

**Clamping is global, not readout-local.** `clamped = min(max, max(min, value))` is computed once
and is the only value that reaches *any* output — `aria-valuenow`, the fill width / segment
distribution, the readout text, and `--sp-progress-percent`. Both sides do it: the server clamps
before rendering (including `data-progress-current-value`), and the controller clamps defensively
so a runtime attribute edit cannot push the fill past 100% or emit an out-of-range
`aria-valuenow`. Clamping only the readout would make a server-rendered `value: 150, max: 100`
show `100%` and then flip to `150%` when Stimulus connects.

This changes existing behavior: `aria-valuenow` is currently written raw. That is a defect —
`aria-valuenow` outside `[aria-valuemin, aria-valuemax]` is invalid — and the fix is in scope.

**Percent.** Compute from the clamped value, then round:

```
percent = (max - min) <= 0 ? 0 : (clamped - min) / (max - min) * 100
text    = "#{round(percent)}%"
```

- `max == min` (and `max < min`) yield `0%` — never `NaN`, a division by zero, or a raise.
  Ruby must not use `Comparable#clamp`, which raises when `min > max`; both sides return `max`
  there, and the `range <= 0` branch then produces `0%`.
- `percent` is always in `[0, 100]`, so half-values round identically in both languages: Ruby's
  `Float#round` (half away from zero) and JS `Math.round` (half toward +∞) agree for
  non-negatives. `1/3 → 33%`, `2/3 → 67%`, `0.5 → 1%`.
- Non-zero minima are handled by the subtraction, e.g. `value: 5, min: 0, max: 20 → 25%`;
  `value: 15, min: 10, max: 20 → 50%`.

**Value and value_max.** Render the *clamped* value, and render an integral number without a
decimal point so `45.0` and `45` produce the same string in both languages:

```
n       = clamped % 1 == 0 ? integer(clamped) : clamped
:value  → "#{n}"
:value_max → "#{n} / #{integer_if_integral(max)}"
```

Ruby's `45.0.to_s` is `"45.0"` while JS renders `45` — without this rule the server and client
disagree on the first re-render for any Float-typed attribute, which is exactly the case a Rails
decimal column produces.

The duplication itself is accepted deliberately, to avoid an empty readout before Stimulus
connects. Same tradeoff `Password::Requirements` makes.

## JS controller changes (additive)

- New target `value` — the readout span.
- New value `format: String` (default `''`).
- New `aria.js` export `setValueText`, joining `setValueMin` / `setValueMax` / `setValueNow`.
- `render()` calls `renderValueText()` in the shared bar/segmented/ring branch.

Existing markup without a `value` target is unaffected — every new path is guarded on
`hasValueTarget`.

## Form-field changes

`Form::Field` assumes `<label for=…>` can point at its input. `for` is only valid against a
**labelable** element — `button`, `input` (not hidden), `meter`, `output`, `progress`, `select`,
`textarea`. A `<div role="progressbar">` is none of those, so the association is never formed and
the accessible name never lands.

- `Field::LABEL_MODES = %i[native aria]` — every type in `Fields::Renderer::FIELD` declares one in
  the parallel `LABEL_MODE` map, and `Builder#render_field` passes it as `label_mode:`. A type with
  no entry, or an unknown mode, raises at load.
- `:aria`: `field_label` renders `tag: :span` with no `for_id`, and `build_aria` adds
  `labelledby: label_id(input_id)`. `Fields::Label` itself is unchanged — it already accepts
  `tag:`, and Rails omits nil attributes.
- `floating:` applies to `:native` only (the floating path needs a real input with a
  placeholder); `render` takes the default-field branch otherwise.

The modes are named for the association mechanism, not for what the field is: the test is "how
does this caption legally attach", which is not the same as "is this a control". A div-based
slider would be a control and still need `:aria`.

Declared metadata rather than a `NON_LABELABLE_TYPES` denylist so the answer is stated per type
instead of inferred from absence — a new display-only field cannot quietly default into emitting a
`<label for>` that names nothing.

### Validation and control-only attributes are suppressed

`Form::Base#build_aria` and `#build_html_options` emit `required`, `aria-required`,
`aria-invalid`, and error UI for every field. None of these are meaningful on a read-only
`role="progressbar"` — `aria-invalid` and `aria-required` are not supported on the progressbar
role, and a bare `required` attribute on a `div` is invalid HTML. A `:progress` field therefore
suppresses all of them:

| Attribute / behavior          | Control field | `:progress` field |
| ----------------------------- | ------------- | ----------------- |
| `required` (HTML attribute)   | emitted       | **never emitted** |
| `aria-required`               | emitted       | **never emitted** |
| `aria-invalid`                | on error      | **never emitted** |
| `hint:` → `aria-describedby`  | yes           | yes               |
| model/`error:` messages       | error UI + `aria-describedby` | **descriptive text + `aria-describedby`, no error role or `aria-invalid`** |

`required:` passed to a `:progress` field is ignored silently rather than raised — unlike
`format:` + `segments:`, it is meaningful on the *field* (a caller may mark the whole row
required) and only the input-level attributes are dropped.

**Errors are rendered, not swallowed.** If the model carries an error on the attribute, the
message still appears and still joins `aria-describedby`, but as ordinary descriptive text: no
`aria-invalid`, no error role. Dropping the message entirely would lose information the caller
put there; asserting an invalid state on a read-only element is the part that is wrong. This is a
judgment call — if progress fields should instead reject `error:` outright, that changes only
`Field#build_aria` and one test.

## Accessibility

- Visible name and accessible name are the same string — WCAG 2.5.3 (Label in Name).
- The readout is `aria-hidden="true"`; the value reaches AT only via `aria-valuenow` /
  `aria-valuetext`. Without this it is announced twice.
- No new interactive elements; nothing focusable is added, so no keyboard work.

## Rendered markup

Classes elided to the semantically interesting ones. `style="width"` is applied by the controller
on `connect`, not server-rendered — existing behavior, unchanged.

### Standalone, no readout — byte-identical to today

```html
<div role="progressbar" aria-label="Upload progress"
     aria-valuemin="0" aria-valuemax="100" aria-valuenow="45"
     class="relative w-full h-2 … bg-(--sp-color-muted)"
     data-controller="progress" data-progress-variant-value="bar"
     data-progress-current-value="45"
     data-progress-min-value="0" data-progress-max-value="100"
     data-progress-indeterminate-value="false">
  <div data-progress-target="fill" class="h-full … bg-(--sp-color-primary)" style="width: 45%"></div>
</div>
```

### Standalone, `format: :percent`

Adds the format value, the readout span, and a taller track (`h-5`). No `aria-valuetext`.

```html
<div role="progressbar" aria-label="Upload progress"
     aria-valuemin="0" aria-valuemax="100" aria-valuenow="45"
     class="relative w-full h-5 …"
     data-controller="progress" data-progress-variant-value="bar"
     data-progress-current-value="45"
     data-progress-min-value="0" data-progress-max-value="100"
     data-progress-format-value="percent"
     data-progress-indeterminate-value="false">
  <div data-progress-target="fill" style="width: 45%"></div>
  <span data-progress-target="value" aria-hidden="true"
        class="absolute inset-0 flex items-center justify-center … mix-blend-difference">45%</span>
</div>
```

`format: :value_max` is the same shape plus `aria-valuetext="45 / 100"`. Indeterminate empties the
readout and drops both `aria-valuenow` and `aria-valuetext`.

### Form field — `f.field(:completion, as: :progress, format: :percent)`

```html
<div class="[form_group]">
  <span id="onboarding_completion_label" class="[form_field_label]">Completion</span>
  <div id="onboarding_completion" role="progressbar"
       aria-labelledby="onboarding_completion_label"
       aria-valuemin="0" aria-valuemax="100" aria-valuenow="45"
       class="relative w-full h-5 … [+ form_field_input_progress]"
       data-controller="progress" data-progress-variant-value="bar"
       data-progress-current-value="45"
       data-progress-min-value="0" data-progress-max-value="100"
       data-progress-format-value="percent"
       data-progress-indeterminate-value="false">
    <div data-progress-target="fill" style="width: 45%"></div>
    <span data-progress-target="value" aria-hidden="true">45%</span>
  </div>
</div>
```

Three differences from standalone: the label is a `<span>` with no `for=`; the name comes from
`aria-labelledby` rather than `aria-label`; and the element carries an `id` (from `field_id`) plus
the form-context classes. With a `hint:`, `aria-describedby` wires up exactly as for real inputs.

### Form field, segmented — `f.field(:profile_strength, as: :progress, segments: 5, max: 5)`

Segmented takes no readout, so `format:` is not accepted here.

```html
<div class="[form_group]">
  <span id="onboarding_profile_strength_label">Profile strength</span>
  <div id="onboarding_profile_strength" role="progressbar"
       aria-labelledby="onboarding_profile_strength_label"
       aria-valuemin="0" aria-valuemax="5" aria-valuenow="4"
       class="flex w-full gap-(--sp-space-1)"
       data-controller="progress" data-progress-variant-value="segmented"
       data-progress-segment-mode-value="discrete"
       data-progress-current-value="4"
       data-progress-min-value="0" data-progress-max-value="5"
       data-progress-indeterminate-value="false">
    <!-- ×5 -->
    <div aria-hidden="true" class="[segment]"><div data-progress-target="fill" style="width: 100%"></div></div>
  </div>
</div>
```

### Form field, range — `f.field(:volume, as: :range, format: :percent)`

Ordinary `<label for>` pointing at the input. An input takes no children, so the readout is a
sibling — which means the controller must sit on an element that contains **both**, otherwise the
`value` target never resolves (Stimulus targets must be descendants of the controller element).

```html
<div class="[form_group]">
  <label for="preferences_volume" class="[form_field_label]">Volume</label>

  <div data-controller="progress" data-progress-variant-value="range"
       data-progress-min-value="0" data-progress-max-value="100"
       data-progress-current-value="45"
       data-progress-format-value="percent"
       class="[form_field_input_range_group]">
    <input type="range" id="preferences_volume" name="preferences[volume]"
           min="0" max="100" value="45"
           class="[form_field_input_range]"
           style="--sp-progress-percent: 45"
           data-progress-target="input"
           data-action="input->progress#render">
    <span data-progress-target="value" aria-hidden="true">45%</span>
  </div>
</div>
```

`--sp-progress-percent` is on the `<input>`, never the wrapper — the input carries the track
gradient, so the property has to resolve there. The renderer sets it server-side in both shapes,
so the fill paints correctly before Stimulus connects.

The wrapper is **local to the input row**, not the field root — `Fields::Group` still owns the
outer element, the label still associates natively, and no caller-facing option changes. It exists
only when the controller needs to span the input and the readout.

Without `format:` there is no readout and therefore no second element to span, so the controller
and the custom property sit directly on the `<input>` and no wrapper is emitted:

```html
<input type="range" id="preferences_volume" name="preferences[volume]"
       min="0" max="100" value="45"
       class="[form_field_input_range]"
       style="--sp-progress-percent: 45"
       data-controller="progress" data-progress-variant-value="range"
       data-action="input->progress#render">
```

In both shapes `--sp-progress-percent` lives on the `<input>`, is rendered server-side, and is
updated by the controller on `this.inputTarget` when the wrapper is present and `this.element`
otherwise.

No `aria-*` is written by the controller in either shape — the native input owns its slider
semantics.

## Range (`<input type="range">`)

The native range input adopts the bar's track/fill visual language and the same `format:` readout.
It is **not** folded into `Components::ProgressBar` — a range is a focusable, value-submitting form
control whose ARIA rules are the opposite of a progressbar's. Only theme tokens and one controller
branch are shared. The API stays `f.field(as: :range)`; no `sp_progress_*` helper wraps it.

Range currently ships with no theme entry at all, so it inherits `form_field_input`'s text-input
classes (border, padding, background) on a range input. Closing that gap is in scope.

### Fill

WebKit has no filled-track pseudo-element (Firefox has `::-moz-range-progress`; Chrome/Safari have
nothing). Portable approach: a `linear-gradient` on the track driven by `--sp-progress-percent`,
which the controller updates on `input`. Same cross-browser caveat `sp_progress_meter` documents.

### Controller

A `range` variant that **only** sets `--sp-progress-percent`, on `this.inputTarget` when present
and `this.element` otherwise. It must not write `aria-value*` — the native input owns its own
slider semantics, and the existing `setValueMin/Max/Now` block would be wrong here. New target
`input`.

### Labelling

`input` is labelable, so range is declared `:native` and keeps an ordinary `<label for>`. It never
takes the `:aria` branch — the two features do not interact.

### Readout

Rendered as a sibling of the input, inside a wrapper local to the input row — required because a
Stimulus target must be a descendant of its controller element, and an `<input>` can hold no
children. `Fields::Group` still owns the field root and no caller-facing option changes; the
wrapper is emitted only when `format:` is given. `aria-hidden` for the same reason as the bar —
the native input already exposes its value.

## Theme keys

| Key                         | Status  | Purpose                                                      |
| --------------------------- | ------- | ------------------------------------------------------------ |
| `progress_bar`              | changed | Gains `labelled:` (BOOL) — taller track when a readout is present |
| `progress_bar_value`        | new     | Centered readout span                                        |
| `form_field_input_progress` | new     | Form-context overrides; mirrors `form_field_input_combobox`  |
| `form_field_input_range`    | new     | Range track/thumb; reuses `Progress::BAR` color tokens       |
| `form_field_input_range_group` | new  | Input-row wrapper; emitted only when range has a readout      |
| `progress_bar_fill`, `progress_segmented`, `progress_segment` | unchanged | — |

## Out of scope

- Ring and meter readouts.
- A standalone caption-row wrapper helper.
- Caller-supplied format callbacks — the three formats cover the reference; a JS hook is
  speculative until asked for.
- A div-based `role="slider"` component. If a control needs a user-settable value, the native
  range input is the supported path.
- A readout that tracks the thumb position along the range track.
