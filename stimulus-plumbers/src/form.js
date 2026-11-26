// Dispatches `form:reset` on each control of a reset form once the browser has restored its value.
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
