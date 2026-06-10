# Card

Rails helper for rendering a themed card with optional icon, title, body, and action slots.

## Helper

### `sp_card`

```erb
<%# Minimal %>
<%= sp_card do |card| %>
  <% card.with_body { "Simple content." } %>
<% end %>

<%# With title and icon %>
<%= sp_card(title_tag: :h3) do |card| %>
  <% card.with_icon("user") %>
  <% card.with_title("Account") %>
  <% card.with_body { "Your account is active." } %>
<% end %>

<%# With action link %>
<%= sp_card do |card| %>
  <% card.with_title("Settings") %>
  <% card.with_action("Manage", url: settings_path) %>
<% end %>

<%# With action button (no url) %>
<%= sp_card do |card| %>
  <% card.with_action("Open") %>
<% end %>
```

| Option           | Default     | Description                        |
| ---------------- | ----------- | ---------------------------------- |
| `variant:`       | `:tertiary` | Theme variant for the card wrapper |
| `title_tag:`     | `:h2`       | HTML tag used by `with_title`      |
| `**html_options` | —           | Forwarded to the outer `<div>`     |

### Slot methods (yielded as `card`)

| Slot method                        | Description                                                                  |
| ---------------------------------- | ---------------------------------------------------------------------------- |
| `card.with_icon(name_or_html)`     | Icon before the title — string/symbol resolves via `Icon`; HTML passed as-is |
| `card.with_title(text)`            | Title text rendered as `title_tag`                                           |
| `card.with_body { content }`       | Body content — block required                                                |
| `card.with_action(text, url: nil)` | Action link (`<a>`) when `url:` present; `<button>` otherwise                |

`with_action` raises `ArgumentError` when `url:` is given but no content (text or block).

---

## Rendered HTML Structure

```html
<div class="[card theme classes]">
  <!-- header: rendered when icon or title is present -->
  <div class="[card_header theme classes]">
    <svg aria-hidden="true" class="[card_icon theme classes]">...</svg>
    <h2 class="[card_title theme classes]">Account</h2>
  </div>

  <!-- body -->
  <div class="[card_body theme classes]">Your account is active.</div>

  <!-- action -->
  <div class="[card_action theme classes]">
    <a href="/settings">Manage</a>
  </div>
</div>
```

---

## Theme keys

| Key           | Element                             | Variants                                      |
| ------------- | ----------------------------------- | --------------------------------------------- |
| `card`        | Outer `<div>`                       | `variant: :primary\|:secondary\|:tertiary\|…` |
| `card_header` | Header wrapper `<div>` (icon+title) | —                                             |
| `card_icon`   | Icon inside the header              | —                                             |
| `card_title`  | Title element (`h2` etc.)           | —                                             |
| `card_body`   | Body `<div>`                        | —                                             |
| `card_action` | Action `<div>`                      | —                                             |

---

## ARIA

- `sp_card` is a layout container — no ARIA roles are added automatically.
- Supply `role:` or `aria:` via `html_options` when the card plays a semantic role (e.g. `role: "region"`, `aria: { label: "..." }`).
- For interactive card-style inputs (radio/checkbox), see `f.choice` with `type: :card` in the [form doc](form.md).
