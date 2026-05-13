import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { ComboboxDropdown } from '../../../src/plumbers/combobox_dropdown'

describe('ComboboxDropdown', () => {
  let mockController, dropdown

  beforeEach(() => {
    const el = document.createElement('div')
    document.body.appendChild(el)
    mockController = {
      identifier: 'combobox-dropdown',
      element: el,
      dispatch: vi.fn(() => true),
    }
    dropdown = new ComboboxDropdown(mockController)
  })

  describe('fuzzyMatch', () => {
    it('empty needle matches any haystack', () => {
      expect(dropdown.fuzzyMatch('', 'anything')).toBe(true)
    })

    it('returns true when needle chars appear in order in haystack', () => {
      expect(dropdown.fuzzyMatch('app', 'apple')).toBe(true)
      expect(dropdown.fuzzyMatch('apl', 'apple')).toBe(true)
    })

    it('returns false when needle chars are out of order', () => {
      expect(dropdown.fuzzyMatch('ppa', 'apple')).toBe(false)
    })

    it('returns false when needle is longer than haystack', () => {
      expect(dropdown.fuzzyMatch('toolong', 'too')).toBe(false)
    })

    it('returns true for an exact match', () => {
      expect(dropdown.fuzzyMatch('apple', 'apple')).toBe(true)
    })

    it('returns false when haystack is empty and needle is not', () => {
      expect(dropdown.fuzzyMatch('a', '')).toBe(false)
    })
  })

  describe('fuzzyFilter', () => {
    let listbox

    beforeEach(() => {
      listbox = document.createElement('ul')
      listbox.innerHTML = `
        <li role="option">Apple</li>
        <li role="option">Banana</li>
        <li role="option">Apricot</li>
      `
      document.body.appendChild(listbox)
    })

    it('hides non-matching options and returns visible count', () => {
      const visible = dropdown.fuzzyFilter(listbox, 'ban')
      expect(visible).toBe(1)
      const opts = listbox.querySelectorAll('[role="option"]')
      expect(opts[0].hidden).toBe(true)  // Apple
      expect(opts[1].hidden).toBe(false) // Banana
      expect(opts[2].hidden).toBe(true)  // Apricot
    })

    it('returns 0 when no options match', () => {
      const visible = dropdown.fuzzyFilter(listbox, 'xyz')
      expect(visible).toBe(0)
      listbox.querySelectorAll('[role="option"]').forEach((o) => {
        expect(o.hidden).toBe(true)
      })
    })

    it('shows all options when query matches all', () => {
      const visible = dropdown.fuzzyFilter(listbox, 'a')
      expect(visible).toBe(3)
      listbox.querySelectorAll('[role="option"]').forEach((o) => {
        expect(o.hidden).toBe(false)
      })
    })
  })

  describe('scheduleFetch', () => {
    beforeEach(() => {
      vi.useFakeTimers()
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('calls fetch callback after the specified delay', () => {
      const callback = { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() }
      global.fetch = vi.fn(async () => ({ ok: true, text: async () => '' }))

      dropdown.scheduleFetch('hello', 300, callback)
      vi.runAllTimers()

      expect(global.fetch).toHaveBeenCalledOnce()
    })

    it('debounces: only the last scheduled call fires', () => {
      const callback = { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() }
      global.fetch = vi.fn(async () => ({ ok: true, text: async () => '' }))

      dropdown.scheduleFetch('h', 300, callback)
      dropdown.scheduleFetch('he', 300, callback)
      dropdown.scheduleFetch('hel', 300, callback)
      vi.runAllTimers()

      expect(global.fetch).toHaveBeenCalledOnce()
    })
  })

  describe('fetch', () => {
    beforeEach(() => {
      global.fetch = vi.fn()
    })

    afterEach(() => {
      delete global.fetch
    })

    it('calls onLoading(true) then onLoaded(text) then onLoading(false) on success', async () => {
      const onLoading = vi.fn()
      const onLoaded = vi.fn()
      const onError = vi.fn()

      global.fetch.mockResolvedValue({
        ok: true,
        text: async () => '<li>Result</li>',
      })

      await dropdown.fetch('hello', { url: '/search', field: 'q', onLoading, onLoaded, onError })

      expect(onLoading).toHaveBeenNthCalledWith(1, true)
      expect(onLoaded).toHaveBeenCalledWith('<li>Result</li>')
      expect(onLoading).toHaveBeenLastCalledWith(false)
      expect(onError).not.toHaveBeenCalled()
    })

    it('appends the query as a search param on the fetch URL', async () => {
      global.fetch.mockResolvedValue({ ok: true, text: async () => '' })

      await dropdown.fetch('my query', { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() })

      const calledUrl = global.fetch.mock.calls[0][0].toString()
      expect(calledUrl).toContain('q=my+query')
    })

    it('calls onError when response is not ok', async () => {
      const onLoading = vi.fn()
      const onLoaded = vi.fn()
      const onError = vi.fn()

      global.fetch.mockResolvedValue({ ok: false, status: 500 })

      await dropdown.fetch('hello', { url: '/search', field: 'q', onLoading, onLoaded, onError })

      expect(onError).toHaveBeenCalledWith(expect.objectContaining({ message: '500' }))
      expect(onLoaded).not.toHaveBeenCalled()
      expect(onLoading).toHaveBeenLastCalledWith(false)
    })

    it('suppresses AbortError and does not call onError', async () => {
      const onLoading = vi.fn()
      const onError = vi.fn()
      const abortError = Object.assign(new Error('Aborted'), { name: 'AbortError' })

      global.fetch.mockRejectedValue(abortError)

      await dropdown.fetch('hello', { url: '/search', field: 'q', onLoading, onLoaded: vi.fn(), onError })

      expect(onError).not.toHaveBeenCalled()
      expect(onLoading).toHaveBeenLastCalledWith(false)
    })

    it('calls onError for non-abort errors', async () => {
      const onError = vi.fn()
      const networkError = new TypeError('Network failure')

      global.fetch.mockRejectedValue(networkError)

      await dropdown.fetch('hello', { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError })

      expect(onError).toHaveBeenCalledWith(networkError)
    })

    it('aborts the previous in-flight request when a second fetch is made', async () => {
      let firstAborted = false
      global.fetch.mockImplementation((url, { signal }) => {
        signal.addEventListener('abort', () => { firstAborted = true })
        return new Promise(() => {}) // never resolves
      })

      // First fetch — hangs
      dropdown.fetch('a', { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() })
      const firstController = dropdown.abortController

      // Second fetch — should abort first
      global.fetch.mockResolvedValue({ ok: true, text: async () => '' })
      await dropdown.fetch('b', { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() })

      expect(firstController.signal.aborted).toBe(true)
    })
  })

  describe('cancel', () => {
    it('clears the debounce timer so the callback never fires', () => {
      vi.useFakeTimers()
      const onLoading = vi.fn()
      global.fetch = vi.fn(async () => ({ ok: true, text: async () => '' }))

      dropdown.scheduleFetch('hello', 300, { url: '/search', field: 'q', onLoading, onLoaded: vi.fn(), onError: vi.fn() })
      dropdown.cancel()
      vi.runAllTimers()

      expect(global.fetch).not.toHaveBeenCalled()
      vi.useRealTimers()
      delete global.fetch
    })

    it('aborts an in-flight request', async () => {
      global.fetch = vi.fn(() => new Promise(() => {})) // never resolves
      dropdown.fetch('hello', { url: '/search', field: 'q', onLoading: vi.fn(), onLoaded: vi.fn(), onError: vi.fn() })

      const controller = dropdown.abortController
      dropdown.cancel()

      expect(controller.signal.aborted).toBe(true)
      delete global.fetch
    })

    it('does not throw when there is nothing to cancel', () => {
      expect(() => dropdown.cancel()).not.toThrow()
    })
  })
})
