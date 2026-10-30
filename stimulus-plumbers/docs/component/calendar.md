# Calendar Controllers

## calendar

Calendar grid behaviour for [Rails `sp_calendar`](../../../stimulus-plumbers-rails/docs/component/calendar.md#sp_calendar)
or hand-written markup: keeps one cell in the Tab sequence, moves focus with the grid keys, commits
selection, and navigates between periods. Focus never commits a selection.

- **stimulus** (default): draws each period into an empty grid with `Intl` and redraws it on
  navigation. No server values are required.
- **turbo**: enhances a server-rendered grid; [`calendar-turbo`](#calendar-turbo) loads periods.

```html
<div id="trip" data-controller="calendar" data-action="click->calendar#onClick">
  <div role="status" data-calendar-target="status"></div>
  <div>
    <button type="button" data-navigation="previous">‹</button>
    <h2 id="trip_heading"></h2>
    <button type="button" data-navigation="zoom"></button>
    <button type="button" data-navigation="next">›</button>
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

In stimulus mode the header buttons are found by `data-navigation="previous" | "zoom" | "next"`;
the heading is the grid's `aria-labelledby`.

**Values**

| Value              | Type    | Default                          | Description                                                                                                                    |
| ------------------ | ------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `navigation`       | String  | `"stimulus"`                     | `stimulus` draws periods; `turbo` waits for `calendar-turbo`                                                                   |
| `selected`         | String  | `""`                             | Committed date key                                                                                                             |
| `selectable`       | Boolean | `false`                          | Day activation commits                                                                                                         |
| `displayed`        | String  | `selected`, then today           | First period drawn (stimulus)                                                                                                  |
| `view`             | String  | `"month"`                        | First view drawn: `month`, `year`, or `decade` (stimulus)                                                                      |
| `today`            | String  | the browser's local date         | Date marked `aria-current="date"` (stimulus)                                                                                   |
| `locale`           | String  | the browser's locale             | `Intl` locale for headings and labels (stimulus)                                                                               |
| `firstDayOfWeek`   | Number  | the locale's week info, else `1` | `0` is Sunday (stimulus)                                                                                                       |
| `showOtherMonths`  | Boolean | `false`                          | Shows adjacent-month days (stimulus)                                                                                           |
| `labels`           | Object  | English                          | `previousMonth`, `nextMonth`, `previousYear`, `nextYear`, `previousDecade`, `nextDecade`, `chooseMonth`, `chooseYear`, `error` |
| `url`              | String  | `""`                             | Base of period URLs; the current URL when empty                                                                                |
| `min`, `max`       | String  | `""`                             | Range as date keys                                                                                                             |
| `disabledDates`    | Array   | `[]`                             | Unavailable date keys                                                                                                          |
| `disabledWeekdays` | Array   | `[]`                             | Unavailable weekdays, `0`–`6`                                                                                                  |
| `disabledMonths`   | Array   | `[]`                             | Unavailable months, `1`–`12`                                                                                                   |
| `disabledYears`    | Array   | `[]`                             | Unavailable years                                                                                                              |

Invalid `min`, `max`, or `disabled*` values and day or period cells without a date key are
reported with `console.error`. `min`, `max`, and `disabled*` limit what the calendar offers: an
unavailable `selected` date stays selected and cannot be chosen, and the calendar never validates a value.

**Actions**

| Action             | Wired on                    | Description                                                            |
| ------------------ | --------------------------- | ---------------------------------------------------------------------- |
| `onKeydown(event)` | `keydown` grid              | Grid keys; see [ARIA.md](../../../ARIA.md)                             |
| `onClick(event)`   | `click` root                | Commits a clicked day; navigates from header controls and period cells |
| `onFailed()`       | a transport's failure event | Keeps the current grid and writes `labels.error` to `status`           |
| `select(value)`    | —                           | Commits an enabled, rendered date; returns `false` if refused          |

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
requested view, and `url` the period URL (`url` or the current URL plus `<id>[displayed]` and
`<id>[view]`); `focusDate` is the intended date after a grid key, or `null` otherwise. In stimulus
mode the period is drawn at once; in turbo mode a transport replaces the grid. When the requested
period arrives, the controller moves the Tab stop to the intended date (or the nearest available
one in that period), returns focus there or to the same header control if focus is still in the
calendar, writes the heading to `status`, and dispatches `navigated`. A grid for another period is
ignored.

---

## calendar-turbo

Loads [`calendar`](#calendar) periods through the calendar's `<turbo-frame>`
([Rails `sp_calendar(navigation: :turbo)`](../../../stimulus-plumbers-rails/docs/component/calendar.md#sp_calendar)).
Turbo mode requires it; without it, period links do nothing.

| Action              | Wired on                                                | Description                                 |
| ------------------- | ------------------------------------------------------- | ------------------------------------------- |
| `onNavigate(event)` | `calendar:navigate` root                                | Sets the frame `src` to the period URL      |
| `onResponse(event)` | `turbo:before-fetch-response` root                      | Dispatches `failed` for a failed response   |
| `onError(event)`    | `turbo:frame-missing`, `turbo:fetch-request-error` root | Keeps the current grid; dispatches `failed` |

| Event                   | Detail | When                        |
| ----------------------- | ------ | --------------------------- |
| `calendar-turbo:failed` | —      | Wire to `calendar#onFailed` |

---

# calendar-month

Renders an accessible calendar grid for a given month. Driven by the `Calendar` plumber, which provides navigation, disabled dates, and range availability.

## Targets

| Target        | Description                          |
| ------------- | ------------------------------------ |
| `daysOfWeek`  | Container for the weekday header row |
| `daysOfMonth` | Container for the day grid rows      |

## Classes

| Class             | Description                               |
| ----------------- | ----------------------------------------- |
| `dayOfWeek`       | Applied to each weekday header cell       |
| `dayOfMonth`      | Applied to each day cell                  |
| `dayOfOtherMonth` | Applied to day cells from adjacent months |
| `row`             | Applied to each week row                  |

## Values

| Value              | Type    | Default       | Description                                                                            |
| ------------------ | ------- | ------------- | -------------------------------------------------------------------------------------- |
| `year`             | Number  | —             | Year being displayed                                                                   |
| `month`            | Number  | —             | Month being displayed (0-indexed)                                                      |
| `since`            | String  | `""`          | Earliest selectable date (ISO string)                                                  |
| `till`             | String  | `""`          | Latest selectable date (ISO string)                                                    |
| `locales`          | Array   | `["default"]` | `Intl.DateTimeFormat` locale(s)                                                        |
| `weekdayFormat`    | String  | `"short"`     | Weekday header format: `"short"` \| `"long"` \| `"narrow"`                             |
| `dayFormat`        | String  | `"numeric"`   | Day number format                                                                      |
| `daysOfOtherMonth` | Boolean | `false`       | Show overflow days from adjacent months                                                |
| `today`            | String  | `""`          | Override the "today" marker (ISO date string); defaults to system date                 |
| `selected`         | String  | `""`          | Currently selected date (ISO string); sets `aria-selected="true"` on the matching cell |

## Calendar plumber options (programmatic only)

These options are not exposed as Stimulus values and must be passed via a subclass or custom controller:

| Option             | Description                                  |
| ------------------ | -------------------------------------------- |
| `firstDayOfWeek`   | `0` = Sunday, `1` = Monday, … (default `0`)  |
| `disabledDates`    | Array of ISO date strings to disable         |
| `disabledWeekdays` | Array of weekday names or numbers to disable |
| `disabledDays`     | Array of day-of-month numbers to disable     |
| `disabledMonths`   | Array of month names or numbers to disable   |

## Standalone usage

```html
<div
  data-controller="calendar-month"
  data-calendar-month-year-value="2024"
  data-calendar-month-month-value="1"
  data-calendar-month-locales-value='["en-US"]'
  role="grid"
>
  <div data-calendar-month-target="daysOfWeek"></div>
  <div role="rowgroup" data-calendar-month-target="daysOfMonth"></div>
</div>
```

## Rails helper

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::CalendarHelper
end
```

```erb
<%# Current month %>
<%= sp_calendar_month %>

<%# Navigate to a specific date %>
<%= sp_calendar_month(date: Date.new(2024, 3, 15)) %>

<%# With custom classes %>
<%= sp_calendar_month(class: "my-calendar") %>
```

## Actions

| Method            | Description                                                                                                        |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| `select(iso)`     | Selects a date by ISO string — sets `selectedValue`, updates `aria-selected`, dispatches `calendar-month:selected` |
| `navigate(date)`  | Navigates to the given `Date` — updates `yearValue`/`monthValue` and re-renders the grid                           |
| `step(unit, dir)` | Steps the calendar by `unit` (`'day'`/`'month'`/`'year'`) in `dir` (`1`/`-1`)                                      |

Click-handling is wired internally — `calendar-month` handles clicks on its own grid and dispatches `calendar-month:selected` automatically.

**Dispatches**

| Event                      | Detail           | When                                                |
| -------------------------- | ---------------- | --------------------------------------------------- |
| `calendar-month:selecting` | —                | On every valid cell click, before date is confirmed |
| `calendar-month:selected`  | `{ epoch, iso }` | After a valid date is parsed from the clicked cell  |
| `calendar-month:navigate`  | `{ from, to }`   | Before navigation begins (ISO strings)              |
| `calendar-month:navigated` | `{ from, to }`   | After navigation completes (ISO strings)            |

## Accessibility

- Weekday headers use `role="columnheader"` with `title` for the long name
- See [ARIA.md's Calendar / Date Picker pattern](../../../ARIA.md) for grid roles, selection/disabled state, and keyboard navigation

---

## calendar-year

Year-view grid controller — renders a 12-month grid and dispatches a `calendar-year:selected` event when a month button is clicked. Pair with `combobox-date` via `data-action` on the orchestrator element.

**Targets**

| Target | Description                                             |
| ------ | ------------------------------------------------------- |
| `grid` | `role="rowgroup"` container the controller renders into |

**Values**

| Value         | Type   | Default       | Description                                                    |
| ------------- | ------ | ------------- | -------------------------------------------------------------- |
| `current`     | Number | —             | Year being displayed                                           |
| `today`       | String | `""`          | ISO date string for today marker                               |
| `selected`    | String | `""`          | ISO date string for selected marker                            |
| `since`       | String | `""`          | Earliest selectable date (ISO string)                          |
| `till`        | String | `""`          | Latest selectable date (ISO string)                            |
| `locales`     | Array  | `["default"]` | `Intl.DateTimeFormat` locale(s)                                |
| `monthFormat` | String | `"short"`     | Month button label format: `"short"` \| `"long"` \| `"narrow"` |

**Dispatches**

| Event                    | Detail      | When                                              |
| ------------------------ | ----------- | ------------------------------------------------- |
| `calendar-year:selected` | `{ month }` | After a valid month button is clicked (1-indexed) |

```html
<!-- action wired on the combobox-date element -->
<div
  data-controller="combobox-date"
  data-action="calendar-year:selected->combobox-date#onMonthSelect"
  data-combobox-date-calendar-year-outlet="#year_view"
>
  <div id="year_view" hidden data-controller="calendar-year" role="grid" aria-label="Year view">
    <div data-calendar-year-target="grid" role="rowgroup"></div>
  </div>
</div>
```

---

## calendar-decade

Decade-view grid controller — renders a 12-year grid and dispatches a `calendar-decade:selected` event when a year button is clicked. Pair with `combobox-date` via `data-action` on the orchestrator element.

**Targets**

| Target | Description                                             |
| ------ | ------------------------------------------------------- |
| `grid` | `role="rowgroup"` container the controller renders into |

**Values**

| Value      | Type   | Default | Description                            |
| ---------- | ------ | ------- | -------------------------------------- |
| `current`  | Number | —       | Year within the decade being displayed |
| `today`    | String | `""`    | ISO date string for today marker       |
| `selected` | String | `""`    | ISO date string for selected marker    |
| `since`    | String | `""`    | Earliest selectable date (ISO string)  |
| `till`     | String | `""`    | Latest selectable date (ISO string)    |

**Dispatches**

| Event                      | Detail     | When                                 |
| -------------------------- | ---------- | ------------------------------------ |
| `calendar-decade:selected` | `{ year }` | After a valid year button is clicked |

```html
<!-- action wired on the combobox-date element -->
<div
  data-controller="combobox-date"
  data-action="calendar-decade:selected->combobox-date#onYearSelect"
  data-combobox-date-calendar-decade-outlet="#decade_view"
>
  <div id="decade_view" hidden data-controller="calendar-decade" role="grid" aria-label="Decade view">
    <div data-calendar-decade-target="grid" role="rowgroup"></div>
  </div>
</div>
```

---

## calendar-month-selector

Thin SSR/Turbo adapter for server-rendered month grids. Attaches click-to-select behaviour to a server-rendered day grid — no targets or values. The server renders each view as a `<turbo-frame>`; this controller handles day selection and emits the same `calendar-month:selected` event as `calendar-month`.

Used with `sp_calendar_turbo_month` (Rails). Pair with `combobox-date` exactly as you would `calendar-month`. See [docs/plumber/calendar-selector.md](../plumber/calendar-selector.md) for the underlying plumber.

---

## calendar-year-selector

Thin SSR/Turbo adapter for server-rendered year (month-grid) views. Attaches click-to-select behaviour — no targets or values. Emits `calendar-year:selected` on month click.

Used with `sp_calendar_turbo_year` (Rails). See [docs/plumber/calendar-selector.md](../plumber/calendar-selector.md) for the underlying plumber.

---

## calendar-decade-selector

Thin SSR/Turbo adapter for server-rendered decade (year-grid) views. Attaches click-to-select behaviour — no targets or values. Emits `calendar-decade:selected` on year click.

Used with `sp_calendar_turbo_decade` (Rails). See [docs/plumber/calendar-selector.md](../plumber/calendar-selector.md) for the underlying plumber.
