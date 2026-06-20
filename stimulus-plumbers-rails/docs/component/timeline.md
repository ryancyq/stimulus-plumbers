# Timeline

Rails helper for rendering a themed timeline as an ordered list with optional interactive (expandable) events.

## Helper

### `sp_timeline`

```erb
<%# Static — server-rendered date text %>
<%= sp_timeline do |t| %>
  <% t.event(datetime: "2024-01-15") do |e| %>
    <% e.indicator %>
    <% e.time { "January 2024" } %>
    <% e.title { "Event title" } %>
    <% e.description { "Brief text" } %>
    <% e.actions { sp_link("Read more", url: "/") } %>
  <% end %>
<% end %>

<%# Interactive (expandable) — client-formatted date %>
<%= sp_timeline(interactive: true,
                data: { "timeline-date-format-value": { month: "long", year: "numeric", day: "numeric" }.to_json }) do |t| %>
  <% t.event(id: "event-1", datetime: "2024-01-15") do |e| %>
    <% e.indicator %>
    <% e.trigger { "Event title" } %>
    <% e.description { "Brief text" } %>
    <% e.detail { "Expanded content" } %>
    <% e.actions { sp_link("Read more", url: "/") } %>
  <% end %>
<% end %>
```

| Option           | Default     | Description                                               |
| ---------------- | ----------- | --------------------------------------------------------- |
| `orientation:`   | `:vertical` | Passed to theme as `theme.resolve(:timeline, orientation:)` |
| `interactive:`   | `false`     | Adds `data-controller="timeline"` to `<ol>`              |
| `**html_options` | —           | Forwarded to the outer `<ol>`                             |

### `t.event` options

| Option           | Default | Description                                                       |
| ---------------- | ------- | ----------------------------------------------------------------- |
| `datetime:`      | `nil`   | Renders `<time datetime="...">` — required when `e.time {}` used |
| `id:`            | `nil`   | Stable base ID; derives detail element id via `detail_id_for`    |
| `**html_options` | —       | Forwarded to the `<li>`                                           |

### Event slot methods (yielded as `e`)

| Slot method                   | Description                                                                                         |
| ----------------------------- | --------------------------------------------------------------------------------------------------- |
| `e.indicator`                 | Dot indicator `<div aria-hidden="true">`                                                            |
| `e.indicator(icon: "name")`   | Icon indicator — renders `Icon` component inside the wrapper                                        |
| `e.time { text }`             | Text content for `<time>`; requires `datetime:` on `t.event`                                       |
| `e.title { text }`            | Static `<h3>` — mutually exclusive with `e.trigger`                                                |
| `e.trigger { text }`          | `<h3><button>` — mutually exclusive with `e.title`; button has `aria-expanded` and `aria-controls` |
| `e.description { text }`      | `<p>` element                                                                                       |
| `e.detail { text }`           | Collapsible `<div hidden>` — requires `e.trigger`; id linked to trigger's `aria-controls`          |
| `e.actions { content }`       | Actions wrapper `<div>` — suppressed when block yields nil/empty                                    |

**Constraints:**
- `e.title` and `e.trigger` are mutually exclusive — raises `ArgumentError` if both set.
- `e.detail` requires `e.trigger` — raises `ArgumentError` otherwise.
- `e.time` requires `datetime:` on `t.event` — raises `ArgumentError` otherwise.
- `e.actions` requires a block — raises `ArgumentError` otherwise.

---

## Rendered HTML Structure

### Static

```html
<ol>
  <li>
    <div aria-hidden="true"></div>                    <!-- indicator dot -->
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
    <time datetime="2024-01-15"></time>               <!-- filled by JS dateFormatValue -->
    <h3>
      <button type="button"
              aria-expanded="false"
              aria-controls="event-1_detail"
              data-timeline-target="trigger"
              data-action="timeline#toggle">
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

| Key                         | Element                           | Variants              |
| --------------------------- | --------------------------------- | --------------------- |
| `timeline`                  | Outer `<ol>`                      | `orientation:`        |
| `timeline_item`             | `<li>`                            | `orientation:`        |
| `timeline_item_indicator`   | Indicator `<div>`                 | `type: :dot \| :icon` |
| `timeline_item_time`        | `<time>`                          | —                     |
| `timeline_item_title`       | Static `<h3>`                     | —                     |
| `timeline_item_heading`     | `<h3>` wrapping the trigger button | —                    |
| `timeline_item_trigger`     | `<button>` inside the heading     | —                     |
| `timeline_item_description` | `<p>`                             | —                     |
| `timeline_item_detail`      | Collapsible `<div>`               | —                     |
| `timeline_item_actions`     | Actions `<div>`                   | —                     |

---

## ARIA

- See [ARIA.md](../../ARIA.md) for WCAG 2.1 AA criteria and disclosure widget patterns.
- The trigger button uses `aria-expanded` (managed by the JS controller) and `aria-controls` pointing to the detail `id`.
- Indicator elements carry `aria-hidden="true"` to hide decorative markup from screen readers.
- For JS controller targets, values, and actions, see the [stimulus-plumbers JS controller doc](../../stimulus-plumbers/docs/component/timeline.md).
