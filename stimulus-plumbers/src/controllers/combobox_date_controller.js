import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['trigger', 'input', 'panel'];
  static outlets = ['calendar'];

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

  // ArrowDown opens the panel and has the calendar outlet focus its Tab stop; Tab closes the panel.
  // The native popover API opens and closes the panel; the popover controller follows its toggle events.
  onKeydown(event) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (!this._isOpen) this.panelTarget.showPopover({ source: this.triggerTarget });
      if (this.hasCalendarOutlet) this.calendarOutlet.focusTabStop();
    } else if (event.key === 'Tab' && this._isOpen) {
      this.panelTarget.hidePopover();
    }
  }

  // Clicks on the icons and padding open the panel from the trigger.
  onClick(event) {
    if (!this._isInFieldBox(event.target)) return;

    this.triggerTarget.focus({ preventScroll: true });
    if (!this._isOpen) this.panelTarget.showPopover({ source: this.triggerTarget });
  }

  // Keeps focus on the trigger while the icons and padding are pressed.
  onMousedown(event) {
    if (this._isInFieldBox(event.target)) event.preventDefault();
  }

  // Closes the panel when focus moves to an element outside the combobox; WebKit sends focus
  // nowhere on a click inside the panel.
  onFocusout(event) {
    const target = event.relatedTarget;
    if (this._isOpen && target && !this.element.contains(target)) this.panelTarget.hidePopover();
  }

  // Copies the selected date into the field, closes the panel, and focuses the trigger.
  onChange(event) {
    if (this.inputTarget.value !== event.detail.value) {
      this.inputTarget.value = event.detail.value;
      this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }));
    }
    this._selectionChanged();
    if (this._isOpen) this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  get _isOpen() {
    return this.panelTarget.matches(':popover-open');
  }

  _restore() {
    this.inputTarget.value = this.initial;
    this._selectionChanged();
  }

  _selectionChanged() {
    this.dispatch('changed', { detail: { value: this.inputTarget.value } });
  }

  // Whether the target is in the input group holding the trigger, other than the trigger.
  _isInFieldBox(target) {
    return target !== this.triggerTarget && this.triggerTarget.parentElement.contains(target);
  }
}
