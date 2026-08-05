# Dedicated a11y + Snapshot Coverage for the Password Field

**Date:** 2026-07-20
**Status:** Approved, not yet implemented
**Packages:** `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`
**Blocked by:** `2026-07-20-password-strength-meter-design.md` — nothing here is implemented
until the strength meter lands. This spec **supersedes that spec's Accessibility and Visual
snapshots sections**; its Ruby-unit and JS-unit sections stay where they are.

## Problem

Password has no dedicated coverage at either visual layer. What exists is incidental:

| where | what it actually tests |
| --- | --- |
| `form.spec.js` → `sign up form` | a password field inside a whole-form integration page |
| `form.spec.js` → `floating label form` | floating variants × revealable (8 baselines) |
| `form_accessibility_test.rb` | axe over `#sign-up` with the password revealed |
| `floating_label_accessibility_test.rb` | axe over `#floating-label-filled-revealable`, closed and revealed |

Two consequences. Reveal is only ever exercised as a side effect of testing something else,
so there is no page where password states can be compared against each other. And strength —
meter, level, rules checklist — has no home at all, because the feature does not exist yet.

Every other form input with real behaviour already has a dedicated page: `code`,
`credit_card`, `choices`, `fieldset`, `field_error`. Password is the outlier.

## Solution

One sandbox page per gem, one snapshot spec, one accessibility test.

### Sandbox page — `/form/password`

Added to **both** sandboxes: `stimulus-plumbers-rails/test/sandbox` (themeless, drives axe)
and `stimulus-plumbers-tailwind/test/sandbox` (themed, drives pixels). Each needs:

- `get :password` in `test/sandbox/config/routes/form.rb`
- `FormController#password`
- `test/sandbox/app/views/form/password.html.erb`

Five sections, per the multi-variant convention in `stimulus-plumbers-rails/CLAUDE.md`:

```
#password-default              plain, no reveal, no strength
#password-revealable           revealable: true
#password-strength             strength block, no reveal
#password-strength-revealable  both
#password-error                error + revealable
```

Mirror `floating_label.html.erb`'s locals rather than inventing a new shape — a `fresh`
form object and an `error_form` built with `.tap { |f| f.errors.add(:password, ...) }`,
both declared at the top of the view.

Icon names must be generic (`close`, `check`). The rails sandbox runs with no theme, so
heroicon compound names will not resolve.

### Snapshots — `stimulus-plumbers-tailwind/test/snapshots/password.spec.js`

Nine tests, 18 baselines (every test renders at both `desktop` and `mobile`):

| section | tests |
| --- | --- |
| `#password-default` | default |
| `#password-revealable` | hidden, revealed |
| `#password-strength` | empty, weak, fine, strong |
| `#password-strength-revealable` | revealed |
| `#password-error` | error |

All three levels are snapshotted. `fine` is the only one whose `<meter>` coloring depends on
both `low` and `high`, so it is where a threshold off-by-one shows up.

**Assert state before screenshotting.** `form.spec.js:3` already establishes why — *"A broken
toggle still renders unchanged pixels, so assert reveal state directly."* Apply the same rule
to strength:

- reveal → input `type`, the `Hide password` label, both icon targets
- strength → the `<meter>` value and the rules' `data-satisfied` attributes

A screenshot alone cannot distinguish a working controller from a dead one that happens to
render the same pixels.

### Accessibility — `test/accessibility/form/password_accessibility_test.rb`

`PasswordAccessibilityTest`, visiting `/form/password`. Six `assert_accessible` calls, scoped
per section, with reveal counted both closed and open:

```
#password-default
#password-revealable            (closed)
#password-revealable            (after clicking Show password)
#password-strength              (empty)
#password-strength              (after typing)
#password-error
```

Plus one structural assertion the strength spec requires and axe cannot make: after typing,
assert the satisfied rule exposes a **non-color** indicator. WCAG 1.4.1 Use of Color is not
machine-checkable, and rule state is the one place in this component where color could
silently become the sole signal.

That is the only non-axe assertion in the file. Every other structural check — the
`aria-describedby` composition, the outlet selector, the `data-progress-target="meter"`
wiring — belongs to `password_test.rb` and is already specified by the strength spec.

## Behaviour is out of scope here

Debounce timing, level-change-only announcement, and rule toggling are already specified as
`tests/unit/controllers/password_strength_controller.test.js`. They are asserted there with
fake timers, deterministically, at no baseline cost. This spec does not restate them.

The rule: **snapshots capture static visual states; unit tests capture behaviour.** A 700ms
debounce driven through a real browser is the classic source of CI flake, and it buys nothing
a fake timer does not already prove.

## Removals

From `stimulus-plumbers-tailwind/test/snapshots/form.spec.js`, `sign up form` describe:

- `test("password revealed")` — superseded by `#password-revealable`
- `test("floating labels — password revealed")` — duplicates the `floating label form`
  describe's `outlined revealable → revealed`, which stays

Delete their four baselines:

```
sign-up-password-revealed-{desktop,mobile}-linux.png
sign-up-floating-password-revealed-{desktop,mobile}-linux.png
```

From `form_accessibility_test.rb`: `test_passes_wcag_with_password_revealed`.

`sign up form`'s `default` and `floating labels` tests stay — they contain a password field
but are not password tests. Everything under `floating label form` stays untouched: floating
× revealable is a genuine cross-cutting interaction, and its 8 baselines and 2 a11y tests are
the only coverage of it.

Net: **+14 baselines** (18 added, 4 removed).

## Edits to the strength spec

Replace its **Accessibility** and **Visual snapshots** sections with a pointer to this
document. Both currently describe a sandbox page and snapshot coverage in outline
(`<div id="password-strength">`, "weak, fine, and strong states"), which this spec supersedes
in full. Two specs describing one sandbox page violates the no-cross-doc-duplication rule in
the root `CLAUDE.md`.

Its **Ruby unit** and **JS unit** sections are feature tests, not coverage design, and stay
exactly as written.

## Conventions this must honour

- **No `I18n.t(...)` in tests.** Assert `"Show password"` / `"Hide password"` as literals, so
  the test fails when the string changes.
- **Scope axe to the section**, never the page: `assert_accessible context: "#password-strength"`.
- **Test outcomes, not utilities.** Assert `data-satisfied` and semantic tokens, not Tailwind
  class names.

## Sequencing

Nothing ships until the strength meter is implemented. The reveal half — the page skeleton,
`#password-revealable`, `#password-error`, and the sign_up removals — could technically land
earlier, but splitting it means two passes over the same five files and two baseline
regeneration cycles. One pass, after strength.

Baselines are linux-only and must be generated by dispatching `ci-snapshots.yml`. They cannot
be produced on a developer machine: running Playwright on darwin finds no matching baseline
and writes a parallel `-darwin` set into the repo.

## Out of scope

- Generalising `revealable:` beyond `as: :password`. It is currently a keyword on
  `password_field` and `render_password_input` only. The `api_key` case the extraction spec
  documents still routes through `as: :password` and renders identically, so it earns no
  section and no baseline here.
- The stale `Status: Approved, not yet implemented` on
  `2026-07-20-input-revealable-extraction-design.md`. The controller shipped in `7aab4f36`;
  correcting that header is a separate, unrelated edit.
- `floating_label`'s revealable coverage, in either direction.
