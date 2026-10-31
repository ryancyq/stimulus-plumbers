import TurboFrame from './turbo/frame';

// Loads calendar periods through the calendar's Turbo Frame.
export default class extends TurboFrame {
  onNavigate(event) {
    if (this._frame && event.detail?.url) this._frame.src = event.detail.url;
  }

  get _frame() {
    return this.element.querySelector('turbo-frame');
  }

  _failed() {
    this.dispatch('failed');
  }
}
