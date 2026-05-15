# Calendar

Manages calendar state: current month/year, today marker, date range constraints, and disabled date rules. Exposes navigation and query methods on the controller. Used by `calendar-month`.

## Factory

```js
import { initCalendar } from '../plumbers';
this.calendar = initCalendar(controller, options);
```

Returns a `Calendar` instance; the controller accesses it via `this.calendar`.

## Options

| Option             | Type               | Default       | Description                                         |
| ------------------ | ------------------ | ------------- | --------------------------------------------------- |
| `locales`          | String[]           | `['default']` | Locale identifiers used for `Intl.DateTimeFormat`   |
| `today`            | String \| Date     | `''`          | Override for "today"; defaults to `new Date()`      |
| `day`              | Number             | `null`        | Initial day                                         |
| `month`            | Number             | `null`        | Initial month (0–11)                                |
| `year`             | Number             | `null`        | Initial year                                        |
| `since`            | String \| Date     | `null`        | Earliest selectable date (inclusive)                |
| `till`             | String \| Date     | `null`        | Latest selectable date (inclusive)                  |
| `disabledDates`    | (String\|Date)[]   | `[]`          | Specific dates to disable                           |
| `disabledWeekdays` | (String\|Number)[] | `[]`          | Weekday numbers to disable (0 = Sunday)             |
| `disabledDays`     | (String\|Number)[] | `[]`          | Day-of-month numbers to disable                     |
| `disabledMonths`   | (String\|Number)[] | `[]`          | Month numbers to disable (0–11)                     |
| `disabledYears`    | (String\|Number)[] | `[]`          | Years to disable                                    |
| `firstDayOfWeek`   | Number             | `0`           | First day of week (0 = Sunday, 1 = Monday)          |
| `onNavigated`      | String             | `'navigated'` | Controller method called after navigation completes |

## Calendar instance properties

| Property  | Type     | Description                      |
| --------- | -------- | -------------------------------- |
| `year`    | Number   | Currently displayed year         |
| `month`   | Number   | Currently displayed month (0–11) |
| `day`     | Number   | Currently selected day           |
| `today`   | Date     | Resolved today date              |
| `locales` | String[] | Active locale list               |

## Calendar instance methods

| Method                         | Returns         | Description                                                      |
| ------------------------------ | --------------- | ---------------------------------------------------------------- |
| `navigate(date)`               | `Promise<void>` | Navigate to the month containing `date`                          |
| `step(unit, delta)`            | `Promise<void>` | Step by `delta` months or years (`unit: 'month' \| 'year'`)      |
| `isDisabled(year, month, day)` | `boolean`       | True if the given date matches any disabled rule or range        |
| `isToday(year, month, day)`    | `boolean`       | True if the given date is today                                  |
| `daysInMonth(year, month)`     | `number`        | Number of days in the given month                                |
| `monthGrid()`                  | `Array[]`       | 2D grid of `{ year, month, day, outside }` objects for rendering |

## Dispatches & callbacks

| Moment        | Dispatch             | Callback                       |
| ------------- | -------------------- | ------------------------------ |
| Post-navigate | `{prefix}:navigated` | `onNavigated({ year, month })` |
