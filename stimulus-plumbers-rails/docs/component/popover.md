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

| Option             | Default | Description                                                                                     |
| ------------------ | ------- | ----------------------------------------------------------------------------------------------- |
| `panel_id:`        | auto    | Override the generated panel `id`                                                               |
| `close_on_select:` | —       | When `false`, sets `data-popover-close-on-select-value="false"` (panel stays open on selection) |
| `**html_options`   | —       | Forwarded to the outer wrapper `div`                                                            |

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

### `p.panel` / `p.build_panel`

Two panel slots mirror the `render` / `build` split (and the 0-/1-arity `trigger`):

`p.panel` — the builder renders the wired panel element; all kwargs are forwarded as
HTML attributes. The panel is hidden by default and revealed by the Stimulus controller.

```erb
<% p.panel(tag: :ul, role: "listbox", aria: { labelledby: "my-label" }) do %>
  ...
<% end %>
```

`p.build_panel` — the **caller** renders the element; the block receives
`(panel_id, panel_attrs)` to spread onto its own root. Use it when the panel needs a
structure of its own (e.g. combobox typeahead: a wrapper around a listbox plus sibling
status regions).

```ruby
p.build_panel(classes: "...") do |panel_id, panel_attrs|
  content_tag(:div, **panel_attrs) { safe_join([listbox_html, status_html]) }
end
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

`Popover::Panel` exposes the same pair: `#render` (builds the wired element) and `#build`
(yields `panel_id` + attrs for the caller to wire).

---

## Rendered HTML Structure

```html
<div data-controller="popover" class="[popover_wrapper]">
  <button
    type="button"
    aria-haspopup="dialog"
    aria-expanded="false"
    aria-controls="[panel_id]"
    data-popover-target="trigger"
    data-action="click->popover#toggle keydown.esc->popover#close"
    class="[popover_trigger]"
  >
    Open
  </button>
  <div
    id="[panel_id]"
    hidden
    class="[popover]"
    role="dialog"
    aria-label="Options"
    data-popover-target="panel"
  >
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
