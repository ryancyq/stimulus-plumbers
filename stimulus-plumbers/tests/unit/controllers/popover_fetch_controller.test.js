import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import PopoverFetchController from '../../../src/controllers/popover_fetch_controller';
import { installNativePopover } from '../../support/native_popover';

describe('PopoverFetchController', () => {
  let application;
  let requests;

  // Resolves on demand; rejects with AbortError when aborted, like fetch.
  const stubFetch = () => {
    requests = [];
    vi.stubGlobal(
      'fetch',
      vi.fn(
        (url, { signal }) =>
          new Promise((resolve, reject) => {
            requests.push({ url: String(url), resolve });
            signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError')));
          })
      )
    );
  };
  const respond = async (index, body, ok = true) => {
    requests[index].resolve({ ok, status: ok ? 200 : 500, text: async () => body });
    await new Promise((resolve) => setTimeout(resolve));
  };
  const lifecycle = (element, name) => element.dispatchEvent(new CustomEvent(`popover:${name}`, { bubbles: true }));

  const render = async ({ reload = false, regionId = 'menu' } = {}) => {
    document.body.innerHTML = `
      <div id="container" data-controller="popover-fetch" data-popover-fetch-src-value="/menu"
           data-popover-fetch-reload-value="${reload}"
           data-action="popover:opened->popover-fetch#onOpened popover:closed->popover-fetch#onClosed">
        <div id="panel" popover="auto" tabindex="-1">
          <div ${regionId ? `id="${regionId}"` : ''} data-popover-fetch-target="region"><a href="#" id="placeholder">Loading</a></div>
          <div role="status" data-popover-fetch-target="status"></div>
        </div>
      </div>`;
    const container = document.querySelector('#container');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    panel.showPopover();
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'popover-fetch'));
    return { container, panel };
  };
  const status = () => document.querySelector('[role="status"]').textContent;
  const menu = (text) => `<div id="menu"><a href="#" id="item">${text}</a></div>`;

  beforeEach(() => {
    stubFetch();
    application = Application.start();
    application.register('popover-fetch', PopoverFetchController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it('loads the region when the panel first opens', async () => {
    const { panel } = await render();

    lifecycle(panel, 'opened');
    expect(requests[0].url).toMatch(/\/menu$/);
    expect(status()).toBe('Loading…');

    await respond(0, menu('Profile'));
    expect(document.querySelector('#menu').textContent).toBe('Profile');
    expect(status()).toBe('');

    lifecycle(panel, 'opened');
    expect(requests).toHaveLength(1);
  });

  it('reloads on every open with reload', async () => {
    const { panel } = await render({ reload: true });
    lifecycle(panel, 'opened');
    await respond(0, menu('First'));

    lifecycle(panel, 'opened');
    await respond(1, menu('Second'));

    expect(document.querySelector('#menu').textContent).toBe('Second');
  });

  it('shows the error text for a failed load and retries on the next open', async () => {
    const { panel } = await render();
    lifecycle(panel, 'opened');
    await respond(0, 'Server error', false);

    expect(status()).toBe('Content could not be loaded');

    lifecycle(panel, 'opened');
    expect(requests).toHaveLength(2);
  });

  it('cancels a load in flight when the panel closes', async () => {
    const { panel } = await render();
    lifecycle(panel, 'opened');

    lifecycle(panel, 'closed');
    await new Promise((resolve) => setTimeout(resolve));

    expect(status()).toBe('');
    expect(document.querySelector('#menu').hasAttribute('aria-busy')).toBe(false);
  });

  it('moves focus into the new region when the swap drops it', async () => {
    // jsdom has no layout; focusFirst skips elements without a box.
    vi.spyOn(HTMLElement.prototype, 'offsetWidth', 'get').mockReturnValue(1);
    const { panel } = await render();
    lifecycle(panel, 'opened');
    document.querySelector('#placeholder').focus();

    await respond(0, menu('Profile'));

    expect(document.activeElement.id).toBe('item');
  });

  it('focuses the panel when the new region has nothing focusable', async () => {
    const { panel } = await render();
    lifecycle(panel, 'opened');
    document.querySelector('#placeholder').focus();

    await respond(0, '<div id="menu">No items</div>');

    expect(document.activeElement).toBe(panel);
  });

  it('leaves focus that moved out of the region during the load', async () => {
    const { panel } = await render();
    document.body.insertAdjacentHTML('beforeend', '<button id="outside">Outside</button>');
    document.querySelector('#placeholder').focus();
    lifecycle(panel, 'opened');
    document.querySelector('#outside').focus();

    await respond(0, menu('Profile'));

    expect(document.activeElement.id).toBe('outside');
  });

  it('finds the swapped-in region by id after reconnecting', async () => {
    const { container, panel } = await render({ reload: true });
    lifecycle(panel, 'opened');
    await respond(0, menu('First'));

    container.remove();
    document.body.append(container);
    await new Promise((resolve) => setTimeout(resolve));
    lifecycle(panel, 'opened');
    await respond(1, menu('Second'));

    expect(document.querySelector('#menu').textContent).toBe('Second');
  });

  it('ignores opens when the region has no id', async () => {
    const { panel } = await render({ regionId: null });

    lifecycle(panel, 'opened');
    await new Promise((resolve) => setTimeout(resolve));

    expect(requests).toHaveLength(0);
    expect(status()).toBe('');
  });

  it('ignores a popover opening inside the region', async () => {
    await render();
    document.querySelector('#menu').insertAdjacentHTML('beforeend', '<div id="nested" popover="auto"></div>');

    lifecycle(document.querySelector('#nested'), 'opened');

    expect(requests).toHaveLength(0);
  });
});
