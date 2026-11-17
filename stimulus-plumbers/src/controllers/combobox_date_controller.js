import Temporal from './combobox/temporal';

export default class extends Temporal {
  static outlets = ['calendar'];

  onOpening(event) {
    if (event.target === this.panelTarget && this.hasCalendarOutlet) {
      this.calendarOutlet.selectedValue = this.inputTarget.value;
    }
  }

  onChange(event) {
    this._setValue(event.detail.value);
    if (this._isOpen) this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  _focusPanel() {
    if (this.hasCalendarOutlet) this.calendarOutlet.focusTabStop();
  }
}
