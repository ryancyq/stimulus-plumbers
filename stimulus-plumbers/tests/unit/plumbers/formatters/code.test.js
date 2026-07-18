import { describe, it, expect } from 'vitest'
import { CodeFormatter } from '../../../../src/plumbers/formatters/code'

describe('CodeFormatter', () => {
  describe('normalize', () => {
    it('strips non-digits when charset is digits', () => {
      expect(CodeFormatter.normalize('4 8-29 13', { charset: 'digits' })).toBe('482913')
    })

    it('strips digits and symbols when charset is letters', () => {
      expect(CodeFormatter.normalize('ab-12cd', { charset: 'letters' })).toBe('ABCD')
    })

    it('keeps letters and digits when charset is alphanumeric', () => {
      expect(CodeFormatter.normalize('a1-b2 c3', { charset: 'alphanumeric' })).toBe('A1B2C3')
    })

    it('defaults to alphanumeric charset', () => {
      expect(CodeFormatter.normalize('a1!b2')).toBe('A1B2')
    })

    it('uppercases letters', () => {
      expect(CodeFormatter.normalize('abc', { charset: 'letters' })).toBe('ABC')
    })

    it('truncates to length when length is set', () => {
      expect(CodeFormatter.normalize('12345678', { charset: 'digits', length: 6 })).toBe('123456')
    })

    it('does not truncate when length is 0 or unset', () => {
      expect(CodeFormatter.normalize('12345678', { charset: 'digits' })).toBe('12345678')
    })

    it('returns empty string for non-string input', () => {
      expect(CodeFormatter.normalize(null)).toBe('')
      expect(CodeFormatter.normalize(undefined)).toBe('')
    })
  })

  describe('validate', () => {
    it('is true only at exact length when length is set', () => {
      expect(CodeFormatter.validate('482913', { length: 6 })).toBe(true)
      expect(CodeFormatter.validate('4829', { length: 6 })).toBe(false)
      expect(CodeFormatter.validate('4829131', { length: 6 })).toBe(false)
    })

    it('is true at any length when length is unset', () => {
      expect(CodeFormatter.validate('4829')).toBe(true)
    })

    it('is false for non-string input', () => {
      expect(CodeFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('returns the value unchanged (cells handle display)', () => {
      expect(CodeFormatter.format('482913')).toBe('482913')
    })

    it('returns empty string for non-string input', () => {
      expect(CodeFormatter.format(null)).toBe('')
    })
  })

  describe('cells', () => {
    it('hints uniform cells with the configured length', () => {
      expect(CodeFormatter.cells({ length: 6 })).toEqual({ groups: [], length: 6 })
    })

    it('hints length 0 when unset', () => {
      expect(CodeFormatter.cells()).toEqual({ groups: [], length: 0 })
    })
  })
})
