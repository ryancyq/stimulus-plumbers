# Accessibility Helper Design

Three JS modules under `src/accessibility/` provide the accessibility primitives for all controllers. This doc explains **which helper to use for which ARIA interaction pattern** and the **usage contract** every controller must follow.

## Three Patterns

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

### 2. Managed Focus / Listbox — `ListboxNavigation` (`keyboard.js`)

Use when: focus stays on an external element (e.g. a combobox input) while arrow keys move a selection cursor (`aria-selected`) through a listbox of options.

- Focus **never enters** the listbox.
- `aria-selected="true"` marks the highlighted option; the listbox item itself is never focused.
- `ListboxNavigation` is **passive** — it attaches no listeners automatically. Wire it through a Stimulus action.

```js
// connect()
this.listboxNav = new ListboxNavigation(this.listboxTarget);

// in the Stimulus action wired to the input's keydown:
onNavigate(event) {
  this.listboxNav?.handleKeyDown(event);
}
```

`handleKeyDown` handles Up/Down, Home, End, Enter, Space. It calls `event.preventDefault()` only for keys it handles. `step(1)` / `step(-1)` move selection forward/backward directly.

Getters: `selectedItem` returns the currently `aria-selected` element; `currentIndex` returns its index (or `-1`).

### 3. Focus Trap — `FocusTrap` (`focus.js`)

Use when: focus must stay within a bounded region until explicitly dismissed (modal dialogs, drawer panels).

- Tab/Shift+Tab cycles within the container.
- `escapeDeactivates: true` enables Escape key to close.
- `onDeactivate` callback fires whenever the trap deactivates — use it to hide the panel.

```js
this.focusTrap = new FocusTrap(container, {
  escapeDeactivates: true,
  onDeactivate: () => this.close(),
});

// open
this.focusTrap.activate();

// close
this.focusTrap.deactivate(); // also called automatically on Escape
```

Optional options: `initialFocus` (element to focus on activate; default: first focusable), `returnFocus` (element to restore on deactivate; default: `activeElement` at activate time).

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

### Always use `setHidden` — never `removeAttribute`/`setAttribute('hidden', ...)`

```js
// correct
import { setHidden } from '../accessibility/aria';
setHidden(panel, false); // show
setHidden(panel, true); // hide

// wrong
panel.removeAttribute('hidden');
panel.setAttribute('hidden', '');
```

### Call `announce()` on meaningful state changes

Any state change a screen reader should know about without a focus move must call `announce()` — WCAG 4.1.3 (Status Messages). Examples: section expanded/collapsed, panel opened/closed.

```js
import { announce } from '../accessibility/aria';
announce('Event title expanded');
announce('Panel closed');
```

### `connectTriggerToTarget(trigger, target)`

Wires `trigger.setAttribute('aria-controls', target.id)` and sets `aria-expanded` if not already present. Use once at connect time for disclosure widgets.

### `getFocusableElements(container)`

Returns an array of focusable descendants in DOM order. Used internally by `FocusTrap`. Call directly when you need to enumerate tabbable elements outside a trap context.

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

Wires ARIA relationships between a trigger and target element: sets `role` on target, `aria-controls` on trigger (requires target `id`), `aria-describedby` when `role === 'tooltip'`, and `aria-haspopup` based on role. Skips attributes already present unless `override: true`.

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
- **`RovingTabIndex` ignores all modifier keys by default, not just `Alt`** — the guard must be correct for any `moveKey` a co-located plumber might use (`Reorderable`'s `moveKey` is configurable to `Control`/`Shift`/`Meta`), and for any future `RovingTabIndex` consumer, without that consumer needing to know about a specific plumber. `ignoreModifierKeys` is a list, not a boolean, precisely so a future consumer that wants a modified combination (e.g. `Shift+Arrow` range-select) to still move focus can narrow it.
- **Prefer a reserved-key guard over attach order for two listeners sharing one item** — if a future plumber needs to attach its own raw `keydown` listener to items also managed by `RovingTabIndex`, extend `ignoreModifierKeys` (or add an equivalent reserved-key convention) rather than relying on which `addEventListener` call runs first plus `stopImmediatePropagation()`. The latter is an implicit ordering that silently breaks if reordered; the former partitions the keyspace structurally.
- **`ListboxNavigation` is passive** — combobox inputs already have their own `keydown` Stimulus actions; `ListboxNavigation` is a delegate, not an event owner. Auto-attach would conflict with the controller's action descriptor system.
- **`FocusRestoration` was removed** — it was a thin wrapper around `save()/restore()` with no behaviour beyond `FocusTrap`'s built-in `returnFocus` option. `FocusTrap` handles the common case; callers that need manual save/restore can use `document.activeElement` directly.

## Reference

- API reference: [docs/utility/accessibility.md](../utility/accessibility.md)
- WCAG criteria and component ARIA patterns: [ARIA.md](../../ARIA.md)
