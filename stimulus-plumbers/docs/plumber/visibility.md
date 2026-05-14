# Visibility

Manages show/hide state for an element, synchronises `aria-expanded` on an optional activator, and dispatches lifecycle events. Used by `popover` and `visibility`.

## Factory

```js
import { attachVisibility } from '../plumbers';
attachVisibility(controller, options);
```

Exposes `this.visibility` on the controller.

## Options

| Option       | Type        | Default            | Description                                                              |
| ------------ | ----------- | ------------------ | ------------------------------------------------------------------------ |
| `element`    | HTMLElement | controller.element | Target element to show/hide                                              |
| `visibility` | String      | `'visibility'`     | Namespace for the controller property (e.g. `'contentLoaderVisibility'`) |
| `activator`  | HTMLElement | `null`             | Element that receives `aria-expanded` updates                            |
| `onShown`    | String      | `'shown'`          | Controller method called after element is shown                          |
| `onHidden`   | String      | `'hidden'`         | Controller method called after element is hidden                         |

## Controller property — `this.visibility`

| Helper          | Signature          | Description                                                                    |
| --------------- | ------------------ | ------------------------------------------------------------------------------ |
| `show()`        | `async () → void`  | Shows element, sets `aria-expanded="true"`, calls `onShown` callback           |
| `hide()`        | `async () → void`  | Hides element, sets `aria-expanded="false"`, calls `onHidden` callback         |
| `visible`       | `boolean` (getter) | True if element is currently visible (no `hidden` attribute / no hidden class) |
| `isVisible(el)` | `(el) → boolean`   | Checks visibility of any element                                               |

`show()` and `hide()` are no-ops if the element is already in the target state.

## Lifecycle — dispatches & callbacks

| Moment    | Dispatch          | Callback     |
| --------- | ----------------- | ------------ |
| Pre-show  | `{prefix}:show`   | —            |
| Post-show | `{prefix}:shown`  | `onShown()`  |
| Pre-hide  | `{prefix}:hide`   | —            |
| Post-hide | `{prefix}:hidden` | `onHidden()` |

The `hidden` attribute (or configured `hiddenClass`) is toggled synchronously before the callback is awaited, so transitions and focus management can be handled in the controller callback.

## Multiple instances

A controller can attach more than one `Visibility` instance by providing a unique `visibility` namespace:

```js
attachVisibility(this, { element: this.contentTarget }); // this.visibility
attachVisibility(this, { element: this.loaderTarget, visibility: 'loaderVisibility' }); // this.loaderVisibility
```
