# List

Rails helper for rendering an accessible list of links, buttons, or grouped sections.

## Helper

### `sp_list`

```erb
<%# Flat list %>
<%= sp_list do |list| %>
  <%= list.item("Dashboard", url: root_path) %>
  <%= list.item("Settings", url: settings_path) %>
  <%= list.item("Sign out") %>
<% end %>

<%# With icons %>
<%= sp_list do |list| %>
  <%= list.item("Dashboard", url: root_path) do |item| %>
    <% item.with_icon_leading("home") %>
  <% end %>
<% end %>

<%# Grouped sections %>
<%= sp_list(heading_level: 2) do |list| %>
  <%= list.section(title: "Account") do |section| %>
    <%= section.item("Profile", url: profile_path) %>
    <%= section.item("Billing", url: billing_path) %>
  <% end %>
  <%= list.section(title: "Danger zone") do |section| %>
    <%= section.item("Delete account") %>
  <% end %>
<% end %>
```

| Option           | Default  | Description                                                                              |
| ---------------- | -------- | ---------------------------------------------------------------------------------------- |
| `heading_level:` | `nil`    | When set, section titles render as `<h{n}>`; nested sections increment and clamp at `h6` |
| `role:`          | `"list"` | ARIA role on the `<ul>` — use `"menu"` for interactive menus                             |
| `**html_options` | —        | Forwarded to the `<ul>`                                                                  |

### `list.section(title:, description:, **html_options)`

Renders a `<li>` with an optional heading/description and a nested `<ul>`.

| Option         | Default | Description                                                                                          |
| -------------- | ------- | ---------------------------------------------------------------------------------------------------- |
| `title:`       | `nil`   | Without `heading_level`: renders `<span aria-hidden="true">`; with `heading_level`: renders `<h{n}>` |
| `description:` | `nil`   | Rendered as a `<span>` beside the title                                                              |

### `list.item(content, url:, active:, target:, **html_options, &block)`

Renders a `<li>` containing an `<a>` (when `url:` present) or `<button>`.

| Option           | Default | Description                                                         |
| ---------------- | ------- | ------------------------------------------------------------------- |
| `content`        | `nil`   | Item label — positional arg or via `item.with_title`                |
| `url:`           | `nil`   | Renders `<a href>` inside the `<li>`                                |
| `active:`        | `false` | Adds `aria-current="page"` (link) or `aria-current="true"` (button) |
| `target:`        | `nil`   | Forwarded to the `<a>` (e.g. `"_blank"`)                            |
| `**html_options` | —       | Forwarded to the inner `<a>` or `<button>`                          |

When `target: "_blank"` is set, `icon_trailing: "external-link"` is added automatically.

### Item slot methods (yielded as `item`)

| Slot method                     | Description                                                   |
| ------------------------------- | ------------------------------------------------------------- |
| `item.with_icon_leading(name)`  | Icon before the content — string/symbol resolves via `Icon`   |
| `item.with_title(text)`         | Title text (pre-populated when positional `content` is given) |
| `item.with_description(text)`   | Secondary text below the title                                |
| `item.with_icon_trailing(name)` | Icon after the content — string/symbol resolves via `Icon`    |

---

## Rendered HTML Structure

### Flat list

```html
<ul role="list" class="[list theme classes]">
  <li class="[list_item theme classes]">
    <a href="/dashboard" class="...">
      <span class="[list_item_content theme classes]">
        <span class="[list_item_title theme classes]">Dashboard</span>
      </span>
    </a>
  </li>
</ul>
```

### Item with icons

```html
<li class="[list_item theme classes]">
  <a href="/profile" class="...">
    <svg aria-hidden="true" class="[list_item_icon theme classes]">...</svg>
    <span class="[list_item_content theme classes]">
      <span class="[list_item_title theme classes]">Profile</span>
      <span class="[list_item_description theme classes]"
        >Manage your account</span
      >
    </span>
    <svg aria-hidden="true" class="[list_item_icon theme classes]">...</svg>
  </a>
</li>
```

### Sectioned list (no heading_level)

```html
<ul role="list" class="[list theme classes]">
  <li class="[list_section theme classes]">
    <span aria-hidden="true" class="[list_section_title theme classes]"
      >Account</span
    >
    <ul aria-label="Account">
      <li class="[list_item theme classes]">...</li>
    </ul>
  </li>
</ul>
```

### Sectioned list (heading_level: 2)

```html
<ul role="list" class="[list theme classes]">
  <li class="[list_section theme classes]">
    <h2 class="[list_section_title theme classes]">Account</h2>
    <ul aria-label="Account">
      <li class="[list_item theme classes]">...</li>
    </ul>
  </li>
</ul>
```

---

## Theme keys

| Key                        | Element                                               | Variants |
| -------------------------- | ----------------------------------------------------- | -------- |
| `list`                     | Outer `<ul>`                                          | —        |
| `list_section`             | Section wrapper `<li>`                                | —        |
| `list_section_title`       | Section title `<span>` or `<h{n}>`                    | —        |
| `list_section_description` | Section description `<span>`                          | —        |
| `list_item`                | Item `<li>` (theme applied to inner `<a>`/`<button>`) | —        |
| `list_item_icon`           | Leading and trailing icon elements                    | —        |
| `list_item_content`        | Content wrapper `<span>` (title + description)        | —        |
| `list_item_title`          | Title `<span>`                                        | —        |
| `list_item_description`    | Description `<span>`                                  | —        |

---

## ARIA

- Default `role="list"` is appropriate for navigation or command lists.
- Use `role="menu"` + `role="menuitem"` (via `html_options`) only when items form a widget menu — arrow key navigation must then be wired via a Stimulus controller.
- `active: true` adds `aria-current="page"` on links and `aria-current="true"` on buttons; pair this with a visual style change so the state is not communicated by color alone.
- Section titles without `heading_level` use `aria-hidden="true"` on the `<span>` and set `aria-label` on the nested `<ul>` to avoid double-announcing.
- Nested sections increment the heading level automatically (clamped at `h6`).
