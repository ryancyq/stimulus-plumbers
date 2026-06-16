import { Controller } from '@hotwired/stimulus';
import { initCalendar } from '../plumbers';
import { attachCalendarMonthSelector } from '../plumbers/calendar-selector';
import { tryParseDate } from '../plumbers/plumber/date';

const MONTHS_PER_ROW = 4;

export default class extends Controller {
  static targets = ['grid'];
  static values = {
    current: Number,
    today: { type: String, default: '' },
    selected: { type: String, default: '' },
    since: { type: String, default: '' },
    till: { type: String, default: '' },
    locales: { type: Array, default: ['default'] },
    monthFormat: { type: String, default: 'short' },
  };

  initialize() {
    this.selector = attachCalendarMonthSelector(this);
    initCalendar(this, {
      today: this.todayValue,
      year: this.currentValue || undefined,
      since: this.sinceValue || null,
      till: this.tillValue || null,
    });
  }

  connect() {
    this.selector.attach();
    this.navigated();
  }

  disconnect() {
    this.selector.detach();
  }

  currentValueChanged() {
    if (!this.calendar || !this.hasCurrentValue) return;
    this.calendar.navigate(this.currentDate);
  }

  selectedValueChanged() {
    if (!this.hasGridTarget) return;
    const selected = tryParseDate(this.selectedValue);
    this.gridTarget.querySelectorAll('button[data-month]').forEach((btn) => {
      const month = parseInt(btn.dataset.month, 10) - 1; // 0-indexed
      btn.setAttribute('aria-selected', selected && selected.getMonth() === month ? 'true' : 'false');
    });
  }

  navigate(date) {
    this.currentValue = date.getFullYear();
  }

  step(unit, dir) {
    return this.calendar.step(unit, dir);
  }

  navigated() {
    this.drawGrid();
  }

  get currentDate() {
    return new Date(this.currentValue, 0, 1);
  }

  drawGrid() {
    if (!this.hasGridTarget) return;

    const { year, monthsOfYear } = this.calendar;
    const today = this.calendar.today;
    const selectedDate = tryParseDate(this.selectedValue);
    const cells = [];

    const formatter = new Intl.DateTimeFormat(this.localesValue, { month: this.monthFormatValue });

    for (const m of monthsOfYear) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = formatter.format(m.date);
      btn.dataset.month = m.value + 1; // 1-indexed
      btn.setAttribute('role', 'gridcell');
      const isSelected = selectedDate && selectedDate.getMonth() === m.value;
      btn.setAttribute('aria-selected', isSelected ? 'true' : 'false');
      if (m.value === today.getMonth() && year === today.getFullYear()) {
        btn.setAttribute('aria-current', 'month');
      }
      if (m.disabled) btn.setAttribute('aria-disabled', 'true');
      cells.push(btn);
    }

    const rowgroup = document.createElement('div');
    rowgroup.setAttribute('role', 'rowgroup');
    for (let i = 0; i < cells.length; i += MONTHS_PER_ROW) {
      const row = document.createElement('div');
      row.setAttribute('role', 'row');
      for (const cell of cells.slice(i, i + MONTHS_PER_ROW)) row.appendChild(cell);
      rowgroup.appendChild(row);
    }
    this.gridTarget.replaceChildren(rowgroup);
  }
}
