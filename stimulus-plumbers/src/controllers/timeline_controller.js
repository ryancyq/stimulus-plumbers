import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['trigger', 'detail', 'item'];
  static values = {
    orientation: { type: String, default: 'vertical' },
  };

  connect() {
    this.triggerTargets.forEach((trigger) => {
      if (!trigger.hasAttribute('aria-expanded')) {
        trigger.setAttribute('aria-expanded', 'false');
      }
    });
  }

  toggle(event) {
    const trigger = event.currentTarget;
    if (trigger.getAttribute('aria-expanded') === 'true') {
      this.collapseItem(trigger);
    } else {
      this.expandItem(trigger);
    }
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
    trigger.addEventListener('keydown', this.onKeydown);
  }

  triggerTargetDisconnected(trigger) {
    trigger.removeEventListener('keydown', this.onKeydown);
  }

  onKeydown = (event) => {
    const triggers = this.triggerTargets;
    const index = triggers.indexOf(event.currentTarget);

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
