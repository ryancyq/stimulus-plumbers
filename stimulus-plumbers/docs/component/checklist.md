# Checklist

Master "select all" toggle for a group of native `<input type="checkbox">` checklist items. Aggregates their `.checked` state onto a master checkbox's `checked`/`indeterminate` properties and toggles them all at once. See [stimulus-plumbers-rails's docs/component/checklist.md](../../../stimulus-plumbers-rails/docs/component/checklist.md) for the Rails render options.

## Stimulus Identifier

`checklist`

## Targets

| Name     | Purpose                                                               |
| -------- | --------------------------------------------------------------------- |
| `master` | The "select all" `<input type="checkbox">` — receives aggregate state |
| `item`   | Each checklist item `<input type="checkbox">`                         |

## Actions

| Name        | Purpose                                                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `onChange`  | Wired to `change` on the wrapper — event adapter: if the event came from the master, calls `toggleAll`; always calls `recompute` |
| `toggleAll` | Programmatic API — sets every enabled item's `.checked` to the given value                                                       |
| `recompute` | Programmatic API — writes the master's `.checked`/`.indeterminate` from the enabled items' aggregate state                       |

## Example HTML

```html
<div data-controller="checklist" data-action="change->checklist#onChange">
  <label>
    <input type="checkbox" data-checklist-target="master" />
    Select all
  </label>

  <label>
    <input type="checkbox" data-checklist-target="item" checked />
    Buy milk
  </label>

  <label>
    <input type="checkbox" data-checklist-target="item" />
    Walk the dog
  </label>
</div>
```

Disabled items (`disabled` attribute) are excluded from both aggregation and bulk toggling — the controller filters them out via `enabledItems()`. `indeterminate` is a JS-only property with no HTML attribute; it is set on connect and after every change, never rendered server-side.
