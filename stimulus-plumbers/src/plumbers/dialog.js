const defaultOptions = {
  prefix: 'modal',
};

const isDialogElement = (element) => typeof HTMLDialogElement !== 'undefined' && element instanceof HTMLDialogElement;

const normalizeResult = (result) => (result == null ? '' : String(result));

/**
 * Adapts a native <dialog> element to the modal lifecycle.
 *
 * Native dialog events remain the source of truth for opened and closed
 * notifications. The pointer and requestClose fallbacks only fill platform
 * gaps; they do not replace native dialog state.
 */
export class Dialog {
  #controller;
  #element;
  #prefix;
  #connected;
  #openedEventEmitted;
  #beforeOpenEventEmitted;
  #closedEventEmitted;
  #pendingDismissResult;
  #pendingOpen;
  #closing;
  #opening;
  #cycleComplete;
  #openFallbackTimer;
  #focusRestoreTarget;
  #focusRestoreToken;
  #supportsClosedBy;
  #onBeforeToggle;
  #onToggle;
  #onCancel;
  #onClose;
  #onPointerDown;
  #onPointerUp;
  #onPointerCancel;
  #pointerDownTarget;
  #pointerDownId;

  constructor(controller, options = {}) {
    this.#controller = controller;

    const config = Object.assign({}, defaultOptions, options);
    this.#element = config.element || controller.element;
    this.#prefix = typeof config.prefix === 'string' && config.prefix ? config.prefix : defaultOptions.prefix;
    this.#connected = true;
    this.#openedEventEmitted = false;
    this.#beforeOpenEventEmitted = false;
    this.#closedEventEmitted = false;
    this.#pendingDismissResult = null;
    this.#pendingOpen = false;
    this.#closing = false;
    this.#opening = false;
    this.#cycleComplete = false;
    this.#openFallbackTimer = null;
    this.#focusRestoreTarget = null;
    this.#focusRestoreToken = 0;

    if (!isDialogElement(this.#element)) {
      this.#connected = false;
      return;
    }

    this.#supportsClosedBy = 'closedBy' in this.#element;
    if (!this.#element.hasAttribute('closedby')) this.#element.setAttribute('closedby', 'closerequest');

    this.#onBeforeToggle = this.#handleBeforeToggle.bind(this);
    this.#onToggle = this.#handleToggle.bind(this);
    this.#onCancel = this.#handleCancel.bind(this);
    this.#onClose = this.#handleClose.bind(this);
    this.#onPointerDown = this.#handlePointerDown.bind(this);
    this.#onPointerUp = this.#handlePointerUp.bind(this);
    this.#onPointerCancel = this.#handlePointerCancel.bind(this);
    this.#pointerDownTarget = null;
    this.#pointerDownId = null;

    this.#element.addEventListener('beforetoggle', this.#onBeforeToggle);
    this.#element.addEventListener('toggle', this.#onToggle);
    this.#element.addEventListener('cancel', this.#onCancel);
    this.#element.addEventListener('close', this.#onClose);

    // closedby="any" needs a pointer fallback on engines without closedBy.
    if (!this.#supportsClosedBy) {
      this.#element.addEventListener('pointerdown', this.#onPointerDown);
      this.#element.addEventListener('pointerup', this.#onPointerUp);
      this.#element.addEventListener('pointercancel', this.#onPointerCancel);
    }
  }

  get open() {
    return !!(this.#connected && this.#element && this.#element.open);
  }

  show(invoker) {
    if (!this.#connected || !isDialogElement(this.#element) || this.open || this.#opening || this.#closing) {
      if (this.#closing) {
        this.#pendingOpen = true;
        this.#focusRestoreToken += 1;
        const target = this.#focusTargetFromElement(invoker) || this.#focusTargetFromActiveElement();
        if (target) this.#focusRestoreTarget = target;
      }
      return;
    }

    this.#rememberFocusTarget(invoker);
    this.#resetCycle();
    this.#element.returnValue = '';
    this.#pendingDismissResult = null;
    this.#opening = true;

    // Dispatch before the native call so cancellation is honored even where
    // showModal() is mocked or beforetoggle is unavailable.
    if (this.#dispatchBeforeOpen()) {
      this.#opening = false;
      this.#cycleComplete = true;
      this.#clearFocusRestore();
      return;
    }

    try {
      this.#element.showModal();
    } catch (error) {
      this.#opening = false;
      this.#closing = false;
      this.#pendingOpen = false;
      this.#pendingDismissResult = null;
      this.#cycleComplete = true;
      this.#clearFocusRestore();
      throw error;
    }

    this.#opening = false;
    this.#scheduleOpenedFallback();
  }

  dismiss(result) {
    if (!this.#connected || !isDialogElement(this.#element) || !this.open) return;
    if (this.#closedBy() === 'none') return;

    const normalizedResult = normalizeResult(result);
    this.#pendingDismissResult = normalizedResult;

    if (typeof this.#element.requestClose === 'function') {
      this.#closing = true;
      try {
        this.#element.requestClose(normalizedResult);
      } catch (error) {
        this.#closing = false;
        this.#pendingDismissResult = null;
        throw error;
      }

      // A later cancel listener may veto the request after this adapter's
      // listener has run. Native close removes `open` synchronously, so an
      // open dialog here means the complete cancel dispatch was prevented.
      if (this.open) {
        this.#closing = false;
        this.#pendingOpen = false;
        this.#pendingDismissResult = null;
      }
      return;
    }

    // requestClose() is not available on older engines. Dispatching cancel
    // preserves the same cancellable path before using explicit close().
    const cancel = new Event('cancel', { bubbles: false, cancelable: true });
    this.#element.dispatchEvent(cancel);
    if (cancel.defaultPrevented) {
      this.#closing = false;
      this.#pendingOpen = false;
      this.#pendingDismissResult = null;
      return;
    }

    this.#closing = true;
    try {
      this.#element.close(normalizedResult);
    } catch (error) {
      this.#closing = false;
      this.#pendingDismissResult = null;
      throw error;
    }
  }

  close(result) {
    if (!this.#connected || !isDialogElement(this.#element) || !this.open) return;

    const normalizedResult = normalizeResult(result);
    this.#pendingDismissResult = null;
    this.#closing = true;
    try {
      this.#element.close(normalizedResult);
    } catch (error) {
      this.#closing = false;
      throw error;
    }
  }

  disconnect() {
    if (!this.#connected || !this.#element) return;

    this.#element.removeEventListener('beforetoggle', this.#onBeforeToggle);
    this.#element.removeEventListener('toggle', this.#onToggle);
    this.#element.removeEventListener('cancel', this.#onCancel);
    this.#element.removeEventListener('close', this.#onClose);

    if (!this.#supportsClosedBy) {
      this.#element.removeEventListener('pointerdown', this.#onPointerDown);
      this.#element.removeEventListener('pointerup', this.#onPointerUp);
      this.#element.removeEventListener('pointercancel', this.#onPointerCancel);
    }

    this.#connected = false;
    this.#pendingOpen = false;
    this.#pendingDismissResult = null;
    this.#pointerDownTarget = null;
    this.#pointerDownId = null;
    this.#clearFocusRestore();
    if (this.#openFallbackTimer !== null) clearTimeout(this.#openFallbackTimer);
    this.#openFallbackTimer = null;
  }

  #closedBy() {
    if (this.#supportsClosedBy) return String(this.#element.closedBy || 'closerequest').toLowerCase();

    const value = this.#element.getAttribute('closedby');
    return value === 'any' || value === 'none' ? value : 'closerequest';
  }

  #dispatch(name, detail = {}) {
    return this.#controller.dispatch(name, {
      target: this.#element,
      prefix: this.#prefix,
      detail,
      cancelable: name === 'before-open' || name === 'before-dismiss',
    });
  }

  #dispatchBeforeOpen() {
    if (this.#beforeOpenEventEmitted) return false;
    this.#beforeOpenEventEmitted = true;
    const event = this.#dispatch('before-open', {});
    return event?.defaultPrevented === true || event === false;
  }

  #dispatchBeforeDismiss(result) {
    const event = this.#dispatch('before-dismiss', { result: normalizeResult(result) });
    return event?.defaultPrevented === true || event === false;
  }

  #handleBeforeToggle(event) {
    if (event.newState && event.newState !== 'open') return;
    if (!this.#opening && this.#cycleComplete) this.#resetCycle();
    if (!this.#opening) this.#rememberFocusTarget(event.source);
    this.#opening = false;
    if (this.#beforeOpenEventEmitted) return;

    if (this.#dispatchBeforeOpen()) {
      event.preventDefault();
      this.#cycleComplete = true;
      this.#clearFocusRestore();
      return;
    }

    this.#scheduleOpenedFallback();
  }

  #handleToggle(event) {
    if (event.newState === 'closed') return;
    if (this.#cycleComplete) this.#resetCycle();
    if (this.#openFallbackTimer !== null) clearTimeout(this.#openFallbackTimer);
    this.#openFallbackTimer = null;
    if (!this.#openedEventEmitted) this.#emitOpened();
  }

  #handleCancel(event) {
    if (this.#closedBy() === 'none') {
      event.preventDefault();
      this.#closing = false;
      this.#pendingOpen = false;
      this.#pendingDismissResult = null;
      return;
    }

    const result = this.#pendingDismissResult ?? normalizeResult(this.#element.returnValue);
    if (this.#dispatchBeforeDismiss(result)) {
      event.preventDefault();
      this.#closing = false;
      this.#pendingOpen = false;
      this.#pendingDismissResult = null;
      return;
    }

    this.#closing = true;
  }

  #handleClose() {
    if (this.#closedEventEmitted) return;

    this.#closedEventEmitted = true;
    this.#opening = false;
    this.#pendingDismissResult = null;
    this.#closing = true;
    if (this.#openFallbackTimer !== null) clearTimeout(this.#openFallbackTimer);
    this.#openFallbackTimer = null;
    this.#dispatch('closed', { result: normalizeResult(this.#element.returnValue) });
    this.#closing = false;
    this.#cycleComplete = true;

    const reopen = this.#pendingOpen && this.#connected;
    this.#pendingOpen = false;
    this.#deferFocusRestore();
    if (reopen) queueMicrotask(() => this.show());
  }

  #emitOpened() {
    if (this.#openedEventEmitted) return;
    this.#openedEventEmitted = true;
    this.#dispatch('opened', {});
  }

  #resetCycle() {
    this.#openedEventEmitted = false;
    this.#beforeOpenEventEmitted = false;
    this.#closedEventEmitted = false;
    this.#cycleComplete = false;
  }

  #scheduleOpenedFallback() {
    if (this.#openFallbackTimer !== null) clearTimeout(this.#openFallbackTimer);

    this.#openFallbackTimer = setTimeout(() => {
      this.#openFallbackTimer = null;
      if (!this.#connected || this.#openedEventEmitted) return;

      if (this.open) this.#emitOpened();
      else {
        this.#cycleComplete = true;
        this.#clearFocusRestore();
      }
    }, 0);
  }

  #rememberFocusTarget(invoker) {
    this.#focusRestoreToken += 1;
    this.#focusRestoreTarget = this.#focusTargetFromElement(invoker) || this.#focusTargetFromActiveElement();
  }

  #focusTargetFromActiveElement() {
    return this.#focusTargetFromElement(document.activeElement);
  }

  #focusTargetFromElement(element) {
    return element instanceof HTMLElement &&
      element !== document.body &&
      element !== document.documentElement &&
      element !== this.#element &&
      !this.#element.contains(element) &&
      element.isConnected &&
      !element.hidden &&
      !element.matches(':disabled') &&
      typeof element.focus === 'function'
      ? element
      : null;
  }

  #clearFocusRestore() {
    this.#focusRestoreToken += 1;
    this.#focusRestoreTarget = null;
  }

  #deferFocusRestore() {
    const token = this.#focusRestoreToken;
    queueMicrotask(() => {
      if (token !== this.#focusRestoreToken || !this.#connected || this.open || this.#pendingOpen) return;

      const active = document.activeElement;
      const focusNeedsRestoring =
        !active || active === document.body || active === document.documentElement || this.#element.contains(active);
      const target = this.#focusRestoreTarget;
      this.#focusRestoreTarget = null;
      if (
        !focusNeedsRestoring ||
        !target ||
        !target.isConnected ||
        target.hidden ||
        target.matches(':disabled') ||
        typeof target.focus !== 'function'
      )
        return;

      try {
        target.focus({ preventScroll: true });
      } catch {
        // A disconnected or otherwise unfocusable invoker is safely ignored.
      }
    });
  }

  #handlePointerDown(event) {
    if (!this.open || this.#closedBy() !== 'any' || event.target !== this.#element) {
      this.#pointerDownTarget = null;
      this.#pointerDownId = null;
      return;
    }

    this.#pointerDownTarget = this.#isOutside(event) ? event.target : null;
    this.#pointerDownId = this.#pointerDownTarget ? event.pointerId : null;
  }

  #handlePointerUp(event) {
    const target = this.#pointerDownTarget;
    const pointerId = this.#pointerDownId;
    this.#pointerDownTarget = null;
    this.#pointerDownId = null;
    if (!target || target !== event.target || target !== this.#element) return;
    if (pointerId !== event.pointerId) return;
    if (!this.open || this.#closedBy() !== 'any') return;
    if (!this.#isOutside(event)) return;

    this.dismiss();
  }

  #handlePointerCancel() {
    this.#pointerDownTarget = null;
    this.#pointerDownId = null;
  }

  #isOutside(event) {
    const rect = this.#element.getBoundingClientRect();
    return (
      event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom
    );
  }
}

export const attachDialog = (controller, options) => new Dialog(controller, options);
