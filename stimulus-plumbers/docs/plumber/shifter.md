# Shifter

Applies a CSS `translate` transform to keep an element inside the viewport boundaries. Recalculates on `resize` (or configured events). Used by `visibility`.

Extends `WindowObserver`. Exposes `this.shift()` on the controller, registers window event listeners, and cleans up on `disconnect`.

## Factory

```js
import { attachShifter } from '../plumbers';
attachShifter(controller, options);
```

## Options

| Option          | Type        | Default                    | Description                                                       |
| --------------- | ----------- | -------------------------- | ----------------------------------------------------------------- |
| `element`       | HTMLElement | controller.element         | Element to shift                                                  |
| `events`        | String[]    | `['resize']`               | Events triggering a shift recalculation                           |
| `boundaries`    | String[]    | `['top', 'left', 'right']` | Viewport edges to check: `'top'`, `'bottom'`, `'left'`, `'right'` |
| `respectMotion` | Boolean     | `true`                     | Suppresses CSS transitions when `prefers-reduced-motion` is set   |
| `onShifted`     | String      | `'shifted'`                | Controller method called after shifting                           |

## Controller method — `this.shift(element)`

Applies a `translate(x, y)` transform to bring the element back within configured viewport boundaries. Only fires when the element is visible.

## Dispatches & callbacks

| Moment     | Dispatch           | Callback                                                                                |
| ---------- | ------------------ | --------------------------------------------------------------------------------------- |
| Pre-shift  | `{prefix}:shift`   | —                                                                                       |
| Post-shift | `{prefix}:shifted` | `onShifted(overflow)` — `overflow` is an object with direction keys and pixel distances |
