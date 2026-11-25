import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['selectAll', 'item'];

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;
    // A morph rewrites every item's checked state from the markup, but never the select-all checkbox's
    // indeterminate property, so each morphed node schedules a redraw.
    this.element.addEventListener('turbo:morph-element', () => this._scheduleDrawSelectAll(), { signal });
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  selectAllTargetConnected() {
    this._scheduleDrawSelectAll();
  }

  itemTargetConnected() {
    this._scheduleDrawSelectAll();
  }

  itemTargetDisconnected() {
    this._scheduleDrawSelectAll();
  }

  onChange(event) {
    if (this.hasSelectAllTarget && event.target === this.selectAllTarget) {
      this.toggleAll(this.selectAllTarget.checked);
      return;
    }
    this._drawSelectAll();
  }

  onFormReset() {
    this._drawSelectAll();
  }

  toggleAll(checked) {
    this.enabledItems()
      .filter((item) => item.checked !== checked)
      .forEach((item) => {
        item.checked = checked;
        item.dispatchEvent(new Event('input', { bubbles: true }));
        item.dispatchEvent(new Event('change', { bubbles: true }));
      });
    this._drawSelectAll();
  }

  _drawSelectAll() {
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
  // they share one redraw after the burst.
  _scheduleDrawSelectAll() {
    if (this._drawSelectAllScheduled) return;
    this._drawSelectAllScheduled = true;
    queueMicrotask(() => {
      this._drawSelectAllScheduled = false;
      this._drawSelectAll();
    });
  }
}
