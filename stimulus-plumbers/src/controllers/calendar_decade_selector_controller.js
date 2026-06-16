import { Controller } from '@hotwired/stimulus';
import { attachCalendarYearSelector } from '../plumbers/calendar-selector';

export default class extends Controller {
  initialize() {
    this.selector = attachCalendarYearSelector(this);
  }
  connect() {
    this.selector.attach();
  }
  disconnect() {
    this.selector.detach();
  }
}
