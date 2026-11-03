import { describe, expect, it } from 'vitest';
import {
  availabilityErrors,
  dateAvailability,
  dateTimeKey,
  dayAvailability,
  isDisabled,
  parseDateTimeKey,
} from '../../../src/datetime';
import { parseDateKey } from '../../../src/date';
import availability from '../../fixtures/datetime/availability.json';

describe('date-time core', () => {
  it.each(availability.parse)('parses only date-time keys: "$value"', ({ value, expect: key }) => {
    const dateTime = parseDateTimeKey(value);
    expect(dateTime && dateTimeKey(dateTime)).toBe(key);
  });

  it('disables date-times outside min–max, on unavailable dates, and outside the daily window', () => {
    availability.cases.forEach(({ dateTime, availability: rules, expect: disabled }) =>
      expect(isDisabled(parseDateTimeKey(dateTime), rules)).toBe(disabled)
    );
  });

  it('cuts the daily window off at min and max on their dates', () => {
    availability.days.forEach(({ date, availability: rules, expect: day }) =>
      expect(dayAvailability(parseDateKey(date), rules)).toEqual(day)
    );
  });

  it.each(availability.dates)('gives the calendar its dates: $name', ({ availability: rules, expect: dates }) => {
    expect(dateAvailability(rules)).toEqual(dates);
  });

  it.each(availability.invalid)('reports unusable availability: $name', ({ availability: rules, option }) => {
    const [error = null] = availabilityErrors(rules);
    expect(error && error.split(' ')[0]).toBe(option);
  });
});
