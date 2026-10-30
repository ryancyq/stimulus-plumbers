import { afterEach, describe, expect, it, vi } from 'vitest';
import { neighbour, unitKey, weekStart } from '../../../../src/plumbers/plumber/calendar_period';

describe('calendar period', () => {
  afterEach(() => vi.restoreAllMocks());

  it('starts the week on the locale first day', () => {
    expect(weekStart('en-US')).toBe(0);
    expect(weekStart('en-GB')).toBe(1);
  });

  it('starts the week on Monday when the locale has no week info', () => {
    vi.spyOn(Intl, 'Locale').mockImplementation(() => ({}));

    expect(weekStart('en-US')).toBe(1);
  });

  it('steps by month, year, and decade within 0001–9999', () => {
    expect(neighbour('2026-09-15', 'month', 1)).toBe('2026-10-01');
    expect(neighbour('2026-09-15', 'year', -1)).toBe('2025-01-01');
    expect(neighbour('2026-09-15', 'decade', 1)).toBe('2036-01-01');
    expect(neighbour('0001-01-15', 'month', -1)).toBeNull();
  });

  it('maps a date to the cell of each view', () => {
    expect(unitKey('2026-09-15', 'month')).toBe('2026-09-15');
    expect(unitKey('2026-09-15', 'year')).toBe('2026-09-01');
    expect(unitKey('2026-09-15', 'decade')).toBe('2026-01-01');
  });
});
