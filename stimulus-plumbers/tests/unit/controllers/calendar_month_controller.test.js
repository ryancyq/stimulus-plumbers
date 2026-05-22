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
      const otherMonth = daysOfMonth.querySelectorAll('div[role="gridcell"]');
      expect(otherMonth.length).toBeGreaterThan(0);
      for (const cell of otherMonth) {
        expect(cell.getAttribute('aria-selected')).toBe('false');
      }
    });

    it('onSelect() sets aria-selected="true" on the matching cell', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      ctrl.onSelect(new CustomEvent('selected', { detail: { iso: new Date(2024, 9, 10).toISOString() } }));
      await new Promise(resolve => setTimeout(resolve, 10));

      const selected = daysOfMonth.querySelectorAll('[aria-selected="true"]');
      expect(selected.length).toBe(1);
      expect(selected[0].textContent).toContain('10');
    });

    it('onSelect() does nothing when detail iso is absent', async () => {
      document.body.innerHTML = `
        <div data-controller="calendar-month" data-calendar-month-selected-value="2024-10-15">
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const el = document.querySelector('[data-controller="calendar-month"]');
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      const ctrl = application.getControllerForElementAndIdentifier(el, 'calendar-month');

      ctrl.onSelect(new CustomEvent('selected', { detail: {} }));
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
