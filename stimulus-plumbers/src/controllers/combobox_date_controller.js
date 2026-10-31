import Temporal from './combobox/temporal';

export default class extends Temporal {
  // Commits the chosen date, closes the panel, and focuses the trigger.
  onChange(event) {
    this._commit(event.detail.value);
    if (this._open) this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  // Focuses the calendar's Tab stop.
  _focusPanel() {
    this.panelTarget.querySelector('[data-calendar-target~="grid"] [tabindex="0"]')?.focus();
  }

  _snapshot() {
    return { value: this.inputTarget.value };
  }

  _restore({ value }) {
    this._commit(value);
  }
}
