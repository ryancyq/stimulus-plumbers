import { parseDateKey } from '../date';
import { availabilityErrors, dayAvailability } from '../datetime';
import ComboboxTimeController from './combobox_time_controller';

// A combobox-time whose panel also holds a calendar; the value joins the chosen date and time.
export default class extends ComboboxTimeController {
  static targets = ['calendar'];
  static values = { timeMin: String, timeMax: String };

  // Takes the date chosen in the calendar; the panel stays open.
  onDateChange() {
    this._changed();
  }

  // Escape anywhere in the panel restores the value from opening.
  onEscape(event) {
    this._cancel(event);
  }

  // Focuses the calendar's Tab stop.
  _focusPanel() {
    this.calendarTarget.querySelector('[data-calendar-target~="grid"] [tabindex="0"]')?.focus();
  }

  get _date() {
    return this.calendarTarget.getAttribute('data-calendar-selected-value') || null;
  }

  _report() {
    const errors = availabilityErrors(this._dateTimeAvailability());
    if (errors.length) console.error(`ComboboxDatetimeController has invalid availability: ${errors.join('; ')}.`);
  }

  // The chosen date's times, or the daily window before a date is chosen.
  _availability() {
    const date = parseDateKey(this._date);
    const availability = this._dateTimeAvailability();
    return date ? dayAvailability(date, availability) : availability.time;
  }

  _dateTimeAvailability() {
    return {
      min: this.minValue || null,
      max: this.maxValue || null,
      time: { min: this.timeMinValue || null, max: this.timeMaxValue || null, step: this.stepValue },
    };
  }

  // YYYY-MM-DDTHH:MM once a date and an available time are chosen.
  _value() {
    const time = super._value();
    return time && this._date ? `${this._date}T${time}` : null;
  }

  _snapshot() {
    return { ...super._snapshot(), date: this._date };
  }

  _show(snapshot) {
    if (snapshot.date) this.calendarTarget.setAttribute('data-calendar-selected-value', snapshot.date);
    else this.calendarTarget.removeAttribute('data-calendar-selected-value');
    super._show(snapshot);
  }
}
