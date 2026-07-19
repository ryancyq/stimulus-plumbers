import { Controller } from '@hotwired/stimulus';
import { tryParseDate } from '../plumbers/plumber/date';
import { setHidden } from '../accessibility/aria';

const VIEWS = ['month', 'year', 'decade'];

export default class extends Controller {
  static targets = ['previous', 'next', 'day', 'month', 'year', 'viewTitle'];
  static outlets = ['calendar-month', 'calendar-year', 'calendar-decade'];
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
  }

  async calendarMonthOutletConnected() {
    if (this.dateValue) {
      const date = tryParseDate(this.dateValue);
      if (date) await this.calendarMonthOutlet.calendar.navigate(date);
    }
    this.draw();
  }

  onDaySelect(event) {
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

  async onMonthSelect(event) {
    const { month } = event.detail; // 1-indexed
    if (!this.hasCalendarMonthOutlet) return;
    const { year } = this.calendarMonthOutlet.calendar;
    await this.calendarMonthOutlet.calendar.navigate(new Date(year, month - 1, 1));
    this.viewValue = 'month';
    this.draw();
  }

  async onYearSelect(event) {
    const { year } = event.detail;
    if (!this.hasCalendarMonthOutlet) return;
    const { month } = this.calendarMonthOutlet.calendar;
    await this.calendarMonthOutlet.calendar.navigate(new Date(year, month, 1));
    if (this.hasCalendarYearOutlet) {
      this.calendarYearOutlet.navigate(this.calendarMonthOutlet.calendar.current);
    }
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
    this.syncOutletValues();
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
    this.syncOutletValues();
    this.draw();
  }

  draw() {
    this.drawDay();
    this.drawMonth();
    this.drawYear();
    this.drawViewTitle();
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

  syncOutletValues() {
    if (!this.hasCalendarMonthOutlet) return;
    const { current } = this.calendarMonthOutlet.calendar;
    if (!current) return;
    if (this.hasCalendarYearOutlet) this.calendarYearOutlet.navigate(current);
    if (this.hasCalendarDecadeOutlet) this.calendarDecadeOutlet.navigate(current);
  }

  stepArgs(direction) {
    if (this.viewValue === 'year') return ['year', direction];
    if (this.viewValue === 'decade') return ['year', direction * 10];
    return ['month', direction];
  }

  viewTitleLabel(year, month) {
    if (this.viewValue === 'year') return String(year);
    if (this.viewValue === 'decade') {
      const start = Math.floor(year / 10) * 10;
      return `${start}–${start + 9}`;
    }
    return new Intl.DateTimeFormat(this.localesValue, { month: 'long', year: 'numeric' }).format(new Date(year, month));
  }

  drawView() {
    const inMonthView = this.viewValue === 'month';
    const inYearView = this.viewValue === 'year';
    const inDecadeView = this.viewValue === 'decade';

    if (this.hasCalendarMonthOutlet) {
      const outlet = this.calendarMonthOutlet;
      if (outlet.hasDaysOfWeekTarget) setHidden(outlet.daysOfWeekTarget, !inMonthView);
      if (outlet.hasDaysOfMonthTarget) setHidden(outlet.daysOfMonthTarget, !inMonthView);
    }
    if (this.hasCalendarYearOutlet) {
      setHidden(this.calendarYearOutletElement, !inYearView);
    }
    if (this.hasCalendarDecadeOutlet) {
      setHidden(this.calendarDecadeOutletElement, !inDecadeView);
    }
  }
}
