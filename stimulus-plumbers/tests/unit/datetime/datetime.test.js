import { describe, expect, it } from 'vitest';
import {
  availabilityErrors,
  dateAvailability,
  dateTimeKey,
  dayAvailability,
  parseDateTimeKey,
} from '../../../src/datetime';
import { isDisabled as isDateDisabled, parseDateKey } from '../../../src/date';
import { isDisabled as isTimeDisabled } from '../../../src/time';
import availability from '../../fixtures/datetime/availability.json';

describe('date-time core', () => {
  it.each(availability.parse)('parses only date-time keys: "$value"', ({ value, expect: key }) => {
    const dateTime = parseDateTimeKey(value);
    expect(dateTime && dateTimeKey(dateTime)).toBe(key);
  });

  it('offers a date-time only on an offered date and within its times', () => {
    availability.cases.forEach(({ dateTime, availability: rules, expect: disabled }) => {
      const { date, time } = parseDateTimeKey(dateTime);
      const offered =
        !isDateDisabled(date, dateAvailability(rules)) && !isTimeDisabled(time, dayAvailability(date, rules));
      expect(!offered, dateTime).toBe(disabled);
    });
  });

  it('trims the daily window at min and max on their dates', () => {
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
