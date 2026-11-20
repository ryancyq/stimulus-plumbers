// Installed once on import: after a native reset restores a form's controls, dispatches a non-bubbling
// `form:reset` on each of them, unless the reset was cancelled.
const INSTALLED = Symbol.for('stimulus-plumbers.form');

function dispatchFormReset(event) {
  const form = event.target;
  if (!(form instanceof HTMLFormElement)) return;

  setTimeout(() => {
    if (event.defaultPrevented || !form.isConnected) return;
    [...form.elements].forEach((control) => control.dispatchEvent(new CustomEvent('form:reset')));
  });
}

if (typeof document !== 'undefined' && !document[INSTALLED]) {
  document[INSTALLED] = true;
  document.addEventListener('reset', dispatchFormReset, true);
}
