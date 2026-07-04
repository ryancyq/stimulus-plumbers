# Accessibility Utilities

Keyboard navigation, focus management, and ARIA helpers for Stimulus controllers.

For full API, design decisions, and usage contracts see [`docs/accessibility/design.md`](../accessibility/design.md).

## Helpers

- **`RovingTabIndex`** — self-managing roving tabindex for disclosure widgets, trees, toolbars
- **`ListboxNavigation`** — passive managed-focus navigator for combobox listboxes
- **`FocusTrap`** — focus trap with optional `onDeactivate` callback
- **`getFocusableElements(container)`** — returns focusable descendants in DOM order
- **`setExpanded(el, value)`** — sets/clears `aria-expanded`
- **`setHidden(el, value)`** — sets/clears `hidden`
- **`announce(message, options?)`** — screen reader live region announcement (`options.politeness`, `options.atomic`, `options.relevant`)
- **`connectTriggerToTarget({ trigger, target, role?, override? })`** — wires `aria-controls` and `role`/other ARIA relationships
