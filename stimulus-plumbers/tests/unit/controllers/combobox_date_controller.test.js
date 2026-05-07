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
        <button data-combobox-date-target="next">Next</button>
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
})
