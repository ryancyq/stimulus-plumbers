import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import CalendarMonthObserverController from '../../../src/controllers/calendar_month_observer_controller';

describe('CalendarMonthObserverController', () => {
  let application;

  beforeEach(async () => {
    application = Application.start();
    application.register('calendar-month-observer', CalendarMonthObserverController);

    document.body.innerHTML = `
      <div
        role="grid"
        data-controller="calendar-month-observer"
        data-action="click->calendar-month-observer#select"
      >
        <button role="gridcell" tabindex="0">
          <time datetime="2026-04-01">1</time>
        </button>
        <button role="gridcell" tabindex="-1" disabled>
          <time datetime="2026-04-02">2</time>
        </button>
        <span role="gridcell" tabindex="-1" aria-disabled="true" aria-selected="false">
          <time datetime="2026-03-31">31</time>
        </span>
        <span aria-hidden="true">
          <time datetime="2026-03-30"></time>
        </span>
      </div>
    `;

    await new Promise(resolve => setTimeout(resolve, 10));
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const grid = () => document.querySelector('[data-controller="calendar-month-observer"]');
  const button = () => document.querySelector('button[role="gridcell"]:not([disabled])');

  describe('select', () => {
    it('dispatches select and selected events when clicking a gridcell button', () => {
      const selectSpy = vi.fn();
      const selectedSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);
      grid().addEventListener('calendar-month-observer:selected', selectedSpy);

      button().click();

      expect(selectSpy).toHaveBeenCalledTimes(1);
      expect(selectedSpy).toHaveBeenCalledTimes(1);
    });

    it('selected event detail includes epoch and iso', () => {
      let detail;
      grid().addEventListener('calendar-month-observer:selected', e => { detail = e.detail; });

      button().click();

      expect(typeof detail.epoch).toBe('number');
      expect(detail.iso).toMatch(/^\d{4}-\d{2}-\d{2}T/);
    });

    it('epoch and iso correspond to the clicked cell datetime', () => {
      let detail;
      grid().addEventListener('calendar-month-observer:selected', e => { detail = e.detail; });

      button().click();

      const date = new Date(detail.epoch);
      expect(date.getFullYear()).toBe(2026);
      expect(date.getMonth()).toBe(3); // April (0-indexed)
      expect(date.getDate()).toBe(1);
    });

    it('dispatches when clicking the time child element inside a button', () => {
      const selectSpy = vi.fn();
      const selectedSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);
      grid().addEventListener('calendar-month-observer:selected', selectedSpy);

      button().querySelector('time').click();

      expect(selectSpy).toHaveBeenCalledTimes(1);
      expect(selectedSpy).toHaveBeenCalledTimes(1);
    });

    it('does not dispatch when clicking a disabled button', () => {
      const selectSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);

      document.querySelector('button[disabled]').click();

      expect(selectSpy).not.toHaveBeenCalled();
    });

    it('does not dispatch when clicking an aria-disabled cell', () => {
      const selectSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);

      document.querySelector('[aria-disabled="true"]').click();

      expect(selectSpy).not.toHaveBeenCalled();
    });

    it('dispatches select but not selected when cell has no time element', () => {
      const selectSpy = vi.fn();
      const selectedSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);
      grid().addEventListener('calendar-month-observer:selected', selectedSpy);

      const btn = document.createElement('button');
      btn.setAttribute('role', 'gridcell');
      grid().appendChild(btn);
      btn.click();

      expect(selectSpy).toHaveBeenCalledTimes(1);
      expect(selectedSpy).not.toHaveBeenCalled();
    });

    it('does not block dispatch when aria-disabled is false', () => {
      const selectSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:select', selectSpy);

      const btn = document.createElement('button');
      btn.setAttribute('role', 'gridcell');
      btn.setAttribute('aria-disabled', 'false');
      const time = document.createElement('time');
      time.dateTime = '2026-04-05';
      btn.appendChild(time);
      grid().appendChild(btn);
      btn.click();

      expect(selectSpy).toHaveBeenCalledTimes(1);
    });

    it('does not dispatch selected when time datetime is unparseable', () => {
      const selectedSpy = vi.fn();
      grid().addEventListener('calendar-month-observer:selected', selectedSpy);

      const btn = document.createElement('button');
      btn.setAttribute('role', 'gridcell');
      const time = document.createElement('time');
      time.dateTime = 'not-a-date';
      btn.appendChild(time);
      grid().appendChild(btn);
      btn.click();

      expect(selectedSpy).not.toHaveBeenCalled();
    });
  });
});
