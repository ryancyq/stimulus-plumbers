# Icon

Rails helper for rendering a named icon from the active theme's icon registry.

## Helper

### `sp_icon`

```erb
<%= sp_icon "check" %>
<%= sp_icon "spinner", aria: { label: "Loading" }, role: "img" %>
<%= sp_icon "unknown-icon" %>
<%= sp_icon "check", size: :sm %>
```

| Option           | Default    | Description                                                            |
| ---------------- | ---------- | ---------------------------------------------------------------------- |
| `name`           | (required) | Positional (1st argument). Icon name — looked up in the theme registry |
| `size`           | `:lg`      | `:sm` \| `:md` \| `:lg` — theme-resolved size class                    |
| `**html_options` | —          | Forwarded to the root element                                          |

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

- The theme applies `aria-hidden="true"` by default (see [ARIA.md's Avatar / Card / Icon pattern](../../../ARIA.md)).
- For meaningful icons (standalone, no adjacent label), pass `aria: { label: "..." }` and `role: "img"` to override.
- Button and link icons are rendered internally with `aria-hidden="true"`; callers do not need to set this manually.
