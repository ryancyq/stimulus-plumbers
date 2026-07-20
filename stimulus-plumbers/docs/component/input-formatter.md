# input-formatter

Formats values written to an input element. Handles structured display formatting for credit cards, phone numbers, currencies, dates, and times.

> When co-located with `input-combobox`, see [combobox.md](combobox.md) for the full event flow and wiring.

## Targets

| Target  | Element                  | Description                                                                                                                                                                                                                                |
| ------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `input` | `<input>` or any element | Write destination — sets `.value` for `<input>`, `.textContent` otherwise                                                                                                                                                                  |
| `cell`  | `<div>` (any element)    | Optional character cells; when present, the canonical value is painted one character per cell, or (grouped mode — cell count equals `groups.length`) one group-sized slice per cell — see [character-cells](../plumber/character-cells.md) |

## Values

| Value     | Type   | Default   | Description                                                                       |
| --------- | ------ | --------- | --------------------------------------------------------------------------------- |
| `format`  | String | `"plain"` | Formatter type — see [Formatters](#formatters) for valid identifiers              |
| `options` | Object | `{}`      | Formatter-specific options (e.g. `{ locale: "en-US" }` for currency)              |
| `groups`  | Array  | `[]`      | Cell group widths (e.g. `[4,4,4,4]`); overrides the formatter's own grouping hint |

## Methods

| Method            | Wired via                | Description                                                                              |
| ----------------- | ------------------------ | ---------------------------------------------------------------------------------------- |
| `format(value)`   | —                        | Programmatic API — normalises, formats, writes to `input` target, dispatches `formatted` |
| `onChange(event)` | `input-combobox:changed` | Event adapter — extracts `event.detail.value`, calls `format(value)`                     |
| `onPaste(event)`  | `clipboard:pasted`       | Event adapter — normalises and validates pasted text, calls `format(value)`              |
| `onInput(event)`  | `input` DOM event        | Event adapter — re-formats from the input's current value                                |
| `onFocus(event)`  | `focus` DOM event        | Event adapter — redraws cells so the caret cell appears                                  |
| `onBlur(event)`   | `blur` DOM event         | Event adapter — redraws cells so the caret cell clears                                   |

## Dispatches

| Event                       | Detail      | When                                                                                                                                                                                             |
| --------------------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `input-formatter:formatted` | `{ value }` | After every write to the `input` target                                                                                                                                                          |
| `input-formatter:filled`    | `{ value }` | When a valid, cell-capable formatter's value reaches its expected cell length — auto-submit hook. Fires once per fill, on the transition into "full"; not on connect with an already-full value. |

## Formatters

| `type`         | Description                                                                                                        |
| -------------- | ------------------------------------------------------------------------------------------------------------------ |
| `"plain"`      | No-op — passes the value through unchanged                                                                         |
| `"creditCard"` | Groups digits as `#### #### #### ####`                                                                             |
| `"phone"`      | Formats as a local phone number                                                                                    |
| `"currency"`   | Locale-aware thousands separator and decimal places                                                                |
| `"date"`       | Locale-aware date string                                                                                           |
| `"time"`       | Locale-aware time string                                                                                           |
| `"code"`       | Charset-filtered fixed-length codes (OTP, PIN); options `{ charset: "digits"\|"letters"\|"alphanumeric", length }` |

Custom formatters can be registered at runtime:

```js
import { Formatter } from '@stimulus-plumbers/controllers';

Formatter.register('iban', {
  normalize: (raw) => raw.replace(/\s/g, '').toUpperCase(),
  validate: (value) => /^[A-Z]{2}\d{2}[A-Z0-9]+$/.test(value),
  format: (value) => value.replace(/(.{4})/g, '$1 ').trim(),
});
```

## Examples

### Credit card formatting

```html
<div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
  <input type="text" data-input-formatter-target="input" />
</div>
```

### One-time code entry (cells)

```html
<div
  data-controller="input-formatter"
  data-input-formatter-format-value="code"
  data-input-formatter-options-value='{"charset":"digits","length":6}'
>
  <label for="otp" class="sr-only">Verification code</label>
  <div class="cells-row">
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
  </div>
  <input
    id="otp"
    data-input-formatter-target="input"
    autocomplete="one-time-code"
    inputmode="numeric"
    maxlength="6"
    data-action="input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur"
  />
</div>
```

Cells are decoration; style them via `[data-filled]`, `[data-caret]`, `[data-group-end]`, `[data-inactive]`. See [ARIA.md's Code Input pattern](../../../ARIA.md) for the overlay/labeling requirements.

### Credit card formatting (grouped cells)

Rendering exactly `groups.length` cells (instead of one cell per digit) puts the plumber into
grouped mode: each cell displays its whole group of digits. Separators between cells (e.g. a
dash) are authored HTML, never inserted by the plumber — see
[character-cells](../plumber/character-cells.md#grouped-mode).

```html
<div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
  <div class="cells-row">
    <span data-input-formatter-target="cell"></span>
    <span aria-hidden="true">-</span>
    <span data-input-formatter-target="cell"></span>
    <span aria-hidden="true">-</span>
    <span data-input-formatter-target="cell"></span>
    <span aria-hidden="true">-</span>
    <span data-input-formatter-target="cell"></span>
  </div>
  <input
    data-input-formatter-target="input"
    autocomplete="cc-number"
    inputmode="numeric"
    maxlength="16"
    data-action="input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur"
  />
</div>
```

## Accessibility

- Cell display: see [ARIA.md's Code Input pattern](../../../ARIA.md).
