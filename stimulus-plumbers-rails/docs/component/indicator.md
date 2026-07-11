# Indicator

Presentational status marker — a colored dot, an animated "pulse" ring, or a numeric badge. No Stimulus controller.

## Helper

### `sp_indicator`

```erb
<%# Dot — must be paired with an accessible name %>
<span>
  <%= sp_indicator(variant: :success) %>
  <span class="sr-only">Online</span>
</span>

<%# Pulse %>
<span>
  <%= sp_indicator(type: :pulse, variant: :destructive, pulse: true) %>
  <span class="sr-only">Live</span>
</span>

<%# Badge %>
<span>
  <%= sp_indicator(type: :badge, variant: :primary) { "5" } %>
  <span class="sr-only">5 unread notifications</span>
</span>
```

| Option           | Default    | Description                                                                                                               |
| ---------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------- |
| `type:`          | `:dot`     | `:dot` \| `:pulse` \| `:badge` — `:badge` renders the given block as content                                              |
| `variant:`       | `:primary` | Semantic color token — `:primary` \| `:secondary` \| `:tertiary` \| `:success` \| `:destructive` \| `:warning` \| `:info` |
| `pulse:`         | `false`    | Adds an animated ring element (`prefers-reduced-motion` suppresses the animation)                                         |
| `**html_options` | —          | Forwarded to the dot `<span>`                                                                                             |

When `pulse: true`, the dot is wrapped in an extra `<span>` (`indicator_wrapper` theme key) that positions the ring behind the dot — no margin offsets involved.

**Every indicator must be paired with an accessible name** — a visible label or `aria-label`/adjacent `sr-only` text. The component itself renders no text and cannot know the right label; this is enforced by an accessibility test (see `test/accessibility/components/indicator_accessibility_test.rb`), not by the component.

## Legend pattern

To explain what each indicator color means (e.g. a status legend), pair indicators with visible text inside a list — do not rely on color alone:

```erb
<%= sp_list do |list| %>
  <%= list.item do |item| %>
    <% item.with_icon_leading { sp_indicator(variant: :success) } %>
    <% item.with_title("Online") %>
  <% end %>
  <%= list.item do |item| %>
    <% item.with_icon_leading { sp_indicator(variant: :warning) } %>
    <% item.with_title("Away") %>
  <% end %>
<% end %>
```
