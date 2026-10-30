import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ComboboxController from '../../../src/controllers/combobox_controller';
import ComboboxFetchController from '../../../src/controllers/combobox_fetch_controller';
import { installNativePopover } from '../../support/native_popover';

describe('ComboboxFetchController', () => {
  let application;
  let requests;

  const results = (...labels) => `
    <ul id="listbox" role="listbox" data-combobox-target="listbox">
      ${labels.map((label) => `<li role="option" data-value="${label}">${label}</li>`).join('')}
    </ul>`;

  // Resolves on demand; rejects with AbortError when aborted, like fetch.
  const stubFetch = () => {
    requests = [];
    vi.stubGlobal(
      'fetch',
      vi.fn(
        (url, { signal }) =>
          new Promise((resolve, reject) => {
            requests.push({ url: String(url), signal, resolve });
            signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError')));
          })
      )
    );
  };
  const respond = async (index, body, ok = true) => {
    requests[index].resolve({ ok, status: ok ? 200 : 500, text: async () => body });
    await vi.waitUntil(() => true);
    await new Promise((resolve) => setTimeout(resolve));
  };

  const render = async ({ delay = 0 } = {}) => {
    document.body.innerHTML = `
      <div id="root" data-controller="combobox combobox-fetch"
           data-combobox-mode-value="editable" data-combobox-match-value="none"
           data-combobox-fetch-src-value="/cities" data-combobox-fetch-delay-value="${delay}"
           data-action="combobox:query->combobox-fetch#onQuery combobox:closed->combobox-fetch#onClosed">
        <input id="trigger" role="combobox" aria-expanded="false" data-combobox-target="trigger"
               data-action="input->combobox#onInput keydown->combobox#onKeydown" />
        <input type="hidden" data-combobox-target="input" />
        <div id="panel" popover="manual" data-combobox-target="panel">
          ${results()}
          <div id="status" role="status" data-combobox-target="status" data-combobox-fetch-target="status"></div>
        </div>
      </div>`;
    installNativePopover(document.querySelector('#panel'));
    const root = document.querySelector('#root');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'combobox-fetch'));
    return { root, control: document.querySelector('#trigger') };
  };

  const type = async (control, text) => {
    control.value = text;
    control.dispatchEvent(new Event('input', { bubbles: true }));
    await new Promise((resolve) => setTimeout(resolve));
  };
  const status = () => document.querySelector('#status').textContent;
  const labels = () => [...document.querySelectorAll('[role="option"]')].map((option) => option.textContent);

  beforeEach(() => {
    stubFetch();
    application = Application.start();
    application.register('combobox', ComboboxController);
    application.register('combobox-fetch', ComboboxFetchController);
  });

  // Clearing first lets disconnect cancel pending requests.
  afterEach(async () => {
    document.body.innerHTML = '';
    await new Promise((resolve) => setTimeout(resolve));
    application.stop();
    vi.unstubAllGlobals();
  });

  it('requests the query and replaces the listbox with the matching response listbox', async () => {
    const { control } = await render();

    await type(control, 'Se');
    expect(requests.map((request) => request.url)).toEqual(['http://localhost:3000/cities?q=Se']);
    expect(status()).toBe('Loading…');
    expect(document.querySelector('#listbox').getAttribute('aria-busy')).toBe('true');
    await respond(0, `<main>${results('Seoul', 'Seville')}</main>`);

    expect(labels()).toEqual(['Seoul', 'Seville']);
    expect(document.querySelector('#listbox').hasAttribute('aria-busy')).toBe(false);
    expect(status()).toBe('');
  });

  it('requests the default results for an empty query', async () => {
    const { control } = await render();

    await type(control, 'S');
    await type(control, '');

    expect(requests.at(-1).url).toBe('http://localhost:3000/cities');
  });

  it('never lets a superseded response replace newer results', async () => {
    const { control } = await render();

    await type(control, 'S');
    await type(control, 'Se');
    expect(status()).toBe('Loading…');
    await respond(1, results('Seoul'));
    await respond(0, results('Singapore', 'Seoul'));

    expect(labels()).toEqual(['Seoul']);
    expect(status()).toBe('');
  });

  it('aborts the in-flight request as soon as a new query starts', async () => {
    const { control } = await render({ delay: 50 });

    await type(control, 'S');
    await vi.waitUntil(() => requests.length === 1);
    await type(control, 'Se');

    expect(requests[0].signal.aborted).toBe(true);
    expect(document.querySelector('#listbox').hasAttribute('aria-busy')).toBe(false);
    expect(status()).toBe('Loading…');
  });

  it('drops a request in flight when the panel closes', async () => {
    const { control } = await render();

    await type(control, 'Se');
    control.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true }));
    await new Promise((resolve) => setTimeout(resolve));

    expect(requests[0].signal.aborted).toBe(true);
    expect(status()).toBe('');
  });

  it('keeps a request in flight when a nested combobox closes', async () => {
    const { control } = await render();
    await type(control, 'Se');
    const nested = document.createElement('div');
    nested.setAttribute('data-controller', 'combobox');
    document.querySelector('#panel').append(nested);

    nested.dispatchEvent(new CustomEvent('combobox:closed', { bubbles: true }));
    nested.remove();

    expect(requests[0].signal.aborted).toBe(false);
    expect(status()).toBe('Loading…');
  });

  it('shows the error text for a failed response', async () => {
    const { control } = await render();

    await type(control, 'Se');
    await respond(0, 'Server error', false);

    expect(status()).toBe('Results could not be loaded');
    expect(document.querySelector('#listbox').hasAttribute('aria-busy')).toBe(false);
  });

  it('shows the error text when the response has no matching listbox', async () => {
    const { control } = await render();

    await type(control, 'Se');
    await respond(0, '<ul id="other" role="listbox"></ul>');

    expect(status()).toBe('Results could not be loaded');
    expect(document.querySelector('#listbox')).not.toBeNull();
  });

  it('ignores a query from a nested combobox', async () => {
    await render();

    document
      .querySelector('#listbox')
      .dispatchEvent(new CustomEvent('combobox:query', { bubbles: true, detail: { query: 'Se' } }));
    await new Promise((resolve) => setTimeout(resolve));

    expect(requests).toEqual([]);
  });

  it('cancels a pending request on disconnect', async () => {
    const { root, control } = await render();

    await type(control, 'Se');
    root.remove();
    await new Promise((resolve) => setTimeout(resolve));

    expect(requests[0].signal.aborted).toBe(true);
  });
});
