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

  describe('weekdayFormat value', () => {
    it('renders short weekday labels by default', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-locales-value='["en-US"]'>
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const headers = document
        .querySelector('[data-calendar-month-target="daysOfWeek"]')
        .querySelectorAll('[role="columnheader"]');
      expect(headers[0].textContent).toBe('Sun');
    });

    it('renders long weekday labels when weekdayFormat is "long"', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month"
             data-calendar-month-locales-value='["en-US"]'
             data-calendar-month-weekday-format-value="long">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const headers = document
        .querySelector('[data-calendar-month-target="daysOfWeek"]')
        .querySelectorAll('[role="columnheader"]');
      expect(headers[0].textContent).toBe('Sunday');
    });

    it('renders narrow weekday labels when weekdayFormat is "narrow"', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month"
             data-calendar-month-locales-value='["en-US"]'
             data-calendar-month-weekday-format-value="narrow">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const headers = document
        .querySelector('[data-calendar-month-target="daysOfWeek"]')
        .querySelectorAll('[role="columnheader"]');
      expect(headers[0].textContent).toBe('S');
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

  describe('aria-selected', () => {
    it('sets aria-selected="false" on all current-month cells when no selected value', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const buttons = daysOfMonth.querySelectorAll('button[role="gridcell"]');
      expect(buttons.length).toBeGreaterThan(0);
      for (const btn of buttons) {
        expect(btn.getAttribute('aria-selected')).toBe('false');
      }
    });

    it('sets aria-selected="true" only on the cell matching selected value', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-selected-value="2024-10-15">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('15');
    });

    it('sets aria-selected="false" on all other current-month cells when one is selected', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-selected-value="2024-10-15">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const notSelected = daysOfMonth.querySelectorAll('button[aria-selected="false"]');
      expect(notSelected.length).toBe(30); // 31 days in October, 1 selected
    });

    it('does not set aria-selected on hidden other-month cells', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      for (const cell of daysOfMonth.querySelectorAll('[aria-hidden="true"]')) {
        expect(cell.hasAttribute('aria-selected')).toBe(false);
      }
    });

    it('sets aria-selected="false" on visible other-month cells when daysOfOtherMonth is enabled', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      // navigable outside days are now buttons; filter by datetime to find non-October dates
      const outsideButtons = Array.from(daysOfMonth.querySelectorAll('button[role="gridcell"]')).filter((btn) => {
        const d = new Date(btn.querySelector('time').dateTime);
        return d.getMonth() !== 9 || d.getFullYear() !== 2024; // not October 2024
      });
      // Oct 2024: Sep 29-30 (leading) + Nov 1-2 (trailing) = 4 navigable outside days
      expect(outsideButtons.length).toBe(4);
      for (const btn of outsideButtons) {
        expect(btn.getAttribute('aria-selected')).toBe('false');
      }
    });

    it('select() sets aria-selected="true" on the matching cell', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      ctrl.select(new Date(2024, 9, 10).toISOString());
      await new Promise(resolve => setTimeout(resolve, 10));

      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('10');
    });

    it('select() does nothing for an unparseable iso', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-selected-value="2024-10-15">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      ctrl.select('not-a-date');
      await new Promise(resolve => setTimeout(resolve, 10));

      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('15');
    });

    it('re-renders aria-selected when selected value changes', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');

      expect(daysOfMonth.querySelectorAll('[aria-selected="true"]').length).toBe(0);

      el.dataset.calendarMonthSelectedValue = '2024-10-20';
      await new Promise(resolve => setTimeout(resolve, 10));

      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('20');
    });
  });

  describe('outside day navigation', () => {
    it('renders navigable outside days as buttons when daysOfOtherMonth is enabled', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      // Oct 2024: 31 current + 4 navigable outside = 35 buttons total
      expect(daysOfMonth.querySelectorAll('button[role="gridcell"]').length).toBe(35);
    });

    it('outside day buttons have no aria-disabled', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      for (const btn of daysOfMonth.querySelectorAll('button[role="gridcell"]')) {
        expect(btn.disabled).toBe(false);
        expect(btn.getAttribute('aria-disabled')).not.toBe('true');
      }
    });

    it('filler outside days (daysOfOtherMonth disabled) render as div with aria-disabled and aria-hidden', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      // When daysOfOtherMonthValue is false, outside days are not navigable → div + aria-disabled + aria-hidden
      const fillerDivs = daysOfMonth.querySelectorAll('div[role="gridcell"][aria-disabled="true"][aria-hidden="true"]');
      expect(fillerDivs.length).toBe(4); // Sep 29-30 + Nov 1-2
    });

    it('select() with outside day navigates to that month and selects the day', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      // Select Nov 1 (outside day — trailing padding for Oct 2024)
      const nov1 = new Date(2024, 10, 1);
      ctrl.select(nov1.toISOString());
      await new Promise(resolve => setTimeout(resolve, 50));

      // Calendar should have navigated to November 2024
      expect(ctrl.calendar.month).toBe(10); // November = month index 10
      expect(ctrl.calendar.year).toBe(2024);

      // Nov 1 should be selected in the redrawn month
      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('1');
    });

    it('select() with current-month day does not navigate', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-days-of-other-month-value="true">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      ctrl.select(new Date(2024, 9, 10).toISOString());
      await new Promise(resolve => setTimeout(resolve, 10));

      // Still October
      expect(ctrl.calendar.month).toBe(9);
      expect(ctrl.calendar.year).toBe(2024);
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

  describe('yearValue/monthValue navigation', () => {
    it('re-renders the day grid when yearValue changes', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month"
             data-calendar-month-year-value="2024"
             data-calendar-month-month-value="9">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      el.dataset.calendarMonthYearValue = '2025';
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(ctrl.calendar.year).toBe(2025);
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBeGreaterThan(0);
    });

    it('re-renders the day grid when monthValue changes', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month"
             data-calendar-month-year-value="2024"
             data-calendar-month-month-value="9">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      el.dataset.calendarMonthMonthValue = '1'; // February
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(ctrl.calendar.month).toBe(1);
      const buttons = Array.from(daysOfMonth.querySelectorAll('button[role="gridcell"]'));
      expect(buttons.some(btn => btn.textContent.trim() === '29')).toBe(true);
    });

    it('coalesces simultaneous year+month changes into one render', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month"
             data-calendar-month-year-value="2024"
             data-calendar-month-month-value="9">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');
      const navigateSpy = vi.spyOn(ctrl.calendar, 'navigate');

      el.dataset.calendarMonthYearValue = '2025';
      el.dataset.calendarMonthMonthValue = '2'; // March
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(navigateSpy).toHaveBeenCalledTimes(1);
      expect(ctrl.calendar.year).toBe(2025);
      expect(ctrl.calendar.month).toBe(2);
    });
  });
});
