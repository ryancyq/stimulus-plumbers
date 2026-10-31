import { Controller } from '@hotwired/stimulus';
import { ActiveDescendant } from '../accessibility/keyboard';

const MOVES = {
  ArrowDown: (descendant) => descendant.move(1),
  ArrowUp: (descendant) => descendant.move(-1),
  Home: (descendant) => descendant.first(),
  End: (descendant) => descendant.last(),
};

export default class extends Controller {
  static targets = ['trigger', 'input', 'panel', 'hour', 'minute', 'meridiem'];

  connect() {
    this.connection = new AbortController();
    // Survives reconnects.
    this.initial ??= this._snapshot();
    this.element
      .closest('form')
      ?.addEventListener(
        'reset',
        (event) => setTimeout(() => event.defaultPrevented || !this.connection || this._reset()),
        { signal: this.connection.signal }
      );
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
    this.descendants = null;
  }

  // ArrowDown opens the panel and focuses the hour column; Tab closes the panel.
  onKeydown(event) {
    if (event.key === 'ArrowDown') {
      event.preventDefault();
      if (!this._isOpen) this.panelTarget.showPopover({ source: this.triggerTarget });
      this.hourTarget.focus();
    } else if (event.key === 'Tab' && this._isOpen) {
      this.panelTarget.hidePopover();
    } else if (event.key === 'Escape') {
      this._cancel(event);
    }
  }

  // Records the value to restore on Escape.
  onOpening(event) {
    if (event.target === this.panelTarget) this.opened = this._snapshot();
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

  // Clicks on the icons and padding open the panel from the trigger.
  onClick(event) {
    if (!this._isInFieldBox(event.target)) return;

    this.triggerTarget.focus({ preventScroll: true });
    if (!this._isOpen) this.panelTarget.showPopover({ source: this.triggerTarget });
  }

  // Keeps focus on the trigger while the icons and padding are pressed.
  onMousedown(event) {
    if (this._isInFieldBox(event.target)) event.preventDefault();
  }

  // Closes the panel when focus moves to an element outside the combobox; WebKit sends focus
  // nowhere on a click inside the panel.
  onFocusout(event) {
    const target = event.relatedTarget;
    if (this._isOpen && target && !this.element.contains(target)) this.panelTarget.hidePopover();
  }

  get _isOpen() {
    return this.panelTarget.matches(':popover-open');
  }

  get _columns() {
    return [this.hourTarget, this.minuteTarget, ...this.meridiemTargets];
  }

  _cancel(event) {
    if (!this._isOpen) return;

    event.preventDefault();
    this._apply(this.opened);
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

  _snapshot() {
    return { value: this.inputTarget.value, options: this._columns.map((column) => this._selectedOption(column)) };
  }

  // Restores the initial time without a change event, as a native form reset does.
  _reset() {
    this.inputTarget.value = this.initial.value;
    this._apply(this.initial);
  }

  _apply({ value, options }) {
    this._columns.forEach((column, index) => this._selectOption(column, options[index]));
    this._setValue(value);
  }

  _setValue(value) {
    if (this.inputTarget.value !== value) {
      this.inputTarget.value = value;
      this.inputTarget.dispatchEvent(new Event('change', { bubbles: true }));
    }
    this.dispatch('changed', { detail: { value } });
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

  // Whether the target is in the input group holding the trigger, other than the trigger.
  _isInFieldBox(target) {
    return target !== this.triggerTarget && this.triggerTarget.parentElement.contains(target);
  }
}
