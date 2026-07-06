# Calendar

Rails helpers for rendering calendar grids. Two rendering modes are supported:

- **CSR (Stimulus)** — JS controller renders the month grid client-side; drill-down (year/decade views) driven by `combobox-date`.
- **SSR (Turbo)** — Server renders each view as a Turbo Frame; controller handles navigation via Turbo Drive.

---

## CSR — Stimulus calendar

### Setup

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::CalendarHelper
end
```

### Usage

```erb
<%# Current month (defaults to today) %>
<%= sp_calendar_month %>

<%# Navigate to a specific month %>
<%= sp_calendar_month(date: Date.new(2024, 2, 1)) %>

<%# Inside a combobox-date wrapper for drill-down navigation %>
<div data-controller="combobox-date"
     data-combobox-date-calendar-month-outlet="[data-controller~='calendar-month']">
  <%= sp_calendar_month(date: @date) %>
</div>
```

| Option           | Description                                                             |
| ---------------- | ----------------------------------------------------------------------- |
| `date`           | `Date` — sets `year-value`, `month-value` (0-indexed) on the controller |
| `**html_options` | Forwarded to the `calendar-month` controller root element               |

For the JS controller API (targets, values, keyboard behaviour), see the [JS package docs](../../../stimulus-plumbers/docs/component/calendar.md).

### Rendered HTML structure

`sp_calendar_month` renders a `calendar-month` controller shell. The JS controller populates the day/week grids on connect and on each navigation. Year/decade drill-down views are separate controllers wired by `combobox-date` — see the [JS package docs](../../../stimulus-plumbers/docs/component/calendar.md).

```html
<!-- sp_calendar_month(date: Date.new(2024, 2, 15)) -->
<div
  data-controller="calendar-month"
  data-calendar-month-year-value="2024"
  data-calendar-month-month-value="1"
  role="grid"
>
  <!-- days-of-week header row (JS-populated) -->
  <div data-calendar-month-target="daysOfWeek"></div>

  <!-- days-of-month body (JS-populated) -->
  <div role="rowgroup" data-calendar-month-target="daysOfMonth"></div>
</div>
```

---

## SSR — Turbo calendar

### Setup

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::CalendarTurboHelper
end
```

### Usage

`sp_calendar_turbo` renders all three view frames at once (month visible, year/decade hidden). Each frame is a `<turbo-frame>` targeted by `combobox-date`.

```erb
<%= sp_calendar_turbo(date: @date, today: @today, selectable: true) %>
```

Individual view helpers render a single view (used for Turbo Frame responses). They accept the same common options plus extras:

```erb
<%# Month view (days grid) %>
<%= sp_calendar_turbo_month(date: @date, today: @today, weekday_format: :narrow) %>

<%# Year view (months grid) %>
<%= sp_calendar_turbo_year(date: @date, today: @today, month_format: :long) %>

<%# Decade view (years grid) %>
<%= sp_calendar_turbo_decade(date: @date, today: @today) %>
```

**`sp_calendar_turbo_month`** — extra option:

| Option           | Description                                                        |
| ---------------- | ------------------------------------------------------------------ |
| `weekday_format` | `:short` (default) \| `:long` \| `:narrow` — weekday header format |

**`sp_calendar_turbo_year`** — extra option:

| Option         | Description                                                      |
| -------------- | ---------------------------------------------------------------- |
| `month_format` | `:short` (default) \| `:long` \| `:narrow` — month button format |

**Common options** (all helpers and `sp_calendar_turbo`):

| Option              | Description                                              |
| ------------------- | -------------------------------------------------------- |
| `date`              | `Date` — the month/year being displayed                  |
| `today`             | `Date` — used to mark today and aria-current             |
| `selectable`        | `true` renders day cells as `<button>` (month only)      |
| `selected_date`     | `Date` — marks the selected cell with aria-selected      |
| `show_other_months` | `true` shows padding days from adjacent months           |
| `since`             | `Date` — minimum selectable date (disables earlier days) |
| `till`              | `Date` — maximum selectable date (disables later days)   |
| `disabled_months`   | Array — month numbers/names to disable in the year view  |
| `disabled_years`    | Array — years to disable in the decade view              |

### Rendered HTML structure

#### Month view (`sp_calendar_turbo_month`)

```html
<!-- sp_calendar_turbo_month(date: @date, today: @today, selectable: true) -->
<div role="grid" data-controller="calendar-month-selector">
  <!-- weekday column headers -->
  <div role="row">
    <span role="columnheader">Su</span>
    <!-- … -->
  </div>

  <!-- day cells -->
  <div role="rowgroup">
    <div role="row">
      <!-- selectable: true → <button>; selectable: false → <span> -->
      <button role="gridcell" tabindex="0" aria-selected="false">
        <time datetime="2024-02-01">1</time>
      </button>
      <!-- … -->
    </div>
  </div>
</div>
```

#### Year view (`sp_calendar_turbo_year`)

Displays 12 month buttons in a 4-column grid. Used when drilling up from the month view.

```html
<!-- sp_calendar_turbo_year(date: @date, today: @today) -->
<div
  role="grid"
  aria-label="Year view"
  data-controller="calendar-year-selector"
>
  <div role="rowgroup">
    <div role="row">
      <button
        role="gridcell"
        data-month="1"
        aria-current="month"
        aria-selected="false"
      >
        Jan
      </button>
      <!-- … 11 more months … -->
    </div>
  </div>
</div>
```

#### Decade view (`sp_calendar_turbo_decade`)

Displays 10 year buttons in a 4-column grid (plus 2 buffer cells, disabled). Used when drilling up from the year view.

```html
<!-- sp_calendar_turbo_decade(date: @date, today: @today) -->
<div
  role="grid"
  aria-label="Decade view"
  data-controller="calendar-decade-selector"
>
  <div role="rowgroup">
    <div role="row">
      <button
        role="gridcell"
        data-year="2020"
        aria-current="year"
        aria-selected="false"
      >
        2020
      </button>
      <!-- … 9 more years … -->
    </div>
  </div>
</div>
```

#### Full Turbo setup (`sp_calendar_turbo`)

Renders all three frames. Used inside a `combobox-date` controller for drill-down navigation.

```html
<!-- month view frame — visible by default -->
<turbo-frame id="calendar-month-frame">
  <!-- sp_calendar_turbo_month output -->
</turbo-frame>

<!-- year view frame — hidden until drill-up -->
<turbo-frame id="calendar-year-frame" hidden>
  <!-- sp_calendar_turbo_year output -->
</turbo-frame>

<!-- decade view frame — hidden until drill-up twice -->
<turbo-frame id="calendar-decade-frame" hidden>
  <!-- sp_calendar_turbo_decade output -->
</turbo-frame>
```
