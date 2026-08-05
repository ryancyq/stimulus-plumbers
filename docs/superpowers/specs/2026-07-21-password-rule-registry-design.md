# Password Rule Registry + client/server `valid?` — Design

**Date:** 2026-07-21
**Packages:** `@stimulus-plumbers/controllers` (npm), `stimulus-plumbers` (Rails gem)
**Status:** Approved, pending implementation plan

## Goal

Turn password strength from a client-only, hardcoded-rule feature into a
declarative rule set that is (a) extensible with custom rules, and (b) usable
as the **server-side enforcement point** via `ActiveModel` validation — with a
single rule definition driving both the live client meter and server
validation.

## Motivation

Today the Rails gem evaluates nothing: `Password::Config` emits option keys,
and all scoring happens client-side in `password_strength.js` against a
hardcoded `matchers` table. There is no `valid?`, no custom rules, and no
server enforcement. This design adds server enforcement without creating two
drifting implementations of each rule.

## Decisions (locked during brainstorming)

- **`valid?` job:** ActiveModel enforcement — the server is the real gate.
- **Custom rules run on both client and server** (live meter + server
  enforcement), so rule definitions must cross the JS/Ruby boundary.
- **Parity architecture:** a shared *declarative* rule contract (Approach 1),
  not dual registries. Rules are data, not code.
- **`valid?` semantics:** `true` iff every enabled rule passes (≡ `strong`).
  Thresholds (`low`/`high`/`optimum`) are meter-coloring only and do not affect
  `valid?`.
- **Built-ins are opt-in** (enable by key, as today). "Disable" = "don't
  enable"; no separate disable API.
- **Character-class rules support occurrence counts** (`min`/`max` on how many
  matches), not just "contains one." This unifies presence, negation, and
  length into a single `min ≤ n ≤ max` evaluator.

## Section A — Component boundaries & naming

Rule definitions must be usable outside the form (inside a model validator), so
they cannot stay coupled to the form-field DSL.

- **`Password::Config → Password::Requirements`** — rename the existing class
  and give the *same* object the evaluation + serialization responsibilities.
  It keeps its block DSL (`strength`, `rule`) and gains `evaluate`, `valid?`,
  `to_stimulus`. One class, one concept.
- **`Requirements` does NOT inherit `Plumber::Config`.** `Plumber::Config` is
  the sibling-of-`Slots` substrate for *component* block DSLs that hold a
  `template` for renderers. `Requirements` never renders and never uses
  `template`, and is now built inside model-layer validators — so inheriting a
  view-layer base with an unused `template` would be a layering smell.
  `Requirements` becomes a standalone plain object holding its own state (two
  ivars: strength options + rule overrides). It re-implements ~5 lines of
  trivial state rather than dragging in the base.
- **`Plumber::Config` is unchanged** and still backs `Combobox::Config`, which
  genuinely uses `template` (`render_panel`).
- Out of scope: the `Combobox::Config → Variant` rename (unrelated to this
  feature).

## Section B — The shared rule contract

Every rule serializes to a uniform descriptor: `{ key, label, pattern?, min, max }`,
evaluated by a **single rule — `min ≤ n ≤ max`** — where `n` is:

- **length** (no `pattern`) — the password length.
- **count** (with `pattern`) — the number of occurrences of `pattern` in the
  password: Ruby `password.scan(Regexp.new(src)).size`, JS
  `(pw.match(new RegExp(src, "g")) || []).length`.

Defaults for count rules: `min` 1, `max` unbounded (`nil`/`Infinity`). This
folds three former cases into one:

- "at least one uppercase" → `{ pattern: "[A-Z]", min: 1 }`
- "at least 2 digits" → `{ pattern: "\\d", min: 2 }`
- "at most 3 symbols" → `{ pattern: "[^A-Za-z0-9]", max: 3 }`
- "no spaces" (former `negate`) → `{ pattern: "\\s", min: 0, max: 0 }`

`negate` is no longer a wire field; `negate: true` in the DSL is sugar for
`min: 0, max: 0`.

**Serialization rule:**
- **Count rules** (uppercase/lowercase/digit/symbol/custom): `min` is
  **mandatory** (defaults to `1`, always emitted); `max` is **optional** —
  omitted when unbounded, and the consumer treats a missing `max` as `Infinity`.
- **Length rule:** both `min` and `max` are **mandatory** — a length rule is a
  bounded range and always emits both ends. Enabling length therefore requires
  both `min_length` and `max_length`; omitting `max_length` raises
  `ArgumentError` (see Section C).

**Portability constraint (enforced by convention, documented):** patterns are
**single-char-consuming character classes** only — **no** anchors
(`^`/`$`/`\A`/`\z`), lookbehind, or unicode-property escapes. Because each match
consumes exactly one character, non-overlapping occurrence counts agree across
the Ruby and JS regex engines. All 5 built-ins satisfy this; custom rules must
too.

Built-in descriptors (the only definition of each, written Ruby-side):

