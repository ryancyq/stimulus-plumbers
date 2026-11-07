import { Controller } from '@hotwired/stimulus';
import { onFormReset } from '../plumbers/plumber/form_reset';

export default class extends Controller {
  static targets = ['selectAll', 'item'];

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;
    // A morph re-syncs every item's checked state from the markup, but never the select-all checkbox's
    // indeterminate property, so each morphed node schedules a recompute.
    this.element.addEventListener('turbo:morph-element', () => this._scheduleRecompute(), { signal });
    onFormReset(this.element, () => this.recompute(), { signal });
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  selectAllTargetConnected() {
    this._scheduleRecompute();
  }

  itemTargetConnected() {
    this._scheduleRecompute();
  }

  itemTargetDisconnected() {
    this._scheduleRecompute();
  }

  onChange(event) {
    if (this.hasSelectAllTarget && event.target === this.selectAllTarget) {
      this.toggleAll(this.selectAllTarget.checked);
      return;
    }
    this.recompute();
  }

  toggleAll(checked) {
    this.enabledItems().forEach((item) => {
      item.checked = checked;
    });
    this.recompute();
  }

  recompute() {
    if (!this.hasSelectAllTarget) return;
    const items = this.enabledItems();
    const checkedCount = items.filter((item) => item.checked).length;
    this.selectAllTarget.checked = items.length > 0 && checkedCount === items.length;
    this.selectAllTarget.indeterminate = checkedCount > 0 && checkedCount < items.length;
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !item.disabled);
  }

  // Target callbacks and morph events arrive in bursts (one per item on connect or morph);
  // they share one recompute after the burst.
  _scheduleRecompute() {
    if (this._recomputeScheduled) return;
    this._recomputeScheduled = true;
    queueMicrotask(() => {
      this._recomputeScheduled = false;
      this.recompute();
    });
  }
}
