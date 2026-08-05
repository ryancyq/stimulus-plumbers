# Status Primitives: Progress, Indicator, Checklist design

## Scope

First of four independent Flowbite-inspired sub-projects (Progress/Indicator/Checklist, QR code, Maps, Settings/Profile composition guide — the latter three are separate future brainstorms). This spec covers three related pieces, grouped together because Checklist and Progress both back the future "password complexity" input (out of scope here, tracked as a follow-up once these primitives exist):

1. **`progress` controller + `progress_bar`/`progress_ring`/`meter` components** (new)
2. **`indicator` component** (new, extracted from `timeline_item_indicator*`; `timeline` refactored to consume it)
3. **`list_item` checked-state extension** (existing component gains a state, no new top-level component)

Currency input (`input-formatter`'s existing `"currency"` format) and password reveal (`input-formatter`'s existing `"password"` format) already exist and are out of scope — only a Rails helper check for `as: :currency` is a possible small follow-up, not part of this spec.

## Part 1: Progress (`progress` controller)

### Values

| Value | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | String | `"bar"` | `"bar"` \| `"ring"` \| `"meter"` — determines which visual calculation applies |
| `value` | Number | `0` | Current value |
| `min` | Number | `0` | Range minimum |
| `max` | Number | `100` | Range maximum |
| `optimum` | Number | — | Meter-only; maps to native `<meter optimum>` |
| `low`/`high` | Number | — | Meter-only; maps to native `<meter low/high>` |
| `indeterminate` | Boolean | `false` | Unknown-duration state; suppresses `aria-valuenow`, adds CSS animation class |

### Targets

| Target | Element | Description |
| --- | --- | --- |
| `fill` | `<div>` (bar) / `<circle>` (ring) | Element whose `width` (bar) or `stroke-dasharray`/`stroke-dashoffset` (ring) is recalculated |
| `meter` | `<meter>` | Present only for `variant: "meter"` — native element, attributes synced directly, no custom fill calculation |

### Methods

| Method | Wired via | Description |
| --- | --- | --- |
| `setValue(value)` | — | Programmatic API — clamps to `[min, max]`, updates `valueValue`, recalculates fill, dispatches `progress:changed` |
| `valueValueChanged(value)` | Stimulus value callback | Recalculates fill/attrs whenever `value` changes (covers both `setValue()` and direct attribute edits) |

### Dispatches

`progress:changed` — `{ value, min, max }`. Lets other controllers (e.g. a future password-strength scorer) drive Progress without touching its internals — same event-adapter shape as `input-formatter:formatted`.

### Rendering per variant

- **bar**: `role="progressbar" aria-valuenow aria-valuemin aria-valuemax`, `fill` target's inline `width: N%` set by the controller (not Tailwind — value is dynamic).
- **ring**: same ARIA as bar, `fill` target is an SVG `<circle>`; controller computes `stroke-dasharray = circumference` and `stroke-dashoffset = circumference * (1 - percent)` from the circle's `r` attribute (read once at connect, not hardcoded).
- **meter**: renders a real `<meter>` element (native semantics, no ARIA role needed); controller syncs `value`/`min`/`max`/`low`/`high`/`optimum` attributes directly, no fill computation.
- **indeterminate**: `aria-valuenow` omitted per ARIA spec for indeterminate progress; a CSS animation class is toggled instead of computing fill.

### Rails helper

- `lib/stimulus_plumbers/components/progress_bar.rb`, `progress_ring.rb`, `meter.rb` — thin renderers emitting the controller/value/target data-attributes above. No slot/content API needed (no children — value-driven only).
- `sp_progress_bar(value:, max: 100, **html_options)`, `sp_progress_ring(value:, max: 100, radius: 20, **html_options)`, `sp_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **html_options)`.

### Theme keys

| Key | Element |
| --- | --- |
| `progress_bar` | outer `<div role="progressbar">` |
| `progress_bar_fill` | inner fill `<div>` |
| `progress_ring` | outer `<svg>` |
| `progress_ring_track` | background `<circle>` |
| `progress_ring_fill` | foreground `<circle>` (the `fill` target) |
| `meter` | `<meter>` (styling via `::-webkit-meter-*`/`::-moz-meter-*` pseudo-elements, documented as a known cross-browser limitation) |

### Testing

- `tests/unit/controllers/progress_controller.test.js`: `setValue` clamps to range and dispatches `progress:changed`; bar fill `width` matches percent; ring `stroke-dashoffset` matches percent given a known `r`; meter variant syncs native attributes instead of computing fill; indeterminate omits `aria-valuenow`.
- `test/stimulus_plumbers/components/progress_bar_test.rb` (+ ring, meter): correct ARIA role/attrs per variant.
- `test/accessibility/components/progress_test.rb`: sandbox views for all three variants, `assert_accessible`.

