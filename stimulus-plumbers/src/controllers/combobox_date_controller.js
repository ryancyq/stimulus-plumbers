import { Controller } from '@hotwired/stimulus';
import { tryParseDate } from '../plumbers/plumber/date';

const VIEWS = ['month', 'year', 'decade'];

export default class extends Controller {
  static targets = ['previous', 'next', 'day', 'month', 'year', 'viewTitle', 'monthView', 'yearView', 'decadeView'];
  static outlets = ['calendar-month'];
  static values = {
    date: String,
    view: { type: String, default: 'month' },
    locales: { type: Array, default: ['default'] },
    dayFormat: { type: String, default: 'numeric' },
    monthFormat: { type: String, default: 'long' },
    yearFormat: { type: String, default: 'numeric' },
  };

  initialize() {
    this.previous = this.previous.bind(this);
    this.next = this.next.bind(this);
    this.selectMonth = this.selectMonth.bind(this);
    this.selectYear = this.selectYear.bind(this);
  }

  async calendarMonthOutletConnected() {
    if (this.dateValue) {
      const date = tryParseDate(this.dateValue);
      if (date) await this.calendarMonthOutlet.calendar.navigate(date);
    }
    this.draw();
  }

  onSelect(event) {
    this.dateValue = event.detail.iso;
    this.draw();
    this.dispatch('selected', { detail: { value: event.detail.iso }, bubbles: true });
  }

  zoomOut() {
    const idx = VIEWS.indexOf(this.viewValue);
    if (idx < VIEWS.length - 1) {
      this.viewValue = VIEWS[idx + 1];
      this.draw();
    }
  }

  async selectMonth(event) {
    const btn = event.target.closest('button[data-month]');
    if (!btn) return;
    const month = parseInt(btn.dataset.month, 10) - 1; // data-month is 1-indexed
    const { year } = this.calendarMonthOutlet.calendar;
    await this.calendarMonthOutlet.calendar.navigate(new Date(year, month, 1));
    this.viewValue = 'month';
    this.draw();
  }

  async selectYear(event) {
    const btn = event.target.closest('button[data-year]');
    if (!btn || btn.getAttribute('aria-disabled') === 'true') return;
    const year = parseInt(btn.dataset.year, 10);
    const { month } = this.calendarMonthOutlet.calendar;
    await this.calendarMonthOutlet.calendar.navigate(new Date(year, month, 1));
    this.viewValue = 'year';
    this.draw();
  }

  previousTargetConnected(target) {
    target.addEventListener('click', this.previous);
  }

  previousTargetDisconnected(target) {
    target.removeEventListener('click', this.previous);
  }

  async previous() {
    await this.calendarMonthOutlet.calendar.step(...this.stepArgs(-1));
    this.draw();
  }

  nextTargetConnected(target) {
    target.addEventListener('click', this.next);
  }

  nextTargetDisconnected(target) {
    target.removeEventListener('click', this.next);
  }

  async next() {
    await this.calendarMonthOutlet.calendar.step(...this.stepArgs(1));
    this.draw();
  }

  yearViewTargetConnected(target) {
    target.addEventListener('click', this.selectMonth);
  }

  yearViewTargetDisconnected(target) {
    target.removeEventListener('click', this.selectMonth);
  }

  decadeViewTargetConnected(target) {
    target.addEventListener('click', this.selectYear);
  }

  decadeViewTargetDisconnected(target) {
    target.removeEventListener('click', this.selectYear);
  }

  draw() {
    this.drawDay();
    this.drawMonth();
    this.drawYear();
    this.drawViewTitle();
    this.drawYearView();
    this.drawDecadeView();
    this.drawView();
  }

  drawDay() {
    if (!this.hasDayTarget || !this.hasCalendarMonthOutlet) return;
    const { year, month, day } = this.calendarMonthOutlet.calendar;
    this.dayTarget.textContent = new Intl.DateTimeFormat(this.localesValue, { day: this.dayFormatValue }).format(
      new Date(year, month, day)
    );
  }

