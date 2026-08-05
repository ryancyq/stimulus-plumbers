# CharacterCells — cell-based display for input-formatter

**Date:** 2026-07-18
**Status:** Approved design, pre-implementation

## Problem

OTP/verification-code entry needs the "row of character boxes" UX (one box per character,
seen in fundravel's `otp_boxes_controller.js`). Rather than a one-off OTP controller, this
design generalizes the mechanism so any fixed-alphabet string format (OTP, PIN, credit
card, IBAN, SWIFT) can render into cells through the existing `input-formatter` controller.

## Interaction model (decided)

One real `<input>` overlaid invisibly (`opacity: 0`) on a row of decorative cell elements.
The input owns all behavior — typing, backspace, paste, mobile SMS autofill — and the cells
are paint-only. No per-cell `<input>` elements, no roving focus.

## Format taxonomy (decided)

Formats group by what their value *is*; each group maps to one mechanism:

| Group | Formats | Value shape | Mechanism |
| --- | --- | --- | --- |
| 1. Fixed-alphabet codes | `code` (new), `creditCard`, registered types (IBAN, SWIFT) | One string over a known charset, known/max length | **CharacterCells** (this spec) |
| 2. Locale scalars | `currency` | Number; display width varies by locale/magnitude | Single-input formatting (unchanged) |
| 3. Composite values | `phone`, `date`, `time` | Multiple sub-values with independent bounds/rollover | Future `input-segments` primitive (out of scope; boundary only) |
| 4. Concealment-only | `plain`, `password` | String; masking/reveal only | Existing reveal toggle (unchanged) |

## Architecture

```
input-formatter (controller — identifier unchanged, no new controller)
├── Formatter plumber (existing)      strategies: normalize/validate/format/mask
│     └── + code formatter (NEW)      charset filtering + length validation
└── CharacterCells plumber (NEW)      paints one string into author-rendered cells
```

- No new controller. OTP = `input-formatter` + `format: "code"` + cell targets.
- CharacterCells activates only when `cell` targets exist → zero behavior change for
  every existing `input-formatter` usage.
- Cells are author-rendered HTML (server or static); the plumber adopts them and never
  generates DOM. "Dynamic length" = changing `length` re-derives which cells are active.

## CharacterCells plumber

**File:** `src/plumbers/character_cells.js`. `extends Plumber`; factory
`attachCharacterCells(controller, options)`; defines `controller.characterCells`
(mirrors `Formatter` / `attachFormatter`).

Named for its content — cells that each hold one character — not `input_cells`, because
the plumber never touches an input: it receives a string via `draw(value)` and is usable
by any string source.

### Options

| Option | Type | Default | Meaning |
| --- | --- | --- | --- |
| `groups` | `Number[]` | `[]` | Chunk widths, e.g. `[4,4,4,4]`. Empty = uniform 1-char cells. |
| `length` | `Number` | `0` | Expected value length. `0` = derive from cell count (uniform) or sum of `groups`. |

### Helpers (`controller.characterCells`)

| Helper | Behavior |
| --- | --- |
| `draw(value)` | Writes `value[i]` into each active cell's `textContent`, clears the rest, stamps state attributes. The single write path. |
| `clear()` | Sugar for `draw('')`. |
| `active()` | Number of cells in play (min of available cells and configured length). |

### Cell state — data-attributes, not classes

Fundravel toggled hardcoded Tailwind classes from JS; that couples behavior to one theme.
Instead:

- `data-filled` — cell holds a character
- `data-caret` — cell at the current input position, **only while the input has focus**
- `data-group-index` / `data-group-end` — grouping hooks for CSS gaps/separators
- `data-inactive` — cells beyond the configured length

Authors style via `[data-filled]` / `[data-caret]` selectors. The plumber never inserts
separator elements — separators are authored HTML or CSS decoration.

Mismatch handling: more cells than length → extras get `data-inactive`; fewer →
`console.warn` once, paint what fits.

## `code` formatter

**File:** `src/plumbers/formatters/code.js`, registered as `FORMATTER_TYPES.CODE = 'code'`.

| Option | Type | Default | Meaning |
| --- | --- | --- | --- |
| `charset` | String | `'alphanumeric'` | `'digits'` \| `'letters'` \| `'alphanumeric'` — `normalize()` strips everything else, uppercases letters |
| `length` | Number | `0` | `validate()` true only at exactly this length (`0` = any) |

`format()` returns the value unchanged (cells handle display). No `mask` — the reveal
toggle stays hidden via the existing `maskable()` check.

## input-formatter controller changes (all additive)

1. `connect()` also calls `attachCharacterCells(this, …)` when `cellTargets` exist.
   Options derive from the formatter's grouping hints (`code` → uniform; `creditCard` and
   registered types → their group pattern), overridable via an explicit `groups` value.
   The plumber's `length` is fed from the formatter's own length knowledge (`code`'s
   `length` option; a `groups` sum otherwise) — authors declare length once, in
   `options-value`, never twice.
