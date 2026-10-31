import TurboFrame from './turbo/frame';

export default class extends TurboFrame {
  static targets = ['frame', 'status'];
  static values = {
    src: String,
    param: { type: String, default: 'q' },
    delay: { type: Number, default: 300 },
    loadingText: { type: String, default: 'Loading…' },
    errorText: { type: String, default: 'Results could not be loaded' },
  };

  disconnect() {
    clearTimeout(this.timer);
  }

  onQuery(event) {
    if (event.target !== this.element || !this.hasFrameTarget) return;

    const { query } = event.detail;
    this._cancel();
    this._setStatus(this.loadingTextValue);
    if (query) this.timer = setTimeout(() => this._navigate(query), this.delayValue);
    else this._navigate(query);
  }

  // Fired by the panel; ignore nested comboboxes.
  onClosed(event) {
    if (event.target.closest('[data-controller~="combobox"]') !== this.element) return;

    this._cancel();
  }

  // Removing src cancels Turbo's in-flight request.
  _cancel() {
    clearTimeout(this.timer);
    if (this.hasFrameTarget) this.frameTarget.removeAttribute('src');
  }

  _navigate(query) {
    const url = new URL(this.srcValue, window.location.href);
    if (query) url.searchParams.set(this.paramValue, query);
    this.frameTarget.setAttribute('src', url.href);
  }

  get _frame() {
    return this.hasFrameTarget ? this.frameTarget : null;
  }

  _failed() {
    this._setStatus(this.errorTextValue);
  }

  _setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text;
  }
}
