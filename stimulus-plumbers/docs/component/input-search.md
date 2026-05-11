# input-search

Shows a clear button when a search input has a value, hides it when empty, and clears the input on demand. Keyboard users can also press Escape inside the input to clear it.

## Targets

| Target  | Element                 | Description                           |
| ------- | ----------------------- | ------------------------------------- |
| `input` | `<input type="search">` | The search input to monitor and clear |
| `clear` | `<button>`              | The button that triggers clearing     |

## Methods

| Method    | Wired via     | Description                                                                                     |
| --------- | ------------- | ----------------------------------------------------------------------------------------------- |
| `clear()` | `data-action` | Empties the input, hides the clear button, returns focus to the input, dispatches `input` event |
| `draw()`  | `data-action` | Syncs clear button visibility to the current input value                                        |

## Example

```html
<div data-controller="input-search">
  <input type="search" data-input-search-target="input" data-action="input->input-search#draw" />
  <button
    type="button"
    aria-label="Clear search"
    data-input-search-target="clear"
    data-action="click->input-search#clear"
  ></button>
</div>
```

## Accessibility

- The clear button must carry `aria-label="Clear search"` — the controller never overrides it.
- The clear button is hidden (`hidden` attribute) while the input is empty, so keyboard users only reach it when there is something to clear.
- After clearing, focus returns to the input so the user can type immediately (WCAG 2.4.3 Focus Order).
- Pressing Escape inside the input clears it when the field has a value; the event's default is prevented to avoid closing parent overlays unintentionally.
- No `aria-live` region is needed — clearing is user-initiated and the button's disappearance is self-explanatory.

## Notes

- Suppress the native WebKit clear button via CSS to avoid visual duplication: `input[type="search"]::-webkit-search-cancel-button { appearance: none }`.
- `clear()` dispatches a native `input` event with `bubbles: true` so upstream listeners (e.g. live search) react to the cleared value.
- The controller is standalone — it has no dependency on `input-format` or any other plumber.
