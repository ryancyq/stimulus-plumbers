import { Controller } from '@hotwired/stimulus';
import { setPressed } from '../accessibility/aria';
import { attachFormatter } from '../plumbers';

export default class extends Controller {
  static targets = ['input', 'toggle'];
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    revealed: { type: Boolean, default: false },
  };

  connect() {
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.format(this.readValue());
    this.drawToggle();
  }

  formatValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.format(this.readValue());
    this.drawToggle();
  }

  optionsValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.format(this.readValue());
  }

  revealedValueChanged() {
    if (!this.formatter) return;
    this.format(this.readValue());
    this.drawToggle();
  }

  onChange(event) {
    this.format(event?.detail?.value ?? '');
  }

  format(value) {
    if (!this.formatter) return;
    this.onFormatting(value);
  }

  toggle() {
    if (!this.formatter.maskable() && this.formatValue !== 'password') return;
    this.revealedValue = !this.revealedValue;
  }

  onPaste(event) {
    const raw = event.detail?.text ?? '';
    if (!this.formatter || !raw) return;
    const value = this.formatter.normalize(raw);
    if (!this.formatter.validate(value)) return;
    this.format(value);
  }

  drawToggle() {
    if (!this.hasToggleTarget) return;
    const hasToggleBehavior = this.formatter?.maskable() || this.formatValue === 'password';
    this.toggleTarget.hidden = !hasToggleBehavior;
    if (hasToggleBehavior) setPressed(this.toggleTarget, this.revealedValue);
  }

  readValue() {
    if (!this.hasInputTarget) return '';
    return this.inputTarget instanceof HTMLInputElement ? this.inputTarget.value : this.inputTarget.textContent;
  }

  onFormatting(raw) {
    if (!this.formatter) return;

    if (this.formatValue === 'password') {
      if (this.hasInputTarget) this.inputTarget.type = this.revealedValue ? 'text' : 'password';
      return;
    }

    const value = this.formatter.normalize(raw);
    const formatted =
      this.revealedValue || !this.formatter.maskable() ? this.formatter.format(value) : this.formatter.mask(value);

    if (this.hasInputTarget) {
      if (this.inputTarget instanceof HTMLInputElement) {
        this.inputTarget.value = formatted;
      } else {
        this.inputTarget.textContent = formatted;
      }
    }

    this.dispatch('formatted', { detail: { value: formatted } });
  }
}
