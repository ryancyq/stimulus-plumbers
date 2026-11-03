import { describe, expect, it } from 'vitest';
import { availabilityErrors, isDisabled, isHourDisabled, parseTimeKey, timeKey } from '../../../src/time';
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

  it('cuts off the times before from and after to', () => {
    availability.cutoffs.forEach(({ time, availability: rules, expect: disabled }) =>
      expect(isDisabled(parseTimeKey(time), rules)).toBe(disabled)
    );
  });

  it.each(availability.invalid)('reports unusable availability: $name', ({ availability: rules, option }) => {
    const [error = null] = availabilityErrors(rules);
    expect(error && error.split(' ')[0]).toBe(option);
  });
});
