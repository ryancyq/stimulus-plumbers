import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import TurboFrame from '../../../../src/controllers/turbo/frame';
import { flush, startApplication } from '../../../support/stimulus';

class FrameController extends TurboFrame {
  get _frame() {
    return this.element.querySelector('#frame');
  }

  _failed() {
    this.dispatch('failed');
  }
}

describe('Turbo Frame', () => {
  const render = async () => {
    document.body.innerHTML = `
      <div id="root" data-controller="frame"
           data-action="turbo:before-fetch-response->frame#onResponse turbo:frame-missing->frame#onError turbo:fetch-request-error->frame#onError">
        <turbo-frame id="frame"><turbo-frame id="nested"></turbo-frame></turbo-frame>
        <turbo-frame id="other"></turbo-frame>
      </div>`;
    const failed = vi.fn();
    document.querySelector('#root').addEventListener('frame:failed', failed);
    await flush();
    return { failed };
  };

  const respond = (selector, fetchResponse) =>
    document
      .querySelector(selector)
      .dispatchEvent(new CustomEvent('turbo:before-fetch-response', { bubbles: true, detail: { fetchResponse } }));

  beforeEach(() => {
    startApplication({ frame: FrameController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('reports a failed response', async () => {
    const { failed } = await render();

    respond('#frame', { succeeded: false, isHTML: true });
    respond('#frame', { succeeded: true, isHTML: true });

    expect(failed).toHaveBeenCalledOnce();
  });

  it('reports a successful response that is not HTML', async () => {
    const { failed } = await render();

    respond('#frame', { succeeded: true, isHTML: false });

    expect(failed).toHaveBeenCalledOnce();
  });

  it('keeps the current content when the response has no matching frame', async () => {
    const { failed } = await render();
    const missing = new CustomEvent('turbo:frame-missing', { bubbles: true, cancelable: true });

    document.querySelector('#frame').dispatchEvent(missing);

    expect(missing.defaultPrevented).toBe(true);
    expect(failed).toHaveBeenCalledOnce();
  });

  it('reports a network error without blocking Turbo', async () => {
    const { failed } = await render();
    const error = new CustomEvent('turbo:fetch-request-error', { bubbles: true, cancelable: true });

    document.querySelector('#frame').dispatchEvent(error);

    expect(error.defaultPrevented).toBe(false);
    expect(failed).toHaveBeenCalledOnce();
  });

  it('ignores responses for other frames', async () => {
    const { failed } = await render();

    respond('#other', { succeeded: false, isHTML: true });
    respond('#nested', { succeeded: false, isHTML: true });

    expect(failed).not.toHaveBeenCalled();
  });
});
