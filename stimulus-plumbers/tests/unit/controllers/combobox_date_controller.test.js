import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ComboboxDateController from '../../../src/controllers/combobox_date_controller'
import CalendarMonthController from '../../../src/controllers/calendar_month_controller'
import CalendarYearController from '../../../src/controllers/calendar_year_controller'
import CalendarDecadeController from '../../../src/controllers/calendar_decade_controller'

describe('ComboboxDateController', () => {
  let application

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2024, 9, 15)) // October 15, 2024

    application = Application.start()
    application.register('combobox-date', ComboboxDateController)
    application.register('calendar-month', CalendarMonthController)
    application.register('calendar-year', CalendarYearController)
    application.register('calendar-decade', CalendarDecadeController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.useRealTimers()
  })

  const setup = () => {
    document.body.innerHTML = `
      <div data-controller="combobox-date"
           data-combobox-date-locales-value='["en-US"]'
           data-combobox-date-calendar-month-outlet="#month_view"
           data-combobox-date-calendar-year-outlet="#year_view"
           data-combobox-date-calendar-decade-outlet="#decade_view"
           data-action="calendar-year:selected->combobox-date#onMonthSelect calendar-decade:selected->combobox-date#onYearSelect">
        <button data-combobox-date-target="previous">Prev</button>
        <button data-combobox-date-target="day"></button>
        <button data-combobox-date-target="month"></button>
        <button data-combobox-date-target="year"></button>
        <button data-combobox-date-target="viewTitle"></button>
        <button data-combobox-date-target="next">Next</button>
        <div id="month_view" data-controller="calendar-month">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
        <div id="year_view" hidden data-controller="calendar-year" role="grid" aria-label="Year view">
          <div data-calendar-year-target="grid" role="rowgroup"></div>
        </div>
        <div id="decade_view" hidden data-controller="calendar-decade" role="grid" aria-label="Decade view">
          <div data-calendar-decade-target="grid" role="rowgroup"></div>
        </div>
      </div>
    `
  }

  const setupWithDate = (date = '') => {
    document.body.innerHTML = `
      <div data-controller="combobox-date"
           data-combobox-date-locales-value='["en-US"]'
           data-combobox-date-date-value="${date}"
           data-combobox-date-calendar-month-outlet="#month_view">
        <button data-combobox-date-target="month"></button>
        <button data-combobox-date-target="year"></button>
        <div id="month_view" data-controller="calendar-month">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      </div>
    `
  }

  const getController = () => {
    const el = document.querySelector('[data-controller~="combobox-date"]')
    return application.getControllerForElementAndIdentifier(el, 'combobox-date')
  }

  describe('nav labels', () => {
    beforeEach(setup)

    it('draws day label on outlet connect', () => {
      expect(document.querySelector('[data-combobox-date-target="day"]').textContent).toBe('15')
    })

    it('draws month label on outlet connect', () => {
      expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('October')
    })

    it('draws year label on outlet connect', () => {
      expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2024')
    })
  })

  describe('previous', () => {
    beforeEach(setup)

    it('steps calendar back one month', async () => {
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('September')
      })
    })

    describe('when in January', () => {
      beforeEach(() => {
        vi.setSystemTime(new Date(2024, 0, 15))
        setup()
      })

      it('updates year when stepping back past January', async () => {
        document.querySelector('[data-combobox-date-target="previous"]').click()
        await vi.waitFor(() => {
          expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('December')
          expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2023')
        })
      })
    })
  })

  describe('next', () => {
    beforeEach(setup)

    it('steps calendar forward one month', async () => {
      document.querySelector('[data-combobox-date-target="next"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('November')
      })
    })
  })

  describe('date value initialization', () => {
    it('navigates calendar to date value on outlet connect', async () => {
      setupWithDate('2024-03-20T00:00:00.000Z')
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('March')
        expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2024')
      })
    })

    it('uses current date when date value is empty', async () => {
      setupWithDate('')
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('October')
      })
    })
  })

  describe('onDaySelect', () => {
    it('dispatches combobox-date:selected with the iso value', async () => {
      setupWithDate('')
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)

      const el  = document.querySelector('[data-controller~="combobox-date"]')
      const spy = vi.fn()
      el.addEventListener('combobox-date:selected', spy)

      getController().onDaySelect({ detail: { iso: '2024-06-15T00:00:00.000Z' } })

      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.value).toBe('2024-06-15T00:00:00.000Z')
    })

    it('does not throw without a calendar outlet', () => {
      setup()
      expect(() => getController()?.onDaySelect({ detail: { iso: '2024-06-15T00:00:00.000Z' } })).not.toThrow()
    })
  })

  describe('calendar grid', () => {
    beforeEach(setup)

    it('renders 35 gridcells for October 2024', () => {
      expect(
        document.querySelector('[data-calendar-month-target="daysOfMonth"]')
          .querySelectorAll('[role="gridcell"]').length
      ).toBe(35)
    })

    it('redraws grid after previous', async () => {
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(
          document.querySelector('[data-calendar-month-target="daysOfMonth"]')
            .querySelectorAll('button').length
        ).toBe(30)
      })
    })
  })

  describe('viewTitle label', () => {
    beforeEach(setup)

    it('shows month and year in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toMatch(/October.*2024|2024.*October/)
    })

    it('shows year only in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2024')
    })

    it('shows decade range in decade view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2020–2029')
    })

    it('stays in decade view when zoomOut called again', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()
      getController().zoomOut()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2020–2029')
    })
  })

  describe('view visibility', () => {
    beforeEach(setup)

    it('year outlet element is hidden in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('#year_view').hidden).toBe(true)
    })

    it('year outlet element is visible in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      expect(document.querySelector('#year_view').hidden).toBe(false)
    })

    it('decade outlet element is visible in decade view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()
      expect(document.querySelector('#decade_view').hidden).toBe(false)
    })

    it('year outlet element is hidden in decade view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()
      expect(document.querySelector('#year_view').hidden).toBe(true)
    })

    it('day grid is hidden in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      expect(document.querySelector('[data-calendar-month-target="daysOfMonth"]').hidden).toBe(true)
    })

    it('day grid is visible in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('[data-calendar-month-target="daysOfMonth"]').hidden).toBe(false)
    })
  })

  describe('year grid contents', () => {
    beforeEach(setup)

    it('renders 12 month buttons in calendar-year grid', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const cells = document.querySelector('#year_view').querySelectorAll('[role="gridcell"]')
      expect(cells).toHaveLength(12)
    })

    it('marks today month with aria-current', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const current = document.querySelector('#year_view [aria-current="month"]')
      expect(current).not.toBeNull()
      expect(current.dataset.month).toBe('10') // October = 10 (1-indexed)
    })

    it('year view has grid role', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('#year_view').getAttribute('role')).toBe('grid')
    })

    it('year view rowgroup wraps 3 rows of 4 month cells', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const rowgroup = document.querySelector('#year_view [role="rowgroup"]')
      expect(rowgroup).not.toBeNull()
      const rows = rowgroup.querySelectorAll('[role="row"]')
      expect(rows).toHaveLength(3)
      rows.forEach((row) => {
        expect(row.querySelectorAll('[role="gridcell"]')).toHaveLength(4)
      })
    })
  })

  describe('decade grid contents', () => {
    beforeEach(setup)

    it('renders 12 year buttons in calendar-decade grid', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const cells = document.querySelector('#decade_view').querySelectorAll('[role="gridcell"]')
      expect(cells).toHaveLength(12)
    })

    it('marks current year with aria-current', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const current = document.querySelector('#decade_view [aria-current="year"]')
      expect(current).not.toBeNull()
      expect(current.dataset.year).toBe('2024')
    })

    it('marks buffer years with aria-disabled', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const disabled = document.querySelectorAll('#decade_view [aria-disabled="true"]')
      expect(disabled).toHaveLength(2)
    })

    it('decade view has grid role', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('#decade_view').getAttribute('role')).toBe('grid')
    })

    it('decade view rowgroup wraps 3 rows of 4 year cells', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const rowgroup = document.querySelector('#decade_view [role="rowgroup"]')
      expect(rowgroup).not.toBeNull()
      const rows = rowgroup.querySelectorAll('[role="row"]')
      expect(rows).toHaveLength(3)
      rows.forEach((row) => {
        expect(row.querySelectorAll('[role="gridcell"]')).toHaveLength(4)
      })
    })
  })

  describe('level-aware previous/next', () => {
    beforeEach(setup)

    it('steps back one month in month view', async () => {
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('September')
      })
    })

    it('steps back one year in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2023')
        expect(document.querySelector('#year_view').querySelectorAll('[role="gridcell"]').length).toBe(12)
      })
    })

    it('steps back one decade in decade view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2010–2019')
      })
    })

    it('steps forward one year in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      document.querySelector('[data-combobox-date-target="next"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2025')
        expect(document.querySelector('#year_view').querySelectorAll('[role="gridcell"]').length).toBe(12)
      })
    })
  })

  describe('onMonthSelect', () => {
    beforeEach(setup)

    it('navigates to selected month and returns to month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()

      const marchBtn = [...document.querySelectorAll('#year_view [data-month]')]
        .find((btn) => btn.dataset.month === '3')
      marchBtn.click()

      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('March')
        expect(document.querySelector('#year_view').hidden).toBe(true)
      })
    })
  })

  describe('onYearSelect', () => {
    beforeEach(setup)

    it('navigates to selected year and returns to year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()

      const btn2022 = [...document.querySelectorAll('#decade_view [data-year]')]
        .find((btn) => btn.dataset.year === '2022')
      btn2022.click()

      await vi.waitFor(() => {
        expect(document.querySelector('#decade_view').hidden).toBe(true)
        expect(document.querySelector('#year_view').hidden).toBe(false)
      })
    })

    it('does not navigate when clicking a disabled buffer year', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().zoomOut()
      getController().zoomOut()

      const disabledBtn = document.querySelector('#decade_view [aria-disabled="true"]')
      const currentCells = document.querySelector('#decade_view').querySelectorAll('[role="gridcell"]').length
      disabledBtn.click()

      await vi.waitFor(() => {
        // Still in decade view, same cells
        expect(document.querySelector('#decade_view').querySelectorAll('[role="gridcell"]').length).toBe(currentCells)
      })
    })
  })
})
