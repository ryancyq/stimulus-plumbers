import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InputSearchController from '../../../src/controllers/input_search_controller'

describe('InputSearchController', () => {
  let application

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-search"]'),
      'input-search'
    )

  const setup = async (html) => {
    document.body.innerHTML = html
    await new Promise((resolve) => setTimeout(resolve, 10))
  }

  beforeEach(() => {
    application = Application.start()
    application.register('input-search', InputSearchController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  describe('connect — empty input', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search">
          <input type="search" value="" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('hides the clear button when input is empty', () => {
      expect(document.querySelector('[data-input-search-target="clear"]').hidden).toBe(true)
    })
  })

  describe('connect — pre-filled input', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search">
          <input type="search" value="rails" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('shows the clear button when input has a value', () => {
      expect(document.querySelector('[data-input-search-target="clear"]').hidden).toBe(false)
    })
  })

  describe('input event', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search"
             data-action="input->input-search#draw">
          <input type="search" value="" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('shows the clear button when input receives a value', async () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      input.value = 'hello'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-input-search-target="clear"]').hidden).toBe(false)
    })

    it('hides the clear button when input is cleared', async () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      input.value = 'hello'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      await new Promise((resolve) => setTimeout(resolve, 10))

      input.value = ''
      input.dispatchEvent(new Event('input', { bubbles: true }))
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-input-search-target="clear"]').hidden).toBe(true)
    })
  })

  describe('clear()', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search">
          <input type="search" value="hello" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('sets input value to empty string', () => {
      getController().clear()
      expect(document.querySelector('[data-input-search-target="input"]').value).toBe('')
    })

    it('hides the clear button', () => {
      getController().clear()
      expect(document.querySelector('[data-input-search-target="clear"]').hidden).toBe(true)
    })

    it('dispatches a bubbling input event on the input element', () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      const spy = vi.fn()
      document.body.addEventListener('input', spy)
      getController().clear()
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].target).toBe(input)
    })

    it('returns focus to the input', () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      getController().clear()
      expect(document.activeElement).toBe(input)
    })
  })

  describe('Escape key', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search">
          <input type="search" value="hello" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('clears the input when Escape is pressed with a value', () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
      input.dispatchEvent(event)
      expect(input.value).toBe('')
      expect(event.defaultPrevented).toBe(true)
    })

    it('does nothing when Escape is pressed on an empty input', () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      input.value = ''
      const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
      input.dispatchEvent(event)
      expect(event.defaultPrevented).toBe(false)
    })

    it('ignores non-Escape keys', () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      const event = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
      input.dispatchEvent(event)
      expect(input.value).toBe('hello')
    })
  })

  describe('missing targets', () => {
    beforeEach(async () => {
      await setup(`<div data-controller="input-search"></div>`)
    })

    it('does not throw on connect when targets are absent', () => {
      expect(() => getController().draw()).not.toThrow()
    })

    it('does not throw when clear() is called without targets', () => {
      expect(() => getController().clear()).not.toThrow()
    })
  })

  describe('inputTargetDisconnected', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-search">
          <input type="search" value="" data-input-search-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-search-target="clear"
                  data-action="click->input-search#clear">
          </button>
        </div>
      `)
    })

    it('removes input and keydown listeners when input target disconnects', async () => {
      const input = document.querySelector('[data-input-search-target="input"]')
      const spy = vi.spyOn(input, 'removeEventListener')

      input.remove()
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(spy).toHaveBeenCalledWith('input', expect.any(Function))
      expect(spy).toHaveBeenCalledWith('keydown', expect.any(Function))
    })
  })
})
