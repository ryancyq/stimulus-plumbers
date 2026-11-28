# input-formatter

Formats values written to an input element. Handles structured display formatting for credit cards, phone numbers, currencies, dates, times, and date-times.

> [`combobox-date`](combobox.md#combobox-date), [`combobox-time`](combobox.md#combobox-time), and [`combobox-datetime`](combobox.md#combobox-datetime) wire `onChange` to their `changed` events.

## Targets

| Target  | Element                  | Description                                                               |
| ------- | ------------------------ | ------------------------------------------------------------------------- |
| `input` | `<input>` or any element | Write destination — sets `.value` for `<input>`, `.textContent` otherwise |

## Values

| Value     | Type   | Default   | Description                                                          |
| --------- | ------ | --------- | -------------------------------------------------------------------- |
| `format`  | String | `"plain"` | Formatter type — see [Formatters](#formatters) for valid identifiers |
| `options` | Object | `{}`      | Formatter-specific options (e.g. `{ locale: "en-US" }` for currency) |

## Methods

| Method                 | Wired via                                                                     | Description                                                                                                                                  |
| ---------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `format(value)`        | —                                                                             | Programmatic API — normalises, formats, writes to `input` target, dispatches `formatted`                                                     |
| `onChange(event)`      | `combobox-date:changed`, `combobox-time:changed`, `combobox-datetime:changed` | Event adapter — extracts `event.detail.value`, calls `format(value)`                                                                         |
| `onPaste(event)`       | `clipboard:pasted`                                                            | Event adapter — normalises and validates pasted text; when valid, calls `format(value)` and cancels the event so the native paste is skipped |
| `onInput(event)`       | `input` DOM event                                                             | Event adapter — re-formats from the input's current value; the caret stays after the same kept characters                                    |
| `onBeforeinput(event)` | `beforeinput` DOM event                                                       | Event adapter — when the value is at the formatter's cap, a typed character replaces the one after the caret                                 |
| `onFormReset()`        | `form:reset` on the input                                                     | Re-formats the restored value without dispatching `filled`                                                                                   |

## Dispatches

| Event                       | Detail      | When                                                                                                                                                                         |
| --------------------------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `input-formatter:formatted` | `{ value }` | After every write to the `input` target                                                                                                                                      |
| `input-formatter:filled`    | `{ value }` | When a valid value reaches the formatter's `filledLength` — auto-submit hook. Fires once per fill, on the transition into "full"; not on connect with an already-full value. |

## Formatters

| `type`         | Description                                                                                                                                                  |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `"plain"`      | No-op — passes the value through unchanged                                                                                                                   |
| `"creditCard"` | Groups digits at the `groups` breaks, else 4-6-5 for Amex and 4-4-4-4 otherwise, joined by `separator` (a space by default); options `{ groups, separator }` |
| `"phone"`      | Formats as a local phone number                                                                                                                              |
| `"currency"`   | Locale-aware thousands separator and decimal places                                                                                                          |
| `"date"`       | Locale-aware date string                                                                                                                                     |
| `"time"`       | Locale-aware time string                                                                                                                                     |
| `"datetime"`   | Locale-aware date and time of a `YYYY-MM-DDTHH:MM` value, on the wall clock                                                                                  |
| `"code"`       | Charset-filtered fixed-length codes (OTP, PIN); options `{ charset: "digits"\|"letters"\|"alphanumeric", length }`                                           |

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
<input
  type="text"
  autocomplete="cc-number"
  inputmode="numeric"
  data-controller="input-formatter"
  data-input-formatter-target="input"
  data-input-formatter-format-value="creditCard"
  data-input-formatter-options-value='{"separator":"-"}'
  data-action="input->input-formatter#onInput beforeinput->input-formatter#onBeforeinput form:reset->input-formatter#onFormReset"
/>
```

### One-time code entry

See [input-code](input-code.md), which draws the code in cells.
