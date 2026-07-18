import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['master', 'item'];

  connect() {
    this.recompute();
  }

  onChange(event) {
    if (event.target === this.masterTarget) this.toggleAll(this.masterTarget.checked);
    this.recompute();
  }

  toggleAll(checked) {
    this.enabledItems().forEach((item) => {
      item.checked = checked;
    });
  }

  recompute() {
    const items = this.enabledItems();
    const checkedCount = items.filter((item) => item.checked).length;
    this.masterTarget.checked = items.length > 0 && checkedCount === items.length;
    this.masterTarget.indeterminate = checkedCount > 0 && checkedCount < items.length;
  }

  enabledItems() {
    return this.itemTargets.filter((item) => !item.disabled);
  }
}
