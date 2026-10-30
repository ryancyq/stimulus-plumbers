import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['input', 'clear'];

  initialize() {
    this.onInput = this._syncClear.bind(this);
    this.onEscape = this._handleEscape.bind(this);
  }

  connect() {
    this._syncClear();
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
    this._syncClear();
    this.inputTarget.focus();
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }));
  }

  _syncClear() {
    if (!this.hasInputTarget || !this.hasClearTarget) return;
    setHidden(this.clearTarget, this.inputTarget.value.length === 0);
  }

  _handleEscape(event) {
    if (event.key !== 'Escape') return;
    if (this.inputTarget.value === '') return;
    event.preventDefault();
    this.clear();
  }
}
