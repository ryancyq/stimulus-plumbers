import { Controller } from '@hotwired/stimulus';
import { focusFirst } from '../accessibility/focus';
import { attachDismisser, attachVisibility } from '../plumbers';

export default class extends Controller {
  static targets = ['trigger', 'popover', 'input'];
  static values = {
    value: String,
    minLength: { type: Number, default: 1 },
  };
  static outlets = ['combobox-dropdown'];

  connect() {
    attachDismisser(this);
    if (this.hasPopoverTarget) {
      attachVisibility(this, {
        element: this.popoverTarget,
        activator: this.hasTriggerTarget ? this.triggerTarget : null,
      });
    }
  }

  async dismissed() {
    await this.close();
  }

  async open() {
    if (!this.hasPopoverTarget) return;
    await this.visibility.show();
  }

  async close() {
    if (!this.hasPopoverTarget) return;
    await this.visibility.hide();
  }

  async toggle() {
    this.visibility?.visible ? await this.close() : await this.open();
  }

  async shown() {
    if (this.hasPopoverTarget) focusFirst(this.popoverTarget);
  }

  async hidden() {
    if (this.hasTriggerTarget) this.triggerTarget.focus();
  }

  // Receives combobox-*:selected events from sub-controllers
  async onSelect(event) {
    if (event.detail?.value !== undefined) this.valueValue = event.detail.value;
    await this.close();
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
