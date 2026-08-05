# Password Strength: Live Meter + Rules Checklist

**Date:** 2026-07-20
**Status:** Approved, not yet implemented
**Packages:** `stimulus-plumbers` (JS), `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`
**Depends on:** `2026-07-20-input-revealable-extraction-design.md` (landed; this spec assumes
that markup exists but does not modify it)

## Problem

Password fields enforce complexity rules server-side, so users learn they failed only after
submitting. The reference implementation this generalizes
(`fundravel/app/javascript/controllers/password_requirements_controller.js`) solves the
feedback half but has two defects worth not inheriting:

1. **Color-only rule state** — it toggles a `text-fern-600` class and nothing else, so rule
   status is invisible to screen readers and fails WCAG 1.4.1 (Use of Color).
2. **No strength summary** — a user satisfying 2 of 4 rules sees two green lines and no sense
   of overall progress.

## Solution

Two affordances driven by one computation:

```
[ password input                    ] [eye]
[=========>              ] Fine

  ✓ At least 12 characters
  ✓ One uppercase letter
  ✗ One number
  ✗ One symbol
```

The meter answers "how am I doing"; the checklist answers "what do I fix". The checklist is
the part that makes the requirement understandable — a bare meter says "weak" without saying
why.

## What already exists

Most of the machinery is in place and is reused unchanged:

- `progress_controller.js` has a `meter` variant wrapping native `<meter>` with
  `low` / `high` / `optimum` — exactly weak/fine/strong semantics, with browser-native ARIA.
  It exposes a public `setValue()`.
- `Components::ProgressMeter` (`components/progress_meter.rb`) renders that markup, helper
  `sp_progress_meter`.
- `Requestor` (`src/requestor.js`) provides `schedule(fn, delay)` — a debouncer — and
  `cancel()`. Precedent for a controller using it purely as a debouncer:
  `combobox_dropdown_controller.js:52`.
- `Plumber::Config` is the base for configuration block DSLs (as opposed to `Plumber::Slots`,
  which captures content); `Components::Combobox::Config` is the model to follow. See
  `2026-07-20-plumber-config-pattern-design.md`.

**`progress_controller.js` is not modified by this work.** The outlet call is the entire
integration.

## Architecture

### `stimulus-plumbers/src/plumbers/password_strength.js` (new)

Pure scoring, no DOM. Mirrors `plumbers/formatter.js` structurally: a `registry` Map, a
static `register(type, scorer)`, a default scorer, and
`attachPasswordStrength(controller, options)` defining a `strength` getter on the controller.

Scorer contract — one method:

```js
score(password, options) → { value, level, rules }
```

- `value` — Number, 0–100, for the meter
- `level` — `'weak' | 'fine' | 'strong'`. `strong` requires every enabled rule; `low` splits
  `weak` from `fine`. `RulesScorer` ignores `high` — with few rules "one missing" scores above
  any fixed high (2/3=67, 3/4=75), which would read strong with a rule visibly unmet.
- `rules` — `{ [ruleKey]: Boolean }`, one entry per configured rule

The default `RulesScorer` computes `value` as `satisfied / total × 100` and evaluates these
rule keys: `length` (`minLength`/`maxLength`), `uppercase`, `lowercase`, `digit`, `symbol`.
A rule is evaluated only when enabled in options.

Registration mirrors `Formatter.register`, so an app can supply entropy-based scoring
without this library taking a dependency:

```js
PasswordStrength.register('entropy', { score: (pw, opts) => ({ value, level, rules }) });
```

Export from `src/index.js` and add a row to the Utilities table in
`stimulus-plumbers/README.md` per the Doc Update Rule.

### `stimulus-plumbers/src/controllers/password_strength_controller.js` (new)

DOM only.

```js
static targets = ['input', 'rule', 'level'];
static outlets = ['progress'];
static values = {
  scorer:        { type: String, default: 'rules' },
  options:       { type: Object, default: {} },
  announceDelay: { type: Number, default: 700 },
};
```

On input:

1. `const { value, level, rules } = this.strength.score(this.readValue(), this.optionsValue)`
2. `if (this.hasProgressOutlet) this.progressOutlet.setValue(value)`
3. For each `ruleTarget`: set `data-satisfied` from `rules[target.dataset.rule]`, and swap the
   ✓/✗ icon pair using `setHidden` from `accessibility/aria.js` — the same two-icon technique
   the reveal toggle uses, including its both-or-neither gate: swap only when both icons are
   present, so a lone icon stays visible instead of leaving an empty row.
   **Use `setHidden`, never the `.hidden` property**: icons render as
   `<svg>`, which is not an `HTMLElement` and therefore has no `hidden` property; assigning it
   silently does nothing. This bug shipped in the reveal work and was caught only by probing
   the live DOM. Unit-test fixtures must use `<svg>` elements, not `<span>`, or they will not
   catch a regression.
