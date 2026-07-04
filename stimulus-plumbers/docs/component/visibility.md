# visibility

Shows/hides a `content` element, keeping it within the viewport and dismissing it on click-outside. Backed by the `Visibility`, `Shifter`, and `Dismisser` plumbers.

## Targets

| Target    | Description                                                                       |
| --------- | --------------------------------------------------------------------------------- |
| `content` | Element to show/hide. Optional — `toggle()`/`dismissed()` are no-ops when absent. |

## Methods

| Method        | Wired via         | Description                                                                |
| ------------- | ----------------- | -------------------------------------------------------------------------- |
| `toggle()`    | `data-action`     | Shows `content` if hidden (shifting it into viewport), hides it if visible |
| `dismissed()` | Dismisser plumber | Plumber callback — hides `content` on click-outside                        |

## Example

```html
<div data-controller="visibility">
  <button data-action="visibility#toggle">Toggle</button>
  <div data-visibility-target="content" hidden>Content</div>
</div>
```

## Notes

- See [docs/plumber/visibility.md](../plumber/visibility.md) for the show/hide API and dispatched events.
- See [docs/plumber/shifter.md](../plumber/shifter.md) for the viewport-shifting behavior applied to `content` on show.
- See [docs/component/dismisser.md](dismisser.md) for click-outside-to-dismiss behavior.
