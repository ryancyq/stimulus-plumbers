import { describe, it, expect } from 'vitest';
import { fuzzyMatcher } from '../../src/researcher';

describe('fuzzyMatcher', () => {
  it('empty needle matches any haystack', () => {
    expect(fuzzyMatcher('', 'anything')).toBe(true);
  });

  it('returns true when needle chars appear in order in haystack', () => {
    expect(fuzzyMatcher('app', 'apple')).toBe(true);
    expect(fuzzyMatcher('apl', 'apple')).toBe(true);
  });

  it('returns false when needle chars are out of order', () => {
    expect(fuzzyMatcher('ppa', 'apple')).toBe(false);
  });

  it('returns false when needle is longer than haystack', () => {
    expect(fuzzyMatcher('toolong', 'too')).toBe(false);
  });

  it('returns true for an exact match', () => {
    expect(fuzzyMatcher('apple', 'apple')).toBe(true);
  });

  it('returns false when haystack is empty and needle is not', () => {
    expect(fuzzyMatcher('a', '')).toBe(false);
  });
});
