import { Controller } from '@hotwired/stimulus';

// Loads calendar periods through the calendar's Turbo Frame.
export default class extends Controller {
  onNavigate(event) {
    if (this._frame && event.detail?.url) this._frame.src = event.detail.url;
  }

  onResponse(event) {
    if (this._owns(event) && !event.detail?.fetchResponse?.succeeded) this.dispatch('failed');
  }

  // Keeps the current grid when the response has no matching frame.
  onError(event) {
    if (!this._owns(event)) return;

    if (event.type === 'turbo:frame-missing') event.preventDefault();
    this.dispatch('failed');
  }

  get _frame() {
    return this.element.querySelector('turbo-frame');
  }

  _owns(event) {
    return event.target.closest?.('turbo-frame') === this._frame;
  }
}
