# Divider

Rails helper for rendering a horizontal rule, optionally labelled.

## Helper

### `sp_divider`

```erb
<%= sp_divider %>
<%= sp_divider "or" %>
<%= sp_divider "Section title", class: "my-4" %>
```

| Option           | Default | Description                                               |
| ---------------- | ------- | --------------------------------------------------------- |
| `label`          | `nil`   | Positional arg. When present, the label is centred between two `<hr>` lines |
| `**html_options` | —       | Forwarded to the outer `<div role="separator">`           |

---

## Rendered HTML Structure

### Without label

```html
<div role="separator" class="[divider theme classes]">
  <hr class="[divider_separator theme classes]" />
</div>
```

### With label

```html
<div role="separator" class="[divider theme classes]">
  <hr class="[divider_separator theme classes]" />
  <span class="[divider_label theme classes]">or</span>
  <hr class="[divider_separator theme classes]" />
</div>
```

---

## ARIA

- The outer `<div>` always carries `role="separator"`.
- The label `<span>` is visible text — no additional ARIA needed.
