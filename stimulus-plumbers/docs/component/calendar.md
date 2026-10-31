# Calendar Controllers

## calendar

Calendar grid behaviour for [Rails `sp_calendar`](../../../stimulus-plumbers-rails/docs/component/calendar.md#sp_calendar)
or hand-written markup: keeps at most one cell in the Tab sequence, moves focus with the grid keys, selects dates, and navigates between periods. Focus never selects.

- **stimulus** (default): draws each period into an empty grid with `Intl` and redraws it on
  navigation. No server values are required.
- **turbo**: enhances a server-rendered grid; [`calendar-turbo`](#calendar-turbo) loads periods.

```html
<div id="trip" data-controller="calendar" data-action="click->calendar#onClick">
  <div role="status" data-calendar-target="status"></div>
  <div>
    <button type="button" data-navigation="previous-year">«</button>
    <button type="button" data-navigation="previous">‹</button>
    <h2 id="trip_heading"></h2>
    <button type="button" data-navigation="zoom"></button>
    <button type="button" data-navigation="next">›</button>
    <button type="button" data-navigation="next-year">»</button>
  </div>
  <table
    role="grid"
    aria-labelledby="trip_heading"
    data-calendar-target="grid"
    data-action="keydown->calendar#onKeydown"
  ></table>
</div>
```

**Targets**

| Target            | Description                                                                        |
| ----------------- | ---------------------------------------------------------------------------------- |
| `grid`            | `<table role="grid">`; carries `data-displayed` and `data-view` once drawn         |
| `day`             | Day button with `data-date="YYYY-MM-DD"`                                           |
| `period`          | Month or year cell in the year and decade views                                    |
| `status`          | `role="status"` outside the replaced grid                                          |
| `weekdayTemplate` | Optional `<template>` holding the weekday `<th>`                                   |
| `cellTemplate`    | Optional `<template>` holding an empty `<td>`                                      |
| `dateTemplate`    | Optional `<template>` holding a `<td>` with a `<button>`; plain elements otherwise |

In stimulus mode the header buttons are found by `data-navigation="previous-year" | "previous" | "zoom" | "next" | "next-year"`;
the heading is the grid's `aria-labelledby`.

**Values**

| Value              | Type    | Default                          | Description                                                                                                                    |
| ------------------ | ------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `navigation`       | String  | `"stimulus"`                     | `stimulus` draws periods; `turbo` waits for `calendar-turbo`                                                                   |
| `selected`         | String  | `""`                             | Selected date key                                                                                                              |
| `selectable`       | Boolean | `false`                          | Day activation selects                                                                                                         |
| `displayed`        | String  | `selected`, then today           | First period drawn (stimulus)                                                                                                  |
| `view`             | String  | `"month"`                        | First view drawn: `month`, `year`, or `decade` (stimulus)                                                                      |
| `today`            | String  | the browser's local date         | Date marked `aria-current="date"` (stimulus)                                                                                   |
| `locale`           | String  | the browser's locale             | `Intl` locale for headings and labels (stimulus)                                                                               |
| `firstDayOfWeek`   | Number  | the locale's week info, else `1` | `0` is Sunday (stimulus)                                                                                                       |
| `showOtherMonths`  | Boolean | `false`                          | Shows adjacent-month days (stimulus)                                                                                           |
| `labels`           | Object  | English                          | `previousMonth`, `nextMonth`, `previousYear`, `nextYear`, `previousDecade`, `nextDecade`, `chooseMonth`, `chooseYear`, `error` |
| `min`, `max`       | String  | `""`                             | Range as date keys                                                                                                             |
| `disabledDates`    | Array   | `[]`                             | Unavailable date keys                                                                                                          |
| `disabledWeekdays` | Array   | `[]`                             | Unavailable weekdays, `0`–`6`                                                                                                  |
| `disabledMonths`   | Array   | `[]`                             | Unavailable months, `1`–`12`                                                                                                   |
| `disabledYears`    | Array   | `[]`                             | Unavailable years                                                                                                              |

Invalid `min`, `max`, or `disabled*` values and day or period cells without a date key are
reported with `console.error`. `min`, `max`, and `disabled*` limit what the calendar offers: an
unavailable `selected` date stays selected and cannot be selected, and the calendar never validates a value.

**Actions**

| Action             | Wired on                | Description                                                                       |
| ------------------ | ----------------------- | --------------------------------------------------------------------------------- |
| `onKeydown(event)` | `keydown` grid          | Grid keys; see [ARIA.md](../../../ARIA.md)                                        |
| `onClick(event)`   | `click` container       | Selects a clicked day; navigates from header controls and period cells            |
| `onFailed()`       | `calendar-turbo:failed` | Keeps the current grid and writes `labels.error` to `status`                      |
| `select(value)`    | —                       | Selects an enabled, rendered date; returns `false` if refused                     |
| `focusTabStop()`   | —                       | Focuses the grid's Tab stop, or with none the first shown, enabled header control |

**Events**

| Event                      | Cancelable | Detail                               |
| -------------------------- | ---------- | ------------------------------------ |
| `calendar:before-change`   | yes        | `{ value, previousValue }`           |
| `calendar:changed`         | no         | `{ value, previousValue }`           |
| `calendar:before-navigate` | yes        | `{ from, to, focusDate, view, url }` |
| `calendar:navigate`        | no         | `{ from, to, focusDate, view, url }` |
| `calendar:navigated`       | no         | `{ from, to, focusDate, view }`      |

Values are date keys (`YYYY-MM-DD`). `changed` also fires when the current date is activated again.
A form reset restores the initial selection.

Navigation: `from` is the shown period's date, `to` a date inside the requested period, `view` the
requested view, and `url` the URL of the link followed, in turbo mode only; `focusDate` is the intended
date after a grid key, or `null` otherwise. In stimulus mode the period is drawn at once; in turbo mode
`calendar-turbo` loads `url` and the response replaces the grid. Turbo period links carry `data-date` and
`data-view`; a grid key that leaves the period follows the header link to it, and does nothing without one. When the requested
period arrives, the controller moves the Tab stop to the intended date (or the nearest available
one in that period), returns focus there or to the same header control if focus is still in the
calendar (with no available date, to a header control, as [ARIA.md](../../../ARIA.md) lists), writes the heading to `status`, and dispatches `navigated`. A grid for another period is
ignored.

---

## calendar-turbo

Loads [`calendar`](#calendar) periods through the calendar's `<turbo-frame>`
([Rails `sp_calendar(navigation: :turbo)`](../../../stimulus-plumbers-rails/docs/component/calendar.md#sp_calendar)).
Turbo mode requires it; without it, period links do nothing.

| Action              | Wired on                                                     | Description                                                         |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------- |
| `onNavigate(event)` | `calendar:navigate` container                                | Sets the frame `src` to the period URL                              |
| `onResponse(event)` | `turbo:before-fetch-response` container                      | Dispatches `failed` for a failed or non-HTML response for its frame |
| `onError(event)`    | `turbo:frame-missing`, `turbo:fetch-request-error` container | Keeps the current grid; dispatches `failed` for its frame           |

| Event                   | Detail | When                        |
| ----------------------- | ------ | --------------------------- |
| `calendar-turbo:failed` | —      | Wire to `calendar#onFailed` |
