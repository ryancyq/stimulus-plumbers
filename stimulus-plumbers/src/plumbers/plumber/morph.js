/**
 * Calls `callback` once after each Turbo morph that reaches `element` or its descendants.
 * Coalesces one morph's `turbo:morph-element` events into one microtask run; listens by event
 * name, without importing Turbo.
 * @param {HTMLElement} element - Element whose subtree is watched
 * @param {Function} callback - Runs after the morph completes
 * @param {{ signal?: AbortSignal }} [options] - Aborting `signal` removes the listener and drops a pending run
 */
export function onMorph(element, callback, { signal } = {}) {
  let pending = false;
  element.addEventListener(
    'turbo:morph-element',
    () => {
      if (pending) return;
      pending = true;
      queueMicrotask(() => {
        pending = false;
        if (!signal?.aborted) callback();
      });
    },
    { signal }
  );
}
