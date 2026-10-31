import Temporal from './combobox/temporal';

export default class extends Temporal {
  static outlets = ['calendar'];

  // Writes the calendar's date to the input, closes the panel, and focuses the trigger.
  onChange(event) {
    this._setValue(event.detail.value);
    if (this._isOpen) this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  // Has the calendar outlet focus its Tab stop.
  _focusPanel() {
    if (this.hasCalendarOutlet) this.calendarOutlet.focusTabStop();
  }

  _snapshot() {
    return { value: this.inputTarget.value };
  }

  _restore({ value }) {
    this._setValue(value);
  }
}
