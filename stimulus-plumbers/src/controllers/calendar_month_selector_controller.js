import { Controller } from '@hotwired/stimulus';
import { attachCalendarDaySelector } from '../plumbers/calendar-selector';

export default class extends Controller {
  initialize() {
    this.selector = attachCalendarDaySelector(this);
  }
  connect() {
    this.selector.attach();
  }
  disconnect() {
    this.selector.detach();
  }
}
