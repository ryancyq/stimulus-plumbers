# Accessibility Helper Design

Three JS modules under `src/accessibility/` provide the accessibility primitives for all controllers. This doc explains **which helper to use for which ARIA interaction pattern** and the **usage contract** every controller must follow.

## Two Patterns

`calendar_controller` handles its own grid keys, which move focus by date and may load another period.

### 1. Roving Tabindex — `RovingTabIndex` (`keyboard.js`)

Use when: a group of sibling elements each take focus in turn (toolbar, tab list, disclosure trigger group).

- Only one item in the group has `tabIndex=0` at a time; all others have `tabIndex=-1`.
- Arrow keys move focus between items.
- The currently focused item is the "active" member of the group.

```js
// connect()
this.rovingTabIndex = new RovingTabIndex(this.triggerTargets, { orientation: 'vertical' });
this.rovingTabIndex.activate();

// disconnect()
this.rovingTabIndex?.deactivate();

// when the item set changes (targetConnected / targetDisconnected)
this.rovingTabIndex?.updateItems(this.triggerTargets);
```

**Options:**

- `orientation` (`'vertical'` | `'horizontal'` | `'both'`) — which arrow keys move focus; default `'both'`
- `wrap` (boolean) — whether navigation wraps at boundaries; default `true`
- `initialIndex` (number) — which item starts focused; default `0`
- `ignoreModifierKeys` (array of `'Alt' | 'Control' | 'Shift' | 'Meta'`) — modifier keys that suppress arrow/Home/End handling entirely when held; default: all four. A modified key is ignored before any internal state changes (no `currentIndex` sync either). Narrow this list (or pass `[]`) if a specific modifier combination should still move focus.

`orientation: 'vertical'` restricts to Up/Down/Home/End. Use `'horizontal'` for Left/Right, `'both'` for all four arrows (default).

`activate()` attaches `keydown` and `click` listeners to every item and sets initial `tabIndex` values. `deactivate()` removes all listeners. `updateItems(newEls)` swaps the item set and re-attaches; it clamps `currentIndex` so it stays in bounds. `setCurrentIndex(n)` moves focus programmatically.

### 2. Active Descendant — `ActiveDescendant` (`keyboard.js`)

Use when: DOM focus stays on one owner element while the active option of a listbox changes (`combobox`, each `combobox-time` column).

- The active option is `aria-selected="true"`, and the owner's `aria-activedescendant` references it; options get an id when they lack one.
- `activate(option)`, `move(delta)`, `first()`, `last()`, and `clear()` change it; `move` stops at the ends and skips options that `enabled` rejects, and from a rejected active option goes to the nearest enabled option on the delta's side, or on the other side when that side has none.
- `active` returns the active option, or `null` once it is removed or no longer enabled.
- The owner is an element, or a function returning the current one.
- `ActiveDescendant` is **passive** — it attaches no listeners. The controller maps keys to moves.

```js
this.activeDescendant = new ActiveDescendant(() => this.triggerTarget, {
  options: () => [...this.listboxTarget.querySelectorAll('[role="option"]')],
  enabled: (option) => !isAriaDisabled(option),
});

// in the Stimulus action wired to the owner's keydown:
if (event.key === 'ArrowDown') this.activeDescendant.move(1);
```

## Usage Contract

Every controller in this library must follow these rules. They exist to ensure consistency for screen reader users across all components.

### Always use `setExpanded` — never `setAttribute`

```js
// correct
import { setExpanded } from '../accessibility/aria';
setExpanded(trigger, true);

// wrong
trigger.setAttribute('aria-expanded', 'true');
```

### Always use `setHidden` — never the `.hidden` property or `removeAttribute`/`setAttribute('hidden', ...)`

```js
// correct
import { setHidden } from '../accessibility/aria';
setHidden(panel, false); // show
setHidden(panel, true); // hide

// wrong
panel.hidden = true;
panel.removeAttribute('hidden');
panel.setAttribute('hidden', '');
```

### Call `announce()` only for status messages

Call `announce()` for a status a screen reader would otherwise miss without a focus move — WCAG 4.1.3 (Status Messages), e.g. an item moved to a new position. Changes an ARIA state already reports are not announced; see [ARIA.md](../../../ARIA.md).

```js
import { announce } from '../accessibility/aria';
announce('Moved to position 2 of 5');
```

### `connectTriggerToTarget({ trigger, target, role, override })`

Use once at connect time to wire a trigger to its popup or tooltip. It never sets `aria-expanded`; the owning controller manages that state. Attribute details are in the Full API Reference below.

