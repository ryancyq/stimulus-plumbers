import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ComboboxController from '../../../src/controllers/combobox_controller';
import ComboboxTurboController from '../../../src/controllers/combobox_turbo_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('ComboboxTurboController', () => {
  const render = async () => {
    document.body.innerHTML = `
      <div id="container" data-controller="combobox combobox-turbo"
           data-combobox-mode-value="editable" data-combobox-match-value="none"
           data-combobox-turbo-src-value="/cities" data-combobox-turbo-delay-value="300"
           data-action="combobox:query->combobox-turbo#onQuery combobox:closed->combobox-turbo#onClosed">
        <input id="trigger" role="combobox" aria-expanded="false" data-combobox-target="trigger"
               data-action="input->combobox#onInput keydown->combobox#onKeydown" />
        <input type="hidden" data-combobox-target="input" />
        <div id="panel" popover="manual" data-combobox-target="panel">
          <turbo-frame id="frame" data-combobox-turbo-target="frame"
                       data-action="turbo:before-fetch-response->combobox-turbo#onResponse turbo:frame-missing->combobox-turbo#onError turbo:fetch-request-error->combobox-turbo#onError">
            <ul id="listbox" role="listbox" data-combobox-target="listbox"></ul>
          </turbo-frame>
          <div id="status" role="status" data-combobox-target="status" data-combobox-turbo-target="status"></div>
        </div>
      </div>`;
    installNativePopover(document.querySelector('#panel'));
    const container = document.querySelector('#container');
    await flush();
    vi.useFakeTimers({ toFake: ['setTimeout', 'clearTimeout'] });
    return { container, frame: document.querySelector('#frame'), control: document.querySelector('#trigger') };
  };

  const query = (container, text) =>
    container.dispatchEvent(new CustomEvent('combobox:query', { detail: { query: text } }));
  const type = (control, text) => {
    control.value = text;
    control.dispatchEvent(new Event('input', { bubbles: true }));
  };
  const status = () => document.querySelector('#status').textContent;
  const key = (target, name) =>
    target.dispatchEvent(new KeyboardEvent('keydown', { key: name, bubbles: true, cancelable: true }));

  beforeEach(() => {
    startApplication({ combobox: ComboboxController, 'combobox-turbo': ComboboxTurboController });
  });

  afterEach(() => {
    vi.useRealTimers();
    document.body.innerHTML = '';
  });

  it('navigates the frame to the query after the delay', async () => {
    const { container, frame } = await render();

    query(container, 'Se');
    expect(frame.hasAttribute('src')).toBe(false);
    vi.advanceTimersByTime(300);

    expect(frame.getAttribute('src')).toBe('http://localhost:3000/cities?q=Se');
  });

  it('navigates only for the latest query', async () => {
    const { container, frame } = await render();
    const setAttribute = vi.spyOn(frame, 'setAttribute');

    query(container, 'S');
    vi.advanceTimersByTime(100);
    query(container, 'Se');
    vi.advanceTimersByTime(300);

    expect(setAttribute.mock.calls).toEqual([['src', 'http://localhost:3000/cities?q=Se']]);
  });

  it('loads the default results at once for an empty query', async () => {
    const { container, frame } = await render();

    query(container, 'Se');
    query(container, '');

    expect(frame.getAttribute('src')).toBe('http://localhost:3000/cities');
    vi.advanceTimersByTime(300);
    expect(frame.getAttribute('src')).toBe('http://localhost:3000/cities');
  });

  it('cancels the in-flight request as soon as a new query starts', async () => {
    const { container, frame } = await render();
    frame.setAttribute('src', 'http://localhost:3000/cities?q=S');

    query(container, 'Se');
    expect(frame.hasAttribute('src')).toBe(false);
    vi.advanceTimersByTime(300);

    expect(frame.getAttribute('src')).toBe('http://localhost:3000/cities?q=Se');
  });

  it('cancels pending and in-flight requests when the panel closes', async () => {
    const { frame, control } = await render();
    const settleClose = async () => {
      key(control, 'Escape');
      await Promise.resolve();
      await Promise.resolve();
    };

    type(control, 'S');
    vi.advanceTimersByTime(300);
    expect(frame.hasAttribute('src')).toBe(true);
    await settleClose();
    expect(frame.hasAttribute('src')).toBe(false);

    type(control, 'Se');
    await Promise.resolve();
    await settleClose();
    vi.advanceTimersByTime(300);

    expect(frame.hasAttribute('src')).toBe(false);
    expect(status()).toBe('');
  });

  it('keeps the request when a nested combobox closes', async () => {
    const { frame } = await render();
    frame.setAttribute('src', 'http://localhost:3000/cities?q=S');
    const nested = document.createElement('div');
    nested.setAttribute('data-controller', 'combobox');
    document.querySelector('#panel').append(nested);

    nested.dispatchEvent(new CustomEvent('combobox:closed', { bubbles: true }));
    nested.remove();

    expect(frame.getAttribute('src')).toBe('http://localhost:3000/cities?q=S');
  });

  it('shows loading while a query is pending', async () => {
    const { container } = await render();

    query(container, 'Se');

    expect(status()).toBe('Loading…');
  });

  it('shows the error text for a failed response and keeps loading for a successful one', async () => {
    const { container, frame } = await render();
    const respond = (fetchResponse) =>
      frame.dispatchEvent(new CustomEvent('turbo:before-fetch-response', { detail: { fetchResponse } }));

    query(container, 'Se');
    respond({ succeeded: true, isHTML: true });
    expect(status()).toBe('Loading…');
    respond({ succeeded: false, isHTML: true });

    expect(status()).toBe('Results could not be loaded');
  });

  it('ignores a query from a nested combobox', async () => {
    const { frame } = await render();

    document
      .querySelector('#listbox')
      .dispatchEvent(new CustomEvent('combobox:query', { bubbles: true, detail: { query: 'Se' } }));
    vi.advanceTimersByTime(300);

    expect(frame.hasAttribute('src')).toBe(false);
  });

  it('cancels a pending query on disconnect', async () => {
    const { container, frame } = await render();

    query(container, 'Se');
    container.remove();
    await Promise.resolve();
    vi.advanceTimersByTime(300);

    expect(frame.hasAttribute('src')).toBe(false);
  });

  it('opens on loading and reports the replacement results', async () => {
    const { control, frame } = await render();

    type(control, 'Se');
    expect(document.querySelector('#panel').matches(':popover-open')).toBe(true);
    expect(status()).toBe('Loading…');

    frame.innerHTML = `
      <ul id="listbox" role="listbox" data-combobox-target="listbox">
        <li role="option" data-value="se">Seoul</li>
        <li role="option" data-value="sv">Seville</li>
      </ul>`;
    await Promise.resolve();

    expect(status()).toBe('');
    expect(document.querySelectorAll('[role="option"]:not([hidden])')).toHaveLength(2);
  });

  it('reports no results from an empty replacement', async () => {
    const { control, frame } = await render();

    type(control, 'zz');
    frame.innerHTML = '<ul id="listbox" role="listbox" data-combobox-target="listbox"></ul>';
    await Promise.resolve();

    expect(status()).toBe('No results');
  });
});
