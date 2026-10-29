import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['input', 'toggle', 'revealIcon', 'concealIcon'];
  static values = {
    revealed: { type: Boolean, default: false },
    revealLabel: { type: String, default: '' },
    concealLabel: { type: String, default: '' },
  };

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;
    document.addEventListener('turbo:before-cache', () => this._conceal(), { signal });
    window.addEventListener('pagehide', () => this._conceal(), { signal });
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  toggle() {
    this.revealedValue = !this.revealedValue;
  }

  // Draws synchronously, before the page is cached.
  _conceal() {
    this.revealedValue = false;
    this.draw();
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
