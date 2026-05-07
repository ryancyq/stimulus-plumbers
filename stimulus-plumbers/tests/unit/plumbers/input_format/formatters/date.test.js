import { describe, it, expect } from 'vitest'
import { DateInputFormatter } from '../../../../../src/plumbers/input_format/formatters/date'

describe('DateInputFormatter', () => {
  describe('normalize', () => {
    it('returns ISO date string unchanged', () => {
      expect(DateInputFormatter.normalize('2025-04-13')).toBe('2025-04-13')
    })

    it('normalizes MM/DD/YYYY format', () => {
      expect(DateInputFormatter.normalize('04/13/2025')).toBe('2025-04-13')
    })

    it('normalizes YYYY/MM/DD format', () => {
      expect(DateInputFormatter.normalize('2025/04/13')).toBe('2025-04-13')
    })

    it('normalizes YYYY-MM-DD with dashes', () => {
      expect(DateInputFormatter.normalize('2025-04-13')).toBe('2025-04-13')
    })

    it('normalizes YYYYMMDD format', () => {
      expect(DateInputFormatter.normalize('20250413')).toBe('2025-04-13')
    })

    it('handles MM.DD.YYYY format', () => {
      expect(DateInputFormatter.normalize('04.13.2025')).toBe('2025-04-13')
    })

    it('returns empty string for null', () => {
      expect(DateInputFormatter.normalize(null)).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for a valid ISO date', () => {
      expect(DateInputFormatter.validate('2025-04-13')).toBe(true)
    })

    it('returns true for a leap year date', () => {
      expect(DateInputFormatter.validate('2024-02-29')).toBe(true)
    })

    it('returns false for an invalid leap year date', () => {
      expect(DateInputFormatter.validate('2025-02-29')).toBe(false)
    })

    it('returns false for invalid month', () => {
      expect(DateInputFormatter.validate('2025-13-01')).toBe(false)
    })

    it('returns false for invalid day', () => {
      expect(DateInputFormatter.validate('2025-04-31')).toBe(false)
    })

    it('returns true for MM/DD/YYYY format (normalized internally)', () => {
      expect(DateInputFormatter.validate('04/13/2025')).toBe(true)
    })

    it('returns true for MM-DD-YYYY format', () => {
      expect(DateInputFormatter.validate('04-13-2025')).toBe(true)
    })

    it('returns true for YYYYMMDD compact format', () => {
      expect(DateInputFormatter.validate('20250413')).toBe(true)
    })

    it('returns false for completely invalid input', () => {
      expect(DateInputFormatter.validate('not-a-date')).toBe(false)
    })

    it('returns false for null', () => {
      expect(DateInputFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('formats date for en-US locale (MM/DD/YYYY)', () => {
      expect(DateInputFormatter.format('2025-04-13')).toBe('04/13/2025')
    })

    it('formats date for en-GB locale (DD/MM/YYYY)', () => {
      expect(DateInputFormatter.format('2025-04-13', { locale: 'en-GB' })).toBe('13/04/2025')
    })

    it('formats with long month name when month opt is "long"', () => {
      const result = DateInputFormatter.format('2025-04-13', { month: 'long' })
      expect(result).toContain('April')
    })

    it('formats with custom timeZone opt', () => {
      // With UTC, 2025-04-13 stays the same regardless of local TZ
      const result = DateInputFormatter.format('2025-04-13', { timeZone: 'UTC' })
      expect(result).toBe('04/13/2025')
    })

    it('returns value as-is for invalid date', () => {
      expect(DateInputFormatter.format('not-a-date')).toBe('not-a-date')
    })

    it('returns empty string for null', () => {
      expect(DateInputFormatter.format(null)).toBe('')
    })
  })

  it('does not have a mask method', () => {
    expect(DateInputFormatter.mask).toBeUndefined()
  })
})
