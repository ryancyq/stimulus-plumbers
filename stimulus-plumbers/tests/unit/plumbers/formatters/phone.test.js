import { describe, it, expect } from 'vitest'
import { PhoneFormatter } from '../../../../src/plumbers/formatters/phone'

describe('PhoneFormatter', () => {
  describe('normalize', () => {
    it('strips formatting from US number with parentheses', () => {
      expect(PhoneFormatter.normalize('(555) 123-4567')).toBe('5551234567')
    })

    it('preserves + for international numbers', () => {
      expect(PhoneFormatter.normalize('+1 555 123 4567')).toBe('+15551234567')
    })

    it('strips dashes and spaces', () => {
      expect(PhoneFormatter.normalize('555-123-4567')).toBe('5551234567')
    })

    it('returns empty string for null', () => {
      expect(PhoneFormatter.normalize(null)).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for US 10-digit number', () => {
      expect(PhoneFormatter.validate('5551234567')).toBe(true)
    })

    it('returns true for E.164 international number', () => {
      expect(PhoneFormatter.validate('+15551234567')).toBe(true)
    })

    it('returns true for international number with different country code', () => {
      expect(PhoneFormatter.validate('+441234567890')).toBe(true)
    })

    it('returns false for number with too few digits', () => {
      expect(PhoneFormatter.validate('123456')).toBe(false)
    })

    it('returns false for number with too many digits', () => {
      expect(PhoneFormatter.validate('+12345678901234567')).toBe(false)
    })

    it('returns false for null', () => {
      expect(PhoneFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('formats US 10-digit number', () => {
      expect(PhoneFormatter.format('5551234567')).toBe('(555) 123-4567')
    })

    it('formats US number with country code +1', () => {
      expect(PhoneFormatter.format('+15551234567')).toBe('+1 (555) 123-4567')
    })

    it('returns value as-is for other international numbers', () => {
      expect(PhoneFormatter.format('+441234567890')).toBe('+441234567890')
    })

    it('returns empty string for null', () => {
      expect(PhoneFormatter.format(null)).toBe('')
    })
  })

  it('does not have a mask method', () => {
    expect(PhoneFormatter.mask).toBeUndefined()
  })
})
