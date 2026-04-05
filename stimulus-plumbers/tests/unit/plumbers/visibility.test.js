import { describe, it, expect, beforeEach, vi } from 'vitest'
import {
  Visibility,
  attachVisibility,
} from '../../../src/plumbers/visibility'
import { visibilityConfig } from '../../../src/plumbers/plumber/support'

describe('Visibility', () => {
  let mockController
  let element

  beforeEach(() => {
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'visibility',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Reset visibility config
    visibilityConfig.hiddenClass = 'hidden'

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    })
  })

  describe('constructor', () => {
    it('defaults namespace to "visibility", resolver to "isVisible", callbacks to shown/hidden', () => {
      const visibility = new Visibility(mockController)

      expect(visibility.controller).toBe(mockController)
      expect(visibility.visibility).toBe('visibility')
      expect(visibility.visibilityResolver).toBe('isVisible')
      expect(visibility.onShown).toBe('shown')
      expect(visibility.onHidden).toBe('hidden')
    })

    it('accepts custom visibility namespace', () => {
      const visibility = new Visibility(mockController, {
        visibility: 'customNamespace',
      })

      expect(visibility.visibility).toBe('customNamespace')
    })

    it('accepts custom callbacks', () => {
      const visibility = new Visibility(mockController, {
        onShown: 'customShown',
        onHidden: 'customHidden',
      })

      expect(visibility.onShown).toBe('customShown')
      expect(visibility.onHidden).toBe('customHidden')
    })

    it('attaches show and hide helpers to controller', () => {
      new Visibility(mockController)

      expect(mockController.visibility).toBeDefined()
      expect(mockController.visibility.show).toBeTypeOf('function')
      expect(mockController.visibility.hide).toBeTypeOf('function')
    })
  })

  describe('isVisible', () => {
    it('returns false for non-HTMLElement', () => {
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(null)).toBe(false)
      expect(visibility.isVisible(undefined)).toBe(false)
      expect(visibility.isVisible({})).toBe(false)
    })

    it('returns true without hidden class', () => {
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(true)
    })

    it('returns false with hidden class', () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(false)
    })

    it('uses hidden attribute when hiddenClass is null', () => {
      visibilityConfig.hiddenClass = null
      const visibility = new Visibility(mockController)

      expect(visibility.isVisible(element)).toBe(true)

      element.setAttribute('hidden', true)
      expect(visibility.isVisible(element)).toBe(false)
    })
  })

  describe('show', () => {
    it('does nothing when element is already visible', async () => {
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches show and shown events', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(mockController.dispatch).toHaveBeenCalledWith('show', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('shown', expect.any(Object))
    })

    it('removes hidden class', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.show()

      expect(element.classList.contains('hidden')).toBe(false)
    })

    it('calls onShown callback', async () => {
      element.classList.add('hidden')
      const onShown = vi.fn()
      const visibility = new Visibility(mockController, { onShown: 'shown' })
      visibility.shown = onShown

      await visibility.show()

      expect(onShown).toHaveBeenCalledWith({ target: element })
    })

    it('awaits async onShown callback', async () => {
      element.classList.add('hidden')
      const onShown = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      const visibility = new Visibility(mockController, { onShown: 'shown' })
      visibility.shown = onShown

      await visibility.show()

      expect(onShown).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('shown', expect.any(Object))
    })

    it('does nothing for non-HTMLElement', async () => {
      const visibility = new Visibility(mockController, { element: null })

      await visibility.show()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('hide', () => {
    it('does nothing when element is already hidden', async () => {
      element.classList.add('hidden')
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })

    it('dispatches hide and hidden events', async () => {
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(mockController.dispatch).toHaveBeenCalledWith('hide', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('hidden', expect.any(Object))
    })

    it('adds hidden class', async () => {
      const visibility = new Visibility(mockController)

      await visibility.hide()

      expect(element.classList.contains('hidden')).toBe(true)
    })

    it('calls onHidden callback', async () => {
      const onHidden = vi.fn()
      const visibility = new Visibility(mockController, { onHidden: 'hidden' })
      visibility.hidden = onHidden

      await visibility.hide()

      expect(onHidden).toHaveBeenCalledWith({ target: element })
    })

    it('awaits async onHidden callback', async () => {
      const onHidden = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      const visibility = new Visibility(mockController, { onHidden: 'hidden' })
      visibility.hidden = onHidden

      await visibility.hide()

      expect(onHidden).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('hidden', expect.any(Object))
    })

    it('does nothing for non-HTMLElement', async () => {
      const visibility = new Visibility(mockController, { element: null })

      await visibility.hide()

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('enhance', () => {
    it('adds show and hide methods to controller', () => {
      new Visibility(mockController)

      expect(mockController.visibility.show).toBeTypeOf('function')
      expect(mockController.visibility.hide).toBeTypeOf('function')
    })

    it('adds visible getter to controller', () => {
      new Visibility(mockController)

      expect(mockController.visibility.visible).toBe(true)

      element.classList.add('hidden')
      expect(mockController.visibility.visible).toBe(false)
    })

    it('adds isVisible resolver to controller', () => {
      new Visibility(mockController)

      expect(mockController.visibility.isVisible).toBeTypeOf('function')
      expect(mockController.visibility.isVisible(element)).toBe(true)

      element.classList.add('hidden')
      expect(mockController.visibility.isVisible(element)).toBe(false)
    })

    it('uses custom namespace', () => {
      new Visibility(mockController, { visibility: 'customVis' })

      expect(mockController.customVis).toBeDefined()
      expect(mockController.customVis.show).toBeTypeOf('function')
      expect(mockController.customVis.hide).toBeTypeOf('function')
    })
  })

  describe('activator', () => {
    let activator

    beforeEach(() => {
      activator = document.createElement('button')
      document.body.appendChild(activator)
    })

    it('sets aria-expanded="false" on init when element has hidden class', () => {
      element.classList.add('hidden')
      new Visibility(mockController, { activator })

      expect(activator.getAttribute('aria-expanded')).toBe('false')
    })

    it('sets aria-expanded="false" on init when element has hidden attribute', () => {
      visibilityConfig.hiddenClass = null
      element.setAttribute('hidden', true)
      new Visibility(mockController, { activator })

      expect(activator.getAttribute('aria-expanded')).toBe('false')
    })

    it('sets aria-expanded="true" on init when element is visible', () => {
      new Visibility(mockController, { activator })

      expect(activator.getAttribute('aria-expanded')).toBe('true')
    })

    it('does not set aria-expanded on init when no element passed', () => {
      new Visibility(mockController, { activator, element: null })

      expect(activator.hasAttribute('aria-expanded')).toBe(false)
    })

    it('sets aria-expanded="true" after show', async () => {
      element.classList.add('hidden')
      new Visibility(mockController, { activator })

      await mockController.visibility.show()

      expect(activator.getAttribute('aria-expanded')).toBe('true')
    })

    it('sets aria-expanded="false" after hide', async () => {
      new Visibility(mockController, { activator })

      await mockController.visibility.hide()

      expect(activator.getAttribute('aria-expanded')).toBe('false')
    })

    it('does not throw when no activator passed', async () => {
      element.classList.add('hidden')
      new Visibility(mockController)

      await expect(mockController.visibility.show()).resolves.toBeUndefined()
    })

    it('ignores non-HTMLElement activator', () => {
      expect(() => new Visibility(mockController, { activator: 'not-an-element' })).not.toThrow()
    })
  })

  describe('attachVisibility', () => {
    it('creates and returns a Visibility instance', () => {
      const visibility = attachVisibility(mockController, {
        visibility: 'custom',
      })

      expect(visibility).toBeInstanceOf(Visibility)
      expect(visibility.visibility).toBe('custom')
    })
  })

  describe('integration', () => {
    it('show and hide toggle class and visible getter', async () => {
      new Visibility(mockController)

      expect(mockController.visibility.visible).toBe(true)

      await mockController.visibility.hide()
      expect(element.classList.contains('hidden')).toBe(true)
      expect(mockController.visibility.visible).toBe(false)

      await mockController.visibility.show()
      expect(element.classList.contains('hidden')).toBe(false)
      expect(mockController.visibility.visible).toBe(true)
    })

    it('works with attribute-based visibility', async () => {
      visibilityConfig.hiddenClass = null
      new Visibility(mockController)

      await mockController.visibility.hide()
      expect(element.hasAttribute('hidden')).toBe(true)

      await mockController.visibility.show()
      expect(element.hasAttribute('hidden')).toBe(false)
    })
  })
})
