import { Controller } from '@hotwired/stimulus';
import { setExpanded } from '../aria';

export default class InputComboboxController extends Controller {
  static targets = ['trigger', 'popover', 'value'];
  static values = {
    value: String,
    minLength: { type: Number, default: 1 },
  };
  static outlets = ['combobox-dropdown'];

  open() {
    if (!this.hasPopoverTarget) return;
    this.popoverTarget.hidden = false;
    if (this.hasTriggerTarget) setExpanded(this.triggerTarget, true);
    this.focusFirstInPopover();
  }

  close() {
    if (!this.hasPopoverTarget) return;
    this.popoverTarget.hidden = true;
    if (this.hasTriggerTarget) {
      setExpanded(this.triggerTarget, false);
      this.triggerTarget.focus();
    }
  }

  toggle() {
    this.hasPopoverTarget && this.popoverTarget.hidden ? this.open() : this.close();
  }

  // Receives combobox-*:selected events from sub-controllers
  onSelect(event) {
    if (event.detail?.value !== undefined) this.valueValue = event.detail.value;
    this.close();
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
    if (this.hasValueTarget) this.valueTarget.value = newVal;
    this.dispatch('changed', { detail: { value: newVal } });
  }

  focusFirstInPopover() {
    if (!this.hasPopoverTarget) return;
    const focusable = this.popoverTarget.querySelector(
      'button:not([disabled]), [href], input:not([type="hidden"]):not([disabled]), [tabindex]:not([tabindex="-1"])'
    );
    focusable?.focus();
  }
}
