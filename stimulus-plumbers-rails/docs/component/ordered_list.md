# OrderedList

Rails helper for a flat, reorderable list — pointer-drag and keyboard reorder via the [`reorderable`](../../../stimulus-plumbers/docs/component/reorderable.md) JS controller. Unlike [`List`](list.md), item order is semantic content (`<ol>`, not `<ul>`), there are no sections, and every item has a pointer drag surface.

## Helper

### `sp_ordered_list`

```erb
<%# Whole-item handle (default), content-only rows %>
<%= sp_ordered_list do |list| %>
  <%= list.item("First", id: "item-1") %>
  <%= list.item("Second", id: "item-2") %>
<% end %>

<%# Links + a dedicated leading-icon handle, editing enabled %>
<%= sp_ordered_list(editing: true) do |list| %>
  <%= list.item(id: "link-1", url: "/", handle: :leading) do |item| %>
    <% item.with_title("Dashboard") %>
  <% end %>
<% end %>
```

| Option           | Default | Description                                                              |
| ---------------- | ------- | -------------------------------------------------------------------------- |
| `move_key:`      | `"Alt"` | Maps to `data-reorderable-move-key-value`. One of `Alt`, `Control`, `Shift`, `Meta`. |
| `editing:`       | `false` | Initial render-time state, maps to `data-reorderable-editing-value`.       |
| `role:`          | `"list"` | ARIA role on the `<ol>` — preserves list semantics when consumer CSS resets `list-style`. |
| `**html_options` | —       | Forwarded to the outer `<ol>`.                                             |

### `list.item(content, id:, handle:, url:, target:, active:, **html_options, &block)`

| Option           | Default  | Description                                                                                  |
| ---------------- | -------- | ---------------------------------------------------------------------------------------------- |
| `content`        | `nil`    | Item label — positional arg or via `item.with_title`.                                          |
| `id:`            | —        | **Required.** Raises `ArgumentError` if missing.                                               |
| `handle:`        | `:item`  | `:item` (whole `<li>` is the drag surface) \| `:leading` \| `:trailing` (that icon position is). |
| `url:`           | `nil`    | Renders `<a href>` around the title/description. Without it, content renders with no wrapper (no click target at all — no `<button>` fallback, unlike `List::Item`). |
| `target:`        | `nil`    | Forwarded to the `<a>` (e.g. `"_blank"`), only used when `url:` is set.                        |
| `active:`        | `false`  | Adds `aria-current="page"`, only used when `url:` is set.                                      |
| `**html_options` | —        | Forwarded to the `<a>` when `url:` is set. Raises `ArgumentError` if given without `url:` — there is no element for them to land on. |

### Item slot methods (yielded as `item`)

| Slot method                     | Description                                                                                                   |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `item.with_icon_leading(name)`   | Icon at the leading position. Becomes the drag handle if `handle: :leading`; otherwise purely decorative.        |
| `item.with_title(text)`          | Title text (pre-populated when positional `content` is given).                                                   |
| `item.with_description(text)`    | Secondary text below the title.                                                                                  |
| `item.with_icon_trailing(name)`  | Icon at the trailing position. Becomes the drag handle if `handle: :trailing`; otherwise purely decorative.       |

If `handle: :leading`/`:trailing` is set and the corresponding icon slot isn't, a default `grip-vertical` glyph renders there instead.

---

## Rendered HTML Structure

### `handle: :item` (default), no link

```html
<ol role="list" data-controller="reorderable" data-reorderable-move-key-value="Alt" data-reorderable-editing-value="false">
  <li id="item-1" data-reorderable-target="item handle" data-action="pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp">
    First
  </li>
</ol>
```

### `handle: :leading`, with a link

```html
<li id="link-1" data-reorderable-target="item">
  <span data-reorderable-target="handle" data-action="pointerdown->reorderable#onPointerDown ...">
    <svg aria-hidden="true">...</svg> <!-- grip-vertical, or a custom icon if item.with_icon_leading was set -->
  </span>
  <a href="/" data-reorderable-target="trigger">
    <span>
      <span>Dashboard</span>
      <span>Overview</span>
    </span>
  </a>
</li>
```

Icon positions (leading/trailing) are always siblings of the `<a>`, never nested inside it — this is what lets a real link coexist with drag reordering without one accidentally triggering the other. See [reorderable's editing mode](../../../stimulus-plumbers/docs/component/reorderable.md) for how the link itself is neutralized while editing.

---

## Theme keys

| Key                             | Element                                          | Variants |
| -------------------------------- | --------------------------------------------------- | -------- |
| `ordered_list`                   | Outer `<ol>`                                        | —        |
| `ordered_list_item`              | `<li>`                                              | —        |
| `ordered_list_item_handle`       | Leading/trailing `<span>` (decorative-or-handle)    | —        |
| `ordered_list_item_content`      | Content wrapper `<span>` inside `<a>` (or bare)     | —        |
| `ordered_list_item_title`        | Title `<span>`                                      | —        |
| `ordered_list_item_description`  | Description `<span>`                                | —        |

---

## ARIA

- See [ARIA.md](../../../ARIA.md) for WCAG 2.1 AA criteria.
- For the `reorderable` JS controller's targets, values, and actions (including `editingValue`/`trigger`/`toggleEditing`), see the [stimulus-plumbers JS controller doc](../../../stimulus-plumbers/docs/component/reorderable.md).
