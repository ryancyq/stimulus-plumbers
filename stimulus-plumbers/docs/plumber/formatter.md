# Formatter

Attaches a formatter to a controller, exposing `this.formatter` with `normalize`, `validate`, `format`, and `mask` helpers. Used by `input-formatter`.

## Factory

```js
import { attachFormatter } from '../plumbers';
attachFormatter(controller, options);
```

Exposes `this.formatter` on the controller.

## Options

| Option    | Type   | Default   | Description                                          |
| --------- | ------ | --------- | ---------------------------------------------------- |
| `type`    | String | `'plain'` | Formatter type key — see built-in types below        |
| `options` | Object | `{}`      | Type-specific options passed to every formatter call |

## Controller property — `this.formatter`

| Helper            | Signature                | Description                                              |
| ----------------- | ------------------------ | -------------------------------------------------------- |
| `normalize(raw)`  | `(raw) → string`         | Strips raw input to canonical stored form                |
| `validate(value)` | `(value) → boolean`      | Validates canonical value                                |
| `format(value)`   | `(value) → string`       | Formats canonical value for display                      |
| `mask(value)`     | `(value) → string\|null` | Returns masked display string, or `null` if not maskable |
| `maskable()`      | `() → boolean`           | True if this formatter supports masking                  |

## Built-in types

| `type`         | Class                 | Description                                                              |
| -------------- | --------------------- | ------------------------------------------------------------------------ |
| `'plain'`      | `PlainFormatter`      | No-op — passes value through unchanged                                   |
| `'creditCard'` | `CreditCardFormatter` | Normalises to digits only; formats as `#### #### #### ####`              |
| `'phone'`      | `PhoneFormatter`      | Normalises to digits or E.164; formats local numbers as `(555) 123-4567` |
| `'currency'`   | `CurrencyFormatter`   | Locale-aware normalisation and `Intl.NumberFormat` display               |
| `'date'`       | `DateFormatter`       | Normalises to ISO 8601; `Intl.DateTimeFormat` display                    |
| `'time'`       | `TimeFormatter`       | Normalises to `HH:MM` (24h); formats as h12 or h24                       |

## Custom formatters

Register additional types via `Formatter.register` before the controller connects:

```js
import { Formatter } from '@stimulus-plumbers/controllers';

Formatter.register('iban', {
  normalize: (raw) => raw.replace(/\s/g, '').toUpperCase(),
  validate: (value) => /^[A-Z]{2}\d{2}[A-Z0-9]+$/.test(value),
  format: (value) => value.replace(/(.{4})/g, '$1 ').trim(),
});
```

`normalize` and `validate` are required. `format` and `mask` are optional.

## Individual formatters

Each built-in formatter is importable directly for use outside the plumber:

```js
import { CreditCardFormatter } from '@stimulus-plumbers/controllers/plumbers/formatters/credit_card';
```
