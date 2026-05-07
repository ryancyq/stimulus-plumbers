# calendar-month

Renders an accessible calendar grid for a given month. Driven by the `Calendar` plumber, which provides navigation, disabled dates, and range constraints.

## Targets

| Target        | Description                          |
| ------------- | ------------------------------------ |
| `daysOfWeek`  | Container for the weekday header row |
| `daysOfMonth` | Container for the day grid rows      |

## Classes

| Class        | Description                         |
| ------------ | ----------------------------------- |
| `dayOfWeek`  | Applied to each weekday header cell |
| `dayOfMonth` | Applied to each day cell            |

## Values

| Value              | Type    | Default       | Description                                                |
| ------------------ | ------- | ------------- | ---------------------------------------------------------- |
| `locales`          | Array   | `["default"]` | `Intl.DateTimeFormat` locale(s)                            |
| `weekdayFormat`    | String  | `"short"`     | Weekday header format: `"short"` \| `"long"` \| `"narrow"` |
| `dayFormat`        | String  | `"numeric"`   | Day number format                                          |
| `daysOfOtherMonth` | Boolean | `false`       | Show overflow days from adjacent months                    |

## Calendar plumber options

Pass these as data attributes using the `calendar-month-*-value` prefix:

| Option             | Description                                    |
| ------------------ | ---------------------------------------------- |
| `since`            | Minimum selectable date (ISO string or `Date`) |
| `till`             | Maximum selectable date (ISO string or `Date`) |
| `firstDayOfWeek`   | `0` = Sunday, `1` = Monday, … (default `0`)    |
| `disabledDates`    | Array of ISO date strings to disable           |
| `disabledWeekdays` | Array of weekday names or numbers to disable   |
| `disabledDays`     | Array of day-of-month numbers to disable       |
| `disabledMonths`   | Array of month names or numbers to disable     |

## Standalone usage

```html
<div
  data-controller="calendar-month"
  data-calendar-month-locales-value='["en-US"]'
  data-calendar-month-first-day-of-week-value="1"
>
  <div data-calendar-month-target="daysOfWeek"></div>
  <div data-calendar-month-target="daysOfMonth"></div>
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

## calendar-month-observer

Companion controller that listens for clicks on gridcell elements and dispatches selection events. Pair it with `calendar-month` via `data-action`.

**Methods**

| Method            | Wired via           | Description                                                                                  |
| ----------------- | ------------------- | -------------------------------------------------------------------------------------------- |
| `onSelect(event)` | `click` on the grid | Event adapter — validates the clicked cell, dispatches `selecting`, calls `select(iso)`      |
| `select(iso)`     | —                   | Programmatic API — dispatches `selected` with `{ epoch, iso }` for the given ISO date string |

**Dispatches**

| Event                               | Detail           | When                                                |
| ----------------------------------- | ---------------- | --------------------------------------------------- |
| `calendar-month-observer:selecting` | —                | On every valid cell click, before date is confirmed |
| `calendar-month-observer:selected`  | `{ epoch, iso }` | After a valid date is parsed from the clicked cell  |

```html
<div role="grid" data-controller="calendar-month-observer" data-action="click->calendar-month-observer#onSelect">
  <!-- gridcell buttons rendered by calendar-month -->
</div>
```

## Accessibility

- Grid uses `role="grid"` → `role="row"` → `role="gridcell"`
- Weekday headers use `role="columnheader"` with `title` for the long name
- Today is marked with `aria-current="date"`
- Disabled dates use `disabled` (buttons) or `aria-disabled="true"` (non-interactive)
- Selected dates use `aria-selected="true"`
