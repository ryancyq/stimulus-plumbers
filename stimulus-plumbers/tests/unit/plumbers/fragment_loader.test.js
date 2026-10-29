import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { attachFragmentLoader } from '../../../src/plumbers/fragment_loader';
import { autoDisconnect, flush } from '../../support/stimulus';

describe('FragmentLoader', () => {
  let requests;
  let controller;

  // Resolves on demand; rejects with AbortError when aborted, like fetch.
  const stubFetch = () => {
    requests = [];
    vi.stubGlobal(
      'fetch',
      vi.fn(
        (url, { headers, signal }) =>
          new Promise((resolve, reject) => {
            requests.push({ url: String(url), headers, resolve });
            signal.addEventListener('abort', () => reject(new DOMException('Aborted', 'AbortError')));
          })
      )
    );
  };
  const respond = async (index, body, ok = true) => {
    requests[index].resolve({ ok, status: ok ? 200 : 500, text: async () => body });
    await flush();
  };
  const region = (text) => `<div id="region"><p>${text}</p></div>`;

  beforeEach(() => {
    stubFetch();
    document.body.innerHTML = `<div id="root">${region('Placeholder')}</div>`;
    controller = { element: document.querySelector('#root') };
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.unstubAllGlobals();
  });

  const attach = (element = document.querySelector('#region')) =>
    autoDisconnect(attachFragmentLoader(controller, { element }));

  it('swaps in the response element with the same id', async () => {
    const loader = attach();
    const loading = loader.load('/region');

    expect(document.querySelector('#region').getAttribute('aria-busy')).toBe('true');
    expect(loader.busy).toBe(true);
    expect(requests[0].headers).toEqual({ Accept: 'text/html' });

    await respond(0, `<main>${region('Loaded')}</main>`);
    const replacement = await loading;

    expect(replacement).toBe(document.querySelector('#region'));
    expect(replacement.textContent).toBe('Loaded');
    expect(replacement.hasAttribute('aria-busy')).toBe(false);
    expect(loader.element).toBe(replacement);
    expect(loader.busy).toBe(false);
  });

  it('loads into the swapped-in element next time', async () => {
    const loader = attach();
    const first = loader.load('/region');
    await respond(0, region('First'));
    await first;

    const second = loader.load('/region');
    await respond(1, region('Second'));

    expect((await second).textContent).toBe('Second');
  });

  it('cancels a load when a newer one starts', async () => {
    const loader = attach();
    const older = loader.load('/region?q=a');
    const newer = loader.load('/region?q=ab');

    expect(await older).toBeNull();
    await respond(1, region('ab'));

    expect((await newer).textContent).toBe('ab');
  });

  it('cancel() drops the load and clears the busy state', async () => {
    const loader = attach();
    const loading = loader.load('/region');

    loader.cancel();

    expect(await loading).toBeNull();
    expect(document.querySelector('#region').hasAttribute('aria-busy')).toBe(false);
    expect(document.querySelector('#region').textContent).toBe('Placeholder');
  });

  it('rejects a failed response and keeps the current element', async () => {
    const loader = attach();
    const failed = expect(loader.load('/region')).rejects.toThrow('500');
    await respond(0, 'Server error', false);

    await failed;
    expect(document.querySelector('#region').textContent).toBe('Placeholder');
    expect(document.querySelector('#region').hasAttribute('aria-busy')).toBe(false);
  });

  it('rejects a response without a matching element', async () => {
    const loader = attach();
    const failed = expect(loader.load('/region')).rejects.toThrow('Response has no #region');
    await respond(0, '<div id="other"></div>');

    await failed;
  });

  it('rejects another origin without requesting it', async () => {
    const loader = attach();

    await expect(loader.load('https://elsewhere.example/region')).rejects.toThrow('is not the page origin');
    expect(requests).toHaveLength(0);
  });

  it('is inert for a target without an id or for the controller element', async () => {
    document.querySelector('#region').removeAttribute('id');

    expect(await attach(document.querySelector('#root > div')).load('/region')).toBeNull();
    expect(await attach(controller.element).load('/region')).toBeNull();
    expect(await attach(null).load('/region')).toBeNull();
    expect(requests).toHaveLength(0);
  });

  it('disconnect() cancels the load and leaves the loader inert', async () => {
    const loader = attach();
    const loading = loader.load('/region');

    loader.disconnect();

    expect(await loading).toBeNull();
    expect(await loader.load('/region')).toBeNull();
    expect(requests).toHaveLength(1);
  });
});
