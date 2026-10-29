import { Controller } from '@hotwired/stimulus';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['status'];
  static values = {
    src: String,
    param: { type: String, default: 'q' },
    delay: { type: Number, default: 300 },
    loadingText: { type: String, default: 'Loading…' },
    errorText: { type: String, default: 'Results could not be loaded' },
  };

  connect() {
    this._requestor = new Requestor();
  }

  disconnect() {
    this._requestor.cancel();
  }

  onQuery(event) {
    if (event.target !== this.element) return;

    const { query } = event.detail;
    this._requestor.cancel();
    this._setStatus(this.loadingTextValue);
    this._requestor.schedule(() => this._load(query), query ? this.delayValue : 0);
  }

  // Fired by the panel; ignore nested comboboxes.
  onClosed(event) {
    if (event.target.closest('[data-controller~="combobox"]') !== this.element) return;

    this._requestor.cancel();
  }

  async _load(query) {
    const listbox = this.element.querySelector('[role="listbox"]');
    if (!listbox) return;

    const url = new URL(this.srcValue, window.location.href);
    if (query) url.searchParams.set(this.paramValue, query);
    listbox.setAttribute('aria-busy', 'true');
    try {
      const response = await this._requestor.request(url, { headers: { Accept: 'text/html' } });
      const template = document.createElement('template');
      template.innerHTML = await response.text();
      const replacement = template.content.getElementById(listbox.id);
      if (!replacement) throw new Error(`Response has no #${listbox.id}`);
      listbox.replaceWith(replacement);
    } catch (error) {
      listbox.removeAttribute('aria-busy');
      // A newer query or closing aborted this one.
      if (error.name !== 'AbortError') this._setStatus(this.errorTextValue);
    }
  }

  _setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text;
  }
}
