import { Controller } from '@hotwired/stimulus';
import { attachDismisser, attachVisibility, attachShifter } from '../plumbers';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    this.dismisser = attachDismisser(this);
  }

  disconnect() {
    this.dismisser.disconnect();
    this._disposeShifter();
  }

  contentTargetConnected(target) {
    this._disposeShifter();
    this.shifter = attachShifter(this, { element: target });
    attachVisibility(this, { element: target });
  }

  contentTargetDisconnected(target) {
    if (this.shifter?.element === target) this._disposeShifter();
  }

  async dismissed() {
    if (!this.hasContentTarget) return;

    await this.visibility.hide();
  }

  async toggle() {
    if (!this.hasContentTarget) return;

    if (this.visibility.visible) {
      await this.visibility.hide();
    } else {
      await this.visibility.show();
      this.shift(this.contentTarget);
    }
  }

  _disposeShifter() {
    this.shifter?.disconnect();
    this.shifter = null;
  }
}
