import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputFormatterController from '../../../src/controllers/input_formatter_controller'

describe('InputFormatterController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('input-formatter', InputFormatterController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-formatter"]'),
      'input-formatter'
    )

  describe('plain type (default) — non-input display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter">
          <output data-input-formatter-target="input">hello</output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('attaches formatter on connect', () => {
      expect(getController().formatter).toBeDefined()
    })

    it('renders existing textContent as the formatted value', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('hello')
    })

    it('format(value) writes formatted value to the input target', async () => {
      getController().format('world')
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('world')
    })

    it('onChange(event) writes event.detail.value to the input target', () => {
      getController().onChange({ detail: { value: 'world' } })
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe('world')
    })

    it('dispatches input-formatter:formatted after writing', () => {
      const el  = document.querySelector('[data-controller="input-formatter"]')
      const spy = vi.fn()
      el.addEventListener('input-formatter:formatted', spy)
      getController().format('x')
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.value).toBe('x')
    })

  })

  describe('plain type — <input> display target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter">
          <input type="text" value="initial" data-input-formatter-target="input">
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('reads existing .value on connect and writes it back formatted', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').value).toBe('initial')
    })

    it('format(value) writes to .value on <input> targets', () => {
      getController().format('updated')
      expect(document.querySelector('[data-input-formatter-target="input"]').value).toBe('updated')
    })
  })

  describe('creditCard type', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <output data-input-formatter-target="input">4242424242424242</output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('formats the initial value on connect', () => {
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

  })

  describe('sync without input target', () => {
    beforeEach(async () => {
      document.body.innerHTML = `<div data-controller="input-formatter"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('dispatches formatted event even with no input target', () => {
      const el  = document.querySelector('[data-controller="input-formatter"]')
      const spy = vi.fn()
      el.addEventListener('input-formatter:formatted', spy)
      getController().format('test')
      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('does not throw when no input target', () => {
      expect(() => getController().format('test')).not.toThrow()
    })
  })

  describe('formatValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="plain">
          <output data-input-formatter-target="input">4242424242424242</output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('re-attaches the formatter when typeValue changes', async () => {
      const el = document.querySelector('[data-controller="input-formatter"]')
      el.setAttribute('data-input-formatter-format-value', 'creditCard')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

  })

  describe('optionsValueChanged', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="currency"
             data-input-formatter-options-value='{"currency":"USD"}'>
          <output data-input-formatter-target="input">1234.56</output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('re-formats when optionsValue changes', async () => {
      const el = document.querySelector('[data-controller="input-formatter"]')
      el.setAttribute('data-input-formatter-options-value', JSON.stringify({ currency: 'EUR', locale: 'de-DE' }))
      await new Promise((resolve) => setTimeout(resolve, 10))
      const text = document.querySelector('[data-input-formatter-target="input"]').textContent
      expect(text).toContain('1')
      expect(text.length).toBeGreaterThan(0)
    })
  })

  describe('onPaste', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <output data-input-formatter-target="input"></output>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('normalizes and formats a valid pasted value', () => {
      getController().onPaste({ detail: { text: '4242424242424242' } })
      expect(document.querySelector('[data-input-formatter-target="input"]').textContent).toBe(
        '4242 4242 4242 4242'
      )
    })

    it('does not write when the normalized value fails validation', () => {
      const output = document.querySelector('[data-input-formatter-target="input"]')
      output.textContent = 'original'
      getController().onPaste({ detail: { text: 'not-a-card' } })
      expect(output.textContent).toBe('original')
    })

    it('does not write when pasted text is empty', () => {
      const output = document.querySelector('[data-input-formatter-target="input"]')
      output.textContent = 'original'
      getController().onPaste({ detail: { text: '' } })
      expect(output.textContent).toBe('original')
    })

    it('does not throw when there is no formatter', async () => {
      document.body.innerHTML = `<div data-controller="input-formatter"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(() =>
        getController().onPaste({ detail: { text: '4242424242424242' } })
      ).not.toThrow()
    })
  })

  describe('code type with cells', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          ${'<div data-input-formatter-target="cell"></div>'.repeat(6)}
          <input data-input-formatter-target="input"
                 data-action="input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
    const input = () => document.querySelector('[data-input-formatter-target="input"]')

    it('attaches characterCells on connect', () => {
      expect(getController().characterCells).toBeDefined()
    })

    it('stamps aria-hidden on cells', () => {
      cells().forEach((cell) => expect(cell.getAttribute('aria-hidden')).toBe('true'))
    })

    it('paints typed characters into cells on input', () => {
      input().value = '482'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells().map((cell) => cell.textContent)).toEqual(['4', '8', '2', '', '', ''])
    })

    it('clears previously painted cells when switching to a formatter with no cells hint', async () => {
      input().value = '1234'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells().map((cell) => cell.textContent)).toEqual(['1', '2', '3', '4', '', ''])

      document
        .querySelector('[data-controller="input-formatter"]')
        .setAttribute('data-input-formatter-format-value', 'plain')
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(cells().map((cell) => cell.textContent).join('')).toBe('')
      expect(getController().characterCells).toBeUndefined()
    })

    it('filters non-charset characters and writes back to the input', () => {
      input().value = '4 8-29 13'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(input().value).toBe('482913')
    })

    it('dispatches input-formatter:filled at configured length', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '482913'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: '482913' })
    })

    it('does not dispatch filled below configured length', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '4829'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).not.toHaveBeenCalled()
    })

    it('shows the caret cell only while focused', () => {
      input().value = '48'
      input().focus()
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells()[2].hasAttribute('data-caret')).toBe(true)
      input().blur()
      expect(cells()[2].hasAttribute('data-caret')).toBe(false)
    })

    it('does not dispatch filled again when a 7th char is typed and truncated back to the same 6 chars', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '482913'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      input().value = '4829137'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('fires filled again after the value drops below length and is refilled', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '482913'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      input().value = '48291'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      input().value = '482913'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(2)
    })
  })

  describe('filled dispatch on connect with a prefilled value', () => {
    it('does not dispatch filled on connect even when the initial value is already full', async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          ${'<div data-input-formatter-target="cell"></div>'.repeat(6)}
          <input data-input-formatter-target="input" value="482913"
                 data-action="input->input-formatter#onInput" />
        </div>
      `
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('filled dispatch generalizes beyond the code formatter', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(16)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const input = () => document.querySelector('[data-input-formatter-target="input"]')

    it('dispatches filled for a valid creditCard value reaching its cells length', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '4242424242424242'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: '4242424242424242' })
    })
  })

  describe('creditCard type with cells', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(16)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('derives 4-4-4-4 grouping from the formatter hint', () => {
      const cells = [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
      expect(cells[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells[4].getAttribute('data-group-index')).toBe('1')
    })

    it('paints the canonical (unformatted) value into cells', () => {
      const input = document.querySelector('[data-input-formatter-target="input"]')
      input.value = '4242 4242'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      const cells = [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
      expect(cells.slice(0, 8).map((cell) => cell.textContent)).toEqual(['4', '2', '4', '2', '4', '2', '4', '2'])
    })
  })

  describe('creditCard type with cells — 19-digit card via groups override', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard"
             data-input-formatter-groups-value="[4,4,4,4,3]">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(19)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
    const input = () => document.querySelector('[data-input-formatter-target="input"]')

    it('paints all 19 digits, including the last 3 beyond the default 16-cell cap', () => {
      input().value = '1234567890123456785'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells().map((cell) => cell.textContent).join('')).toBe('1234567890123456785')
      expect(cells()[18].hasAttribute('data-inactive')).toBe(false)
    })

    it('dispatches filled once the full 19-digit valid number is entered', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '1234567890123456785'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
    })
  })

  describe('groups value override', () => {
    // 20 cells: more than the override's groups sum (15) and more than the formatter's
    // own hint length (16), so active()/warn behavior only matches the override sum
    // when length is correctly re-derived from it rather than the formatter's hint.
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard"
             data-input-formatter-groups-value="[4,6,5]">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(20)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]

    it('derives expected length from the override groups sum, not the formatter hint length', () => {
      expect(getController().characterCells.active()).toBe(15)
    })

    it('marks cells beyond the override sum as inactive, not just beyond the hint length', () => {
      expect(cells()[14].hasAttribute('data-inactive')).toBe(false)
      expect(cells()[15].hasAttribute('data-inactive')).toBe(true)
    })

    it('stamps group boundaries from the override, not the formatter hint', () => {
      expect(cells()[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells()[4].getAttribute('data-group-index')).toBe('1')
      expect(cells()[9].hasAttribute('data-group-end')).toBe(true)
      expect(cells()[10].getAttribute('data-group-index')).toBe('2')
    })

    it('re-derives grouping when groupsValue changes', async () => {
      const el = document.querySelector('[data-controller="input-formatter"]')
      el.setAttribute('data-input-formatter-groups-value', '[3,3,3,3,3]')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(cells()[2].hasAttribute('data-group-end')).toBe(true)
      expect(cells()[3].getAttribute('data-group-index')).toBe('1')
      expect(getController().characterCells.active()).toBe(15)
    })
  })

  describe('cells appended after connect (e.g. Turbo Stream/morph)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          <div class="cells-row">
            ${'<div data-input-formatter-target="cell"></div>'.repeat(4)}
          </div>
          <input data-input-formatter-target="input" value="482915"
                 data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]

    it('adopts (stamps aria-hidden on) a cell appended after connect', async () => {
      const newCell = document.createElement('div')
      newCell.setAttribute('data-input-formatter-target', 'cell')
      document.querySelector('.cells-row').appendChild(newCell)
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(newCell.getAttribute('aria-hidden')).toBe('true')
    })

    it('extends active() to include cells appended after connect', async () => {
      const row = document.querySelector('.cells-row')
      const a = document.createElement('div')
      a.setAttribute('data-input-formatter-target', 'cell')
      const b = document.createElement('div')
      b.setAttribute('data-input-formatter-target', 'cell')
      row.appendChild(a)
      row.appendChild(b)
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(cells().length).toBe(6)
      expect(getController().characterCells.active()).toBe(6)
    })

    it('paints the current value into a cell appended after connect', async () => {
      const row = document.querySelector('.cells-row')
      const newCell = document.createElement('div')
      newCell.setAttribute('data-input-formatter-target', 'cell')
      row.appendChild(newCell)
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(newCell.textContent).toBe('1')
    })
  })

  describe('creditCard type with 4 grouped cells (one cell per group)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(4)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
    const input = () => document.querySelector('[data-input-formatter-target="input"]')

    it('paints a 4-digit chunk per cell', () => {
      input().value = '4242424242424242'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells().map((cell) => cell.textContent)).toEqual(['4242', '4242', '4242', '4242'])
    })

    it('dispatches filled once the full 16-digit value is entered', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '4242424242424242'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
    })

    it('does not dispatch filled below 16 digits', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '424242'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('without cell targets (regression)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <input data-input-formatter-target="input" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('does not attach characterCells', () => {
      expect(getController().characterCells).toBeUndefined()
    })
  })
})
