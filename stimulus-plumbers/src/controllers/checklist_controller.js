import { Controller } from '@hotwired/stimulus';
import { onMorph } from '../plumbers/plumber/morph';
import { onFormReset } from '../plumbers/plumber/form_reset';

export default class extends Controller {
  static targets = ['master', 'item'];

  connect() {
    this.connection = new AbortController();
    const { signal } = this.connection;
    // Recomputes after a morph or a form reset.
    onMorph(this.element, () => this.recompute(), { signal });
    onFormReset(this.element, () => this.recompute(), { signal });
    this.recompute();
  }

  disconnect() {
    this.connection?.abort();
    this.connection = null;
  }

  masterTargetConnected() {
    this.recompute();
  }

  itemTargetConnected() {
    this.recompute();
  }

  itemTargetDisconnected() {
    this.recompute();
  }

  onChange(event) {
    if (this.hasMasterTarget && event.target === this.masterTarget) {
      this.toggleAll(this.masterTarget.checked);
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
    if (!this.hasMasterTarget) return;
    const items = this.enabledItems();
    const checkedCount = items.filter((item) => item.checked).length;
    this.masterTarget.checked = items.length > 0 && checkedCount === items.length;
    this.masterTarget.indeterminate = checkedCount > 0 && checkedCount < items.length;
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !item.disabled);
  }
}
