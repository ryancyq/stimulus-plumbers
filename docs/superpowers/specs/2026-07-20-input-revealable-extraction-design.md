# Extract `input-revealable`; Remove Masking

**Date:** 2026-07-20
**Status:** Approved, not yet implemented
**Packages:** `stimulus-plumbers` (JS), `stimulus-plumbers-rails`
**Supersedes the JS half of:** `2026-07-20-password-reveal-two-icon-design.md` — merged as
PR #185 (`3391853f`), with the SVG `hidden` fix in `7abb7ebd`. Its two-icon behavior is
preserved but moves to a new controller.
**Blocks:** `2026-07-20-password-strength-meter-design.md` (re-point after this lands)

## Problem

Password reveal lives inside `input-formatter`, which is a formatting controller. The
coupling is not real:

- **Password never formats.** `onFormatting()` returns early for `format: "password"`, so
  neither `format()` nor `mask()` is ever called. `'password'` is not in `FORMATTER_TYPES`
  either — `registry.get('password')` misses and falls through to `PlainFormatter`, whose
  pass-through `format` is never invoked. "The password formatter" does not exist; it is a
  special-case branch that borrows the controller's `revealed` boolean and toggle UI.
- **The shared state serves nothing else.** `revealedValue`'s other job is choosing
  `format()` vs `mask()` for maskable formatters — and no shipped formatter implements
  `mask()`.

So one controller carries two unrelated mechanisms joined by a single boolean.

## Analysis: `format()` vs `mask()`

`format` is lossless and reversible; `mask` is lossy and irreversible.

```js
// credit_card.js — presentational regrouping
'4242424242424242'  →  '4242 4242 4242 4242'   // normalize() inverts it

// the only mask() anywhere in the repo (a test fixture)
mask: (value) => value.replace(/./g, '*')
'hello'  →  '*****'                             // nothing inverts it
```

`onFormatting()` writes the result back into the target. For `format` that is safe — the
value round-trips through `normalize()` on the next keystroke. For `mask` it **destroys the
user's data**: an editable `<input>` literally becomes `*****`, and the next `onInput`
normalizes the asterisks as if they were real. That is why every maskable test fixture uses
`<output>` rather than `<input>`.

| | `format` | `mask` |
| --- | --- | --- |
| Reversible | yes, via `normalize` | no |
| Safe target | editable `<input>` | read-only `<output>`, cells |
| Purpose | readability | obfuscation |
| Shipped implementations | 6 formatters | **zero** |

## Decisions

### Remove masking entirely

Client-side masking provides no security — the full value is already in the DOM, so `mask()`
only changes what is painted. If a value is sensitive enough to mask, the server should send
`•••• 4242` and never send the rest.

The one legitimate client case is reveal-on-demand for a value the user is entitled to see
(API key, recovery code). That is served better by `input[type=password]`, which never
mutates the value — exactly what the password path already does.

And the implementation cannot safely do the thing that would justify it: a masked *editable*
field would need a shadow value the controller does not have.

A feature with no users, no security value, a destructive failure mode on its most natural
target, and a better alternative in the same controller. Removed from **both** the controller
and the `Formatter` plumber (pre-1.0; keeping a helper whose only consumer is being deleted is
debt).

### Extract `input-revealable`

Named for the `input-*` controller family (`input-formatter`, `input-clearable`,
`input-combobox`) and to match the Rails `revealable:` option, so the name is consistent
across the stack.

Scoped to "obscured input", not "password" — its actual job (flip `type`, swap two icons,
swap the label) has nothing password-specific in it, and it serves readonly secrets unchanged.

### Type swapping is the only mechanism; visual-only concealing was rejected

A `concealMode: 'type' | 'style'` variant was considered — obscuring a `type="text"` input
with `-webkit-text-security: disc` so API-key fields would not attract password managers.
Rejected after probing Chromium directly:

```json
{"supportsProp":true,"cssSupportsDisc":true,
 "passwordWithNone":"disc","textWithDisc":"disc"}
```

`-webkit-text-security: none` on a password input **computes back to `disc`** — the engine
enforces masking independently of the property. So a password field cannot be revealed by
CSS, and type swapping is not a legacy accident: it is the only portable mechanism that
exists. There is no version of this feature where the two modes are symmetric.

Shipping the `style` mode anyway would have added a non-standard property with unverified
Firefox support (fails open — shows the secret), plus a second concealing path that does not
hide the value from assistive technology, unlike `type="password"`. One mechanism, no feature
detection, no theme contract.

API-key fields therefore use `type="password"` like any other secret, and suppress
password-manager prompts through caller markup: `autocomplete="off"` plus vendor opt-outs
(`data-1p-ignore`, `data-lpignore="true"`).

