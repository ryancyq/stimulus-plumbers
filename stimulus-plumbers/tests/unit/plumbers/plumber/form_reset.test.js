import { describe, it, expect, beforeEach, vi } from 'vitest';
import { onFormReset } from '../../../../src/plumbers/plumber/form_reset';
import { flush } from '../../../support/stimulus';

describe('onFormReset', () => {
  let form;
  let input;

  beforeEach(() => {
    document.body.innerHTML = '<form><input value="initial"></form>';
    form = document.querySelector('form');
    input = document.querySelector('input');
  });

  it('runs once the form controls hold their reset values', async () => {
    const callback = vi.fn(() => input.value);
    onFormReset(input, callback);

    input.value = 'edited';
    form.reset();
    expect(callback).not.toHaveBeenCalled();
    await flush();

    expect(callback).toHaveReturnedWith('initial');
  });

  it('skips a cancelled reset', async () => {
    const callback = vi.fn();
    onFormReset(input, callback);
    form.addEventListener('reset', (event) => event.preventDefault());

    form.reset();
    await flush();

    expect(callback).not.toHaveBeenCalled();
  });

  it('does nothing outside a form', () => {
    const callback = vi.fn();
    document.body.innerHTML = '<div><input></div>';

    expect(() => onFormReset(document.querySelector('input'), callback)).not.toThrow();
  });

  it('stops listening once the signal aborts', async () => {
    const callback = vi.fn();
    const connection = new AbortController();
    onFormReset(input, callback, { signal: connection.signal });

    connection.abort();
    form.reset();
    await flush();

    expect(callback).not.toHaveBeenCalled();
  });

  it('drops a pending run when the signal aborts before it', async () => {
    const callback = vi.fn();
    const connection = new AbortController();
    onFormReset(input, callback, { signal: connection.signal });

    form.reset();
    connection.abort();
    await flush();

    expect(callback).not.toHaveBeenCalled();
  });
});
