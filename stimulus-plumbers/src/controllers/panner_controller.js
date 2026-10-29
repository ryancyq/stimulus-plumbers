import { Controller } from '@hotwired/stimulus';
import { attachShifter } from '../plumbers';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    this.shifter = attachShifter(this, { element: this.hasContentTarget ? this.contentTarget : null });
  }

  disconnect() {
    this.shifter.disconnect();
  }
}
