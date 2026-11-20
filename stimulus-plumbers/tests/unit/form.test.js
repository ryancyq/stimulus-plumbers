import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import '../../src/form';
import { flush } from '../support/stimulus';

describe('form:reset', () => {
  let form;
  let received;

  const listen = (selector) =>
    document.querySelector(selector).addEventListener('form:reset', (event) => received.push(event));

  beforeEach(() => {
    document.body.innerHTML = `
      <form id="form"><input id="inside" value="initial"><select id="choice"><option>a</option></select></form>
      <input id="outside" form="form">
      <input id="unrelated">`;
    form = document.querySelector('#form');
    received = [];
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('is dispatched on each control once the reset values are restored', async () => {
    const values = [];
    const input = document.querySelector('#inside');
    input.addEventListener('form:reset', () => values.push(input.value));
    listen('#choice');

    input.value = 'edited';
    form.reset();
    expect(values).toEqual([]);
    await flush();

    expect(values).toEqual(['initial']);
    expect(received).toHaveLength(1);
  });

  it('is dispatched on a control associated through the form attribute', async () => {
    listen('#outside');
    listen('#unrelated');

    form.reset();
    await flush();

    expect(received.map((event) => event.target.id)).toEqual(['outside']);
  });

  it('does not bubble', async () => {
    const onForm = vi.fn();
    form.addEventListener('form:reset', onForm);

    form.reset();
    await flush();

    expect(onForm).not.toHaveBeenCalled();
  });

  it('is not dispatched for a cancelled reset', async () => {
    listen('#inside');
    form.addEventListener('reset', (event) => event.preventDefault());

    form.reset();
    await flush();

    expect(received).toEqual([]);
  });

  it('is not dispatched once the form is removed', async () => {
    listen('#inside');

    form.reset();
    form.remove();
    await flush();

    expect(received).toEqual([]);
  });
});
