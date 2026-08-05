# Password Reveal: Two-Icon Toggle

**Date:** 2026-07-20
**Status:** Approved, not yet implemented
**Packages:** `stimulus-plumbers` (JS), `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`

## Problem

The revealable password field renders a single static `reveal` icon. State is conveyed
only by `aria-pressed` on the toggle button, and the accessible name stays
`"Show password"` in both states.

Two problems follow:

1. **No visual state.** Sighted users see the same eye glyph whether the password is
   masked or shown. Nothing in the button reflects which state they are in.
2. **Ambiguous announcement.** `aria-label="Show password"` combined with
   `aria-pressed="true"` announces as *"Show password, toggle button, pressed"*, which
   reads as either "the password is now shown" or "showing is engaged, press to show."
   Icon-only toggle buttons are the classic case where `aria-pressed` reads badly,
   because the accessible name describes an action rather than a state.

## Solution

One button, two icons. The button swaps which icon is visible and swaps its accessible
name; `aria-pressed` is removed.

```html
<button type="button"
        aria-label="Show password"
        data-input-formatter-target="toggle"
        data-action="click->input-formatter#toggle">
  <svg data-input-formatter-target="revealIcon"  aria-hidden="true">…</svg>
  <svg data-input-formatter-target="concealIcon" aria-hidden="true" hidden>…</svg>
</button>
```

After toggling:

```html
<button type="button" aria-label="Hide password" …>
  <svg data-input-formatter-target="revealIcon"  aria-hidden="true" hidden>…</svg>
  <svg data-input-formatter-target="concealIcon" aria-hidden="true">…</svg>
</button>
```

## Decisions

### Single button, not two

Two buttons (a "Show" and a "Hide" that swap visibility) was rejected. Hiding the
focused button drops focus to `<body>` — a 2.4.3 Focus Order failure that is worse than
any announcement concern. Avoiding it requires explicit `focus()` transfer on every
toggle path, layered on top of `drawToggle()`'s existing conditional hiding of the whole
button. Single button's worst case is a missed announcement; two buttons' worst case is
lost focus, with several easy-to-miss paths (Turbo morph, the non-maskable branch that
hides the button entirely, initial `drawToggle()` on connect).

### Icon names come from the theme's alias registry, not the schema

`theme.resolve(:x)` only ever calls `#{x}_classes` (`themes/base.rb:47-54`) — it is a CSS
class channel and cannot carry icon names. Icon names resolve through `theme.icons`, the
alias registry where `"reveal" => "eye"` already lives
(`stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/icon.rb:19`).

**No new schema key.** Rails renders the generic names `"reveal"` and `"conceal"`; each
theme aliases them to its own glyph set.

**No single-icon fallback branch.** An unresolved icon name does not raise —
`Icon#render` (`components/icon.rb:18-23`) emits an empty `<span>`. That is already what
the unthemed core sandbox does for `"reveal"` today. So `password.rb` always renders both
icons; a theme lacking a `conceal` glyph gets a blank span exactly as it currently would
for `reveal`. There is no `theme.icons.key?` gate and no degraded path to test.

### `aria-pressed` is dropped; the accessible name changes instead

WCAG 4.1.2 requires state to be programmatically determinable *only if the control has
state*. A button whose accessible name states the next action is not a toggle — there is
no state to expose. This is the pattern GOV.UK and the WAI password tutorials use.

**Known tradeoff:** screen readers announce `aria-pressed` changes on the focused element
more reliably than they announce accessible-*name* changes. There is a scenario where an
SR user activates the button, focus stays put, and they hear nothing back. Two things
mitigate it: the input's `type` flips between `password` and `text` (screen readers treat
password inputs distinctly, so moving to the field gives an independent cue), and the
change is user-initiated on the element they are already on.

A visually-hidden `aria-live` region announcing "Password shown" / "Password hidden" was
considered and **rejected** — it adds a chatty region for a state the input itself already
conveys.

**This rationale must be recorded in `ARIA.md`** so the decision is not silently reverted.

### Label strings reach JS via Stimulus Values

Two new values on the `input-formatter` controller, populated by Rails from I18n. Keeps
all copy in `en.yml` and out of the controller. Reading the strings from `data-`
attributes on the button is the same idea with a weaker contract.

## Changes

### `stimulus-plumbers` (JS)

`src/controllers/input_formatter_controller.js`:

- Add `revealIcon`, `concealIcon` to `static targets`.
- Add to `static values`:
  ```js
  labelReveal:  { type: String, default: '' },
  labelConceal: { type: String, default: '' },
  ```
