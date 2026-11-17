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
    this.descendants = null;
  }

  onKeydown(event) {
    if (event.key === 'Escape') this._cancel(event);
    else super.onKeydown(event);
  }

  // `opened` is what Escape restores.
  onOpening(event) {
    if (event.target !== this.panelTarget) return;

    this.opened = { value: this.inputTarget.value, selection: this._selectionFor(this.inputTarget.value) };
    this._showSelection(this.opened.selection);
  }

  // Shows the selected options.
  onOpened(event) {
    if (event.target !== this.panelTarget) return;

    this._columns.forEach((column) => this._selectedOption(column)?.scrollIntoView({ block: 'nearest' }));
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
    if (!option) return;

    this._activeDescendant(event.currentTarget).activate(option);
    this._selectionChanged();
  }

  get _columns() {
    return [this.hourTarget, this.minuteTarget, ...this.meridiemTargets];
  }

  _cancel(event) {
    if (!this._isOpen) return;

    event.preventDefault();
    this._showSelection(this.opened.selection);
    this._setValue(this.opened.value);
    this.panelTarget.hidePopover();
    this.triggerTarget.focus();
  }

  _selectionChanged() {
    const value = this._selectedValue();
    if (value) this._setValue(value);
  }

  // HH:MM from the selected options, or null until hour and minute are selected.
  _selectedValue() {
    const [hour, minute, meridiem] = this._columns.map((column) => this._selectedOption(column)?.dataset.value);
    if (!hour || !minute) return null;
    if (!this.hasMeridiemTarget) return `${hour}:${minute}`;
    if (!meridiem) return null;

    const twelve = Number(hour) % 12;
    return `${String(meridiem === 'PM' ? twelve + 12 : twelve).padStart(2, '0')}:${minute}`;
  }

  _focusPanel() {
    this.hourTarget.focus();
  }

  // The option of each column that a HH:MM value selects; none for a minute off the step.
  _selectionFor(value) {
    const [hour, minute] = (value || '').split(':').map(Number);
    const twelve = String(((hour + 11) % 12) + 1);
    const values = [
      this.hasMeridiemTarget ? twelve : String(hour).padStart(2, '0'),
      String(minute).padStart(2, '0'),
      hour < 12 ? 'AM' : 'PM',
    ];
    return {
      options: this._columns.map((column, index) =>
        value ? column.querySelector(`[role="option"][data-value="${values[index]}"]`) : null
      ),
    };
  }

  _showSelection({ options }) {
    this._columns.forEach((column, index) => this._selectOption(column, options[index]));
  }

  _selectOption(column, option) {
    if (option) this._activeDescendant(column).activate(option);
    else this._activeDescendant(column).clear();
  }

  _selectedOption(column) {
    return this._activeDescendant(column).active;
  }

  // Starts from the server-rendered selection.
  _activeDescendant(column) {
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
