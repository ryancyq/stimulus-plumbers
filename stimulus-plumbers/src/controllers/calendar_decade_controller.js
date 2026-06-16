import { Controller } from '@hotwired/stimulus';
import { initCalendar } from '../plumbers';
import { attachCalendarYearSelector } from '../plumbers/calendar-selector';
import { tryParseDate } from '../plumbers/plumber/date';

const YEARS_PER_ROW = 4;

export default class extends Controller {
  static targets = ['grid'];
  static values = {
    current: Number,
    today: { type: String, default: '' },
    selected: { type: String, default: '' },
    since: { type: String, default: '' },
    till: { type: String, default: '' },
  };

  initialize() {
    this.selector = attachCalendarYearSelector(this);
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
    const selectedYear = selected ? selected.getFullYear() : null;
    this.gridTarget.querySelectorAll('button[data-year]').forEach((btn) => {
      const year = parseInt(btn.dataset.year, 10);
      btn.setAttribute('aria-selected', year === selectedYear ? 'true' : 'false');
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

    const { yearsOfDecade } = this.calendar;
    const todayYear = this.calendar.today.getFullYear();
    const selectedDate = tryParseDate(this.selectedValue);
    const selectedYear = selectedDate ? selectedDate.getFullYear() : null;
    const cells = [];

    for (const y of yearsOfDecade) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = y.value;
      btn.dataset.year = y.value;
      btn.setAttribute('role', 'gridcell');
      btn.setAttribute('aria-selected', y.value === selectedYear ? 'true' : 'false');
      if (y.value === todayYear) btn.setAttribute('aria-current', 'year');
      if (y.disabled) btn.setAttribute('aria-disabled', 'true');
      cells.push(btn);
    }

    const rowgroup = document.createElement('div');
    rowgroup.setAttribute('role', 'rowgroup');
    for (let i = 0; i < cells.length; i += YEARS_PER_ROW) {
      const row = document.createElement('div');
      row.setAttribute('role', 'row');
      for (const cell of cells.slice(i, i + YEARS_PER_ROW)) row.appendChild(cell);
      rowgroup.appendChild(row);
    }
    this.gridTarget.replaceChildren(rowgroup);
  }
}
