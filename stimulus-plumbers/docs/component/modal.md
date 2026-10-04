# modal

Adapts a native `<dialog>` opened with `showModal()` to the modal lifecycle. The controller
does not provide a custom overlay, focus trap, announcements, or body scroll lock.

The supported contract allows one active modal at a time. Opening another modal while one is open
is unsupported; applications should close or replace the active modal first.

## Migration from legacy modal markup

The legacy controller supported a custom overlay with `modal` and `overlay` targets:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>
  <div data-modal-target="overlay" hidden>
    <div data-modal-target="modal" role="dialog" aria-modal="true">
      <button data-action="modal#close">Cancel</button>
    </div>
  </div>
</div>
```

Use a native dialog target instead. Wire `modal#dismiss` for cancellation and `modal#close` for
completion:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>
  <dialog data-modal-target="dialog" closedby="closerequest" aria-labelledby="modal-title">
    <h2 id="modal-title">Confirm action</h2>
    <button data-action="modal#dismiss">Cancel</button>
    <button data-action="modal#close">Confirm</button>
  </dialog>
</div>
```

Remove `dismissed()`, the custom body lock and focus trap, `aria-modal`, and global open/close
announcements. The current controller has no compatibility alias for the legacy targets or hooks.

## Targets

| Target   | Required | Description               |
| -------- | -------- | ------------------------- |
| `dialog` | yes      | Native `<dialog>` element |

## Methods

| Method                    | Description                                             |
| ------------------------- | ------------------------------------------------------- |
| `open(event?)`            | Opens the dialog; repeated calls while open are ignored |
| `dismiss(eventOrResult?)` | Requests a cancellable dismissal                        |
| `close(eventOrResult?)`   | Explicitly completes and closes the dialog              |

The dialog must have an accessible name through `aria-labelledby` or `aria-label`.
The controller passes the action invoker to the dialog adapter so focus restoration remains
reliable on engines that do not focus a clicked button. Native restoration still wins; the
fallback runs only if focus remains on the document or inside the closed dialog.

Action parameters use `result`, for example:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>

  <dialog data-modal-target="dialog" aria-labelledby="modal-title">
    <h2 id="modal-title">Confirm action</h2>
    <p>Are you sure?</p>
    <button data-action="modal#dismiss">Cancel</button>
    <button data-action="modal#close" data-modal-result-param="confirm">Confirm</button>
  </dialog>
</div>
```

`<form method="dialog">` is also supported. Results are normalized to strings and reported
through `modal:closed`.

## Events

Events are dispatched from the `<dialog>`:

| Event                  | Cancellable | Detail       |
| ---------------------- | ----------- | ------------ |
| `modal:before-open`    | yes         | `{}`         |
| `modal:opened`         | no          | `{}`         |
| `modal:before-dismiss` | yes         | `{ result }` |
| `modal:closed`         | no          | `{ result }` |

Escape and backdrop dismissal emit `modal:before-dismiss`. Explicit `close()`, external
`.close()`, and `method="dialog"` completion do not.

## Dismissal policy

Author the native `closedby` attribute directly:

```html
<dialog data-modal-target="dialog" closedby="closerequest" aria-labelledby="modal-title">
  <h2 id="modal-title">Confirm action</h2>
  <button data-action="modal#dismiss">Cancel</button>
  <button data-action="modal#close" data-modal-result-param="confirm">Confirm</button>
</dialog>
```

Use `any` to allow backdrop dismissal, `closerequest` for Escape only, or `none` to disable
dismissal requests. Explicit completion remains available for every policy.

## Accessibility

- See [ARIA.md's Modal pattern](../../../ARIA.md) for the accessibility contract.

## Turbo modal

`modal-turbo` is the Turbo Frame adapter for `modal` on the same wrapper and opens a native dialog after a
successful, non-empty Turbo Frame render. It uses `onBeforeFetchRequest(event)`,
`onFrameRender(event)`, `onSubmitEnd(event)`, and `onClosed(event)` actions; frame rendering must
use Turbo's `fetchResponse` detail from `turbo:frame-render`.

```html
<div
  data-controller="modal modal-turbo"
  data-modal-turbo-close-on-success-value="true"
  data-action="modal:closed->modal-turbo#onClosed"
>
  <dialog data-modal-target="dialog" aria-labelledby="modal-title">
    <turbo-frame
      id="modal"
      data-modal-turbo-target="frame"
      data-action="turbo:before-fetch-request->modal-turbo#onBeforeFetchRequest turbo:frame-render->modal-turbo#onFrameRender turbo:submit-end->modal-turbo#onSubmitEnd"
    ></turbo-frame>
  </dialog>
</div>
```

`closeOnSuccess` defaults to `true`; set `data-modal-turbo-close-on-success-value="false"` to
keep the dialog open after a successful form submission. Validation and network failures remain
open. A successful response rendered after `turbo:submit-end` is cleared without reopening the
dialog. If it arrives while the close clear is pending, the content remains until the dialog's
exit animation completes; after a prior clear, the new response is cleared without reopening. The
controller clears frame content after the close animation and before Turbo caches the page.

Frame responses use direct `<header>`, body `<div>`, and optional `<footer>` children. Include the
visible `h2#modal-title` when using `aria-labelledby`; a body form may be submitted by a footer
control using the standard HTML `form` attribute. The packaged modal stylesheet owns the dialog
and backdrop opacity/transform transitions; the surface theme does not duplicate those states.
