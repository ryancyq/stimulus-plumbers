# Checklist

Rails helper for rendering an accessible group of checkbox-style items. Items render as native `<label><input type="checkbox"></label>` pairs, no `<li>` wrapper — see [ARIA.md's Checklist pattern](../../../ARIA.md) for why.

## Helper

### `sp_checklist`

```erb
<%= sp_checklist(label: "Groceries") do |checklist| %>
  <%= checklist.item("Buy milk", checked: true) %>
  <%= checklist.item("Walk the dog", checked: false) %>
<% end %>

<%# With a description %>
<%= sp_checklist(label: "Onboarding") do |checklist| %>
  <%= checklist.item("Verify email", checked: true) do |item| %>
    <% item.with_description("Sent to you at signup") %>
  <% end %>
<% end %>

<%# Read-only summary (e.g. an activity feed) %>
<%= sp_checklist(label: "Completed steps") do |checklist| %>
  <%= checklist.item("Account created", checked: true, readonly: true) %>
<% end %>
```

| Option              | Default        | Description                                                                                                      |
| ------------------- | -------------- | ---------------------------------------------------------------------------------------------------------------- |
| `label:`            | `nil`          | Sets `aria-label` on the group wrapper                                                                           |
| `labelledby:`       | `nil`          | Sets `aria-labelledby`; takes precedence over `label:` when both given                                           |
| `select_all:`       | `false`        | `true` renders a master "select all" toggle wired to the group's items                                           |
| `select_all_label:` | `"Select all"` | Label text for the master toggle (used as both `aria-label` and visible text); ignored unless `select_all: true` |
| `**html_options`    | —              | Forwarded to the `<div role="group">`                                                                            |

### `select_all:`

```erb
<%= sp_checklist(label: "Groceries", select_all: true, select_all_label: "Select all items") do |checklist| %>
  <%= checklist.item("Buy milk", checked: true) %>
  <%= checklist.item("Walk the dog", checked: false) %>
<% end %>
```

Renders a master `<label><input type="checkbox"></label>` before the items, wired to the `checklist` Stimulus controller. See [stimulus-plumbers's docs/component/checklist.md](../../../stimulus-plumbers/docs/component/checklist.md) for the controller's targets and actions.

Read-only items (`readonly: true`) are excluded from the master's aggregate state — see [ARIA.md's Checklist pattern](../../../ARIA.md) for why.

### `checklist.item(content, checked:, readonly:, **html_options, &block)`

Renders a `<label>` wrapping a native `<input type="checkbox">`.

| Option           | Default | Description                                                                          |
| ---------------- | ------- | ------------------------------------------------------------------------------------ |
| `content`        | `nil`   | Item label — positional arg or via `item.with_title`                                 |
| `checked:`       | —       | **Required.** Sets `checked`                                                         |
| `readonly:`      | `false` | `true` renders **disabled** on the input — removed from the tab order, no controller |
| `**html_options` | —       | Forwarded to the `<label>`                                                           |

### Item slot methods (yielded as `item`)

| Slot method                   | Description                                                   |
| ----------------------------- | ------------------------------------------------------------- |
| `item.with_title(text)`       | Title text (pre-populated when positional `content` is given) |
| `item.with_description(text)` | Secondary text below the title                                |

---

## Rendered HTML Structure

```html
<div role="group" aria-label="Groceries" class="[checklist theme classes]">
  <label class="[checklist_item theme classes]">
    <input
      type="checkbox"
      checked
      data-checklist-target="item"
      class="[checklist_item_input theme classes]"
    />
    <span class="[checklist_item_content theme classes]">
      <span class="[checklist_item_title theme classes]">Buy milk</span>
    </span>
  </label>
</div>
```

### `select_all: true`

```html
<div
  role="group"
  aria-label="Groceries"
  data-controller="checklist"
  data-action="change->checklist#onChange"
  class="[checklist theme classes]"
>
  <label class="[checklist_item theme classes]">
    <input
      type="checkbox"
      data-checklist-target="master"
      class="[checklist_item_input theme classes]"
    />
    Select all
  </label>

  <label class="[checklist_item theme classes]">
    <input
      type="checkbox"
      checked
      data-checklist-target="item"
      class="[checklist_item_input theme classes]"
    />
    ...
  </label>
</div>
```

The master's `checked` state is computed from the items' `checked:` values at render time (all-true renders `checked`; every other case, including mixed, renders unchecked) — the `checklist` controller corrects it to `indeterminate` client-side once connected. See [ARIA.md's Checklist pattern](../../../ARIA.md) for the accepted flash this tradeoff causes in the mixed case.

### Read-only item (`readonly: true`)

```html
<label class="[checklist_item theme classes]">
  <input
    type="checkbox"
    checked
    disabled
    class="[checklist_item_input theme classes]"
  />
  ...
</label>
```

---

## Theme keys

| Key                          | Element                                        | Variants |
| ---------------------------- | ---------------------------------------------- | -------- |
| `checklist`                  | Outer `<div role="group">`                     | —        |
| `checklist_item`             | Item `<label>`                                 | —        |
| `checklist_item_input`       | Item/master checkbox `<input>`                 | —        |
| `checklist_item_content`     | Content wrapper `<span>` (title + description) | —        |
| `checklist_item_title`       | Title `<span>`                                 | —        |
| `checklist_item_description` | Description `<span>`                           | —        |

Checked-state styling (strikethrough title) reads the sibling `<input>`'s `:checked` state via Tailwind's `:has()`-based `group-has-checked/checklist-item:` variant — there is no `aria-checked` or `checked:` theme-resolver kwarg to pass.

---

## ARIA

See [ARIA.md's Checklist pattern](../../../ARIA.md) for why items use native `<input type="checkbox">` with no ARIA attributes, the `disabled` read-only behavior, and the `indeterminate` tradeoff for the master toggle.
