import { Controller } from '@hotwired/stimulus';
import { initCalendar } from '../plumbers';

export default class extends Controller {
  static targets = ['daysOfWeek', 'daysOfMonth'];
  static classes = ['dayOfWeek', 'dayOfMonth', 'week'];
  static values = {
    locales: { type: Array, default: ['default'] },
    weekdayFormat: { type: String, default: 'short' },
    dayFormat: { type: String, default: 'numeric' },
    daysOfOtherMonth: { type: Boolean, default: false },
  };

  initialize() {
    initCalendar(this);
  }

  connect() {
    this.draw();
  }

  navigated() {
    this.draw();
  }

  draw() {
    this.drawDaysOfWeek();
    this.drawDaysOfMonth();
  }

  createDayElement(day, { selectable = false, disabled = false } = {}) {
    const element = document.createElement(selectable ? 'button' : 'div');
    element.tabIndex = -1;
    if (day) element.textContent = day;
    else element.setAttribute('aria-hidden', 'true');
    if (disabled) {
      if (element instanceof HTMLButtonElement) element.disabled = true;
      else element.setAttribute('aria-disabled', 'true');
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
      dayElement.setAttribute('role', 'columnheader');
      dayElement.title = date.long;
      if (this.hasDayOfWeekClass) dayElement.classList.add(...this.dayOfWeekClasses);
      daysOfWeek.push(dayElement);
    }
    const row = document.createElement('div');
    row.setAttribute('role', 'row');
    if (this.hasWeekClass) row.classList.add(...this.weekClasses);
    row.replaceChildren(...daysOfWeek);
    this.daysOfWeekTarget.replaceChildren(row);
  }

  drawDaysOfMonth() {
    if (!this.hasDaysOfMonthTarget) return;

    const t = this.calendar.today;
    const today = new Date(t.getFullYear(), t.getMonth(), t.getDate()).getTime();
    const daysOfMonth = [];
    for (const date of this.calendar.daysOfMonth) {
      const dayDisabled =
        !date.current || this.calendar.isDisabled(date.date) || !this.calendar.isWithinRange(date.date);
      const dayText = date.current || this.daysOfOtherMonthValue ? date.value : '';
      const dayElement = this.createDayElement(dayText, {
        selectable: date.current,
        disabled: dayDisabled,
      });

      if (today === date.date.getTime()) dayElement.setAttribute('aria-current', 'date');
      if (this.hasDayOfMonthClass) dayElement.classList.add(...this.dayOfMonthClasses);

      const time = document.createElement('time');
      time.dateTime = date.iso;
      dayElement.appendChild(time);

      daysOfMonth.push(dayElement);
    }

    const rows = [];
    for (let i = 0; i < daysOfMonth.length; i += 7) {
      const row = document.createElement('div');
      row.setAttribute('role', 'row');
      if (this.hasWeekClass) row.classList.add(...this.weekClasses);
      for (const day of daysOfMonth.slice(i, i + 7)) {
        day.setAttribute('role', 'gridcell');
        row.appendChild(day);
      }
      rows.push(row);
    }
    this.daysOfMonthTarget.replaceChildren(...rows);
  }
}
