import { Controller } from '@hotwired/stimulus';

export default class InputSearchController extends Controller {
  static targets = ['input', 'clear'];

  initialize() {
    this.onInput = this.draw.bind(this);
    this.onEscape = this.handleEscape.bind(this);
  }

  connect() {
    this.draw();
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
    this.draw();
    this.inputTarget.focus();
    this.inputTarget.dispatchEvent(new Event('input', { bubbles: true }));
  }

  draw() {
    if (!this.hasInputTarget || !this.hasClearTarget) return;
    this.clearTarget.hidden = this.inputTarget.value.length === 0;
  }

  handleEscape(event) {
    if (event.key !== 'Escape') return;
    if (this.inputTarget.value === '') return;
    event.preventDefault();
    this.clear();
  }
}
