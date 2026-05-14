import { describe, it, expect } from 'vitest'
import { PlainFormatter } from '../../../../src/plumbers/formatters/plain'

describe('PlainFormatter', () => {
  describe('normalize', () => {
    it('returns string as-is', () => {
      expect(PlainFormatter.normalize('hello world')).toBe('hello world')
    })

    it('preserves whitespace', () => {
      expect(PlainFormatter.normalize('  spaced  ')).toBe('  spaced  ')
    })

    it('returns empty string for null', () => {
      expect(PlainFormatter.normalize(null)).toBe('')
    })

    it('returns empty string for undefined', () => {
      expect(PlainFormatter.normalize(undefined)).toBe('')
    })

    it('returns empty string for non-string types', () => {
      expect(PlainFormatter.normalize(123)).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for any string', () => {
      expect(PlainFormatter.validate('anything')).toBe(true)
    })

    it('returns true for empty string', () => {
      expect(PlainFormatter.validate('')).toBe(true)
    })

    it('returns true for non-string values', () => {
      expect(PlainFormatter.validate(null)).toBe(true)
      expect(PlainFormatter.validate(undefined)).toBe(true)
    })
  })

  it('does not have a format method', () => {
    expect(PlainFormatter.format).toBeUndefined()
  })

  it('does not have a mask method', () => {
    expect(PlainFormatter.mask).toBeUndefined()
  })
})
