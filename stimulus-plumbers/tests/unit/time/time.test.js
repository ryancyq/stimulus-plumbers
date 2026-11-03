import { describe, expect, it } from 'vitest';
import { availabilityErrors, isDisabled, isHourDisabled, parseTimeKey, timeKey, windowRanges } from '../../../src/time';
import availability from '../../fixtures/time/availability.json';

describe('time core', () => {
  it.each(availability.parse)('parses only time keys: "$value"', ({ value, expect: key }) => {
    const time = parseTimeKey(value);
    expect(time && timeKey(time)).toBe(key);
  });

  it('disables times outside min–max and off the step', () => {
    availability.cases.forEach(({ time, availability: rules, expect: disabled }) =>
      expect(isDisabled(parseTimeKey(time), rules)).toBe(disabled)
    );
  });

  it('disables hours with no available minute', () => {
    availability.hours.forEach(({ hour, availability: rules, expect: disabled }) =>
      expect(isHourDisabled(hour, rules)).toBe(disabled)
    );
  });

  it('splits a window that wraps past midnight into two ranges', () => {
    expect(windowRanges({ min: '22:00', max: '02:00' })).toEqual([
      ['00:00', '02:00'],
      ['22:00', '23:59'],
    ]);
    expect(windowRanges({})).toEqual([['00:00', '23:59']]);
  });

  it.each(availability.invalid)('reports unusable availability: $name', ({ availability: rules, option }) => {
    const [error = null] = availabilityErrors(rules);
    expect(error && error.split(' ')[0]).toBe(option);
  });
});
