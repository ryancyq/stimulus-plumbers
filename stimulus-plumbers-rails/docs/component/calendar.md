# Calendar

Rails helper for rendering a standalone calendar month grid.

## Helper

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::CalendarHelper
end
```

```erb
<%# Current month (uses today's date) %>
<%= sp_calendar_month %>

<%# Navigate to a specific date %>
<%= sp_calendar_month(date: Date.new(2024, 3, 15)) %>

<%# With additional HTML attributes %>
<%= sp_calendar_month(class: "my-calendar", id: "picker-cal") %>
```

| Option           | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `date`           | `Date` object — navigates the calendar to this month |
| `**html_options` | Forwarded to the `calendar-month` controller element |

For the JS controller API (targets, values, keyboard behaviour), see the [JS package docs](../../../stimulus-plumbers/docs/component/calendar.md).

---

## Rendered HTML Structure

```html
<div
  data-controller="calendar-month"
  data-calendar-month-year-value="2024"
  data-calendar-month-month-value="2"
  data-calendar-month-day-value="15"
>
  <!-- calendar grid rendered by the JS controller -->
</div>
```

> `month-value` is **zero-indexed** (January = 0, December = 11), matching the JavaScript `Date` API.
>
> When no `date:` option is passed, the three value attributes are omitted and the controller defaults to the current month.
