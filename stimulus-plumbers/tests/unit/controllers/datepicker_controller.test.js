import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import DatepickerController from '../../../src/controllers/datepicker_controller';
import CalendarMonthController from '../../../src/controllers/calendar_month_controller';

describe('DatepickerController', () => {
  let application;

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] });
    vi.setSystemTime(new Date(2024, 9, 15)); // October 15, 2024

    application = Application.start();
    application.register('datepicker', DatepickerController);
    application.register('calendar-month', CalendarMonthController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    vi.useRealTimers();
  });

  const setup = () => {
    document.body.innerHTML = `
      <div data-controller="datepicker"
           data-datepicker-locales-value='["en-US"]'
           data-datepicker-calendar-month-outlet="[data-controller~='calendar-month']">
        <button data-datepicker-target="previous">Prev</button>
        <button data-datepicker-target="day"></button>
        <button data-datepicker-target="month"></button>
        <button data-datepicker-target="year"></button>
        <button data-datepicker-target="next">Next</button>
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      </div>
    `;
  };

  const setupWithInput = (value = '') => {
    document.body.innerHTML = `
      <div data-controller="datepicker popover"
           data-datepicker-locales-value='["en-US"]'
           data-datepicker-calendar-month-outlet="[data-controller~='calendar-month']">
        <input data-datepicker-target="display" type="text" data-action="focus->popover#show">
        <input data-datepicker-target="input" type="hidden" value="${value}">
        <div data-popover-target="content" hidden>
          <button data-datepicker-target="month"></button>
          <button data-datepicker-target="year"></button>
          <div data-controller="calendar-month">
            <div data-calendar-month-target="daysOfWeek"></div>
            <div data-calendar-month-target="daysOfMonth"></div>
          </div>
        </div>
      </div>
    `;
  };

  const getController = () => {
    const el = document.querySelector('[data-controller~="datepicker"]');
    return application.getControllerForElementAndIdentifier(el, 'datepicker');
  };

  describe('labels', () => {
    beforeEach(setup);

    it('draws day label on outlet connect', () => {
      expect(document.querySelector('[data-datepicker-target="day"]').textContent).toBe('15');
    });

    it('draws month label on outlet connect', () => {
      expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('October');
    });

    it('draws year label on outlet connect', () => {
      expect(document.querySelector('[data-datepicker-target="year"]').textContent).toBe('2024');
    });
  });

  describe('previous', () => {
    beforeEach(setup);

    it('steps calendar back one month', async () => {
      document.querySelector('[data-datepicker-target="previous"]').click();
      await vi.waitFor(() => {
        expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('September');
      });
    });

    describe('when in January', () => {
      beforeEach(() => {
        vi.setSystemTime(new Date(2024, 0, 15)); // January 15, 2024
        setup();
      });

      it('updates year label when stepping back past January', async () => {
        document.querySelector('[data-datepicker-target="previous"]').click();
        await vi.waitFor(() => {
          expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('December');
          expect(document.querySelector('[data-datepicker-target="year"]').textContent).toBe('2023');
        });
      });
    });
  });

  describe('next', () => {
    beforeEach(setup);

    it('steps calendar forward one month', async () => {
      document.querySelector('[data-datepicker-target="next"]').click();
      await vi.waitFor(() => {
        expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('November');
      });
    });

    describe('when in December', () => {
      beforeEach(() => {
        vi.setSystemTime(new Date(2024, 11, 15)); // December 15, 2024
        setup();
      });

      it('updates year label when stepping forward past December', async () => {
        document.querySelector('[data-datepicker-target="next"]').click();
        await vi.waitFor(() => {
          expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('January');
          expect(document.querySelector('[data-datepicker-target="year"]').textContent).toBe('2025');
        });
      });
    });
  });

  describe('input initialization', () => {
    it('navigates calendar to input date on outlet connect', async () => {
      setupWithInput('2024-03-20T00:00:00.000Z');
      await vi.waitFor(() => {
        expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('March');
        expect(document.querySelector('[data-datepicker-target="year"]').textContent).toBe('2024');
      });
    });

    it('uses current date when input is empty', async () => {
      setupWithInput('');
      await vi.waitFor(() => {
        expect(document.querySelector('[data-datepicker-target="month"]').textContent).toBe('October');
      });
    });
  });

  describe('selected', () => {
    it('writes iso date to input target', async () => {
      setupWithInput('');
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet);

      getController().selected({ detail: { iso: '2024-06-15T00:00:00.000Z' } });

      expect(document.querySelector('[data-datepicker-target="input"]').value).toBe('2024-06-15T00:00:00.000Z');
    });

    it('writes formatted date to display target', async () => {
      setupWithInput('');
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet);

      getController().selected({ detail: { iso: '2024-06-15T00:00:00.000Z' } });

      expect(document.querySelector('[data-datepicker-target="display"]').value).toBeTruthy();
    });

    it('does nothing when no input target', () => {
      setup();
      expect(() => getController()?.selected({ detail: { iso: '2024-06-15T00:00:00.000Z' } })).not.toThrow();
    });
  });

  describe('calendar grid', () => {
    beforeEach(setup);

    it('renders 35 gridcells for October 2024', () => {
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      expect(daysOfMonth.querySelectorAll('[role="gridcell"]').length).toBe(35);
    });

    it('redraws grid after previous', async () => {
      document.querySelector('[data-datepicker-target="previous"]').click();
      const daysOfMonth = document.querySelector('[data-calendar-month-target="daysOfMonth"]');
      await vi.waitFor(() => {
        expect(daysOfMonth.querySelectorAll('button').length).toBe(30);
      });
    });
  });
});