### `getFocusableElements(container)`

Returns an array of focusable descendants in DOM order. Call it when you need to enumerate tabbable elements, e.g. to move focus into a replaced region.

## Full API Reference

### `src/accessibility/aria.js`

#### `announce(message, options?)`

| Option       | Type    | Default            | Description                 |
| ------------ | ------- | ------------------ | --------------------------- |
| `politeness` | String  | `'polite'`         | `'polite'` or `'assertive'` |
| `atomic`     | Boolean | `true`             | Value for `aria-atomic`     |
| `relevant`   | String  | `'additions text'` | Value for `aria-relevant`   |

#### `generateId(prefix?)` / `ensureId(element, prefix?)`

`generateId` returns a unique ID string. `ensureId` assigns one to `element` if it lacks one; returns the id.

#### `setExpanded(element, expanded)` / `setPressed` / `setChecked`

Convenience setters for `aria-expanded`, `aria-pressed`, `aria-checked`. Always use these — never call `setAttribute` directly.

#### `setHidden(element, hidden)`

Sets (`hidden: true`) or removes (`hidden: false`) the `hidden` attribute. Always use this — never call `removeAttribute('hidden')` or `setAttribute('hidden', ...)` directly.

#### `setDisabled(element, disabled)`

Sets `aria-disabled`. Adds `tabindex="-1"` when disabled; removes it when enabled.

#### `connectTriggerToTarget({ trigger, target, role?, override? })`

Wires ARIA relationships between a trigger and target element: sets `role` on target, `aria-controls` on trigger (requires target `id`), `aria-describedby` when `role === 'tooltip'`, and `aria-haspopup` only for roles in `ARIA_HASPOPUP_VALUES`. Skips attributes already present unless `override: true`.

#### `disconnectTriggerFromTarget({ trigger, target, attributes? })`

Removes ARIA relationship attributes (`aria-controls`, `aria-haspopup`, `aria-describedby`, `role`).

#### `ARIA_HASPOPUP_VALUES`

Role → `aria-haspopup` value map: `menu`, `listbox`, `tree`, `grid`, `dialog`.

### `src/accessibility/focus.js`

#### `FOCUSABLE_SELECTOR`

CSS selector matching all natively focusable elements.

#### `getFocusableElements(container)` / `focusFirst(container)`

`getFocusableElements` returns visible focusable elements within `container` as an array. `focusFirst` focuses the first one; returns `true` if found.

### `src/accessibility/keyboard.js`

#### `isKey(event, key)` / `isActivationKey(event)` / `isArrowKey(event)` / `preventDefault(event)`

Key predicates. `isActivationKey` matches Enter or Space; `isArrowKey` matches all four arrow keys. `preventDefault` calls both `preventDefault()` and `stopPropagation()`.

## Decision Log

- **`RovingTabIndex` self-manages via `activate()`** — controllers should not manually wire `keydown` handlers for roving tabindex; `activate()` encapsulates the full lifecycle so controllers only call `activate()` / `deactivate()` / `updateItems()`.
- **`ActiveDescendant` is passive** — listbox owners map keys differently (an editable combobox leaves Home, End, and Space to text editing; a time column closes on Enter), so the controller keeps the key mapping.
- **`RovingTabIndex` ignores all modifier keys by default, not just `Alt`** — the guard must be correct for any `moveKey` a co-located plumber might use (`Reorderable`'s `moveKey` is configurable to `Control`/`Shift`/`Meta`), and for any future `RovingTabIndex` consumer, without that consumer needing to know about a specific plumber. `ignoreModifierKeys` is a list, not a boolean, precisely so a future consumer that wants a modified combination (e.g. `Shift+Arrow` range-select) to still move focus can narrow it.
- **Prefer a reserved-key guard over attach order for two listeners sharing one item** — if a future plumber needs to attach its own raw `keydown` listener to items also managed by `RovingTabIndex`, extend `ignoreModifierKeys` (or add an equivalent reserved-key convention) rather than relying on which `addEventListener` call runs first plus `stopImmediatePropagation()`. The latter is an implicit ordering that silently breaks if reordered; the former partitions the keyspace structurally.
- **Containment and focus return** — use native `<dialog>` (`showModal()` makes the rest of the page inert and restores focus on close) or the popover API; for a manual save and restore, keep `document.activeElement`.

## Reference

- API reference: [docs/utility/accessibility.md](../utility/accessibility.md)
- WCAG criteria and component ARIA patterns: [ARIA.md](../../../ARIA.md)
