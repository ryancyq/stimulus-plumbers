import { isDisabled, parseDateKey } from '../date';
import { availabilityErrors, dateAvailability, dayAvailability } from '../datetime';
import ComboboxTimeController from './combobox_time_controller';

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

  onDateChange() {
    this._selectionChanged();
  }

  onEscape(event) {
    this._cancel(event);
  }

  _focusPanel() {
    if (this.hasCalendarOutlet) this.calendarOutlet.focusTabStop();
  }

  get _date() {
    return this.calendarTarget.getAttribute('data-calendar-selected-value') || null;
  }

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

  _selectedValue() {
    const time = super._selectedValue();
    return time && this._date ? `${this._date}T${time}` : null;
  }

  _selectionFor(value) {
    return { ...super._selectionFor(value.slice(11)), date: value.slice(0, 10) || null };
  }

  _showSelection(selection) {
    if (selection.date) this.calendarTarget.setAttribute('data-calendar-selected-value', selection.date);
    else this.calendarTarget.removeAttribute('data-calendar-selected-value');
    super._showSelection(selection);
  }
}
