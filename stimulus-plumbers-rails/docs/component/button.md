# Button

Rails helpers for rendering themed, accessible buttons and links.

## Helpers

### `sp_button`

```erb
<%= sp_button "Save" %>
<%= sp_button(icon_leading: "check") { "Confirm" } %>
<%= sp_button "Delete", type: :default, variant: :destructive, size: :sm %>
```

| Option           | Default    | Description                                                                                                       |
| ---------------- | ---------- | ----------------------------------------------------------------------------------------------------------------- |
| `content`        | `nil`      | Button label — positional arg or block                                                                            |
| `type`           | `:default` | Visual style — `:default` \| `:outline` \| `:ghost` \| `:fab` \| `:fab_outline` \| `:dashed` \| `:card`           |
| `variant`        | `:primary` | Color source — `:primary` \| `:secondary` \| `:tertiary` \| `:success` \| `:destructive` \| `:warning` \| `:info` |
| `size`           | `:md`      | Size — `:xs` \| `:sm` \| `:md` \| `:lg` \| `:xl` (ignored when `type: :card`)                                     |
| `icon_leading`   | `nil`      | Icon rendered **before** the label — icon name (string or symbol) or callable                                     |
| `icon_trailing`  | `nil`      | Icon rendered **after** the label — icon name (string or symbol) or callable                                      |
| `**html_options` | —          | Forwarded to the `<button>` element                                                                               |

**`type:` — visual style**

| Value          | Appearance                                                                     |
| -------------- | ------------------------------------------------------------------------------ |
| `:default`     | Filled — solid background from `variant` color                                 |
| `:outline`     | Surface background, colored border and text; subtle tint on hover              |
| `:ghost`       | Transparent, no border; subtle tint on hover                                   |
| `:fab`         | Floating action button — `rounded-full`, elevated shadow, filled               |
| `:fab_outline` | Floating action button — `rounded-full`, elevated shadow, fills solid on hover |
| `:dashed`      | Dashed border, surface background                                              |
| `:card`        | Full-padding card — `flex-1`, `justify-start`; `size:` ignored                 |

**`variant:` — color source**

| Value          | Color tokens used              |
| -------------- | ------------------------------ |
| `:primary`     | `--sp-color-primary-*`         |
| `:secondary`   | `--sp-color-secondary-*`       |
| `:tertiary`    | `--sp-color-muted-*` (neutral) |
| `:success`     | `--sp-color-success-*`         |
| `:destructive` | `--sp-color-destructive-*`     |
| `:warning`     | `--sp-color-warning-*`         |
| `:info`        | `--sp-color-info-*`            |

**Icon values:**

- String or symbol — resolved by name through the active theme's icon registry, rendered via `sp_icon` with `button_icon` theme classes applied
- Callable (e.g. `-> { tag.span "★" }`) — rendered as-is, no theme applied

### `sp_button_group`

Wraps buttons in a themed container `<div>`.

```erb
<%= sp_button_group do %>
  <%= sp_button "Cancel", type: :outline %>
  <%= sp_button "Save" %>
<% end %>

<%= sp_button_group(layout: :stacked) do %>
  ...
<% end %>
```

| Option           | Default   | Description                                |
| ---------------- | --------- | ------------------------------------------ |
| `layout`         | `:inline` | Layout direction — `:inline` \| `:stacked` |
| `**html_options` | —         | Forwarded to the wrapper `<div>`           |

---

## Rendered HTML Structure

### Button (action)

Text content is always wrapped in a `<span>`:

```html
<button type="button" class="[theme classes]"><span>Save</span></button>
```

### With icons

Icons are rendered **inside** the `<button>`, before or after the label `<span>`:

```html
<button type="button" class="[theme classes]">
  <svg aria-hidden="true" class="[button_icon theme classes]">
    <!-- icon svg -->
  </svg>
  <span>Confirm</span>
</button>
```

```html
<button type="button" class="[theme classes]">
  <span>Next</span>
  <svg aria-hidden="true" class="[button_icon theme classes]">
    <!-- icon svg -->
  </svg>
</button>
```

### Icon only

When no text is provided, no `<span>` is rendered. The theme uses `:has(> span)` to detect this and applies `aspect-square` + `px-0`, making the button square (or a circle for `type: :fab` / `:fab_outline`):

```html
<button type="button" aria-label="Add" class="[theme classes]">
  <svg aria-hidden="true" class="[button_icon theme classes]">
    <!-- icon svg -->
  </svg>
</button>
```

### Button group

```html
<div role="group" class="[button_group theme classes]">
  <button type="button">Cancel</button>
  <button type="button">Save</button>
</div>
```

---

## ARIA

- `<button>` always has `type="button"` to prevent accidental form submission.
- Icon-only buttons must supply an accessible label via `aria: { label: "..." }` in `html_options`.
- For navigation actions (links), use `sp_link` instead — it renders an `<a>` element.