  drawMonth() {
    if (!this.hasMonthTarget || !this.hasCalendarMonthOutlet) return;
    const { year, month } = this.calendarMonthOutlet.calendar;
    this.monthTarget.textContent = new Intl.DateTimeFormat(this.localesValue, { month: this.monthFormatValue }).format(
      new Date(year, month)
    );
  }

  drawYear() {
    if (!this.hasYearTarget || !this.hasCalendarMonthOutlet) return;
    const { year } = this.calendarMonthOutlet.calendar;
    this.yearTarget.textContent = new Intl.DateTimeFormat(this.localesValue, { year: this.yearFormatValue }).format(
      new Date(year, 0)
    );
  }

  drawViewTitle() {
    if (!this.hasViewTitleTarget || !this.hasCalendarMonthOutlet) return;
    const { year, month } = this.calendarMonthOutlet.calendar;
    this.viewTitleTarget.textContent = this.viewTitleLabel(year, month);
  }

  drawYearView() {
    if (!this.hasYearViewTarget || !this.hasCalendarMonthOutlet) return;

    const { year, month, monthsOfYear } = this.calendarMonthOutlet.calendar;
    const today = this.calendarMonthOutlet.calendar.today;
    const cells = [];

    for (const m of monthsOfYear) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = m.short;
      btn.dataset.month = m.value + 1; // 1-indexed to match SSR convention
      btn.setAttribute('role', 'gridcell');
      btn.setAttribute('aria-selected', m.value === month ? 'true' : 'false');
      if (m.value === today.getMonth() && year === today.getFullYear()) {
        btn.setAttribute('aria-current', 'month');
      }
      cells.push(btn);
    }

    this.yearViewTarget.replaceChildren(...cells);
  }

  drawDecadeView() {
    if (!this.hasDecadeViewTarget || !this.hasCalendarMonthOutlet) return;

    const { year, yearsOfDecade } = this.calendarMonthOutlet.calendar;
    const todayYear = this.calendarMonthOutlet.calendar.today.getFullYear();
    const cells = [];

    for (const y of yearsOfDecade) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = y.value;
      btn.dataset.year = y.value;
      btn.setAttribute('role', 'gridcell');
      btn.setAttribute('aria-selected', y.value === year ? 'true' : 'false');
      if (y.value === todayYear) btn.setAttribute('aria-current', 'year');
      if (y.outside) btn.setAttribute('aria-disabled', 'true');
      cells.push(btn);
    }

    this.decadeViewTarget.replaceChildren(...cells);
  }

  viewTitleLabel(year, month) {
    if (this.viewValue === 'year') return String(year);
    if (this.viewValue === 'decade') {
      const start = Math.floor(year / 10) * 10;
      return `${start}–${start + 9}`;
    }
    return new Intl.DateTimeFormat(this.localesValue, { month: 'long', year: 'numeric' }).format(new Date(year, month));
  }

  stepArgs(direction) {
    if (this.viewValue === 'year') return ['year', direction];
    if (this.viewValue === 'decade') return ['year', direction * 10];
    return ['month', direction];
  }

  drawView() {
    if (this.hasMonthViewTarget) this.monthViewTarget.hidden = this.viewValue !== 'month';
    if (this.hasYearViewTarget) this.yearViewTarget.hidden = this.viewValue !== 'year';
    if (this.hasDecadeViewTarget) this.decadeViewTarget.hidden = this.viewValue !== 'decade';

    if (this.hasCalendarMonthOutlet) {
      const outlet = this.calendarMonthOutlet;
      const monthView = this.viewValue === 'month';
      if (outlet.hasDaysOfWeekTarget) outlet.daysOfWeekTarget.hidden = !monthView;
      if (outlet.hasDaysOfMonthTarget) outlet.daysOfMonthTarget.hidden = !monthView;
    }
  }
}
