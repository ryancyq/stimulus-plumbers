import { Controller } from '@hotwired/stimulus';
import { DateFormatter } from '../plumbers/formatters/date';

export default class extends Controller {
  static targets = ['trigger', 'detail'];
  static values = {
    dateFormat: { type: Object, default: {} },
  };

  connect() {
    this.formatTimes();
  }

  toggle(event) {
    const trigger = event.currentTarget;
    trigger.getAttribute('aria-expanded') === 'true' ? this.collapseItem(trigger) : this.expandItem(trigger);
  }

  expand(event) {
    this.expandItem(event.currentTarget);
  }

  collapse(event) {
    this.collapseItem(event.currentTarget);
  }

  expandItem(trigger) {
    trigger.setAttribute('aria-expanded', 'true');
    const detail = this.detailTargets.find((d) => d.id === trigger.getAttribute('aria-controls'));
    if (detail) detail.removeAttribute('hidden');
  }

  collapseItem(trigger) {
    trigger.setAttribute('aria-expanded', 'false');
    const detail = this.detailTargets.find((d) => d.id === trigger.getAttribute('aria-controls'));
    if (detail) detail.setAttribute('hidden', '');
  }

  triggerTargetConnected(trigger) {
    if (!trigger.hasAttribute('aria-expanded')) trigger.setAttribute('aria-expanded', 'false');
    trigger.addEventListener('keydown', this.onKeydown);
  }

  triggerTargetDisconnected(trigger) {
    trigger.removeEventListener('keydown', this.onKeydown);
  }

  formatTimes() {
    if (!Object.keys(this.dateFormatValue).length) return;
    this.element.querySelectorAll('time[datetime]').forEach((el) => {
      if (el.textContent.trim()) return;
      const formatted = DateFormatter.format(el.getAttribute('datetime'), this.dateFormatValue);
      if (formatted) el.textContent = formatted;
    });
  }

  onKeydown = (event) => {
    const triggers = this.triggerTargets;
    const index = triggers.indexOf(event.currentTarget);
    if (index === -1) return;

    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        triggers[(index + 1) % triggers.length].focus();
        break;
      case 'ArrowUp':
        event.preventDefault();
        triggers[(index - 1 + triggers.length) % triggers.length].focus();
        break;
      case 'Home':
        event.preventDefault();
        triggers[0].focus();
        break;
      case 'End':
        event.preventDefault();
        triggers[triggers.length - 1].focus();
        break;
    }
  };
}
