import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import ComboboxTimeController from '../../../src/controllers/combobox_time_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('ComboboxTimeController', () => {
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

  const render = async ({ value = '14:30', twelveHour = true, availability = {} } = {}) => {
    const [hour, minute] = value ? value.split(':').map(Number) : [];
    const hourValue = value && (twelveHour ? String(((hour + 11) % 12) + 1) : String(hour).padStart(2, '0'));
    document.body.innerHTML = `
      <form id="form">
        <div id="root" data-controller="combobox-time" ${values(availability)}
             data-action="popover:before-open->combobox-time#onOpening popover:opened->combobox-time#onOpened popover:closed->combobox-time#onClosed focusout->combobox-time#onFocusout mousedown->combobox-time#onMousedown click->combobox-time#onClick">
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

  const values = (availability) =>
    Object.entries(availability)
      .map(([name, value]) => `data-combobox-time-${name}-value="${value}"`)
      .join(' ');

  const disabled = (name, value) => option(name, value).getAttribute('aria-disabled') === 'true';
  const chosen = (name, value) => option(name, value).getAttribute('aria-selected') === 'true';

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
    startApplication({ 'combobox-time': ComboboxTimeController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete Element.prototype.scrollIntoView;
  });

  it('ArrowDown focuses the hour column', async () => {
    const { trigger } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(document.activeElement.id).toBe('hour');
  });

  it('each choice commits the time and reports it', async () => {
    const { root, panel, input } = await render();
    const changed = vi.fn();
    const formatted = vi.fn();
    input.addEventListener('change', changed);
    root.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
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

  it('waits for the hour and minute before committing', async () => {
    const { panel, input } = await render({ value: '' });
    open(panel);

    option('hour', '2').click();
    option('meridiem', 'PM').click();
    expect(input.value).toBe('');

    option('minute', '30').click();
    expect(input.value).toBe('14:30');
  });

  it('arrows, Home, and End move the chosen option within the column', async () => {
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

  it('ArrowUp in a column with nothing chosen starts at the last option', async () => {
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
    const { root, panel, trigger, input } = await render();
    const formatted = vi.fn();
    root.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
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

  it('focus leaving the combobox keeps the chosen time', async () => {
    const { panel, input } = await render();
    document.body.insertAdjacentHTML('beforeend', '<button id="next">Next</button>');
    open(panel);
    option('minute', '00').click();
    document.querySelector('#minute').focus();

    document.querySelector('#next').focus();

    expect(input.value).toBe('14:00');
  });

  it('form reset restores the initial time and options', async () => {
    const { root, panel, input } = await render();
    const formatted = vi.fn();
    root.addEventListener('combobox-time:changed', (event) => formatted(event.detail.value));
    open(panel);
    option('minute', '00').click();

    document.querySelector('#form').reset();
    await flush();

    expect(formatted).toHaveBeenLastCalledWith('14:30');
    expect(input.value).toBe('14:30');
    expect(option('minute', '30').getAttribute('aria-selected')).toBe('true');
  });

  describe('availability', () => {
    it('marks the times outside min–max unavailable', async () => {
      await render({ value: '', twelveHour: false, availability: { min: '01:00', max: '14:00' } });

      expect(disabled('hour', '00')).toBe(true);
      expect(disabled('hour', '01')).toBe(false);
      expect(disabled('hour', '14')).toBe(false);
      expect(disabled('minute', '30')).toBe(false);
    });

    it('the chosen hour limits the minutes', async () => {
      const { panel } = await render({ value: '', twelveHour: false, availability: { max: '14:00' } });
      open(panel);

      option('hour', '14').click();

      expect(disabled('minute', '00')).toBe(false);
      expect(disabled('minute', '30')).toBe(true);
    });

    it('the chosen AM or PM limits the hours, and hours never limit it', async () => {
      const { panel } = await render({ value: '', availability: { max: '13:00' } });
      open(panel);
      expect(disabled('hour', '2')).toBe(false);

      option('meridiem', 'PM').click();

      expect(disabled('hour', '2')).toBe(true);
      expect(disabled('hour', '1')).toBe(false);
      expect(disabled('meridiem', 'AM')).toBe(false);
    });

    it('AM or PM with no available time is unavailable', async () => {
      await render({ value: '', availability: { min: '13:00' } });

      expect(disabled('meridiem', 'AM')).toBe(true);
      expect(disabled('meridiem', 'PM')).toBe(false);
    });

    it('a min after max wraps past midnight', async () => {
      await render({ value: '', availability: { min: '22:00', max: '01:00' } });

      expect(disabled('meridiem', 'AM')).toBe(false);
      expect(disabled('meridiem', 'PM')).toBe(false);
      expect(disabled('hour', '1')).toBe(false);
      expect(disabled('hour', '2')).toBe(true);
    });

    it('a window that wraps past midnight limits 12-hour choices by AM or PM', async () => {
      await render({ value: '00:30', availability: { min: '22:00', max: '01:00' } });

      expect(disabled('hour', '12')).toBe(false);
      expect(disabled('hour', '1')).toBe(false);
      expect(disabled('hour', '2')).toBe(true);
      expect(disabled('meridiem', 'AM')).toBe(false);
      expect(disabled('meridiem', 'PM')).toBe(false);

      option('meridiem', 'PM').click();

      expect(disabled('hour', '12')).toBe(true);
    });

    it('arrows, Home, and End skip unavailable options', async () => {
      const { panel } = await render({ value: '', twelveHour: false, availability: { min: '01:00', max: '01:30' } });
      const hour = document.querySelector('#hour');
      open(panel);

      keydown(hour, 'Home');
      expect(chosen('hour', '01')).toBe(true);

      keydown(hour, 'ArrowDown');
      expect(chosen('hour', '01')).toBe(true);

      keydown(hour, 'End');
      expect(chosen('hour', '01')).toBe(true);
    });

    it('clicking an unavailable option chooses nothing', async () => {
      const { panel, input } = await render({ twelveHour: false, availability: { min: '01:00' } });
      open(panel);

      option('hour', '00').click();

      expect(chosen('hour', '14')).toBe(true);
      expect(input.value).toBe('14:30');
    });

    it('a choice that makes another unavailable keeps it chosen and commits nothing', async () => {
      const { panel, input } = await render({ value: '01:30', availability: { max: '13:00' } });
      open(panel);

      option('meridiem', 'PM').click();

      expect(chosen('minute', '30')).toBe(true);
      expect(disabled('minute', '30')).toBe(true);
      expect(input.value).toBe('01:30');

      option('minute', '00').click();
      expect(input.value).toBe('13:00');
    });

    it('closing the panel discards a choice that made another unavailable', async () => {
      const { root, panel, input } = await render({ value: '01:30', availability: { max: '13:00' } });
      const changed = vi.fn();
      open(panel);
      option('hour', '2').click();
      option('meridiem', 'PM').click();
      expect(disabled('minute', '30')).toBe(true);
      root.addEventListener('combobox-time:changed', changed);

      panel.hidePopover();
      lifecycle(panel, 'closed');

      expect(input.value).toBe('02:30');
      expect(chosen('hour', '2')).toBe(true);
      expect(chosen('meridiem', 'AM')).toBe(true);
      expect(disabled('minute', '30')).toBe(false);
      expect(changed).not.toHaveBeenCalled();
    });

    it('closing the panel keeps a choice still in progress', async () => {
      const { panel } = await render({ value: '' });
      open(panel);
      option('hour', '1').click();

      panel.hidePopover();
      lifecycle(panel, 'closed');

      expect(chosen('hour', '1')).toBe(true);
    });

    it('Escape restores an unavailable value and its options', async () => {
      const { panel, input } = await render({ twelveHour: false, availability: { max: '14:00' } });
      const minute = document.querySelector('#minute');
      open(panel);

      keydown(minute, 'ArrowUp');
      expect(input.value).toBe('14:00');

      keydown(minute, 'Escape');

      expect(input.value).toBe('14:30');
      expect(chosen('minute', '30')).toBe(true);
    });

    it('reports unusable availability', async () => {
      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {});

      await render({ availability: { min: '09:05', max: '09:10', step: 15 } });

      expect(consoleError).toHaveBeenCalledWith(expect.stringContaining('min and max leave no time on the step'));
      consoleError.mockRestore();
    });
  });
});
