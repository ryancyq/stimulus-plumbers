import { ActiveDescendant } from '../accessibility/keyboard';
import Temporal from './combobox/temporal';

const MOVES = {
  ArrowDown: (descendant) => descendant.move(1),
  ArrowUp: (descendant) => descendant.move(-1),
  Home: (descendant) => descendant.first(),
  End: (descendant) => descendant.last(),
};

export default class extends Temporal {
  static targets = ['hour', 'minute', 'meridiem'];

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
    if (event.target === this.panelTarget) this.opened = this._snapshot();
  }

  // Shows the chosen options.
  onOpened(event) {
    if (event.target !== this.panelTarget) return;

    this._columns.forEach((column) => this._selected(column)?.scrollIntoView({ block: 'nearest' }));
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
    if (!option) return;

    this._descendant(event.currentTarget).activate(option);
    this._changed();
  }

  get _columns() {
    return [this.hourTarget, this.minuteTarget, ...this.meridiemTargets];
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
    const value = this._value();
    if (value) this._commit(value);
  }

  // HH:MM from the chosen options, or null until hour and minute are chosen.
  _value() {
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

  _restore({ value, options }) {
    this._columns.forEach((column, index) => this._mark(column, options[index]));
    this._commit(value);
  }

  _mark(column, option) {
    if (option) this._descendant(column).activate(option);
    else this._descendant(column).clear();
  }

  _selected(column) {
    return this._descendant(column).active;
  }

  // Starts from the server-rendered selection.
  _descendant(column) {
    this.descendants ??= new Map();
    if (!this.descendants.has(column)) {
      const descendant = new ActiveDescendant(column, {
        options: () => [...column.querySelectorAll('[role="option"]')],
      });
      descendant.activate(column.querySelector('[role="option"][aria-selected="true"]'));
      this.descendants.set(column, descendant);
    }
    return this.descendants.get(column);
  }
}
