import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  addDays,
  addMonths,
  addYears,
  compareDate,
  availabilityErrors,
  daysBetween,
  dateKey,
  daysInMonth,
  focusDate,
  isDisabled,
  isMonthDisabled,
  isYearDisabled,
  monthGrid,
  parseDateKey,
  weekday,
} from '../../../src/date';
import arithmetic from '../../fixtures/date/arithmetic.json';
import grid from '../../fixtures/date/grid.json';
import availability from '../../fixtures/date/availability.json';
import focus from '../../fixtures/date/focus.json';

const ZONES = ['UTC', 'Asia/Singapore', 'America/Los_Angeles', 'Australia/Lord_Howe'];
const parse = (value) => parseDateKey(value);
const key = (date) => (date ? dateKey(date) : null);

describe.each(ZONES)('date core in %s', (zone) => {
  let original;
  beforeAll(() => {
    original = process.env.TZ;
    process.env.TZ = zone;
  });
  afterAll(() => {
    process.env.TZ = original;
  });

  it('counts days in a month by Gregorian rules', () => {
    arithmetic.daysInMonth.forEach(({ year, month, expect: days }) => expect(daysInMonth(year, month)).toBe(days));
  });

  it('parses only valid date keys', () => {
    arithmetic.parse.forEach(({ value, expect: result }) => expect(key(parse(value))).toBe(result));
  });

  it('adds days across months and years', () => {
    arithmetic.addDays.forEach(({ from, amount, expect: result }) =>
      expect(key(addDays(parse(from), amount))).toBe(result)
    );
  });

  it('adds months, clamping or rejecting an overflowing day', () => {
    arithmetic.addMonths.forEach(({ from, amount, overflow, expect: result }) =>
      expect(key(addMonths(parse(from), amount, overflow))).toBe(result)
    );
  });

  it('adds years, clamping or rejecting a leap day', () => {
    arithmetic.addYears.forEach(({ from, amount, overflow, expect: result }) =>
      expect(key(addYears(parse(from), amount, overflow))).toBe(result)
    );
  });

  it('finds the weekday independent of the timezone', () => {
    arithmetic.weekday.forEach(({ date, expect: day }) => expect(weekday(parse(date))).toBe(day));
  });

  it('lays out whole weeks from the first day of the week', () => {
    grid.cases.forEach(({ month, firstDayOfWeek, weeks }) =>
      expect(monthGrid(parse(`${month}-01`), firstDayOfWeek)).toEqual(weeks)
    );
  });

  it('disables dates outside min–max and listed dates', () => {
    availability.cases.forEach(({ date, availability: rules, expect: disabled }) =>
      expect(isDisabled(parse(date), rules)).toBe(disabled)
    );
  });

  it('disables months and years', () => {
    availability.periods.forEach(({ year, month, availability: rules, expect: disabled }) =>
      expect(month ? isMonthDisabled(year, month, rules) : isYearDisabled(year, rules)).toBe(disabled)
    );
  });

  it.each(availability.invalid)('reports unusable availability: $name', ({ availability: rules, option }) => {
    const [error = null] = availabilityErrors(rules);
    expect(error && error.split(' ')[0]).toBe(option);
  });

  it.each(focus.cases)('focuses per D4: $name', (testCase) => {
    const dates = monthGrid(parse(`${testCase.month}-01`), testCase.firstDayOfWeek ?? 0)
      .flat()
      .filter((date) => testCase.showOtherMonths || date.startsWith(testCase.month));
    const { selected, today, displayed, availability: rules } = testCase;
    expect(focusDate({ dates, selected, today, displayed, availability: rules })).toBe(testCase.expect);
  });
});

describe('daysBetween', () => {
  it('counts calendar days across months and leap years', () => {
    expect(daysBetween(parse('2024-02-28'), parse('2024-03-01'))).toBe(2);
    expect(daysBetween(parse('2026-09-15'), parse('2026-09-01'))).toBe(-14);
  });
});

describe('compareDate', () => {
  it('orders dates by year, month, then day', () => {
    expect(compareDate(parse('2026-09-15'), parse('2026-09-16'))).toBeLessThan(0);
    expect(compareDate(parse('2026-10-01'), parse('2026-09-30'))).toBeGreaterThan(0);
    expect(compareDate(parse('2026-09-15'), parse('2026-09-15'))).toBe(0);
  });
});
