import { Controller } from '@hotwired/stimulus';
import { setPressed } from '../aria';
import { attachInputFormat } from '../plumbers';

export default class InputFormatController extends Controller {
  static targets = ['input', 'toggle'];
  static values = {
    type: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    revealed: { type: Boolean, default: false },
  };

  connect() {
    attachInputFormat(this, { type: this.typeValue, options: this.optionsValue });
    this.format(this.readValue());
    this.drawToggle();
  }

  typeValueChanged() {
    if (!this.inputFormat) return;
    attachInputFormat(this, { type: this.typeValue, options: this.optionsValue });
    this.format(this.readValue());
    this.drawToggle();
  }

  optionsValueChanged() {
    if (!this.inputFormat) return;
    attachInputFormat(this, { type: this.typeValue, options: this.optionsValue });
    this.format(this.readValue());
  }

  revealedValueChanged() {
    if (!this.inputFormat) return;
    this.format(this.readValue());
    this.drawToggle();
  }

  // Event adapter — wired via data-action="input-combobox:changed->input-format#onChange"
  onChange(event) {
    this.format(event?.detail?.value ?? '');
  }

  // Programmatic API — formats and writes a raw value
  format(value) {
    if (!this.inputFormat) return;
    this.onFormatting(value);
  }

  toggle() {
    if (!this.inputFormat.maskable() && this.typeValue !== 'password') return;
    this.revealedValue = !this.revealedValue;
  }

  // Event adapter — wired via data-action="clipboard:pasted->input-format#onPaste"
  onPaste(event) {
    const raw = event.detail?.text ?? '';
    if (!this.inputFormat || !raw) return;
    const value = this.inputFormat.normalize(raw);
    if (!this.inputFormat.validate(value)) return;
    this.format(value);
  }

  drawToggle() {
    if (!this.hasToggleTarget) return;
    const hasToggleBehavior = this.inputFormat?.maskable() || this.typeValue === 'password';
    this.toggleTarget.hidden = !hasToggleBehavior;
    if (hasToggleBehavior) setPressed(this.toggleTarget, this.revealedValue);
  }

  readValue() {
    if (!this.hasInputTarget) return '';
    return this.inputTarget instanceof HTMLInputElement ? this.inputTarget.value : this.inputTarget.textContent;
  }

  onFormatting(raw) {
    if (!this.inputFormat) return;

    if (this.typeValue === 'password') {
      if (this.hasInputTarget) this.inputTarget.type = this.revealedValue ? 'text' : 'password';
      return;
    }

    const value = this.inputFormat.normalize(raw);
    const formatted =
      this.revealedValue || !this.inputFormat.maskable()
        ? this.inputFormat.format(value)
        : this.inputFormat.mask(value);

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
