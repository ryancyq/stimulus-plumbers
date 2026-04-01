import { Controller } from '@hotwired/stimulus';
import { attachCalendar } from '../plumbers';
import { tryParseDate } from '../plumbers/plumber/support';

export default class extends Controller {
  static targets = ['day', 'month', 'year', 'previous', 'next', 'daysOfWeek', 'daysOfMonth'];
  static classes = ['dayOfWeek', 'dayOfMonth'];
  static values = {
    locales: { type: Array, default: ['default'] },
    weekdayFormat: { type: String, default: 'short' },
    dayFormat: { type: String, default: 'numeric' },
    monthFormat: { type: String, default: 'long' },
    yearFormat: { type: String, default: 'numeric' },
    daysOfOtherMonth: { type: Boolean, default: false },
  };

  initialize() {
    this.previous = this.previous.bind(this);
    this.next = this.next.bind(this);
    this.select = this.select.bind(this);
  }

  connect() {
    attachCalendar(this);
    this.draw();
  }

  draw() {
    this.drawDay();
    this.drawMonth();
    this.drawYear();
    this.drawDaysOfWeek();
    this.drawDaysOfMonth();
  }

  navigated() {
    this.draw();
  }

  previousTargetConnected(target) {
    target.addEventListener('click', this.previous);
  }

  previousTargetDisconnected(target) {
    target.removeEventListener('click', this.previous);
  }

  async previous(event) {
    event.preventDefault();

    const { params = {} } = event;
    await this.calendar.step(params.type || 'month', -1);
  }

  nextTargetConnected(target) {
    target.addEventListener('click', this.next);
  }

  nextTargetDisconnected(target) {
    target.removeEventListener('click', this.next);
  }

  async next(event) {
    event.preventDefault();

    const { params = {} } = event;
    await this.calendar.step(params.type || 'month', 1);
  }

  drawDay() {
    if (!this.hasDayTarget || this.dayTarget.childElementCount > 0) return;

    const formatter = new Intl.DateTimeFormat(this.localesValue, { day: this.dayFormatValue });
    this.dayTarget.textContent = formatter.format(new Date(this.calendar.year, this.calendar.month, this.calendar.day));
  }

  drawMonth() {
    if (!this.hasMonthTarget || this.monthTarget.childElementCount > 0) return;

    const formatter = new Intl.DateTimeFormat(this.localesValue, { month: this.monthFormatValue });
    this.monthTarget.textContent = formatter.format(new Date(this.calendar.year, this.calendar.month));
  }

  drawYear() {
    if (!this.hasYearTarget || this.yearTarget.childElementCount > 0) return;

    const formatter = new Intl.DateTimeFormat(this.localesValue, { year: this.yearFormatValue });
    this.yearTarget.textContent = formatter.format(new Date(this.calendar.year, 0));
  }

  createDayElement(day, { selectable = false, disabled = false } = {}) {
    const element = document.createElement(selectable ? 'button' : 'div');
    element.tabIndex = -1;
    if (day) element.textContent = day;
    else element.ariaHidden = true;
    if (disabled) {
      if (element instanceof HTMLButtonElement) element.disabled = true;
      else element.ariaDisabled = true;
    }
    return element;
  }

  drawDaysOfWeek() {
    if (!this.hasDaysOfWeekTarget) return;

    const formatter = new Intl.DateTimeFormat(this.localesValue, {
      weekday: this.weekdayFormatValue,
    });
    const daysOfWeek = [];
    for (const date of this.calendar.daysOfWeek) {
      const dayElement = this.createDayElement(formatter.format(date.date));
      dayElement.role = 'columnheader';
      dayElement.title = date.long;
      if (this.hasDayOfWeekClass) dayElement.classList.add(...this.dayOfWeekClasses);
      daysOfWeek.push(dayElement);
    }
    this.daysOfWeekTarget.replaceChildren(...daysOfWeek);
  }

  drawDaysOfMonth() {
    if (!this.hasDaysOfMonthTarget) return;

    const today = this.calendar.today.getTime();
    const daysOfMonth = [];
    for (const date of this.calendar.daysOfMonth) {
      const dayDisabled =
        !date.current || this.calendar.isDisabled(date.date) || !this.calendar.isWithinRange(date.date);
      const dayText = date.current || this.daysOfOtherMonthValue ? date.value : '';
      const dayElement = this.createDayElement(dayText, {
        selectable: date.current,
        disabled: dayDisabled,
      });

      if (today === date.date.getTime()) dayElement.ariaCurrent = 'date';
      if (this.hasDayOfMonthClass) dayElement.classList.add(...this.dayOfMonthClasses);

      const time = document.createElement('time');
      time.dateTime = date.iso;
      dayElement.appendChild(time);

      daysOfMonth.push(dayElement);
    }

    const rows = [];
    for (let i = 0; i < daysOfMonth.length; i += 7) {
      const row = document.createElement('div');
      row.role = 'row';
      for (const day of daysOfMonth.slice(i, i + 7)) {
        day.role = 'gridcell';
        row.appendChild(day);
      }
      rows.push(row);
    }
    this.daysOfMonthTarget.replaceChildren(...rows);
  }

  daysOfMonthTargetConnected(target) {
    target.addEventListener('click', this.select);
  }

  daysOfMonthTargetDisconnected(target) {
    target.removeEventListener('click', this.select);
  }

  select(event) {
    if (!(event && event.target instanceof HTMLElement)) return;
    if (!(this.hasDaysOfMonthTarget && this.daysOfMonthTarget.contains(event.target))) return;

    event.preventDefault();
    const input = event.target instanceof HTMLTimeElement ? event.target.parentElement : event.target;
    if (input.disabled || input.ariaDisabled === 'true') return;

    this.dispatch('select', { target: input });
    const time = event.target instanceof HTMLTimeElement ? event.target : event.target.querySelector('time');
    if (!time) return console.error(`unable to locate time element within ${input}`);

    const date = tryParseDate(time.dateTime);
    if (!date) return console.error(`unable to parse ${time.dateTime} found within the time element`);
    this.dispatch('selected', {
      target: input,
      detail: { epoch: date.getTime(), iso: date.toISOString() },
    });
  }
}
