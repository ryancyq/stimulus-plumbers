# Card

Rails helpers for rendering a themed card container with optional sections.

## Helpers

### `sp_card`

```erb
<%= sp_card do %>
  <p>Simple card</p>
<% end %>

<%= sp_card title: "Profile" do %>
  <p>Card with a title heading.</p>
<% end %>

<%= sp_card title: "Settings", title_tag: :h3 do %>
  ...
<% end %>
```

| Option           | Default | Description                                          |
| ---------------- | ------- | ---------------------------------------------------- |
| `title`          | `nil`   | Rendered as a heading inside the card before content |
| `title_tag`      | `:h2`   | HTML tag for the title element                       |
| `**html_options` | —       | Forwarded to the `<div>` wrapper                     |

### `sp_card_section`

Renders a subsection inside a card with its own optional title.

```erb
<%= sp_card do %>
  <%= sp_card_section title: "Details" do %>
    <p>Section content</p>
  <% end %>
  <%= sp_card_section title: "Actions" do %>
    ...
  <% end %>
<% end %>
```

| Option           | Default | Description                                             |
| ---------------- | ------- | ------------------------------------------------------- |
| `title`          | `nil`   | Rendered as a heading inside the section before content |
| `title_tag`      | `:h3`   | HTML tag for the title element                          |
| `**html_options` | —       | Forwarded to the `<div>` wrapper                        |

---

## Rendered HTML Structure

```html
<div class="[card theme classes]">
  <h2>Profile</h2>
  <!-- block content -->

  <div class="[card_section theme classes]">
    <h3>Details</h3>
    <!-- section content -->
  </div>
</div>
```

---

## ARIA

- `sp_card` and `sp_card_section` are pure layout containers — no ARIA roles are added automatically.
- Supply `role:` or `aria:` options via `html_options` when the card plays a semantic role (e.g. `role: "region"`, `aria: { label: "..." }`).
- For interactive card-style inputs (radio/checkbox), see `f.choice` with `type: :card` in the [form doc](form.md).
