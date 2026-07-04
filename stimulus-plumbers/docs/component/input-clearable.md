# input-clearable

Shows a clear button when an input has a value, hides it when empty, and clears the input on demand. Keyboard users can also press Escape inside the input to clear it.

## Targets

| Target  | Element                 | Description                           |
| ------- | ----------------------- | ------------------------------------- |
| `input` | `<input type="search">` | The search input to monitor and clear |
| `clear` | `<button>`              | The button that triggers clearing     |

## Methods

| Method    | Wired via     | Description                                                                                     |
| --------- | ------------- | ----------------------------------------------------------------------------------------------- |
| `clear()` | `data-action` | Empties the input, hides the clear button, returns focus to the input, dispatches `input` event |

> `draw()` is called automatically by the controller whenever the input value changes. It does not need to be wired via `data-action`.

## Example

```html
<div data-controller="input-clearable">
  <input type="search" data-input-clearable-target="input" />
  <button
    type="button"
    aria-label="Clear search"
    data-input-clearable-target="clear"
    data-action="click->input-clearable#clear"
  ></button>
</div>
```

## Accessibility

- The clear button must carry `aria-label="Clear search"` — the controller never overrides it.
- See [ARIA.md's Input Clearable pattern](../../../ARIA.md) for the clear-button tab-order, Escape-key, and focus-return contract.

## Notes

- Suppress the native WebKit clear button via CSS to avoid visual duplication: `input[type="search"]::-webkit-search-cancel-button { appearance: none }`.
- `clear()` dispatches a native `input` event with `bubbles: true` so upstream listeners (e.g. live search) react to the cleared value.
- The controller is standalone — it has no dependency on `input-formatter` or any other plumber.
