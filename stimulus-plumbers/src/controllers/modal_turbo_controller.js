import { Controller } from '@hotwired/stimulus';

/**
 * Coordinates a Turbo Frame with the native dialog managed by modal.
 *
 * The controller deliberately delegates dialog state to the sibling modal controller.
 */
export default class extends Controller {
  static targets = ['frame'];

  static values = {
    closeOnSuccess: { type: Boolean, default: true },
  };

  _clearGeneration = 0;
  _pendingClear;
  _closingAfterSubmit = false;
  _connected = false;
  _onBeforeCache;
  _onModalOpening;
  _onModalOpened;
  _configured = false;

  connect() {
    this._clearGeneration = 0;
    this._pendingClear = null;
    this._closingAfterSubmit = false;
    this._connected = true;
    this._onBeforeCache = this._beforeCache.bind(this);
    this._onModalOpening = this._modalOpening.bind(this);
    this._onModalOpened = this._modalOpened.bind(this);
    document.addEventListener('turbo:before-cache', this._onBeforeCache);
    this.element.addEventListener('modal:before-open', this._onModalOpening);
    this.element.addEventListener('modal:opened', this._onModalOpened);

    if (!this.hasFrameTarget) {
      this._configured = false;
      console.error(
        'ModalTurboController requires a frame target. Add data-modal-turbo-target="frame" to your element.'
      );
      return;
    }

    this._configured = true;
  }

  disconnect() {
    this._connected = false;
    this._configured = false;
    this._cancelPendingClear();
    document.removeEventListener('turbo:before-cache', this._onBeforeCache);
    this.element.removeEventListener('modal:before-open', this._onModalOpening);
    this.element.removeEventListener('modal:opened', this._onModalOpened);
  }

  frameTargetConnected() {
    if (!this._closingAfterSubmit) this._cancelPendingClear();
    if (this._connected) this._configured = true;
  }

  frameTargetDisconnected() {
    if (!this._closingAfterSubmit) this._cancelPendingClear();
  }

  onFrameRender(event) {
    if (!this._configured || !this.hasFrameTarget || event.target !== this.frameTarget) return;

    if (!this.frameTarget.innerHTML.trim()) return;

    const modal = this._modalController();
    const dialog = modal?.hasDialogTarget ? modal.dialogTarget : null;
    if (dialog?.open) {
      this._cancelPendingClear();
      this._focusRenderedContent(dialog);
      return;
    }

    if (event.detail?.fetchResponse?.succeeded !== true) return;
    if (this._closingAfterSubmit) {
      if (!this._pendingClear) this._clearFrame();
      return;
    }

    this._cancelPendingClear();
    modal?.open();
  }

  onBeforeFetchRequest(event) {
    if (!this._configured || !this.hasFrameTarget) return;
    if (event.target !== this.frameTarget && !this.frameTarget.contains(event.target)) return;

    this._closingAfterSubmit = false;
  }

  onSubmitEnd(event) {
    if (!this._configured || !this.hasFrameTarget) return;

    const form = event.target;
    if (!(form instanceof HTMLFormElement) || !this.frameTarget.contains(form)) return;
    if (event.detail?.success !== true || !this.closeOnSuccessValue) return;
    const modal = this._modalController();
    if (!modal) return;

    this._closingAfterSubmit = true;
    modal.close();
  }

  onClosed(event) {
    if (!this._configured || !this.hasFrameTarget) return;

    const modal = this._modalController();
    const dialog = event.target?.closest?.('dialog') || (modal?.hasDialogTarget ? modal.dialogTarget : null);
    if (!dialog) {
      this._clearFrame();
      return;
    }

    this._cancelPendingClear();
    const generation = this._clearGeneration;
    const pendingClear = this._afterAnimations(dialog);
    this._pendingClear = pendingClear;
    pendingClear.then(() => {
      if (this._pendingClear === pendingClear) this._pendingClear = null;
      if (!this._connected || !this._configured || generation !== this._clearGeneration) return;
      this._clearFrame();
    });
  }

  _beforeCache() {
    if (!this._configured) return;

    this._cancelPendingClear();
    this._closingAfterSubmit = false;
    this._modalController()?.close();
    this._clearFrame();
  }

  _modalOpening() {
    this._closingAfterSubmit = false;
    this._cancelPendingClear();
  }

  _modalOpened() {
    this._cancelPendingClear();
  }

  _focusRenderedContent(dialog) {
    const active = document.activeElement;
    if (active === dialog || dialog.contains(active)) return;

    const autofocus = this.frameTarget.querySelector('[autofocus]');
    if (autofocus && typeof autofocus.focus === 'function') {
      autofocus.focus({ preventScroll: true });
      return;
    }

    dialog.focus?.({ preventScroll: true });
  }

  _modalController() {
    return this.application?.getControllerForElementAndIdentifier(this.element, 'modal');
  }

  _cancelPendingClear() {
    if (!this._pendingClear) return;

    this._clearGeneration += 1;
    this._pendingClear = null;
  }

  _clearFrame() {
    if (!this.hasFrameTarget) return;

    this._cancelPendingClear();
    this.frameTarget.removeAttribute('src');
    this.frameTarget.removeAttribute('complete');
    this.frameTarget.replaceChildren();
  }

  _afterAnimations(dialog) {
    return new Promise((resolve) => {
      const nextFrame = window.requestAnimationFrame || ((callback) => window.setTimeout(callback, 0));
      nextFrame(() => {
        if (typeof dialog.getAnimations !== 'function') {
          resolve();
          return;
        }

        const animations = this._exitAnimations(dialog);
        if (!animations.length) {
          resolve();
          return;
        }

        Promise.allSettled(animations.map((animation) => animation.finished)).then(() => resolve());
      });
    });
  }

  _exitAnimations(dialog) {
    return dialog.getAnimations({ subtree: true }).filter((animation) => {
      const effect = animation.effect;
      const ownedByDialog = effect?.target === dialog || effect?.pseudoElement === '::backdrop';
      if (!ownedByDialog) return false;

      const timing = effect?.getComputedTiming?.();
      return Number.isFinite(timing?.endTime);
    });
  }
}
