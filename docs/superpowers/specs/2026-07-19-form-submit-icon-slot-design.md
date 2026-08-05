# Form Submit Icon Slot — Design

**Date:** 2026-07-19
**Scope:** `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`

## Problem

`f.submit` renders a themed button but cannot take a leading or trailing icon, while `sp_button` can. The two produce structurally identical markup, so the gap is purely that `submit` reimplements the button's inner content instead of reusing its icon layout.

## Current State

`Form::Fields::Inputs::Submit#submit` (`form/fields/inputs/submit.rb:8-23`) routes through `Components::Button#build`, which yields themed attributes, then wraps the value in a bare `<span>`:

```html
<button type="submit" class="…"><span>Save</span></button>
```

Everything needed already exists:

- `Button::Slots` (`components/button/slots.rb:7`) declares `:icon_leading` and `:icon_trailing`.
- Tailwind `Button::LAYOUT` is `inline-flex … gap-(--sp-space-2)` with `[&:not(:has(>span))]:aspect-square` for icon-only detection (`themes/tailwind/button.rb:14-18`).
- `form_submit_classes` returns `{}` (`themes/tailwind/form.rb:16`), so `:form_submit` is a pure extension hook with no styling to conflict.

### Why `Button#render` cannot simply be reused

1. **`type:` carries two meanings.** In `Button#build` it is the theme type (`:default`/`:card`, validated by `Button::Ranges::TYPE` at `themes/schema.rb:207`). `submit` needs the HTML attribute `type="submit"`. `Button#render` hardcodes `type: "button"` (`button.rb:12`).
2. **The layout helpers are private.** `build_layout` and `render_icon_slot` (`button.rb:38-59`) are not reachable, and `render` resolves the `:button` theme key, which would drop the `:form_submit` hook.

## Existing `hide_label` Analysis

`hide_label` already exists in the form API, and the interaction was checked before adopting the name:

1. **It currently means "sr-only the field's `<label>`".** `Form::Field` passes it to `Fields::Label#render(hidden:)`, which resolves `form_field_label(hidden:)` → `sr-only` (`tailwind/form/field.rb:117-123`). The element stays in the DOM; three tests pin this (`builder_test.rb:83`, `text_test.rb:106`, `password_test.rb:150`).
2. **`f.submit` does not share that machinery.** It is a Level 1 native override that builds its button directly and never touches `Form::Base`, `Form::Field::OPTIONS`, or `Fields::Label`. On submit the option targets the button's own `<span>`, so it is a parallel implementation sharing a name.
3. **`hide_label` with icons already coexists safely.** `f.field :name, as: :text, label: "Search query", hide_label: true` (sandbox `field_error.html.erb:54`) sits alongside icon-bearing inputs. The password reveal and search clear buttons are separate `<button type="button">` elements resolving `form_field_input_button_reveal`, not `:button` (`password.rb:53-70`); they hold a bare `<svg>` with no span and carry their own `aria-label`. `Button::LAYOUT`'s `:not(:has(>span))` rule never applied to them, and the new selector will not either.

**Decision:** keep the name `hide_label` for vocabulary consistency — "the accessible name stays, the visual text goes" holds in both places. Docs must state that on submit it targets the button's own span rather than a `<label>` element.

**Verified collision-free:** no markup in either gem currently emits `data-sp-label-hidden`.

## API

```ruby
f.submit("Save")                                          # unchanged
f.submit("Save", icon_leading: "save")
f.submit("Save", icon_trailing: "arrow-right")
f.submit("Save", icon_leading: "save", hide_label: true)  # visually icon-only
f.submit("", icon_leading: "save")                        # raises ArgumentError
```

The signature stays `submit(value = nil, options = {})`. `icon_leading:`, `icon_trailing:`, and `hide_label:` are extracted from `options` alongside the existing `type:`/`variant:` extraction so they never reach the HTML attributes.

## Rendered HTML

