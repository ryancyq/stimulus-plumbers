# Reorderable

Reorders a vertical or horizontal list of items via pointer drag (a dedicated handle) or keyboard (`Alt+Arrow`, axis depends on `orientation`). No third-party drag library — built on the native Pointer Events API, backed by the [`Reorderable` plumber](../plumber/reorderable.md). Plain Arrow/Home/End keys move focus only, via [`RovingTabIndex`](../utility/accessibility.md).

## Stimulus Identifier

`reorderable`

## Targets

| Name      | Element                                     | Purpose                                                                                                                                                                                             |
| --------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `item`    | Each reorderable row (`<li>`, `<tr>`, etc.) | Must have a stable `id` to appear in the `reorderable:reordered` event's `itemIds`. The markup renders the roving Tab stop: `tabindex="0"` on the first item, `-1` on the rest                      |
| `handle`  | Drag grip within each `item`                | The only pointer-drag surface — wire `pointerdown`/`pointermove`/`pointerup` to it                                                                                                                  |
| `trigger` | The `<a>`/`<button>` inside an item, if any | Neutralized (via `aria-disabled`/`tabindex`) while `editingValue` is `true`, including triggers added later. The markup renders the same state: `aria-disabled`, plus `tabindex="-1"` while editing |

## Values

| Name          | Type    | Default      | Purpose                                                                                                                                                                                                                                                      |
| ------------- | ------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `moveKey`     | String  | `"Alt"`      | Modifier key that, combined with the move keys below on a focused item, moves it. One of `Alt`, `Control`, `Shift`, `Meta`.                                                                                                                                  |
| `editing`     | Boolean | `false`      | While `true`, pointer drag and `Alt+Arrow` move are active and every `trigger` target is neutralized. While `false`, drag/keyboard-move are inert no-ops and every `trigger` behaves normally. Plain Arrow/Home/End focus movement is unaffected either way. |
| `orientation` | String  | `"vertical"` | Reorder axis: `"vertical"` or `"horizontal"`. Also passed through to [`RovingTabIndex`](../utility/accessibility.md).                                                                                                                                        |

## Actions

| Name            | Purpose                                                                                                    |
| --------------- | ---------------------------------------------------------------------------------------------------------- |
| `onPointerdown` | Wire to `pointerdown` on the `handle` target — starts a drag (no-op unless `editingValue`)                 |
| `onPointermove` | Wire to `pointermove` on the `handle` target — live-reorders while dragging (no-op unless `editingValue`)  |
| `onPointerup`   | Wire to `pointerup` on the `handle` target — ends the drag (no-op unless `editingValue`)                   |
| `toggleEditing` | Flips `editingValue` — wire to e.g. `click->reorderable#toggleEditing` on an app-provided Edit/Done button |
| `enterEditing`  | Sets `editingValue` to `true` explicitly                                                                   |
| `exitEditing`   | Sets `editingValue` to `false` explicitly                                                                  |

## Keyboard

| Key                                                                                  | Behaviour                                                              |
| ------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| `ArrowDown`/`ArrowUp` (vertical) or `ArrowLeft`/`ArrowRight` (horizontal)            | Focus next/previous item (wraps) — unchanged `RovingTabIndex` behavior |
| `Home` / `End`                                                                       | Focus first/last item                                                  |
| `Alt+ArrowDown` (vertical) / `Alt+ArrowRight` (horizontal, `Left` under `dir="rtl"`) | Move the focused item forward one position, keeps focus on it          |
| `Alt+ArrowUp` (vertical) / `Alt+ArrowLeft` (horizontal, `Right` under `dir="rtl"`)   | Move the focused item back one position, keeps focus on it             |

## Dispatches

| Event                   | Detail                  | When                                                                                              |
| ----------------------- | ----------------------- | ------------------------------------------------------------------------------------------------- |
| `reorderable:reordered` | `{ itemIds: string[] }` | After a drag ends or a keyboard move completes. Items without an `id` are omitted from `itemIds`. |

An interrupted drag (`pointercancel`, lost pointer capture, or leaving editing mode) restores the starting order and dispatches nothing. Touch drags need `touch-action: none` on the handle while editing, or the browser cancels them to scroll.

## Example HTML

```html
<ul data-controller="reorderable">
  <li id="row-1" data-reorderable-target="item" tabindex="0">
    <span
      data-reorderable-target="handle"
      data-action="pointerdown->reorderable#onPointerdown pointermove->reorderable#onPointermove pointerup->reorderable#onPointerup"
    >
      ::
    </span>
    First item
  </li>
  <li id="row-2" data-reorderable-target="item" tabindex="-1">
    <span
      data-reorderable-target="handle"
      data-action="pointerdown->reorderable#onPointerdown pointermove->reorderable#onPointermove pointerup->reorderable#onPointerup"
    >
      ::
    </span>
    Second item
  </li>
</ul>
```

## Notes

- Persistence is not built in — listen for `reorderable:reordered` and send `event.detail.itemIds` to your backend.
- Single-list only. Grid orientation and cross-list drag are not supported.
- The dragged/moved item is repositioned live in the DOM — there is no placeholder or ghost element.
- See [ARIA.md's Reorderable pattern](../../../ARIA.md) for the drag/keyboard-move focus-and-announcement contract and the `trigger` neutralization rules.
- Pointer clicks on a `trigger` are not blocked by JS. Apps/themes must add their own CSS rule to block them while editing, e.g. `[data-reorderable-editing-value="true"] [data-reorderable-target="trigger"] { pointer-events: none }` — keeps the controller content-agnostic about link/button internals.
