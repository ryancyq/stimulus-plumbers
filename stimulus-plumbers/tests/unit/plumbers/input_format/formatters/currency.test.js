import { describe, it, expect } from 'vitest'
import { CurrencyInputFormatter } from '../../../../../src/plumbers/input_format/formatters/currency'

describe('CurrencyInputFormatter', () => {
  describe('normalize', () => {
    it('strips currency symbol and thousands separator', () => {
      expect(CurrencyInputFormatter.normalize('$1,234.56')).toBe('1234.56')
    })

    it('handles European format with comma as decimal separator', () => {
      expect(CurrencyInputFormatter.normalize('1.234,56')).toBe('1234.56')
    })

    it('returns plain number unchanged', () => {
      expect(CurrencyInputFormatter.normalize('1234.56')).toBe('1234.56')
    })

    it('handles integer amounts', () => {
      expect(CurrencyInputFormatter.normalize('$1,000')).toBe('1000')
    })

    it('returns empty string for null', () => {
      expect(CurrencyInputFormatter.normalize(null)).toBe('')
    })

    it('returns empty string for non-numeric string', () => {
      expect(CurrencyInputFormatter.normalize('abc')).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for integer', () => {
      expect(CurrencyInputFormatter.validate('1234')).toBe(true)
    })

    it('returns true for decimal with 2 places', () => {
      expect(CurrencyInputFormatter.validate('1234.56')).toBe(true)
    })

    it('returns true for decimal with 1 place', () => {
      expect(CurrencyInputFormatter.validate('1234.5')).toBe(true)
    })

    it('returns true for negative amount', () => {
      expect(CurrencyInputFormatter.validate('-1234.56')).toBe(true)
    })

    it('returns true for more than 2 decimal places (e.g. KWD with 3)', () => {
      expect(CurrencyInputFormatter.validate('1234.567')).toBe(true)
    })

    it('returns false for non-numeric string', () => {
      expect(CurrencyInputFormatter.validate('abc')).toBe(false)
    })

    it('returns false for null', () => {
      expect(CurrencyInputFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('formats as USD by default', () => {
      expect(CurrencyInputFormatter.format('1234.56')).toBe('$1,234.56')
    })

    it('formats with specified locale and currency', () => {
      const result = CurrencyInputFormatter.format('1234.56', { locale: 'de-DE', currency: 'EUR' })
      expect(result).toContain('1.234,56')
    })

    it('formats JPY without decimal places using Intl currency defaults', () => {
      const result = CurrencyInputFormatter.format('1234', { locale: 'ja-JP', currency: 'JPY' })
      expect(result).not.toContain('.')
      expect(result).toContain('1,234')
    })

    it('overrides fraction digits when fractionDigits opt is provided', () => {
      const result = CurrencyInputFormatter.format('1234.5', {
        locale: 'en-US',
        currency: 'USD',
        fractionDigits: 0,
      })
      expect(result).toBe('$1,235')
    })

    it('returns value as-is for non-numeric input', () => {
      expect(CurrencyInputFormatter.format('abc')).toBe('abc')
    })

    it('returns empty string for null', () => {
      expect(CurrencyInputFormatter.format(null)).toBe('')
    })
  })

  it('does not have a mask method', () => {
    expect(CurrencyInputFormatter.mask).toBeUndefined()
  })
})
