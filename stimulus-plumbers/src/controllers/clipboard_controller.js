import { Controller } from '@hotwired/stimulus';

export default class ClipboardController extends Controller {
  static targets = ['source'];
  static values = {
    type: { type: String, default: 'text/plain' },
  };

  onPaste(event) {
    const text = event.clipboardData?.getData(this.typeValue) ?? '';
    const types = Array.from(event.clipboardData?.types ?? []);
    event.preventDefault();
    this.dispatch('pasted', { detail: { text, types }, bubbles: true });
  }

  async copy(event) {
    const text =
      event.params?.text ??
      (this.hasSourceTarget ? (this.sourceTarget.value ?? this.sourceTarget.textContent ?? '') : '');
    try {
      await navigator.clipboard.writeText(text);
      this.dispatch('copied', { detail: { text }, bubbles: true });
    } catch (error) {
      this.dispatch('copy-failed', { detail: { error }, bubbles: true });
    }
  }
}