## Part 2: Indicator

### Design

Presentational component, no controller. Three shape variants sharing one component: `dot` (plain status), `pulse` (dot + CSS ring animation, `prefers-reduced-motion` respected — animation suppressed under that media query), `badge` (numeric counter, renders provided content instead of being empty).

- `lib/stimulus_plumbers/components/indicator.rb` — `sp_indicator(variant: :dot, color:, pulse: false, **html_options)`. `color:` maps to existing semantic color tokens (not raw Tailwind utilities), consistent with the "test use cases not implementation" testing guideline already in CLAUDE.md.
- No built-in text — **every indicator must be paired with an accessible name** (visible label or `aria-label`/adjacent `sr-only` text). This is enforced by an a11y test, not by the component (the component can't know the right label), and documented as the required usage pattern.
- **Legend** is a doc pattern, not new code: an example in `docs/component/indicator.md` showing an `indicator` + visible text label list (e.g. inside `sp_list`) for "what does each color mean" use cases.

### `timeline` refactor

`timeline_item_indicator`, `timeline_item_indicator_dot`, `timeline_item_indicator_icon_slot` are re-implemented in terms of `sp_indicator` internally. No public API change to `Timeline`/`Timeline::Item` — this is an internal de-duplication, verified by the existing timeline test suite passing unmodified.

### Theme keys

| Key | Element |
| --- | --- |
| `indicator` | outer dot/badge element |
| `indicator_pulse` | pulse ring element (present only when `pulse: true`) |

### Testing

- `test/stimulus_plumbers/components/indicator_test.rb`: variant rendering, `pulse: true` adds the ring element, `color:` maps to the semantic token.
- `test/accessibility/components/indicator_test.rb`: sandbox view pairing indicator with a label; `assert_accessible`. A second sandbox view intentionally omitting a label is used to confirm the a11y checker catches the missing-accessible-name case (regression guard for the "must be paired" rule).
- Existing timeline tests must pass unmodified after the internal refactor (no new test needed — this is the acceptance check).

## Part 3: Checklist (`list_item` extension)

### Design

- `List::Item` gains a `checked:` render option (`nil` = plain list item, unchanged; `true`/`false` = checklist item). When set, renders a checkbox-glyph `<span>` (via `Icon`, check/empty-check icon) leading the content, and applies strikethrough styling to title/description when `checked: true`.
- **Interactive toggle**: a new `list_item` controller value `data-list-item-checked-value` + action `click->list-item#toggle` (wired only when `interactive:` option is passed at render time — read-only lists omit the `data-action` entirely, matching the existing `timeline`'s "interactive: true" opt-in precedent). `toggle()` flips the value, dispatches `list-item:toggled`.
- **Programmatic set**: `checkedValueChanged` re-renders the glyph/strikethrough whenever the value changes — covers both user click and an external controller (e.g. a future password-rules validator) calling `element.dataset.listItemCheckedValue = "true"` or dispatching through a small event adapter, same shape as `input-formatter`'s `onChange`.
- No new top-level component or helper — `sp_list`/`list.item(..., checked: true, interactive: true)` is the full API surface.

### Dispatches

`list-item:toggled` — `{ checked: boolean }`.

### Theme keys

Extends existing `list_item`/`list_item_content` keys; adds:

| Key | Element |
| --- | --- |
| `list_item_checkbox` | leading checkbox-glyph `<span>` |

### Testing

- `test/stimulus_plumbers/components/list/item_test.rb`: `checked:` option renders glyph + strikethrough classes; `interactive:` option wires vs. omits the click action.
- `tests/unit/controllers/list_item_controller.test.js`: `toggle()` flips value and dispatches `list-item:toggled`; `checkedValueChanged` updates DOM without requiring `toggle()` to have been called (covers external/programmatic set).
- `test/accessibility/components/list_test.rb`: checklist sandbox view (mix of checked/unchecked/read-only items), `assert_accessible`.

## Out of scope

- Password-complexity input (strength meter + auto-checking rule list) — a follow-up design once Progress and Checklist land; not designed here.
- Currency/password `input-formatter` formats — already exist, untouched.
- Settings/profile composition guide, QR code, Maps — separate future brainstorms.
- Counter-badge numeric formatting (e.g. "99+") — v1 renders whatever content is passed as-is; formatting logic is the app's responsibility.
- Tailwind theme class values for all new `*_ring`/`*_bar`/`indicator*`/`list_item_checkbox` keys — components render via `Base` theme's no-op defaults; visual styling is a separate follow-up task in `stimulus-plumbers-tailwind`, matching the precedent set by the `OrderedList` design.
