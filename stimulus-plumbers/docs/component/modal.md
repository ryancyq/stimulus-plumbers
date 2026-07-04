# modal

Implements the [WAI-ARIA Dialog (Modal) pattern](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/). Supports both native `<dialog>` elements and custom overlay implementations.

## Targets

| Target    | Description                                                 |
| --------- | ----------------------------------------------------------- |
| `modal`   | The dialog element (required)                               |
| `overlay` | Optional wrapper shown/hidden around `modal` in custom mode |

## Methods

| Method         | Wired via                 | Description                                                                    |
| -------------- | ------------------------- | ------------------------------------------------------------------------------ |
| `open(event)`  | `data-action`             | Action — opens the modal, traps focus inside                                   |
| `close(event)` | `data-action`, Escape key | Action — closes the modal, restores focus to trigger                           |
| `dismissed()`  | Dismisser plumber         | Plumber callback — called on click-outside (custom mode only); calls `close()` |

## Native `<dialog>` usage

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>

  <dialog data-modal-target="modal" aria-labelledby="modal-title" aria-modal="true">
    <h2 id="modal-title">Confirm action</h2>
    <p>Are you sure?</p>
    <button data-action="modal#close">Cancel</button>
    <button>Confirm</button>
  </dialog>
</div>
```

The browser handles backdrop rendering. Clicking outside the dialog closes it via `onBackdropClick` (an internal handler, not part of the public API).

## Custom overlay usage

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>

  <div data-modal-target="overlay" hidden>
    <div data-modal-target="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title">
      <h2 id="modal-title">Title</h2>
      <button data-action="modal#close">Close</button>
    </div>
  </div>
</div>
```

Focus is trapped inside `modal` target using `FocusTrap`. Escape key and click-outside (via `dismissed()`) both close the modal.

## Accessibility

- Focus moves into the modal on open; returns to the trigger on close
- Focus is trapped — Tab/Shift+Tab cycle within the modal
- Escape closes the modal
- `body` scroll is locked while open (custom mode)
- See [ARIA.md's Modal pattern](../../../ARIA.md) for the status-announcement contract