4. If `level` differs from the previous level, `this._requestor.schedule(...)` updates the
   `level` target's text after `announceDelay`.

`disconnect()` calls `this._requestor.cancel()`.

**Two cadences, one input event.** Rule toggles and the meter update immediately — visual
feedback must feel instant. Only the announcement is debounced, and only on level change.

**Rule state lives in `data-satisfied`, not a CSS class.** The theme styles from the
attribute. This keeps CSS out of the JS controller, consistent with the rest of the library.

## Accessibility

- **1.4.1 Use of Color** — each rule carries a ✓/✗ icon *and* its text label. Color is never
  the sole indicator. This is the defect from the reference implementation that must not be
  inherited; the a11y test asserts it explicitly.
- **Announcement strategy** — the input is `aria-describedby` the rules list, so requirements
  are read on focus. `Form::Base#described_by` already composes hint and error ids; the rules
  list id joins that composition rather than replacing it.
- **The level label is visible, with `aria-live="polite"`.** A visually-hidden live region was
  considered and rejected: core has no sr-only theme key, so unthemed it would render as
  stray visible text. A visible "Weak / Fine / Strong" beside the meter is useful to sighted
  users anyway — native `<meter>` has no text of its own — and a visible live region is a
  normal, well-supported pattern.
- **Announce on level change only, debounced.** A live region firing on every keystroke
  interrupts the screen reader's echo of the character just typed, making the field harder to
  use rather than easier.

## Rails API

`Form::Builder#field` (`form/builder.rb:50`) does not currently accept a block. This adds
that capability, yielding a `Form::Fields::Inputs::Password::Config < Plumber::Config`:

```ruby
f.field :password, as: :password, revealable: true do |p|
  p.strength min_length: 12
  p.rule :digit,  "One number"
  p.rule :symbol, "One symbol"
end
```

- `p.strength(**options)` — enables the meter and checklist. Accepts `min_length`,
  `max_length`, `uppercase`, `lowercase`, `digit`, `symbol`, and meter thresholds
  `low` / `high` / `optimum` (defaults 34 / 100 / 100). `high: 100` keeps the meter's top band
  aligned with the JS `strong` level.
  **Thresholds are emitted twice, from one source:** as `low`/`high` inside the controller's
  `options` JSON, because `score()` derives `level` from them and receives nothing else; and
  as attributes on the `<meter>`, which drives native coloring. Emit them from a single
  keyword so the label and the bar can never disagree.
- `p.rule(key, label)` — overrides or adds a rule row. `key` must be one of `length`,
  `uppercase`, `lowercase`, `digit`, `symbol`; anything else raises `ArgumentError` listing
  the known keys, in the style of the `unknown field type` raise at `form/builder.rb:75`. An
  unrecognised key would otherwise render a checklist row the scorer never evaluates — a
  requirement the user can see but can never satisfy.
- `p.strength` alone derives the default rule set from its options with I18n labels, so the
  common case is one line.

**Rules merge lazily, at read.** `p.strength` does not populate rules when called; the
builder derives defaults from its options only when the rule list is read, then merges
explicit `p.rule` entries over them. The DSL is therefore order-independent — `p.rule` above
or below `p.strength` gives the same result. Deriving eagerly would let a `p.rule` written
first be silently clobbered by a later `p.strength`.

**An override keeps the derived row's position.** Changing a label must not reorder the
list, since it renders top-to-bottom under the input. Keys not present in the derived set are
appended in declaration order (Ruby hashes preserve insertion order, so a plain `Hash`
accumulator gives this for free).

```ruby
p.strength min_length: 12, digit: true, symbol: true
p.rule :digit, "Must contain a number"
# ✓ At least 12 characters
# ✓ Must contain a number   ← keeps the derived slot, not moved to the end
# ✓ One symbol
```

Blocks on non-password field types are out of scope; `field` yields only when the renderer
supports it.

### Rendered structure

```html
<div data-controller="password-strength"
     data-password-strength-options-value='{"minLength":12,"digit":true,"symbol":true,"low":34,"high":100}'
     data-password-strength-progress-outlet="#pw-meter">
  <label for="pw">…</label>
  <div input-group>
    <input id="pw" type="password" aria-describedby="pw-rules"
           data-password-strength-target="input"
           data-action="input->password-strength#score">
    <button …>  <!-- reveal toggle, from the prior spec -->
  </div>
  <!-- Render via sp_progress_meter — do not hand-write. It emits data-progress-target="meter",
       without which renderMeter() bails on !hasMeterTarget and setValue() paints nothing. -->
  <meter id="pw-meter" data-controller="progress" data-progress-target="meter"
         data-progress-variant-value="meter"
         min="0" max="100" low="34" high="100" optimum="100">
  <p data-password-strength-target="level" aria-live="polite">Weak</p>
  <ul id="pw-rules">
    <li data-password-strength-target="rule" data-rule="digit" data-satisfied="false">
      <svg check icon hidden aria-hidden="true">…</svg>
      <svg close icon aria-hidden="true">…</svg>
      One number
    </li>
  </ul>
</div>
```

