import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ModalController from '../../../src/controllers/modal_controller';
import ModalTurboController from '../../../src/controllers/modal_turbo_controller';

describe('ModalTurboController', () => {
  let application;
  let consoleErrorSpy;

  beforeEach(() => {
    application = Application.start();
    application.register('modal', ModalController);
    application.register('modal-turbo', ModalTurboController);
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    vi.restoreAllMocks();
  });

  const render = async ({ closeOnSuccess = true, frame = true } = {}) => {
    document.body.innerHTML = `
      <div data-controller="modal modal-turbo"
           ${closeOnSuccess ? '' : 'data-modal-turbo-close-on-success-value="false"'}
           data-action="modal:closed->modal-turbo#onClosed">
        <dialog data-modal-target="dialog">
          ${frame ? '<turbo-frame id="modal" data-modal-turbo-target="frame" data-action="turbo:before-fetch-request->modal-turbo#onBeforeFetchRequest turbo:frame-render->modal-turbo#onFrameRender turbo:submit-end->modal-turbo#onSubmitEnd"></turbo-frame>' : ''}
        </dialog>
      </div>
    `;
    const dialog = document.querySelector('dialog');
    dialog.showModal = vi.fn(() => {
      dialog.open = true;
    });
    dialog.close = vi.fn(() => {
      dialog.open = false;
      dialog.dispatchEvent(new Event('close', { bubbles: true }));
    });
    const root = document.querySelector('[data-controller]');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'modal'));
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'modal-turbo'));
    return {
      root,
      dialog,
      frame: document.querySelector('turbo-frame'),
    };
  };

  const renderEvent = (frame, detail = { fetchResponse: { succeeded: true } }) => {
    frame.dispatchEvent(new CustomEvent('turbo:frame-render', { bubbles: true, detail }));
  };

  const eventFor = (name, target, detail) => {
    const event = new CustomEvent(name, { detail });
    Object.defineProperty(event, 'target', { value: target });
    return event;
  };

  it('requires a frame target and remains inert', async () => {
    await render({ frame: false });

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'ModalTurboController requires a frame target. Add data-modal-turbo-target="frame" to your element.'
    );
  });

  it('opens on a successful non-empty render only for its frame', async () => {
    const { dialog, frame } = await render();
    const turbo = application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller]'),
      'modal-turbo'
    );
    expect(turbo).toBeTruthy();
    const otherFrame = document.createElement('turbo-frame');
    document.body.append(otherFrame);

    renderEvent(frame, { fetchResponse: { succeeded: true } });
    expect(dialog.showModal).not.toHaveBeenCalled();

    frame.innerHTML = '<h2>Remote content</h2>';
    renderEvent(otherFrame, { fetchResponse: { succeeded: true } });
    expect(dialog.showModal).not.toHaveBeenCalled();

    renderEvent(frame, { fetchResponse: { succeeded: true } });
    expect(dialog.showModal).toHaveBeenCalledOnce();
  });

  it('preserves focus selected inside an already-open Turbo modal render', async () => {
    const { dialog, frame } = await render({ closeOnSuccess: false });
    dialog.open = true;
    frame.innerHTML = '<input id="selected" aria-label="Selected field">';
    const selected = frame.querySelector('#selected');
    selected.focus();

    renderEvent(frame);

    expect(document.activeElement).toBe(selected);
    expect(dialog.showModal).not.toHaveBeenCalled();
  });

  it('focuses rendered autofocus content after a failed response strands focus', async () => {
    const { dialog, frame } = await render({ closeOnSuccess: false });
    dialog.open = true;
    dialog.focus = vi.fn();
    frame.innerHTML = '<input id="name" autofocus aria-label="Name">';
    document.body.focus();

    renderEvent(frame, { fetchResponse: { succeeded: false } });

    expect(document.activeElement).toBe(frame.querySelector('#name'));
    expect(dialog.focus).not.toHaveBeenCalled();
  });

  it('focuses the open dialog when rendered content has no autofocus', async () => {
    const { dialog, frame } = await render({ closeOnSuccess: false });
    dialog.open = true;
    dialog.focus = vi.fn();
    frame.innerHTML = '<p>Validation failed</p>';
    document.body.focus();

    renderEvent(frame);

    expect(dialog.focus).toHaveBeenCalledWith({ preventScroll: true });
  });

  it('ignores failed frame responses', async () => {
    const { dialog, frame } = await render();
    frame.innerHTML = '<p>Validation</p>';
    renderEvent(frame, { fetchResponse: { succeeded: false } });

    expect(dialog.showModal).not.toHaveBeenCalled();
  });

  it('ignores empty, missing-detail, and network frame renders', async () => {
    const { dialog, frame } = await render();
    renderEvent(frame, {});
    frame.innerHTML = '   ';
    renderEvent(frame);
    renderEvent(frame, { fetchResponse: { succeeded: false, networkError: true } });

    expect(dialog.showModal).not.toHaveBeenCalled();
  });

  it('closes successful forms by default and keeps failed forms open', async () => {
    const { root, dialog, frame } = await render();
    frame.innerHTML = '<form id="inside"></form>';
    dialog.open = true;
    const form = frame.querySelector('form');
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    turbo.onSubmitEnd(eventFor('turbo:submit-end', form, { success: false }));
    expect(dialog.close).not.toHaveBeenCalled();
    turbo.onSubmitEnd(eventFor('turbo:submit-end', form, { success: true }));
    expect(dialog.close).toHaveBeenCalledOnce();
  });

  it('clears a successful response rendered after the previous clear without reopening', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    dialog.getAnimations = vi.fn(() => []);
    frame.innerHTML = '<form></form>';
    dialog.open = true;
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    turbo.onSubmitEnd(eventFor('turbo:submit-end', frame.querySelector('form'), { success: true }));
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));

    frame.innerHTML = '<p>Saved</p>';
    renderEvent(frame);
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));

    expect(dialog.close).toHaveBeenCalledOnce();
    expect(dialog.showModal).not.toHaveBeenCalled();
    expect(frame.innerHTML).toBe('');
  });

  it('keeps a redirected success response until the pending close animation finishes', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    let finish;
    dialog.getAnimations = vi.fn(() => [
      {
        effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) },
        finished: new Promise((resolve) => (finish = resolve)),
      },
    ]);
    frame.innerHTML = '<form></form>';
    dialog.open = true;
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    turbo.onSubmitEnd(eventFor('turbo:submit-end', frame.querySelector('form'), { success: true }));

    frame.innerHTML = '<p>Saved</p>';
    renderEvent(frame);
    expect(dialog.showModal).not.toHaveBeenCalled();
    expect(frame.innerHTML).toContain('Saved');

    finish();
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));
  });

  it('preserves a pending close clear across frame target replacement', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    let finish;
    dialog.getAnimations = vi.fn(() => [
      {
        effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) },
        finished: new Promise((resolve) => (finish = resolve)),
      },
    ]);
    frame.innerHTML = '<form></form>';
    dialog.open = true;
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    turbo.onSubmitEnd(eventFor('turbo:submit-end', frame.querySelector('form'), { success: true }));
    const replacement = document.createElement('turbo-frame');
    replacement.dataset.modalTurboTarget = 'frame';
    replacement.dataset.action = 'turbo:frame-render->modal-turbo#onFrameRender';
    frame.replaceWith(replacement);
    await vi.waitUntil(() => turbo.hasFrameTarget && turbo.frameTarget === replacement);
    replacement.innerHTML = '<p>Saved</p>';
    renderEvent(replacement);
    expect(dialog.showModal).not.toHaveBeenCalled();
    expect(replacement.innerHTML).toContain('Saved');

    finish();
    await vi.waitFor(() => expect(replacement.innerHTML).toBe(''));
  });

  it('resets a stale successful-submit guard when a new frame request begins', async () => {
    const { dialog, frame } = await render();
    frame.innerHTML = '<form id="inside"></form>';
    dialog.open = true;
    const form = frame.querySelector('form');

    form.dispatchEvent(new CustomEvent('turbo:submit-end', { bubbles: true, detail: { success: true } }));
    expect(dialog.close).toHaveBeenCalledOnce();

    frame.dispatchEvent(new CustomEvent('turbo:before-fetch-request', { bubbles: true }));
    frame.innerHTML = '<p>New response</p>';
    renderEvent(frame);

    expect(dialog.showModal).toHaveBeenCalledOnce();
    expect(frame.innerHTML).toContain('New response');
  });

  it('supports opting out of successful-submit closing and ignores unrelated forms', async () => {
    const { root, dialog, frame } = await render({ closeOnSuccess: false });
    frame.innerHTML = '<form id="inside"></form>';
    dialog.open = true;
    const unrelated = document.createElement('form');
    document.body.append(unrelated);
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    turbo.onSubmitEnd(eventFor('turbo:submit-end', unrelated, { success: true }));
    turbo.onSubmitEnd(eventFor('turbo:submit-end', frame.querySelector('form'), { success: true }));
    expect(dialog.close).not.toHaveBeenCalled();
  });

  it('clears after animations and cancels stale clears when content renders again', async () => {
    const { root, dialog, frame } = await render();
    dialog.open = true;
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    let finish;
    dialog.getAnimations = vi.fn(() => [
      {
        effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) },
        finished: new Promise((resolve) => (finish = resolve)),
      },
    ]);
    frame.innerHTML = '<p>Old</p>';
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    turbo.onClosed({ target: dialog });
    await vi.waitUntil(() => finish);
    frame.innerHTML = '<p>New</p>';
    renderEvent(frame);
    finish();
    await vi.waitFor(() => expect(frame.innerHTML).toContain('New'));

    expect(frame.innerHTML).toContain('New');
  });

  it('does not wait for infinite descendant animations', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    let finish;
    const descendant = document.createElement('div');
    dialog.append(descendant);
    dialog.getAnimations = vi.fn(() => [
      {
        effect: {
          target: descendant,
          getComputedTiming: () => ({ endTime: Infinity }),
        },
        finished: new Promise(() => {}),
      },
      {
        effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) },
        finished: new Promise((resolve) => (finish = resolve)),
      },
    ]);
    frame.innerHTML = '<p>Content</p>';
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    turbo.onClosed({ target: dialog });
    finish();
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));
  });

  it('clears on the next frame when animations are unavailable or absent', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    frame.innerHTML = '<p>Without API</p>';
    dialog.getAnimations = undefined;
    turbo.onClosed({ target: dialog });
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));

    frame.innerHTML = '<p>Without animations</p>';
    dialog.getAnimations = vi.fn(() => []);
    turbo.onClosed({ target: dialog });
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));
  });

  it('clears normally after a finite dialog animation', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    dialog.getAnimations = vi.fn(() => [
      { effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) }, finished: Promise.resolve() },
    ]);
    frame.innerHTML = '<p>Content</p>';
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    turbo.onClosed({ target: dialog });
    await vi.waitFor(() => expect(frame.innerHTML).toBe(''));
  });

  it('closes and clears synchronously before Turbo caches', async () => {
    const { dialog, frame } = await render();
    dialog.open = true;
    frame.setAttribute('src', '/edit');
    frame.setAttribute('complete', '');
    frame.innerHTML = '<p>Content</p>';
    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(dialog.close).toHaveBeenCalledOnce();
    expect(frame.getAttribute('src')).toBeNull();
    expect(frame.hasAttribute('complete')).toBe(false);
    expect(frame.innerHTML).toBe('');
  });

  it('cancels a pending clear when disconnected', async () => {
    const { root, dialog, frame } = await render();
    vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => callback());
    let finish;
    const finished = new Promise((resolve) => (finish = resolve));
    dialog.getAnimations = vi.fn(() => [
      { effect: { target: dialog, getComputedTiming: () => ({ endTime: 100 }) }, finished },
    ]);
    frame.innerHTML = '<p>Content</p>';
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    turbo.onClosed({ target: dialog });
    application.stop();
    finish();
    await finished;
    await Promise.resolve();

    expect(frame.innerHTML).toContain('Content');
  });

  it('reconnects the frame target before handling a new render', async () => {
    const { dialog, frame } = await render();
    const replacement = document.createElement('turbo-frame');
    replacement.dataset.modalTurboTarget = 'frame';
    replacement.dataset.action = 'turbo:frame-render->modal-turbo#onFrameRender';
    frame.replaceWith(replacement);
    const root = document.querySelector('[data-controller]');
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    await vi.waitUntil(() => turbo.hasFrameTarget && turbo.frameTarget === replacement);
    replacement.innerHTML = '<p>Reconnected</p>';
    renderEvent(replacement);

    expect(dialog.showModal).toHaveBeenCalledOnce();
  });

  it('recovers when its required frame target is connected later', async () => {
    const { root, dialog } = await render({ frame: false });
    const frame = document.createElement('turbo-frame');
    frame.dataset.modalTurboTarget = 'frame';
    frame.dataset.action = 'turbo:frame-render->modal-turbo#onFrameRender';
    root.querySelector('dialog').append(frame);
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');
    await vi.waitUntil(() => turbo.hasFrameTarget && turbo.frameTarget === frame);
    frame.innerHTML = '<p>Connected later</p>';
    renderEvent(frame);

    expect(dialog.showModal).toHaveBeenCalledOnce();
  });

  it('remains inert when no modal controller is co-located', async () => {
    document.body.innerHTML =
      '<div data-controller="modal-turbo"><turbo-frame data-modal-turbo-target="frame"></turbo-frame></div>';
    const root = document.querySelector('[data-controller]');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'modal-turbo'));
    const frame = root.querySelector('turbo-frame');
    frame.innerHTML = '<form></form><p>Content</p>';
    const turbo = application.getControllerForElementAndIdentifier(root, 'modal-turbo');

    expect(() => renderEvent(frame)).not.toThrow();
    turbo.onSubmitEnd(eventFor('turbo:submit-end', frame.querySelector('form'), { success: true }));
    frame.innerHTML = '<p>Response</p>';
    renderEvent(frame);

    expect(frame.innerHTML).toContain('Response');
  });
});
