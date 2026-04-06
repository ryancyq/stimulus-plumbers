import { Controller } from '@hotwired/stimulus';
import { tryParseDate } from '../plumbers/plumber/support';

export default class extends Controller {
  static targets = ['previous', 'next', 'day', 'month', 'year', 'input', 'display'];
  static outlets = ['calendar-month'];
  static values = {
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
    if (this.hasInputTarget && this.inputTarget.value) {
      const date = tryParseDate(this.inputTarget.value);
      if (date) {
        await this.calendarMonthOutlet.calendar.navigate(date);
      }
    }
    this.draw();
  }

  selected(event) {
    if (this.hasInputTarget) {
      this.inputTarget.value = event.detail.iso;
    }
    if (this.hasDisplayTarget) {
      this.displayTarget.value = this.formatDate(new Date(event.detail.iso));
    }
  }

  formatDate(date) {
    return new Intl.DateTimeFormat(this.localesValue, {
      day:   this.dayFormatValue,
      month: this.monthFormatValue,
      year:  this.yearFormatValue,
    }).format(date);
  }

  previousTargetConnected(target) {
    target.addEventListener('click', this.previous);
  }

  previousTargetDisconnected(target) {
    target.removeEventListener('click', this.previous);
  }

  async previous() {
    await this.calendarMonthOutlet.calendar.step('month', -1);
    this.draw();
  }

  nextTargetConnected(target) {
    target.addEventListener('click', this.next);
  }

  nextTargetDisconnected(target) {
    target.removeEventListener('click', this.next);
  }

  async next() {
    await this.calendarMonthOutlet.calendar.step('month', 1);
    this.draw();
  }

  draw() {
    this.drawDay();
    this.drawMonth();
    this.drawYear();
  }

  drawDay() {
    if (!this.hasDayTarget || !this.hasCalendarMonthOutlet) return;

    const { year, month, day } = this.calendarMonthOutlet.calendar;
    const formatter = new Intl.DateTimeFormat(this.localesValue, { day: this.dayFormatValue });
    this.dayTarget.textContent = formatter.format(new Date(year, month, day));
  }

  drawMonth() {
    if (!this.hasMonthTarget || !this.hasCalendarMonthOutlet) return;

    const { year, month } = this.calendarMonthOutlet.calendar;
    const formatter = new Intl.DateTimeFormat(this.localesValue, { month: this.monthFormatValue });
    this.monthTarget.textContent = formatter.format(new Date(year, month));
  }

  drawYear() {
    if (!this.hasYearTarget || !this.hasCalendarMonthOutlet) return;

    const { year } = this.calendarMonthOutlet.calendar;
    const formatter = new Intl.DateTimeFormat(this.localesValue, { year: this.yearFormatValue });
    this.yearTarget.textContent = formatter.format(new Date(year, 0));
  }
}
