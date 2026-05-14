import { describe, it, expect } from 'vitest'
import { CurrencyFormatter } from '../../../../src/plumbers/formatters/currency'

describe('CurrencyFormatter', () => {
  describe('normalize', () => {
    it('strips currency symbol and thousands separator', () => {
      expect(CurrencyFormatter.normalize('$1,234.56')).toBe('1234.56')
    })

    it('handles European format with comma as decimal separator', () => {
      expect(CurrencyFormatter.normalize('1.234,56')).toBe('1234.56')
    })

    it('returns plain number unchanged', () => {
      expect(CurrencyFormatter.normalize('1234.56')).toBe('1234.56')
    })

    it('handles integer amounts', () => {
      expect(CurrencyFormatter.normalize('$1,000')).toBe('1000')
    })

    it('returns empty string for null', () => {
      expect(CurrencyFormatter.normalize(null)).toBe('')
    })

    it('returns empty string for non-numeric string', () => {
      expect(CurrencyFormatter.normalize('abc')).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for integer', () => {
      expect(CurrencyFormatter.validate('1234')).toBe(true)
    })

    it('returns true for decimal with 2 places', () => {
      expect(CurrencyFormatter.validate('1234.56')).toBe(true)
    })

    it('returns true for decimal with 1 place', () => {
      expect(CurrencyFormatter.validate('1234.5')).toBe(true)
    })

    it('returns true for negative amount', () => {
      expect(CurrencyFormatter.validate('-1234.56')).toBe(true)
    })

    it('returns true for more than 2 decimal places (e.g. KWD with 3)', () => {
      expect(CurrencyFormatter.validate('1234.567')).toBe(true)
    })

    it('returns false for non-numeric string', () => {
      expect(CurrencyFormatter.validate('abc')).toBe(false)
    })

    it('returns false for null', () => {
      expect(CurrencyFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('formats as USD by default', () => {
      expect(CurrencyFormatter.format('1234.56')).toBe('$1,234.56')
    })

    it('formats with specified locale and currency', () => {
      const result = CurrencyFormatter.format('1234.56', { locale: 'de-DE', currency: 'EUR' })
      expect(result).toContain('1.234,56')
    })

    it('formats JPY without decimal places using Intl currency defaults', () => {
      const result = CurrencyFormatter.format('1234', { locale: 'ja-JP', currency: 'JPY' })
      expect(result).not.toContain('.')
      expect(result).toContain('1,234')
    })

    it('overrides fraction digits when fractionDigits opt is provided', () => {
      const result = CurrencyFormatter.format('1234.5', {
        locale: 'en-US',
        currency: 'USD',
        fractionDigits: 0,
      })
      expect(result).toBe('$1,235')
    })

    it('returns value as-is for non-numeric input', () => {
      expect(CurrencyFormatter.format('abc')).toBe('abc')
    })

    it('returns empty string for null', () => {
      expect(CurrencyFormatter.format(null)).toBe('')
    })
  })

  it('does not have a mask method', () => {
    expect(CurrencyFormatter.mask).toBeUndefined()
  })
})
