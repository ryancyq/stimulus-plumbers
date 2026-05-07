import { Controller } from '@hotwired/stimulus';
import { tryParseDate } from '../plumbers/plumber/support';

export default class ComboboxDateController extends Controller {
  static targets = ['previous', 'next', 'day', 'month', 'year'];
  static outlets = ['calendar-month'];
  static values = {
    date: String,
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

  onSelect(event) {
    this.dateValue = event.detail.iso;
    this.draw();
    this.dispatch('selected', { detail: { value: event.detail.iso }, bubbles: true });
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
}
