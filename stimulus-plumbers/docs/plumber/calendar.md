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

| Property           | Type     | Description                              |
| ------------------ | -------- | ---------------------------------------- |
| `today`            | Date     | Resolved today date                      |
| `current`          | Date     | Currently displayed month/year as a Date |
| `year`             | Number   | Currently displayed year                 |
| `month`            | Number   | Currently displayed month (0–11)         |
| `day`              | Number   | Currently selected day                   |
| `since`            | Date     | Earliest selectable date (from options)  |
| `till`             | Date     | Latest selectable date (from options)    |
| `firstDayOfWeek`   | Number   | First day of week (0 = Sunday)           |
| `disabledDates`    | Date[]   | Specific disabled dates                  |
| `disabledWeekdays` | Number[] | Disabled weekday numbers                 |
| `disabledDays`     | Number[] | Disabled days-of-month                   |
| `disabledMonths`   | Number[] | Disabled month numbers (0–11)            |
| `disabledYears`    | Number[] | Disabled years                           |
| `daysOfWeek`       | Array    | Formatted weekday header labels          |
| `daysOfMonth`      | Array    | Grid cells for the current month         |
| `monthsOfYear`     | Array    | Month cells for the month view           |
| `yearsOfDecade`    | Array    | Year cells for the year view             |

## Calendar instance methods

| Method                | Returns         | Description                                                 |
| --------------------- | --------------- | ----------------------------------------------------------- |
| `navigate(date)`      | `Promise<void>` | Navigate to the month containing `date`                     |
| `step(unit, delta)`   | `Promise<void>` | Step by `delta` months or years (`unit: 'month' \| 'year'`) |
| `isDisabled(date)`    | `boolean`       | True if `date` matches any disabled rule or range           |
| `isWithinRange(date)` | `boolean`       | True if `date` falls within `since`…`till` (inclusive)      |

## Dispatches & callbacks

| Moment        | Dispatch             | Callback                    |
| ------------- | -------------------- | --------------------------- |
| Pre-navigate  | `{prefix}:navigate`  | —                           |
| Post-navigate | `{prefix}:navigated` | `onNavigated({ from, to })` |

Both dispatches include `detail: { from: isoString, to: isoString }` where `from`/`to` are ISO date strings.
