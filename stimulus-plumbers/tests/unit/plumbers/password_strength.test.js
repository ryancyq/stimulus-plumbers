import { describe, it, expect } from 'vitest';
import { PasswordStrength, attachPasswordStrength } from '../../../src/plumbers/password_strength';

const score = (pw, rules, opts) => {
  const controller = {};
  attachPasswordStrength(controller, {});
  return controller.strength.score(pw, rules, opts ?? {});
};

const length = (min, max) => ({ key: 'length', min, max });
const digit = (min, max) => ({ key: 'digit', pattern: '\\d', min, max });
const upper = (min) => ({ key: 'uppercase', pattern: '[A-Z]', min });

describe('RulesScorer', () => {
  it('evaluates length against min and max', () => {
    expect(score('abc', [length(5, 12)]).rules.length).toBe(false);
    expect(score('abcde', [length(5, 12)]).rules.length).toBe(true);
    expect(score('a'.repeat(13), [length(5, 12)]).rules.length).toBe(false);
  });

  it('counts occurrences for min', () => {
    expect(score('a1', [digit(2)]).rules.digit).toBe(false);
    expect(score('a12', [digit(2)]).rules.digit).toBe(true);
  });

  it('counts occurrences for max', () => {
    expect(score('123', [digit(0, 2)]).rules.digit).toBe(false);
    expect(score('12', [digit(0, 2)]).rules.digit).toBe(true);
  });

  it('treats max 0 as a forbid rule', () => {
    const noDigits = { key: 'no_digits', pattern: '\\d', min: 0, max: 0 };
    expect(score('ab1', [noDigits]).rules.no_digits).toBe(false);
    expect(score('abc', [noDigits]).rules.no_digits).toBe(true);
  });

  it('scores 0 when nothing satisfied and 100 when all satisfied', () => {
    const rules = [length(4, 12), upper(1), digit(1)];
    expect(score('', rules).value).toBe(0);
    expect(score('Abcd1', rules).value).toBe(100);
  });

  it('is strong only when every rule passes', () => {
    const rules = [upper(1), digit(1)];
    expect(score('aB', rules).level).toBe('fine');
    expect(score('aB1', rules).level).toBe('strong');
  });

  it('splits weak from fine at low', () => {
    const rules = [upper(1), digit(1), length(1, 99)];
    expect(score('a', rules, { low: 70 }).level).toBe('weak');
    expect(score('aB', rules, {}).level).toBe('fine');
  });
});

describe('registry', () => {
  it('prefers a registered scorer', () => {
    PasswordStrength.register('entropy', { score: () => ({ value: 42, level: 'fine', rules: {} }) });
    const controller = {};
    attachPasswordStrength(controller, { type: 'entropy' });
    expect(controller.strength.score('x', [], {}).value).toBe(42);
  });

  it('falls back to rules for an unknown type', () => {
    const controller = {};
    attachPasswordStrength(controller, { type: 'nope' });
    expect(controller.strength.score('abcd', [{ key: 'length', min: 4, max: 12 }], {}).value).toBe(100);
  });
});

import fixtures from '../../fixtures/password_rules.json';

describe('parity fixture', () => {
  fixtures.forEach((fixture) => {
    it(fixture.name, () => {
      const result = score(fixture.password, fixture.rules, {});
      expect(result.rules).toEqual(fixture.expected.rules);
      const valid = fixture.rules.length > 0 && Object.values(result.rules).every(Boolean);
      expect(valid).toBe(fixture.expected.valid);
    });
  });
});