| key       | descriptor                       |
|-----------|----------------------------------|
| length    | `{ min: min_length, max: max_length }` |
| uppercase | `{ pattern: "[A-Z]", min:, max: }`   |
| lowercase | `{ pattern: "[a-z]", min:, max: }`   |
| digit     | `{ pattern: "\\d", min:, max: }`     |
| symbol    | `{ pattern: "[^A-Za-z0-9]", min:, max: }` |

## Section C — Ruby evaluation + ActiveModel validator

**`Password::Requirements`:**

- A module-level table defines the 5 built-ins as descriptors.
- Resolves the enabled set (opt-in by key) plus customs.
- **Count DSL for character-class built-ins** — the option value sets `min`/`max`:
  `digit: true` → `min 1` (unchanged); `digit: 2` → `min 2`; `digit: 2..3` →
  `min 2, max 3`. `length` keeps its distinct `min_length`/`max_length` keys and
  **requires both** — enabling length without `max_length` raises
  `ArgumentError`.
- `evaluate(password)` → `{ rules: { key => bool }, value, level }`, each rule's
  boolean from `min ≤ n ≤ max` (n = length or occurrence count).
  `value` = satisfied/total × 100. `level` via the ported `levelFor`:
  `strong` when all pass; otherwise `low` (default 34) splits `weak` from
  `fine`.
- `valid?(password)` → all enabled rules pass (≡ `strong`).
- `to_stimulus` → serialized descriptors + thresholds + level labels (replaces
  today's `strength_stimulus_options`).

**Define once, consume in both places** (the parity-critical API). Declaring
rules separately in the form block and the validator would let them drift, so
the primary path is a shared `Requirements`:

```ruby
PASSWORD_RULES = StimulusPlumbers::Password::Requirements.build do |r|
  r.strength(min_length: 12, digit: true)
  r.rule(:no_spaces, pattern: /\s/, negate: true, label: "No spaces")
end

# model — server enforcement
validates :password, password_strength: { with: PASSWORD_RULES }

# form — same rules drive the live meter
f.field :password, as: :password, requirements: PASSWORD_RULES
```

Inline declaration still works in each place (form block; validator options
hash) for simple cases; docs steer toward the shared object whenever server
enforcement is in play.

**`PasswordStrengthValidator < ActiveModel::EachValidator`** — builds or accepts
a `Requirements`, calls `valid?`, and on failure adds an error naming the unmet
rules (reusing the rule labels), with an overridable message.

## Section D — JS controller goes data-driven

The JS controller holds **no built-in pattern table**. Ruby emits explicit
descriptors for every enabled rule (built-in and custom) via `to_stimulus`; the
controller evaluates purely from that data.

- `RULE_KEYS`, `matchers`, `enabledRules`, `satisfies` collapse into one generic
  evaluator over the uniform descriptor: compute `n` (password length when no
  `pattern`, else `(pw.match(new RegExp(pattern, "g")) || []).length`) and pass
  when `min ≤ n ≤ max`.
- Each built-in therefore has exactly one definition (Ruby's), shipped to JS —
  no second JS table to drift from.
- The residual parity risk reduces to "does `Regexp.new(src).match?` agree with
  `new RegExp(src).test` for the same `src`?" — a regex-engine-compat question
  the character-class constraint already answers, not a two-implementations
  question.
- Pure-JS standalone users supply rule descriptors directly (documented shape).
  The scorer registry (alternate scoring strategies) is untouched.

The controller gains a `rules` value (the descriptor array). `optionsValue`
retains only non-rule knobs (e.g. thresholds) if any remain.

## Section E — `valid?` semantics + testing/parity

**Semantics recap:** `valid?` is `true` iff every enabled rule passes.
Thresholds never affect it.

**Three test layers:**

1. **Ruby unit** (`requirements_test.rb`) — `evaluate`/`valid?` over: empty,
   each rule alone met/unmet, all-met, count rules (`min` 2, `max` 3), `negate`
   sugar (`min:0,max:0`), the `true`/int/range DSL forms, opt-in sets,
   thresholds not affecting `valid?`; and `to_stimulus` descriptor shape.
2. **JS unit** (extend `password_strength.test.js`) — the data-driven scorer:
   length min/max, occurrence counts (min/max), the `max:0` forbid case, mixed
   satisfied/unsatisfied, `level` boundaries; confirms the `matchers`/`RULE_KEYS`
   removal preserved outcomes.
3. **Parity test** — a shared JSON fixture of
   `(descriptor-set, password) → expected { rules, valid }` committed once and
   loaded by **both** suites: Ruby via `Requirements#evaluate`, JS via the
   scorer. One source of truth for expected results; any JS/Ruby disagreement
   turns one side red. The 5 built-in patterns get explicit coverage here since
   their `src` is the shared boundary.

**No new snapshot/a11y work** — rendered HTML is unchanged (meter + level +
rules list); it only gains descriptor data and, optionally, an app's server
error.

## Out of scope

- Non-regex / arbitrary predicates (breach-list, dictionary, entropy) — the
  contract is length + character-class occurrence counts only.
- `Combobox::Config → Variant` rename.
- On-by-default rules / a disable API.
