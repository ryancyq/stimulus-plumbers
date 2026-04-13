import { Controller } from '@hotwired/stimulus';
import { tryParseDate } from '../plumbers/plumber/support';

export default class extends Controller {
  select(event) {
    if (!(event.target instanceof HTMLElement)) return;

    event.preventDefault();
    const input = event.target instanceof HTMLTimeElement ? event.target.parentElement : event.target;
    if (input.disabled || input.getAttribute('aria-disabled') === 'true') return;

    this.dispatch('select', { target: input });
    const time = event.target instanceof HTMLTimeElement ? event.target : event.target.querySelector('time');
    if (!time) return console.error(`unable to locate time element within ${input}`);

    const date = tryParseDate(time.dateTime);
    if (!date) return console.error(`unable to parse ${time.dateTime} found within the time element`);

    this.dispatch('selected', {
      target: input,
      detail: { epoch: date.getTime(), iso: date.toISOString() },
    });
  }
}
