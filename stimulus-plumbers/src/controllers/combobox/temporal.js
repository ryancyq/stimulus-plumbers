import { Controller } from '@hotwired/stimulus';
import { onFormReset } from '../../plumbers/plumber/form_reset';

// A read-only combobox trigger with a hidden input and a popover panel.
// Subclasses define `_focusPanel()`, `_snapshot()` returning `{ value }` plus any state to restore,
// and `_restore(snapshot)`.
export default class extends Controller {
  static targets = ['trigger', 'input', 'panel'];

  connect() {
    this.connection = new AbortController();
    // Survives reconnects.
    this.initial ??= this._snapshot();
    onFormReset(this.element, () => this._reset(), { signal: this.connection.signal });
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  // ArrowDown opens the panel and focuses it; Tab closes the panel.
  // The native popover API opens and closes the panel; the popover controller follows its toggle events.
  onKeydown(event) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (!this._isOpen) this.panelTarget.showPopover({ source: this.triggerTarget });
      this._focusPanel();
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

  // Closes the panel when focus moves to an element outside the combobox, not when focus goes nowhere.
  onFocusout(event) {
    const target = event.relatedTarget;
    if (this._isOpen && target && !this.element.contains(target)) this.panelTarget.hidePopover();
  }

  get _isOpen() {
    return this.panelTarget.matches(':popover-open');
  }

  // Writes the value to the input, fires `change` when it differs, and dispatches `changed`.
  _setValue(value) {
    if (this.inputTarget.value !== value) {
      this.inputTarget.value = value;
      this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }));
    }
    this.dispatch('changed', { detail: { value } });
  }

  // Restores the initial value without a change event.
  _reset() {
    this.inputTarget.value = this.initial.value;
    this._restore(this.initial);
  }

  // Whether the target is in the input group holding the trigger, other than the trigger.
  _isInFieldBox(target) {
    return target !== this.triggerTarget && this.triggerTarget.parentElement.contains(target);
  }
}
