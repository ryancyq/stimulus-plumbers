import { Controller } from '@hotwired/stimulus';
import { attachFormatter } from '../plumbers';

export default class extends Controller {
  static targets = ['input'];
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
  };

  connect() {
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.primeFilledState();
    this.format(this.readValue());
  }

  formatValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.primeFilledState();
    this.format(this.readValue());
  }

  optionsValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.primeFilledState();
    this.format(this.readValue());
  }

  onChange(event) {
    this.format(event?.detail?.value ?? '');
  }

  format(value) {
    if (!this.formatter) return;
    this._writeFormatted(value);
  }

  onPaste(event) {
    const raw = event.detail?.text ?? '';
    if (!this.formatter || !raw) return;
    const value = this.formatter.normalize(raw);
    if (!this.formatter.validate(value)) return;
    event.preventDefault();
    this.format(value);
  }

  onInput() {
    if (!this.formatter) return;
    this._writeFormatted(this.readValue(), this._keptBeforeCaret());
  }

  // When the value is at its cap, a typed character replaces the one after the caret.
  onBeforeinput(event) {
    if (!this.formatter || event.inputType !== 'insertText' || !event.data) return;
    const { selectionStart, selectionEnd } = this.inputTarget;
    const value = this.formatter.normalize(this.readValue());
    const typed = this.formatter.normalize(event.data);
    if (selectionStart !== selectionEnd || typed === '' || this.formatter.normalize(value + typed) !== value) return;

    event.preventDefault();
    const kept = this._keptBeforeCaret();
    if (kept === null || kept >= value.length) return;
    this._writeFormatted(value.slice(0, kept) + typed + value.slice(kept + typed.length), kept + typed.length);
  }

  // Reformats without dispatching `filled`.
  onFormReset() {
    this.primeFilledState();
    this.format(this.readValue());
  }

  readValue() {
    if (!this.hasInputTarget) return '';
    return this.inputTarget instanceof HTMLInputElement ? this.inputTarget.value : this.inputTarget.textContent;
  }

  // The characters normalize keeps before the caret, or null while the input has no caret.
  _keptBeforeCaret() {
    if (!this.formatter || !this.hasInputTarget || document.activeElement !== this.inputTarget) return null;
    const { selectionStart, value } = this.inputTarget;
    return selectionStart === null ? null : this.formatter.normalize(value.slice(0, selectionStart)).length;
  }

  // Moves the caret to just after the `kept`-th kept character.
  _placeCaret(kept) {
    const { value } = this.inputTarget;
    let offset = 0;
    while (offset < value.length && this.formatter.normalize(value.slice(0, offset)).length < kept) offset += 1;
    this.inputTarget.setSelectionRange(offset, offset);
  }

  // A `kept` count puts the caret after that many kept characters before `formatted` dispatches.
  _writeFormatted(raw, kept = null) {
    if (!this.formatter) return;

    const value = this.formatter.normalize(raw);
    const formatted = this.formatter.format(value);

    if (this.hasInputTarget) {
      if (this.inputTarget instanceof HTMLInputElement) {
        this.inputTarget.value = formatted;
        if (kept !== null) this._placeCaret(kept);
      } else {
        this.inputTarget.textContent = formatted;
      }
    }

    this.dispatch('formatted', { detail: { value: formatted } });

    const full = this.isFull(value);
    if (full && !this.wasFull) {
      this.dispatch('filled', { detail: { value } });
    }
    this.wasFull = full;
  }

  isFull(value) {
    const length = this.formatter.filledLength(value);
    return length > 0 && value.length === length && this.formatter.validate(value);
  }

  /** Records the current filled state without dispatching, so system-driven (re)draws
   *  — connect with a prefilled value, format/options changes — never fire `filled` on
   *  their own; only a subsequent user-driven transition into "full" does. */
  primeFilledState() {
    this.wasFull = this.isFull(this.formatter.normalize(this.readValue()));
  }
}