### `revealLabel` / `concealLabel`

The codebase convention is modifier-first, noun-last: `dayFormat`, `monthFormat`,
`weekdayFormat`, `yearFormat`, `dateFormat`, `contentType`, `moveKey`, `minLength`,
`staleAfter`. `labelReveal`/`labelConceal` were the odd ones out. (Popover's
`announceOpen`/`announceClose` read as verb phrases, a different shape, not a competing
convention.)

This also settles the open genericness item from the reveal spec: in a controller named
`revealable`, these names are correct as-is.

## Changes

### `stimulus-plumbers` — new `src/controllers/input_revealable_controller.js`

```js
static targets = ['input', 'toggle', 'revealIcon', 'concealIcon'];
static values = {
  revealed:     { type: Boolean, default: false },
  revealLabel:  { type: String,  default: '' },
  concealLabel: { type: String,  default: '' },
};

toggle() { this.revealedValue = !this.revealedValue; }

revealedValueChanged() { this.draw(); }

draw() {
  if (this.hasInputTarget) this.inputTarget.type = this.revealedValue ? 'text' : 'password';
  if (!this.hasToggleTarget || !this.hasRevealIconTarget) return;
  setHidden(this.revealIconTarget, this.revealedValue);
  setHidden(this.concealIconTarget, !this.revealedValue);
  const label = this.revealedValue ? this.concealLabelValue : this.revealLabelValue;
  if (label) this.toggleTarget.setAttribute('aria-label', label);
}
```

No `connect()` hook is needed: Stimulus invokes `revealedValueChanged()` once during
initialization, so `draw()` already runs before connect. Adding `connect() { this.draw(); }`
would only double-draw.

### Markup owns the initial state; the controller owns transitions

The rendered markup **must** declare `type="password"`. If the controller were the source of
truth and markup shipped `type="text"`, any JS failure — bundle 404, CSP block, an error
earlier in initialization, Turbo morph timing — would render the secret in plaintext. The
field has to be obscured before JS runs.

The controller's connect-time write is therefore idempotent in the normal case (`revealed`
defaults to `false`, so it writes `password` over `password`). It is not removed, because it
correctly reconciles the one case that needs it: a server-set `revealed: true` against markup
that renders `password`.

**Use `setHidden` from `accessibility/aria.js`, never the `.hidden` property.** Icons render
as `<svg>`, which is not an `HTMLElement` and has no `hidden` property; assigning it silently
does nothing. This bug shipped in the reveal work and was caught only by probing the live DOM.

`toggle()` loses its guard — there is no `maskable()` to consult and no reason to refuse. The
toggle button is never hidden at connect: its presence means the field is revealable, so
`drawToggle()`'s `hasToggleBehavior` concept disappears.

Export from `src/index.js`; add a row to the Controllers table in `README.md`.

### `stimulus-plumbers` — `input_formatter_controller.js` loses

`revealed` value; `toggle`, `revealIcon`, `concealIcon` targets; `labelReveal`/`labelConceal`
values; `toggle()`; `drawToggle()`; `revealedValueChanged()`; the `'password'` branch in
`onFormatting()`; and the masking in `cellsValue()` — which collapses to returning its
argument, so the method goes away and callers pass the value directly. Also drop the now-unused
`setHidden` import.

Left doing one job: normalize → format → write → cells.

### `stimulus-plumbers` — `plumbers/formatter.js` loses

`mask` and `maskable` from the helpers object (lines 55-56).

### `stimulus-plumbers-rails` — `form/fields/inputs/password.rb`

- `STIMULUS_CONTROLLER` → `"input-revealable"`
- `STIMULUS_ACTION` → `"click->input-revealable#toggle"`
- Drop the `input_formatter_format_value: "password"` data key
- Rename data keys: `input_revealable_target`, `input_revealable_reveal_label_value`,
  `input_revealable_conceal_label_value`

Icon rendering, the input-group wrapper, and all I18n stay as they are.

### `stimulus-plumbers-rails` — emit `autocomplete` on password fields

`password.rb` currently emits **no** `autocomplete` attribute, while `code.rb:41` and
`credit_card.rb:40` both emit defaults via `kwargs.delete(:autocomplete) ||
DEFAULT_AUTOCOMPLETE`. Follow that existing convention exactly — plain string passthrough,
no symbol sugar, no separate boolean:

```ruby
DEFAULT_AUTOCOMPLETE = "current-password"
```

```ruby
f.field :password, as: :password                                # sign-in (default)
f.field :password, as: :password, autocomplete: "new-password"  # registration
f.field :api_key,  as: :password, revealable: true,
                   autocomplete: "off"                          # API key display
```

