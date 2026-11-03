import { Controller } from '@hotwired/stimulus';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ComboboxDatetimeController from '../../../src/controllers/combobox_datetime_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('ComboboxDatetimeController', () => {
  // Stands in for the calendar outlet.
  class Calendar extends Controller {
    focusTabStop() {
      this.element.querySelector('[tabindex="0"]').focus();
    }
  }

  const options = (name, values, selected) =>
    values
      .map(
        (value) =>
          `<li role="option" id="t_${name}_${value}" data-value="${value}" aria-selected="${value === selected}">${value}</li>`
      )
      .join('');

  const column = (name, values, selected) => `
    <ul role="listbox" tabindex="0" id="${name}" data-combobox-datetime-target="${name}"
        data-action="keydown->combobox-datetime#onNavigate click->combobox-datetime#onSelect">
      ${options(name, values, selected)}
    </ul>`;

  const render = async ({ value = '2026-11-03T14:30', availability = {}, calendarAttrs = '' } = {}) => {
    const [date, time] = value ? value.split('T') : [];
    const [hour, minute] = time ? time.split(':') : [];
    const values = Object.entries(availability)
      .map(([name, each]) => `data-combobox-datetime-${name}-value="${each}"`)
      .join(' ');
    document.body.innerHTML = `
      <form id="form">
        <div id="container" data-controller="combobox-datetime" data-combobox-datetime-calendar-outlet="#calendar" ${values}
             data-action="calendar:changed->combobox-datetime#onDateChange popover:before-open->combobox-datetime#onOpening popover:opened->combobox-datetime#onOpened popover:closed->combobox-datetime#onClosed focusout->combobox-datetime#onFocusout">
          <div id="group">
            <input id="trigger" readonly value="${value}" data-combobox-datetime-target="trigger"
                   data-action="keydown->combobox-datetime#onKeydown">
          </div>
          <input type="hidden" name="booking[at]" value="${value}" data-combobox-datetime-target="input">
          <div id="panel" popover="auto" data-combobox-datetime-target="panel"
               data-action="keydown.esc->combobox-datetime#onEscape">
            <div id="calendar" data-controller="calendar" data-combobox-datetime-target="calendar" ${date ? `data-calendar-selected-value="${date}"` : ''} ${calendarAttrs}>
              <table data-calendar-target="grid"><tr><td><button id="day" tabindex="0">3</button></td></tr></table>
            </div>
            ${column('hour', ['00', '01', '14'], hour)}
            ${column('minute', ['00', '30'], minute)}
          </div>
        </div>
      </form>`;
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await flush();
    return { panel, trigger: document.querySelector('#trigger'), input: document.querySelector('[type="hidden"]') };
  };

  const calendar = () => document.querySelector('#calendar');

  // The calendar marks its selection, then reports it.
  const selectDate = (value) => {
    calendar().setAttribute('data-calendar-selected-value', value);
    document
      .querySelector('#day')
      .dispatchEvent(new CustomEvent('calendar:changed', { bubbles: true, detail: { value } }));
  };

  const keydown = (element, key) =>
    element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));

  const open = (panel) => {
    panel.dispatchEvent(new CustomEvent('popover:before-open', { bubbles: true }));
    panel.showPopover();
    panel.dispatchEvent(new CustomEvent('popover:opened', { bubbles: true }));
  };

  const option = (name, value) => document.querySelector(`#t_${name}_${value}`);
  const disabled = (name, value) => option(name, value).getAttribute('aria-disabled') === 'true';

  beforeEach(() => {
    Element.prototype.scrollIntoView = vi.fn();
    startApplication({ calendar: Calendar, 'combobox-datetime': ComboboxDatetimeController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete Element.prototype.scrollIntoView;
  });

  it('ArrowDown focuses the calendar Tab stop', async () => {
    const { trigger } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(document.activeElement.id).toBe('day');
  });

  it('fills the input once a date and a time are selected', async () => {
    const { panel, input } = await render({ value: '' });
    open(panel);

    selectDate('2026-11-03');
    expect(input.value).toBe('');

    option('hour', '14').click();
    option('minute', '30').click();
    expect(input.value).toBe('2026-11-03T14:30');
  });

  it('a new date keeps the time, updates the input, and leaves the panel open', async () => {
    const { panel, input } = await render();
    open(panel);

    selectDate('2026-11-04');

    expect(input.value).toBe('2026-11-04T14:30');
    expect(panel.matches(':popover-open')).toBe(true);
  });

  it('min and max limit the times on their own dates', async () => {
    const { panel } = await render({ availability: { min: '2026-11-03T14:00' } });
    open(panel);
    expect(disabled('hour', '01')).toBe(true);
    expect(disabled('hour', '14')).toBe(false);

    selectDate('2026-11-04');

    expect(disabled('hour', '01')).toBe(false);
  });

  it('a wrapped daily window is trimmed at min on its date only', async () => {
    const { panel } = await render({
      availability: { min: '2026-11-03T01:00', 'time-min': '14:00', 'time-max': '01:30' },
    });
    open(panel);
    expect(disabled('hour', '00')).toBe(true);
    expect(disabled('hour', '01')).toBe(false);
    expect(disabled('hour', '14')).toBe(false);

    selectDate('2026-11-04');

    expect(disabled('hour', '00')).toBe(false);
  });

  it('the daily window limits the times before a date is selected', async () => {
    await render({ value: '', availability: { 'time-min': '14:00' } });

    expect(disabled('hour', '01')).toBe(true);
    expect(disabled('hour', '14')).toBe(false);
  });

  it('a date that makes the selected time unavailable keeps it selected and leaves the input unchanged', async () => {
    const { panel, input } = await render({ value: '2026-11-04T01:30', availability: { min: '2026-11-03T14:00' } });
    open(panel);

    selectDate('2026-11-03');

    expect(disabled('hour', '01')).toBe(true);
    expect(option('hour', '01').getAttribute('aria-selected')).toBe('true');
    expect(input.value).toBe('2026-11-04T01:30');
  });

  it('closing the panel discards a date that made the selected time unavailable', async () => {
    const { panel, input } = await render({ value: '2026-11-04T01:30', availability: { min: '2026-11-03T14:00' } });
    open(panel);
    selectDate('2026-11-03');

    panel.hidePopover();
    panel.dispatchEvent(new CustomEvent('popover:closed', { bubbles: true }));

    expect(input.value).toBe('2026-11-04T01:30');
    expect(calendar().getAttribute('data-calendar-selected-value')).toBe('2026-11-04');
    expect(disabled('hour', '01')).toBe(false);
  });

  it('closing the panel discards a date with no time selected', async () => {
    const { panel, input } = await render({ value: '' });
    open(panel);
    selectDate('2026-11-04');

    panel.hidePopover();
    panel.dispatchEvent(new CustomEvent('popover:closed', { bubbles: true }));

    expect(input.value).toBe('');
    expect(calendar().hasAttribute('data-calendar-selected-value')).toBe(false);
  });

  it('Escape in the calendar restores the date and time from opening', async () => {
    const { panel, trigger, input } = await render();
    open(panel);
    selectDate('2026-11-04');

    keydown(document.querySelector('#day'), 'Escape');

    expect(input.value).toBe('2026-11-03T14:30');
    expect(calendar().getAttribute('data-calendar-selected-value')).toBe('2026-11-03');
    expect(panel.matches(':popover-open')).toBe(false);
    expect(document.activeElement).toBe(trigger);
  });

  it('form reset restores the initial date and time', async () => {
    const { panel, input } = await render();
    open(panel);
    selectDate('2026-11-04');

    document.querySelector('#form').reset();
    await flush();

    expect(input.value).toBe('2026-11-03T14:30');
    expect(calendar().getAttribute('data-calendar-selected-value')).toBe('2026-11-03');
  });

  it('a time change on an unavailable date leaves the input unchanged', async () => {
    const { panel, input } = await render({ value: '2026-11-02T14:30', availability: { min: '2026-11-03T00:00' } });
    open(panel);

    option('minute', '00').click();

    expect(input.value).toBe('2026-11-02T14:30');
  });

  it('gives the calendar the dates that still have a time', async () => {
    await render({
      availability: { min: '2026-11-03T23:30', 'time-max': '22:00', 'disabled-weekdays': '[0]' },
      calendarAttrs: 'data-calendar-max-value="2026-12-31"',
    });

    expect(calendar().getAttribute('data-calendar-min-value')).toBe('2026-11-03');
    expect(calendar().getAttribute('data-calendar-disabled-dates-value')).toBe('["2026-11-03"]');
    expect(calendar().getAttribute('data-calendar-disabled-weekdays-value')).toBe('[0]');
    expect(calendar().hasAttribute('data-calendar-max-value')).toBe(false);
  });

  it('a time change with unusable availability fills the input', async () => {
    const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});
    const { panel, input } = await render({ availability: { min: 'nope' } });
    open(panel);

    option('minute', '00').click();

    expect(input.value).toBe('2026-11-03T14:00');
    consoleError.mockRestore();
  });

  it("reports unusable availability and leaves the calendar's values as rendered", async () => {
    const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});

    await render({
      availability: { min: '2026-11-04T00:00', max: '2026-11-03T00:00' },
      calendarAttrs: 'data-calendar-min-value="2026-11-01"',
    });

    expect(consoleError).toHaveBeenCalledWith(expect.stringContaining('min is after max'));
    expect(calendar().getAttribute('data-calendar-min-value')).toBe('2026-11-01');
    consoleError.mockRestore();
  });
});
