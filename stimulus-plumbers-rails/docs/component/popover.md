# Popover

Rails helper for rendering an accessible popover with a trigger and panel slot.

## Helper

```erb
<%# Default button trigger %>
<%= sp_popover do |p| %>
  <% p.trigger { "Open" } %>
  <% p.panel(role: "dialog", aria: { label: "Options" }) do %>
    <p>Popover content</p>
  <% end %>
<% end %>

<%# Custom trigger element — one-arity block receives wiring attrs %>
<%= sp_popover do |p| %>
  <% p.trigger do |attrs| %>
    <button type="button"
            aria-haspopup="<%= attrs[:aria][:haspopup] %>"
            aria-expanded="<%= attrs[:aria][:expanded] %>"
            aria-controls="<%= attrs[:panel_id] %>"
            data-popover-target="trigger"
            data-action="<%= attrs[:data][:action] %>">
      <%= image_tag "avatar.png", alt: "My account" %>
    </button>
  <% end %>
  <% p.panel(role: "menu", aria: { label: "Account" }) do %>
    ...
  <% end %>
<% end %>
```

| Option           | Default | Description                                      |
| ---------------- | ------- | ------------------------------------------------ |
| `panel_id:`      | auto    | Override the generated panel `id`                |
| `**html_options` | —       | Forwarded to the outer wrapper `div`             |

### `p.trigger`

Zero-arity block — renders a wired `<button>`; block content becomes the button label:

```erb
<% p.trigger { "Open" } %>
<% p.trigger(haspopup: "listbox") { "Choose" } %>
```

One-arity block — yields `{ panel_id:, aria:, data: }` for caller-defined elements:

```erb
<% p.trigger do |attrs| %>
  <input type="text" role="combobox"
         aria-controls="<%= attrs[:panel_id] %>"
         data-action="<%= attrs[:data][:action] %>">
<% end %>
```

### `p.panel`

All kwargs are forwarded as HTML attributes. The panel is hidden by default and revealed by the Stimulus controller.

```erb
<% p.panel(tag: :ul, role: "listbox", aria: { labelledby: "my-label" }) do %>
  ...
<% end %>
```

---

## `build` — for component authors

When a component owns its outer wrapper, call `build` instead of `render` to get trigger + panel without the extra div or `data-controller="popover"`:

```ruby
Components::Popover.new(template).build(panel_id: "my-panel") do |p|
  p.trigger(haspopup: "listbox") { |attrs| render_my_trigger(attrs) }
  p.panel(tag: :ul, role: "listbox") { options_html }
end
```

---

## Rendered HTML Structure

```html
<div data-controller="popover" class="[popover_wrapper]">
  <button type="button"
          aria-haspopup="dialog"
          aria-expanded="false"
          aria-controls="[panel_id]"
          data-popover-target="trigger"
          data-action="click->popover#toggle keydown.esc->popover#close"
          class="[popover_trigger]">
    Open
  </button>
  <div id="[panel_id]" hidden class="[popover]" role="dialog" aria-label="Options">
    Popover content
  </div>
</div>
```

---

## ARIA

- Default trigger button has `aria-haspopup="dialog"`, `aria-expanded="false"`, and `aria-controls` pointing to the panel.
- `aria-expanded` is toggled to `"true"` / `"false"` by the Stimulus controller.
- Pass `role: "dialog"` or `role: "tooltip"` on `p.panel` based on whether the content is interactive.
- `aria: { label: }` or `aria: { labelledby: }` on `p.panel` provides the accessible name.

For the JS controller API (targets, values, keyboard behaviour), see the [JS package docs](../../../stimulus-plumbers/docs/component/popover.md).
