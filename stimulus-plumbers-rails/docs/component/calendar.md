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

| Option           | Description                                                                          |
| ---------------- | ------------------------------------------------------------------------------------ |
| `date`           | `Date` — sets `year-value`, `month-value` (0-indexed), `day-value` on the controller |
| `**html_options` | Forwarded to the `calendar-month` controller root element                            |

For the JS controller API (targets, values, keyboard behaviour), see the [JS package docs](../../../stimulus-plumbers/docs/component/calendar.md).

### Rendered HTML structure

`sp_calendar_month` renders a `calendar-month` + `calendar-observer` controller shell. The JS controller populates the day/week grids on connect and on each navigation.

```html
<!-- combobox-date drives navigation and view switching -->
<div
  data-controller="combobox-date"
  data-combobox-date-calendar-month-outlet="[data-controller~='calendar-month']"
  data-combobox-date-date-value="2024-02-15"
>
  <!-- view-title button drills up (month → year → decade) -->
  <button
    data-combobox-date-target="viewTitle"
    data-action="click->combobox-date#zoomOut"
    type="button"
  >
    February 2024
  </button>

  <!-- month view (CSR-rendered by calendar-month controller) -->
  <div
    data-controller="calendar-month calendar-observer"
    data-calendar-month-year-value="2024"
    data-calendar-month-month-value="1"
    data-calendar-month-day-value="15"
    data-action="click->calendar-observer#onSelect"
    role="grid"
  >
    <!-- month-value is 0-indexed: January=0, February=1, … December=11 -->

    <!-- days-of-week header row (JS-generated) -->
    <div data-calendar-month-target="daysOfWeek">
      <div role="row">
        <div role="columnheader" title="Sunday">Su</div>
        <!-- … -->
      </div>
    </div>

    <!-- days-of-month body (JS-generated) -->
    <div role="rowgroup" data-calendar-month-target="daysOfMonth">
      <div role="row">
        <div role="gridcell" tabindex="0" aria-selected="false">
          <time datetime="2024-02-01T00:00:00.000Z">1</time>
        </div>
        <!-- … -->
      </div>
    </div>

    <!-- year view — hidden until user drills up; JS-generated -->
    <div
      hidden
      data-controller="calendar-year"
      data-calendar-year-target="yearView"
    >
      <!-- month buttons inserted by combobox-date#drawYearView -->
    </div>

    <!-- decade view — hidden until user drills up twice; JS-generated -->
    <div
      hidden
      data-controller="calendar-decade"
      data-calendar-decade-target="decadeView"
    >
      <!-- year buttons inserted by combobox-date#drawDecadeView -->
    </div>
  </div>
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

Individual view helpers render a single view (used for Turbo Frame responses):

```erb
<%# Month view (days grid) %>
<%= sp_calendar_turbo_month(date: @date, today: @today) %>

<%# Year view (months grid) %>
<%= sp_calendar_turbo_year(date: @date, today: @today) %>

<%# Decade view (years grid) %>
<%= sp_calendar_turbo_decade(date: @date, today: @today) %>
```

| Option              | Description                                         |
| ------------------- | --------------------------------------------------- |
| `date`              | `Date` — the month/year being displayed             |
| `today`             | `Date` — used to mark today and aria-current        |
| `selectable`        | `true` renders day cells as `<button>` (month only) |
| `selected_date`     | `Date` — marks the selected cell with aria-selected |
| `show_other_months` | `true` shows padding days from adjacent months      |

### Rendered HTML structure

#### Month view (`sp_calendar_turbo_month`)

```html
<div
  role="grid"
  data-controller="calendar-observer"
  data-action="click->calendar-observer#onSelect"
>
  <!-- weekday column headers -->
  <div role="row">
    <div role="columnheader" title="Sunday">Su</div>
    <!-- … -->
  </div>

  <!-- day cells -->
  <div role="rowgroup">
    <div role="row">
      <button role="gridcell" tabindex="0" aria-selected="false">
        <time datetime="2024-02-01T00:00:00.000Z">1</time>
      </button>
      <!-- … -->
    </div>
  </div>
</div>
```

#### Year view (`sp_calendar_turbo_year`)

Displays 12 month buttons in a 4-column grid. Used when drilling up from the month view.

```html
<div role="grid" aria-label="Year view" class="grid grid-cols-4 …">
  <div role="rowgroup">
    <!-- class="contents" -->
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

Displays 10 year buttons in a 4-column grid (2 padding cells). Used when drilling up from the year view.

```html
<div role="grid" aria-label="Decade view" class="grid grid-cols-4 …">
  <div role="rowgroup">
    <!-- class="contents" -->
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
<turbo-frame id="calendar-month-frame" data-combobox-date-target="monthView">
  <!-- sp_calendar_turbo_month output -->
</turbo-frame>

<!-- year view frame — hidden until drill-up -->
<turbo-frame
  id="calendar-year-frame"
  hidden
  data-combobox-date-target="yearView"
>
  <!-- sp_calendar_turbo_year output -->
</turbo-frame>

<!-- decade view frame — hidden until drill-up twice -->
<turbo-frame
  id="calendar-decade-frame"
  hidden
  data-combobox-date-target="decadeView"
>
  <!-- sp_calendar_turbo_decade output -->
</turbo-frame>
```
