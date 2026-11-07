import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['trigger', 'input', 'panel'];

  connect() {
    this.connection = new AbortController();
    // Survives reconnects.
    this.initial ??= this.inputTarget.value;
    this.element
      .closest('form')
      ?.addEventListener(
        'reset',
        (event) => setTimeout(() => event.defaultPrevented || !this.connection || this._restore()),
        { signal: this.connection.signal }
      );
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  // ArrowDown opens the panel and focuses the calendar's Tab stop; Tab closes the panel.
  // The native popover API opens and closes the panel; the popover controller follows its toggle events.
  onKeydown(event) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (!this._open) this.panelTarget.showPopover({ source: this.triggerTarget });
      this.panelTarget.querySelector('[data-calendar-target~="grid"] [tabindex="0"]')?.focus();
    } else if (event.key === 'Tab' && this._open) {
      this.panelTarget.hidePopover();
    }
  }

  // Clicks on the icons and padding open the panel from the trigger.
  onClick(event) {
    if (!this._fieldBox(event.target)) return;

    this.triggerTarget.focus({ preventScroll: true });
    if (!this._open) this.panelTarget.showPopover({ source: this.triggerTarget });
  }

  // Keeps focus on the trigger while the icons and padding are pressed.
  onMousedown(event) {
    if (this._fieldBox(event.target)) event.preventDefault();
  }

  // Closes the panel when focus moves to an element outside the combobox; WebKit sends focus
  // nowhere on a click inside the panel.
  onFocusout(event) {
    const target = event.relatedTarget;
    if (this._open && target && !this.element.contains(target)) this.panelTarget.hidePopover();
  }

  // Copies the committed date into the field, closes the panel, and focuses the trigger.
  onChange(event) {
    this.inputTarget.value = event.detail.value;
    this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }));
    this._changed();
    if (this._open) this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  get _open() {
    return this.panelTarget.matches(':popover-open');
  }

  _restore() {
    this.inputTarget.value = this.initial;
    this._changed();
  }

  _changed() {
    this.dispatch('changed', { detail: { value: this.inputTarget.value } });
  }

  // The field box is the input group holding the trigger and its icons.
  _fieldBox(target) {
    return target !== this.triggerTarget && this.triggerTarget.parentElement.contains(target);
  }
}
