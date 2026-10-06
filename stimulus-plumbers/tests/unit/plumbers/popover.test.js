import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Popover, attachPopover } from '../../../src/plumbers/popover';

describe('Popover', () => {
  let controller;
  let panel;
  let source;
  let openState;

  const nativeEvent = (type, newState, eventSource, oldState = newState === 'open' ? 'closed' : 'open') => {
    const event = new Event(type, { bubbles: false, cancelable: type === 'beforetoggle' });
    Object.defineProperty(event, 'oldState', { value: oldState });
    Object.defineProperty(event, 'newState', { value: newState });
    Object.defineProperty(event, 'source', { value: eventSource });
    return event;
  };

  const settle = (nextState, eventSource = null) => {
    openState = nextState;
    panel.dispatchEvent(nativeEvent('toggle', nextState ? 'open' : 'closed', eventSource));
  };

  beforeEach(() => {
    panel = document.createElement('div');
    panel.setAttribute('popover', 'auto');
    openState = false;
    panel.matches = vi.fn((selector) => selector === ':popover-open' && openState);
    panel.showPopover = vi.fn(() => {
      openState = true;
    });
    panel.hidePopover = vi.fn(() => {
      openState = false;
    });
    panel.togglePopover = vi.fn(() => {
      openState = !openState;
    });
    source = document.createElement('button');

    controller = {
      element: panel,
      dispatch: vi.fn((name, options) => {
        const event = new CustomEvent(options.prefix + ':' + name, {
          bubbles: true,
          cancelable: options.cancelable,
          detail: options.detail,
        });
        options.target.dispatchEvent(event);
        return event;
      }),
    };
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it('exposes only the documented public API', () => {
    expect(Object.getOwnPropertyNames(Popover.prototype)).toEqual([
      'constructor',
      'open',
      'show',
      'hide',
      'toggle',
      'disconnect',
    ]);
  });

  it('attaches through the factory and reflects native popover state', () => {
    const popover = attachPopover(controller, { element: panel });

    expect(popover).toBeInstanceOf(Popover);
    expect(popover.open).toBe(false);
    openState = true;
    expect(popover.open).toBe(true);
    expect(panel.matches).toHaveBeenLastCalledWith(':popover-open');
  });

  it('passes source options only when a source is supplied', () => {
    const popover = new Popover(controller, { element: panel });

    popover.show();
    popover.toggle();
    popover.show(source);
    popover.toggle(source);

    expect(panel.showPopover).toHaveBeenNthCalledWith(1);
    expect(panel.showPopover).toHaveBeenNthCalledWith(2, { source });
    expect(panel.togglePopover).toHaveBeenNthCalledWith(1);
    expect(panel.togglePopover).toHaveBeenNthCalledWith(2, { source });
  });

  it('uses native state to guard redundant show and hide requests', () => {
    const popover = new Popover(controller, { element: panel });

    popover.show();
    openState = true;
    popover.show();
    popover.hide();
    openState = false;
    popover.hide();

    expect(panel.showPopover).toHaveBeenCalledOnce();
    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('dispatches a cancellable before-open event for an opening transition', () => {
    const popover = new Popover(controller, { element: panel });
    const beforeOpen = vi.fn((event) => event.preventDefault());
    panel.addEventListener('popover:before-open', beforeOpen);
    const event = nativeEvent('beforetoggle', 'open', source);

    panel.dispatchEvent(event);

    expect(beforeOpen).toHaveBeenCalledOnce();
    expect(event.defaultPrevented).toBe(true);
    expect(controller.dispatch).toHaveBeenCalledWith('before-open', {
      target: panel,
      prefix: 'popover',
      detail: { source },
      cancelable: true,
    });
    expect(popover.open).toBe(false);
  });

  it('observes external native transitions and emits settled events once per state', () => {
    const popover = new Popover(controller, { element: panel });
    const opened = vi.fn();
    const closed = vi.fn();
    panel.addEventListener('popover:opened', opened);
    panel.addEventListener('popover:closed', closed);

    panel.dispatchEvent(nativeEvent('beforetoggle', 'open', source));
    settle(true, source);
    settle(true, source);
    settle(false);

    expect(opened).toHaveBeenCalledOnce();
    expect(closed).toHaveBeenCalledOnce();
    expect(opened.mock.calls[0][0].detail).toEqual({ source });
    expect(closed.mock.calls[0][0].detail).toEqual({ source: null });
    expect(controller.dispatch).toHaveBeenCalledWith('opened', {
      target: panel,
      prefix: 'popover',
      detail: { source },
      cancelable: false,
    });
    expect(popover.open).toBe(false);
  });

  it('does not emit a transition when a coalesced toggle settles back to its original state', () => {
    new Popover(controller, { element: panel });

    panel.dispatchEvent(nativeEvent('toggle', 'closed', null, 'closed'));

    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('ignores a closing beforetoggle and preserves a missing source as null', () => {
    new Popover(controller, { element: panel });

    panel.dispatchEvent(nativeEvent('beforetoggle', 'closed'));
    settle(true);

    expect(controller.dispatch).not.toHaveBeenCalledWith('before-open', expect.anything());
    expect(controller.dispatch).toHaveBeenCalledWith('opened', {
      target: panel,
      prefix: 'popover',
      detail: { source: null },
      cancelable: false,
    });
  });

  it('removes exactly its listeners and tolerates repeated disposal', () => {
    const popover = new Popover(controller, { element: panel });
    const removeEventListener = vi.spyOn(panel, 'removeEventListener');

    popover.disconnect();
    popover.disconnect();
    panel.dispatchEvent(nativeEvent('beforetoggle', 'open', source));
    settle(true, source);

    expect(removeEventListener).toHaveBeenCalledTimes(2);
    expect(removeEventListener).toHaveBeenNthCalledWith(1, 'beforetoggle', expect.any(Function));
    expect(removeEventListener).toHaveBeenNthCalledWith(2, 'toggle', expect.any(Function));
    expect(controller.dispatch).not.toHaveBeenCalled();
    expect(popover.open).toBe(false);
  });

  it('remains inert for an invalid element', () => {
    const invalid = document.createElement('div');
    const popover = new Popover(controller, { element: invalid });

    expect(popover.open).toBe(false);
    expect(() => popover.show(source)).not.toThrow();
    expect(() => popover.hide()).not.toThrow();
    expect(() => popover.toggle(source)).not.toThrow();
    expect(() => popover.disconnect()).not.toThrow();
  });

  it('rejects an element with native methods but no popover attribute', () => {
    panel.removeAttribute('popover');
    const popover = new Popover(controller, { element: panel });

    popover.show(source);
    popover.toggle(source);
    popover.hide();

    expect(panel.showPopover).not.toHaveBeenCalled();
    expect(panel.togglePopover).not.toHaveBeenCalled();
    expect(panel.hidePopover).not.toHaveBeenCalled();
    expect(popover.open).toBe(false);
  });
});
