import { Controller } from '@hotwired/stimulus';
import { attachFragmentLoader } from '../plumbers/fragment_loader';

export default class extends Controller {
  static targets = ['status'];
  static values = {
    src: String,
    param: { type: String, default: 'q' },
    delay: { type: Number, default: 300 },
    loadingText: { type: String, default: 'Loading…' },
    errorText: { type: String, default: 'Results could not be loaded' },
  };

  disconnect() {
    clearTimeout(this.timer);
    this.loader?.disconnect();
    this.loader = null;
  }

  onQuery(event) {
    if (event.target !== this.element) return;

    const { query } = event.detail;
    this._cancel();
    this._setStatus(this.loadingTextValue);
    this.timer = setTimeout(() => this._load(query), query ? this.delayValue : 0);
  }

  // Fired by the panel; ignore nested comboboxes.
  onClosed(event) {
    if (event.target.closest('[data-controller~="combobox"]') !== this.element) return;

    this._cancel();
  }

  async _load(query) {
    const url = new URL(this.srcValue, window.location.href);
    if (query) url.searchParams.set(this.paramValue, query);
    try {
      await this._loader.load(url);
    } catch {
      this._setStatus(this.errorTextValue);
    }
  }

  _cancel() {
    clearTimeout(this.timer);
    this.loader?.cancel();
  }

  get _loader() {
    if (!this.loader?.element?.isConnected) {
      this.loader?.disconnect();
      this.loader = attachFragmentLoader(this, { element: this.element.querySelector('[role="listbox"]') });
    }
    return this.loader;
  }

  _setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text;
  }
}
