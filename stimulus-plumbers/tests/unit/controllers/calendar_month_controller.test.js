import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import CalendarMonthController from '../../../src/controllers/calendar_month_controller';

describe('CalendarMonthController', () => {
  let application;

  beforeEach(() => {
    // Only fake Date so setTimeout still works for Stimulus connection lifecycle
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
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-locales-value='["en-US"]'>
          <div data-calendar-month-target="day"></div>
          <div data-calendar-month-target="month"></div>
          <div data-calendar-month-target="year"></div>
          <button data-calendar-month-target="previous">Previous</button>
          <button data-calendar-month-target="next">Next</button>
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('renders 7 days of week headers', () => {
      const daysOfWeek = document.querySelector('[data-calendar-month-target="daysOfWeek"]');
      expect(daysOfWeek.childElementCount).toBe(7);
    });

    it('each day of week header has a non-empty title', () => {
      const daysOfWeek = document.querySelector('[data-calendar-month-target="daysOfWeek"]');
      for (const child of daysOfWeek.children) {
        expect(child.title).toBeTruthy();
      }
    });

    it('renders 35 cells for October 2024 (2 leading + 31 current + 2 trailing)', () => {
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(35);
    });

    it('renders 31 buttons for October 2024 current-month days', () => {
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('button').length).toBe(31);
    });

    it('marks today with ariaCurrent="date"', () => {
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const todayCell = [...daysOfMonth.querySelectorAll('[role="gridcell"]')].find(el => el.ariaCurrent === 'date');
      expect(todayCell).toBeDefined();
      expect(todayCell.textContent).toBe('15');
    });

    it('renders current year in year target', () => {
      const yearTarget = document.querySelector('[data-calendar-month-target="year"]');
      expect(yearTarget.textContent).toBe('2024');
    });

    it('renders non-empty text in month target', () => {
      const monthTarget = document.querySelector('[data-calendar-month-target="month"]');
      expect(monthTarget.textContent).toBeTruthy();
    });

    it('renders current day number in day target (fixes { day } option)', () => {
      const dayTarget = document.querySelector('[data-calendar-month-target="day"]');
      // With bug { date: ... }, Intl ignores the invalid key and returns a full date string.
      // With fix { day: ... }, it returns just the day number "15".
      expect(dayTarget.textContent).toBe('15');
    });

    it('each day cell contains a time element with a dateTime attribute', () => {
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      for (const child of daysOfMonth.children) {
        const time = child.querySelector('time');
        expect(time).toBeTruthy();
        expect(time.dateTime).toBeTruthy();
      }
    });
  });

  describe('draw skips targets that already have children', () => {
    it('does not overwrite day target when it already has child elements', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="day"><span>Custom</span></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const dayTarget = document.querySelector('[data-calendar-month-target="day"]');
      expect(dayTarget.textContent).toBe('Custom');
    });
  });

  describe('trailing padding fix', () => {
    it('February 2015 (28 days starting on Sunday) renders exactly 28 cells', async () => {
      // Feb 1, 2015 = Sunday → 0 leading days, 28 current days, 28 % 7 === 0 → 0 trailing
      // Without fix: 7 - (28 % 7) = 7 trailing cells → 35 total
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

    it('November 2024 (35-cell grid) renders exactly 35 cells', async () => {
      // Nov 1, 2024 = Friday → 5 leading + 30 current = 35, 35 % 7 === 0 → 0 trailing
      // Without fix: 7 - (35 % 7) = 7 trailing cells → 42 total
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

    it('July 2023 (42-cell grid) renders exactly 42 cells', async () => {
      // Jul 1, 2023 = Saturday → 6 leading + 31 current + 5 trailing = 42
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

  describe('navigation', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="year"></div>
          <button data-calendar-month-target="previous">Previous</button>
          <button data-calendar-month-target="next">Next</button>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('previous button navigates to previous month', async () => {
      const element = document.querySelector('[data-controller="calendar-month"]');
      const navigated = new Promise(resolve => {
        element.addEventListener('calendar-month:navigated', resolve, { once: true });
      });

      document.querySelector('[data-calendar-month-target="previous"]').click();
      await navigated;

      // September 2024: 30 current-month days
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('button').length).toBe(30);
    });

    it('next button navigates to next month', async () => {
      const element = document.querySelector('[data-controller="calendar-month"]');
      const navigated = new Promise(resolve => {
        element.addEventListener('calendar-month:navigated', resolve, { once: true });
      });

      document.querySelector('[data-calendar-month-target="next"]').click();
      await navigated;

      // November 2024: 30 current-month days
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('button').length).toBe(30);
    });

    it('dispatches navigate and navigated events', async () => {
      const element = document.querySelector('[data-controller="calendar-month"]');
      const navigateSpy = vi.fn();
      element.addEventListener('calendar-month:navigate', navigateSpy);

      const navigated = new Promise(resolve => {
        element.addEventListener('calendar-month:navigated', resolve, { once: true });
      });

      document.querySelector('[data-calendar-month-target="next"]').click();
      await navigated;

      expect(navigateSpy).toHaveBeenCalledTimes(1);
    });

    it('navigate event detail contains from and to ISO strings', async () => {
      const element = document.querySelector('[data-controller="calendar-month"]');
      let navigateEvent;
      element.addEventListener('calendar-month:navigate', e => {
        navigateEvent = e;
      });

      const navigated = new Promise(resolve => {
        element.addEventListener('calendar-month:navigated', resolve, { once: true });
      });

      document.querySelector('[data-calendar-month-target="next"]').click();
      await navigated;

      expect(navigateEvent.detail.from).toMatch(/^\d{4}-\d{2}-\d{2}T/);
      expect(navigateEvent.detail.to).toMatch(/^\d{4}-\d{2}-\d{2}T/);
    });
  });

  describe('daysOfOtherMonth option', () => {
    it('hides day text for leading and trailing days by default', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      // Oct 2024: first 2 gridcells are Sep 29 and Sep 30 (leading divs)
      const leadingDiv = daysOfMonth.querySelector('[role="gridcell"]');
      expect(leadingDiv.ariaDisabled).toBe('true');
      expect(leadingDiv.ariaHidden).toBe('true');
    });

    it('shows day text for other-month days when daysOfOtherMonth is enabled', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      // Sep 29 (leading) should now display its day number
      const leadingDiv = daysOfMonth.children[0];
      expect(leadingDiv.ariaHidden).not.toBe('true');
      expect(leadingDiv.textContent.trim()).not.toBe('');
    });
  });

  describe('without targets', () => {
    it('connects and exposes calendar when no targets are present', async () => {
      document.body.innerHTML = '<div data-controller="calendar-month"></div>';
      await new Promise(resolve => setTimeout(resolve, 10));

      const element = document.querySelector('[data-controller="calendar-month"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'calendar-month');
      expect(controller).toBeTruthy();
      expect(controller.calendar).toBeDefined();
      expect(controller.calendar.year).toBe(2024);
      expect(controller.calendar.month).toBe(9); // October (0-indexed)
    });
  });
});
