# Calendar Selector

Click-to-select adapters for server-rendered (Turbo) calendar grids. Extends `Plumber`. Used by `calendar-month-selector`, `calendar-year-selector`, and `calendar-decade-selector` — no targets or values, just a single `click` listener on the controller's element.

## Factory

```js
import { attachCalendarDaySelector, attachCalendarMonthSelector, attachCalendarYearSelector } from '../plumbers';
attachCalendarDaySelector(controller, options);
attachCalendarMonthSelector(controller, options);
attachCalendarYearSelector(controller, options);
```

## Classes

| Class                   | Used by                    | Reads                             | Dispatches                                                                                        |
| ----------------------- | -------------------------- | --------------------------------- | ------------------------------------------------------------------------------------------------- |
| `CalendarDaySelector`   | `calendar-month-selector`  | `<time datetime>` in clicked cell | `selecting`, then `selected` with `{ epoch, iso }` (or calls `options.onSelect(iso)` if provided) |
| `CalendarMonthSelector` | `calendar-year-selector`   | `data-month` on clicked button    | `selected` with `{ month }`                                                                       |
| `CalendarYearSelector`  | `calendar-decade-selector` | `data-year` on clicked button     | `selected` with `{ year }`                                                                        |

## Options

| Option     | Type   | Default | Description                                                                                                        |
| ---------- | ------ | ------- | ------------------------------------------------------------------------------------------------------------------ |
| `onSelect` | String | `null`  | `CalendarDaySelector` only — controller method called with the selected ISO date instead of dispatching `selected` |

All three classes ignore clicks on disabled cells/buttons (`disabled` attribute or `aria-disabled="true"`).
