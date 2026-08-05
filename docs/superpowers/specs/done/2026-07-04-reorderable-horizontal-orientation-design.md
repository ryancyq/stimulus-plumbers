# Reorderable: Horizontal Orientation Support

## Motivation

`Reorderable` (plumber + `reorderable_controller`) currently only supports vertical-axis
reordering (`docs/component/reorderable.md` Notes: "Vertical-axis, single-list only").
The most common real-world need for the opposite axis is **browser-style tabs** — a row
of open documents / dashboard panels / spreadsheet sheet tabs that a user drags or
keyboard-moves left/right. Tabs also already have a documented APG interaction pattern
(`role="tablist"`/`role="tab"`), making the ARIA story for horizontal reordering cheap to
get right.

This spec adds an `orientation` option (`vertical` | `horizontal`, default `vertical`)
so both axes are supported without duplicating the vertical implementation.

## Scope

In scope:
- `orientation` value on `reorderable_controller` (`vertical` default, `horizontal` opt-in)
- Keyboard move on the opposite arrow-key pair when horizontal, with RTL-aware meaning
- Drag reordering compared along the correct screen axis
- Geometry helper redesign to avoid duplicating the vertical/horizontal center formula
- Doc updates (`docs/component/reorderable.md`, `ARIA.md` if RTL changes announced text)
- Tests for keyboard, drag, and RTL arrow-key flip in horizontal mode

Out of scope (unchanged from current behavior):
- Cross-list drag, grid/2D reordering
- The existing keydown/pointer wiring split (self-attach vs. `data-action`) — tracked
  separately in `docs/superpowers/audits/2026-07-04-reorderable-consistency-audit.md`
  finding #3

## Design

### 1. Controller: `orientation` value

`reorderable_controller.js` gains:
```js
static values = {
  moveKey: { type: String, default: 'Alt' },
  editing: { type: Boolean, default: false },
  orientation: { type: String, default: 'vertical' },
};
```
Passed straight through to both collaborators that already accept it:
```js
this.reorderable = attachReorderable(this, {
  moveKey: this.moveKeyValue,
  orientation: this.orientationValue,
  onMoved: 'moved',
});
this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: this.orientationValue });
```
`RovingTabIndex` already supports `orientation` — no change needed there.

`onPointerMove` stops extracting `event.clientY` and forwards the raw event:
```js
onPointerMove(event) {
  if (!this.editingValue) return;
  this.reorderable.drag(event);
}
```
This keeps the controller orientation-agnostic — only the plumber (which owns
`this.orientation`) needs to know which axis is active.

### 2. Plumber: branch on orientation

`Reorderable` constructor stores `this.orientation` from options (default `'vertical'`).

**Keyboard (`onKeydown`)** — replace the hardcoded `ArrowUp`/`ArrowDown` check with an
orientation-keyed move-key map:
```js
const MOVE_KEYS = {
  vertical: { back: 'ArrowUp', forward: 'ArrowDown' },
  horizontal: { back: 'ArrowLeft', forward: 'ArrowRight' },
};
```
`back`/`forward` are logical (document-order) directions, not physical ones. For
`orientation: 'horizontal'`, `back`/`forward` swap physical Left/Right when the item's
computed `direction` is `rtl` (`getComputedStyle(item).direction`), so `ArrowRight`
always moves an item earlier in a RTL tab strip and `ArrowLeft` moves it later — matching
APG carousel/tablist convention. Vertical orientation is never RTL-affected.

`onKeydown` resolves `back`/`forward` key names once per call via a small
`resolveMoveKeys(item)` helper, then the existing target-index math (`index - 1` for
"back", `index + 1` for "forward") is unchanged — only the key-name lookup changes,
not the reordering logic itself.

**Drag (`drag(event)`)** — takes the pointer event instead of a bare `clientY`:
```js
drag(event) {
  if (!this.draggingItem) return;
  const coord = this.orientation === 'horizontal' ? event.clientX : event.clientY;
  const items = this.items;
  const draggingIndex = items.indexOf(this.draggingItem);
  const previous = items[draggingIndex - 1];
  if (previous && coord < this.midpointOf(previous)) {
    previous.before(this.draggingItem);
    return;
  }
  const next = items[draggingIndex + 1];
  if (next && coord > this.midpointOf(next)) {
    next.after(this.draggingItem);
  }
}
```
Drag axis is physical (mouse/touch movement), not logical — RTL does not affect drag,
only keyboard arrow-key meaning per APG convention (drag direction is visually self-evident
to the user regardless of text direction).

`midpointOf(item)` becomes:
```js
midpointOf(item) {
  return centerOf(item.getBoundingClientRect(), this.orientation);
}
```

### 3. Geometry: replace `verticalCenter` with `centerOf(rect, orientation)`

`verticalCenter(rect)` has exactly one consumer (`reorderable.js`), so there is no
back-compat reason to keep it as a separate export alongside a new `horizontalCenter`
twin (that would just duplicate the same `position + size / 2` formula twice). Instead,
`geometry.js` replaces it with one orientation-aware function:
```js
export function centerOf(rect, orientation = 'vertical') {
  return orientation === 'horizontal' ? rect.left + rect.width / 2 : rect.top + rect.height / 2;
}
```
This is the only axis-branching helper added to `geometry.js`. The pointer-coordinate
branch in `drag()` (`event.clientX` vs `event.clientY`) is a different concern (event
coordinates, not rect geometry) and is used in exactly one place, so it stays as an
inline ternary in `reorderable.js` rather than becoming a second shared abstraction.

### 4. Docs

- `docs/component/reorderable.md`:
  - Add `orientation` row to Values table (`String`, default `"vertical"`, one of
    `vertical`/`horizontal`)
  - Keyboard table: note that `Alt+ArrowLeft`/`Alt+ArrowRight` are the move keys when
    `orientation="horizontal"` (RTL-aware), replacing `Alt+ArrowUp`/`Alt+ArrowDown`
  - Notes: remove "Vertical-axis, single-list only" (single-list restriction still
    applies; only the axis restriction is lifted)
- `ARIA.md`: no new pattern needed — this reuses the existing Reorderable pattern entry
  with the axis parametrized; add a one-line note only if RTL flip changes the
  announcement text (it doesn't — `announce()` still reports position, not direction)

### 5. Tests

- `reorderable_controller.test.js` / `reorderable.test.js`:
  - `Alt+ArrowRight`/`Alt+ArrowLeft` move the focused item in horizontal mode;
    `Alt+ArrowUp`/`Alt+ArrowDown` are inert in horizontal mode (and vice versa for
    vertical, unchanged)
  - Horizontal drag reorders via x-midpoint comparison (mirrors existing vertical
    drag tests, driven by `clientX` instead of `clientY`)
  - RTL: item with `dir="rtl"` in horizontal mode — `ArrowRight` moves the item
    earlier (toward document start), `ArrowLeft` moves it later
- `geometry.test.js`: replace `verticalCenter` describe block with `centerOf`,
  covering both `orientation` values (default vertical behavior unchanged, explicit
  `'horizontal'` uses `rect.left + rect.width / 2`)

## Risks / open items

- `getComputedStyle` per keydown is a minor perf cost vs. the current zero-cost
  hardcoded key check, but keydown is a low-frequency event (guarded by
  `event.repeat` already) so this is negligible.
- No visual/CSS changes are in scope — apps opting into `orientation="horizontal"`
  are responsible for laying out `item` targets in a row (e.g. `display: flex`); the
  controller only changes interaction logic, matching its existing "content-agnostic"
  design principle.
