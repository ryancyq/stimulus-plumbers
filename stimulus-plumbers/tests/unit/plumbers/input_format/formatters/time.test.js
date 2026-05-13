import { describe, it, expect } from 'vitest'
import { TimeInputFormatter } from '../../../../../src/plumbers/input_format/formatters/time'

describe('TimeInputFormatter', () => {
  describe('normalize', () => {
    describe('non-string input', () => {
      it('returns "" for null', () => {
        expect(TimeInputFormatter.normalize(null)).toBe('')
      })

      it('returns "" for undefined', () => {
        expect(TimeInputFormatter.normalize(undefined)).toBe('')
      })

      it('returns "" for a number', () => {
        expect(TimeInputFormatter.normalize(930)).toBe('')
      })
    })

    describe('24-hour format', () => {
      it('normalizes single-digit hour', () => {
        expect(TimeInputFormatter.normalize('9:05')).toBe('09:05')
      })

      it('preserves double-digit hour', () => {
        expect(TimeInputFormatter.normalize('23:59')).toBe('23:59')
      })

      it('normalizes midnight', () => {
        expect(TimeInputFormatter.normalize('0:00')).toBe('00:00')
      })

      it('normalizes leading-zero hour', () => {
        expect(TimeInputFormatter.normalize('09:30')).toBe('09:30')
      })

      it('handles hour 10', () => {
        expect(TimeInputFormatter.normalize('10:00')).toBe('10:00')
      })
    })

    describe('24-hour invalid values', () => {
      it('returns "" for hour 24', () => {
        expect(TimeInputFormatter.normalize('24:00')).toBe('')
      })

      it('returns "" for minute 60', () => {
        expect(TimeInputFormatter.normalize('23:60')).toBe('')
      })

      it('returns "" for non-time string', () => {
        expect(TimeInputFormatter.normalize('abc')).toBe('')
      })

      it('returns "" for empty string', () => {
        expect(TimeInputFormatter.normalize('')).toBe('')
      })
    })

    describe('12-hour AM', () => {
      it('converts 12:00 AM to 00:00', () => {
        expect(TimeInputFormatter.normalize('12:00 AM')).toBe('00:00')
      })

      it('converts 1:30 AM to 01:30', () => {
        expect(TimeInputFormatter.normalize('1:30 AM')).toBe('01:30')
      })

      it('converts 11:59 AM to 11:59 (case-insensitive)', () => {
        expect(TimeInputFormatter.normalize('11:59 am')).toBe('11:59')
      })

      it('converts 12:01 AM to 00:01', () => {
        expect(TimeInputFormatter.normalize('12:01 AM')).toBe('00:01')
      })
    })

    describe('12-hour PM', () => {
      it('keeps 12:00 PM as 12:00', () => {
        expect(TimeInputFormatter.normalize('12:00 PM')).toBe('12:00')
      })

      it('converts 1:30 PM to 13:30', () => {
        expect(TimeInputFormatter.normalize('1:30 PM')).toBe('13:30')
      })

      it('converts 11:59 PM to 23:59', () => {
        expect(TimeInputFormatter.normalize('11:59 PM')).toBe('23:59')
      })

      it('converts 12:59 PM to 12:59', () => {
        expect(TimeInputFormatter.normalize('12:59 PM')).toBe('12:59')
      })
    })

    describe('12-hour overflow', () => {
      it('returns "" for 13:00 PM (hour overflow after +12)', () => {
        expect(TimeInputFormatter.normalize('13:00 PM')).toBe('')
      })
    })
  })

  describe('validate', () => {
    it('returns true for a valid 24h time', () => {
      expect(TimeInputFormatter.validate('14:30')).toBe(true)
    })

    it('returns true for a valid 12h AM time', () => {
      expect(TimeInputFormatter.validate('9:00 AM')).toBe(true)
    })

    it('returns true for a valid 12h PM time', () => {
      expect(TimeInputFormatter.validate('3:45 PM')).toBe(true)
    })

    it('returns false for garbage input', () => {
      expect(TimeInputFormatter.validate('not-a-time')).toBe(false)
    })

    it('returns false for empty string', () => {
      expect(TimeInputFormatter.validate('')).toBe(false)
    })

    it('returns false for non-string', () => {
      expect(TimeInputFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    describe('h12 (default)', () => {
      it('formats midnight as 12:00 AM', () => {
        expect(TimeInputFormatter.format('00:00')).toBe('12:00 AM')
      })

      it('formats noon as 12:00 PM', () => {
        expect(TimeInputFormatter.format('12:00')).toBe('12:00 PM')
      })

      it('formats 1 PM hour', () => {
        expect(TimeInputFormatter.format('13:30')).toBe('1:30 PM')
      })

      it('formats single-digit AM hour without leading zero', () => {
        expect(TimeInputFormatter.format('09:05')).toBe('9:05 AM')
      })

      it('formats 11:59 PM correctly', () => {
        expect(TimeInputFormatter.format('23:59')).toBe('11:59 PM')
      })
    })

    describe('h24 option', () => {
      it('formats with leading zero', () => {
        expect(TimeInputFormatter.format('09:05', { format: 'h24' })).toBe('09:05')
      })

      it('formats midnight as 00:00', () => {
        expect(TimeInputFormatter.format('00:00', { format: 'h24' })).toBe('00:00')
      })

      it('formats 23:59 as 23:59', () => {
        expect(TimeInputFormatter.format('23:59', { format: 'h24' })).toBe('23:59')
      })
    })

    describe('passthrough / edge cases', () => {
      it('returns the value as-is when it does not match HH:MM', () => {
        expect(TimeInputFormatter.format('not-a-time')).toBe('not-a-time')
      })

      it('returns "" for non-string input', () => {
        expect(TimeInputFormatter.format(null)).toBe('')
        expect(TimeInputFormatter.format(undefined)).toBe('')
      })
    })
  })
})
