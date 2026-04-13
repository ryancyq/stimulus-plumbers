import Plumber from './plumber';
import { isValidDate, tryParseDate } from './plumber/support';

const DAYS_OF_WEEK = 7;

const defaultOptions = {
  locales: ['default'],
  today: '',
  day: null,
  month: null,
  year: null,
  since: null,
  till: null,
  disabledDates: [],
  disabledWeekdays: [],
  disabledDays: [],
  disabledMonths: [],
  disabledYears: [],
  firstDayOfWeek: 0,
  onNavigated: 'navigated',
};

export class Calendar extends Plumber {
  /**
   * Creates a new Calendar plumber instance with date navigation and validation.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {string[]} [options.locales=['default']] - Locale identifiers for date formatting
   * @param {string|Date} [options.today=''] - Initial "today" date
   * @param {number} [options.day] - Initial day
   * @param {number} [options.month] - Initial month (0-11)
   * @param {number} [options.year] - Initial year
   * @param {string|Date} [options.since] - Minimum selectable date
   * @param {string|Date} [options.till] - Maximum selectable date
   * @param {Array<string|Date>} [options.disabledDates=[]] - Array of disabled dates
   * @param {string[]|number[]} [options.disabledWeekdays=[]] - Array of disabled weekdays
   * @param {string[]|number[]} [options.disabledDays=[]] - Array of disabled day numbers
   * @param {string[]|number[]} [options.disabledMonths=[]] - Array of disabled months
   * @param {string[]|number[]} [options.disabledYears=[]] - Array of disabled years
   * @param {number} [options.firstDayOfWeek=0] - First day of week (0=Sunday, 1=Monday, etc.)
   * @param {string} [options.onNavigated='navigated'] - Callback name when navigated
   */
  constructor(controller, options = {}) {
    super(controller, options);

    const config = Object.assign({}, defaultOptions, options);
    const { onNavigated, since, till, firstDayOfWeek } = config;
    this.onNavigated = onNavigated;
    this.since = tryParseDate(since);
    this.till = tryParseDate(till);
    this.firstDayOfWeek = 0 <= firstDayOfWeek && firstDayOfWeek < 7 ? firstDayOfWeek : defaultOptions.firstDayOfWeek;

    const { disabledDates, disabledWeekdays, disabledDays, disabledMonths, disabledYears } = config;
    this.disabledDates = Array.isArray(disabledDates) ? disabledDates : [];
    this.disabledWeekdays = Array.isArray(disabledWeekdays) ? disabledWeekdays : [];
    this.disabledDays = Array.isArray(disabledDays) ? disabledDays : [];
    this.disabledMonths = Array.isArray(disabledMonths) ? disabledMonths : [];
    this.disabledYears = Array.isArray(disabledYears) ? disabledYears : [];

    const { today, day, month, year } = config;
    this.now = tryParseDate(today) || new Date();

    if (typeof year === 'number' && typeof month === 'number' && typeof day === 'number') {
      this.current = tryParseDate(year, month, day);
    } else {
      this.current = this.now;
    }

    this.build();
    this.enhance();
  }

  /**
   * Builds all calendar data structures (days of week, days of month, months of year).
   */
  build() {
    this.daysOfWeek = this.buildDaysOfWeek();
    this.daysOfMonth = this.buildDaysOfMonth();
    this.monthsOfYear = this.buildMonthsOfYear();
  }

  /**
   * Builds array of weekday objects with localized names.
   * @returns {Array<Object>} Array of weekday objects
   */
  buildDaysOfWeek() {
    const longFormatter = new Intl.DateTimeFormat(this.localesValue, { weekday: 'long' });
    const shortFormatter = new Intl.DateTimeFormat(this.localesValue, { weekday: 'short' });

    const sunday = new Date('2024-10-06');
    const daysOfWeek = [];
    for (let i = this.firstDayOfWeek, n = i + 7; i < n; i++) {
      const weekday = new Date(sunday);
      weekday.setDate(sunday.getDate() + i);
      daysOfWeek.push({
        date: weekday,
        value: weekday.getDay(),
        long: longFormatter.format(weekday),
        short: shortFormatter.format(weekday),
      });
    }
    return daysOfWeek;
  }

