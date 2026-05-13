import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputFormatController from '../../../src/controllers/input_format_controller'
import { InputFormat } from '../../../src/plumbers/input_format'

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

  describe('typeValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="plain">
          <output data-input-format-target="input">4242424242424242</output>
          <button data-action="input-format#toggle" data-input-format-target="toggle">Toggle</button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('re-attaches the formatter when typeValue changes', async () => {
      const el = document.querySelector('[data-controller="input-format"]')
      el.setAttribute('data-input-format-type-value', 'creditCard')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

    it('keeps toggle hidden for non-maskable types after change', async () => {
      const el = document.querySelector('[data-controller="input-format"]')
      el.setAttribute('data-input-format-type-value', 'creditCard')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-input-format-target="toggle"]').hidden).toBe(true)
    })
  })

  describe('optionsValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="currency"
             data-input-format-options-value='{"currency":"USD"}'>
          <output data-input-format-target="input">1234.56</output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('re-formats when optionsValue changes', async () => {
      const el = document.querySelector('[data-controller="input-format"]')
      el.setAttribute('data-input-format-options-value', JSON.stringify({ currency: 'EUR', locale: 'de-DE' }))
      await new Promise((resolve) => setTimeout(resolve, 10))
      const text = document.querySelector('[data-input-format-target="input"]').textContent
      expect(text).toContain('1')
      expect(text.length).toBeGreaterThan(0)
    })
  })

  describe('onPaste', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="creditCard">
          <output data-input-format-target="input"></output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('normalizes and formats a valid pasted value', () => {
      getController().onPaste({ detail: { text: '4242424242424242' } })
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

    it('does not write when the normalized value fails validation', () => {
      const output = document.querySelector('[data-input-format-target="input"]')
      output.textContent = 'original'
      getController().onPaste({ detail: { text: 'not-a-card' } })
      expect(output.textContent).toBe('original')
    })

    it('does not write when pasted text is empty', () => {
      const output = document.querySelector('[data-input-format-target="input"]')
      output.textContent = 'original'
      getController().onPaste({ detail: { text: '' } })
      expect(output.textContent).toBe('original')
    })

    it('does not throw when there is no inputFormat', async () => {
      document.body.innerHTML = `<div data-controller="input-format"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(() =>
        getController().onPaste({ detail: { text: '4242424242424242' } })
      ).not.toThrow()
    })
  })

  describe('maskable type — custom formatter', () => {
    beforeEach(async () => {
      InputFormat.register('secret', {
        normalize: (raw) => (typeof raw === 'string' ? raw : ''),
        validate: () => true,
        format: (value) => value,
        mask: (value) => value.replace(/./g, '*'),
      })

      document.body.innerHTML = `
        <div data-controller="input-format" data-input-format-type-value="secret">
          <output data-input-format-target="input">hello</output>
          <button data-action="input-format#toggle" data-input-format-target="toggle">Toggle</button>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('shows the toggle button for maskable types', () => {
      expect(document.querySelector('[data-input-format-target="toggle"]').hidden).toBe(false)
    })

    it('writes the masked value when revealed is false', () => {
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe('*****')
    })

    it('writes the formatted value when revealed is true', async () => {
      getController().toggle()
      await new Promise((resolve) => setTimeout(resolve, 10))
      // With revealedValue=true, format() calls format() instead of mask()
      getController().format('hello')
      expect(document.querySelector('[data-input-format-target="input"]').textContent).toBe('hello')
    })

    it('sets aria-pressed on the toggle button', () => {
      const toggle = document.querySelector('[data-input-format-target="toggle"]')
      expect(toggle.getAttribute('aria-pressed')).toBe('false')
    })
  })
})
