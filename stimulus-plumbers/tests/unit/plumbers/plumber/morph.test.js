import { describe, it, expect, beforeEach, vi } from 'vitest';
import { onMorph } from '../../../../src/plumbers/plumber/morph';

const morphed = (element) =>
  element.dispatchEvent(new CustomEvent('turbo:morph-element', { bubbles: true }));

describe('onMorph', () => {
  let root;
  let child;

  beforeEach(() => {
    document.body.innerHTML = '<div id="root"><span id="child"></span></div>';
    root = document.getElementById('root');
    child = document.getElementById('child');
  });

  it('runs once after a morph that touches several nodes', async () => {
    const callback = vi.fn();
    onMorph(root, callback);

    morphed(child);
    morphed(root);
    expect(callback).not.toHaveBeenCalled();
    await Promise.resolve();

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('runs again for a later morph', async () => {
    const callback = vi.fn();
    onMorph(root, callback);

    morphed(root);
    await Promise.resolve();
    morphed(child);
    await Promise.resolve();

    expect(callback).toHaveBeenCalledTimes(2);
  });

  it('ignores morphs outside the element', async () => {
    const callback = vi.fn();
    onMorph(root, callback);

    morphed(document.body);
    await Promise.resolve();

    expect(callback).not.toHaveBeenCalled();
  });

  it('stops listening once the signal aborts', async () => {
    const callback = vi.fn();
    const connection = new AbortController();
    onMorph(root, callback, { signal: connection.signal });

    connection.abort();
    morphed(root);
    await Promise.resolve();

    expect(callback).not.toHaveBeenCalled();
  });

  it('drops a pending run when the signal aborts before it', async () => {
    const callback = vi.fn();
    const connection = new AbortController();
    onMorph(root, callback, { signal: connection.signal });

    morphed(root);
    connection.abort();
    await Promise.resolve();

    expect(callback).not.toHaveBeenCalled();
  });
});
