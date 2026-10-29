import { Controller } from '@hotwired/stimulus';
import { attachDismisser, attachVisibility, attachShifter } from '../plumbers';

export default class extends Controller {
  static targets = ['content', 'trigger'];

  connect() {
    this.dismisser = attachDismisser(this, { visible: '_contentVisible' });
  }

  disconnect() {
    this.dismisser.disconnect();
    this._disposeShifter();
  }

  contentTargetConnected(target) {
    this._disposeShifter();
    this.shifter = attachShifter(this, { element: target });
    this._attachVisibility(target);
  }

  triggerTargetConnected() {
    if (this.hasContentTarget) this._attachVisibility(this.contentTarget);
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

  _attachVisibility(element) {
    attachVisibility(this, { element, activator: this.hasTriggerTarget ? this.triggerTarget : null });
  }

  _disposeShifter() {
    this.shifter?.disconnect();
    this.shifter = null;
  }

  _contentVisible() {
    return this.hasContentTarget && this.visibility.visible;
  }
}
