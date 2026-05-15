import { Controller } from '@hotwired/stimulus';
import { Requestor } from '../requestor';
import { filterOptions } from '../researcher';

export default class extends Controller {
  static targets = ['listbox', 'loading', 'empty'];
  static values = {
    url: { type: String, default: '' },
    field: { type: String, default: 'q' },
    delay: { type: Number, default: 300 },
  };

  initialize() {
    this._requestor = new Requestor();
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

  filter(query) {
    if (this.urlValue) {
      const url = new URL(this.urlValue, window.location.href);
      url.searchParams.set(this.fieldValue, query);
      this.setLoading(true);
      this._requestor.schedule(
        () =>
          this._requestor
            .request(url)
            .then((r) => r.text())
            .then((html) => {
              this.listboxTarget.innerHTML = html;
              this.setEmpty(this.listboxTarget.querySelectorAll('[role="option"]').length === 0);
            })
            .catch((err) => {
              if (err.name !== 'AbortError') console.error('[combobox-dropdown] fetch failed', err);
            })
            .finally(() => this.setLoading(false)),
        this.delayValue
      );
    } else {
      const visible = filterOptions(this.listboxTarget, query);
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
    this._requestor.cancel();
  }
}
