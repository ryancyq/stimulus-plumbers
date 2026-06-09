# Icon

Rails helper for rendering a named icon from the active theme's icon registry.

## Helper

### `sp_icon`

```erb
<%= sp_icon name: "check" %>
<%= sp_icon name: "spinner", aria: { label: "Loading" }, role: "img" %>
<%= sp_icon name: "unknown-icon" %>
```

| Option           | Default    | Description                               |
| ---------------- | ---------- | ----------------------------------------- |
| `name`           | (required) | Icon name — looked up in the theme registry |
| `**html_options` | —          | Forwarded to the root element             |

---

## Rendered HTML Structure

### Registered icon (SVG rendered)

```html
<svg aria-hidden="true" class="[icon theme classes]">
  <path d="..." />
</svg>
```

### Unregistered name (span fallback)

```html
<span class="[icon theme classes]"></span>
```

---

## ARIA

- Icons are **decorative by default** — the theme applies `aria-hidden="true"` so they are invisible to screen readers.
- For meaningful icons (standalone, no adjacent label), pass `aria: { label: "..." }` and `role: "img"` to override.
- Button and link icons are rendered internally with `aria-hidden="true"`; callers do not need to set this manually.
