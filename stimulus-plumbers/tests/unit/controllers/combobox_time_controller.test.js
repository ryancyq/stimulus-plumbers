import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ComboboxTimeController from '../../../src/controllers/combobox_time_controller'

describe('ComboboxTimeController', () => {
  let application

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="combobox-time"]'),
      'combobox-time'
    )

  beforeEach(() => {
    application = Application.start()
    application.register('combobox-time', ComboboxTimeController)
    Element.prototype.scrollIntoView = vi.fn()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.restoreAllMocks()
  })

  const setup12h = (hour = '10', minute = '30', period = 'AM') => {
    document.body.innerHTML = `
      <div data-controller="combobox-time">
        <div data-combobox-time-target="hour" role="listbox">
          <div role="option" data-value="10" aria-selected="${hour === '10' ? 'true' : 'false'}">10</div>
          <div role="option" data-value="11" aria-selected="${hour === '11' ? 'true' : 'false'}">11</div>
          <div role="option" data-value="12" aria-selected="${hour === '12' ? 'true' : 'false'}">12</div>
        </div>
        <div data-combobox-time-target="minute" role="listbox">
          <div role="option" data-value="00" aria-selected="${minute === '00' ? 'true' : 'false'}">00</div>
          <div role="option" data-value="30" aria-selected="${minute === '30' ? 'true' : 'false'}">30</div>
          <div role="option" data-value="45" aria-selected="${minute === '45' ? 'true' : 'false'}">45</div>
        </div>
        <div data-combobox-time-target="period" role="listbox">
          <div role="option" data-value="AM" aria-selected="${period === 'AM' ? 'true' : 'false'}">AM</div>
          <div role="option" data-value="PM" aria-selected="${period === 'PM' ? 'true' : 'false'}">PM</div>
        </div>
      </div>
    `
  }

  const setup24h = (hour = '10', minute = '30') => {
    document.body.innerHTML = `
      <div data-controller="combobox-time">
        <div data-combobox-time-target="hour" role="listbox">
          <div role="option" data-value="09" aria-selected="${hour === '09' ? 'true' : 'false'}">09</div>
          <div role="option" data-value="10" aria-selected="${hour === '10' ? 'true' : 'false'}">10</div>
          <div role="option" data-value="14" aria-selected="${hour === '14' ? 'true' : 'false'}">14</div>
        </div>
        <div data-combobox-time-target="minute" role="listbox">
          <div role="option" data-value="00" aria-selected="${minute === '00' ? 'true' : 'false'}">00</div>
          <div role="option" data-value="30" aria-selected="${minute === '30' ? 'true' : 'false'}">30</div>
        </div>
      </div>
    `
  }

  describe('connect', () => {
    it('dispatches "combobox-time:selected" with the initial 24h value (12h mode)', async () => {
      const handler = vi.fn()
      document.addEventListener('combobox-time:selected', handler)
      setup12h('10', '30', 'AM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(handler).toHaveBeenCalledOnce()
      expect(handler.mock.calls[0][0].detail.value).toBe('10:30')
      document.removeEventListener('combobox-time:selected', handler)
    })

    it('dispatches "combobox-time:selected" with the initial value (24h mode)', async () => {
      const handler = vi.fn()
      document.addEventListener('combobox-time:selected', handler)
      setup24h('10', '30')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(handler).toHaveBeenCalledOnce()
      expect(handler.mock.calls[0][0].detail.value).toBe('10:30')
      document.removeEventListener('combobox-time:selected', handler)
    })

    it('does not dispatch when hour or minute is unselected', async () => {
      const handler = vi.fn()
      document.addEventListener('combobox-time:selected', handler)
      document.body.innerHTML = `
        <div data-controller="combobox-time">
          <div data-combobox-time-target="hour" role="listbox">
            <div role="option" data-value="10" aria-selected="false">10</div>
          </div>
          <div data-combobox-time-target="minute" role="listbox">
            <div role="option" data-value="30" aria-selected="false">30</div>
          </div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(handler).not.toHaveBeenCalled()
      document.removeEventListener('combobox-time:selected', handler)
    })
  })

  describe('toH24 (24h mode — no period target)', () => {
    beforeEach(async () => {
      setup24h('10', '30')
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('returns HH:MM string', () => {
      expect(getController().toH24()).toBe('10:30')
    })

    it('returns null when no hour is selected', () => {
      document
        .querySelectorAll('[data-combobox-time-target="hour"] [role="option"]')
        .forEach((o) => o.setAttribute('aria-selected', 'false'))
      expect(getController().toH24()).toBeNull()
    })

    it('returns null when no minute is selected', () => {
      document
        .querySelectorAll('[data-combobox-time-target="minute"] [role="option"]')
        .forEach((o) => o.setAttribute('aria-selected', 'false'))
      expect(getController().toH24()).toBeNull()
    })
  })

  describe('toH24 (12h mode — with period target)', () => {
    it('converts 12 AM to 00:mm', async () => {
      setup12h('12', '00', 'AM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(getController().toH24()).toBe('00:00')
    })

    it('converts 10 AM to 10:mm', async () => {
      setup12h('10', '30', 'AM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(getController().toH24()).toBe('10:30')
    })

    it('converts 12 PM to 12:mm', async () => {
      setup12h('12', '00', 'PM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(getController().toH24()).toBe('12:00')
    })

    it('converts 10 PM to 22:mm', async () => {
      setup12h('10', '30', 'PM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(getController().toH24()).toBe('22:30')
    })

    it('converts 11 PM to 23:mm', async () => {
      setup12h('11', '45', 'PM')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(getController().toH24()).toBe('23:45')
    })
  })

  describe('onSelect', () => {
    beforeEach(async () => {
      setup12h('10', '30', 'AM')
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('marks the clicked option as aria-selected="true"', () => {
      const option = document.querySelector('[data-combobox-time-target="hour"] [data-value="11"]')
      option.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      getController().onSelect({ target: option })
      expect(option.getAttribute('aria-selected')).toBe('true')
    })

    it('clears aria-selected on sibling options in the same drum', () => {
      const option = document.querySelector('[data-combobox-time-target="hour"] [data-value="11"]')
      getController().onSelect({ target: option })
      expect(
        document.querySelector('[data-combobox-time-target="hour"] [data-value="10"]').getAttribute('aria-selected')
      ).toBe('false')
    })

    it('dispatches "combobox-time:selected" after selection', () => {
      const handler = vi.fn()
      document
        .querySelector('[data-controller="combobox-time"]')
        .addEventListener('combobox-time:selected', handler)
      const option = document.querySelector('[data-combobox-time-target="minute"] [data-value="45"]')
      getController().onSelect({ target: option })
      expect(handler).toHaveBeenCalledOnce()
    })

    it('does nothing when event target is not inside an option', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'select')
      ctrl.onSelect({ target: document.querySelector('[data-controller="combobox-time"]') })
      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('onNavigate', () => {
    beforeEach(async () => {
      setup24h('10', '30')
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('calls step with delta=1 on ArrowDown', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'step')
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      const event = new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true })
      Object.defineProperty(event, 'currentTarget', { value: drum })
      ctrl.onNavigate(event)
      expect(spy).toHaveBeenCalledWith(drum, 1)
    })

    it('calls step with delta=-1 on ArrowUp', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'step')
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      const event = new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true, cancelable: true })
      Object.defineProperty(event, 'currentTarget', { value: drum })
      ctrl.onNavigate(event)
      expect(spy).toHaveBeenCalledWith(drum, -1)
    })

    it('prevents default on arrow keys', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      const event = new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true })
      Object.defineProperty(event, 'currentTarget', { value: drum })
      const spy = vi.spyOn(event, 'preventDefault')
      getController().onNavigate(event)
      expect(spy).toHaveBeenCalled()
    })

    it('ignores unrelated keys', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'step')
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      const event = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
      Object.defineProperty(event, 'currentTarget', { value: drum })
      ctrl.onNavigate(event)
      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('step', () => {
    beforeEach(async () => {
      setup24h('10', '30')
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('advances to the next option in the drum', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      getController().step(drum, 1)
      expect(drum.querySelector('[data-value="14"]').getAttribute('aria-selected')).toBe('true')
      expect(drum.querySelector('[data-value="10"]').getAttribute('aria-selected')).toBe('false')
    })

    it('moves to the previous option in the drum', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      getController().step(drum, -1)
      expect(drum.querySelector('[data-value="09"]').getAttribute('aria-selected')).toBe('true')
      expect(drum.querySelector('[data-value="10"]').getAttribute('aria-selected')).toBe('false')
    })

    it('does not advance past the last option', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      drum.querySelector('[data-value="10"]').setAttribute('aria-selected', 'false')
      drum.querySelector('[data-value="14"]').setAttribute('aria-selected', 'true')
      getController().step(drum, 1)
      expect(drum.querySelector('[data-value="14"]').getAttribute('aria-selected')).toBe('true')
    })

    it('does not go before the first option', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      drum.querySelector('[data-value="10"]').setAttribute('aria-selected', 'false')
      drum.querySelector('[data-value="09"]').setAttribute('aria-selected', 'true')
      getController().step(drum, -1)
      expect(drum.querySelector('[data-value="09"]').getAttribute('aria-selected')).toBe('true')
    })

    it('dispatches "combobox-time:selected" after stepping', () => {
      const handler = vi.fn()
      document
        .querySelector('[data-controller="combobox-time"]')
        .addEventListener('combobox-time:selected', handler)
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      getController().step(drum, 1)
      expect(handler).toHaveBeenCalledOnce()
    })

    it('calls scrollIntoView on the newly selected option', () => {
      const drum = document.querySelector('[data-combobox-time-target="hour"]')
      getController().step(drum, 1)
      expect(Element.prototype.scrollIntoView).toHaveBeenCalledWith({ block: 'nearest' })
    })
  })
})
