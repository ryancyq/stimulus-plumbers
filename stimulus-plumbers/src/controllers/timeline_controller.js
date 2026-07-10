import { Controller } from '@hotwired/stimulus';
import { DateFormatter } from '../plumbers/formatters/date';
import { RovingTabIndex } from '../accessibility/keyboard';
import { setExpanded, isExpanded, setHidden, announce } from '../accessibility/aria';

export default class extends Controller {
  static targets = ['trigger', 'detail', 'time'];
  static values = {
    dateFormat: { type: Object, default: {} },
  };

  connect() {
    this.rovingTabIndex = new RovingTabIndex(this.triggerTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }

  disconnect() {
    this.rovingTabIndex?.deactivate();
    this.rovingTabIndex = null;
  }

  toggle(event) {
    const trigger = event.currentTarget;
    isExpanded(trigger) ? this.collapseItem(trigger) : this.expandItem(trigger);
  }

  expand(event) {
    this.expandItem(event.currentTarget);
  }

  collapse(event) {
    this.collapseItem(event.currentTarget);
  }

  expandItem(trigger) {
    const detail = this.detailTargets.find((d) => d.id === trigger.getAttribute('aria-controls')) ?? null;
    this.dispatch('expand', { detail: { trigger, detail } });
    setExpanded(trigger, true);
    if (detail) {
      setHidden(detail, false);
      announce(`${trigger.textContent.trim()} expanded`);
    }
    this.dispatch('expanded', { detail: { trigger, detail } });
  }

  collapseItem(trigger) {
    const detail = this.detailTargets.find((d) => d.id === trigger.getAttribute('aria-controls')) ?? null;
    this.dispatch('collapse', { detail: { trigger, detail } });
    setExpanded(trigger, false);
    if (detail) {
      setHidden(detail, true);
      announce(`${trigger.textContent.trim()} collapsed`);
    }
    this.dispatch('collapsed', { detail: { trigger, detail } });
  }

  triggerTargetConnected(trigger) {
    if (!trigger.hasAttribute('aria-expanded')) setExpanded(trigger, false);
    this.rovingTabIndex?.updateItems(this.triggerTargets);
  }

  triggerTargetDisconnected() {
    this.rovingTabIndex?.updateItems(this.triggerTargets);
  }

  timeTargetConnected(el) {
    if (!Object.keys(this.dateFormatValue).length || el.textContent.trim()) return;
    const formatted = DateFormatter.format(el.getAttribute('datetime'), this.dateFormatValue);
    if (formatted) el.textContent = formatted;
  }
}
