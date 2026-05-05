# Popover

Rails helper for rendering a popover with a trigger and content slot.

## Helper

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::PopoverHelper
end
```

```erb
<%= sp_popover do |p| %>
  <%= p.trigger { tag.button "Open", data: { action: "popover#show" } } %>
  <%= p.content(role: "dialog", aria: { label: "Options" }) do %>
    <p>Popover content</p>
    <%= tag.button "Close", data: { action: "popover#hide" } %>
  <% end %>
<% end %>
```

| Option | Default | Description |
|--------|---------|-------------|
| `interactive` | `true` | When `true`, renders a `role="dialog"` popover; `false` renders a tooltip |
| `**html_options` | — | Forwarded to the wrapper element |

For the JS controller API (targets, values, remote loading), see the [JS package docs](../../../stimulus-plumbers/docs/component/popover.md).
