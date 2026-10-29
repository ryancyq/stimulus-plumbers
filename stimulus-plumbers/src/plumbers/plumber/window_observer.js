import Plumber from './index';

export default class WindowObserver extends Plumber {
  observe(handler) {
    this.listeners = new AbortController();
    const { signal } = this.listeners;
    this.events.forEach((e) => window.addEventListener(e, handler, { capture: true, signal }));
  }

  /**
   * Removes the window listeners. The owning controller calls this when its lifetime ends.
   */
  disconnect() {
    this.listeners?.abort();
    this.listeners = null;
  }
}
