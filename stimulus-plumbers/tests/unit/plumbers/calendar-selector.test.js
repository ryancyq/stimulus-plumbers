import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import {
  CalendarDaySelector,
  CalendarMonthSelector,
  CalendarYearSelector,
  attachCalendarDaySelector,
  attachCalendarMonthSelector,
  attachCalendarYearSelector,
} from '../../../src/plumbers/calendar-selector';

function makeController(overrides = {}) {
  const element = document.createElement('div');
  document.body.appendChild(element);
  return {
    identifier: 'calendar-month',
    element,
    dispatch: vi.fn(() => true),
    ...overrides,
  };
}

function makeTime(datetime) {
  const time = document.createElement('time');
  time.dateTime = datetime;
  return time;
}

function makeCell({ tag = 'button', datetime, disabled = false, ariaDisabled = null } = {}) {
  const el = document.createElement(tag);
  el.setAttribute('role', 'gridcell');
  if (disabled) el.disabled = true;
  if (ariaDisabled !== null) el.setAttribute('aria-disabled', ariaDisabled);
  if (datetime) el.appendChild(makeTime(datetime));
  return el;
}

afterEach(() => {
  document.body.innerHTML = '';
  vi.clearAllMocks();
});

describe('CalendarDaySelector', () => {
  let controller;

  beforeEach(() => { controller = makeController(); });

  describe('constructor', () => {
    it('stores null onSelect by default', () => {
      expect(new CalendarDaySelector(controller).onSelect).toBeNull();
    });

    it('stores provided onSelect option', () => {
      expect(new CalendarDaySelector(controller, { onSelect: 'select' }).onSelect).toBe('select');
    });
  });

  describe('attach / detach', () => {
    it('adds click listener on attach', () => {
      const spy = vi.spyOn(controller.element, 'addEventListener');
      const sel = new CalendarDaySelector(controller);
      sel.attach();
      expect(spy).toHaveBeenCalledWith('click', sel.handle);
    });

    it('removes click listener on detach', () => {
      const spy = vi.spyOn(controller.element, 'removeEventListener');
      const sel = new CalendarDaySelector(controller);
      sel.attach();
      sel.detach();
      expect(spy).toHaveBeenCalledWith('click', sel.handle);
    });
  });

  describe('handle — without onSelect', () => {
    let sel;
    beforeEach(() => {
      sel = new CalendarDaySelector(controller);
      sel.attach();
    });

    it('dispatches selecting and selected on valid cell click', () => {
      const cell = makeCell({ datetime: '2026-04-01T00:00:00.000Z' });
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.dispatch).toHaveBeenCalledWith('selecting', expect.any(Object));
      expect(controller.dispatch).toHaveBeenCalledWith('selected', expect.objectContaining({
        detail: expect.objectContaining({ iso: '2026-04-01T00:00:00.000Z' }),
      }));
    });

    it('selected detail includes epoch and iso', () => {
      const cell = makeCell({ datetime: '2026-04-01T00:00:00.000Z' });
      controller.element.appendChild(cell);
      cell.click();
      const [, opts] = controller.dispatch.mock.calls.find(([name]) => name === 'selected');
      expect(typeof opts.detail.epoch).toBe('number');
      expect(opts.detail.iso).toBe('2026-04-01T00:00:00.000Z');
    });

    it('dispatches when clicking <time> child', () => {
      const cell = makeCell({ datetime: '2026-04-01T00:00:00.000Z' });
      controller.element.appendChild(cell);
      cell.querySelector('time').click();
      expect(controller.dispatch).toHaveBeenCalledWith('selecting', expect.any(Object));
      expect(controller.dispatch).toHaveBeenCalledWith('selected', expect.any(Object));
    });

    it('skips disabled button', () => {
      const cell = makeCell({ datetime: '2026-04-02T00:00:00.000Z', disabled: true });
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.dispatch).not.toHaveBeenCalled();
    });

    it('skips aria-disabled cell', () => {
      const cell = makeCell({ tag: 'span', datetime: '2026-04-03T00:00:00.000Z', ariaDisabled: 'true' });
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.dispatch).not.toHaveBeenCalled();
    });

    it('skips cell with no <time> element', () => {
      const cell = document.createElement('button');
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.dispatch).not.toHaveBeenCalled();
    });

    it('skips cell with unparseable datetime', () => {
      const cell = makeCell({ datetime: 'not-a-date' });
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('handle — with onSelect callback', () => {
    it('calls controller method instead of dispatching selected', () => {
      controller.select = vi.fn();
      const sel = new CalendarDaySelector(controller, { onSelect: 'select' });
      sel.attach();
      const cell = makeCell({ datetime: '2026-04-01T00:00:00.000Z' });
      controller.element.appendChild(cell);
      cell.click();
      expect(controller.select).toHaveBeenCalledWith('2026-04-01T00:00:00.000Z');
      expect(controller.dispatch).toHaveBeenCalledWith('selecting', expect.any(Object));
      const selectedCall = controller.dispatch.mock.calls.find(([name]) => name === 'selected');
      expect(selectedCall).toBeUndefined();
    });
  });
});

