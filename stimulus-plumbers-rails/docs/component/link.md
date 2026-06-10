# Link

Rails helper for rendering themed, accessible links and link-styled buttons.

## Helper

### `sp_link`

```erb
<%= sp_link "Home", url: root_path %>
<%= sp_link "Docs", url: docs_path, type: :button %>
<%= sp_link "Delete", url: item_path(@item), type: :card, variant: :destructive %>
<%= sp_link(icon_leading: "arrow-left", url: back_path) { "Back" } %>
<%= sp_link "GitHub", url: "https://github.com", target: "_blank" %>
```

| Option           | Default    | Description                                                                        |
| ---------------- | ---------- | ---------------------------------------------------------------------------------- |
| `content`        | `nil`      | Link text — positional arg or block                                                |
| `url`            | (required) | `href` value                                                                       |
| `type`           | `:default` | Visual style — `:default` \| `:button` \| `:card`                                  |
| `variant`        | `:default` | Color source — `:default` \| `:success` \| `:destructive` \| `:warning` \| `:info` |
| `icon_leading`   | `nil`      | Icon rendered **before** the label — icon name (string or symbol) or callable      |
| `icon_trailing`  | `nil`      | Icon rendered **after** the label — icon name (string or symbol) or callable       |
| `target`         | `nil`      | Forwarded to `<a target>`. `"_blank"` auto-sets `icon_trailing: "external-link"`   |
| `**html_options` | —          | Forwarded to the `<a>` element                                                     |

**`type:` — visual style**

| Value      | Appearance                                                                 |
| ---------- | -------------------------------------------------------------------------- |
| `:default` | Inline text link — colored, underlines on hover                            |
| `:button`  | Outlined button shape — border + surface background, no fill               |
| `:card`    | Full-padding card — `flex-1`, `justify-start`; border + surface background |

**`variant:` — color source**

Unlike `sp_button`, link variants use `--link-color` / `--link-ring` / `--link-bg` tokens. `:default` maps to `--sp-color-primary`.

---

## Rendered HTML Structure

Text content is always wrapped in a `<span>`:

```html
<a href="/path" class="[theme classes]"><span>Home</span></a>
```

### With icons

```html
<a href="/path" class="[theme classes]">
  <svg aria-hidden="true" class="[link_icon theme classes]">
    <!-- icon svg -->
  </svg>
  <span>Back</span>
</a>
```

### External link (auto trailing icon)

```html
<a href="https://github.com" target="_blank" class="[theme classes]">
  <span>GitHub</span>
  <svg aria-hidden="true" class="[link_icon theme classes]">
    <!-- external-link icon -->
  </svg>
</a>
```

### Icon only (`type: :button`)

When no text is provided, `type: :button` links become square (same mechanism as `sp_button`):

```html
<a href="/path" aria-label="Add" class="[theme classes]">
  <svg aria-hidden="true" class="[link_icon theme classes]">
    <!-- icon svg -->
  </svg>
</a>
```

---

## ARIA

- Renders an `<a>` element — use `sp_button` for actions without a URL destination.
- `target="_blank"` automatically appends an external-link icon (`aria-hidden="true"`); add a visually-hidden description if the context requires it.
- Icon-only links must supply an accessible label via `aria: { label: "..." }` in `html_options`.
