import { describe, it, expect } from 'vitest';
import { CreditCardFormatter } from '../../../../src/plumbers/formatters/credit_card';

describe('CreditCardFormatter', () => {
  describe('normalize', () => {
    it('strips spaces from formatted number', () => {
      expect(CreditCardFormatter.normalize('4242 4242 4242 4242')).toBe('4242424242424242');
    });

    it('strips dashes from formatted number', () => {
      expect(CreditCardFormatter.normalize('4242-4242-4242-4242')).toBe('4242424242424242');
    });

    it('returns raw digits unchanged', () => {
      expect(CreditCardFormatter.normalize('4242424242424242')).toBe('4242424242424242');
    });

    it('caps at 19 digits', () => {
      expect(CreditCardFormatter.normalize('4242 4242 4242 4242 4242')).toBe('4242424242424242424');
    });

    it('caps an Amex number at 15 digits', () => {
      expect(CreditCardFormatter.normalize('3782 822463 10005 99')).toBe('378282246310005');
    });

    it('caps at the given groups sum', () => {
      expect(CreditCardFormatter.normalize('4242 - 4242 - 4242 - 4242 99', { groups: [4, 4, 4, 4] })).toBe(
        '4242424242424242'
      );
    });

    it('returns empty string for null', () => {
      expect(CreditCardFormatter.normalize(null)).toBe('');
    });

    it('returns empty string for undefined', () => {
      expect(CreditCardFormatter.normalize(undefined)).toBe('');
    });
  });

  describe('validate', () => {
    it('returns true for valid Visa 16-digit number', () => {
      expect(CreditCardFormatter.validate('4242424242424242')).toBe(true);
    });

    it('returns true for valid Mastercard number', () => {
      expect(CreditCardFormatter.validate('5555555555554444')).toBe(true);
    });

    it('returns false for invalid Luhn check', () => {
      expect(CreditCardFormatter.validate('4242424242424241')).toBe(false);
    });

    it('returns false for number shorter than 13 digits', () => {
      expect(CreditCardFormatter.validate('424242424242')).toBe(false);
    });

    it('returns false for number longer than 19 digits', () => {
      expect(CreditCardFormatter.validate('42424242424242424242')).toBe(false);
    });

    it('returns false for number with non-digit characters', () => {
      expect(CreditCardFormatter.validate('4242 4242 4242 4242')).toBe(false);
    });

    it('returns false for null', () => {
      expect(CreditCardFormatter.validate(null)).toBe(false);
    });
  });

  describe('format', () => {
    it('formats 16-digit number with spaces in groups of 4', () => {
      expect(CreditCardFormatter.format('4242424242424242')).toBe('4242 4242 4242 4242');
    });

    it('formats an Amex number as 4-6-5', () => {
      expect(CreditCardFormatter.format('378282246310005')).toBe('3782 822463 10005');
    });

    it('joins the groups with the given separator', () => {
      expect(CreditCardFormatter.format('4242424242424242', { separator: '-' })).toBe('4242-4242-4242-4242');
    });

    it('formats at the given group breaks', () => {
      expect(CreditCardFormatter.format('378282246310005', { groups: [4, 6, 5] })).toBe('3782 822463 10005');
    });

    it('formats a partial value at the given group breaks', () => {
      expect(CreditCardFormatter.format('3782822', { groups: [4, 6, 5] })).toBe('3782 822');
    });

    it('keeps digits past the groups sum as a trailing group', () => {
      expect(CreditCardFormatter.format('123456789', { groups: [4, 4] })).toBe('1234 5678 9');
    });

    it('returns empty string for null', () => {
      expect(CreditCardFormatter.format(null)).toBe('');
    });
  });

  describe('filledLength', () => {
    it('is 16 by default', () => {
      expect(CreditCardFormatter.filledLength('4242')).toBe(16);
    });

    it('is 15 for an Amex number', () => {
      expect(CreditCardFormatter.filledLength('3782')).toBe(15);
    });

    it('is the given groups sum', () => {
      expect(CreditCardFormatter.filledLength('4242', { groups: [4, 4, 4, 4, 3] })).toBe(19);
    });
  });

  describe('cells', () => {
    it('hints four groups of four with no fixed length (13-19 digit range)', () => {
      expect(CreditCardFormatter.cells()).toEqual({ groups: [4, 4, 4, 4], length: 0 });
    });
  });

  it('does not have a mask method', () => {
    expect(CreditCardFormatter.mask).toBeUndefined();
  });
});
