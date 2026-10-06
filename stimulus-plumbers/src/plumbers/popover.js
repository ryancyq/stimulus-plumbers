const defaultOptions = {
  prefix: 'popover',
};

const isPopoverElement = (element) => {
  if (typeof HTMLElement === 'undefined' || !(element instanceof HTMLElement)) return false;

  return (
    element.hasAttribute('popover') &&
    typeof element.showPopover === 'function' &&
    typeof element.hidePopover === 'function' &&
    typeof element.togglePopover === 'function'
  );
};

/**
 * Adapts a native HTML popover element to the popover lifecycle.
 *
 * Native popover state and events remain authoritative. This adapter does not
 * provide focus management, dismissal fallbacks, or positioning behavior.
 */
export class Popover {
  #controller;
  #panel;
  #prefix;
  #connected;
  #lastSettledOpen;
  #onBeforeToggle;
  #onToggle;

  constructor(controller, options = {}) {
    this.#controller = controller;

    const config = Object.assign({}, defaultOptions, options);
    this.#panel = config.element || controller.element;
    this.#prefix = typeof config.prefix === 'string' && config.prefix ? config.prefix : defaultOptions.prefix;
    this.#connected = true;
    this.#lastSettledOpen = null;

    if (!isPopoverElement(this.#panel)) {
      this.#connected = false;
      return;
    }

    this.#onBeforeToggle = this.#handleBeforeToggle.bind(this);
    this.#onToggle = this.#handleToggle.bind(this);

    this.#panel.addEventListener('beforetoggle', this.#onBeforeToggle);
    this.#panel.addEventListener('toggle', this.#onToggle);
  }

  get open() {
    return !!(this.#connected && this.#panel && this.#panel.matches(':popover-open'));
  }

  show(source) {
    if (!this.#connected || this.open) return;

    if (source === undefined) {
      this.#panel.showPopover();
    } else {
      this.#panel.showPopover({ source });
    }
  }

  hide() {
    if (!this.#connected || !this.open) return;

    this.#panel.hidePopover();
  }

  toggle(source) {
    if (!this.#connected) return;

    if (source === undefined) {
      this.#panel.togglePopover();
    } else {
      this.#panel.togglePopover({ source });
    }
  }

  disconnect() {
    if (!this.#connected || !this.#panel) return;

    this.#panel.removeEventListener('beforetoggle', this.#onBeforeToggle);
    this.#panel.removeEventListener('toggle', this.#onToggle);
    this.#connected = false;
    this.#lastSettledOpen = null;
    this.#controller = null;
    this.#panel = null;
    this.#onBeforeToggle = null;
    this.#onToggle = null;
  }

  #dispatch(name, detail, cancelable = false) {
    return this.#controller.dispatch(name, {
      target: this.#panel,
      prefix: this.#prefix,
      detail,
      cancelable,
    });
  }

  #sourceFrom(event) {
    return event && event.source != null ? event.source : null;
  }

  #handleBeforeToggle(event) {
    if (event.newState !== 'open') return;

    const lifecycleEvent = this.#dispatch('before-open', { source: this.#sourceFrom(event) }, true);
    if (lifecycleEvent?.defaultPrevented === true || lifecycleEvent === false) event.preventDefault();
  }

  #handleToggle(event) {
    // Native toggle tasks coalesce. A same-task open/close (or close/open)
    // can therefore report identical old and new states and is not a
    // settled transition for consumers to observe.
    if (event.oldState === event.newState) return;

    const open = this.open;
    if (this.#lastSettledOpen === open) return;

    this.#lastSettledOpen = open;
    const detail = { source: this.#sourceFrom(event) };
    if (open) this.#dispatch('opened', detail);
    else this.#dispatch('closed', detail);
  }
}

export const attachPopover = (controller, options) => new Popover(controller, options);
