# flipper

Positions a floating element (`reference`) relative to an anchor using the `Flipper` plumber. Useful for tooltips, dropdowns, and popovers that need smart placement.

## Targets

| Target      | Description                                         |
| ----------- | --------------------------------------------------- |
| `anchor`    | The element to position relative to (e.g. a button) |
| `reference` | The floating element to position (e.g. a tooltip)   |

## Values

| Value       | Type   | Default     | Description                                                         |
| ----------- | ------ | ----------- | ------------------------------------------------------------------- |
| `placement` | String | `"bottom"`  | Preferred placement: `"top"` \| `"bottom"` \| `"left"` \| `"right"` |
| `alignment` | String | `"start"`   | Alignment along the cross axis: `"start"` \| `"center"` \| `"end"`  |
| `role`      | String | `"tooltip"` | ARIA role applied to the `reference` element                        |

## Methods

| Method      | Wired via                                  | Description                                                                                         |
| ----------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| `flip()`    | Flipper plumber (enhanced onto controller) | Programmatic API — recalculates and applies position; called automatically on `click` events        |
| `flipped()` | Flipper plumber                            | Plumber callback — called after every position calculation. Override to react to placement changes. |

## Example

```html
<div
  data-controller="flipper"
  data-flipper-placement-value="bottom"
  data-flipper-alignment-value="start"
  data-flipper-role-value="tooltip"
>
  <button data-flipper-target="anchor" aria-describedby="my-tooltip">Hover me</button>

  <div id="my-tooltip" data-flipper-target="reference" hidden>Tooltip text</div>
</div>
```

## Notes

- The Flipper plumber calculates available space and flips placement to the opposite side if the preferred side is out of viewport.
- `role` is set on the `reference` element at connect time via `aria-describedby` / `aria-controls` wiring.
- `flip()` is triggered automatically on `click` events; call it manually after programmatically showing the `reference` element.
