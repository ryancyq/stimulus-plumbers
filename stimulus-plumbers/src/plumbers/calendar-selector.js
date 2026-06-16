import Plumber from './plumber';
import { tryParseDate } from './plumber/date';

export class CalendarDaySelector extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);
    this.handle = this.handle.bind(this);
    this.onSelect = options.onSelect || null;
  }

  attach() {
    this.element.addEventListener('click', this.handle);
  }
  detach() {
    this.element.removeEventListener('click', this.handle);
  }

  handle(event) {
    if (!(event.target instanceof HTMLElement)) return;
    event.preventDefault();
    const input = event.target instanceof HTMLTimeElement ? event.target.parentElement : event.target;
    if (input.disabled || input.getAttribute('aria-disabled') === 'true') return;
    const time = event.target instanceof HTMLTimeElement ? event.target : event.target.querySelector('time');
    if (!time) return;
    const date = tryParseDate(time.dateTime);
    if (!date) return;
    this.dispatch('selecting', { target: input });
    const iso = date.toISOString();
    if (this.onSelect) {
      this.awaitCallback(this.onSelect, iso);
    } else {
      this.dispatch('selected', { detail: { epoch: date.getTime(), iso } });
    }
  }
}

export class CalendarMonthSelector extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);
    this.handle = this.handle.bind(this);
  }

  attach() {
    this.element.addEventListener('click', this.handle);
  }
  detach() {
    this.element.removeEventListener('click', this.handle);
  }

  handle(event) {
    const btn = event.target.closest('button[data-month]');
    if (!btn || btn.disabled || btn.getAttribute('aria-disabled') === 'true') return;
    event.preventDefault();
    const month = parseInt(btn.dataset.month, 10);
    if (isNaN(month)) return;
    this.dispatch('selected', { detail: { month } });
  }
}

export class CalendarYearSelector extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);
    this.handle = this.handle.bind(this);
  }

  attach() {
    this.element.addEventListener('click', this.handle);
  }
  detach() {
    this.element.removeEventListener('click', this.handle);
  }

  handle(event) {
    const btn = event.target.closest('button[data-year]');
    if (!btn || btn.disabled || btn.getAttribute('aria-disabled') === 'true') return;
    event.preventDefault();
    const year = parseInt(btn.dataset.year, 10);
    if (isNaN(year)) return;
    this.dispatch('selected', { detail: { year } });
  }
}

export const attachCalendarDaySelector = (controller, options) => new CalendarDaySelector(controller, options);
export const attachCalendarMonthSelector = (controller, options) => new CalendarMonthSelector(controller, options);
export const attachCalendarYearSelector = (controller, options) => new CalendarYearSelector(controller, options);
