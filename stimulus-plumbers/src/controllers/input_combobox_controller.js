import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['trigger', 'input'];
  static values = {
    value: String,
    minLength: { type: Number, default: 1 },
  };
  static outlets = ['combobox-dropdown'];

  onSelect(event) {
    if (event.detail?.value !== undefined) this.valueValue = event.detail.value;
  }

  onInput(event) {
    if (event.target !== this.triggerTarget) return;
    const query = event.target.value.trim();
    if (query.length < this.minLengthValue) {
      if (this.hasComboboxDropdownOutlet) this.comboboxDropdownOutlet.showAll();
      return;
    }
    if (this.hasComboboxDropdownOutlet) this.comboboxDropdownOutlet.filter(query);
  }

  valueValueChanged(newVal) {
    if (this.hasInputTarget) this.inputTarget.value = newVal;
    this.dispatch('changed', { detail: { value: newVal } });
  }
}
