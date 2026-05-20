import { describe, it, expect } from 'vitest'
import { isValidDate, tryParseDate } from '../../../../src/plumbers/plumber/date'

describe('date utilities', () => {
  describe('isValidDate', () => {
    it('returns true for valid Date objects', () => {
      expect(isValidDate(new Date())).toBe(true)
      expect(isValidDate(new Date('2024-01-01'))).toBe(true)
      expect(isValidDate(new Date(2024, 0, 1))).toBe(true)
    })

    it('returns false for invalid Date objects', () => {
      expect(isValidDate(new Date('invalid'))).toBe(false)
      expect(isValidDate(new Date(NaN))).toBe(false)
    })

    it('returns false for non-Date values', () => {
      expect(isValidDate(null)).toBe(false)
      expect(isValidDate(undefined)).toBe(false)
      expect(isValidDate('2024-01-01')).toBe(false)
      expect(isValidDate(1234567890)).toBe(false)
      expect(isValidDate({})).toBe(false)
    })
  })

  describe('tryParseDate', () => {
    it('throws when no values provided', () => {
      expect(() => tryParseDate()).toThrow('Missing values to parse as date')
    })

    it('parses a YYYY-MM-DD string as local time', () => {
      const result = tryParseDate('2024-01-15')
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('returns undefined for empty string', () => {
      expect(tryParseDate('')).toBeUndefined()
    })

    it('parses a single valid timestamp', () => {
      const timestamp = new Date('2024-01-15').getTime()
      const result = tryParseDate(timestamp)
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('returns undefined for single invalid value', () => {
      expect(tryParseDate('invalid')).toBeUndefined()
      expect(tryParseDate(null)).toBeUndefined()
    })

    it('parses multiple values as Date constructor arguments', () => {
      const result = tryParseDate(2024, 0, 15)
      expect(result).toBeInstanceOf(Date)
      expect(result.getFullYear()).toBe(2024)
      expect(result.getMonth()).toBe(0)
      expect(result.getDate()).toBe(15)
    })

    it('returns undefined for invalid multiple values', () => {
      expect(tryParseDate('invalid', 'date')).toBeUndefined()
    })

    it('handles Date objects passed as single value', () => {
      const date = new Date('2024-01-15')
      const result = tryParseDate(date)
      expect(result).toBeInstanceOf(Date)
      expect(result.getTime()).toBe(date.getTime())
    })
  })
})
