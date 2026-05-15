import WindowObserver from './plumber/window_observer';

const defaultOptions = {
  trigger: null,
  events: ['click'],
  onDismissed: 'dismissed',
};

export class Dismisser extends WindowObserver {
  constructor(controller, options = {}) {
    super(controller, options);

    const { trigger, events, onDismissed } = Object.assign({}, defaultOptions, options);
    this.onDismissed = onDismissed;
    this.trigger = trigger || this.element;
    this.events = events;

    this.enhance();
    this.observe(this.dismiss);
  }

  dismiss = async (event) => {
    const { target } = event;
    if (!(target instanceof HTMLElement)) return;
    if (this.element.contains(target)) return;
    if (!this.visible) return;

    this.dispatch('dismiss');
    await this.awaitCallback(this.onDismissed, { target: this.trigger });
    this.dispatch('dismissed');
  };
}

export const attachDismisser = (controller, options) => new Dismisser(controller, options);
