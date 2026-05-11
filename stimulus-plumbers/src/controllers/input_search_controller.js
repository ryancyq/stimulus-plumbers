import { Controller } from '@hotwired/stimulus';

export default class InputSearchController extends Controller {
  static targets = ['input', 'clear'];

  connect() {
    this.draw();
    this.onEscape = this.handleEscape.bind(this);
    this.inputTarget.addEventListener('keydown', this.onEscape);
  }

  disconnect() {
    if (this.hasInputTarget) {
      this.inputTarget.removeEventListener('keydown', this.onEscape);
    }
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
