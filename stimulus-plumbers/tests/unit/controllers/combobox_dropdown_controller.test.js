import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ComboboxDropdownController from '../../../src/controllers/combobox_dropdown_controller'

describe('ComboboxDropdownController', () => {
  let application

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="combobox-dropdown"]'),
      'combobox-dropdown'
    )

  beforeEach(() => {
    application = Application.start()
    application.register('combobox-dropdown', ComboboxDropdownController)
    Element.prototype.scrollIntoView = vi.fn()
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.restoreAllMocks()
  })

  describe('select', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a" aria-selected="false">Option A</li>
            <li role="option" data-value="b" aria-selected="false">Option B</li>
            <li role="option" data-value="c" aria-selected="false">Option C</li>
          </ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('marks the matching option as aria-selected="true"', () => {
      getController().select('b')
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('true')
    })

    it('sets all other options to aria-selected="false"', () => {
      getController().select('b')
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('false')
      expect(document.querySelector('[data-value="c"]').getAttribute('aria-selected')).toBe('false')
    })

    it('dispatches "combobox-dropdown:selected" with the value', () => {
      const handler = vi.fn()
      document
        .querySelector('[data-controller="combobox-dropdown"]')
        .addEventListener('combobox-dropdown:selected', handler)
      getController().select('a')
      expect(handler).toHaveBeenCalledOnce()
      expect(handler.mock.calls[0][0].detail.value).toBe('a')
    })

    it('dispatches selected event even when value has no matching option', () => {
      const handler = vi.fn()
      document
        .querySelector('[data-controller="combobox-dropdown"]')
        .addEventListener('combobox-dropdown:selected', handler)
      getController().select('z')
      expect(handler).toHaveBeenCalledOnce()
      expect(handler.mock.calls[0][0].detail.value).toBe('z')
    })
  })

  describe('onSelect', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown" data-action="click->combobox-dropdown#onSelect">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a" aria-selected="false">Option A</li>
            <li role="option" data-value="b" aria-selected="true">Option B</li>
            <li role="option" data-value="disabled" aria-selected="false" aria-disabled="true">Disabled</li>
          </ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('selects the clicked option', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'select')
      document.querySelector('[data-value="a"]').click()
      expect(spy).toHaveBeenCalledWith('a')
    })

    it('ignores clicks on disabled options', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'select')
      document.querySelector('[data-value="disabled"]').click()
      expect(spy).not.toHaveBeenCalled()
    })

    it('ignores clicks not on an option element', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'select')
      document.querySelector('[role="listbox"]').click()
      expect(spy).not.toHaveBeenCalled()
    })

    it('falls back to empty string when option has no data-value attribute', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'select')
      const li = document.createElement('li')
      li.setAttribute('role', 'option')
      document.querySelector('[role="listbox"]').appendChild(li)
      li.click()
      expect(spy).toHaveBeenCalledWith('')
    })
  })

  describe('onNavigate', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a" aria-selected="true">Option A</li>
            <li role="option" data-value="b" aria-selected="false">Option B</li>
            <li role="option" data-value="c" aria-selected="false">Option C</li>
          </ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('moves selection down on ArrowDown', () => {
      const event = new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true })
      getController().onNavigate(event)
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('true')
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('false')
    })

    it('moves selection up on ArrowUp', () => {
      document.querySelector('[data-value="a"]').setAttribute('aria-selected', 'false')
      document.querySelector('[data-value="b"]').setAttribute('aria-selected', 'true')
      const event = new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true, cancelable: true })
      getController().onNavigate(event)
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('true')
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('false')
    })

    it('clicks the selected option on Enter', () => {
      const option = document.querySelector('[data-value="a"]')
      option.setAttribute('aria-selected', 'true')
      const clickSpy = vi.spyOn(option, 'click')
      const event = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })
      getController().onNavigate(event)
      expect(clickSpy).toHaveBeenCalled()
    })

    it('clicks the selected option on Space', () => {
      const option = document.querySelector('[data-value="a"]')
      option.setAttribute('aria-selected', 'true')
      const clickSpy = vi.spyOn(option, 'click')
      const event = new KeyboardEvent('keydown', { key: ' ', bubbles: true, cancelable: true })
      getController().onNavigate(event)
      expect(clickSpy).toHaveBeenCalled()
    })

    it('prevents default on navigation keys', () => {
      const event = new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true })
      const spy = vi.spyOn(event, 'preventDefault')
      getController().onNavigate(event)
      expect(spy).toHaveBeenCalled()
    })

    it('ignores unrelated keys', () => {
      const ctrl = getController()
      const spy = vi.spyOn(ctrl, 'step')
      const event = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true, cancelable: true })
      getController().onNavigate(event)
      expect(spy).not.toHaveBeenCalled()
    })
  })

  describe('step', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a" aria-selected="true">Option A</li>
            <li role="option" data-value="b" aria-selected="false">Option B</li>
            <li role="option" data-value="c" aria-selected="false" aria-disabled="true">Disabled C</li>
          </ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('advances selection forward', () => {
      getController().step(1)
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('true')
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('false')
    })

    it('does not advance past the last enabled option', () => {
      document.querySelector('[data-value="a"]').setAttribute('aria-selected', 'false')
      document.querySelector('[data-value="b"]').setAttribute('aria-selected', 'true')
      getController().step(1)
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('true')
    })

    it('does not go before the first option', () => {
      getController().step(-1)
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('true')
    })

    it('skips disabled options', () => {
      document.querySelector('[data-value="a"]').setAttribute('aria-selected', 'false')
      document.querySelector('[data-value="b"]').setAttribute('aria-selected', 'true')
      getController().step(1)
      // c is disabled, so b stays selected
      expect(document.querySelector('[data-value="b"]').getAttribute('aria-selected')).toBe('true')
    })

    it('skips hidden options', () => {
      document.querySelector('[data-value="b"]').hidden = true
      getController().step(1)
      // b is hidden, only a is enabled — a stays selected
      expect(document.querySelector('[data-value="a"]').getAttribute('aria-selected')).toBe('true')
    })
  })

  describe('step (empty listbox)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('does nothing when there are no enabled visible options', () => {
      expect(() => getController().step(1)).not.toThrow()
      expect(() => getController().step(-1)).not.toThrow()
    })
  })

  describe('filter (local fuzzy)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="apple">Apple</li>
            <li role="option" data-value="banana">Banana</li>
            <li role="option" data-value="apricot">Apricot</li>
          </ul>
          <div data-combobox-dropdown-target="empty" hidden>No results</div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('hides non-matching options', () => {
      getController().filter('ban')
      expect(document.querySelector('[data-value="banana"]').hidden).toBe(false)
      expect(document.querySelector('[data-value="apple"]').hidden).toBe(true)
      expect(document.querySelector('[data-value="apricot"]').hidden).toBe(true)
    })

    it('shows the empty target when no options match', () => {
      getController().filter('xyz')
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(false)
    })

    it('keeps the empty target hidden when options match', () => {
      getController().filter('app')
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(true)
    })
  })

  describe('showAll', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a" hidden>Option A</li>
            <li role="option" data-value="b" hidden>Option B</li>
          </ul>
          <div data-combobox-dropdown-target="empty">No results</div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('makes all options visible', () => {
      getController().showAll()
      expect(document.querySelector('[data-value="a"]').hidden).toBe(false)
      expect(document.querySelector('[data-value="b"]').hidden).toBe(false)
    })

    it('hides the empty state target', () => {
      getController().showAll()
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(true)
    })
  })

  describe('setLoading', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
          <div data-combobox-dropdown-target="loading" hidden>Loading...</div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('shows the loading target when true', () => {
      getController().setLoading(true)
      expect(document.querySelector('[data-combobox-dropdown-target="loading"]').hidden).toBe(false)
    })

    it('hides the loading target when false', () => {
      getController().setLoading(false)
      expect(document.querySelector('[data-combobox-dropdown-target="loading"]').hidden).toBe(true)
    })

    it('does not throw when loading target is absent', async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(() => getController().setLoading(true)).not.toThrow()
    })
  })

  describe('filter (remote URL)', () => {
    const flushPromises = () => new Promise((r) => setTimeout(r, 0))
    let mockRequestor

    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown"
             data-combobox-dropdown-url-value="http://example.com/options"
             data-combobox-dropdown-delay-value="0">
          <ul data-combobox-dropdown-target="listbox" role="listbox">
            <li role="option" data-value="a">Option A</li>
          </ul>
          <div data-combobox-dropdown-target="loading" hidden>Loading...</div>
          <div data-combobox-dropdown-target="empty" hidden>No results</div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))

      const ctrl = getController()
      mockRequestor = {
        schedule: vi.fn((fn) => fn()),
        request: vi.fn(),
        cancel: vi.fn(),
      }
      ctrl._requestor = mockRequestor
    })

    it('shows loading before scheduling the request', () => {
      mockRequestor.request.mockReturnValue(new Promise(() => {})) // never resolves
      getController().filter('test')
      expect(document.querySelector('[data-combobox-dropdown-target="loading"]').hidden).toBe(false)
    })

    it('passes fieldValue as query param in the request URL', () => {
      mockRequestor.request.mockReturnValue(new Promise(() => {}))
      getController().filter('hello')
      const calledUrl = mockRequestor.request.mock.calls[0][0]
      expect(calledUrl.searchParams.get('q')).toBe('hello')
    })

    it('passes delayValue to requestor.schedule', () => {
      mockRequestor.request.mockReturnValue(new Promise(() => {}))
      getController().filter('test')
      expect(mockRequestor.schedule).toHaveBeenCalledWith(expect.any(Function), 0)
    })

    it('updates listbox HTML on successful response', async () => {
      const html = '<li role="option" data-value="x">X</li>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })
      getController().filter('test')
      await flushPromises()
      expect(document.querySelector('[role="listbox"]').innerHTML).toBe(html)
    })

    it('hides empty target when response contains options', async () => {
      const html = '<li role="option" data-value="x">X</li>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })
      getController().filter('test')
      await flushPromises()
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(true)
    })

    it('shows empty target when response has no options', async () => {
      mockRequestor.request.mockResolvedValue({ text: async () => '' })
      getController().filter('xyz')
      await flushPromises()
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(false)
    })

    it('clears loading after response resolves', async () => {
      const html = '<li role="option" data-value="x">X</li>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })
      getController().filter('test')
      await flushPromises()
      expect(document.querySelector('[data-combobox-dropdown-target="loading"]').hidden).toBe(true)
    })

    it('silently ignores AbortError', async () => {
      const err = new Error('aborted')
      err.name = 'AbortError'
      mockRequestor.request.mockRejectedValue(err)
      const consoleSpy = vi.spyOn(console, 'error')
      getController().filter('test')
      await flushPromises()
      expect(consoleSpy).not.toHaveBeenCalled()
    })

    it('logs non-abort errors to console.error', async () => {
      const err = new Error('network failure')
      mockRequestor.request.mockRejectedValue(err)
      const consoleSpy = vi.spyOn(console, 'error')
      getController().filter('test')
      await flushPromises()
      expect(consoleSpy).toHaveBeenCalledWith('[combobox-dropdown] fetch failed', err)
    })

    it('clears loading after a fetch error', async () => {
      mockRequestor.request.mockRejectedValue(new Error('network failure'))
      getController().filter('test')
      await flushPromises()
      expect(document.querySelector('[data-combobox-dropdown-target="loading"]').hidden).toBe(true)
    })
  })

  describe('setEmpty', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
          <div data-combobox-dropdown-target="empty" hidden>No results</div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('shows the empty target when true', () => {
      getController().setEmpty(true)
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(false)
    })

    it('hides the empty target when false', () => {
      getController().setEmpty(false)
      expect(document.querySelector('[data-combobox-dropdown-target="empty"]').hidden).toBe(true)
    })

    it('does not throw when empty target is absent', async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(() => getController().setEmpty(true)).not.toThrow()
    })
  })

  describe('disconnect', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="combobox-dropdown">
          <ul data-combobox-dropdown-target="listbox" role="listbox"></ul>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('cancels any pending requestor on disconnect', () => {
      const ctrl = getController()
      const cancelSpy = vi.spyOn(ctrl._requestor, 'cancel')
      ctrl.disconnect()
      expect(cancelSpy).toHaveBeenCalledOnce()
    })
  })
})
