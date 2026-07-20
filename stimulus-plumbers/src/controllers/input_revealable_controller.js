import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['input', 'toggle', 'revealIcon', 'concealIcon'];
  static values = {
    revealed: { type: Boolean, default: false },
    revealLabel: { type: String, default: '' },
    concealLabel: { type: String, default: '' },
  };

  toggle() {
    this.revealedValue = !this.revealedValue;
  }

  revealedValueChanged() {
    this.draw();
  }

  draw() {
    if (this.hasInputTarget) this.inputTarget.type = this.revealedValue ? 'text' : 'password';
    if (!this.hasToggleTarget) return;

    // Icons swap as a pair; a lone icon stays visible rather than emptying the button.
    if (this.hasRevealIconTarget && this.hasConcealIconTarget) {
      setHidden(this.revealIconTarget, this.revealedValue);
      setHidden(this.concealIconTarget, !this.revealedValue);
    }

    const label = this.revealedValue ? this.concealLabelValue : this.revealLabelValue;
    if (label) this.toggleTarget.setAttribute('aria-label', label);
  }
}
