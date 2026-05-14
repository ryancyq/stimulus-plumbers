import { Controller } from '@hotwired/stimulus';
import { initComboboxDropdown } from '../plumbers/combobox_dropdown';

export default class extends Controller {
  static targets = ['listbox', 'loading', 'empty'];
  static values = {
    url: { type: String, default: '' },
    field: { type: String, default: 'q' },
    delay: { type: Number, default: 300 },
  };

  initialize() {
    this.comboboxDropdown = initComboboxDropdown(this);
  }

  onSelect(event) {
    const option = event.target.closest('[role="option"]');
    if (!option || option.getAttribute('aria-disabled') === 'true') return;
    this.select(option.dataset.value ?? '');
  }

  select(value) {
    const options = this.listboxTarget.querySelectorAll('[role="option"]');
    options.forEach((o) => o.setAttribute('aria-selected', 'false'));
    const option = [...options].find((o) => o.dataset.value === value);
    if (option) option.setAttribute('aria-selected', 'true');
    this.dispatch('selected', { detail: { value }, bubbles: true });
  }

  onNavigate(event) {
    if (!['ArrowUp', 'ArrowDown', 'Enter', ' '].includes(event.key)) return;
    event.preventDefault();
    if (event.key === 'Enter' || event.key === ' ') {
      this.listboxTarget.querySelector('[aria-selected="true"]')?.click();
      return;
    }
    this.step(event.key === 'ArrowDown' ? 1 : -1);
  }

  step(delta) {
    const options = [
      ...this.listboxTarget.querySelectorAll('[role="option"]:not([aria-disabled="true"]):not([hidden])'),
    ];
    if (!options.length) return;
    const current = this.listboxTarget.querySelector('[aria-selected="true"]');
    const idx = options.indexOf(current);
    const next = delta > 0 ? options[Math.min(idx + 1, options.length - 1)] : options[Math.max(idx - 1, 0)];
    if (!next || next === current) return;
    options.forEach((o) => o.setAttribute('aria-selected', 'false'));
    next.setAttribute('aria-selected', 'true');
    next.scrollIntoView({ block: 'nearest' });
  }

  // Called by input-combobox via outlet when in autocomplete mode
  filter(query) {
    if (this.urlValue) {
      this.comboboxDropdown.scheduleFetch(query, this.delayValue, {
        url: this.urlValue,
        field: this.fieldValue,
        onLoading: (on) => this.setLoading(on),
        onLoaded: (html) => {
          this.listboxTarget.innerHTML = html;
          this.setEmpty(this.listboxTarget.querySelectorAll('[role="option"]').length === 0);
        },
        onError: (err) => console.error('[combobox-dropdown] fetch failed', err),
      });
    } else {
      const visible = this.comboboxDropdown.fuzzyFilter(this.listboxTarget, query);
      this.setEmpty(visible === 0);
    }
  }

  showAll() {
    this.listboxTarget.querySelectorAll('[role="option"]').forEach((o) => (o.hidden = false));
    this.setEmpty(false);
  }

  setLoading(on) {
    if (this.hasLoadingTarget) this.loadingTarget.hidden = !on;
  }
  setEmpty(on) {
    if (this.hasEmptyTarget) this.emptyTarget.hidden = !on;
  }

  disconnect() {
    this.comboboxDropdown.cancel();
  }
}
