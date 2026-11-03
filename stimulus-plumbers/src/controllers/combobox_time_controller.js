import { isAriaDisabled, setAriaDisabled } from '../accessibility/aria';
import { ActiveDescendant } from '../accessibility/keyboard';
import { availabilityErrors, HOURS, isDisabled, isHourDisabled } from '../time';
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
    this._report();
    this._disable();
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
    if (event.target === this.panelTarget) this.opened = this.committed = this._snapshot();
  }

  // Shows the chosen options.
  onOpened(event) {
    if (event.target !== this.panelTarget) return;

    this._columns.forEach((column) => this._selected(column)?.scrollIntoView({ block: 'nearest' }));
  }

  // Discards the choices that left a chosen option unavailable; the input keeps its value.
  onClosed(event) {
    if (event.target === this.panelTarget && this._unavailable) this._show(this.committed);
  }

  // Arrows, Home, and End choose an option; Enter closes the panel; Escape restores the value.
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
    move(this._descendant(event.currentTarget));
    this._changed();
  }

  onSelect(event) {
    const option = event.target.closest('[role="option"]');
    if (!option || isAriaDisabled(option)) return;

    this._descendant(event.currentTarget).activate(option);
    this._changed();
  }

  get _columns() {
    return [this.hourTarget, this.minuteTarget, ...this.meridiemTargets];
  }

  get _unavailable() {
    return this._columns.some((column) => {
      const option = this._selected(column);
      return option && isAriaDisabled(option);
    });
  }

  _focusPanel() {
    this.hourTarget.focus();
  }

  _cancel(event) {
    if (!this._open) return;

    event.preventDefault();
    this._restore(this.opened);
    this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  _changed() {
    this._disable();
    const value = this._value();
    if (value) this._commit(value);
  }

  // Also records the choices the value came from.
  _commit(value) {
    super._commit(value);
    this.committed = this._snapshot();
  }

  // HH:MM from the chosen options, or null until hour and minute are chosen and available.
  _value() {
    if (this._unavailable) return null;

    const [hour, minute, meridiem] = this._columns.map((column) => this._selected(column)?.dataset.value);
    if (!hour || !minute) return null;
    if (!this.hasMeridiemTarget) return `${hour}:${minute}`;
    if (!meridiem) return null;

    const twelve = Number(hour) % 12;
    return `${String(meridiem === 'PM' ? twelve + 12 : twelve).padStart(2, '0')}:${minute}`;
  }

  _snapshot() {
    return { value: this.inputTarget.value, options: this._columns.map((column) => this._selected(column)) };
  }

  _restore(snapshot) {
    this._show(snapshot);
    this._commit(snapshot.value);
  }

  _show({ options }) {
    this._columns.forEach((column, index) => this._mark(column, options[index]));
    this._disable();
  }

  _report() {
    const errors = availabilityErrors(this._availability());
    if (errors.length) console.error(`ComboboxTimeController has invalid availability: ${errors.join('; ')}.`);
  }

  // The time core's availability the columns offer.
  _availability() {
    return { min: this.minValue || null, max: this.maxValue || null, step: this.stepValue };
  }

  // An option is unavailable when no available time matches it and the choices it depends on:
  // an hour depends on the meridiem, a minute on the meridiem and hour.
  _disable() {
    const availability = this._availability();
    const meridiem = this.hasMeridiemTarget ? this._selected(this.meridiemTarget)?.dataset.value : null;
    const hours = this._hours(this._selected(this.hourTarget)?.dataset.value, meridiem);
    const hoursDisabled = (each) => each.every((hour) => isHourDisabled(hour, availability));
    const mark = (columns, disabled) =>
      this._options(columns).forEach((option) => setAriaDisabled(option, disabled(option.dataset.value)));

    mark(this.meridiemTargets, (value) => hoursDisabled(this._hours(null, value)));
    mark([this.hourTarget], (value) => hoursDisabled(this._hours(value, meridiem)));
    mark([this.minuteTarget], (value) =>
      hours.every((hour) => isDisabled({ hour, minute: Number(value) }, availability))
    );
  }

  // The 24-hour hours an hour value and meridiem stand for; either may be unchosen.
  _hours(hour, meridiem) {
    if (!this.hasMeridiemTarget) return hour == null ? HOURS : [Number(hour)];

    return HOURS.filter(
      (each) =>
        (hour == null || each % 12 === Number(hour) % 12) && (meridiem == null || each >= 12 === (meridiem === 'PM'))
    );
  }

  _options(columns) {
    return columns.flatMap((column) => [...column.querySelectorAll('[role="option"]')]);
  }

  _mark(column, option) {
    if (option) this._descendant(column).activate(option);
    else this._descendant(column).clear();
  }

  // The chosen option, even while unavailable; creates the column's descendant at the server-rendered selection.
  _selected(column) {
    this._descendant(column);
    return column.querySelector('[role="option"][aria-selected="true"]');
  }

  // Starts from the server-rendered selection.
  _descendant(column) {
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
