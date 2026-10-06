# Popover

`sp_popover` renders a trigger and a native `popover` panel under one `popover` controller. The JavaScript API
is documented in the [JS popover guide](../../../stimulus-plumbers/docs/component/popover.md); accessibility
rules live in [ARIA.md](../../../ARIA.md).

## Helper

### `sp_popover`

```erb
<%= sp_popover do |popover| %>
  <% popover.trigger { "Open" } %>
  <% popover.panel(role: :region, aria_label: "Options") do %>
    <p>Popover content</p>
  <% end %>
<% end %>
```

| Option           | Default                           | Description                                                                                                                                                                |
| ---------------- | --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `panel_id:`      | `Popover.panel_id_for(sp_dom_id)` | Panel id override                                                                                                                                                          |
| `mode:`          | `:auto`                           | `:auto` (native light dismissal) or `:manual` (consumer owns every close path); other values raise `ArgumentError`                                                         |
| `placement:`     | `:block_end_start`                | Logical, writing-mode aware — `:block_end_start`, `:block_end`, `:block_end_end`, `:block_start_start`, `:block_start`, `:block_start_end`, `:inline_start`, `:inline_end` |
| `**html_options` | —                                 | Forwarded to the outer `<div>`                                                                                                                                             |

### Slot methods (yielded as `popover`)

| Slot method                                                                  | Description                                                                                                                            |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `popover.trigger(haspopup: nil, controls: panel_id)`                         | Zero-arity block renders a `<button popovertarget>`; a one-arity block yields the relationship attributes for a caller-rendered source |
| `popover.panel(tag: :div, role: nil, aria_label: nil, aria_labelledby: nil)` | Renders the panel element                                                                                                              |
| `popover.build_panel(role: nil, aria_label: nil, aria_labelledby: nil)`      | Yields the panel attributes for a caller-owned root element                                                                            |

`haspopup:` also authors `aria-haspopup`, `aria-expanded="false"`, and `aria-controls` (`controls:`); without it
the trigger gets none of them. A caller-rendered source adds its own activation action:

```erb
<% popover.trigger(haspopup: :listbox) do |attrs| %>
  <%= tag.input type: "text", role: "combobox", aria: attrs[:aria],
                data: attrs[:data].merge(action: "click->popover#open") %>
<% end %>
```

For remote content, put a matching Turbo Frame in the panel; the endpoint returns
`<turbo-frame id="notifications_content">…</turbo-frame>`:

```erb
<% popover.panel(role: :region, aria_label: "Notifications") do %>
  <turbo-frame id="notifications_content" src="<%= notifications_path %>" loading="lazy">
    <p>Loading notifications…</p>
  </turbo-frame>
<% end %>
```

---

## Rendered HTML Structure

```html
<div data-controller="popover" class="[popover_wrapper theme classes]">
  <button
    type="button"
    popovertarget="[id]_popover"
    data-popover-target="trigger"
    class="[popover_trigger theme classes]"
  >
    Open
  </button>
  <div
    id="[id]_popover"
    popover="auto"
    role="region"
    aria-label="Options"
    data-popover-target="panel"
    class="[popover theme classes]"
  >
    <p>Popover content</p>
  </div>
</div>
```

## Theme keys

| Key               | Element         | Variants                   |
| ----------------- | --------------- | -------------------------- |
| `popover_wrapper` | Outer `<div>`   | —                          |
| `popover_trigger` | Packaged button | —                          |
| `popover`         | Panel           | `placement:` (see Options) |

## ARIA

- The helper infers no panel role or name; pass them through `popover.panel` (e.g. `role: :region` with `aria_label:`).
- See [ARIA.md's Popover pattern](../../../ARIA.md) for the accessibility contract.
