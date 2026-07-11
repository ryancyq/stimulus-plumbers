# Timeline

Rails helper for rendering a themed timeline as an ordered list with optional interactive (expandable) events.

## Helper

### `sp_timeline`

```erb
<%# Static — server-rendered date text %>
<%= sp_timeline do |t| %>
  <% t.event(datetime: "2024-01-15") do |e| %>
    <% e.with_indicator %>
    <% e.with_time { "January 2024" } %>
    <% e.with_title { "Event title" } %>
    <% e.with_description { "Brief text" } %>
    <% e.with_actions { sp_link("Read more", url: "/") } %>
  <% end %>
<% end %>

<%# Interactive (expandable) — client-formatted date %>
<%= sp_timeline(interactive: true,
                data: { "timeline-date-format-value": { month: "long", year: "numeric", day: "numeric" }.to_json }) do |t| %>
  <% t.event(id: "event-1", datetime: "2024-01-15") do |e| %>
    <% e.with_indicator %>
    <% e.with_trigger { "Event title" } %>
    <% e.with_description { "Brief text" } %>
    <% e.with_detail { "Expanded content" } %>
    <% e.with_actions { sp_link("Read more", url: "/") } %>
  <% end %>
<% end %>
```

| Option           | Default     | Description                                                                                                  |
| ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------ |
| `orientation:`   | `:vertical` | Layout direction — `:vertical` \| `:horizontal`. Passed to theme as `theme.resolve(:timeline, orientation:)` |
| `interactive:`   | `false`     | Adds `data-controller="timeline"` to `<ol>`                                                                  |
| `**html_options` | —           | Forwarded to the outer `<ol>`                                                                                |

### `t.event` options

| Option           | Default | Description                                                      |
| ---------------- | ------- | ---------------------------------------------------------------- |
| `datetime:`      | `nil`   | Renders `<time datetime="...">` — required when `e.time {}` used |
| `id:`            | `nil`   | Stable base ID; derives detail element id via `detail_id_for`    |
| `**html_options` | —       | Forwarded to the `<li>`                                          |

### Event slot methods (yielded as `e`)

| Slot method                      | Description                                                                                             |
| -------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `e.with_indicator`               | Dot indicator `<div aria-hidden="true">`                                                                |
| `e.with_indicator(icon: "name")` | Icon indicator — renders `Icon` component inside the wrapper                                            |
| `e.with_time { text }`           | Text content for `<time>`; requires `datetime:` on `t.event`                                            |
| `e.with_title { text }`          | Static `<h3>` — mutually exclusive with `e.with_trigger`                                                |
| `e.with_trigger { text }`        | `<h3><button>` — mutually exclusive with `e.with_title`; button has `aria-expanded` and `aria-controls` |
| `e.with_description { text }`    | `<p>` element                                                                                           |
| `e.with_detail { text }`         | Collapsible `<div hidden>` — requires `e.with_trigger`; id linked to trigger's `aria-controls`          |
| `e.with_actions { content }`     | Actions wrapper `<div>` — suppressed when block yields nil/empty                                        |

**Constraints:**

- `e.with_title` and `e.with_trigger` are mutually exclusive — raises `ArgumentError` if both set.
- `e.with_detail` requires `e.with_trigger` — raises `ArgumentError` otherwise.
- `e.with_time` requires `datetime:` on `t.event` — raises `ArgumentError` otherwise.

### `sp_timeline_group`

Groups events under dated sections, each with its own `<ol>` — for timelines broken up by day/month rather than one flat list.

```erb
<%= sp_timeline_group do |g| %>
  <% g.section(date: "January 2025", datetime: "2025-01-15") do |t| %>
    <% t.event do |e| %>
      <% e.with_indicator %>
      <% e.with_title { "Event title" } %>
      <% e.with_description { "Brief text" } %>
    <% end %>
  <% end %>
<% end %>
```

| Option           | Default     | Description                                                               |
| ---------------- | ----------- | ------------------------------------------------------------------------- |
| `orientation:`   | `:vertical` | Layout direction for each section's events — `:vertical` \| `:horizontal` |
| `**html_options` | —           | Forwarded to the outer `<div>`                                            |

`g.section` options:

| Option           | Default | Description                                        |
| ---------------- | ------- | -------------------------------------------------- |
| `date:`          | —       | Required — text content for the section's `<time>` |
| `datetime:`      | `nil`   | Renders `<time datetime="...">` when set           |
| `**html_options` | —       | Forwarded to the section's outer `<div>`           |

Each `g.section` block yields a `t` scoped to that section (same `t.event` API as `sp_timeline`, non-interactive, orientation inherited from `sp_timeline_group`'s `orientation:`).

---

## Rendered HTML Structure

### Static

```html
<ol>
  <li>
    <div aria-hidden="true"></div>
    <!-- indicator dot -->
    <time datetime="2024-01-15">January 2024</time>
    <h3>Event title</h3>
    <p>Brief text</p>
    <div><!-- actions --></div>
  </li>
</ol>
```

### Interactive

```html
<ol data-controller="timeline">
  <li>
    <div aria-hidden="true"></div>
    <time datetime="2024-01-15"></time>
    <!-- filled by JS dateFormatValue -->
    <h3>
      <button
        type="button"
        aria-expanded="false"
        aria-controls="event-1_detail"
        data-timeline-target="trigger"
        data-action="timeline#toggle"
      >
        Event title
      </button>
    </h3>
    <p>Brief text</p>
    <div id="event-1_detail" hidden data-timeline-target="detail">
      Expanded content
    </div>
    <div><!-- actions --></div>
  </li>
</ol>
```

---

## Theme keys

| Key                           | Element                            | Variants              |
| ----------------------------- | ---------------------------------- | --------------------- |
| `timeline`                    | Outer `<ol>`                       | `orientation:`        |
| `timeline_item`               | `<li>`                             | `orientation:`        |
| `timeline_item_indicator`     | Indicator `<div>`                  | `type: :dot \| :icon` |
| `timeline_item_time`          | `<time>`                           | —                     |
| `timeline_item_title`         | Static `<h3>`                      | —                     |
| `timeline_item_heading`       | `<h3>` wrapping the trigger button | —                     |
| `timeline_item_trigger`       | `<button>` inside the heading      | —                     |
| `timeline_item_description`   | `<p>`                              | —                     |
| `timeline_item_detail`        | Collapsible `<div>`                | —                     |
| `timeline_item_actions`       | Actions `<div>`                    | —                     |
| `timeline_group`              | `sp_timeline_group` outer `<div>`  | —                     |
| `timeline_group_section`      | `g.section` outer `<div>`          | —                     |
| `timeline_group_section_date` | Section `<time>`                   | —                     |
| `timeline_group_section_list` | Section `<ol>`                     | `orientation:`        |

---

## ARIA

- See [ARIA.md](../../../ARIA.md) for WCAG 2.1 AA criteria and disclosure widget patterns.
- The trigger button uses `aria-expanded` (managed by the JS controller) and `aria-controls` pointing to the detail `id`.
- Indicator elements carry `aria-hidden="true"` to hide decorative markup from screen readers.
- For JS controller targets, values, and actions, see the [stimulus-plumbers JS controller doc](../../../stimulus-plumbers/docs/component/timeline.md).
