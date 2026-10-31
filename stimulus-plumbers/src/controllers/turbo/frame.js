import { Controller } from '@hotwired/stimulus';

// Reports a Turbo Frame load that fails, returns no HTML, or has no matching frame.
// Subclasses define `_frame` and `_failed()`.
export default class extends Controller {
  onResponse(event) {
    if (!this._owns(event)) return;

    const response = event.detail?.fetchResponse;
    if (!response?.succeeded || !response.isHTML) this._failed();
  }

  // Keeps the current content when the response has no matching frame.
  onError(event) {
    if (!this._owns(event)) return;

    if (event.type === 'turbo:frame-missing') event.preventDefault();
    this._failed();
  }

  _owns(event) {
    return Boolean(this._frame) && event.target.closest?.('turbo-frame') === this._frame;
  }
}
