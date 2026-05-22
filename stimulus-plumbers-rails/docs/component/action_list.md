# Action List

Rails helpers for rendering an accessible list of actions — links, buttons, or grouped sections.

## Helpers

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::ActionListHelper
end
```

### `sp_action_list`

Renders a `<ul>` wrapper. Yields to a block where items and sections are added.

```erb
<%= sp_action_list do %>
  <%= sp_action_list_item "Home",     url: root_path %>
  <%= sp_action_list_item "Settings", url: settings_path %>
  <%= sp_action_list_item "Sign out" %>
<% end %>
```

| Option           | Default  | Description                                                  |
| ---------------- | -------- | ------------------------------------------------------------ |
| `role`           | `"list"` | ARIA role on the `<ul>` — use `"menu"` for interactive menus |
| `**html_options` | —        | Forwarded to the `<ul>`                                      |

### `sp_action_list_item`

Renders a `<li>` containing a themed `<button>` or `<a>`.

```erb
<%# Plain button %>
<%= sp_action_list_item "Sign out" %>

<%# Link %>
<%= sp_action_list_item "Profile", url: profile_path %>

<%# External link %>
<%= sp_action_list_item "Docs", url: "https://example.com", external: true %>

<%# Active state %>
<%= sp_action_list_item "Dashboard", url: root_path, active: true %>

<%# Block content %>
<%= sp_action_list_item(url: edit_path) { "Edit #{@user.name}" } %>

<%# With icons (forwarded to sp_button) %>
<%= sp_action_list_item "Delete", icon_leading: :trash, variant: :danger %>
```

| Option           | Default | Description                                                                                                   |
| ---------------- | ------- | ------------------------------------------------------------------------------------------------------------- |
| `content`        | `nil`   | Item label — positional arg or block                                                                          |
| `url`            | `nil`   | Renders an `<a>` inside the `<li>`; omit for `<button>`                                                       |
| `external`       | `false` | Adds `target="_blank"` on the anchor                                                                          |
| `active`         | `false` | Applies the `action_list_item(active: true)` theme variant                                                    |
| `**html_options` | —       | Forwarded to the inner `<button>` or `<a>` (including `icon_leading:`, `icon_trailing:`, `variant:`, `size:`) |

All options accepted by `sp_button` are forwarded — see [button.md](button.md).

### `sp_action_list_section`

Renders a `<li>` wrapper containing an optional visible heading and a nested `<ul>`.

```erb
<%= sp_action_list do %>
  <%= sp_action_list_section(title: "Account") do %>
    <%= sp_action_list_item "Profile", url: profile_path %>
    <%= sp_action_list_item "Billing", url: billing_path %>
  <% end %>
  <%= sp_action_list_section(title: "Danger zone") do %>
    <%= sp_action_list_item "Delete account" %>
  <% end %>
<% end %>
```

| Option           | Default | Description                                                                                                 |
| ---------------- | ------- | ----------------------------------------------------------------------------------------------------------- |
| `title`          | `nil`   | Section heading rendered as a visible `<span>` (aria-hidden); also set as `aria-label` on the nested `<ul>` |
| `**html_options` | —       | Forwarded to the outer `<li>`                                                                               |

---

## Rendered HTML Structure

### Flat list

```html
<ul role="list">
  <li>
    <button type="button" class="[action_list_item theme classes]">Home</button>
  </li>
  <li>
    <a href="/settings" class="[action_list_item theme classes]">Settings</a>
  </li>
</ul>
```

### Active item

```html
<li>
  <a href="/" class="[action_list_item active theme classes]">Dashboard</a>
</li>
```

### Sectioned list

```html
<ul role="list">
  <li>
    <span aria-hidden="true">Account</span>
    <ul aria-label="Account">
      <li>
        <a href="/profile" class="[action_list_item theme classes]">Profile</a>
      </li>
    </ul>
  </li>
</ul>
```

### Item with icon

Icons are rendered as siblings outside the inner `<button>`/`<a>` — see [button.md](button.md#with-icons) for details.

```html
<li>
  <span aria-hidden="true" class="[button_icon theme classes]"
    ><!-- icon --></span
  >
  <button type="button" class="[action_list_item theme classes]">Delete</button>
</li>
```

---

## ARIA

- Default `role="list"` is appropriate for navigation or command lists where items are not exclusively interactive menu commands.
- Use `role="menu"` + `role="menuitem"` (via `html_options`) only when the list represents a widget menu (e.g. a dropdown opened by a button) — Arrow key navigation must then be wired separately via a Stimulus controller.
- The `active` state must be communicated beyond color alone; pair it with `aria: { current: "page" }` in `html_options` for navigation lists.
- Section titles use `aria-hidden="true"` on the visible `<span>` and `aria-label` on the nested `<ul>` to avoid double-announcing the heading to screen readers.
