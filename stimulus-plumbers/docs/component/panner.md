# panner

Keeps a content element within the viewport by applying a CSS `translate` transform when the window resizes. Backed by the `Shifter` plumber.

## Targets

| Target    | Description                                                                |
| --------- | -------------------------------------------------------------------------- |
| `content` | Element to keep in-viewport. Defaults to the controller element if absent. |

## Example

```html
<div data-controller="panner">
  <div data-panner-target="content">
    <!-- content that must stay visible when the window resizes -->
  </div>
</div>
```

## Notes

- Shifting is skipped when the `content` target is hidden.
- See [docs/plumber/shifter.md](../plumber/shifter.md) for the full options API (`boundaries`, `events`, `respectMotion`).
