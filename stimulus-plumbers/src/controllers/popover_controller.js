import { Controller } from '@hotwired/stimulus';
import { attachPopover, isPopoverElement } from '../plumbers/popover';

export default class extends Controller {
  static targets = ['trigger', 'panel'];

  connect() {
    this.connection = new AbortController();
    document.addEventListener('turbo:before-cache', () => this._closeForCache(), { signal: this.connection.signal });

    if (!this.hasPanelTarget) this._reportInvalidConfiguration('missing');
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
    this._disposePopover();
  }

  panelTargetConnected(panel) {
    this._disposePopover();

    if (!isPopoverElement(panel)) {
      this._reportInvalidConfiguration(panel);
      return;
    }

    this.reportedConfiguration = null;
    this.popover = attachPopover(this, { element: panel });
    this.panelElement = panel;
    this.panelListeners = new AbortController();
    const { signal } = this.panelListeners;
    panel.addEventListener('popover:opened', (event) => event.target === panel && this._syncTrigger(true), { signal });
    panel.addEventListener('popover:closed', (event) => event.target === panel && this._syncTrigger(false), { signal });
    this._syncTrigger();
  }

  panelTargetDisconnected(panel) {
    if (this.panelElement !== panel) return;

    this._disposePopover();
  }

  triggerTargetConnected() {
    this._syncTrigger();
  }

  open(event) {
    this._preventDefault(event);
    this.popover?.show(this._sourceFor(event));
  }

  close(event) {
    this._preventDefault(event);
    this.popover?.hide();
  }

  toggle(event) {
    this._preventDefault(event);
    this.popover?.toggle(this._sourceFor(event));
  }

  _closeForCache() {
    if (this.popover?.open) this.popover.hide();
  }

  _disposePopover() {
    this.panelListeners?.abort();
    this.panelListeners = null;
    this.popover?.disconnect();
    this.popover = null;
    this.panelElement = null;
  }

  _preventDefault(event) {
    if (event && typeof event.preventDefault === 'function') event.preventDefault();
  }

  _sourceFor(event) {
    if (event && typeof event.preventDefault === 'function' && event.currentTarget) return event.currentTarget;
    return this.hasTriggerTarget ? this.triggerTarget : undefined;
  }

  _syncTrigger(open = this.popover?.open === true) {
    if (!this.hasTriggerTarget || !this.triggerTarget.hasAttribute('aria-expanded')) return;

    this.triggerTarget.setAttribute('aria-expanded', String(open));
  }

  _reportInvalidConfiguration(configuration) {
    if (this.reportedConfiguration === configuration) return;

    this.reportedConfiguration = configuration;
    if (configuration === 'missing') {
      console.error('PopoverController requires a panel target. Add data-popover-target="panel" to your element.');
    } else {
      console.error('PopoverController requires data-popover-target="panel" to be a native popover element.');
    }
  }
}
