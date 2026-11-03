import { isAriaDisabled, setAriaDisabled } from '../accessibility/aria';
import { ActiveDescendant } from '../accessibility/keyboard';
import { availabilityErrors, HOURS, isDisabled, isHourDisabled, timeKey } from '../time';
import Temporal from './combobox/temporal';

const MOVES = {
  ArrowDown: (descendant) => descendant.move(1),
  ArrowUp: (descendant) => descendant.move(-1),
  Home: (descendant) => descendant.first(),
  End: (descendant) => descendant.last(),
};

export default class extends Temporal {
  static targets = ['hour', 'minute', 'meridiem'];
  static values = { min: String, max: String, step: { type: Number, default: 1 } };

  connect() {
    super.connect();
    this._reportInvalidAvailability();
    this._markUnavailable();
  }

  disconnect() {
    super.disconnect();
    this.descendants = null;
  }

  // Escape restores the value from when the panel opened.
  onKeydown(event) {
    if (event.key === 'Escape') this._cancel(event);
    else super.onKeydown(event);
  }

  // Records the value to restore on Escape.
  onOpening(event) {
    if (event.target === this.panelTarget) this.opened = this.selection = this._snapshot();
  }

  // Shows the selected options.
  onOpened(event) {
    if (event.target !== this.panelTarget) return;

    this._columns.forEach((column) => this._selectedOption(column)?.scrollIntoView({ block: 'nearest' }));
  }

  // Discards the selections not in the input.
  onClosed(event) {
    if (event.target === this.panelTarget) this._showSelection(this.selection);
  }

  // Arrows, Home, and End select an option; Enter closes the panel; Escape restores the value.
  onNavigate(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      this.panelTarget.hidePopover();
      this.triggerTarget.focus();
      return;
    }
    if (event.key === 'Escape') {
      this._cancel(event);
      return;
    }
    const move = MOVES[event.key];
    if (!move) return;

    event.preventDefault();
    move(this._activeDescendant(event.currentTarget));
    this._selectionChanged();
  }

  onSelect(event) {
    const option = event.target.closest('[role="option"]');
    if (!option || isAriaDisabled(option)) return;

    this._activeDescendant(event.currentTarget).activate(option);
    this._selectionChanged();
  }

  get _columns() {
    return [this.hourTarget, this.minuteTarget, ...this.meridiemTargets];
  }

  get _isUnavailable() {
    return this._columns.some((column) => {
      const option = this._selectedOption(column);
      return option && isAriaDisabled(option);
    });
  }

  _focusPanel() {
    this.hourTarget.focus();
  }

  _cancel(event) {
    if (!this._isOpen) return;

    event.preventDefault();
    this._restore(this.opened);
    this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  _selectionChanged() {
    this._markUnavailable();
    const value = this._selectedValue();
    if (value) this._setValue(value);
  }

  // Also records the selections the value came from.
  _setValue(value) {
    super._setValue(value);
    this.selection = this._snapshot();
  }

  // HH:MM from the selected options, or null until hour and minute are selected and available.
  _selectedValue() {
    if (this._isUnavailable) return null;

    const [hour, minute, meridiem] = this._columns.map((column) => this._selectedOption(column)?.dataset.value);
    if (!hour || !minute) return null;
    if (!this.hasMeridiemTarget) return `${hour}:${minute}`;
    if (!meridiem) return null;

    const twelve = Number(hour) % 12;
    return timeKey({ hour: meridiem === 'PM' ? twelve + 12 : twelve, minute: Number(minute) });
  }

  _snapshot() {
    return { value: this.inputTarget.value, options: this._columns.map((column) => this._selectedOption(column)) };
  }

  _restore(snapshot) {
    this._showSelection(snapshot);
    this._setValue(snapshot.value);
  }

  _showSelection({ options }) {
    this._columns.forEach((column, index) => this._selectOption(column, options[index]));
    this._markUnavailable();
  }

  _reportInvalidAvailability() {
    const errors = availabilityErrors(this._availability());
    if (errors.length) console.error(`ComboboxTimeController has invalid availability: ${errors.join('; ')}.`);
  }

  // The time core's availability the columns offer.
  _availability() {
    return { min: this.minValue || null, max: this.maxValue || null, step: this.stepValue };
  }

  // An option is unavailable when no available time matches it and the selections it depends on:
  // an hour depends on the meridiem, a minute on the meridiem and hour.
  _markUnavailable() {
    const availability = this._availability();
    const meridiem = this.hasMeridiemTarget ? this._selectedOption(this.meridiemTarget)?.dataset.value : null;
    const hours = this._matchingHours(this._selectedOption(this.hourTarget)?.dataset.value, meridiem);
    const hoursDisabled = (each) => each.every((hour) => isHourDisabled(hour, availability));
    const mark = (columns, disabled) =>
      this._options(columns).forEach((option) => setAriaDisabled(option, disabled(option.dataset.value)));

    mark(this.meridiemTargets, (value) => hoursDisabled(this._matchingHours(null, value)));
    mark([this.hourTarget], (value) => hoursDisabled(this._matchingHours(value, meridiem)));
    mark([this.minuteTarget], (value) =>
      hours.every((hour) => isDisabled({ hour, minute: Number(value) }, availability))
    );
  }

  // The 24-hour hours an hour value and meridiem stand for; either may be unselected.
  _matchingHours(hour, meridiem) {
    if (!this.hasMeridiemTarget) return hour == null ? HOURS : [Number(hour)];

    return HOURS.filter(
      (each) =>
        (hour == null || each % 12 === Number(hour) % 12) && (meridiem == null || each >= 12 === (meridiem === 'PM'))
    );
  }

  _options(columns) {
    return columns.flatMap((column) => [...column.querySelectorAll('[role="option"]')]);
  }

  _selectOption(column, option) {
    if (option) this._activeDescendant(column).activate(option);
    else this._activeDescendant(column).clear();
  }

  // The selected option, even while unavailable; creates the column's descendant at the server-rendered selection.
  _selectedOption(column) {
    this._activeDescendant(column);
    return column.querySelector('[role="option"][aria-selected="true"]');
  }

  // Starts from the server-rendered selection.
  _activeDescendant(column) {
    this.descendants ??= new Map();
    if (!this.descendants.has(column)) {
      const descendant = new ActiveDescendant(column, {
        options: () => [...column.querySelectorAll('[role="option"]')],
        enabled: (option) => !isAriaDisabled(option),
      });
      descendant.activate(column.querySelector('[role="option"][aria-selected="true"]'));
      this.descendants.set(column, descendant);
    }
    return this.descendants.get(column);
  }
}
