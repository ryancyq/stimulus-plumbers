import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import CalendarDecadeController from '../../../src/controllers/calendar_decade_controller'

describe('CalendarDecadeController', () => {
  let application

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2024, 9, 15)) // October 15, 2024

    application = Application.start()
    application.register('calendar-decade', CalendarDecadeController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.useRealTimers()
  })

  const setupWithGrid = () => {
    document.body.innerHTML = `
      <div role="grid" data-controller="calendar-decade" aria-label="Decade view">
        <div data-calendar-decade-target="grid" role="rowgroup"></div>
      </div>
    `
    return new Promise(resolve => setTimeout(resolve, 10))
  }

  const grid = () => document.querySelector('[data-controller="calendar-decade"]')

  describe('grid rendering', () => {
    beforeEach(setupWithGrid)

    it('renders 12 year buttons on connect (decade ±1 buffer)', () => {
      expect(grid().querySelectorAll('[role="gridcell"]').length).toBe(12)
    })

    it('renders year buttons with data-year', () => {
      const buttons = grid().querySelectorAll('button[data-year]')
      expect(buttons.length).toBe(12)
    })

    it('marks today year with aria-current="year"', () => {
      const current = grid().querySelector('[aria-current="year"]')
      expect(current).not.toBeNull()
      expect(current.dataset.year).toBe('2024')
    })

    it('marks buffer years with aria-disabled', () => {
      const disabled = grid().querySelectorAll('[aria-disabled="true"]')
      expect(disabled.length).toBe(2) // 2019 and 2030 for decade 2020-2029
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

    it('dispatches calendar-decade:selected when clicking a year button', () => {
      const spy = vi.fn()
      grid().addEventListener('calendar-decade:selected', spy)

      grid().querySelector('[data-year="2022"]').click()

      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('detail includes year as number', () => {
      let detail
      grid().addEventListener('calendar-decade:selected', (e) => { detail = e.detail })

      grid().querySelector('[data-year="2024"]').click()

      expect(detail.year).toBe(2024)
    })

    it('does not dispatch when clicking a buffer year (aria-disabled)', () => {
      const spy = vi.fn()
      grid().addEventListener('calendar-decade:selected', spy)

      const disabledBtn = grid().querySelector('[aria-disabled="true"]')
      disabledBtn.click()

      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('navigate', () => {
    beforeEach(setupWithGrid)

    it('re-renders grid for the new decade', async () => {
      const ctrl = application.getControllerForElementAndIdentifier(grid(), 'calendar-decade')
      ctrl.navigate(new Date(2015, 0, 1))
      await new Promise(resolve => setTimeout(resolve, 10))

      // Decade 2010-2019; today (2024) not in this decade so no aria-current
      const current = grid().querySelector('[aria-current="year"]')
      expect(current).toBeNull()
      expect(grid().querySelectorAll('[role="gridcell"]').length).toBe(12)
    })
  })

  describe('without grid target', () => {
    it('connects without error when no grid target present', async () => {
      document.body.innerHTML = `<div role="grid" data-controller="calendar-decade"></div>`
      await new Promise(resolve => setTimeout(resolve, 10))

      const ctrl = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="calendar-decade"]'),
        'calendar-decade'
      )
      expect(ctrl).toBeDefined()
    })
  })
})
