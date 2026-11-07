import { Controller } from '@hotwired/stimulus';
import { attachPopover, isPopoverElement } from '../plumbers/popover';
import { onFormReset } from '../plumbers/plumber/form_reset';
import { ensureId, isAriaDisabled, setExpanded, setHidden, setSelected } from '../accessibility/aria';
import { ActiveDescendant } from '../accessibility/keyboard';
import { fuzzyMatcher, matchContains, matchPrefix } from '../matcher';

const OPTION_SELECTOR = '[role="option"]';
const MATCHERS = {
  prefix: matchPrefix,
  contains: matchContains,
  fuzzy: fuzzyMatcher,
  none: () => true,
};
const normalize = (text) => text.normalize('NFD').replace(/\p{M}/gu, '').toLocaleLowerCase();

export default class extends Controller {
  static targets = ['trigger', 'input', 'panel', 'listbox', 'status'];
  static values = {
    mode: { type: String, default: 'select_only' },
    valuePolicy: { type: String, default: 'restricted' },
    closeOnSelect: { type: Boolean, default: true },
    match: { type: String, default: 'prefix' },
    minLength: { type: Number, default: 1 },
    emptyText: { type: String, default: 'No results' },
  };

  initialize() {
    this.expanded = false;
    this.edited = false;
    this.selection = { value: '', label: '' };
    this.initial = null;
    this.sequence = 0;
    this.query = '';
    this.filtered = [];
    this.activeDescendant = new ActiveDescendant(() => this.triggerTarget, {
      options: () => this._allOptions(),
      enabled: (option) => this._isSelectable(option),
      idPrefix: 'combobox-option',
    });
  }

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;

