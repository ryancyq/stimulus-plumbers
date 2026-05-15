import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Requestor } from '../../src/requestor'

describe('Requestor', () => {
  let requestor

  beforeEach(() => {
    requestor = new Requestor()
  })

  afterEach(() => {
    vi.useRealTimers()
    delete global.fetch
  })

  describe('schedule', () => {
    beforeEach(() => {
      vi.useFakeTimers()
    })

    it('calls the function after the specified delay', () => {
      global.fetch = vi.fn(async () => ({ ok: true, text: async () => '' }))
      const fn = vi.fn()
      requestor.schedule(fn, 300)
      vi.runAllTimers()
      expect(fn).toHaveBeenCalledOnce()
    })

    it('debounces: only the last scheduled call fires', () => {
      const fn = vi.fn()
      requestor.schedule(fn, 300)
      requestor.schedule(fn, 300)
      requestor.schedule(fn, 300)
      vi.runAllTimers()
      expect(fn).toHaveBeenCalledOnce()
    })
  })

  describe('request', () => {
    beforeEach(() => {
      global.fetch = vi.fn()
    })

    it('returns the response on success', async () => {
      const mockResponse = { ok: true, text: async () => '<p>Hello</p>' }
      global.fetch.mockResolvedValue(mockResponse)

      const res = await requestor.request('/test')
      expect(res).toBe(mockResponse)
    })

    it('throws on non-ok response', async () => {
      global.fetch.mockResolvedValue({ ok: false, status: 500 })
      await expect(requestor.request('/test')).rejects.toThrow('500')
    })

    it('passes options through to fetch', async () => {
      global.fetch.mockResolvedValue({ ok: true })
      await requestor.request('/test', { method: 'POST', headers: { 'Content-Type': 'application/json' } })
      expect(global.fetch).toHaveBeenCalledWith('/test', expect.objectContaining({
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
      }))
    })

    it('aborts the previous in-flight request when a second request is made', async () => {
      let firstAborted = false
      global.fetch.mockImplementationOnce((url, { signal }) => {
        signal.addEventListener('abort', () => { firstAborted = true })
        return new Promise(() => {}) // never resolves
      })
      global.fetch.mockResolvedValueOnce({ ok: true })

      requestor.request('/a')
      const firstController = requestor._abortController
      await requestor.request('/b')

      expect(firstController.signal.aborted).toBe(true)
    })

    it('propagates AbortError to caller', async () => {
      const abortError = Object.assign(new Error('Aborted'), { name: 'AbortError' })
      global.fetch.mockRejectedValue(abortError)
      await expect(requestor.request('/test')).rejects.toMatchObject({ name: 'AbortError' })
    })

    it('propagates network errors to caller', async () => {
      const networkError = new TypeError('Network failure')
      global.fetch.mockRejectedValue(networkError)
      await expect(requestor.request('/test')).rejects.toThrow('Network failure')
    })
  })

  describe('cancel', () => {
    it('clears the debounce timer so the function never fires', () => {
      vi.useFakeTimers()
      const fn = vi.fn()
      requestor.schedule(fn, 300)
      requestor.cancel()
      vi.runAllTimers()
      expect(fn).not.toHaveBeenCalled()
    })

    it('aborts an in-flight request', async () => {
      global.fetch = vi.fn(() => new Promise(() => {}))
      requestor.request('/test')
      const controller = requestor._abortController
      requestor.cancel()
      expect(controller.signal.aborted).toBe(true)
    })

    it('does not throw when there is nothing to cancel', () => {
      expect(() => requestor.cancel()).not.toThrow()
    })
  })
})
