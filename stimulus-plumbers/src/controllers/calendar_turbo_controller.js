import { Controller } from '@hotwired/stimulus';
import { isFailedResponse, isFrameEvent } from '../plumbers/plumber/turbo_frame';

// Loads calendar periods through the calendar's Turbo Frame.
export default class extends Controller {
  onNavigate(event) {
    if (this._frame && event.detail?.url) this._frame.src = event.detail.url;
  }

  onResponse(event) {
    if (isFrameEvent(event, this._frame) && isFailedResponse(event)) this.dispatch('failed');
  }

  // Keeps the current grid when the response has no matching frame.
  onError(event) {
    if (!isFrameEvent(event, this._frame)) return;

    if (event.type === 'turbo:frame-missing') event.preventDefault();
    this.dispatch('failed');
  }

  get _frame() {
    return this.element.querySelector('turbo-frame');
  }
}
