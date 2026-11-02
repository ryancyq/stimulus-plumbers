# Popover plumber

`Popover` adapts a native `popover` element to the popover lifecycle used by `popover_controller`.
`:popover-open` is authoritative; the top layer, light dismissal, and Escape remain browser behavior.

```js
import { attachPopover } from '@stimulus-plumbers/controllers';

const popover = attachPopover(controller, { element: controller.panelTarget });
popover.show(button); // native showPopover({ source: button })
popover.hide();
popover.toggle(button); // native togglePopover({ source: button })
popover.disconnect();
```

## Options

| Option    | Type        | Default              | Description            |
| --------- | ----------- | -------------------- | ---------------------- |
| `element` | HTMLElement | `controller.element` | Native popover element |
| `prefix`  | String      | `'popover'`          | Event name prefix      |

## Members

| Member            | Description                                               |
| ----------------- | --------------------------------------------------------- |
| `open`            | Read-only reflection of `:popover-open`                   |
| `show(source?)`   | Opens with native `showPopover()` and optional source     |
| `hide()`          | Closes with native `hidePopover()`                        |
| `toggle(source?)` | Toggles with native `togglePopover()` and optional source |
| `disconnect()`    | Removes native lifecycle listeners; safe to repeat        |

The adapter observes native `beforetoggle` and `toggle` and dispatches the
[popover lifecycle events](../component/popover.md#events) from the panel. A non-popover element produces an
inert adapter.

The plumber does not move focus, trap focus, add dismissal listeners, fetch content, or position the panel.
