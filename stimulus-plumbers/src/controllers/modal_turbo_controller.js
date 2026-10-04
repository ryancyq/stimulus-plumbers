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

  #clearGeneration = 0;
  #pendingClear;
  #closingAfterSubmit = false;
  #connected = false;
  #onBeforeCache;
  #onModalOpening;
  #onModalOpened;
  #configured = false;

  connect() {
    this.#clearGeneration = 0;
    this.#pendingClear = null;
    this.#closingAfterSubmit = false;
    this.#connected = true;
    this.#onBeforeCache = this.#beforeCache.bind(this);
    this.#onModalOpening = this.#modalOpening.bind(this);
    this.#onModalOpened = this.#modalOpened.bind(this);
    document.addEventListener('turbo:before-cache', this.#onBeforeCache);
    this.element.addEventListener('modal:before-open', this.#onModalOpening);
    this.element.addEventListener('modal:opened', this.#onModalOpened);

    if (!this.hasFrameTarget) {
      this.#configured = false;
      console.error(
        'ModalTurboController requires a frame target. Add data-modal-turbo-target="frame" to your element.'
      );
      return;
    }

    this.#configured = true;
  }

  disconnect() {
    this.#connected = false;
    this.#configured = false;
    this.#cancelPendingClear();
    document.removeEventListener('turbo:before-cache', this.#onBeforeCache);
    this.element.removeEventListener('modal:before-open', this.#onModalOpening);
    this.element.removeEventListener('modal:opened', this.#onModalOpened);
  }

  frameTargetConnected() {
    if (!this.#closingAfterSubmit) this.#cancelPendingClear();
    if (this.#connected) this.#configured = true;
  }

  frameTargetDisconnected() {
    if (!this.#closingAfterSubmit) this.#cancelPendingClear();
  }

  onFrameRender(event) {
    if (!this.#configured || !this.hasFrameTarget || event.target !== this.frameTarget) return;

    if (!this.frameTarget.innerHTML.trim()) return;

    const modal = this.#modalController();
    const dialog = modal?.hasDialogTarget ? modal.dialogTarget : null;
    if (dialog?.open) {
      this.#cancelPendingClear();
      this.#focusRenderedContent(dialog);
      return;
    }

    if (event.detail?.fetchResponse?.succeeded !== true) return;
    if (this.#closingAfterSubmit) {
      if (!this.#pendingClear) this.#clearFrame();
      return;
    }

    this.#cancelPendingClear();
    modal?.open();
  }

  onBeforeFetchRequest(event) {
    if (!this.#configured || !this.hasFrameTarget) return;
    if (event.target !== this.frameTarget && !this.frameTarget.contains(event.target)) return;

    this.#closingAfterSubmit = false;
  }

  onSubmitEnd(event) {
    if (!this.#configured || !this.hasFrameTarget) return;

    const form = event.target;
    if (!(form instanceof HTMLFormElement) || !this.frameTarget.contains(form)) return;
    if (event.detail?.success !== true || !this.closeOnSuccessValue) return;
    const modal = this.#modalController();
    if (!modal) return;

    this.#closingAfterSubmit = true;
    modal.close();
  }

  onClosed(event) {
    if (!this.#configured || !this.hasFrameTarget) return;

    const modal = this.#modalController();
    const dialog = event.target?.closest?.('dialog') || (modal?.hasDialogTarget ? modal.dialogTarget : null);
    if (!dialog) {
      this.#clearFrame();
      return;
    }

    this.#cancelPendingClear();
    const generation = this.#clearGeneration;
    const pendingClear = this.#afterAnimations(dialog);
    this.#pendingClear = pendingClear;
    pendingClear.then(() => {
      if (this.#pendingClear === pendingClear) this.#pendingClear = null;
      if (!this.#connected || !this.#configured || generation !== this.#clearGeneration) return;
      this.#clearFrame();
    });
  }

  #beforeCache() {
    if (!this.#configured) return;

    this.#cancelPendingClear();
    this.#closingAfterSubmit = false;
    this.#modalController()?.close();
    this.#clearFrame();
  }

  #modalOpening() {
    this.#closingAfterSubmit = false;
    this.#cancelPendingClear();
  }

  #modalOpened() {
    this.#cancelPendingClear();
  }

  #focusRenderedContent(dialog) {
    const active = document.activeElement;
    if (active === dialog || dialog.contains(active)) return;

    const autofocus = this.frameTarget.querySelector('[autofocus]');
    if (autofocus && typeof autofocus.focus === 'function') {
      autofocus.focus({ preventScroll: true });
      return;
    }

    dialog.focus?.({ preventScroll: true });
  }

  #modalController() {
    return this.application?.getControllerForElementAndIdentifier(this.element, 'modal');
  }

  #cancelPendingClear() {
    if (!this.#pendingClear) return;

    this.#clearGeneration += 1;
    this.#pendingClear = null;
  }

  #clearFrame() {
    if (!this.hasFrameTarget) return;

    this.#cancelPendingClear();
    this.frameTarget.removeAttribute('src');
    this.frameTarget.removeAttribute('complete');
    this.frameTarget.replaceChildren();
  }

  #afterAnimations(dialog) {
    return new Promise((resolve) => {
      const nextFrame = window.requestAnimationFrame || ((callback) => window.setTimeout(callback, 0));
      nextFrame(() => {
        if (typeof dialog.getAnimations !== 'function') {
          resolve();
          return;
        }

        const animations = this.#exitAnimations(dialog);
        if (!animations.length) {
          resolve();
          return;
        }

        Promise.allSettled(animations.map((animation) => animation.finished)).then(() => resolve());
      });
    });
  }

  #exitAnimations(dialog) {
    return dialog.getAnimations({ subtree: true }).filter((animation) => {
      const effect = animation.effect;
      const ownedByDialog = effect?.target === dialog || effect?.pseudoElement === '::backdrop';
      if (!ownedByDialog) return false;

      const timing = effect?.getComputedTiming?.();
      return Number.isFinite(timing?.endTime);
    });
  }
}
