import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import CalendarMonthController from '../../../src/controllers/calendar_month_controller';

describe('CalendarMonthController', () => {
  let application;

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] });
    vi.setSystemTime(new Date(2024, 9, 15)); // October 15, 2024

    application = Application.start();
    application.register('calendar-month', CalendarMonthController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    vi.useRealTimers();
  });

  describe('draw on connect', () => {
    let daysOfWeek, daysOfMonth;

    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-locales-value='["en-US"]'>
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      daysOfWeek = document.querySelector('[data-calendar-month-target="daysOfWeek"]');
      daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
    });

    it('renders a row of 7 columnheaders in daysOfWeek', () => {
      const row = daysOfWeek.querySelector('[role="row"]');
      expect(row).toBeTruthy();
      expect(row.children.length).toBe(7);
      for (const header of row.children) {
        expect(header.getAttribute('role')).toBe('columnheader');
        expect(header.title).toBeTruthy();
      }
    });

    it('renders 35 gridcells for October 2024', () => {
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(35);
    });

    it('renders 31 buttons for current-month days', () => {
      expect(daysOfMonth.querySelectorAll('button').length).toBe(31);
    });

    it('marks today with aria-current="date"', () => {
      const today = daysOfMonth.querySelector('[aria-current="date"]');
      expect(today).toBeTruthy();
      expect(today.textContent).toContain('15');
    });

    it('each gridcell contains a time element with dateTime', () => {
      for (const cell of daysOfMonth.querySelectorAll('[role="gridcell"]')) {
        const time = cell.querySelector('time');
        expect(time).toBeTruthy();
        expect(time.dateTime).toBeTruthy();
      }
    });
  });

  describe('trailing padding', () => {
    it('February 2015 renders exactly 28 gridcells', async () => {
      vi.setSystemTime(new Date(2015, 1, 1));
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(28);
    });

    it('November 2024 renders exactly 35 gridcells', async () => {
      vi.setSystemTime(new Date(2024, 10, 1));
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(35);
    });

    it('July 2023 renders exactly 42 gridcells', async () => {
      vi.setSystemTime(new Date(2023, 6, 1));
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(42);
    });
  });

  describe('daysOfOtherMonth', () => {
    it('hides text and disables leading/trailing gridcells by default', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const leading = daysOfMonth.querySelector('[role="gridcell"]');
      expect(leading.getAttribute('aria-disabled')).toBe('true');
      expect(leading.getAttribute('aria-hidden')).toBe('true');
    });

    it('shows text for other-month gridcells when enabled', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const leading = daysOfMonth.querySelector('[role="gridcell"]');
      expect(leading.getAttribute('aria-hidden')).not.toBe('true');
      expect(leading.textContent.trim()).not.toBe('');
    });
  });

  describe('today value', () => {
    it('marks the specified today date with aria-current="date"', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-today-value="2024-10-20">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const today = daysOfMonth.querySelector('[aria-current="date"]');
      expect(today).toBeTruthy();
      expect(today.textContent).toContain('20');
    });

    it('falls back to system date when today value is empty', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const today = daysOfMonth.querySelector('[aria-current="date"]');
      expect(today).toBeTruthy();
      expect(today.textContent).toContain('15'); // system time mocked to Oct 15, 2024
    });
  });

  describe('without targets', () => {
    it('connects and attaches calendar', async () => {
      document.body.innerHTML = '<div data-controller="calendar-month"></div>';
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="calendar-month"]'),
        'calendar-month'
      );
      expect(controller.calendar).toBeDefined();
    });
  });
});
