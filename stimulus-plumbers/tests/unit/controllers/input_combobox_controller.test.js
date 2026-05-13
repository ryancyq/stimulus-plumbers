import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputComboboxController from '../../../src/controllers/input_combobox_controller'

describe('InputComboboxController', () => {
  let application

  beforeEach(async () => {
    application = Application.start()
    application.register('input-combobox', InputComboboxController)

    document.body.innerHTML = `
      <div data-controller="input-combobox">
        <input type="text" data-input-combobox-target="trigger"
               role="combobox" aria-expanded="false" aria-haspopup="dialog">
        <input type="hidden" data-input-combobox-target="value">
        <div data-input-combobox-target="popover" hidden>
          <button id="first-focusable">Pick</button>
        </div>
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-combobox"]'),
      'input-combobox'
    )

  describe('open', () => {
    it('shows the popover', () => {
      getController().open()
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(false)
    })

    it('sets aria-expanded to true on the trigger', () => {
      getController().open()
      expect(
        document.querySelector('[data-input-combobox-target="trigger"]').getAttribute('aria-expanded')
      ).toBe('true')
    })

    it('moves focus to the first focusable element inside the popover', () => {
      getController().open()
      expect(document.activeElement).toBe(document.getElementById('first-focusable'))
    })

    it('does not throw when popover target is absent', async () => {
      document.body.innerHTML = `<div data-controller="input-combobox"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))
      const ctrl = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="input-combobox"]'),
        'input-combobox'
      )
      expect(() => ctrl.open()).not.toThrow()
    })
  })

  describe('close', () => {
    beforeEach(() => getController().open())

    it('hides the popover', () => {
      getController().close()
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(true)
    })

    it('sets aria-expanded to false on the trigger', () => {
      getController().close()
      expect(
        document.querySelector('[data-input-combobox-target="trigger"]').getAttribute('aria-expanded')
      ).toBe('false')
    })

    it('returns focus to the trigger', () => {
      getController().close()
      expect(document.activeElement).toBe(
        document.querySelector('[data-input-combobox-target="trigger"]')
      )
    })
  })

  describe('toggle', () => {
    it('opens when popover is hidden', () => {
      getController().toggle()
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(false)
    })

    it('closes when popover is visible', () => {
      getController().open()
      getController().toggle()
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(true)
    })
  })

  describe('onSelect', () => {
    it('writes event.detail.value to the value target', async () => {
      getController().open()
      getController().onSelect({ detail: { value: '2024-03-15' } })
      await new Promise((r) => setTimeout(r, 10))
      expect(document.querySelector('[data-input-combobox-target="value"]').value).toBe('2024-03-15')
    })

    it('closes the popover after selection', () => {
      getController().open()
      getController().onSelect({ detail: { value: 'us' } })
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(true)
    })

    it('returns focus to trigger after selection', () => {
      getController().open()
      getController().onSelect({ detail: { value: 'us' } })
      expect(document.activeElement).toBe(
        document.querySelector('[data-input-combobox-target="trigger"]')
      )
    })
  })

  describe('valueValueChanged', () => {
    it('dispatches input-combobox:changed with the new value', async () => {
      const el  = document.querySelector('[data-controller="input-combobox"]')
      const spy = vi.fn()
      el.addEventListener('input-combobox:changed', spy)
      getController().valueValue = 'hello'
      await new Promise((r) => setTimeout(r, 10))
      expect(spy).toHaveBeenCalled()
      expect(spy.mock.calls[spy.mock.calls.length - 1][0].detail.value).toBe('hello')
    })

    it('syncs value to the value target', async () => {
      getController().valueValue = 'abc'
      await new Promise((r) => setTimeout(r, 10))
      expect(document.querySelector('[data-input-combobox-target="value"]').value).toBe('abc')
    })
  })

  describe('onInput', () => {
    const mockOutlet = () => ({ showAll: vi.fn(), filter: vi.fn() })

    function wireOutlet(ctrl, outlet) {
      Object.defineProperty(ctrl, 'hasComboboxDropdownOutlet', { get: () => true, configurable: true })
      Object.defineProperty(ctrl, 'comboboxDropdownOutlet', { get: () => outlet, configurable: true })
    }

    it('ignores input events from elements other than the trigger', () => {
      const outlet = mockOutlet()
      wireOutlet(getController(), outlet)

      const other = document.createElement('input')
      other.value = 'something'
      getController().onInput({ target: other })

      expect(outlet.showAll).not.toHaveBeenCalled()
      expect(outlet.filter).not.toHaveBeenCalled()
    })

    it('calls showAll when query is shorter than minLength', () => {
      const outlet = mockOutlet()
      wireOutlet(getController(), outlet)

      const trigger = document.querySelector('[data-input-combobox-target="trigger"]')
      trigger.value = '' // length 0 < default minLength 1
      getController().onInput({ target: trigger })

      expect(outlet.showAll).toHaveBeenCalledOnce()
      expect(outlet.filter).not.toHaveBeenCalled()
    })

    it('calls filter(query) when query meets minLength', () => {
      const outlet = mockOutlet()
      wireOutlet(getController(), outlet)

      const trigger = document.querySelector('[data-input-combobox-target="trigger"]')
      trigger.value = 'abc'
      getController().onInput({ target: trigger })

      expect(outlet.filter).toHaveBeenCalledWith('abc')
      expect(outlet.showAll).not.toHaveBeenCalled()
    })

    it('does not throw when below minLength and no outlet is connected', () => {
      const trigger = document.querySelector('[data-input-combobox-target="trigger"]')
      trigger.value = ''
      expect(() => getController().onInput({ target: trigger })).not.toThrow()
    })

    it('does not throw when above minLength and no outlet is connected', () => {
      const trigger = document.querySelector('[data-input-combobox-target="trigger"]')
      trigger.value = 'hello'
      expect(() => getController().onInput({ target: trigger })).not.toThrow()
    })
  })

  describe('close — no trigger target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-combobox">
          <div data-input-combobox-target="popover">
            <button>Pick</button>
          </div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('hides the popover without throwing when trigger target is absent', () => {
      const ctrl = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="input-combobox"]'),
        'input-combobox'
      )
      ctrl.open()
      expect(() => ctrl.close()).not.toThrow()
      expect(document.querySelector('[data-input-combobox-target="popover"]').hidden).toBe(true)
    })
  })
})
