import { Controller } from '@hotwired/stimulus';
import { initCalendar } from '../plumbers';
import { tryParseDate } from '../plumbers/plumber/date';

export default class extends Controller {
  static targets = ['daysOfWeek', 'daysOfMonth'];
  static classes = ['dayOfWeek', 'dayOfMonth', 'dayOfOtherMonth', 'row'];
  static values = {
    locales: { type: Array, default: ['default'] },
    weekdayFormat: { type: String, default: 'short' },
    dayFormat: { type: String, default: 'numeric' },
    daysOfOtherMonth: { type: Boolean, default: false },
    today: { type: String, default: '' },
    selected: { type: String, default: '' },
  };

  initialize() {
    initCalendar(this, { today: this.todayValue });
  }

  connect() {
    this.draw();
  }

  navigated() {
    this.draw();
  }

  selectedValueChanged() {
    if (!this.hasDaysOfMonthTarget) return;

    this.daysOfMonthTarget.querySelectorAll('[aria-selected]').forEach((el) => {
      el.setAttribute('aria-selected', 'false');
    });

    if (!this.selectedValue) return;

    const parsed = tryParseDate(this.selectedValue);
    if (!parsed) return;

    const time = this.daysOfMonthTarget.querySelector(`time[datetime="${parsed.toISOString()}"]`);
    if (time) time.closest('[aria-selected]').setAttribute('aria-selected', 'true');
  }

  onSelect(event) {
    const iso = event.detail?.iso;
    if (!iso) return;
    const date = tryParseDate(iso);
    if (!date) return;
    this.selectedValue = iso;
    if (date.getMonth() !== this.calendar.month || date.getFullYear() !== this.calendar.year) {
      this.calendar.navigate(date);
    }
  }

  draw() {
    this.drawDaysOfWeek();
    this.drawDaysOfMonth();
    this.selectedValueChanged();
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
    if (this.hasRowClass) row.classList.add(...this.rowClasses);
    row.replaceChildren(...daysOfWeek);
    this.daysOfWeekTarget.replaceChildren(row);
  }

  drawDaysOfMonth() {
    if (!this.hasDaysOfMonthTarget) return;

    const t = this.calendar.today;
    const today = new Date(t.getFullYear(), t.getMonth(), t.getDate()).getTime();
    const daysOfMonth = [];
    for (const date of this.calendar.daysOfMonth) {
      const dayRuleDisabled = this.calendar.isDisabled(date.date) || !this.calendar.isWithinRange(date.date);
      const dayOutsideNavigable = !date.current && this.daysOfOtherMonthValue && !dayRuleDisabled;
      const dayText = date.current || this.daysOfOtherMonthValue ? date.value : '';
      const dayElement = this.createDayElement(dayText, {
        selectable: date.current || dayOutsideNavigable,
        disabled: date.current ? dayRuleDisabled : !dayOutsideNavigable,
      });

      if (today === date.date.getTime()) dayElement.setAttribute('aria-current', 'date');
      if (date.current || this.daysOfOtherMonthValue) dayElement.setAttribute('aria-selected', '');
      if (!date.current && this.daysOfOtherMonthValue && this.hasDayOfOtherMonthClass) {
        dayElement.classList.add(...this.dayOfOtherMonthClasses);
      } else if (this.hasDayOfMonthClass) {
        dayElement.classList.add(...this.dayOfMonthClasses);
      }

      const time = document.createElement('time');
      time.dateTime = date.iso;
      dayElement.appendChild(time);

      daysOfMonth.push(dayElement);
    }

    const rows = [];
    for (let i = 0; i < daysOfMonth.length; i += 7) {
      const row = document.createElement('div');
      row.setAttribute('role', 'row');
      if (this.hasRowClass) row.classList.add(...this.rowClasses);
      for (const day of daysOfMonth.slice(i, i + 7)) {
        day.setAttribute('role', 'gridcell');
        row.appendChild(day);
      }
      rows.push(row);
    }
    this.daysOfMonthTarget.replaceChildren(...rows);
  }
}
