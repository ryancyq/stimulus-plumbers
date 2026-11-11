import { Controller } from '@hotwired/stimulus';
import { attachDismisser } from '../plumbers';

export default class extends Controller {
  static targets = ['trigger'];

  connect() {
    this.dismisser = attachDismisser(this, { trigger: this.hasTriggerTarget ? this.triggerTarget : null });
  }

  disconnect() {
    this.dismisser.disconnect();
  }
}
