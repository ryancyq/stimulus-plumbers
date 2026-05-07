import { describe, it, expect } from 'vitest'
import { PlainInputFormatter } from '../../../../../src/plumbers/input_format/formatters/plain'

describe('PlainInputFormatter', () => {
  describe('normalize', () => {
    it('returns string as-is', () => {
      expect(PlainInputFormatter.normalize('hello world')).toBe('hello world')
    })

    it('preserves whitespace', () => {
      expect(PlainInputFormatter.normalize('  spaced  ')).toBe('  spaced  ')
    })

    it('returns empty string for null', () => {
      expect(PlainInputFormatter.normalize(null)).toBe('')
    })

    it('returns empty string for undefined', () => {
      expect(PlainInputFormatter.normalize(undefined)).toBe('')
    })

    it('returns empty string for non-string types', () => {
      expect(PlainInputFormatter.normalize(123)).toBe('')
    })
  })

  describe('validate', () => {
    it('returns true for any string', () => {
      expect(PlainInputFormatter.validate('anything')).toBe(true)
    })

    it('returns true for empty string', () => {
      expect(PlainInputFormatter.validate('')).toBe(true)
    })

    it('returns true for non-string values', () => {
      expect(PlainInputFormatter.validate(null)).toBe(true)
      expect(PlainInputFormatter.validate(undefined)).toBe(true)
    })
  })

  it('does not have a format method', () => {
    expect(PlainInputFormatter.format).toBeUndefined()
  })

  it('does not have a mask method', () => {
    expect(PlainInputFormatter.mask).toBeUndefined()
  })
})
