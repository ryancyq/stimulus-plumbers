import { isDisabled, parseDateKey } from '../date';
import { availabilityErrors, dateAvailability, dayAvailability } from '../datetime';
import ComboboxTimeController from './combobox_time_controller';

// A combobox-time whose panel also holds a calendar; the value joins the selected date and time.
export default class extends ComboboxTimeController {
  static targets = ['calendar'];
  static outlets = ['calendar'];
  static values = {
    timeMin: String,
    timeMax: String,
    disabledDates: Array,
    disabledWeekdays: Array,
    disabledMonths: Array,
    disabledYears: Array,
  };

  // Gives the calendar the dates that still have a time.
  calendarTargetConnected(calendar) {
    const availability = this._dateTimeAvailability();
    if (availabilityErrors(availability).length) return;

    const { min, max, disabledDates, disabledWeekdays, disabledMonths, disabledYears } = dateAvailability(availability);
    const values = { min, max, disabledDates, disabledWeekdays, disabledMonths, disabledYears };
    Object.entries(values).forEach(([name, value]) => {
      const attribute = `data-calendar-${name.replace(/[A-Z]/g, (letter) => `-${letter.toLowerCase()}`)}-value`;
      if (value == null || value.length === 0) calendar.removeAttribute(attribute);
      else calendar.setAttribute(attribute, Array.isArray(value) ? JSON.stringify(value) : value);
    });
  }

  // Takes the date selected in the calendar; the panel stays open.
  onDateChange() {
    this._selectionChanged();
  }

  // Escape anywhere in the panel restores the value from opening.
  onEscape(event) {
    this._cancel(event);
  }

  // Has the calendar outlet focus its Tab stop.
  _focusPanel() {
    if (this.hasCalendarOutlet) this.calendarOutlet.focusTabStop();
  }

  get _date() {
    return this.calendarTarget.getAttribute('data-calendar-selected-value') || null;
  }

  // A time on an unavailable date is unavailable too.
  get _isUnavailable() {
    const date = parseDateKey(this._date);
    const availability = this._dateTimeAvailability();
    if (date == null || availabilityErrors(availability).length) return super._isUnavailable;
    return super._isUnavailable || isDisabled(date, dateAvailability(availability));
  }

  _reportInvalidAvailability() {
    const errors = availabilityErrors(this._dateTimeAvailability());
    if (errors.length) console.error(`ComboboxDatetimeController has invalid availability: ${errors.join('; ')}.`);
  }

  // The selected date's times, or the daily window before a date is selected.
  _availability() {
    const date = parseDateKey(this._date);
    const availability = this._dateTimeAvailability();
    return date ? dayAvailability(date, availability) : availability.time;
  }

  _dateTimeAvailability() {
    return {
      min: this.minValue || null,
      max: this.maxValue || null,
      disabledDates: this.disabledDatesValue,
      disabledWeekdays: this.disabledWeekdaysValue,
      disabledMonths: this.disabledMonthsValue,
      disabledYears: this.disabledYearsValue,
      time: { min: this.timeMinValue || null, max: this.timeMaxValue || null, step: this.stepValue },
    };
  }

  // YYYY-MM-DDTHH:MM once a date and an available time are selected.
  _selectedValue() {
    const time = super._selectedValue();
    return time && this._date ? `${this._date}T${time}` : null;
  }

  _snapshot() {
    return { ...super._snapshot(), date: this._date };
  }

  _showSelection(snapshot) {
    if (snapshot.date) this.calendarTarget.setAttribute('data-calendar-selected-value', snapshot.date);
    else this.calendarTarget.removeAttribute('data-calendar-selected-value');
    super._showSelection(snapshot);
  }
}
