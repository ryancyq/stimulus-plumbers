import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ComboboxTimeController from '../../../src/controllers/combobox_time_controller';
import { installNativePopover } from '../../support/native_popover';

describe('ComboboxTimeController', () => {
  let application;

  const options = (name, values, selected) =>
    values
      .map(
        (value) =>
          `<li role="option" id="t_${name}_${value}" data-value="${value}" aria-selected="${value === selected}">${value}</li>`
      )
      .join('');

  const column = (name, values, selected) => `
    <ul role="listbox" tabindex="0" id="${name}" data-combobox-time-target="${name}"
        data-action="keydown->combobox-time#onNavigate click->combobox-time#onSelect">
      ${options(name, values, selected)}
    </ul>`;

  const render = async ({ value = '14:30', twelveHour = true } = {}) => {
    const [hour, minute] = value ? value.split(':').map(Number) : [];
    const hourValue = value && (twelveHour ? String(((hour + 11) % 12) + 1) : String(hour).padStart(2, '0'));
    document.body.innerHTML = `
      <form id="form">
        <div id="container" data-controller="combobox-time"
             data-action="popover:before-open->combobox-time#onOpening popover:opened->combobox-time#onOpened focusout->combobox-time#onFocusout mousedown->combobox-time#onMousedown click->combobox-time#onClick">
          <div id="group">
            <span id="icon" aria-hidden="true"></span>
            <input id="trigger" readonly value="${value}" data-combobox-time-target="trigger"
                   data-action="keydown->combobox-time#onKeydown">
          </div>
          <input type="hidden" name="meeting[at]" value="${value}" data-combobox-time-target="input">
          <div id="panel" popover="auto" data-combobox-time-target="panel">
            ${column('hour', twelveHour ? ['12', '1', '2'] : ['00', '01', '14'], hourValue)}
            ${column('minute', ['00', '30'], value && String(minute).padStart(2, '0'))}
            ${twelveHour ? column('meridiem', ['AM', 'PM'], value && (hour < 12 ? 'AM' : 'PM')) : ''}
          </div>
        </div>
      </form>`;
    const container = document.querySelector('#container');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'combobox-time'));
    return {
      container,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('[type="hidden"]'),
    };
  };

  const keydown = (element, key) => {
    const event = new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true });
    element.dispatchEvent(event);
    return event;
  };

  const lifecycle = (panel, name) => panel.dispatchEvent(new CustomEvent(`popover:${name}`, { bubbles: true }));

  const open = (panel) => {
    lifecycle(panel, 'before-open');
    panel.showPopover();
    lifecycle(panel, 'opened');
  };

  const option = (name, value) => document.querySelector(`#t_${name}_${value}`);

  beforeEach(() => {
    Element.prototype.scrollIntoView = vi.fn();
    application = Application.start();
    application.register('combobox-time', ComboboxTimeController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    delete Element.prototype.scrollIntoView;
  });

  it('ArrowDown opens the panel and focuses the hour column', async () => {
    const { panel, trigger } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(document.activeElement.id).toBe('hour');
  });

  it('each selection updates the input and reports the time', async () => {
    const { container, panel, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    container.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
    open(panel);

    option('minute', '00').click();

    expect(input.value).toBe('14:00');
    expect(changed).toHaveBeenCalledOnce();
    expect(formatted).toHaveBeenCalledWith('14:00');
    expect(panel.hidePopover).not.toHaveBeenCalled();
  });

  it('the AM/PM column sets the 24-hour value', async () => {
    const { panel, input } = await render();
    open(panel);

    option('hour', '12').click();
    expect(input.value).toBe('12:30');

    option('meridiem', 'AM').click();
    expect(input.value).toBe('00:30');
  });

  it('a 24-hour time has no AM/PM column', async () => {
    const { panel, input } = await render({ twelveHour: false });
    open(panel);

    option('hour', '01').click();

    expect(input.value).toBe('01:30');
  });

  it('waits for the hour and minute before selecting', async () => {
    const { panel, input } = await render({ value: '' });
    open(panel);

    option('hour', '2').click();
    option('meridiem', 'PM').click();
    expect(input.value).toBe('');

    option('minute', '30').click();
    expect(input.value).toBe('14:30');
  });

  it('arrows, Home, and End move the selected option within the column', async () => {
    const { panel } = await render();
    const hour = document.querySelector('#hour');
    open(panel);

    keydown(hour, 'ArrowDown');
    expect(hour.getAttribute('aria-activedescendant')).toBe('t_hour_2');

    keydown(hour, 'Home');
    expect(option('hour', '12').getAttribute('aria-selected')).toBe('true');
    expect(hour.getAttribute('aria-activedescendant')).toBe('t_hour_12');

    keydown(hour, 'ArrowUp');
    expect(hour.getAttribute('aria-activedescendant')).toBe('t_hour_12');

    keydown(hour, 'End');
    expect(hour.querySelectorAll('[aria-selected="true"]')).toHaveLength(1);
    expect(hour.getAttribute('aria-activedescendant')).toBe('t_hour_2');
  });

  it('ArrowUp in a column with nothing selected starts at the last option', async () => {
    const { panel } = await render({ value: '' });
    const hour = document.querySelector('#hour');
    open(panel);

    keydown(hour, 'ArrowUp');

    expect(hour.getAttribute('aria-activedescendant')).toBe('t_hour_2');
  });

  it('Enter closes the panel, keeps the time, and focuses the trigger', async () => {
    const { panel, trigger, input } = await render();
    open(panel);
    option('minute', '00').click();

    keydown(document.querySelector('#minute'), 'Enter');

    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(input.value).toBe('14:00');
    expect(document.activeElement).toBe(trigger);
  });

  it('Escape restores the time from opening, closes the panel, and focuses the trigger', async () => {
    const { container, panel, trigger, input } = await render();
    const formatted = vi.fn();
    container.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
    open(panel);
    option('minute', '00').click();

    const event = keydown(document.querySelector('#minute'), 'Escape');

    expect(event.defaultPrevented).toBe(true);
    expect(input.value).toBe('14:30');
    expect(formatted).toHaveBeenLastCalledWith('14:30');
    expect(option('minute', '30').getAttribute('aria-selected')).toBe('true');
    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(document.activeElement).toBe(trigger);
  });

  it('Escape restores the time before the opened event arrives', async () => {
    const { panel, trigger, input } = await render();
    lifecycle(panel, 'before-open');
    panel.showPopover();
    option('minute', '00').click();

    keydown(trigger, 'Escape');

    expect(input.value).toBe('14:30');
  });

  it('Escape from the trigger restores the time too', async () => {
    const { panel, trigger, input } = await render();
    open(panel);
    option('minute', '00').click();

    keydown(trigger, 'Escape');

    expect(input.value).toBe('14:30');
  });

  it('leaves Escape alone while the panel is closed', async () => {
    const { trigger } = await render();

    expect(keydown(trigger, 'Escape').defaultPrevented).toBe(false);
  });

  it('Tab from the trigger closes an open panel', async () => {
    const { panel, trigger } = await render();
    open(panel);

    keydown(trigger, 'Tab');

    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('closes the panel and keeps the time when focus leaves the combobox', async () => {
    const { panel, input } = await render();
    document.body.insertAdjacentHTML('beforeend', '<button id="next">Next</button>');
    open(panel);
    option('minute', '00').click();
    document.querySelector('#minute').focus();

    document.querySelector('#next').focus();

    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(input.value).toBe('14:00');
  });

  it('a click on an icon opens the panel and focuses the trigger', async () => {
    const { panel, trigger } = await render();
    const icon = document.querySelector('#icon');
    const mousedown = new MouseEvent('mousedown', { bubbles: true, cancelable: true });

    icon.dispatchEvent(mousedown);
    icon.click();

    expect(mousedown.defaultPrevented).toBe(true);
    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(document.activeElement).toBe(trigger);
  });

  it('form reset restores the initial time and options', async () => {
    const { container, panel, input } = await render();
    const formatted = vi.fn();
    container.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
    open(panel);
    option('minute', '00').click();

    document.querySelector('#form').reset();

    await vi.waitFor(() => expect(formatted).toHaveBeenLastCalledWith('14:30'));
    expect(input.value).toBe('14:30');
    expect(option('minute', '30').getAttribute('aria-selected')).toBe('true');
  });
});