  /**
   * Builds array of day objects for the current month view, including overflow from adjacent months.
   * @returns {Array<Object>} Array of day objects with metadata
   */
  buildDaysOfMonth() {
    const currentMonth = this.month;
    const currentYear = this.year;
    const daysOfMonth = [];
    const parseDate = (date) => ({
      current: this.month === date.getMonth() && this.year === date.getFullYear(),
      date: date,
      value: date.getDate(),
      month: date.getMonth(),
      year: date.getFullYear(),
      iso: date.toISOString(),
    });

    const currentWeekday = new Date(currentYear, currentMonth).getDay();
    const weekdayBeforeCurrent = this.firstDayOfWeek - currentWeekday;
    for (let i = weekdayBeforeCurrent > 0 ? weekdayBeforeCurrent - 7 : weekdayBeforeCurrent; i < 0; i++) {
      const previous = new Date(currentYear, currentMonth, i + 1);
      daysOfMonth.push(parseDate(previous));
    }
    const currentMonthTotalDays = new Date(currentYear, currentMonth + 1, 0).getDate();
    for (let i = 1; i <= currentMonthTotalDays; i++) {
      const current = new Date(currentYear, currentMonth, i);
      daysOfMonth.push(parseDate(current));
    }
    const mod = daysOfMonth.length % DAYS_OF_WEEK;
    const trailing = mod === 0 ? 0 : DAYS_OF_WEEK - mod;
    for (let i = 1; i <= trailing; i++) {
      const next = new Date(currentYear, currentMonth + 1, i);
      daysOfMonth.push(parseDate(next));
    }
    return daysOfMonth;
  }

  /**
   * Builds array of month objects with localized names for the current year.
   * @returns {Array<Object>} Array of month objects
   */
  buildMonthsOfYear() {
    const longFormatter = new Intl.DateTimeFormat(this.localesValue, { month: 'long' });
    const shortFormatter = new Intl.DateTimeFormat(this.localesValue, { month: 'short' });
    const numericFormatter = new Intl.DateTimeFormat(this.localesValue, { month: 'numeric' });

    const monthsOfYear = [];
    for (let i = 0; i < 12; i++) {
      const month = new Date(this.year, i);
      monthsOfYear.push({
        date: month,
        value: month.getMonth(),
        long: longFormatter.format(month),
        short: shortFormatter.format(month),
        numeric: numericFormatter.format(month),
      });
    }
    return monthsOfYear;
  }

  /**
   * Gets the current "today" reference date.
   * @returns {Date} Today's date
   */
  get today() {
    return this.now;
  }

  /**
   * Sets the "today" reference date.
   * @param {Date} value - New today date
   */
  set today(value) {
    if (!isValidDate(value)) return;

    const month = this.month ? this.month : value.getMonth();
    const year = this.year ? this.year : value.getFullYear();
    const sameMonthYear = month == value.getMonth() && year == value.getFullYear();
    const day = this.hasDayValue ? this.day : sameMonthYear ? value.getDate() : 1;
    this.now = new Date(year, month, day).toISOString();
  }

  /**
   * Gets the current selected date.
   * @returns {Date|null} Current date or null if not fully specified
   */
  get current() {
    if (typeof this.year === 'number' && typeof this.month === 'number' && typeof this.day === 'number') {
      return tryParseDate(this.year, this.month, this.day);
    }
    return null;
  }

  /**
   * Sets the current selected date.
   * @param {Date} value - New current date
   */
  set current(value) {
    if (!isValidDate(value)) return;

    this.day = value.getDate();
    this.month = value.getMonth();
    this.year = value.getFullYear();
  }

  /**
   * Navigates to a specific date, dispatching events and rebuilding calendar.
   * @param {Date} to - Target date to navigate to
   * @returns {Promise<void>}
   */
  navigate = async (to) => {
    if (!isValidDate(to)) return;

    const from = this.current;
    const toIso = to.toISOString();
    const fromIso = from.toISOString();

    this.dispatch('navigate', { detail: { from: fromIso, to: toIso } });

    this.current = to;
    this.build();
    await this.awaitCallback(this.onNavigated, { from: fromIso, to: toIso });

    this.dispatch('navigated', { detail: { from: fromIso, to: toIso } });
  };

