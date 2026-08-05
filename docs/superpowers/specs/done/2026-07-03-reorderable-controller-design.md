# `reorderable` controller design

## Scope

JS Stimulus controller + plumber, in `stimulus-plumbers/src/controllers/reorderable_controller.js` and `stimulus-plumbers/src/plumbers/reorderable.js`. No Rails helper wiring, no persistence contract — both are follow-up designs. Single-list, vertical-axis reordering.

## Approach

- **Plumber split**: following the `Calendar`/`CalendarDaySelector` precedent (`src/plumbers/calendar.js`, `src/plumbers/calendar-selector.js`) — not the `WindowObserver` subclasses (`Shifter`/`Flipper`/`Dismisser`), which is a narrower special case. Every controller in this repo delegates non-trivial logic to a plumber; `reorderable`'s pointer state machine + keyboard-move + DOM-swap logic is comparable in weight to `Calendar`'s date math, not to `timeline_controller.js`'s few lines of attribute toggling — so it gets the same treatment. `Reorderable` extends the base `Plumber` class (`src/plumbers/plumber/index.js`) and owns: pointer drag state machine, hit-testing, DOM swap, keyboard-move swap, `orderedIds()`, and dispatch (via `Plumber`'s inherited `dispatch()`, auto-prefixed with the controller's identifier — no manual `reorderable:` string needed). The controller shrinks to target/value declarations, thin `data-action` adapters that call into the plumber, and its own `RovingTabIndex` instance.
- **`RovingTabIndex` stays in the controller**, not the plumber: the only other place in this codebase that uses `RovingTabIndex` (`timeline_controller.js`) instantiates it directly rather than through a plumber, and no plumber in this repo currently owns a `RovingTabIndex` instance. Keeping it there also matches the existing split — accessibility utilities (`src/accessibility/*`) are controller-level concerns, plumbers (`src/plumbers/*`) are behavior/state engines.
- Drag mechanics: Pointer Events API (`pointerdown`/`pointermove`/`pointerup` + `setPointerCapture`) — no third-party library, works across mouse/touch/pen with one code path.
- Visual feedback: live DOM reorder — the dragged item is actually moved in the DOM as the pointer crosses a neighbor's midpoint. No placeholder clone or drop-indicator element.
- Keyboard reorder: the plumber intercepts `Alt+ArrowUp`/`Alt+ArrowDown` (attached directly via `addEventListener`, same pattern as `CalendarDaySelector#attach`) to move the focused item; the controller's separate `RovingTabIndex` instance still owns plain Arrow/Home/End (focus movement, unchanged). The plumber's listener must attach before `RovingTabIndex.activate()` runs (both are plain `addEventListener` calls on the same `item` elements, not Stimulus actions, so ordering is whichever attaches first) — the plumber's handler calls `stopImmediatePropagation()` only when the modifier matches, otherwise falls through untouched to `RovingTabIndex`.
- Status announcements: the plumber calls `announce()` (`stimulus-plumbers/src/accessibility/aria.js`) directly after a keyboard move — no new live-region mechanism. **Not called after a pointer drag** — forcing keyboard focus/announcement onto a mouse-drag target would be an unexpected focus steal for mouse users, and WCAG 2.1.1's keyboard-equivalent requirement is already satisfied by the separate keyboard path.
- Hit-testing math: `getBoundingClientRect()` directly in the plumber (`plumber/geometry.js`'s exports are viewport-relative helpers, not element-to-element hit-testing — not reused here).
- Output: dispatches a `reorderable:reordered` CustomEvent only, via the plumber's inherited `dispatch()`. No built-in fetch/persistence — app code (or a later Rails-helper design) listens and persists.
- Post-reorder bookkeeping (refresh `RovingTabIndex`'s item list, refocus after a keyboard move) is relayed from plumber to controller via an `onMoved` callback name option, the same pattern as `Calendar`'s `onNavigated` / `Dismisser`'s `onDismissed`.

## Targets

| Target   | Description                                                    |
| -------- | ---------------------------------------------------------------- |
| `item`   | Each reorderable row (multiple)                                  |
| `handle` | Drag grip within each `item` — the only pointer-drag surface     |

## Values

| Value     | Type   | Default | Description                                                                                   |
| --------- | ------ | ------- | ----------------------------------------------------------------------------------------------- |
| `moveKey` | String | `"Alt"` | Modifier key that, combined with ArrowUp/ArrowDown on a focused item, moves it (not just focus) |

No `orientation`, `animation`, or persistence-related values in v1.

## Actions

`data-action` wiring on the `handle` target for pointer events; the controller's methods are thin adapters delegating to the plumber:

```html
<span data-reorderable-target="handle"
      data-action="pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp">
</span>
```

Keyboard (`Alt+Arrow`) is **not** wired via `data-action` — the plumber attaches its own `keydown` listener directly to each `item` (see Approach), for deterministic ordering against `RovingTabIndex`'s own listener on the same element.

## Drag mechanics (pointer)

1. `pointerdown` on `handle` → controller's `onPointerDown` calls `reorderable.startDrag(item, handle, pointerId)` → plumber captures the pointer, tracks the dragging item
2. `pointermove` → controller's `onPointerMove` calls `reorderable.drag(clientY)` → plumber computes the midpoint of the dragging item's immediate previous/next sibling and swaps DOM position live when crossed
3. `pointerup` → controller's `onPointerUp` calls `reorderable.endDrag(handle, pointerId)` → plumber releases the pointer, dispatches `reorderable:reordered`; controller then refreshes `RovingTabIndex`'s item list (no refocus, no announcement — see Approach)

## Keyboard mechanics

- `Alt+ArrowUp` / `Alt+ArrowDown` on a focused `item`: the plumber's own `keydown` listener swaps it with the previous/next `item`, dispatches `reorderable:reordered`, calls `announce("Moved to position N of M")`, then invokes the `onMoved` callback so the controller refreshes `RovingTabIndex` and refocuses the moved item. `Alt` avoids colliding with OS/browser text-navigation and tab-switching shortcuts bound to `Ctrl`/`Cmd` on some platforms.
- Plain arrows/Home/End: delegated to `RovingTabIndex` (focus-only, unchanged)

## Output event

`reorderable:reordered` — `detail: { itemIds: [...] }`, where `itemIds` is each `item`'s DOM `id` attribute in new order. Items without an `id` are excluded from `itemIds`. Dispatched from the plumber (`Plumber#dispatch`), not the controller.

## Testing

- Vitest unit (plumber, `tests/unit/plumbers/reorderable.test.js`): constructs `Reorderable` with a mock controller (same style as `tests/unit/plumbers/dismisser.test.js`) — asserts drag swap math, keyboard swap math, `orderedIds()`, `dispatch` calls, `announce()` calls
- Vitest unit (controller, `tests/unit/controllers/reorderable_controller.test.js`): full Stimulus `Application` integration — asserts `RovingTabIndex` plain-arrow focus movement is unaffected, `Alt+Arrow`/pointer sequences reorder the DOM end-to-end, refocus happens after keyboard move but not after drag
- Playwright: deferred — see "Out of scope" below

## Out of scope (v1)

- Horizontal/grid orientation
- Cross-list drag
- Persistence / AJAX (event-only)
- Placeholder/ghost drop indicator
