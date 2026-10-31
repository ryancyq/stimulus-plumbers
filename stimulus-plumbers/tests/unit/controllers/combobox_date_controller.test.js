import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ComboboxDateController from '../../../src/controllers/combobox_date_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('ComboboxDateController', () => {
  const render = async () => {
    document.body.innerHTML = `
      <form id="form">
        <div id="root" data-controller="combobox-date" data-action="calendar:changed->combobox-date#onChange focusout->combobox-date#onFocusout mousedown->combobox-date#onMousedown click->combobox-date#onClick">
          <div id="group">
            <span id="icon" aria-hidden="true"></span>
            <input id="trigger" readonly value="2026-09-15" data-combobox-date-target="trigger"
                   data-action="keydown->combobox-date#onKeydown">
          </div>
          <input type="hidden" name="person[birthday]" value="2026-09-15" data-combobox-date-target="input">
          <div id="panel" popover="auto" data-combobox-date-target="panel">
            <a href="#" id="previous">Previous month</a>
            <section id="calendar">
              <table data-calendar-target="grid">
                <tr>
                  <td><button tabindex="-1" data-date="2026-09-14">14</button></td>
                  <td><button tabindex="0" data-date="2026-09-15">15</button></td>
                </tr>
              </table>
            </section>
          </div>
        </div>
      </form>`;
    const root = document.querySelector('#root');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await flush();
    return {
      root,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('[type="hidden"]'),
    };
  };

  const keydown = (element, key) =>
    element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));

  const change = (target, value) =>
    target.dispatchEvent(
      new CustomEvent('calendar:changed', { bubbles: true, detail: { value, previousValue: null } })
    );

  beforeEach(() => {
    startApplication({ 'combobox-date': ComboboxDateController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('ArrowDown focuses the calendar Tab stop', async () => {
    const { trigger } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(document.activeElement.dataset.date).toBe('2026-09-15');
  });

  it('commits the chosen date, closes the panel, and focuses the trigger', async () => {
    const { root, panel, trigger, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    root.addEventListener('combobox-date:changed', (event) => formatted(event.detail.value));
    panel.showPopover();

    change(document.querySelector('#calendar'), '2026-09-14');

    expect(input.value).toBe('2026-09-14');
    expect(changed).toHaveBeenCalledOnce();
    expect(formatted).toHaveBeenCalledWith('2026-09-14');
    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(document.activeElement).toBe(trigger);
  });

  it('choosing the committed date reports it without a change event', async () => {
    const { root, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    root.addEventListener('combobox-date:changed', (event) => formatted(event.detail.value));

    change(document.querySelector('#calendar'), '2026-09-15');

    expect(formatted).toHaveBeenCalledWith('2026-09-15');
    expect(changed).not.toHaveBeenCalled();
  });

  it('form reset reports the restored date', async () => {
    const { root, input } = await render();
    const formatted = vi.fn();
    root.addEventListener('combobox-date:changed', (event) => formatted(event.detail.value));
    input.value = '2026-09-14';

    document.querySelector('#form').reset();
    await flush();

    expect(formatted).toHaveBeenCalledWith('2026-09-15');
  });

  it('ignores a nested combobox date', async () => {
    const { input } = await render();
    document
      .querySelector('#calendar')
      .insertAdjacentHTML(
        'beforeend',
        '<div data-controller="combobox-date"><input type="hidden" data-combobox-date-target="input"><span id="inner"></span></div>'
      );

    change(document.querySelector('#inner'), '2026-09-14');

    expect(input.value).toBe('2026-09-15');
  });
});
