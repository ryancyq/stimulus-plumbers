# Shifter

Applies a CSS `translate` transform to keep an element inside the viewport boundaries. Recalculates on `resize` (or configured events). Used by `visibility`.

## Factory

```js
import { attachShifter } from '../plumbers';
attachShifter(controller, options);
```

Exposes `this.shift()` on the controller and registers window event listeners. Cleans up on `disconnect`.

## Options

| Option          | Type        | Default                    | Description                                                       |
| --------------- | ----------- | -------------------------- | ----------------------------------------------------------------- |
| `element`       | HTMLElement | controller.element         | Element to shift                                                  |
| `events`        | String[]    | `['resize']`               | Events triggering a shift recalculation                           |
| `boundaries`    | String[]    | `['top', 'left', 'right']` | Viewport edges to check: `'top'`, `'bottom'`, `'left'`, `'right'` |
| `respectMotion` | Boolean     | `true`                     | Suppresses CSS transitions when `prefers-reduced-motion` is set   |
| `onShifted`     | String      | `'shifted'`                | Controller method called after shifting                           |

## Controller method — `this.shift(element)`

Measures how much the element overflows each configured boundary and applies a `translate(x, y)` transform to push it back inside the viewport. Accounts for any existing transform so repeated calls are idempotent.

Only fires when the element is visible.

## Dispatches & callbacks

| Moment     | Dispatch           | Callback                                                                                |
| ---------- | ------------------ | --------------------------------------------------------------------------------------- |
| Pre-shift  | `{prefix}:shift`   | —                                                                                       |
| Post-shift | `{prefix}:shifted` | `onShifted(overflow)` — `overflow` is an object with direction keys and pixel distances |

## Cleanup

`Shifter` patches `controller.disconnect` to call `unobserve()` automatically.