describe('CalendarMonthSelector', () => {
  let controller;

  beforeEach(() => { controller = makeController({ identifier: 'calendar-year' }); });

  function makeMonthButton({ month, disabled = false, ariaDisabled = null } = {}) {
    const btn = document.createElement('button');
    if (month !== undefined) btn.dataset.month = month;
    if (disabled) btn.disabled = true;
    if (ariaDisabled !== null) btn.setAttribute('aria-disabled', ariaDisabled);
    return btn;
  }

  it('dispatches selected with month on valid button click', () => {
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    const btn = makeMonthButton({ month: 3 });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).toHaveBeenCalledWith('selected', expect.objectContaining({
      detail: { month: 3 },
    }));
  });

  it('skips click with no button[data-month] ancestor', () => {
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    const span = document.createElement('span');
    controller.element.appendChild(span);
    span.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips disabled button', () => {
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    const btn = makeMonthButton({ month: 5, disabled: true });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips aria-disabled button', () => {
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    const btn = makeMonthButton({ month: 5, ariaDisabled: 'true' });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips button with non-numeric data-month', () => {
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    const btn = document.createElement('button');
    btn.dataset.month = 'abc';
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('attach / detach wires and unwires click', () => {
    const addSpy = vi.spyOn(controller.element, 'addEventListener');
    const removeSpy = vi.spyOn(controller.element, 'removeEventListener');
    const sel = new CalendarMonthSelector(controller);
    sel.attach();
    expect(addSpy).toHaveBeenCalledWith('click', sel.handle);
    sel.detach();
    expect(removeSpy).toHaveBeenCalledWith('click', sel.handle);
  });
});

describe('CalendarYearSelector', () => {
  let controller;

  beforeEach(() => { controller = makeController({ identifier: 'calendar-decade' }); });

  function makeYearButton({ year, disabled = false, ariaDisabled = null } = {}) {
    const btn = document.createElement('button');
    if (year !== undefined) btn.dataset.year = year;
    if (disabled) btn.disabled = true;
    if (ariaDisabled !== null) btn.setAttribute('aria-disabled', ariaDisabled);
    return btn;
  }

  it('dispatches selected with year on valid button click', () => {
    const sel = new CalendarYearSelector(controller);
    sel.attach();
    const btn = makeYearButton({ year: 2028 });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).toHaveBeenCalledWith('selected', expect.objectContaining({
      detail: { year: 2028 },
    }));
  });

  it('skips click with no button[data-year] ancestor', () => {
    const sel = new CalendarYearSelector(controller);
    sel.attach();
    const span = document.createElement('span');
    controller.element.appendChild(span);
    span.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips disabled button', () => {
    const sel = new CalendarYearSelector(controller);
    sel.attach();
    const btn = makeYearButton({ year: 2030, disabled: true });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips aria-disabled button', () => {
    const sel = new CalendarYearSelector(controller);
    sel.attach();
    const btn = makeYearButton({ year: 2030, ariaDisabled: 'true' });
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });

  it('skips button with non-numeric data-year', () => {
    const sel = new CalendarYearSelector(controller);
    sel.attach();
    const btn = document.createElement('button');
    btn.dataset.year = 'abc';
    controller.element.appendChild(btn);
    btn.click();
    expect(controller.dispatch).not.toHaveBeenCalled();
  });
});

describe('attach helpers', () => {
  it('attachCalendarDaySelector returns CalendarDaySelector', () => {
    const controller = makeController();
    expect(attachCalendarDaySelector(controller)).toBeInstanceOf(CalendarDaySelector);
  });

  it('attachCalendarMonthSelector returns CalendarMonthSelector', () => {
    const controller = makeController();
    expect(attachCalendarMonthSelector(controller)).toBeInstanceOf(CalendarMonthSelector);
  });

  it('attachCalendarYearSelector returns CalendarYearSelector', () => {
    const controller = makeController();
    expect(attachCalendarYearSelector(controller)).toBeInstanceOf(CalendarYearSelector);
  });
});
