import { Controller } from '@hotwired/stimulus';
import { attachDialog } from '../plumbers/dialog';

export default class extends Controller {
  static targets = ['dialog'];

  _dialog;
  _dialogElement;
  _onBeforeCache;

  connect() {
    this._onBeforeCache = this._closeForCache.bind(this);
    document.addEventListener('turbo:before-cache', this._onBeforeCache);

    if (!this.hasDialogTarget) {
      console.error('ModalController requires a dialog target. Add data-modal-target="dialog" to your element.');
    }
  }

  disconnect() {
    document.removeEventListener('turbo:before-cache', this._onBeforeCache);
    this._dialog?.disconnect();
    this._dialog = null;
    this._dialogElement = null;
  }

  dialogTargetConnected(dialog) {
    if (!(typeof HTMLDialogElement !== 'undefined' && dialog instanceof HTMLDialogElement)) {
      console.error('ModalController requires data-modal-target="dialog" to be a native <dialog> element.');
      return;
    }

    this._dialog?.disconnect();
    this._dialog = attachDialog(this, { element: dialog });
    this._dialogElement = dialog;
  }

  dialogTargetDisconnected(dialog) {
    if (!this._dialog || this._dialogElement !== dialog) return;
    this._dialog.disconnect();
    this._dialog = null;
    this._dialogElement = null;
  }

  onOpen(event) {
    event.preventDefault();
    this.open(event.currentTarget);
  }

  onDismiss(event) {
    event.preventDefault();
    this.dismiss(event.params?.result);
  }

  onClose(event) {
    event.preventDefault();
    this.close(event.params?.result);
  }

  open(source) {
    this._dialog?.show(source);
  }

  dismiss(result) {
    this._dialog?.dismiss(result);
  }

  close(result) {
    this._dialog?.close(result);
  }

  _closeForCache() {
    if (this._dialog?.open) this._dialog.close();
  }
}
