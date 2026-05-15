import Plumber from './index';

export default class WindowObserver extends Plumber {
  observe(handler) {
    this._handler = handler;
    this.events.forEach((e) => window.addEventListener(e, handler, true));
  }

  unobserve() {
    if (!this._handler) return;
    this.events.forEach((e) => window.removeEventListener(e, this._handler, true));
  }

  enhance() {
    const context = this;
    const superDisconnect = this.controller.disconnect?.bind(this.controller) || (() => {});
    this.controller.disconnect = () => {
      context.unobserve();
      superDisconnect();
    };
  }
}
