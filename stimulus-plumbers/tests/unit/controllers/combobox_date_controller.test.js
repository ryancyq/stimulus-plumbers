import { Controller } from '@hotwired/stimulus';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ComboboxDateController from '../../../src/controllers/combobox_date_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('ComboboxDateController', () => {
  // Stands in for the calendar outlet.
  class Calendar extends Controller {
    static values = { selected: String };

    focusTabStop() {
      this.element.querySelector('[tabindex="0"]').focus();
    }
  }

  const render = async () => {
    document.body.innerHTML = `
      <form id="form">
        <div id="container" data-controller="combobox-date" data-combobox-date-calendar-outlet="#calendar" data-action="calendar:changed->combobox-date#onChange popover:before-open->combobox-date#onOpening focusout->combobox-date#onFocusout mousedown->combobox-date#onMousedown click->combobox-date#onClick">
          <div id="group">
            <span id="icon" aria-hidden="true"></span>
            <input id="trigger" readonly value="2026-09-15" data-combobox-date-target="trigger"
                   data-action="keydown->combobox-date#onKeydown">
          </div>
          <input type="text" hidden readonly name="person[birthday]" value="2026-09-15" data-combobox-date-target="input"
                 data-action="form:reset->combobox-date#onFormReset">
          <div id="panel" popover="auto" data-combobox-date-target="panel">
            <a href="#" id="previous">Previous month</a>
            <section id="calendar" data-controller="calendar">
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
    const container = document.querySelector('#container');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await flush();
    return {
      container,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('[data-combobox-date-target="input"]'),
    };
  };

  const keydown = (element, key) =>
    element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));

  const change = (target, value) =>
    target.dispatchEvent(
      new CustomEvent('calendar:changed', { bubbles: true, detail: { value, previousValue: null } })
    );

  beforeEach(() => {
    startApplication({ calendar: Calendar, 'combobox-date': ComboboxDateController });
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

  it('writes the calendar date, closes the panel, and focuses the trigger', async () => {
    const { container, panel, trigger, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    container.addEventListener('combobox-date:changed', (event) => formatted(event.detail.value));
    panel.showPopover();

    change(document.querySelector('#calendar'), '2026-09-14');

    expect(input.value).toBe('2026-09-14');
    expect(changed).toHaveBeenCalledOnce();
    expect(formatted).toHaveBeenCalledWith('2026-09-14');
    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(document.activeElement).toBe(trigger);
  });

  it('a new date dispatches input, change, and changed in order', async () => {
    const { container, input } = await render();
    const events = [];
    input.addEventListener('input', () => events.push('input'));
    input.addEventListener('change', () => events.push('change'));
    container.addEventListener('combobox-date:changed', () => events.push('changed'));

    change(document.querySelector('#calendar'), '2026-09-14');

    expect(events).toEqual(['input', 'change', 'changed']);
  });

  it('selecting the selected date reports it without a change event', async () => {
    const { container, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    container.addEventListener('combobox-date:changed', (event) => formatted(event.detail.value));

    change(document.querySelector('#calendar'), '2026-09-15');

    expect(formatted).toHaveBeenCalledWith('2026-09-15');
    expect(changed).not.toHaveBeenCalled();
  });

  it('opening selects the input date in the calendar', async () => {
    const { panel, input } = await render();
    input.value = '2026-09-14';

    panel.dispatchEvent(new CustomEvent('popover:before-open', { bubbles: true }));

    expect(document.querySelector('#calendar').getAttribute('data-calendar-selected-value')).toBe('2026-09-14');
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
