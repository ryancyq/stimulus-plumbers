import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['source'];
  static values = {
    contentType: { type: String, default: 'text/plain' },
  };

  onPaste(event) {
    const text = event.clipboardData?.getData(this.contentTypeValue) ?? '';
    const types = Array.from(event.clipboardData?.types ?? []);
    const pasted = this.dispatch('pasted', { detail: { text, types }, bubbles: true, cancelable: true });
    if (pasted.defaultPrevented) event.preventDefault();
  }

  onCopy(event) {
    this.copy(event.params?.text);
  }

  async copy(text) {
    const value = text ?? this._sourceText();
    if (!value) {
      this.dispatch('copy-failed', { detail: { error: new Error('Nothing to copy') }, bubbles: true });
      return;
    }

    try {
      await navigator.clipboard.writeText(value);
      this.dispatch('copied', { detail: { text: value }, bubbles: true });
    } catch (error) {
      this.dispatch('copy-failed', { detail: { error }, bubbles: true });
    }
  }

  _sourceText() {
    if (!this.hasSourceTarget) return '';
    return this.sourceTarget.value ?? this.sourceTarget.textContent ?? '';
  }
}
