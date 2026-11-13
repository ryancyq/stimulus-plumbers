import { Controller } from '@hotwired/stimulus';
import { attachPopover, isPopoverElement } from '../plumbers/popover';

export default class extends Controller {
  static targets = ['trigger', 'panel'];

  connect() {
    this.connection = new AbortController();
    document.addEventListener('turbo:before-cache', () => this._closeForCache(), { signal: this.connection.signal });
    this.interacted = false;
    for (const type of ['pointerdown', 'keydown']) {
      document.addEventListener(type, () => (this.interacted = true), {
        capture: true,
        signal: this.connection.signal,
      });
    }

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

  onOpen(event) {
    event.preventDefault();
    this.open(event.currentTarget);
  }

  onClose(event) {
    event.preventDefault();
    this.close();
  }

  onToggle(event) {
    event.preventDefault();
    this.toggle(event.currentTarget);
  }

  open(source) {
    this.popover?.show(source ?? this._defaultSource());
  }

  close() {
    this.popover?.hide();
  }

  toggle(source) {
    this.popover?.toggle(source ?? this._defaultSource());
  }

  // Opens on focus, except before any user input since connect, when focus returns from the
  // panel, or inside an open modal.
  onFocus(event) {
    if (!this.interacted || this.panelElement?.contains(event.relatedTarget)) return;
    if (event.currentTarget.closest('dialog')?.matches(':modal')) return;

    this.open(event.currentTarget);
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

  _defaultSource() {
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
