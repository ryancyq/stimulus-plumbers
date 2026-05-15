# Accessibility Utilities

Three focused modules for ARIA state, focus management, and keyboard interaction.

## Import

```js
import { announce, generateId, connectTriggerToTarget } from '@stimulus-plumbers/controllers';
import { FocusTrap, focusFirst } from '@stimulus-plumbers/controllers';
import { isActivationKey, RovingTabIndex } from '@stimulus-plumbers/controllers';
```

---

## `src/accessibility/aria.js`

### `announce(message, options?)`

Announces a message via an `aria-live` region in `document.body`.

| Option       | Type    | Default            | Description                 |
| ------------ | ------- | ------------------ | --------------------------- |
| `politeness` | String  | `'polite'`         | `'polite'` or `'assertive'` |
| `atomic`     | Boolean | `true`             | Value for `aria-atomic`     |
| `relevant`   | String  | `'additions text'` | Value for `aria-relevant`   |

### `generateId(prefix?)`

Returns a unique ID string. Default prefix: `'a11y'`.

### `ensureId(element, prefix?)`

Assigns a generated `id` to `element` if it doesn't have one. Returns the id.

### `setExpanded(element, expanded)` / `setPressed` / `setChecked`

Convenience setters for `aria-expanded`, `aria-pressed`, `aria-checked`.

### `setDisabled(element, disabled)`

Sets `aria-disabled`. Adds `tabindex="-1"` when disabled, removes it when enabled.

### `connectTriggerToTarget({ trigger, target, role?, override? })`

Wires ARIA relationships between a trigger and target element:

- Sets `role` on target
- Sets `aria-controls` on trigger (requires target `id`)
- Sets `aria-describedby` on trigger when `role === 'tooltip'`
- Sets `aria-haspopup` on trigger based on role

Skips attributes already present unless `override: true`. Returns `{ trigger: {}, target: {} }` with the applied attributes.

### `disconnectTriggerFromTarget({ trigger, target, attributes? })`

Removes ARIA relationship attributes (`aria-controls`, `aria-haspopup`, `aria-describedby`, `role`). Pass `attributes` to limit scope.

### `ARIA_HASPOPUP_VALUES`

Role → `aria-haspopup` value map: `menu`, `listbox`, `tree`, `grid`, `dialog`.

---

## `src/accessibility/focus.js`

### `FOCUSABLE_SELECTOR`

CSS selector matching all natively focusable elements.

### `getFocusableElements(container)`

Returns visible focusable elements within `container` as an array.

### `focusFirst(container)`

Focuses the first focusable element. Returns `true` if one was found.

### `class FocusTrap`

Traps Tab/Shift+Tab within a container.

```js
const trap = new FocusTrap(dialogEl, {
  initialFocus: firstInputEl, // default: first focusable element
  returnFocus: triggerEl, // default: activeElement at activate time
  escapeDeactivates: true,
});

trap.activate();
trap.deactivate();
```

### `class FocusRestoration`

Saves and restores `document.activeElement`.

```js
const restoration = new FocusRestoration();
restoration.save();
restoration.restore();
```

---

## `src/accessibility/keyboard.js`

### `isKey(event, key)` / `isActivationKey(event)` / `isArrowKey(event)`

Key predicates. `isActivationKey` matches Enter or Space; `isArrowKey` matches all four arrow keys.

### `preventDefault(event)`

Calls `event.preventDefault()` and `event.stopPropagation()`.

### `class RovingTabIndex`

[Roving tabindex](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/#kbd_roving_tabindex) for a list of items.

```js
const rover = new RovingTabIndex(itemEls, 0);

rover.handleKeyDown(event); // ArrowUp/Down/Left/Right, Home, End
rover.updateItems(newItemEls);
rover.setCurrentIndex(2);
```
