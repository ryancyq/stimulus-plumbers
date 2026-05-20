import { describe, it, expect, beforeEach, vi } from 'vitest'
import { Calendar, initCalendar } from '../../../src/plumbers/calendar'

describe('Calendar', () => {
  let mockController
  let element

  beforeEach(() => {
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'calendar',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    })
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.controller).toBe(mockController)
      expect(calendar.firstDayOfWeek).toBe(0)
      expect(calendar.onNavigated).toBe('navigated')
      expect(calendar.disabledDates).toEqual([])
      expect(calendar.disabledWeekdays).toEqual([])
      expect(calendar.disabledDays).toEqual([])
      expect(calendar.disabledMonths).toEqual([])
      expect(calendar.disabledYears).toEqual([])
    })

    it('accepts custom firstDayOfWeek', () => {
      const calendar = new Calendar(mockController, {
        firstDayOfWeek: 1, // Monday
      })

      expect(calendar.firstDayOfWeek).toBe(1)
    })

    it('rejects invalid firstDayOfWeek', () => {
      const calendar = new Calendar(mockController, {
        firstDayOfWeek: 7,
      })

      expect(calendar.firstDayOfWeek).toBe(0)
    })

    it('accepts custom today date', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      expect(calendar.now).toBeInstanceOf(Date)
      expect(calendar.now.getFullYear()).toBe(2024)
      expect(calendar.now.getMonth()).toBe(0)
      expect(calendar.now.getDate()).toBe(15)
    })

    it('accepts individual day, month, year components when all three are provided', () => {
      const calendar = new Calendar(mockController, {
        year: 2024,
        month: 5, // June (0-indexed)
        day: 20,
      })

      expect(calendar.current).toBeInstanceOf(Date)
      expect(calendar.current.getFullYear()).toBe(2024)
      expect(calendar.current.getMonth()).toBe(5)
      expect(calendar.current.getDate()).toBe(20)
      expect(calendar.day).toBe(20)
      expect(calendar.month).toBe(5)
      expect(calendar.year).toBe(2024)
    })

    it('ignores partial date components and uses today instead', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
        month: 11, // Ignored because year and day are missing
      })

      // Should use today since not all three components provided
      expect(calendar.current).toBeInstanceOf(Date)
      expect(calendar.current.getFullYear()).toBe(2024)
      expect(calendar.current.getMonth()).toBe(0) // January, not December
      expect(calendar.current.getDate()).toBe(15)
    })

    it('accepts since and till dates', () => {
      const calendar = new Calendar(mockController, {
        since: '2024-01-01',
        till: '2024-12-31',
      })

      expect(calendar.since).toBeInstanceOf(Date)
      expect(calendar.till).toBeInstanceOf(Date)
    })

    it('accepts disabled date arrays', () => {
      const calendar = new Calendar(mockController, {
        disabledDates: ['2024-01-15', '2024-01-20'],
        disabledWeekdays: [0, 6],
        disabledDays: [13],
        disabledMonths: [11],
        disabledYears: [2025],
      })

      expect(calendar.disabledDates).toEqual(['2024-01-15', '2024-01-20'])
      expect(calendar.disabledWeekdays).toEqual([0, 6])
      expect(calendar.disabledDays).toEqual([13])
      expect(calendar.disabledMonths).toEqual([11])
      expect(calendar.disabledYears).toEqual([2025])
    })

    it('rejects negative firstDayOfWeek', () => {
      const calendar = new Calendar(mockController, { firstDayOfWeek: -1 })

      expect(calendar.firstDayOfWeek).toBe(0)
    })

    it('falls back to empty arrays for non-array disabled option values', () => {
      const calendar = new Calendar(mockController, {
        disabledDates: 'not-an-array',
        disabledWeekdays: 123,
        disabledDays: null,
        disabledMonths: {},
        disabledYears: false,
      })

      expect(calendar.disabledDates).toEqual([])
      expect(calendar.disabledWeekdays).toEqual([])
      expect(calendar.disabledDays).toEqual([])
      expect(calendar.disabledMonths).toEqual([])
      expect(calendar.disabledYears).toEqual([])
    })

    it('enhances controller with calendar helpers', () => {
      const calendar = new Calendar(mockController)

      expect(mockController.calendar).toBeDefined()
      expect(mockController.calendar.navigate).toBeTypeOf('function')
      expect(mockController.calendar.step).toBeTypeOf('function')
      expect(mockController.calendar.isDisabled).toBeTypeOf('function')
      expect(mockController.calendar.isWithinRange).toBeTypeOf('function')
    })
  })

  describe('today setter', () => {
    it('rejects invalid date without changing now', () => {
      const calendar = new Calendar(mockController, { today: '2024-06-15' })
      const before = calendar.now
      calendar.today = new Date('invalid')
      expect(calendar.now).toBe(before)
    })

    it('uses the new date day when month/year match the current calendar', () => {
      const calendar = new Calendar(mockController, { today: '2024-06-15' })
      calendar.today = new Date('2024-06-20')
      const now = new Date(calendar.now)
      expect(now.getDate()).toBe(20)
      expect(now.getMonth()).toBe(5)
      expect(now.getFullYear()).toBe(2024)
    })

    it('sets day to 1 when the new date is in a different month', () => {
      const calendar = new Calendar(mockController, { today: '2024-06-15' })
      // calendar.month = 5 (June), so sameMonthYear = false for July
      calendar.today = new Date('2024-07-20')
      const now = new Date(calendar.now)
      expect(now.getDate()).toBe(1)
      expect(now.getMonth()).toBe(5) // retains existing June
      expect(now.getFullYear()).toBe(2024)
    })

    it('assigns now as a Date after setting', () => {
      const calendar = new Calendar(mockController, { today: '2024-06-15' })
      calendar.today = new Date('2024-06-20')
      expect(calendar.now).toBeInstanceOf(Date)
    })

    it('retains month 0 (January) when setting today to a different month', () => {
      const calendar = new Calendar(mockController, { today: '2024-01-15' })
      calendar.today = new Date('2024-03-10')
      expect(calendar.now.getMonth()).toBe(0) // January retained via ?? operator
    })
  })

  describe('buildDaysOfWeek', () => {
    it('builds 7 days of week', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.daysOfWeek).toHaveLength(7)
    })

    it('starts with Sunday when firstDayOfWeek is 0', () => {
      const calendar = new Calendar(mockController, {
        firstDayOfWeek: 0,
      })

      expect(calendar.daysOfWeek[0].value).toBe(0) // Sunday
    })

    it('starts with Monday when firstDayOfWeek is 1', () => {
      const calendar = new Calendar(mockController, {
        firstDayOfWeek: 1,
      })

      expect(calendar.daysOfWeek[0].value).toBe(1) // Monday
    })

    it('includes long and short formats', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.daysOfWeek[0].long).toBeDefined()
      expect(calendar.daysOfWeek[0].short).toBeDefined()
      expect(typeof calendar.daysOfWeek[0].long).toBe('string')
      expect(typeof calendar.daysOfWeek[0].short).toBe('string')
    })
  })

  describe('buildDaysOfMonth', () => {
    it('builds days for current month', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      expect(calendar.daysOfMonth.length).toBeGreaterThan(0)
    })

    it('includes days from previous and next months', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      const hasPreviousMonth = calendar.daysOfMonth.some((day) => day.month === 11)
      const hasNextMonth = calendar.daysOfMonth.some((day) => day.month === 1)

      expect(hasPreviousMonth || hasNextMonth).toBe(true)
    })

    it('marks current month days correctly', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      const currentMonthDays = calendar.daysOfMonth.filter((day) => day.current)
      expect(currentMonthDays.length).toBeGreaterThan(0)
    })
  })

  describe('buildMonthsOfYear', () => {
    it('builds 12 months', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.monthsOfYear).toHaveLength(12)
    })

    it('includes long, short, and numeric formats', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.monthsOfYear[0].long).toBeDefined()
      expect(calendar.monthsOfYear[0].short).toBeDefined()
      expect(calendar.monthsOfYear[0].numeric).toBeDefined()
    })

    it('has correct month values', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.monthsOfYear[0].value).toBe(0)
      expect(calendar.monthsOfYear[11].value).toBe(11)
    })
  })

  describe('current', () => {
    it('returns current date', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      expect(calendar.current).toBeInstanceOf(Date)
      expect(calendar.current.getFullYear()).toBe(2024)
      expect(calendar.current.getMonth()).toBe(0)
      expect(calendar.current.getDate()).toBe(15)
    })

    it('can be set to new date', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      calendar.current = new Date('2024-02-20')

      expect(calendar.day).toBe(20)
      expect(calendar.month).toBe(1)
      expect(calendar.year).toBe(2024)
    })
  })

  describe('navigate', () => {
    it('updates current date', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.navigate(new Date('2024-02-20'))

      expect(calendar.day).toBe(20)
      expect(calendar.month).toBe(1)
      expect(calendar.year).toBe(2024)
    })

    it('dispatches navigate and navigated events', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.navigate(new Date('2024-02-20'))

      expect(mockController.dispatch).toHaveBeenCalledWith('navigate', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('navigated', expect.any(Object))
    })

    it('calls onNavigated callback', async () => {
      const onNavigated = vi.fn()
      mockController.navigated = onNavigated
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
        onNavigated: 'navigated',
      })

      await calendar.navigate(new Date('2024-02-20'))

      expect(onNavigated).toHaveBeenCalled()
    })

    it('rebuilds calendar data', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      const oldMonths = calendar.monthsOfYear
      await calendar.navigate(new Date('2025-02-20'))
      const newMonths = calendar.monthsOfYear

      expect(newMonths).not.toBe(oldMonths)
    })

    it('does nothing for invalid dates', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.navigate(new Date('invalid'))

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches navigate and navigated with matching from/to ISO strings', async () => {
      const calendar = new Calendar(mockController, { today: '2024-01-15' })
      const target = new Date('2024-02-20')
      const toIso = target.toISOString()

      await calendar.navigate(target)

      expect(mockController.dispatch).toHaveBeenCalledWith(
        'navigate',
        expect.objectContaining({ detail: expect.objectContaining({ to: toIso }) }),
      )
      expect(mockController.dispatch).toHaveBeenCalledWith(
        'navigated',
        expect.objectContaining({ detail: expect.objectContaining({ to: toIso }) }),
      )
    })
  })

  describe('step', () => {
    it('steps forward by days', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('day', 5)

      expect(calendar.day).toBe(20)
    })

    it('steps backward by days', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('day', -5)

      expect(calendar.day).toBe(10)
    })

    it('steps forward by months', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('month', 2)

      expect(calendar.month).toBe(2) // March
    })

    it('steps backward by months', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('month', -1)

      expect(calendar.month).toBe(11) // December of previous year
      expect(calendar.year).toBe(2023)
    })

    it('steps forward by years', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('year', 3)

      expect(calendar.year).toBe(2027)
    })

    it('steps backward by years', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('year', -2)

      expect(calendar.year).toBe(2022)
    })

    it('does nothing when value is 0', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('day', 0)

      expect(calendar.day).toBe(15)
      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('does nothing for invalid type', async () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      await calendar.step('invalid', 5)

      expect(calendar.day).toBe(15)
      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('isDisabled', () => {
    it('returns false for invalid dates', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.isDisabled(new Date('invalid'))).toBe(false)
    })

    it('checks disabled dates', () => {
      const calendar = new Calendar(mockController, {
        disabledDates: ['2024-01-15'],
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isDisabled(new Date('2024-01-16'))).toBe(false)
    })

    it('checks disabled weekdays by value', () => {
      const calendar = new Calendar(mockController, {
        disabledWeekdays: [0, 6], // Sunday and Saturday
      })

      expect(calendar.isDisabled(new Date('2024-01-14'))).toBe(true) // Sunday
      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(false) // Monday
    })

    it('checks disabled days of month', () => {
      const calendar = new Calendar(mockController, {
        disabledDays: [13],
      })

      expect(calendar.isDisabled(new Date('2024-01-13'))).toBe(true)
      expect(calendar.isDisabled(new Date('2024-01-14'))).toBe(false)
    })

    it('checks disabled months', () => {
      const calendar = new Calendar(mockController, {
        disabledMonths: [0], // January
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isDisabled(new Date('2024-02-15'))).toBe(false)
    })

    it('checks disabled years', () => {
      const calendar = new Calendar(mockController, {
        disabledYears: [2024],
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isDisabled(new Date('2025-01-15'))).toBe(false)
    })

    it('returns false when no disabled criteria match', () => {
      const calendar = new Calendar(mockController, {
        disabledDates: ['2024-01-20'],
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(false)
    })

    it('checks disabled weekdays by short name', () => {
      const calendar = new Calendar(mockController, {
        disabledWeekdays: ['Sun'],
      })

      expect(calendar.isDisabled(new Date('2024-01-14'))).toBe(true) // Sunday
      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(false) // Monday
    })

    it('checks disabled weekdays by long name', () => {
      const calendar = new Calendar(mockController, {
        disabledWeekdays: ['Sunday'],
      })

      expect(calendar.isDisabled(new Date('2024-01-14'))).toBe(true) // Sunday
      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(false) // Monday
    })

    it('checks disabled months by short name', () => {
      const calendar = new Calendar(mockController, {
        disabledMonths: ['Jan'],
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isDisabled(new Date('2024-02-15'))).toBe(false)
    })

    it('checks disabled months by long name', () => {
      const calendar = new Calendar(mockController, {
        disabledMonths: ['January'],
      })

      expect(calendar.isDisabled(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isDisabled(new Date('2024-02-15'))).toBe(false)
    })
  })

  describe('isWithinRange', () => {
    it('returns false for invalid dates', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.isWithinRange(new Date('invalid'))).toBe(false)
    })

    it('returns true when no range is set', () => {
      const calendar = new Calendar(mockController)

      expect(calendar.isWithinRange(new Date('2024-01-15'))).toBe(true)
    })

    it('checks since date', () => {
      const calendar = new Calendar(mockController, {
        since: '2024-01-10',
      })

      expect(calendar.isWithinRange(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isWithinRange(new Date('2024-01-05'))).toBe(false)
    })

    it('checks till date', () => {
      const calendar = new Calendar(mockController, {
        till: '2024-01-20',
      })

      expect(calendar.isWithinRange(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isWithinRange(new Date('2024-01-25'))).toBe(false)
    })

    it('checks both since and till', () => {
      const calendar = new Calendar(mockController, {
        since: '2024-01-10',
        till: '2024-01-20',
      })

      expect(calendar.isWithinRange(new Date('2024-01-15'))).toBe(true)
      expect(calendar.isWithinRange(new Date('2024-01-05'))).toBe(false)
      expect(calendar.isWithinRange(new Date('2024-01-25'))).toBe(false)
    })
  })

  describe('enhance', () => {
    it('adds calendar getter to controller', () => {
      const calendar = new Calendar(mockController)

      expect(mockController.calendar).toBeDefined()
    })

    it('exposes calendar properties', () => {
      const calendar = new Calendar(mockController, {
        today: '2024-01-15',
      })

      expect(mockController.calendar.today).toBeDefined()
      expect(mockController.calendar.current).toBeDefined()
      expect(mockController.calendar.day).toBe(15)
      expect(mockController.calendar.month).toBe(0)
      expect(mockController.calendar.year).toBe(2024)
    })

    it('exposes calendar methods', () => {
      const calendar = new Calendar(mockController)

      expect(mockController.calendar.navigate).toBeTypeOf('function')
      expect(mockController.calendar.step).toBeTypeOf('function')
      expect(mockController.calendar.isDisabled).toBeTypeOf('function')
      expect(mockController.calendar.isWithinRange).toBeTypeOf('function')
    })

    it('exposes collection and range properties', () => {
      const calendar = new Calendar(mockController, {
        since: '2024-01-01',
        till: '2024-12-31',
        firstDayOfWeek: 1,
        disabledDates: ['2024-03-15'],
        disabledWeekdays: [0],
        disabledDays: [13],
        disabledMonths: [11],
        disabledYears: [2025],
      })

      const cal = mockController.calendar
      expect(cal.since).toBeInstanceOf(Date)
      expect(cal.till).toBeInstanceOf(Date)
      expect(cal.firstDayOfWeek).toBe(1)
      expect(cal.disabledDates).toEqual(['2024-03-15'])
      expect(cal.disabledWeekdays).toEqual([0])
      expect(cal.disabledDays).toEqual([13])
      expect(cal.disabledMonths).toEqual([11])
      expect(cal.disabledYears).toEqual([2025])
      expect(cal.daysOfWeek).toHaveLength(7)
      expect(cal.daysOfMonth.length).toBeGreaterThan(0)
      expect(cal.monthsOfYear).toHaveLength(12)
    })
  })

  describe('initCalendar', () => {
    it('creates and returns a Calendar instance', () => {
      const calendar = initCalendar(mockController, {
        firstDayOfWeek: 1,
      })

      expect(calendar).toBeInstanceOf(Calendar)
      expect(calendar.firstDayOfWeek).toBe(1)
    })
  })
})
