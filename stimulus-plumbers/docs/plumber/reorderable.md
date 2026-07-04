# Reorderable

Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system. Composes safely with a separately-instantiated `RovingTabIndex` on the same items regardless of attach order — `RovingTabIndex` ignores modified arrow keys by default (see `docs/accessibility/design.md`), so `Alt+Arrow` (or whichever `moveKey` is configured) never reaches it as plain focus movement. Keyboard moves only apply while the controller's `editingValue` is `true` — see [docs/component/reorderable.md](../component/reorderable.md) for the full editing-mode contract.

## Factory

```js
import { attachReorderable } from '../plumbers';
attachReorderable(controller, options);
```

## Options

| Option        | Type   | Default      | Description                                                                                                                                                                                          |
| ------------- | ------ | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `moveKey`     | String | `'Alt'`      | Modifier key name (`Alt`, `Control`, `Shift`, or `Meta`) combined with the move keys to move an item. Falls back to `'Alt'` for any other value.                                                     |
| `onMoved`     | String | `null`       | Controller method called with the moved item after a keyboard move (not called after a drag)                                                                                                         |
| `orientation` | String | `'vertical'` | `'vertical'`: `ArrowUp`/`ArrowDown` move keys, drag compares `clientY`. `'horizontal'`: `ArrowLeft`/`ArrowRight` move keys (flipped under `dir="rtl"` on the focused item), drag compares `clientX`. |

## Methods

| Method                               | Purpose                                                                                                                                                |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `attachItem(item)`                   | Adds the `keydown` listener for `Alt+Arrow` move handling to `item`                                                                                    |
| `detachItem(item)`                   | Removes it                                                                                                                                             |
| `attachItems(items)`                 | Calls `attachItem` for each item in `items`                                                                                                            |
| `detachItems(items)`                 | Calls `detachItem` for each item in `items`                                                                                                            |
| `startDrag(item, handle, pointerId)` | Begins tracking `item` as the drag target and captures the pointer on `handle`                                                                         |
| `drag(event)`                        | Swaps the dragging item past its immediate previous/next sibling once the pointer event's `clientX`/`clientY` (per `orientation`) crosses its midpoint |
| `endDrag(handle, pointerId)`         | Releases the pointer, dispatches `reordered`, and returns the moved item (or `null` if no drag was in progress)                                        |
| `orderedIds()`                       | Returns `controller.itemTargets` ids (DOM order), omitting items without an `id`                                                                       |

Reads the current item list from `controller.itemTargets` on every call (a live Stimulus target getter) — never caches it, so it stays correct across DOM mutations from either drag or keyboard moves.

## Dispatches & callbacks

| Moment                | Dispatch             | Callback                                                                                       |
| --------------------- | -------------------- | ---------------------------------------------------------------------------------------------- |
| After a keyboard move | `{prefix}:reordered` | `onMoved(item)`, then `announce()`                                                             |
| After a drag ends     | `{prefix}:reordered` | — no callback, no announcement (see [ARIA.md's Reorderable pattern](../../../ARIA.md) for why) |

## Controller callback

```js
connect() {
  this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
  this.reorderable.attachItems(this.itemTargets);
}

moved(item) {
  this.rovingTabIndex?.updateItems(this.itemTargets);
  this.rovingTabIndex.setCurrentIndex(this.itemTargets.indexOf(item));
}
```

## Design notes

- **Keyboard and pointer attachment use different mechanisms on purpose.** `attachItem`/`detachItem` self-attach a raw `keydown` listener per item — the plumber owns this because items connect/disconnect over time and `keydown` needs no markup wiring. Pointer handling (`onPointerDown`/`onPointerMove`/`onPointerUp`) is instead wired via `data-action` in the consumer's HTML, so the controller owns it. This is an accepted asymmetry, not an oversight: pointer targets have no `handleTargetConnected`-style lifecycle hook today, so self-attaching pointer listeners the same way would require adding one, with no current driver for it. A consumer that copies item markup but omits the handle's `data-action` gets working keyboard-move and silently broken drag — if this becomes a real support burden, revisit unifying the two.
- **`Reorderable` reads `controller.itemTargets`/`controller.editingValue` directly, unlike every other plumber**, which only _writes_ to the controller or takes concrete elements/config via constructor options (`Flipper` takes `anchor`/`element`, `Shifter` takes `element`, `Dismisser` takes `trigger`/`element`). This is deliberate: both values must be read live — items connect/disconnect after construction, and editing toggles at runtime — which the snapshot-at-construction options pattern the other plumbers use doesn't support. The tradeoff is that `Reorderable` cannot be reused by a controller that names its `item` target or `editing` value differently; that's accepted for now since there is exactly one consumer (`reorderable_controller.js`).
