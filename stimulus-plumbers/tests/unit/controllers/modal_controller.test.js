import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ModalController from '../../../src/controllers/modal_controller';

describe('ModalController', () => {
  let application;
  let consoleErrorSpy;

  beforeEach(() => {
    application = Application.start();
    application.register('modal', ModalController);
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    consoleErrorSpy.mockRestore();
  });

  const render = async ({ attributes = '', methods = true } = {}) => {
    document.body.innerHTML = `
      <div data-controller="modal">
        <button id="open" data-action="modal#open">Open</button>
        <dialog data-modal-target="dialog" ${attributes}>
          <button id="dismiss" data-action="modal#dismiss">Cancel</button>
          <button id="close" data-action="modal#close" data-modal-result-param="confirm">Confirm</button>
        </dialog>
      </div>
    `;

    const dialog = document.querySelector('dialog');
    if (methods) {
      dialog.showModal = vi.fn(() => {
        dialog.open = true;
      });
      dialog.close = vi.fn((result = '') => {
        dialog.returnValue = result;
        dialog.open = false;
        dialog.dispatchEvent(new Event('close'));
      });
    }
    const root = document.querySelector('[data-controller="modal"]');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'modal'));
    return dialog;
  };

  it('requires a dialog target', async () => {
    document.body.innerHTML = '<div data-controller="modal"></div>';
    await vi.waitFor(() =>
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'ModalController requires a dialog target. Add data-modal-target="dialog" to your element.'
      )
    );
  });

  it('rejects a non-dialog target without throwing', async () => {
    document.body.innerHTML = '<div data-controller="modal"><div data-modal-target="dialog"></div></div>';
    await vi.waitFor(() =>
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'ModalController requires data-modal-target="dialog" to be a native <dialog> element.'
      )
    );
  });

  it('opens through showModal and resets returnValue', async () => {
    const dialog = await render();
    dialog.returnValue = 'old';

    document.querySelector('#open').click();

    expect(dialog.returnValue).toBe('');
    expect(dialog.showModal).toHaveBeenCalledOnce();
  });

  it('restores focus to the action invoker after closing', async () => {
    const dialog = await render();
    const open = document.querySelector('#open');

    open.click();
    dialog.close();
    await Promise.resolve();

    expect(document.activeElement).toBe(open);
  });

  it('ignores repeated open calls while the dialog is open', async () => {
    const dialog = await render();

    document.querySelector('#open').click();
    document.querySelector('#open').click();

    expect(dialog.showModal).toHaveBeenCalledOnce();
  });

  it('uses close for explicit completion and normalizes the action result', async () => {
    const dialog = await render();
    document.querySelector('#open').click();
    document.querySelector('#close').click();

    expect(dialog.close).toHaveBeenCalledWith('confirm');
  });

  it('normalizes programmatic results', async () => {
    const dialog = await render();
    const root = document.querySelector('[data-controller="modal"]');
    const controller = application.getControllerForElementAndIdentifier(root, 'modal');
    controller.open();
    controller.close(42);

    expect(dialog.close).toHaveBeenCalledWith('42');
  });

  it('dispatches opened and closed lifecycle events from native signals', async () => {
    const dialog = await render();
    const opened = vi.fn();
    const closed = vi.fn();
    dialog.addEventListener('modal:opened', opened);
    dialog.addEventListener('modal:closed', closed);

    document.querySelector('#open').click();
    dialog.dispatchEvent(new Event('toggle'));
    dialog.dispatchEvent(new Event('close'));

    expect(opened).toHaveBeenCalledOnce();
    expect(closed).toHaveBeenCalledOnce();
    expect(closed.mock.calls[0][0].detail).toEqual({ result: '' });
  });

  it('cancels open from modal:before-open', async () => {
    const dialog = await render();
    dialog.addEventListener('modal:before-open', (event) => event.preventDefault());

    document.querySelector('#open').click();

    expect(dialog.showModal).not.toHaveBeenCalled();
  });

  it('cancels request dismissal from modal:before-dismiss', async () => {
    const dialog = await render({ attributes: 'closedby="any"' });
    dialog.addEventListener('modal:before-dismiss', (event) => event.preventDefault());
    document.querySelector('#open').click();

    const cancel = new Event('cancel', { cancelable: true });
    dialog.dispatchEvent(cancel);

    expect(cancel.defaultPrevented).toBe(true);
    expect(dialog.close).not.toHaveBeenCalled();
  });

  it('removes adapter listeners when the target disconnects', async () => {
    const dialog = await render();
    const remove = vi.spyOn(dialog, 'removeEventListener');
    dialog.remove();

    await vi.waitFor(() => {
      expect(remove).toHaveBeenCalledWith('beforetoggle', expect.any(Function));
      expect(remove).toHaveBeenCalledWith('toggle', expect.any(Function));
      expect(remove).toHaveBeenCalledWith('cancel', expect.any(Function));
      expect(remove).toHaveBeenCalledWith('close', expect.any(Function));
    });
  });

  it('disconnects the old plumber when Turbo replaces the dialog target', async () => {
    const oldDialog = await render();
    const oldRemove = vi.spyOn(oldDialog, 'removeEventListener');

    const root = document.querySelector('[data-controller="modal"]');
    const newDialog = document.createElement('dialog');
    newDialog.dataset.modalTarget = 'dialog';
    newDialog.showModal = vi.fn(() => {
      newDialog.open = true;
    });
    newDialog.close = vi.fn();
    oldDialog.replaceWith(newDialog);

    await vi.waitFor(() => expect(oldRemove).toHaveBeenCalledWith('close', expect.any(Function)));
    await vi.waitUntil(() => root.querySelector('dialog') === newDialog);
    document.querySelector('#open').click();
    expect(newDialog.showModal).toHaveBeenCalledOnce();
  });

  it('closes an open dialog before Turbo caches the page', async () => {
    const dialog = await render();
    document.querySelector('#open').click();

    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(dialog.close).toHaveBeenCalledWith('');
  });

  it('removes the Turbo cache listener on controller disconnect', async () => {
    const dialog = await render();
    application.stop();

    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(dialog.close).not.toHaveBeenCalled();
  });
});