- `drawToggle()`: remove the `setPressed(this.toggleTarget, this.revealedValue)` call.
  Add, guarded by `hasRevealIconTarget`, the icon swap and the label swap:
  ```js
  this.revealIconTarget.hidden  = this.revealedValue;
  this.concealIconTarget.hidden = !this.revealedValue;
  ```
  Set `aria-label` to `labelRevealValue` when `revealedValue` is false and to
  `labelConcealValue` when it is true — the label always names the *next* action, matching
  the icon that is visible. Leave the existing label untouched when the applicable value
  is empty.
- Remove the now-unused `setPressed` import (line 2). Verify no other caller —
  `drawToggle()` is its only use site.

`drawToggle()`'s existing behavior is otherwise unchanged: it still hides the entire
toggle button when the formatter is not maskable and the format is not `password`.

### `stimulus-plumbers-rails`

`lib/stimulus_plumbers/form/fields/inputs/password.rb`:

- `reveal_button` renders two `Components::Icon` calls — `"reveal"` and `"conceal"` —
  each with `size: :sm`, `aria: { hidden: "true" }`, `theme.resolve(:button_icon)`, and
  its respective `data-input-formatter-target`. The conceal icon also gets `hidden: true`.
- `build_reveal_button` drops `aria: { pressed: "false" }`, keeps
  `aria: { label: … "Show password" }`.
- `render_revealable_password` adds the two label values to the controller element's data:
  ```ruby
  input_formatter_label_reveal_value:  I18n.t("stimulus_plumbers.form.password.show", default: "Show password"),
  input_formatter_label_conceal_value: I18n.t("stimulus_plumbers.form.password.hide", default: "Hide password")
  ```

`config/locales/en.yml` — add `hide: "Hide password"` under `form.password`, beside the
existing `show:`.

### `stimulus-plumbers-tailwind`

`lib/stimulus_plumbers/themes/tailwind/icon.rb` — add `"conceal" => "eye-slash"` to
`Icon::ALIASES`, beside the existing `"reveal" => "eye"`.

## Documentation

Same commit, per the Doc Update Rule:

- `ARIA.md:63` — Password Reveal pattern currently reads "`aria-pressed` managed on toggle
  button, reflecting revealed state". Replace with the accessible-name-changes pattern and
  record the rationale above.
- `stimulus-plumbers/docs/component/input-formatter.md:78` — HTML example shows
  `aria-pressed="false"`; update to the two-icon markup.
- `stimulus-plumbers/docs/component/input-formatter.md:154` — cross-reference to ARIA.md
  mentions "`aria-label`/`aria-pressed` requirements"; update the wording.

## Testing

### Ruby unit — `test/stimulus_plumbers/form/fields/inputs/password_test.rb`

- **Remove** `test_reveal_toggle_button_has_aria_pressed_false` (line 65). Assert the
  button has no `aria-pressed` attribute at all.
- **Keep** `test_reveal_toggle_button_has_aria_label` — the server-rendered label is still
  `"Show password"`.
- **Add:** both icons render inside the button with their respective targets; the conceal
  icon carries `hidden` and the reveal icon does not; the controller element carries both
  label values.

Per the I18n convention, assert the literal strings `"Show password"` / `"Hide password"`,
never `I18n.t(...)`.

### JS unit — `tests/unit/controllers/input_formatter_controller.test.js`

- **Rewrite** `sets aria-pressed on the toggle button` (line 285) as the label-swap test.
- **Add:** toggling flips `hidden` on both icon targets; markup without icon targets still
  toggles without error (the `hasRevealIconTarget` guard).

### Accessibility

The core sandbox needs **no** `conceal` icon asset — both icons render as blank spans
unthemed, and the swap remains fully testable because the targets and `hidden` attribute
are what the tests assert.

Existing password a11y tests cover the masked state. Add revealed-state coverage via
`find(...).click` before `assert_accessible`, per the convention for interactive states.

Note that axe-core flags neither the old nor the new pattern, so `assert_accessible` will
not catch a regression here in either direction. Correctness lives in the unit tests
asserting the label swap.

### Visual snapshots

`stimulus-plumbers-tailwind/test/snapshots/form.spec.js` covers the password field.
Baselines will need regeneration once the eye-slash glyph appears.

## Out of scope

- Any other consumer of `input-formatter` — `password.rb` is the only renderer that emits
  a `toggle` button (verified by grep across `.rb`/`.erb`). Maskable formatters such as
  credit card have no toggle markup.
- The `revealable:` option's shape. It stays a boolean.
