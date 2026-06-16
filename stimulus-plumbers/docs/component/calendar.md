# calendar-month

Renders an accessible calendar grid for a given month. Driven by the `Calendar` plumber, which provides navigation, disabled dates, and range constraints.

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

- Grid uses `role="grid"` → `role="row"` → `role="gridcell"`
- Weekday headers use `role="columnheader"` with `title` for the long name
- Today is marked with `aria-current="date"`
- Disabled dates use `disabled` (buttons) or `aria-disabled="true"` (non-interactive)
- Selected dates use `aria-selected="true"`

## calendar-year

Year-view grid controller — renders a 12-month grid and dispatches a `calendar-year:selected` event when a month button is clicked. Pair with `combobox-date` via `data-action` on the orchestrator element.

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

## calendar-decade

Decade-view grid controller — renders a 12-year grid and dispatches a `calendar-decade:selected` event when a year button is clicked. Pair with `combobox-date` via `data-action` on the orchestrator element.

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
