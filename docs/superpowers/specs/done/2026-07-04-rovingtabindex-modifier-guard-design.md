# `RovingTabIndex` modifier guard — decoupling from `Reorderable`'s attach order

## Scope

JS accessibility utility + one plumber + one controller, in `stimulus-plumbers/src/accessibility/keyboard.js`, `stimulus-plumbers/src/plumbers/reorderable.js`, and `stimulus-plumbers/src/controllers/reorderable_controller.js`. Supersedes the attach-order coupling described in `docs/superpowers/specs/2026-07-03-reorderable-controller-design.md` (Approach bullet on keyboard reorder, and the Keyboard mechanics/Actions sections referencing listener-attach ordering). No change to drag mechanics, output events, or targets/values from that spec.

## Problem

`reorderable_controller.js` and `plumbers/reorderable.js` currently attach `keydown` independently of `RovingTabIndex`'s own `keydown` listener, on the same `item` elements. Both are plain `addEventListener` calls, so which one runs first for a given event is whichever attached first — an implicit ordering the controller's `connect()` currently enforces by attaching the plumber's listener before calling `RovingTabIndex.activate()`, with an inline comment warning not to reverse the two lines. The plumber's handler then calls `event.stopImmediatePropagation()` for `Alt+Arrow` so `RovingTabIndex`'s listener never runs for that combination. This is fragile: nothing structurally prevents someone from reordering `connect()`, and the correctness of the whole reorder-vs-focus-move split rests on a comment.

## Approach

Teach `RovingTabIndex` to ignore modified arrow/Home/End keys by default, so it no longer matters which listener attaches first — the two listeners naturally partition the keyspace (unmodified key → focus move, modified key → whatever the other listener does with it) instead of racing.

- **`RovingTabIndex` gains an `ignoreModifierKeys` option**: an array of modifier names drawn from the same vocabulary `Reorderable` already uses (`'Alt' | 'Control' | 'Shift' | 'Meta'`). Default: all four. `_handleKeyDown` early-returns, before any `currentIndex`/`fromIndex` sync, if any modifier in the list is active on the event (`event.altKey`, `event.ctrlKey`, `event.shiftKey`, `event.metaKey`).
- **Default is "ignore any modifier," not "ignore `Alt` only,"** so the guard is correct regardless of what `moveKey` a `Reorderable` instance is configured with, and so it also applies to any other current or future `RovingTabIndex` consumer without that consumer needing to know about `Reorderable` at all. A future consumer that wants a modified-arrow combo (e.g. `Shift+Arrow` range-select) to still move focus can override with a narrower list or `[]` — this is why the option is a list, not a boolean.
- **`MODIFIER_KEYS` moves from `plumbers/reorderable.js` to `accessibility/keyboard.js`**, and `reorderable.js` imports it from there instead of declaring its own copy. This follows the existing dependency direction — `plumbers/reorderable.js` already imports `announce` from `accessibility/aria.js`.
- **`Reorderable#onKeydown` drops `event.stopImmediatePropagation()`.** With the guard in place, `RovingTabIndex` self-excludes modified keys regardless of listener order, so forcibly stopping propagation to defeat it is no longer necessary. `event.preventDefault()` is retained (still needed to stop the browser's native scroll-on-arrow behavior).
- **`reorderable_controller.js#connect()` drops the attach-order comment.** `this.reorderable.attachItem(...)` and `this.rovingTabIndex.activate()` may run in either order.
- **No change to `timeline_controller.js`.** It gets the corrected default behavior automatically (no code change) since `ignoreModifierKeys` defaults on. It has no competing listener today, so this is a behavior change in name only — currently untested and unused, but intentional and documented as the correct universal default, not a special case for `Reorderable`.
- **Scoped fix, not an architectural rewrite.** This does not eliminate the general risk of two independent plumbers attaching raw listeners to the same DOM nodes — it resolves the one instance that exists today. A `design.md` Decision Log entry captures the general guidance for future authors instead of forcing a broader rewrite (e.g. converting `RovingTabIndex` to a passive delegate composed explicitly by the controller) that has no current driver. See "Rejected approach" below.

## Guard placement detail

The guard sits at the very top of `_handleKeyDown`, before the existing `fromIndex`/`currentIndex` sync (current lines 92–97 in `keyboard.js`) — a modified keydown has zero side effects on `RovingTabIndex` state, not just no navigation effect.

## Rejected approach: explicit controller-side composition

Considered converting `RovingTabIndex` to a passive delegate (like `ListboxNavigation`) with the controller explicitly sequencing `reorderable.handleKeydown(event)` then `rovingTabIndex.handleKeydown(event)`, removing independent raw-listener attachment entirely. Rejected for now:

- Breaks `RovingTabIndex`'s documented self-managing `activate()`/`deactivate()` contract (`docs/accessibility/design.md` Decision Log calls this a deliberate design choice), affecting `timeline_controller.js` — the only other consumer, which has no conflict today — for no benefit to it.
- Requires restructuring `Reorderable`'s public API (`attachItem`/`detachItem` repurposed or removed for the keyboard path).
- Introduces new failure modes in the controller's hand-written dispatch sequence (wrong order, double `preventDefault`, a forgotten path) in exchange for closing a risk that isn't concretely occurring.

## Documentation changes

- `docs/accessibility/design.md`: document `ignoreModifierKeys` in the `RovingTabIndex` section (default value, purpose). Add two Decision Log entries: (1) why the default ignores all four modifiers rather than being `Reorderable`-specific, (2) general guidance that a plumber needing to reserve a key combination on `RovingTabIndex`-managed items should extend `ignoreModifierKeys`'s reserved-combination convention rather than relying on attach order + `stopImmediatePropagation()`.
- `docs/plumber/reorderable.md`: remove the attach-order language from the top description and the Controller callback section; note reordering now composes safely with `RovingTabIndex` via the modifier guard, independent of attach order.
- No changelog/migration notice: `reorderable_controller.js` landed in this same feature branch (commit `af486472`, unreleased), so there is no external consumer of the old behavior.

## Testing

- `tests/unit/accessibility/keyboard.test.js`: for each of `Alt`, `Control`, `Shift`, `Meta` individually — construct `RovingTabIndex` with default options, dispatch a modified arrow key, assert no focus/index change. One case asserting a plain (unmodified) arrow still navigates (regression guard for the guard itself). One case constructing with `ignoreModifierKeys: ['Alt']` and asserting `Shift+Arrow` still navigates while `Alt+Arrow` does not, to cover the override path.
- `tests/unit/plumbers/reorderable.test.js` / `tests/unit/controllers/reorderable_controller.test.js`: remove any assertions tied to `stopImmediatePropagation` or attach order; keep existing `Alt+Arrow` move / plain-arrow-focus assertions since observable behavior there is unchanged.

## Out of scope

- Making `ignoreModifierKeys` configurable per-`Reorderable`-instance (e.g. `reorderable_controller.js` passing a custom list) — the default already covers its case; no current need to override.
- Any change to drag mechanics, output events, targets, or values from the original reorderable design.
