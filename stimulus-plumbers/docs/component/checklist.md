# Checklist

Select-all checkbox for a group of native `<input type="checkbox">` checklist items. Aggregates their `.checked` state onto a select-all checkbox's `checked`/`indeterminate` properties and toggles them all at once. See [stimulus-plumbers-rails's docs/component/checklist.md](../../../stimulus-plumbers-rails/docs/component/checklist.md) for the Rails render options.

## Stimulus Identifier

`checklist`

## Targets

| Name        | Purpose                                                             |
| ----------- | ------------------------------------------------------------------- |
| `selectAll` | The select-all `<input type="checkbox">` — receives aggregate state |
| `item`      | Each checklist item `<input type="checkbox">`                       |

## Actions

| Name        | Purpose                                                                                                                                   |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `onChange`  | Wired to `change` on the wrapper — event adapter: calls `toggleAll` if the event came from the select-all checkbox, otherwise `recompute` |
| `toggleAll` | Programmatic API — sets every enabled item's `.checked` to the given value, then calls `recompute`                                        |
| `recompute` | Programmatic API — writes the select-all checkbox's `.checked`/`.indeterminate` from the enabled items' aggregate state                   |

The select-all checkbox also recomputes when items are added or removed, after a Turbo morph, and after a form reset.

## Example HTML

```html
<div data-controller="checklist" data-action="change->checklist#onChange">
  <label>
    <input type="checkbox" data-checklist-target="selectAll" />
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
