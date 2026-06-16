import { Controller } from '@hotwired/stimulus';
import { attachCalendarMonthSelector } from '../plumbers/calendar-selector';

export default class extends Controller {
  initialize() {
    this.selector = attachCalendarMonthSelector(this);
  }
  connect() {
    this.selector.attach();
  }
  disconnect() {
    this.selector.detach();
  }
}
