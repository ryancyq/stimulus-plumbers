import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ClipboardController from '../../../src/controllers/clipboard_controller'

function makePasteEvent(data = {}) {
  const event = new Event('paste', { bubbles: true, cancelable: true })
  Object.defineProperty(event, 'clipboardData', {
    value: {
      getData: (type) => data[type] ?? '',
      types: Object.keys(data),
    },
  })
  return event
}

describe('ClipboardController', () => {
  let application

  beforeEach(async () => {
    application = Application.start()
    application.register('clipboard', ClipboardController)

    document.body.innerHTML = `
      <div data-controller="clipboard"
           data-action="paste->clipboard#onPaste">
      </div>
    `
    await new Promise((resolve) => setTimeout(resolve, 10))
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  describe('default behaviour (text/plain)', () => {
    it('dispatches clipboard:pasted with text on paste', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'hello world' }))

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.text).toBe('hello world')
    })

    it('includes types array in payload', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(
        makePasteEvent({ 'text/plain': 'hello', 'text/html': '<b>hello</b>' })
      )

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy.mock.calls[0][0].detail.types).toEqual(
        expect.arrayContaining(['text/plain', 'text/html'])
      )
    })

    it('prevents the default paste behavior', () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const event = makePasteEvent({ 'text/plain': 'test' })
      const preventDefaultSpy = vi.spyOn(event, 'preventDefault')

      element.dispatchEvent(event)
      expect(preventDefaultSpy).toHaveBeenCalled()
    })

    it('dispatches empty text and empty types when clipboardData is null', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      const event = new Event('paste', { bubbles: true, cancelable: true })
      Object.defineProperty(event, 'clipboardData', { value: null })
      element.dispatchEvent(event)

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy.mock.calls[0][0].detail.text).toBe('')
      expect(spy.mock.calls[0][0].detail.types).toEqual([])
    })

    it('dispatches event that bubbles up to parent', async () => {
      const parent = document.createElement('div')
      const element = document.querySelector('[data-controller="clipboard"]')
      parent.appendChild(element)
      document.body.appendChild(parent)

      const spy = vi.fn()
      parent.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'bubbled text' }))

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy).toHaveBeenCalledTimes(1)
    })
  })

  describe('configured type value', () => {
    beforeEach(async () => {
      application.stop()
      document.body.innerHTML = ''

      application = Application.start()
      application.register('clipboard', ClipboardController)

      document.body.innerHTML = `
        <div data-controller="clipboard"
             data-clipboard-content-type-value="text/html"
             data-action="paste->clipboard#onPaste">
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('extracts the configured MIME type from clipboardData', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(
        makePasteEvent({
          'text/plain': 'plain text',
          'text/html': '<b>bold</b>',
        })
      )

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy.mock.calls[0][0].detail.text).toBe('<b>bold</b>')
    })

    it('still includes all available types in payload', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(
        makePasteEvent({
          'text/plain': 'plain text',
          'text/html': '<b>bold</b>',
        })
      )

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy.mock.calls[0][0].detail.types).toEqual(
        expect.arrayContaining(['text/plain', 'text/html'])
      )
    })

    it('returns empty text when configured type is not in clipboard', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:pasted', spy)

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'only plain' }))

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy.mock.calls[0][0].detail.text).toBe('')
    })
  })

  describe('copy to clipboard', () => {
    beforeEach(async () => {
      application.stop()
      document.body.innerHTML = ''

      application = Application.start()
      application.register('clipboard', ClipboardController)

      document.body.innerHTML = `
        <div data-controller="clipboard">
          <input value="copy this text" data-clipboard-target="source">
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('writes source value to clipboard and dispatches clipboard:copied', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:copied', spy)

      const writeTextSpy = vi.fn().mockResolvedValue(undefined)
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      })

      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard')
      await controller.copy({})

      expect(writeTextSpy).toHaveBeenCalledWith('copy this text')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.text).toBe('copy this text')
    })

    it('dispatches clipboard:copy-failed when write fails', async () => {
      const element = document.querySelector('[data-controller="clipboard"]')
      const spy = vi.fn()
      element.addEventListener('clipboard:copy-failed', spy)

      const error = new Error('Not allowed')
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: vi.fn().mockRejectedValue(error) },
        configurable: true,
      })

      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard')
      await controller.copy({})

      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail.error).toBe(error)
    })

    it('uses text from event params when provided', async () => {
      const writeTextSpy = vi.fn().mockResolvedValue(undefined)
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      })

      const element = document.querySelector('[data-controller="clipboard"]')
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard')
      await controller.copy({ params: { text: 'from params' } })

      expect(writeTextSpy).toHaveBeenCalledWith('from params')
    })

    it('uses textContent when source has no value (e.g. a span)', async () => {
      application.stop()
      document.body.innerHTML = ''
      application = Application.start()
      application.register('clipboard', ClipboardController)

      document.body.innerHTML = `
        <div data-controller="clipboard">
          <span data-clipboard-target="source">span text</span>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))

      const writeTextSpy = vi.fn().mockResolvedValue(undefined)
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      })

      const element = document.querySelector('[data-controller="clipboard"]')
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard')
      await controller.copy({})

      expect(writeTextSpy).toHaveBeenCalledWith('span text')
    })

    it('copies empty string when no source target and no params', async () => {
      application.stop()
      document.body.innerHTML = ''
      application = Application.start()
      application.register('clipboard', ClipboardController)

      document.body.innerHTML = `<div data-controller="clipboard"></div>`
      await new Promise((resolve) => setTimeout(resolve, 10))

      const writeTextSpy = vi.fn().mockResolvedValue(undefined)
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      })

      const element = document.querySelector('[data-controller="clipboard"]')
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard')
      await controller.copy({})

      expect(writeTextSpy).toHaveBeenCalledWith('')
    })
  })
})
