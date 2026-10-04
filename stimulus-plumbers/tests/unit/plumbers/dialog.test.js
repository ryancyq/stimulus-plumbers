import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Dialog, attachDialog } from '../../../src/plumbers/dialog';

describe('Dialog', () => {
  let controller;
  let element;

  beforeEach(() => {
    element = document.createElement('dialog');
    document.body.appendChild(element);
    controller = {
      identifier: 'modal',
      dispatch: vi.fn((name, options) => {
        const event = new CustomEvent(`${options.prefix}:${name}`, {
          bubbles: true,
          cancelable: name === 'before-open' || name === 'before-dismiss',
          detail: options.detail,
        });
        options.target.dispatchEvent(event);
        return event;
      }),
    };
    element.showModal = vi.fn(() => {
      element.open = true;
    });
    element.close = vi.fn((result = '') => {
      element.returnValue = result;
      element.open = false;
      element.dispatchEvent(new Event('close'));
    });
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('exposes only the documented public API', () => {
    expect(Object.getOwnPropertyNames(Dialog.prototype)).toEqual([
      'constructor',
      'open',
      'show',
      'dismiss',
      'close',
      'disconnect',
    ]);
  });

  const setRect = () => {
    element.getBoundingClientRect = vi.fn(() => ({
      top: 100,
      left: 100,
      right: 300,
      bottom: 300,
    }));
  };

  const invoker = (label = 'Open modal') => {
    const button = document.createElement('button');
    button.textContent = label;
    document.body.appendChild(button);
    button.focus();
    return button;
  };

  const pointer = (type, target, clientX, clientY, pointerId = 1) =>
    target.dispatchEvent(new PointerEvent(type, { bubbles: true, clientX, clientY, pointerId }));

  it('attaches through the factory and reflects native open state', () => {
    const dialog = attachDialog(controller, { element });

    expect(dialog).toBeInstanceOf(Dialog);
    expect(dialog.open).toBe(false);
    element.open = true;
    expect(dialog.open).toBe(true);
  });

  it('remains inert for an invalid element', () => {
    const invalid = document.createElement('div');
    const dialog = new Dialog(controller, { element: invalid });

    expect(dialog.open).toBe(false);
    expect(() => dialog.show()).not.toThrow();
    expect(() => dialog.dismiss('cancel')).not.toThrow();
    expect(() => dialog.close('confirm')).not.toThrow();
  });

  it('authors the default closedby policy', () => {
    new Dialog(controller, { element });

    expect(element.getAttribute('closedby')).toBe('closerequest');
  });

  it('uses native showModal and close methods', () => {
    const dialog = new Dialog(controller, { element });
    dialog.show();
    dialog.close('confirm');

    expect(element.showModal).toHaveBeenCalledOnce();
    expect(element.close).toHaveBeenCalledWith('confirm');
  });

  it('does not override native focus restoration', async () => {
    const button = invoker();
    const focus = vi.spyOn(button, 'focus');
    const dialog = new Dialog(controller, { element });

    dialog.show();
    button.focus();
    focus.mockClear();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
    expect(focus).not.toHaveBeenCalled();
  });

  it('restores the invoker when closing leaves focus on the document body', async () => {
    const button = invoker();
    const dialog = new Dialog(controller, { element });
    document.body.tabIndex = -1;

    dialog.show();
    document.body.focus();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
  });

  it('restores an unfocused event invoker when activeElement is the body', async () => {
    const button = document.createElement('button');
    document.body.appendChild(button);
    const dialog = new Dialog(controller, { element });
    document.body.tabIndex = -1;

    document.body.focus();
    dialog.show(button);
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
  });

  it('does not restore a removed invoker', async () => {
    const button = invoker();
    const focus = vi.spyOn(button, 'focus');
    const dialog = new Dialog(controller, { element });
    document.body.tabIndex = -1;

    dialog.show();
    button.remove();
    document.body.focus();
    focus.mockClear();
    dialog.close();
    await Promise.resolve();

    expect(focus).not.toHaveBeenCalled();
    expect(document.activeElement).toBe(document.body);
  });

  it('ignores invalid and disconnected invoker candidates', async () => {
    const disconnected = document.createElement('button');
    const focus = vi.spyOn(disconnected, 'focus');
    const dialog = new Dialog(controller, { element });
    document.body.tabIndex = -1;

    document.body.focus();
    dialog.show(document.createElement('div'));
    dialog.close();
    await Promise.resolve();
    expect(document.activeElement).toBe(document.body);

    document.body.focus();
    dialog.show(disconnected);
    dialog.close();
    await Promise.resolve();

    expect(focus).not.toHaveBeenCalled();
    expect(document.activeElement).toBe(document.body);
  });

  it('does not override focus moved by a modal:closed listener', async () => {
    const button = invoker();
    const other = invoker('Other control');
    const focus = vi.spyOn(button, 'focus');
    const dialog = new Dialog(controller, { element });
    element.addEventListener('modal:closed', () => other.focus());

    dialog.show();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(other);
    expect(focus).not.toHaveBeenCalled();
  });

  it('clears focus restoration after canceled and failed opens', async () => {
    const button = invoker();
    const dialog = new Dialog(controller, { element });
    const cancelOpen = vi.fn((event) => event.preventDefault());
    element.addEventListener('modal:before-open', cancelOpen);

    dialog.show();
    element.removeEventListener('modal:before-open', cancelOpen);
    document.body.tabIndex = -1;
    document.body.focus();
    dialog.show();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(document.body);
    expect(button).not.toBe(document.activeElement);

    element.showModal = vi
      .fn()
      .mockImplementationOnce(() => {
        throw new Error('not allowed');
      })
      .mockImplementation(() => {
        element.open = true;
      });
    button.focus();
    expect(() => dialog.show()).toThrow('not allowed');
    document.body.focus();
    dialog.show();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(document.body);
  });

  it('captures an invoker for an external native beforetoggle open', async () => {
    const button = invoker();
    new Dialog(controller, { element });
    document.body.tabIndex = -1;

    element.dispatchEvent(new Event('beforetoggle'));
    element.open = true;
    element.dispatchEvent(new Event('toggle'));
    document.body.focus();
    element.open = false;
    element.dispatchEvent(new Event('close'));
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
  });

  it('prefers a native beforetoggle source over activeElement', async () => {
    const button = document.createElement('button');
    document.body.appendChild(button);
    new Dialog(controller, { element });
    document.body.tabIndex = -1;
    const beforetoggle = new Event('beforetoggle');
    Object.defineProperty(beforetoggle, 'source', { value: button });

    document.body.focus();
    element.dispatchEvent(beforetoggle);
    element.open = true;
    element.dispatchEvent(new Event('toggle'));
    element.open = false;
    element.dispatchEvent(new Event('close'));
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
  });

  it('cleans cycle state when showModal throws so a later open can retry', () => {
    const dialog = new Dialog(controller, { element });
    element.showModal = vi
      .fn()
      .mockImplementationOnce(() => {
        throw new Error('not allowed');
      })
      .mockImplementation(() => {
        element.open = true;
      });

    expect(() => dialog.show()).toThrow('not allowed');
    expect(() => dialog.show()).not.toThrow();
    expect(element.showModal).toHaveBeenCalledTimes(2);
  });

  it('dispatches before-open once and opened on toggle', () => {
    const dialog = new Dialog(controller, { element });
    const beforeOpen = vi.fn();
    const opened = vi.fn();
    element.addEventListener('modal:before-open', beforeOpen);
    element.addEventListener('modal:opened', opened);

    dialog.show();
    element.dispatchEvent(new Event('beforetoggle'));
    element.dispatchEvent(new Event('toggle'));

    expect(beforeOpen).toHaveBeenCalledOnce();
    expect(opened).toHaveBeenCalledOnce();
  });

  it('resets lifecycle guards for two external open cycles', () => {
    new Dialog(controller, { element });
    const beforeOpen = vi.fn();
    const opened = vi.fn();
    const closed = vi.fn();
    element.addEventListener('modal:before-open', beforeOpen);
    element.addEventListener('modal:opened', opened);
    element.addEventListener('modal:closed', closed);

    element.dispatchEvent(new Event('beforetoggle'));
    element.open = true;
    element.dispatchEvent(new Event('toggle'));
    element.open = false;
    element.dispatchEvent(new Event('close'));

    element.dispatchEvent(new Event('beforetoggle'));
    element.open = true;
    element.dispatchEvent(new Event('toggle'));
    element.open = false;
    element.dispatchEvent(new Event('close'));

    expect(beforeOpen).toHaveBeenCalledTimes(2);
    expect(opened).toHaveBeenCalledTimes(2);
    expect(closed).toHaveBeenCalledTimes(2);
  });

  it('delivers opened when showModal succeeds without a toggle event', () => {
    vi.useFakeTimers();
    const dialog = new Dialog(controller, { element });
    const opened = vi.fn();
    element.addEventListener('modal:opened', opened);

    dialog.show();
    vi.runAllTimers();

    expect(opened).toHaveBeenCalledOnce();
    vi.useRealTimers();
  });

  it('delivers opened for an external beforetoggle without toggle support', () => {
    vi.useFakeTimers();
    new Dialog(controller, { element });
    const opened = vi.fn();
    element.addEventListener('modal:opened', opened);

    element.dispatchEvent(new Event('beforetoggle'));
    element.open = true;
    vi.runAllTimers();

    expect(opened).toHaveBeenCalledOnce();
    vi.useRealTimers();
  });

  it('starts a new external cycle after native beforetoggle is canceled later', () => {
    vi.useFakeTimers();
    new Dialog(controller, { element });
    const beforeOpen = vi.fn();
    const cancelNativeOpen = vi.fn((event) => event.preventDefault());
    element.addEventListener('modal:before-open', beforeOpen);
    element.addEventListener('beforetoggle', cancelNativeOpen);

    element.dispatchEvent(new Event('beforetoggle', { cancelable: true }));
    vi.runAllTimers();
    element.removeEventListener('beforetoggle', cancelNativeOpen);

    element.dispatchEvent(new Event('beforetoggle', { cancelable: true }));
    element.open = true;
    element.dispatchEvent(new Event('toggle'));

    expect(beforeOpen).toHaveBeenCalledTimes(2);
    vi.useRealTimers();
  });

  it('reports external close exactly once with a normalized result', () => {
    new Dialog(controller, { element });
    const closed = vi.fn();
    element.addEventListener('modal:closed', closed);
    element.open = true;
    element.returnValue = 42;

    element.dispatchEvent(new Event('close'));
    element.dispatchEvent(new Event('close'));

    expect(closed).toHaveBeenCalledOnce();
    expect(closed.mock.calls[0][0].detail).toEqual({ result: '42' });
  });

  it('queues an immediate reopen until the native close event completes', async () => {
    const button = invoker();
    const inside = document.createElement('input');
    element.appendChild(inside);
    const dialog = new Dialog(controller, { element });
    element.close = vi.fn(() => {
      element.open = false;
    });

    dialog.show();
    inside.focus();
    dialog.close('confirm');
    dialog.show();

    expect(element.showModal).toHaveBeenCalledOnce();
    element.dispatchEvent(new Event('close'));
    await Promise.resolve();

    expect(element.showModal).toHaveBeenCalledTimes(2);
    dialog.close('final');
    element.dispatchEvent(new Event('close'));
    await Promise.resolve();

    expect(document.activeElement).toBe(button);
  });

  it('uses requestClose when available and exposes a cancellable dismissal', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    element.requestClose = vi.fn((result) => {
      const cancel = new Event('cancel', { cancelable: true });
      element.dispatchEvent(cancel);
      if (!cancel.defaultPrevented) {
        element.returnValue = result;
        element.open = false;
      }
    });
    const beforeDismiss = vi.fn();
    element.addEventListener('modal:before-dismiss', beforeDismiss);

    dialog.dismiss('cancel');

    expect(element.requestClose).toHaveBeenCalledWith('cancel');
    expect(beforeDismiss).toHaveBeenCalledWith(expect.objectContaining({ detail: { result: 'cancel' } }));
  });

  it('uses cancellable cancel fallback when requestClose is unavailable', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    const beforeDismiss = vi.fn((event) => event.preventDefault());
    element.addEventListener('modal:before-dismiss', beforeDismiss);

    dialog.dismiss('cancel');

    expect(beforeDismiss).toHaveBeenCalledOnce();
    expect(element.close).not.toHaveBeenCalled();
  });

  it('cleans cancellation state so a later dismissal can proceed', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    const beforeDismiss = vi.fn((event) => event.preventDefault());
    element.addEventListener('modal:before-dismiss', beforeDismiss);

    dialog.dismiss('cancel');
    element.removeEventListener('modal:before-dismiss', beforeDismiss);
    dialog.dismiss('cancel');

    expect(element.close).toHaveBeenCalledWith('cancel');
  });

  it('cleans state when a later cancel listener prevents requestClose', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    element.returnValue = 'existing';
    element.requestClose = vi.fn((result) => {
      const cancel = new Event('cancel', { cancelable: true });
      element.dispatchEvent(cancel);
      if (!cancel.defaultPrevented) {
        element.returnValue = result;
        element.open = false;
      }
    });
    element.addEventListener('cancel', (event) => event.preventDefault());

    dialog.dismiss('cancel');

    expect(element.returnValue).toBe('existing');
  });

  it('cleans state when a later cancel listener prevents the fallback', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    element.addEventListener('cancel', (event) => event.preventDefault());

    dialog.dismiss('cancel');

    expect(element.close).not.toHaveBeenCalled();
  });

  it.each([
    ['any', false],
    ['closerequest', false],
    ['none', true],
  ])('applies the %s dismissal policy to cancel requests', (policy, prevented) => {
    new Dialog(controller, { element });
    element.setAttribute('closedby', policy);
    element.open = true;

    const cancel = new Event('cancel', { cancelable: true });
    element.dispatchEvent(cancel);

    expect(cancel.defaultPrevented).toBe(prevented);
  });

  it('explicit close bypasses before-dismiss', () => {
    const dialog = new Dialog(controller, { element });
    const beforeDismiss = vi.fn();
    element.addEventListener('modal:before-dismiss', beforeDismiss);
    element.open = true;

    dialog.close('confirm');

    expect(beforeDismiss).not.toHaveBeenCalled();
    expect(element.close).toHaveBeenCalledWith('confirm');
  });

  it('does not change returnValue when native close throws', () => {
    const dialog = new Dialog(controller, { element });
    element.open = true;
    element.returnValue = 'existing';
    element.close = vi.fn(() => {
      throw new Error('not allowed');
    });

    expect(() => dialog.close('confirm')).toThrow('not allowed');
    expect(element.returnValue).toBe('existing');
  });

  it('requires a matching backdrop pointer pair for closedby any', () => {
    const dialog = new Dialog(controller, { element });
    element.setAttribute('closedby', 'any');
    element.open = true;
    setRect();
    const dismiss = vi.spyOn(dialog, 'dismiss');

    pointer('pointerdown', element, 0, 0);
    pointer('pointerup', element, 0, 0);

    expect(dismiss).toHaveBeenCalledOnce();
  });

  it('does not dismiss for interior, mixed, or mismatched backdrop pointers', () => {
    const child = document.createElement('span');
    element.appendChild(child);
    const dialog = new Dialog(controller, { element });
    element.setAttribute('closedby', 'any');
    element.open = true;
    setRect();
    const dismiss = vi.spyOn(dialog, 'dismiss');

    pointer('pointerdown', element, 200, 200);
    pointer('pointerup', element, 200, 200);
    pointer('pointerdown', element, 0, 0);
    pointer('pointerup', element, 200, 200);
    pointer('pointerdown', element, 0, 0);
    pointer('pointerup', child, 0, 0);

    expect(dismiss).not.toHaveBeenCalled();
  });

  it('does not dismiss after pointer cancellation or with a different pointer', () => {
    const dialog = new Dialog(controller, { element });
    element.setAttribute('closedby', 'any');
    element.open = true;
    setRect();
    const dismiss = vi.spyOn(dialog, 'dismiss');

    pointer('pointerdown', element, 0, 0, 1);
    pointer('pointercancel', element, 0, 0, 1);
    pointer('pointerup', element, 0, 0, 1);
    pointer('pointerdown', element, 0, 0, 1);
    pointer('pointerup', element, 0, 0, 2);

    expect(dismiss).not.toHaveBeenCalled();
  });

  it('cleans every listener on disconnect', () => {
    const dialog = new Dialog(controller, { element });
    const remove = vi.spyOn(element, 'removeEventListener');
    dialog.disconnect();

    expect(remove).toHaveBeenCalledWith('beforetoggle', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('toggle', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('cancel', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('close', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('pointerdown', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('pointerup', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('pointercancel', expect.any(Function));
  });
});
