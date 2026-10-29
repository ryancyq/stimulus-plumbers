import { vi } from 'vitest';

// jsdom lacks the popover API.
export const toggleEvent = (type, newState, source = null, oldState = newState === 'open' ? 'closed' : 'open') => {
  const event = new Event(type, { cancelable: type === 'beforetoggle' });
  Object.defineProperty(event, 'oldState', { value: oldState });
  Object.defineProperty(event, 'newState', { value: newState });
  Object.defineProperty(event, 'source', { value: source });
  return event;
};

// toggle is queued, as in browsers. jsdom hides [popover] until :popover-open, which it never
// matches, so an open panel is shown inline.
export const installNativePopover = (panel) => {
  let open = false;
  panel.matches = vi.fn((selector) => selector === ':popover-open' && open);
  panel.showPopover = vi.fn((options) => {
    const source = options?.source ?? null;
    if (open || !panel.dispatchEvent(toggleEvent('beforetoggle', 'open', source))) return;
    open = true;
    panel.style.display = 'block';
    queueMicrotask(() => panel.dispatchEvent(toggleEvent('toggle', 'open', source)));
  });
  panel.hidePopover = vi.fn(() => {
    if (!open) return;
    panel.dispatchEvent(toggleEvent('beforetoggle', 'closed'));
    open = false;
    panel.style.removeProperty('display');
    queueMicrotask(() => panel.dispatchEvent(toggleEvent('toggle', 'closed')));
  });
  panel.togglePopover = vi.fn((options) => (open ? panel.hidePopover() : panel.showPopover(options)));
};