**Why `current-password` and not `off`:**

1. **WCAG 1.3.5 Identify Input Purpose (AA)** requires a correct autocomplete token on fields
   collecting the user's own information. `ARIA.md:69` already invokes 1.3.5 as the reason
   `code.rb` emits `one-time-code`, so defaulting password to `off` would contradict the
   precedent this codebase already set.
2. **`autocomplete="off"` on password fields is largely ignored** — Chrome, Firefox, and
   Safari deliberately override it, because sites using it were suppressing password managers
   and pushing users toward weak, reused passwords.
3. **Sign-in is the dominant case.** The failure modes also favour it: `current-password` on a
   registration form may autofill the existing password (visible, mildly encourages reuse),
   whereas `new-password` on a sign-in form suppresses saved-credential autofill and can
   trigger generate-password UI — breaking the common path.

`off` remains correct for the API-key case: that field is not collecting the user's own
credential, so 1.3.5 does not apply, and suppressing the save prompt is the actual intent.

## No behavior change from dropping cell masking

`cellsValue()` could only mask when `maskable()` was true, which no shipped formatter ever
made true. OTP/code cells already always showed real values.

## Documentation

- New `stimulus-plumbers/docs/component/input-revealable.md`, including a **readonly secret**
  example (API key / recovery code). Note there that `type="password"` triggers
  password-manager heuristics, and that callers can suppress them with `autocomplete="off"`
  plus vendor opt-outs (`data-1p-ignore`, `data-lpignore="true"`) — caller markup, not
  controller behavior.
- Add a one-line note that non-input display elements (`<output>`, `<span>`, table cells) are
  **not supported**; if needed, the shape is server-rendered concealed/revealed elements
  swapped with `setHidden`, not a revived `mask()`.
- `input-formatter.md`: remove the password-reveal example, the `toggle` target row, the
  `revealed` value row, the `toggle()` action row, and the `"password"` formatter row.
- `docs/plumber/formatter.md`: remove `mask`/`maskable`.
- `ARIA.md`: re-point the Password Reveal pattern at `input-revealable`, keeping the existing
  rationale for why there is no `aria-pressed`.
- `stimulus-plumbers-rails/docs/component/form.md`: update any reveal wiring references.

## Testing

**New** `tests/unit/controllers/input_revealable_controller.test.js` — the reveal tests move
over roughly as-is:

- icon swap on toggle, asserted with `hasAttribute('hidden')` on **`<svg>`** fixtures (a
  `<span>` fixture cannot catch the SVG bug, and `.hidden` on an SVG is `undefined`, not
  `false`)
- label swaps to name the next action
- input `type` flips between `password` and `text`
- toggles without icon targets present, no throw
- readonly input: toggling does not alter `value`
- markup rendered `type="password"` with `revealed` defaulting false stays `password` after
  initialization (the connect-time write is idempotent)
- markup rendered `type="password"` with a server-set `revealed: true` reconciles to `text`

**Deleted** from `input_formatter_controller.test.js`: both `maskable type — custom formatter`
describe blocks and every toggle/reveal assertion.

**Deleted** from `tests/unit/plumbers/formatter.test.js` and the five built-in formatter tests
(`date`, `phone`, `plain`, `credit_card`, `currency`): `maskable()` assertions.

**Rails** `password_test.rb`: update the controller name, action, and data-key assertions.
Coverage stays equivalent. Add autocomplete coverage: the default is `current-password`, an
explicit `autocomplete:` overrides it, and `off` is emitted verbatim when passed.

**Accessibility**: existing password a11y tests should pass unchanged — the rendered ARIA is
identical, only the controller identifier changes.

**Snapshots**: no visual change from this work. Confirm the 4 revealed-state baselines were
regenerated when PR #185 merged; if not, that is a separate CI dispatch and not this change's
responsibility.

## Breaking changes

Pre-1.0. CHANGELOG handled separately by the maintainer.

- `mask()` / `maskable()` removed from the `Formatter` contract
- `format: "password"` removed as a formatter type
- `input-formatter`'s `toggle` target, `revealed` value, and `toggle()` action removed

## Out of scope

- Display-element revealing (`<output>`, `<span>`). Documented as unsupported with the shape
  it would take; not implemented.
- Visual-only concealing (`-webkit-text-security`). Considered and rejected — see decisions.
- CHANGELOG entries.
- Re-pointing the strength spec — a follow-up edit once this lands.

## Sequencing

Land this before the password strength meter, so the `password-strength` controller is
designed against the final markup rather than the interim shape.