2. `onFormatting()` additionally calls `this.characterCells?.draw(value)` after writing to
   the input target — cells always mirror the canonical (unmasked, unformatted) value.
3. New dispatch `input-formatter:filled` `{ value }` when a `code` value reaches its
   configured length — the OTP auto-submit hook.
4. For `code` only, `normalize()` output is written back to the input's own value (pasting
   `"4 8-29 13"` leaves `482913` in the field). Other formatters keep current behavior.
5. New event adapter `onInput(event)` → `format(this.readValue())`, wired via
   `data-action="input->input-formatter#onInput"` (per the `onX` convention).

### Canonical OTP markup

```html
<div data-controller="input-formatter"
     data-input-formatter-format-value="code"
     data-input-formatter-options-value='{"charset":"digits","length":6}'>
  <div class="cells-row">
    <div data-input-formatter-target="cell"></div>
    <!-- ×6 -->
  </div>
  <input data-input-formatter-target="input"
         autocomplete="one-time-code" inputmode="numeric"
         maxlength="6" data-action="input->input-formatter#onInput" />
</div>
```

## Accessibility

The real `<input>` is the entire accessible surface; cells are decoration.

- The plumber stamps `aria-hidden="true"` on adopted cells (via `src/accessibility/aria`
  helpers) — not left to authors, since omission causes double announcement.
- Docs mandate for the input: a `<label>` (visually hidden ok), `autocomplete="one-time-code"`
  for OTP (WCAG 1.3.5), `inputmode` matching charset, `maxlength` matching length, and the
  overlay uses `opacity: 0` — never `display:none`/`visibility:hidden` (kills focusability).
- Focus visibility (WCAG 2.4.7): `data-caret` only while focused; recommend styling
  `:focus-within` on the wrapper plus `[data-caret]`. Controller wires focus/blur re-draws.
- `ARIA.md` gains `#### Code Input (\`input_formatter_controller\`)` under
  Component-Specific Patterns; the component doc links to it (one fact, one place).

## Testing

- `tests/unit/plumbers/character_cells.test.js` — draw/clear, grouping attributes,
  filled/caret/inactive, aria-hidden stamping, mismatch warning.
- `tests/unit/plumbers/formatters/code.test.js` — charset normalization, length validation.
- `input_formatter_controller.test.js` additions — cells activate only with cell targets
  (regression: existing fixtures untouched), `filled` dispatch, paste write-back,
  focus/blur caret.

## Docs & packaging (same commit as implementation, per repo doc rule)

- `docs/component/input-formatter.md`: `cell` target, `code` formatter row, `groups`
  value, `filled` dispatch, OTP + credit-card-in-cells examples.
- New `docs/plumber/character-cells.md` (plumber factory API).
- `README.md`: no new Controllers row (no new controller); adjust `input-formatter`
  description if needed.
- MCP: no `EXPECTED_IDENTIFIERS` change (no new identifier); manifest rebuild picks up the
  new target/value automatically.

## Deferred (explicitly out of scope)

- `input-segments` composite primitive for phone/date/time (Group 3) — separate future spec.
- Rails helper (`sp_*`) and Tailwind theme for the cell UI — follow-up after the JS ships;
  no `input-formatter` Rails helper exists today.
- Currency/scalar cell rendering (variable width makes cells meaningless).
- DOM generation of cells by the plumber.

## Addendum (2026-07-19): grouped mode for credit card cells

After the Rails/Tailwind implementation landed, credit card cells changed from 16 one-char
cells (with a CSS margin gap between groups) to 4 cells — one per group — each showing that
group's whole slice of digits, with a literal dash `<span>` authored between cells.

This supersedes the "cells always hold exactly one character" framing above (`draw(value)`
→ `value[i]`) for credit card specifically. The mechanism, still additive and still cell-count
driven:

- **Grouped mode** is inferred, not a new option: `CharacterCells` compares the adopted cell
  count to `groups.length`. Equal → grouped (`draw()` writes `value.slice(groupStart,
  groupEnd)` per cell); otherwise → the original one-char-per-cell behavior. Width-1 groups
  degenerate to identical rendering either way, so this is safe even on a coincidental match.
- `data-group-end` no longer applies in grouped mode — the whole cell already *is* one group,
  so there's nothing to mark as "last in its group." The "separators are authored HTML, never
  inserted by the plumber" rule (line 80-81 above) still holds — grouped mode just moves the
  separator from a CSS margin hack (`data-[group-end]:me-*`) to a real authored element between
  cells, which is closer to the original intent than the margin hack was.
- `code` (OTP) is unaffected — Rails still renders one cell per character for it, so it never
  enters grouped mode.
- See `stimulus-plumbers/docs/plumber/character-cells.md` (Grouped mode section) and
  `stimulus-plumbers/docs/component/input-formatter.md` (credit card example) for the
  user-facing API docs; `stimulus-plumbers-rails/docs/component/form.md` for the Rails
  `credit_card` field options.
