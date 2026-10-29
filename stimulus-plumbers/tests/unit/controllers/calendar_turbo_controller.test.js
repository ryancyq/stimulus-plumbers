import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import CalendarTurboController from '../../../src/controllers/calendar_turbo_controller';
import { startApplication } from '../../support/stimulus';

describe('CalendarTurboController', () => {
  let application;

  const render = async () => {
    document.body.innerHTML = `<section id="root" data-controller="calendar-turbo"
        data-action="calendar:navigate->calendar-turbo#onNavigate turbo:before-fetch-response->calendar-turbo#onResponse
                     turbo:frame-missing->calendar-turbo#onError turbo:fetch-request-error->calendar-turbo#onError">
        <turbo-frame id="root_frame"><span id="inside"></span></turbo-frame>
        <turbo-frame id="other"></turbo-frame></section>`;
    const root = document.querySelector('#root');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'calendar-turbo'));
    const failed = vi.fn();
    root.addEventListener('calendar-turbo:failed', failed);
    return { root, frame: document.querySelector('turbo-frame'), failed };
  };

  beforeEach(() => {
    application = startApplication({ 'calendar-turbo': CalendarTurboController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('loads the requested period into the frame', async () => {
    const { root, frame } = await render();

    root.dispatchEvent(
      new CustomEvent('calendar:navigate', { detail: { url: 'http://localhost/?root%5Bview%5D=year' } })
    );

    expect(frame.src).toBe('http://localhost/?root%5Bview%5D=year');
  });

  it('reports a failed response', async () => {
    const { frame, failed } = await render();

    frame.dispatchEvent(
      new CustomEvent('turbo:before-fetch-response', { bubbles: true, detail: { fetchResponse: { succeeded: false } } })
    );
    frame.dispatchEvent(
      new CustomEvent('turbo:before-fetch-response', { bubbles: true, detail: { fetchResponse: { succeeded: true } } })
    );

    expect(failed).toHaveBeenCalledOnce();
  });

  it('ignores responses for other frames inside the calendar', async () => {
    const { failed } = await render();

    document.querySelector('#other').dispatchEvent(
      new CustomEvent('turbo:before-fetch-response', {
        bubbles: true,
        detail: { fetchResponse: { succeeded: false } },
      })
    );

    expect(failed).not.toHaveBeenCalled();
  });

  it('keeps the grid when the response has no matching frame', async () => {
    const { frame, failed } = await render();
    const missing = new CustomEvent('turbo:frame-missing', { bubbles: true, cancelable: true });

    frame.dispatchEvent(missing);
    frame.dispatchEvent(new CustomEvent('turbo:fetch-request-error', { bubbles: true }));

    expect(missing.defaultPrevented).toBe(true);
    expect(failed).toHaveBeenCalledTimes(2);
  });
});
