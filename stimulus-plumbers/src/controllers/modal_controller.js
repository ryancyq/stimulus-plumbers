import { Controller } from '@hotwired/stimulus';
import { attachDialog } from '../plumbers/dialog';

export default class extends Controller {
  static targets = ['dialog'];

  #dialog;
  #dialogElement;
  #onBeforeCache;

  connect() {
    this.#onBeforeCache = this.#closeForCache.bind(this);
    document.addEventListener('turbo:before-cache', this.#onBeforeCache);

    if (!this.hasDialogTarget) {
      console.error('ModalController requires a dialog target. Add data-modal-target="dialog" to your element.');
    }
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this.#onBeforeCache);
    this.#dialog?.disconnect();
    this.#dialog = null;
    this.#dialogElement = null;
  }

  dialogTargetConnected(dialog) {
    if (!(typeof HTMLDialogElement !== 'undefined' && dialog instanceof HTMLDialogElement)) {
      console.error('ModalController requires data-modal-target="dialog" to be a native <dialog> element.');
      return;
    }

    this.#dialog?.disconnect();
    this.#dialog = attachDialog(this, { element: dialog });
    this.#dialogElement = dialog;
  }

  dialogTargetDisconnected(dialog) {
    if (!this.#dialog || this.#dialogElement !== dialog) return;
    this.#dialog.disconnect();
    this.#dialog = null;
    this.#dialogElement = null;
  }

  open(event) {
    event?.preventDefault?.();
    this.#dialog?.show(event?.currentTarget);
  }

  dismiss(eventOrResult) {
    const result = this.#resultFrom(eventOrResult);
    this.#dialog?.dismiss(result);
  }

  close(eventOrResult) {
    const result = this.#resultFrom(eventOrResult);
    this.#dialog?.close(result);
  }

  #closeForCache() {
    if (this.#dialog?.open) this.#dialog.close();
  }

  #resultFrom(eventOrResult) {
    if (eventOrResult && typeof eventOrResult.preventDefault === 'function') {
      eventOrResult.preventDefault();
      return eventOrResult.params?.result;
    }

    return eventOrResult;
  }
}
