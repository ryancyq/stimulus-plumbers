import { describe, it, expect } from 'vitest'
import { CreditCardInputFormatter } from '../../../../../src/plumbers/input_format/formatters/credit_card'

describe('CreditCardInputFormatter', () => {
  describe('normalize', () => {
    it('strips spaces from formatted number', () => {
      expect(CreditCardInputFormatter.normalize('4242 4242 4242 4242')).toBe('4242424242424242')
    })

    it('strips dashes from formatted number', () => {
      expect(CreditCardInputFormatter.normalize('4242-4242-4242-4242')).toBe('4242424242424242')
    })

    it('returns raw digits unchanged', () => {
      expect(CreditCardInputFormatter.normalize('4242424242424242')).toBe('4242424242424242')
    })

    it('returns empty string for null', () => {
      expect(CreditCardInputFormatter.normalize(null)).toBe('')
    })

    it('returns empty string for undefined', () => {
      expect(CreditCardInputFormatter.normalize(undefined)).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for valid Visa 16-digit number', () => {
      expect(CreditCardInputFormatter.validate('4242424242424242')).toBe(true)
    })

    it('returns true for valid Mastercard number', () => {
      expect(CreditCardInputFormatter.validate('5555555555554444')).toBe(true)
    })

    it('returns false for invalid Luhn check', () => {
      expect(CreditCardInputFormatter.validate('4242424242424241')).toBe(false)
    })

    it('returns false for number shorter than 13 digits', () => {
      expect(CreditCardInputFormatter.validate('424242424242')).toBe(false)
    })

    it('returns false for number longer than 19 digits', () => {
      expect(CreditCardInputFormatter.validate('42424242424242424242')).toBe(false)
    })

    it('returns false for number with non-digit characters', () => {
      expect(CreditCardInputFormatter.validate('4242 4242 4242 4242')).toBe(false)
    })

    it('returns false for null', () => {
      expect(CreditCardInputFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('formats 16-digit number with spaces in groups of 4', () => {
      expect(CreditCardInputFormatter.format('4242424242424242')).toBe('4242 4242 4242 4242')
    })

    it('formats 15-digit number with spaces', () => {
      expect(CreditCardInputFormatter.format('378282246310005')).toBe('3782 8224 6310 005')
    })

    it('returns empty string for null', () => {
      expect(CreditCardInputFormatter.format(null)).toBe('')
    })
  })

  it('does not have a mask method', () => {
    expect(CreditCardInputFormatter.mask).toBeUndefined()
  })
})
