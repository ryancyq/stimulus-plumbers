import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import CalendarYearController from '../../../src/controllers/calendar_year_controller'

describe('CalendarYearController', () => {
  let application

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2024, 9, 15)) // October 15, 2024

    application = Application.start()
    application.register('calendar-year', CalendarYearController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.useRealTimers()
  })

  const setupWithGrid = () => {
    document.body.innerHTML = `
      <div role="grid" data-controller="calendar-year" aria-label="Year view">
        <div data-calendar-year-target="grid" role="rowgroup"></div>
      </div>
    `
    return new Promise(resolve => setTimeout(resolve, 10))
  }

  const grid = () => document.querySelector('[data-controller="calendar-year"]')

  describe('grid rendering', () => {
    beforeEach(setupWithGrid)

    it('renders 12 month buttons on connect', () => {
      expect(grid().querySelectorAll('[role="gridcell"]').length).toBe(12)
    })

    it('renders month buttons with data-month (1-indexed)', () => {
      const buttons = grid().querySelectorAll('button[data-month]')
      expect(buttons.length).toBe(12)
      expect(buttons[0].dataset.month).toBe('1')
      expect(buttons[11].dataset.month).toBe('12')
    })

    it('marks today month with aria-current="month"', () => {
      const current = grid().querySelector('[aria-current="month"]')
      expect(current).not.toBeNull()
      expect(current.dataset.month).toBe('10') // October
    })

    it('wraps cells in rows of 4 inside a rowgroup', () => {
      const rowgroup = grid().querySelector('[role="rowgroup"]')
      expect(rowgroup).not.toBeNull()
      const rows = rowgroup.querySelectorAll('[role="row"]')
      expect(rows.length).toBe(3)
      rows.forEach(row => expect(row.querySelectorAll('[role="gridcell"]').length).toBe(4))
    })
  })

  describe('click dispatch', () => {
    beforeEach(setupWithGrid)

    it('dispatches calendar-year:selected when clicking a month button', () => {
      const spy = vi.fn()
      grid().addEventListener('calendar-year:selected', spy)

      grid().querySelector('[data-month="3"]').click()

      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('detail includes 1-indexed month', () => {
      let detail
      grid().addEventListener('calendar-year:selected', (e) => { detail = e.detail })

      grid().querySelector('[data-month="3"]').click()

      expect(detail.month).toBe(3)
    })

    it('does not dispatch when clicking an aria-disabled button', () => {
      const spy = vi.fn()
      grid().addEventListener('calendar-year:selected', spy)

      // Make one button disabled and click it
      const btn = grid().querySelector('button[data-month]')
      btn.setAttribute('aria-disabled', 'true')
      btn.click()

      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('navigate', () => {
    beforeEach(setupWithGrid)

    it('re-renders grid for the new year', async () => {
      const ctrl = application.getControllerForElementAndIdentifier(grid(), 'calendar-year')
      ctrl.navigate(new Date(2025, 0, 1))
      await new Promise(resolve => setTimeout(resolve, 10))

      // 2025 — October is still today's month but aria-current checks today's year match
      expect(grid().querySelectorAll('[role="gridcell"]').length).toBe(12)
    })
  })

  describe('without grid target', () => {
    it('connects without error when no grid target present', async () => {
      document.body.innerHTML = `<div role="grid" data-controller="calendar-year"></div>`
      await new Promise(resolve => setTimeout(resolve, 10))

      const ctrl = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="calendar-year"]'),
        'calendar-year'
      )
      expect(ctrl).toBeDefined()
    })
  })
})
