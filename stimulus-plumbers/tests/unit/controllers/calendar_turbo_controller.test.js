import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import CalendarTurboController from '../../../src/controllers/calendar_turbo_controller';
import { startApplication } from '../../support/stimulus';

describe('CalendarTurboController', () => {
  let application;

  const render = async () => {
    document.body.innerHTML = `<section id="container" data-controller="calendar-turbo"
        data-action="calendar:navigate->calendar-turbo#onNavigate turbo:before-fetch-response->calendar-turbo#onResponse
                     turbo:frame-missing->calendar-turbo#onError turbo:fetch-request-error->calendar-turbo#onError">
        <turbo-frame id="container_frame"><span id="inside"></span></turbo-frame>
        <turbo-frame id="other"></turbo-frame></section>`;
    const container = document.querySelector('#container');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'calendar-turbo'));
    const failed = vi.fn();
    container.addEventListener('calendar-turbo:failed', failed);
    return { container, frame: document.querySelector('turbo-frame'), failed };
  };

  beforeEach(() => {
    application = startApplication({ 'calendar-turbo': CalendarTurboController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('loads the requested period into the frame', async () => {
    const { container, frame } = await render();

    container.dispatchEvent(
      new CustomEvent('calendar:navigate', { detail: { url: 'http://localhost/?container%5Bview%5D=year' } })
    );

    expect(frame.src).toBe('http://localhost/?container%5Bview%5D=year');
  });

  it('reports a failed response', async () => {
    const { frame, failed } = await render();

    frame.dispatchEvent(
      new CustomEvent('turbo:before-fetch-response', { bubbles: true, detail: { fetchResponse: { succeeded: false } } })
    );
    frame.dispatchEvent(
      new CustomEvent('turbo:before-fetch-response', {
        bubbles: true,
        detail: { fetchResponse: { succeeded: true, isHTML: true } },
      })
    );

    expect(failed).toHaveBeenCalledOnce();
  });
});
