import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ComboboxDateController from '../../../src/controllers/combobox_date_controller'
import CalendarMonthController from '../../../src/controllers/calendar_month_controller'

describe('ComboboxDateController', () => {
  let application

  beforeEach(() => {
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date(2024, 9, 15)) // October 15, 2024

    application = Application.start()
    application.register('combobox-date', ComboboxDateController)
    application.register('calendar-month', CalendarMonthController)
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
           data-combobox-date-calendar-month-outlet="[data-controller~='calendar-month']">
        <button data-combobox-date-target="previous">Prev</button>
        <button data-combobox-date-target="day"></button>
        <button data-combobox-date-target="month"></button>
        <button data-combobox-date-target="year"></button>
        <button data-combobox-date-target="viewTitle"></button>
        <button data-combobox-date-target="next">Next</button>
        <div data-combobox-date-target="monthView" hidden></div>
        <div data-combobox-date-target="yearView" hidden></div>
        <div data-controller="calendar-month">
          <div data-calendar-month-target="daysOfWeek"></div>
          <div data-calendar-month-target="daysOfMonth"></div>
        </div>
      </div>
    `
  }

  const setupWithDate = (date = '') => {
    document.body.innerHTML = `
      <div data-controller="combobox-date"
           data-combobox-date-locales-value='["en-US"]'
           data-combobox-date-date-value="${date}"
           data-combobox-date-calendar-month-outlet="[data-controller~='calendar-month']">
        <button data-combobox-date-target="month"></button>
        <button data-combobox-date-target="year"></button>
        <div data-controller="calendar-month">
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

  describe('onSelect', () => {
    it('dispatches combobox-date:selected with the iso value', async () => {
      setupWithDate('')
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)

      const el  = document.querySelector('[data-controller~="combobox-date"]')
      const spy = vi.fn()
      el.addEventListener('combobox-date:selected', spy)

      getController().onSelect({ detail: { iso: '2024-06-15T00:00:00.000Z' } })

      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.value).toBe('2024-06-15T00:00:00.000Z')
    })

    it('does not throw without a calendar outlet', () => {
      setup()
      expect(() => getController()?.onSelected({ detail: { iso: '2024-06-15T00:00:00.000Z' } })).not.toThrow()
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

    it('shows month and year in day view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toMatch(/October.*2024|2024.*October/)
    })

    it('shows year only in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2024')
    })

    it('shows decade range in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2020–2029')
    })

    it('stays in year view when drillUp called again', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2020–2029')
    })
  })

  describe('grid visibility', () => {
    beforeEach(setup)

    it('monthView is hidden in day view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('[data-combobox-date-target="monthView"]').hidden).toBe(true)
    })

    it('monthView is visible in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="monthView"]').hidden).toBe(false)
    })

    it('yearView is visible in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="yearView"]').hidden).toBe(false)
    })

    it('monthView is hidden in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()
      expect(document.querySelector('[data-combobox-date-target="monthView"]').hidden).toBe(true)
    })

    it('day grid is hidden in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      expect(document.querySelector('[data-calendar-month-target="daysOfMonth"]').hidden).toBe(true)
    })

    it('day grid is visible in day view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      expect(document.querySelector('[data-calendar-month-target="daysOfMonth"]').hidden).toBe(false)
    })
  })

  describe('month grid contents', () => {
    beforeEach(setup)

    it('renders 12 month buttons', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const cells = document.querySelector('[data-combobox-date-target="monthView"]').querySelectorAll('[role="gridcell"]')
      expect(cells).toHaveLength(12)
    })

    it('marks current month with aria-current', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const current = document.querySelector('[data-combobox-date-target="monthView"] [aria-current="month"]')
      expect(current).not.toBeNull()
      expect(current.dataset.month).toBe('10') // October = 10 (1-indexed)
    })
  })

  describe('year grid contents', () => {
    beforeEach(setup)

    it('renders 12 year buttons', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const cells = document.querySelector('[data-combobox-date-target="yearView"]').querySelectorAll('[role="gridcell"]')
      expect(cells).toHaveLength(12)
    })

    it('marks current year with aria-current', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const current = document.querySelector('[data-combobox-date-target="yearView"] [aria-current="year"]')
      expect(current).not.toBeNull()
      expect(current.dataset.year).toBe('2024')
    })

    it('marks buffer years with aria-disabled', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      const disabled = document.querySelectorAll('[data-combobox-date-target="yearView"] [aria-disabled="true"]')
      expect(disabled).toHaveLength(2)
    })
  })

  describe('level-aware previous/next', () => {
    beforeEach(setup)

    it('steps back one month in day view', async () => {
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('September')
      })
    })

    it('steps back one year in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2023')
      })
    })

    it('steps back one decade in year view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()
      document.querySelector('[data-combobox-date-target="previous"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="viewTitle"]').textContent).toBe('2010–2019')
      })
    })

    it('steps forward one year in month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      document.querySelector('[data-combobox-date-target="next"]').click()
      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2025')
      })
    })
  })

  describe('selectMonth', () => {
    beforeEach(setup)

    it('navigates to selected month and returns to day view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()

      const marchBtn = [...document.querySelectorAll('[data-combobox-date-target="monthView"] [data-month]')]
        .find((btn) => btn.dataset.month === '3')
      marchBtn.click()

      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="month"]').textContent).toBe('March')
        expect(document.querySelector('[data-combobox-date-target="monthView"]').hidden).toBe(true)
      })
    })
  })

  describe('selectYear', () => {
    beforeEach(setup)

    it('navigates to selected year and returns to month view', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()

      const btn2022 = [...document.querySelectorAll('[data-combobox-date-target="yearView"] [data-year]')]
        .find((btn) => btn.dataset.year === '2022')
      btn2022.click()

      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2022')
        expect(document.querySelector('[data-combobox-date-target="yearView"]').hidden).toBe(true)
        expect(document.querySelector('[data-combobox-date-target="monthView"]').hidden).toBe(false)
      })
    })

    it('does not navigate when clicking a disabled buffer year', async () => {
      await vi.waitUntil(() => getController()?.hasCalendarMonthOutlet)
      getController().drillUp()
      getController().drillUp()

      const disabledBtn = document.querySelector('[data-combobox-date-target="yearView"] [aria-disabled="true"]')
      disabledBtn.click()

      await vi.waitFor(() => {
        expect(document.querySelector('[data-combobox-date-target="year"]').textContent).toBe('2024')
      })
    })
  })
})