    document.addEventListener(
      'turbo:before-cache',
      () => {
        this._closePanel();
        this._resetFilter();
      },
      { signal }
    );
    this.selection = { value: this.inputTarget.value, label: this._displayLabel() };
    // Survives reconnects.
    this.initial ??= { ...this.selection };
    onFormReset(this.element, () => this._restoreInitial(), { signal });
    this._syncSelection();
    if (!this.hasPanelTarget)
      console.error('ComboboxController requires a panel target. Add data-combobox-target="panel".');
    if (this._isEditable() && !this.hasStatusTarget)
      console.error('ComboboxController requires a status target when editable. Add data-combobox-target="status".');
  }

  disconnect() {
    this._closePanel();
    this.connection?.abort();
    this.connection = null;
    this._disposePopover();
  }

  panelTargetConnected(panel) {
    this._disposePopover();
    if (!isPopoverElement(panel)) {
      console.error('ComboboxController requires data-combobox-target="panel" to be a native popover element.');
      return;
    }

    this.popover = attachPopover(this, { element: panel, prefix: 'combobox' });
    this.panelElement = panel;
    this.panelListeners = new AbortController();
    const { signal } = this.panelListeners;
    // External show/hide.
    panel.addEventListener(
      'combobox:opened',
      (event) => event.target === panel && !this.expanded && this._afterOpen('none'),
      { signal }
    );
    panel.addEventListener(
      'combobox:closed',
      (event) => event.target === panel && this.expanded && this._afterClose(),
      {
        signal,
      }
    );
  }

  panelTargetDisconnected(panel) {
    if (this.panelElement !== panel) return;

    if (this.expanded) this._afterClose();
    this._disposePopover();
  }

  listboxTargetConnected() {
    this.filtered = this.filtered.filter((element) => element.isConnected);
    this._allOptions().forEach((option) => ensureId(option, 'combobox-option'));
    if (this.expanded && this._isEditable()) this._filter(this.query);
    const active = this.activeDescendant.active;
    if (!active) this.triggerTarget.removeAttribute('aria-activedescendant');
    if (this.expanded && !active) this.activeDescendant.clear();
    else this._syncSelection(active);
  }

  onKeydown(event) {
    if (event.ctrlKey || event.metaKey || event.altKey) return;

    const editable = this._isEditable();
    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowUp':
        event.preventDefault();
        if (this.expanded) this.activeDescendant.move(event.key === 'ArrowDown' ? 1 : -1);
        else this._openPanel(event.key === 'ArrowDown' ? 'first' : 'last');
        break;
      case 'Home':
      case 'End':
        if (editable) return;
        event.preventDefault();
        if (!this.expanded) this._openPanel();
        if (!this.expanded) return;
        if (event.key === 'Home') this.activeDescendant.first();
        else this.activeDescendant.last();
        break;
      case 'Enter':
        if (event.isComposing || !this.expanded || !this.activeDescendant.active) return;
        event.preventDefault();
        this.select(this.activeDescendant.active);
        break;
      case ' ':
        if (editable || !this.expanded || !this.activeDescendant.active) return;
        event.preventDefault();
        this.select(this.activeDescendant.active);
        break;
      case 'Escape':
        if (event.isComposing || !this.expanded) return;
        event.preventDefault();
        this._closePanel();
        break;
      case 'Tab': {
        if (!this.expanded) return;
        const active = this.activeDescendant.active;
        if (active && this._optionValue(active) !== this.selection.value) this.select(active);
        this._closePanel();
        break;
      }
    }
  }

  onInput() {
    if (!this._isEditable()) return;

    const text = this.triggerTarget.value;
    this.activeDescendant.clear();
    if (this.valuePolicyValue === 'freeform') {
      this.inputTarget.value = text;
      this.selection = { value: text, label: text };
    } else {
      this.edited = true;
      this.inputTarget.value = '';
    }
    const query = text.trim().length < this.minLengthValue ? '' : text;
    this._filter(query);
    if (query !== this.query) {
      this.query = query;
      this.dispatch('query', { detail: { query, sequence: ++this.sequence } });
    }
    if (!this.expanded) this._openPanel('none');
  }

  _filter(query) {
    this._clearFilter();
    const matcher = MATCHERS[this.matchValue] || MATCHERS.prefix;
    const needle = normalize(query);
    if (needle && this.hasListboxTarget) {
      this._allOptions()
        .filter((option) => !matcher(needle, normalize(this._optionLabel(option))))
        .forEach((option) => this._hideFiltered(option));
      this.listboxTarget.querySelectorAll('[role="group"]').forEach((group) => {
        if ([...group.querySelectorAll(OPTION_SELECTOR)].every((option) => option.closest('[hidden]'))) {
          const groupContainer = group.parentElement;
          const presentational =
            groupContainer !== this.listboxTarget && groupContainer.matches('[role="none"], [role="presentation"]');
          this._hideFiltered(presentational ? groupContainer : group);
        }
      });
    }
    if (!this.activeDescendant.active) this.activeDescendant.clear();

    const count = this._allOptions().filter((option) => !option.closest('[hidden]')).length;
    if (this.hasStatusTarget) this.statusTarget.textContent = count === 0 && query ? this.emptyTextValue : '';
    this.dispatch('results', { detail: { query, count } });
  }

  _hideFiltered(element) {
    if (element.hidden) return;
    setHidden(element, true);
    this.filtered.push(element);
  }

  _clearFilter() {
    this.filtered.forEach((element) => setHidden(element, false));
    this.filtered = [];
  }

  _resetFilter() {
    this._clearFilter();
    this.query = '';
    if (this.hasStatusTarget) this.statusTarget.textContent = '';
  }

  onClick(event) {
    const option = event.target.closest?.(OPTION_SELECTOR);
    if (option && this.hasListboxTarget && this.listboxTarget.contains(option)) {
      this.select(option);
      return;
    }

    // Icons and padding act on the trigger.
    const interactive = event.target.closest?.('button, a, input, select, textarea');
    if (interactive && interactive !== this.triggerTarget) return;
    if (this.hasPanelTarget && this.panelTarget.contains(event.target)) return;
    // WebKit does not focus a clicked button.
    this.triggerTarget.focus({ preventScroll: true });
    if (this.expanded && !this._isEditable()) this._closePanel();
    else if (!this.expanded) this._openPanel();
  }

  onMousedown(event) {
    if (!this.triggerTarget.contains(event.target)) event.preventDefault();
  }

  select(option) {
    if (!this._isSelectable(option)) return false;

    const value = this._optionValue(option);
    const label = this._optionLabel(option);
    const detail = { value, label, option };
    if (this.dispatch('before-change', { detail, cancelable: true }).defaultPrevented) return false;

    this.inputTarget.value = value;
    this._setDisplayLabel(label);
    this.selection = { value, label };
    this.edited = false;
    if (this.expanded) this.activeDescendant.activate(option);
    else this._syncSelection();
    this.dispatch('changed', { detail });
    if (this.closeOnSelectValue) this._closePanel();
    return true;
  }

  _openPanel(initial = 'selected') {
    if (this.expanded || !this.popover || !this._hasResults()) return;

    this.popover.show(this.triggerTarget);
    if (this.popover.open) this._afterOpen(initial);
  }

  _closePanel() {
    if (!this.expanded) return;

    this._afterClose();
    this.popover?.hide();
  }

  _afterOpen(initial) {
    this.expanded = true;
    setExpanded(this.triggerTarget, true);

    const selected = initial === 'none' ? null : this._selectedOption();
    if (selected) this.activeDescendant.activate(selected);
    else if (initial === 'first') this.activeDescendant.first();
    else if (initial === 'last') this.activeDescendant.last();

    this.openListeners?.abort();
    this.openListeners = new AbortController();
    const { signal } = this.openListeners;
    const closeIfOutside = (event) => {
      if (!this.element.contains(event.target)) this._closePanel();
    };
    document.addEventListener('click', closeIfOutside, { capture: true, signal });
    document.addEventListener('focusin', closeIfOutside, { signal });
    // Focus moving into an iframe fires no focusin here.
    window.addEventListener(
      'blur',
      () => {
        if (document.activeElement?.matches('iframe')) this._closePanel();
      },
      { signal }
    );
  }

  // Runs synchronously.
  _afterClose() {
    this.expanded = false;
    this.openListeners?.abort();
    this.openListeners = null;
    setExpanded(this.triggerTarget, false);

    if (this.edited) {
      this.inputTarget.value = this.selection.value;
      this._setDisplayLabel(this.selection.label);
      this.edited = false;
    }
    this.activeDescendant.clear();
    this._resetFilter();
    this._syncSelection();
  }

  _syncSelection(active = null) {
    const selected = active || this._selectedOption();
    this._allOptions().forEach((option) => setSelected(option, option === selected));
  }

  _restoreInitial() {
    this._closePanel();
    this._resetFilter();
    this.inputTarget.value = this.initial.value;
    this._setDisplayLabel(this.initial.label);
    this.selection = { ...this.initial };
    this.edited = false;
    this._syncSelection();
  }

  _selectedOption() {
    const value = this.selection.value;
    if (value === '') return null;
    return this._allOptions().find((option) => this._optionValue(option) === value) || null;
  }

  _hasResults() {
    if (this.hasStatusTarget && this.statusTarget.textContent.trim()) return true;
    return this._allOptions().some((option) => !option.closest('[hidden]'));
  }

  _allOptions() {
    return this.hasListboxTarget ? [...this.listboxTarget.querySelectorAll(OPTION_SELECTOR)] : [];
  }

  _isSelectable(option) {
    return (
      !!option &&
      this.hasListboxTarget &&
      this.listboxTarget.contains(option) &&
      !isAriaDisabled(option) &&
      !option.closest('[hidden]')
    );
  }

  _optionValue(option) {
    return option.dataset.value ?? this._optionLabel(option);
  }

  _optionLabel(option) {
    return option.dataset.label ?? option.textContent.trim();
  }

  _isEditable() {
    return this.modeValue === 'editable';
  }

  _displayLabel() {
    return this._isEditable() ? this.triggerTarget.value : this.triggerTarget.textContent.trim();
  }

  _setDisplayLabel(label) {
    if (this._isEditable()) this.triggerTarget.value = label;
    else this.triggerTarget.textContent = label;
  }

  _disposePopover() {
    this.panelListeners?.abort();
    this.panelListeners = null;
    this.popover?.disconnect();
    this.popover = null;
    this.panelElement = null;
  }
}
