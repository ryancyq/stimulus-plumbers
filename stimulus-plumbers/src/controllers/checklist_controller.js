import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['selectAll', 'item'];

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;
    // A morph rewrites every item's checked state from the markup, but never the select-all checkbox's
    // indeterminate property, so each morphed node schedules a recompute.
    this.element.addEventListener('turbo:morph-element', () => this._scheduleRecompute(), { signal });
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

  onFormReset() {
    this.recompute();
  }

  toggleAll(checked) {
    this.enabledItems()
      .filter((item) => item.checked !== checked)
      .forEach((item) => {
        item.checked = checked;
        item.dispatchEvent(new Event('input', { bubbles: true }));
        item.dispatchEvent(new Event('change', { bubbles: true }));
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
