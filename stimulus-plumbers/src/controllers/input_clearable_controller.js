import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['input', 'clear'];

  initialize() {
    this.onInput = this._draw.bind(this);
    this.onEscape = this._handleEscape.bind(this);
  }

  connect() {
    this._draw();
  }

  inputTargetConnected(input) {
    input.addEventListener('input', this.onInput);
    input.addEventListener('keydown', this.onEscape);
  }

  inputTargetDisconnected(input) {
    input.removeEventListener('input', this.onInput);
    input.removeEventListener('keydown', this.onEscape);
  }

  clear() {
    if (!this.hasInputTarget) return;
    this.inputTarget.value = '';
    this._draw();
    this.inputTarget.focus();
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }));
  }

  _draw() {
    if (!this.hasInputTarget || !this.hasClearTarget) return;
    setHidden(this.clearTarget, this.inputTarget.value.length === 0);
  }

  _handleEscape(event) {
    if (event.key !== 'Escape') return;
    // An open combobox owns Escape.
    if (event.defaultPrevented || this.inputTarget.getAttribute('aria-expanded') === 'true') return;
    if (this.inputTarget.value === '') return;
    event.preventDefault();
    this.clear();
  }
}
