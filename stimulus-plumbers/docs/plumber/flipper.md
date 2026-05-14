# Flipper

Positions an element relative to an anchor, flipping to the opposite direction when the preferred placement overflows the viewport. Used by `flipper` and `popover`.

## Factory

```js
import { attachFlipper } from '../plumbers';
attachFlipper(controller, options);
```

Exposes `this.flip()` on the controller and registers window event listeners. Cleans up on `disconnect`.

## Options

| Option          | Type        | Default            | Description                                                     |
| --------------- | ----------- | ------------------ | --------------------------------------------------------------- |
| `element`       | HTMLElement | controller.element | Element to position                                             |
| `anchor`        | HTMLElement | `null`             | Reference element to position relative to                       |
| `events`        | String[]    | `['click']`        | Events triggering a flip recalculation                          |
| `placement`     | String      | `'bottom'`         | Preferred placement: `'top'`, `'bottom'`, `'left'`, `'right'`   |
| `alignment`     | String      | `'start'`          | Cross-axis alignment: `'start'`, `'center'`, `'end'`            |
| `ariaRole`      | String      | `null`             | ARIA role applied to element via `connectTriggerToTarget`       |
| `respectMotion` | Boolean     | `true`             | Suppresses CSS transitions when `prefers-reduced-motion` is set |
| `onFlipped`     | String      | `'flipped'`        | Controller method called after positioning                      |

## Controller method — `this.flip()`

Calculates available space around the anchor, positions the element in the preferred direction, and flips to the opposite direction if there is insufficient space. Sets `position: absolute` and writes `top`/`left` styles directly.

## Dispatches & callbacks

| Moment    | Dispatch           | Callback                           |
| --------- | ------------------ | ---------------------------------- |
| Pre-flip  | `{prefix}:flip`    | —                                  |
| Post-flip | `{prefix}:flipped` | `onFlipped({ target, placement })` |

## Cleanup

`Flipper` patches `controller.disconnect` to call `unobserve()` automatically.
