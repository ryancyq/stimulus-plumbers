/**
 * Calls `callback` after the native reset of `element`'s form, once the form controls hold their
 * reset values. Skips a reset whose event was cancelled.
 * @param {HTMLElement} element - Element inside the form
 * @param {Function} callback - Runs after the reset completes
 * @param {{ signal?: AbortSignal }} [options] - Aborting `signal` removes the listener and drops a pending run
 */
export function onFormReset(element, callback, { signal } = {}) {
  element
    .closest('form')
    ?.addEventListener('reset', (event) => setTimeout(() => signal?.aborted || event.defaultPrevented || callback()), {
      signal,
    });
}