```html
<!-- default (unchanged) -->
<button type="submit"><span>Save</span></button>

<!-- icon_leading -->
<button type="submit"><svg aria-hidden="true">…</svg><span>Save</span></button>

<!-- icon_trailing -->
<button type="submit"><span>Save</span><svg aria-hidden="true">…</svg></button>

<!-- hide_label -->
<button type="submit">
  <svg aria-hidden="true">…</svg>
  <span data-sp-label-hidden class="sr-only">Save</span>
</button>
```

## Components

**`Components::Button::IconLayout`** — new file `components/button/icon_layout.rb` holding `build_layout` and `render_icon_slot`, moved verbatim from `button.rb:38-59`. `Button` includes it. Both methods stay private in each host, so `Button`'s public API is unchanged.

**`Form::Fields::Inputs::Submit`** includes the same module, populates a `Button::Slots` from `icon_leading:`/`icon_trailing:`, and wraps its label span in `build_layout`. Icon resolution — the `Icon.icon_name?` check, `size: :sm`, `aria-hidden="true"`, and the `:button_icon` theme — is inherited unchanged, so a submit icon renders identically to an `sp_button` icon.

## Theme

- New schema key in `themes/schema.rb`, beside `form_submit`:
  ```ruby
  form_submit_label: {
    hidden: { default: false, validate: Ranges::BOOL }
  }.freeze
  ```
- Tailwind `form_submit_label_classes(hidden:)` returns `sr-only` when hidden, added to `tailwind/form.rb` beside `form_submit_classes`.
- `data-sp-label-hidden` is emitted by the Rails gem, not the theme — it is structural, so themeless consumers get it too.
- `Button::LAYOUT` gains `[&:has(>span[data-sp-label-hidden])]:aspect-square` and `[&:has(>span[data-sp-label-hidden])]:px-0`, mirroring the existing `:not(:has(>span))` pair.

## Validation

Raise `ArgumentError` when the resolved label is blank and no accessible name is supplied, checking `options.dig(:aria, :label)`, `options.dig(:aria, :labelledby)`, and `options[:"aria-label"]`.

This is the only path that can produce an unnamed submit button: `hide_label` keeps the text in the DOM, so it always supplies a name by construction. The guard therefore covers `f.submit("")` and a blank `submit_default_value`.

`hide_label: true` with no icons is permitted, not an error — it renders a button whose only content is sr-only text. It is a caller mistake rather than an a11y defect, and guarding it would add a second rule for no accessibility gain.

Note this makes `f.submit` stricter than `sp_button`, where icon-only is a document-only CSS contract with no Ruby enforcement. The divergence is intentional — an unnamed submit is a higher-severity a11y defect than an unnamed button.

## Testing

**Unit** (`test/stimulus_plumbers/form/fields/inputs/submit_test.rb`, extend existing):

- leading icon renders before the span; trailing icon renders after
- both icons together, in order
- `hide_label` emits `data-sp-label-hidden` and keeps the text content
- blank label without an accessible name raises `ArgumentError`
- blank label *with* `aria: { label: … }` renders without raising
- plain `f.submit("Save")` output is unchanged from today

**Tailwind:** snapshot coverage for the icon and icon-only variants.

**Accessibility:** sandbox section with a scoped `assert_accessible`, covering the `hide_label` variant specifically. Use generic icon names per the sandbox convention.

## Docs

- New `f.submit` section in `docs/component/form.md` under Level 1 native overrides, documenting all options. `f.submit` is currently undocumented in both `form.md` and the README, so this is a new section rather than an edit. Include the note that `hide_label` here targets the button's own span.
- `docs/architecture.md:25-31` icon-only contract updated with the second selector — its own text requires this whenever `Button::LAYOUT` changes.

## Out of Scope

- Icon support on `sp_button` (already exists) or on other Level 1 native overrides.
- Changing how `Form::Field#hide_label` works for regular fields.
- Retrofitting `ArgumentError` enforcement onto `sp_button`'s icon-only path.
