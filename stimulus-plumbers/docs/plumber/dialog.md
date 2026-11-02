# Dialog plumber

`Dialog` adapts a native `<dialog>` element to the modal lifecycle. It is not a visibility
plumber and does not implement a custom overlay or focus trap.

```js
import { attachDialog } from '@stimulus-plumbers/controllers';

const dialog = attachDialog(controller, { element: controller.dialogTarget });
dialog.show();
dialog.dismiss('cancel');
dialog.close('confirm');
dialog.disconnect();
```

## Members

| Member             | Description                            |
| ------------------ | -------------------------------------- |
| `open`             | Read-only reflection of `element.open` |
| `show(invoker?)`   | Opens with `showModal()`               |
| `dismiss(result?)` | Requests a cancellable dismissal       |
| `close(result?)`   | Explicitly completes and closes        |
| `disconnect()`     | Removes native and fallback listeners  |

The adapter observes native `beforetoggle`, `toggle`, `cancel`, and `close` events. It uses
`requestClose()` when available and a cancellable `cancel` fallback otherwise. On engines
without `closedBy`, `closedby="any"` uses a matching `pointerdown`/`pointerup` backdrop pair.

Escape with a popover open inside the dialog follows
[ARIA.md's Modal pattern](../../../ARIA.md). The adapter skips `popover="manual"` panels, an Escape
already handled (`defaultPrevented`), and a nested open dialog, which handles its own Escape.

Focus restoration remains native-first. `show(invoker?)` accepts the element that initiated an
open for engines that do not focus clicked buttons; native `beforetoggle.source` and the active
element cover declarative and programmatic opens. After close, the adapter restores the remembered
invoker only when focus is still stranded on the document or closed dialog. It does not override
focus moved by the browser or an application listener, and it ignores an invoker that was removed.