  /**
   * Steps the calendar by a given amount in a specific unit (year, month, or day).
   * @param {string} type - Type of step ('year', 'month', 'day')
   * @param {number} value - Number of units to step (positive or negative)
   * @returns {Promise<void>}
   */
  step = async (type, value) => {
    if (value === 0) return;

    const target = this.current;
    switch (type) {
      case 'year': {
        target.setFullYear(target.getFullYear() + value);
        break;
      }
      case 'month': {
        target.setMonth(target.getMonth() + value);
        break;
      }
      case 'day': {
        target.setDate(target.getDate() + value);
        break;
      }
      default:
        return;
    }
    await this.navigate(target);
  };

  /**
   * Checks if a date is disabled based on configured rules.
   * @param {Date} date - Date to check
   * @returns {boolean} True if date is disabled
   */
  isDisabled = (date) => {
    if (!isValidDate(date)) return false;

    if (this.disabledDates.length) {
      const epoch = date.getTime();
      for (const str of this.disabledDates) {
        if (epoch === new Date(str).getTime()) return true;
      }
    }

    if (this.disabledWeekdays.length) {
      const target = date.getDay();
      const weekdays = this.daysOfWeek;
      const index = weekdays.findIndex((w) => w.value === target);
      if (index >= 0) {
        const weekday = weekdays[index];
        for (const str of this.disabledWeekdays) {
          if (weekday.value == str || weekday.short === str || weekday.long === str) return true;
        }
      }
    }

    if (this.disabledDays.length) {
      const target = date.getDate();
      for (const str of this.disabledDays) {
        if (target == str) return true;
      }
    }

    if (this.disabledMonths.length) {
      const target = date.getMonth();
      const months = this.monthsOfYear;
      const index = months.findIndex((m) => m.value === target);
      if (index >= 0) {
        const month = months[index];
        for (const str of this.disabledMonths) {
          if (month.value == str || month.short === str || month.long === str) return true;
        }
      }
    }

    if (this.disabledYears.length) {
      const target = date.getFullYear();
      for (const str of this.disabledYears) {
        if (target == str) return true;
      }
    }

    return false;
  };

  /**
   * Checks if a date is within the allowed range (since/till).
   * @param {Date} date - Date to check
   * @returns {boolean} True if date is within range
   */
  isWithinRange = (date) => {
    if (!isValidDate(date)) return false;

    let within = true;
    if (this.since) within = within && date >= this.since;
    if (this.till) within = within && date <= this.till;
    return within;
  };

  enhance() {
    const context = this;
    Object.assign(this.controller, {
      get calendar() {
        return {
          get today() {
            return context.today;
          },
          get current() {
            return context.current;
          },
          get day() {
            return context.day;
          },
          get month() {
            return context.month;
          },
          get year() {
            return context.year;
          },
          get since() {
            return context.since;
          },
          get till() {
            return context.till;
          },
          get firstDayOfWeek() {
            return context.firstDayOfWeek;
          },
          get disabledDates() {
            return context.disabledDates;
          },
          get disabledWeekdays() {
            return context.disabledWeekdays;
          },
          get disabledDays() {
            return context.disabledDays;
          },
          get disabledMonths() {
            return context.disabledMonths;
          },
          get disabledYears() {
            return context.disabledYears;
          },
          get daysOfWeek() {
            return context.daysOfWeek;
          },
          get daysOfMonth() {
            return context.daysOfMonth;
          },
          get monthsOfYear() {
            return context.monthsOfYear;
          },
          navigate: async (to) => await context.navigate(to),
          step: async (type, value) => await context.step(type, value),
          isDisabled: (date) => context.isDisabled(date),
          isWithinRange: (date) => context.isWithinRange(date),
        };
      },
    });
  }
}

/**
 * Factory function to create and attach a Calendar plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {Calendar} Calendar plumber instance
 */
export const initCalendar = (controller, options) => new Calendar(controller, options);
