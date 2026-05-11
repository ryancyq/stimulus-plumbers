# input-format

Formats, masks, and reveals values written to an input element. Handles password reveal toggling and structured display formatting for credit cards, phone numbers, currencies, dates, and times.

> When co-located with `input-combobox`, see [combobox.md](combobox.md) for the full event flow and wiring.

## Targets

| Target   | Element                  | Description                                                                 |
| -------- | ------------------------ | --------------------------------------------------------------------------- |
| `input`  | `<input>` or any element | Write destination — sets `.value` for `<input>`, `.textContent` otherwise   |
| `toggle` | `<button>`               | Reveal/conceal button; hidden at connect when the formatter is not maskable |

## Values

| Value      | Type    | Default   | Description                                                          |
| ---------- | ------- | --------- | -------------------------------------------------------------------- |
| `type`     | String  | `"plain"` | Formatter type — see [Formatters](#formatters) for valid identifiers |
| `options`  | Object  | `{}`      | Formatter-specific options (e.g. `{ locale: "en-US" }` for currency) |
| `revealed` | Boolean | `false`   | Whether a masked value is currently revealed; managed by `toggle()`  |

## Methods

| Method            | Wired via                | Description                                                                                    |
| ----------------- | ------------------------ | ---------------------------------------------------------------------------------------------- |
| `format(value)`   | —                        | Programmatic API — normalises, formats/masks, writes to `input` target, dispatches `formatted` |
| `toggle()`        | `data-action`            | Action — flips `revealedValue`; no-op unless `type` is `"password"` or formatter is maskable   |
| `onChange(event)` | `input-combobox:changed` | Event adapter — extracts `event.detail.value`, calls `format(value)`                           |
| `onPaste(event)`  | `clipboard:pasted`       | Event adapter — normalises and validates pasted text, calls `format(value)`                    |

## Dispatches

| Event                    | Detail      | When                                    |
| ------------------------ | ----------- | --------------------------------------- |
| `input-format:formatted` | `{ value }` | After every write to the `input` target |

## Formatters

| `type`         | Description                                                        |
| -------------- | ------------------------------------------------------------------ |
| `"plain"`      | No-op — passes the value through unchanged                         |
| `"password"`   | Switches `input[type]` between `"password"` and `"text"` on reveal |
| `"creditCard"` | Groups digits as `#### #### #### ####`                             |
| `"phone"`      | Formats as a local phone number                                    |
| `"currency"`   | Locale-aware thousands separator and decimal places                |
| `"date"`       | Locale-aware date string                                           |
| `"time"`       | Locale-aware time string                                           |

Custom formatters can be registered at runtime:

```js
import { InputFormat } from '@stimulus-plumbers/controllers';

InputFormat.register('iban', {
  normalize: (raw) => raw.replace(/\s/g, '').toUpperCase(),
  validate: (value) => /^[A-Z]{2}\d{2}[A-Z0-9]+$/.test(value),
  format: (value) => value.replace(/(.{4})/g, '$1 ').trim(),
});
```

## Examples

### Password reveal

```html
<div data-controller="input-format" data-input-format-type-value="password">
  <input type="password" data-input-format-target="input" />
  <button
    type="button"
    aria-label="Show password"
    aria-pressed="false"
    data-input-format-target="toggle"
    data-action="click->input-format#toggle"
  ></button>
</div>
```

### Credit card formatting

```html
<div data-controller="input-format" data-input-format-type-value="creditCard">
  <input type="text" data-input-format-target="input" />
</div>
```

## Accessibility

- The `toggle` button must carry `aria-label` describing the action: `"Show password"` / `"Hide password"`.
- `aria-pressed` is managed automatically — initialised to `"false"`, flipped to `"true"` when the value is revealed.
- Password `type` attribute switches between `"password"` (masked) and `"text"` (revealed), so screen readers announce the field type correctly.
