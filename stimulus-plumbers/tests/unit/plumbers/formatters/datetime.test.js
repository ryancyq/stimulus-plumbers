import { describe, expect, it } from 'vitest';
import { DatetimeFormatter } from '../../../../src/plumbers/formatters/datetime';

describe('DatetimeFormatter', () => {
  it('normalizes to the trimmed text and "" for non-string input', () => {
    expect(DatetimeFormatter.normalize(' 2026-11-03T22:00 ')).toBe('2026-11-03T22:00');
    expect(DatetimeFormatter.normalize(null)).toBe('');
  });

  it('validates only date-time keys', () => {
    expect(DatetimeFormatter.validate('2026-11-03T22:00')).toBe(true);
    expect(DatetimeFormatter.validate('2026-11-03 22:00')).toBe(false);
    expect(DatetimeFormatter.validate('2026-02-30T22:00')).toBe(false);
  });

  it('formats the date and time on the wall clock', () => {
    expect(DatetimeFormatter.format('2026-11-03T22:00')).toMatch(/^11\/03\/2026,\s10:00\sPM$/);
  });

  it('takes Intl options and a locale', () => {
    expect(DatetimeFormatter.format('2026-11-03T22:00', { locale: 'en-GB', hourCycle: 'h23' })).toBe(
      '03/11/2026, 22:00'
    );
    expect(DatetimeFormatter.format('2026-11-03T22:00', { dateStyle: 'medium', timeStyle: 'short' })).toMatch(
      /^Nov 3, 2026,\s10:00\sPM$/
    );
  });

  it('returns other values as given', () => {
    expect(DatetimeFormatter.format('soon')).toBe('soon');
    expect(DatetimeFormatter.format(null)).toBe('');
  });
});
