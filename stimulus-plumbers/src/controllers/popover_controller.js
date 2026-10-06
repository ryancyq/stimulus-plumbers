import { Controller } from '@hotwired/stimulus';
import { attachPopover } from '../plumbers/popover';

const isNativePopover = (element) =>
  typeof HTMLElement !== 'undefined' &&
  element instanceof HTMLElement &&
  element.hasAttribute('popover') &&
  typeof element.showPopover === 'function' &&
  typeof element.hidePopover === 'function' &&
  typeof element.togglePopover === 'function';

export default class extends Controller {
  static targets = ['trigger', 'panel'];

  #popover;
  #panelElement;
  #onBeforeCache;
  #onOpened;
  #onClosed;
  #reportedInvalidConfiguration;

  connect() {
    if (this.#onBeforeCache) document.removeEventListener('turbo:before-cache', this.#onBeforeCache);
    this.#onBeforeCache = this.#closeForCache.bind(this);
    document.addEventListener('turbo:before-cache', this.#onBeforeCache);

    if (!this.hasPanelTarget) this.#reportInvalidConfiguration('missing');
  }

  disconnect() {
    if (this.#onBeforeCache) {
      document.removeEventListener('turbo:before-cache', this.#onBeforeCache);
      this.#onBeforeCache = null;
    }

    this.#disposePopover();
  }

  panelTargetConnected(panel) {
    this.#disposePopover();

    if (!isNativePopover(panel)) {
      this.#reportInvalidConfiguration(panel);
      return;
    }

    this.#reportedInvalidConfiguration = null;
    this.#popover = attachPopover(this, { element: panel });
    this.#panelElement = panel;
    this.#onOpened = this.#syncOpened.bind(this);
    this.#onClosed = this.#syncClosed.bind(this);
    panel.addEventListener('popover:opened', this.#onOpened);
    panel.addEventListener('popover:closed', this.#onClosed);
    this.#syncTrigger();
  }

  panelTargetDisconnected(panel) {
    if (this.#panelElement !== panel) return;

    this.#disposePopover();
  }

  triggerTargetConnected() {
    this.#syncTrigger();
  }

  open(event) {
    this.#preventDefault(event);
    this.#popover?.show(this.#sourceFor(event));
  }

  close(event) {
    this.#preventDefault(event);
    this.#popover?.hide();
  }

  toggle(event) {
    this.#preventDefault(event);
    this.#popover?.toggle(this.#sourceFor(event));
  }

  #closeForCache() {
    if (this.#popover?.open) this.#popover.hide();
  }

  #disposePopover() {
    if (this.#panelElement && this.#onOpened) this.#panelElement.removeEventListener('popover:opened', this.#onOpened);
    if (this.#panelElement && this.#onClosed) this.#panelElement.removeEventListener('popover:closed', this.#onClosed);
    this.#popover?.disconnect();
    this.#popover = null;
    this.#panelElement = null;
    this.#onOpened = null;
    this.#onClosed = null;
  }

  #preventDefault(event) {
    if (event && typeof event.preventDefault === 'function') event.preventDefault();
  }

  #sourceFor(event) {
    if (event && typeof event.preventDefault === 'function' && event.currentTarget) return event.currentTarget;
    return this.hasTriggerTarget ? this.triggerTarget : undefined;
  }

  #syncOpened(event) {
    if (event.target !== this.#panelElement) return;
    this.#syncTrigger(true);
  }

  #syncClosed(event) {
    if (event.target !== this.#panelElement) return;
    this.#syncTrigger(false);
  }

  #syncTrigger(open = this.#popover?.open === true) {
    if (!this.hasTriggerTarget || !this.triggerTarget.hasAttribute('aria-expanded')) return;

    this.triggerTarget.setAttribute('aria-expanded', String(open));
  }

  #reportInvalidConfiguration(configuration) {
    if (this.#reportedInvalidConfiguration === configuration) return;

    this.#reportedInvalidConfiguration = configuration;
    if (configuration === 'missing') {
      console.error('PopoverController requires a panel target. Add data-popover-target="panel" to your element.');
    } else {
      console.error('PopoverController requires data-popover-target="panel" to be a native popover element.');
    }
  }
}
