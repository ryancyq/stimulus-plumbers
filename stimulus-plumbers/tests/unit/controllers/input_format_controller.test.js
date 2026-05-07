import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputFormatController from '../../../src/controllers/input_format_controller'

describe('InputFormatController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('input-format', InputFormatController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-format"]'),
      'input-format'
    )

  describe('plain type (default) — non-input display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format">
          <output data-input-format-target="input">hello</output>
          <button data-action="input-format#toggle" data-input-format-target="toggle">Toggle</button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('attaches inputFormat on connect', () => {
      expect(getController().inputFormat).toBeDefined()
    })

    it('hides the toggle button for non-maskable types', () => {
      expect(document.querySelector('[data-input-format-target="toggle"]').hidden).toBe(true)
    })

    it('renders existing textContent as the formatted value', () => {
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe('hello')
    })

    it('format(value) writes formatted value to the input target', async () => {
      getController().format('world')
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe('world')
    })

    it('onChange(event) writes event.detail.value to the input target', () => {
      getController().onChange({ detail: { value: 'world' } })
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe('world')
    })

    it('dispatches input-format:formatted after writing', () => {
      const el  = document.querySelector('[data-controller="input-format"]')
      const spy = vi.fn()
      el.addEventListener('input-format:formatted', spy)
      getController().format('x')
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.value).toBe('x')
    })

    it('toggle is a no-op for plain type', async () => {
      expect(getController().revealedValue).toBe(false)
      await getController().toggle()
      expect(getController().revealedValue).toBe(false)
    })
  })

  describe('plain type — <input> display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format">
          <input type="text" value="initial" data-input-format-target="input">
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('reads existing .value on connect and writes it back formatted', () => {
      expect(document.querySelector('[data-input-format-target="input"]').value).toBe('initial')
    })

    it('format(value) writes to .value on <input> targets', () => {
      getController().format('updated')
      expect(document.querySelector('[data-input-format-target="input"]').value).toBe('updated')
    })
  })

  describe('creditCard type', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="creditCard">
          <output data-input-format-target="input">4242424242424242</output>
          <button data-action="input-format#toggle" data-input-format-target="toggle">Toggle</button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('formats the initial value on connect', () => {
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

    it('hides the toggle button (not maskable)', () => {
      expect(document.querySelector('[data-input-format-target="toggle"]').hidden).toBe(true)
    })
  })

  describe('password type', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="password">
          <input type="password" data-input-format-target="input">
          <button data-action="input-format#toggle" data-input-format-target="toggle">Show</button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('input starts as type password', () => {
      expect(document.querySelector('[data-input-format-target="input"]').type).toBe('password')
    })

    it('changes input type to text on toggle', async () => {
      await getController().toggle()
      expect(document.querySelector('[data-input-format-target="input"]').type).toBe('text')
    })

    it('reverts input type back to password on second toggle', async () => {
      await getController().toggle()
      await getController().toggle()
      expect(document.querySelector('[data-input-format-target="input"]').type).toBe('password')
    })
  })

  describe('sync without input target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `<div data-controller="input-format"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('dispatches formatted event even with no input target', () => {
      const el  = document.querySelector('[data-controller="input-format"]')
      const spy = vi.fn()
      el.addEventListener('input-format:formatted', spy)
      getController().format('test')
      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('does not throw when no input target', () => {
      expect(() => getController().format('test')).not.toThrow()
    })
  })
})