The field wrapper wires every id itself — callers never hand-wire outlet selectors or
`aria-describedby`, which is where accessibility wiring usually breaks.

### Icons

Use generic names `check` and `close` per the Accessibility Test Convention (the core sandbox
runs unthemed, so heroicon names do not resolve). Both already resolve under Tailwind —
`close` → `x-mark` is in `Icon::ALIASES` and `check` is a heroicon name — so no alias work is
needed. Unresolved names render as blank spans, which is acceptable and already the norm
unthemed.

### Theme keys

New keys in `themes/schema.rb`, added to the `FORM` group, all rendering as no-ops in Base:

`password_strength_wrapper`, `password_strength_rules`, `password_strength_rule`,
`password_strength_rule_icon`, `password_strength_level`.

`progress_meter` already exists and is reused unchanged.

### Locale

New keys under `stimulus_plumbers.form.password` in `config/locales/en.yml`: default rule
labels (`rules.length`, `rules.uppercase`, `rules.lowercase`, `rules.digit`, `rules.symbol`)
and level names (`levels.weak`, `levels.fine`, `levels.strong`).

## Testing

### JS unit

`tests/unit/plumbers/password_strength.test.js` (new):
- each rule key evaluates correctly, including `length` against both bounds
- `value` at boundaries: no rules satisfied → 0, all satisfied → 100
- `level` maps around `low`, and is never `strong` while any rule is unsatisfied
- a registered custom scorer takes precedence; an unknown scorer type falls back to `rules`

`tests/unit/controllers/password_strength_controller.test.js` (new):
- typing toggles `data-satisfied` and swaps the icon pair on the matching rule target
- a rule row with only one icon keeps it visible; `data-satisfied` still flips
- the progress outlet receives `setValue` with the computed value
- markup without a progress outlet scores without error
- the level target updates after the debounce, and **only** when the level changed —
  assert no update when the score moves within a level

### Ruby unit

`test/stimulus_plumbers/form/fields/inputs/password_test.rb` (extend):
- the builder block renders meter, level, and rules list
- `p.strength` alone derives the default rules; explicit `p.rule` overrides them
- `p.rule` before `p.strength` and after it produce identical output — the order-independence
  the lazy merge exists to guarantee
- an overridden rule keeps its derived position; a genuinely new key is appended last
- `p.rule` with an unknown key raises `ArgumentError`; assert the literal message
- the input's `aria-describedby` includes the rules list id *and* still includes hint and
  error ids when those are present
- the outlet selector on the wrapper matches the meter's id, and the meter carries
  `data-progress-target="meter"` — without it the outlet resolves but never paints
- custom thresholds appear both in the options JSON and as `<meter>` attributes
- no block → markup identical to today (no strength UI, no controller)

Assert literal English strings, never `I18n.t(...)`, per the I18n convention.

### Accessibility

New sandbox page wrapped in `<div id="password-strength">`, with `assert_accessible
context: "#password-strength"`. Assert that rule state is conveyed by icon and text, not
color alone — type into the field, then assert the satisfied rule exposes a non-color
indicator.

### Visual snapshots

New snapshot coverage in `stimulus-plumbers-tailwind/test/snapshots/` for weak, fine, and
strong states.

## Out of scope

- Modifying `progress_controller.js` or `ProgressMeter`. Both are reused as-is.
- Server-side validation or parity between these client rules and model validations. The
  rules configured here are a UX affordance; the server remains the enforcement point.
- Entropy or dictionary-based scoring. The registry makes it available to apps; this library
  ships rule-count only and takes no runtime dependency.
- Config blocks on field types other than `:password`.

## Resolved: reveal now lives in its own controller

Superseded by `2026-07-20-input-revealable-extraction-design.md`. Reveal moved out of
`input-formatter` into a dedicated `input-revealable` controller, so the naming concern is
moot — the values are `revealLabel` / `concealLabel` on a controller that owns nothing but
reveal, and the `formatValue === 'password'` special cases are gone.

Two things this spec should inherit from that controller rather than reinvent:

- **Reveal markup is `input-revealable`, not `input-formatter`.** The `<button …>` in the
  rendered structure above carries `data-input-revealable-target="toggle"`.
- **Icon pairs are all-or-nothing.** `input-revealable#draw` swaps icons only when both
  targets are present; a lone icon stays visible so the button never renders empty. The ✓/✗
  rule icons here should follow the same rule — both or neither.
