# Calendar

`sp_calendar` renders the month, year, and decade views.

---

## `sp_calendar`

```erb
<%= sp_calendar id: "availability", selectable: true, selected: @booking.date, min: Date.current %>
```

`navigation:` picks the calendar; the grid, keys, and events are the same in both
([JS `calendar`](../../../stimulus-plumbers/docs/component/calendar.md#calendar)).

- `:stimulus` (default): renders a label-free template; the `calendar` controller draws each period
  with `Intl` in `I18n.locale` and redraws it on navigation without a request.
- `:turbo`: renders the period with Rails I18n inside `turbo-frame#<id>_frame`; previous, next, the
  year links in the month view, and zoom are links that `calendar-turbo` loads into the frame. By
  default a link is the current URL plus `<id>[displayed]=YYYY-MM-DD` and `<id>[view]=…`. Pass both
  back from `params`; the page re-renders the same call. An invalid `displayed` or `view` falls back
  to its default rather than raising.

```erb
<%= sp_calendar id: "availability", navigation: :turbo, selectable: true, selected: @booking.date,
                displayed: params.dig(:availability, :displayed), view: params.dig(:availability, :view) %>
```

`url:` generates the links instead. A Symbol names a view method and a Proc runs on the view; each takes the date and
view and returns the URL. Without a URL, the control renders disabled, and a key that needs it does nothing.

```erb
<%= sp_calendar id: "availability", navigation: :turbo,
                url: ->(date, view) { calendar_path(date.strftime("%Y/%m"), view: view) } %>
```

A `selected` set in the browser moves the calendar only under `:stimulus`
([JS `calendar`](../../../stimulus-plumbers/docs/component/calendar.md#calendar)).

| Option              | Default                  | Description                                                                                                                                 |
| ------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`                | required                 | Stable id; the container, frame, heading, and grid ids derive from it                                                                       |
| `navigation`        | `:stimulus`              | `:stimulus` or `:turbo`                                                                                                                     |
| `displayed`         | `today`                  | `Date` or `YYYY-MM-DD` inside the period shown                                                                                              |
| `view`              | `:month`                 | `:month`, `:year`, or `:decade`                                                                                                             |
| `selected`          | `nil`                    | Selected date                                                                                                                               |
| `today`             | `Date.current`           | Marked `aria-current="date"`                                                                                                                |
| `selectable`        | `false`                  | Days select a date; otherwise the grid is `aria-readonly`                                                                                   |
| `show_other_months` | `false`                  | Shows adjacent-month days                                                                                                                   |
| `first_day_of_week` | `Date.beginning_of_week` | `0` (Sunday) to `6`                                                                                                                         |
| `url`               | current URL              | `:turbo` only. A String is the base of the period URLs; pass the form's GET URL when a POST re-renders. A Symbol or Proc generates each URL |
| `min`, `max`        | `nil`                    | Earliest and latest available date (`Date` or `YYYY-MM-DD`)                                                                                 |
| `disabled_dates`    | `[]`                     | Unavailable dates                                                                                                                           |
| `disabled_weekdays` | `[]`                     | Unavailable weekdays, `0`–`6`                                                                                                               |
| `disabled_months`   | `[]`                     | Unavailable months, `1`–`12`                                                                                                                |
| `disabled_years`    | `[]`                     | Unavailable years                                                                                                                           |
| `**html_options`    | —                        | Forwarded to the container `<div>`                                                                                                          |

Dates are a `Date`, a `YYYY-MM-DD` string, or a time, read as its date in `Time.zone`. An invalid
`min`, `max`, or `disabled_*`, a `min` after `max`, and an invalid `today` raise
`ArgumentError`; a `selected` that is not a date selects nothing. `min`, `max`, and `disabled_*`
limit what the calendar offers
([JS `calendar`](../../../stimulus-plumbers/docs/component/calendar.md#calendar)); validate the
value in the model. Interface text (previous, next, the year controls, zoom,
and the load error) comes from `stimulus_plumbers.calendar.*`.

### Rendered HTML structure

`:stimulus` — hidden until the controller fills the heading, header labels, and grid:

```html
<div
  id="availability"
  data-controller="calendar"
  data-action="click->calendar#onClick"
  data-calendar-displayed-value="2026-09-15"
  data-calendar-view-value="month"
  data-calendar-locale-value="en"
  data-calendar-first-day-of-week-value="1"
  data-calendar-labels-value='{"previousMonth":"Previous month",…}'
>
  <div role="status" data-calendar-target="status"></div>
  <div id="availability_frame" hidden>
    <div>
      <button type="button" data-navigation="previous-year">…</button>
      <button type="button" data-navigation="previous">…</button>
      <h2 id="availability_heading"></h2>
      <button type="button" data-navigation="zoom"></button>
      <button type="button" data-navigation="next">…</button>
      <button type="button" data-navigation="next-year">…</button>
    </div>
    <table
      role="grid"
      aria-labelledby="availability_heading"
      data-calendar-target="grid"
      data-action="keydown->calendar#onKeydown"
    ></table>
  </div>
  <template data-calendar-target="weekdayTemplate"><th></th></template>
  <template data-calendar-target="cellTemplate"><td></td></template>
  <template data-calendar-target="dateTemplate"
    ><td><button type="button"></button></td
  ></template>
</div>
```

`:turbo` — the period is rendered by Rails:

```html
<div
  id="availability"
  data-controller="calendar calendar-turbo"
  data-action="click->calendar#onClick calendar:navigate->calendar-turbo#onNavigate turbo:before-fetch-response->calendar-turbo#onResponse turbo:frame-missing->calendar-turbo#onError turbo:fetch-request-error->calendar-turbo#onError calendar-turbo:failed->calendar#onFailed"
  data-calendar-navigation-value="turbo"
>
  <div role="status" data-calendar-target="status"></div>
  <turbo-frame id="availability_frame">
    <div>
      <a
        href="?availability[displayed]=2025-09-01&availability[view]=month"
        aria-label="Previous year"
        data-navigation="previous-year"
        data-date="2025-09-01"
        data-view="month"
        >…</a
      >
      <a
        href="?availability[displayed]=2026-08-01&availability[view]=month"
        aria-label="Previous month"
        data-navigation="previous"
        data-date="2026-08-01"
        data-view="month"
        >…</a
      >
      <h2 id="availability_heading">September 2026</h2>
      <a
        href="?availability[displayed]=2026-09-15&availability[view]=year"
        data-navigation="zoom"
        data-date="2026-09-15"
        data-view="year"
        >Choose month</a
      >
      <a
        href="?availability[displayed]=2026-10-01&availability[view]=month"
        aria-label="Next month"
        data-navigation="next"
        data-date="2026-10-01"
        data-view="month"
        >…</a
      >
      <a
        href="?availability[displayed]=2027-09-01&availability[view]=month"
        aria-label="Next year"
        data-navigation="next-year"
        data-date="2027-09-01"
        data-view="month"
        >…</a
      >
    </div>
    <table
      role="grid"
      aria-labelledby="availability_heading"
      data-calendar-target="grid"
      data-displayed="2026-09-15"
      data-view="month"
    >
      <thead>
        <tr>
          <th scope="col" abbr="Monday">Mon</th>
          …
        </tr>
      </thead>
      <tbody>
        <tr>
          <td role="gridcell" aria-selected="true">
            <button
              type="button"
              tabindex="0"
              aria-label="September 15, 2026"
              data-calendar-target="day"
              data-date="2026-09-15"
            >
              15
            </button>
          </td>
          …
        </tr>
      </tbody>
    </table>
  </turbo-frame>
</div>
```

- The `tabindex="0"` cell is the selected date, then today, then the displayed date, then the
  first available date.
- Hidden adjacent-month days are empty cells; shown ones carry `data-outside="true"`.
- Year and decade cells (`data-calendar-target="period"`) zoom in to the month or year: buttons in
  `:stimulus`, links in `:turbo`.
- ARIA states follow [ARIA.md](../../../ARIA.md).
- Past the years 0001–9999, previous, next, and the year controls are hidden in `:stimulus` and disabled in
  `:turbo`.
