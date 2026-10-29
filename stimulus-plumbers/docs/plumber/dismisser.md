# Dismisser

Listens for outside-click (or other) events on `window` and calls a controller callback when a click lands outside the controller's element. Used by `visibility` and `dismisser`.

Extends `WindowObserver`. Registers window event listeners on construction and removes them when its `disconnect()` is called.

## Factory

```js
import { attachDismisser } from '../plumbers';
const dismisser = attachDismisser(controller, options);
dismisser.disconnect(); // when the element's lifetime ends
```

## Options

| Option        | Type        | Default            | Description                                                |
| ------------- | ----------- | ------------------ | ---------------------------------------------------------- |
| `element`     | HTMLElement | controller.element | Element that defines the "inside" boundary                 |
| `trigger`     | HTMLElement | controller.element | Element passed to the `onDismissed` callback as context    |
| `events`      | String[]    | `['click']`        | DOM events to listen for                                   |
| `onDismissed` | String      | `'dismissed'`      | Controller method called when an outside event is detected |

## Behaviour

A dismiss fires only when:

1. The event target is an `HTMLElement`
2. The event target is **not** inside `element`
3. The element is currently **visible** (respects `visibilityConfig.visibleOnly`)

## Dispatches & callbacks

| Moment       | Dispatch             | Callback        |
| ------------ | -------------------- | --------------- |
| Pre-dismiss  | `{prefix}:dismiss`   | —               |
| Post-dismiss | `{prefix}:dismissed` | `onDismissed()` |

## Controller callback

```js
connect() {
  this.dismisser = attachDismisser(this);
}

disconnect() {
  this.dismisser.disconnect();
}

async dismissed() {
  await this.close();
}
```
