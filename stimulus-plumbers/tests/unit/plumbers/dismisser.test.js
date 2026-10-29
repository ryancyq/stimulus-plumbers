import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Dismisser, attachDismisser } from '../../../src/plumbers/dismisser'

describe('Dismisser', () => {
  let observeSpy
  let mockController
  let element

  beforeEach(() => {
    observeSpy = vi.spyOn(Dismisser.prototype, 'observe')
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'dismisser',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    })
  })

  afterEach(() => {
    observeSpy.mock.contexts.forEach((observer) => observer.disconnect())
    observeSpy.mockRestore()
    vi.clearAllMocks()
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const dismisser = new Dismisser(mockController)

      expect(dismisser.controller).toBe(mockController)
      expect(dismisser.trigger).toBe(element)
      expect(dismisser.events).toEqual(['click'])
      expect(dismisser.onDismissed).toBe('dismissed')
    })

    it('accepts custom trigger element', () => {
      const trigger = document.createElement('button')
      const dismisser = new Dismisser(mockController, { trigger })

      expect(dismisser.trigger).toBe(trigger)
    })

    it('accepts custom events', () => {
      const dismisser = new Dismisser(mockController, {
        events: ['mousedown', 'touchstart'],
      })

      expect(dismisser.events).toEqual(['mousedown', 'touchstart'])
    })

    it('accepts custom onDismissed callback', () => {
      const dismisser = new Dismisser(mockController, {
        onDismissed: 'customDismissed',
      })

      expect(dismisser.onDismissed).toBe('customDismissed')
    })
  })

  describe('dismiss', () => {
    it('does nothing when target is not an Element', async () => {
      const dismisser = new Dismisser(mockController)
      const event = { target: null }

      await dismisser.dismiss(event)

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches dismiss for a click on an SVG element outside', async () => {
      document.body.insertAdjacentHTML('beforeend', '<svg id="icon"><path></path></svg>')
      const dismisser = new Dismisser(mockController)

      await dismisser.dismiss({ target: document.querySelector('#icon path') })

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object))
    })

    it('does nothing when target is inside element', async () => {
      const child = document.createElement('span')
      element.appendChild(child)
      const dismisser = new Dismisser(mockController)
      const event = { target: child }

      await dismisser.dismiss(event)

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('does nothing when element is not visible', async () => {
      element.setAttribute('hidden', true)
      const dismisser = new Dismisser(mockController)
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)
      const event = { target: outsideElement }

      await dismisser.dismiss(event)

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches dismiss and dismissed events when clicked outside', async () => {
      const dismisser = new Dismisser(mockController)
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)
      const event = { target: outsideElement }

      await dismisser.dismiss(event)

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object))
    })

    it('calls onDismissed callback', async () => {
      const onDismissed = vi.fn()
      mockController.dismissed = onDismissed
      const dismisser = new Dismisser(mockController, { onDismissed: 'dismissed' })
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)
      const event = { target: outsideElement }

      await dismisser.dismiss(event)

      expect(onDismissed).toHaveBeenCalledWith({ target: element })
    })

    it('awaits async onDismissed callback', async () => {
      const onDismissed = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      mockController.dismissed = onDismissed
      const dismisser = new Dismisser(mockController, { onDismissed: 'dismissed' })
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)
      const event = { target: outsideElement }

      await dismisser.dismiss(event)

      expect(onDismissed).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object))
    })
  })

  describe('observe', () => {
    it('dismisses on every configured event', () => {
      new Dismisser(mockController, { events: ['click', 'mousedown'] })
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)

      outsideElement.dispatchEvent(new MouseEvent('click', { bubbles: true }))
      outsideElement.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }))

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'dismiss')).toHaveLength(2)
    })
  })

  describe('disconnect', () => {
    it('stops dismissing on outside clicks', () => {
      const dismisser = new Dismisser(mockController)
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)

      dismisser.disconnect()
      outsideElement.click()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('attachDismisser', () => {
    it('creates and returns a Dismisser instance', () => {
      const dismisser = attachDismisser(mockController, { events: ['mousedown'] })

      expect(dismisser).toBeInstanceOf(Dismisser)
      expect(dismisser.events).toEqual(['mousedown'])
    })
  })

  describe('integration', () => {
    it('dismisses when clicking outside element', async () => {
      const dismisser = new Dismisser(mockController)
      const outsideElement = document.createElement('div')
      document.body.appendChild(outsideElement)

      // Simulate click event
      const clickEvent = new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      })
      Object.defineProperty(clickEvent, 'target', {
        value: outsideElement,
        enumerable: true,
      })

      await dismisser.dismiss(clickEvent)

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object))
    })

    it('does not dismiss when clicking inside element', async () => {
      const dismisser = new Dismisser(mockController)
      const insideElement = document.createElement('span')
      element.appendChild(insideElement)

      const clickEvent = new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      })
      Object.defineProperty(clickEvent, 'target', {
        value: insideElement,
        enumerable: true,
      })

      await dismisser.dismiss(clickEvent)

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })
})
