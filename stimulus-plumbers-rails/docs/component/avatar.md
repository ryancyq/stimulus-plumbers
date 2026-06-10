# Avatar

Rails helper for rendering a user avatar — image, initials, or fallback silhouette.

## Helper

### `sp_avatar`

```erb
<%# Image from URL %>
<%= sp_avatar url: user.avatar_url, name: user.name %>

<%# Initials (SVG text) %>
<%= sp_avatar initials: "RC", name: "Ryan Chang" %>

<%# Named variant + size %>
<%= sp_avatar initials: "AB", name: "Alice B", variant: :purple, size: :lg %>

<%# Auto-selected variant (hashed from name) %>
<%= sp_avatar name: "Ryan Chang" %>

<%# Custom content block %>
<%= sp_avatar(name: "Ryan") { image_tag "custom.png" } %>
```

| Option           | Default | Description                                                                                |
| ---------------- | ------- | ------------------------------------------------------------------------------------------ |
| `name`           | `nil`   | Used for `aria-label` and auto-variant selection                                           |
| `initials`       | `nil`   | Renders an SVG with the initials text; used when no `url` or block is given                |
| `url`            | `nil`   | Image source; renders `<img>` with `alt="[name]'s avatar"` and `onerror` fallback          |
| `variant`        | `nil`   | Color variant for the avatar background — auto-selected from theme range if omitted        |
| `size`           | `:md`   | Size — values defined by the active theme (e.g. `:xs` \| `:sm` \| `:md` \| `:lg` \| `:xl`) |
| `**html_options` | —       | Forwarded to the `<span>` wrapper                                                          |

**Render modes (in priority order):**

| Condition            | Output                         |
| -------------------- | ------------------------------ |
| Block given          | Custom content inside `<span>` |
| `url:` provided      | `<img>` inside `<span>`        |
| `initials:` provided | SVG with initials text         |
| None of the above    | SVG fallback silhouette        |

---

## Rendered HTML Structure

```html
<span role="img" aria-label="Ryan Chang" class="[avatar theme classes]">
  <!-- image mode -->
  <img
    src="[url]"
    alt="Ryan Chang's avatar"
    class="[avatar_image theme classes]"
  />

  <!-- initials mode -->
  <svg viewBox="0 0 40 40">
    <text
      x="50%"
      y="50%"
      dy="0.35em"
      text-anchor="middle"
      fill="currentColor"
      font-size="20"
    >
      RC
    </text>
  </svg>

  <!-- fallback mode -->
  <svg viewBox="0 0 40 40">
    <path fill="currentColor" d="..." />
  </svg>
</span>
```

---

## ARIA

- Always renders `role="img"` with `aria-label` set to `name` (when provided).
- Image `alt` is set to `"[name]'s avatar"`; for anonymous avatars `alt=""` is used.
- `onerror` on `<img>` clears the `src` to prevent broken-image icons.
