# Button

Rails helpers for rendering themed, accessible buttons and links.

## Helpers

### `sp_button`

```erb
<%= sp_button "Save" %>
<%= sp_button "Visit", url: root_path %>
<%= sp_button "Docs",  url: "https://example.com", external: true %>
<%= sp_button(icon_leading: "check") { "Confirm" } %>
<%= sp_button "Delete", variant: :danger, size: :sm %>
```

| Option           | Default    | Description                                                                    |
| ---------------- | ---------- | ------------------------------------------------------------------------------ |
| `content`        | `nil`      | Button label — positional arg or block                                         |
| `url`            | `nil`      | Renders an `<a>` instead of `<button>`                                         |
| `external`       | `false`    | Adds `target="_blank"` (only used when `url:` is set)                          |
| `target`         | `nil`      | Explicit `target` attribute for the anchor (overridden by `external:`)         |
| `variant`        | `:primary` | Theme variant — values depend on the active theme (e.g. `:primary`, `:danger`) |
| `size`           | `:md`      | Theme size — values depend on the active theme (e.g. `:sm`, `:md`, `:lg`)      |
| `icon_leading`   | `nil`      | Icon rendered **before** the button — icon name (string or symbol) or callable |
| `icon_trailing`  | `nil`      | Icon rendered **after** the button — icon name (string or symbol) or callable  |
| `**html_options` | —          | Forwarded to the `<button>` or `<a>` element                                   |

**Icon values:**

- String or symbol — resolved by name through the active theme's icon registry, rendered via `sp_icon` with `button_icon` theme classes applied
- Callable (e.g. `-> { tag.span "★" }`) — rendered as-is, no theme applied

### `sp_button_group`

Wraps buttons in a themed container `<div>`.

```erb
<%= sp_button_group do %>
  <%= sp_button "Cancel", variant: :secondary %>
  <%= sp_button "Save" %>
<% end %>

<%= sp_button_group(alignment: :right, direction: :row) do %>
  ...
<% end %>
```

| Option           | Default | Description                                              |
| ---------------- | ------- | -------------------------------------------------------- |
| `alignment`      | `:left` | Alignment variant passed to the `button_group` theme key |
| `direction`      | `:row`  | Direction variant passed to the `button_group` theme key |
| `**html_options` | —       | Forwarded to the wrapper `<div>`                         |

---

## Rendered HTML Structure

### Button (action)

```html
<button type="button" class="[theme classes]">Save</button>
```

### Link button

```html
<a href="/path" class="[theme classes]"> Visit </a>
```

### External link

```html
<a href="https://example.com" target="_blank" class="[theme classes]"> Docs </a>
```

### With icons

Icons are rendered as **siblings** outside the `<button>`/`<a>`, not inside it:

```html
<span aria-hidden="true" class="[button_icon theme classes]"
  ><!-- icon svg --></span
>
<button type="button" class="[theme classes]">Confirm</button>
```

```html
<button type="button" class="[theme classes]">Next</button>
<span aria-hidden="true" class="[button_icon theme classes]"
  ><!-- icon svg --></span
>
```

This means the containing element must establish layout context (e.g. `display: flex`) to align the icon and button visually.

### Button group

```html
<div class="[button_group theme classes]">
  <button type="button">Cancel</button>
  <button type="button">Save</button>
</div>
```

---

## ARIA

- `<button>` always has `type="button"` to prevent accidental form submission.
- Icon-only buttons must supply an accessible label via `aria: { label: "..." }` in `html_options`.
- When rendered as `<a>`, the element has no explicit `role` — screen readers announce it as a link, not a button. Use `url:` only when navigation is the intent.
