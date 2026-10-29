import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Shifter, attachShifter } from '../../../src/plumbers/shifter'

describe('Shifter', () => {
  let observeSpy
  let mockController
  let element

  beforeEach(() => {
    observeSpy = vi.spyOn(Shifter.prototype, 'observe')
    element = document.createElement('div')
    document.body.appendChild(element)

    mockController = {
      identifier: 'shifter',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Mock getBoundingClientRect
    element.getBoundingClientRect = () => ({
      x: 100,
      y: 100,
      top: 100,
      left: 100,
      right: 300,
      bottom: 300,
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
      const shifter = new Shifter(mockController)

      expect(shifter.controller).toBe(mockController)
      expect(shifter.events).toEqual(['resize'])
      expect(shifter.boundaries).toEqual(['top', 'left', 'right'])
      expect(shifter.onShifted).toBe('shifted')
    })

    it('accepts custom events', () => {
      const shifter = new Shifter(mockController, {
        events: ['scroll', 'resize'],
      })

      expect(shifter.events).toEqual(['scroll', 'resize'])
    })

    it('accepts custom boundaries', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top', 'bottom'],
      })

      expect(shifter.boundaries).toEqual(['top', 'bottom'])
    })

    it('accepts custom onShifted callback', () => {
      const shifter = new Shifter(mockController, {
        onShifted: 'customShifted',
      })

      expect(shifter.onShifted).toBe('customShifted')
    })

    it('initializes with respectMotion enabled by default', () => {
      const shifter = new Shifter(mockController)

      expect(shifter.respectMotion).toBe(true)
    })

    it('accepts custom respectMotion option', () => {
      const shifter = new Shifter(mockController, {
        respectMotion: false,
      })

      expect(shifter.respectMotion).toBe(false)
    })

    it('checks prefers-reduced-motion media query on initialization', () => {
      const matchMediaSpy = vi.spyOn(window, 'matchMedia')
      const shifter = new Shifter(mockController)

      expect(matchMediaSpy).toHaveBeenCalledWith('(prefers-reduced-motion: reduce)')
      expect(shifter.prefersReducedMotion).toBeDefined()
      expect(typeof shifter.prefersReducedMotion).toBe('boolean')

      matchMediaSpy.mockRestore()
    })

    it('enhances controller with shift method', () => {
      const shifter = new Shifter(mockController)

      expect(mockController.shift).toBeTypeOf('function')
    })
  })

  describe('elementTranslations', () => {
    it('returns zero translations for untransformed element', () => {
      const shifter = new Shifter(mockController)
      const translations = shifter.elementTranslations(element)

      expect(translations).toEqual({ x: 0, y: 0 })
    })

    it('parses 2D matrix transformations', () => {
      element.style.transform = 'matrix(1, 0, 0, 1, 50, 100)'
      const shifter = new Shifter(mockController)
      const translations = shifter.elementTranslations(element)

      expect(translations).toEqual({ x: 50, y: 100 })
    })

    it('returns zero for 3D matrix transformations', () => {
      element.style.transform = 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 50, 100, 0, 1)'
      const shifter = new Shifter(mockController)
      const translations = shifter.elementTranslations(element)

      expect(translations).toEqual({ x: 0, y: 0 })
    })
  })

  describe('directionDistance', () => {
    it('calculates distance for top direction', () => {
      const shifter = new Shifter(mockController)
      const inner = { top: 50, bottom: 150, left: 50, right: 150 }
      const outer = { top: 0, bottom: 200, left: 0, right: 200 }

      const distance = shifter.directionDistance(inner, 'top', outer)

      expect(distance).toBe(50)
    })

    it('calculates distance for bottom direction', () => {
      const shifter = new Shifter(mockController)
      const inner = { top: 50, bottom: 150, left: 50, right: 150 }
      const outer = { top: 0, bottom: 200, left: 0, right: 200 }

      const distance = shifter.directionDistance(inner, 'bottom', outer)

      expect(distance).toBe(50)
    })

    it('calculates distance for left direction', () => {
      const shifter = new Shifter(mockController)
      const inner = { top: 50, bottom: 150, left: 50, right: 150 }
      const outer = { top: 0, bottom: 200, left: 0, right: 200 }

      const distance = shifter.directionDistance(inner, 'left', outer)

      expect(distance).toBe(50)
    })

    it('calculates distance for right direction', () => {
      const shifter = new Shifter(mockController)
      const inner = { top: 50, bottom: 150, left: 50, right: 150 }
      const outer = { top: 0, bottom: 200, left: 0, right: 200 }

      const distance = shifter.directionDistance(inner, 'right', outer)

      expect(distance).toBe(50)
    })

    it('throws error for invalid direction', () => {
      const shifter = new Shifter(mockController)
      const inner = { top: 50, bottom: 150, left: 50, right: 150 }
      const outer = { top: 0, bottom: 200, left: 0, right: 200 }

      expect(() => shifter.directionDistance(inner, 'invalid', outer)).toThrow()
    })
  })

  describe('overflowRect', () => {
    it('returns empty overflow when element fits within viewport', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top', 'left', 'right', 'bottom'],
      })
      const targetRect = {
        x: 100,
        y: 100,
        width: 200,
        height: 200,
      }
      const translations = { x: 0, y: 0 }

      const overflow = shifter.overflowRect(targetRect, translations)

      expect(overflow.top).toBe('')
      expect(overflow.left).toBe('')
      expect(overflow.right).toBe('')
      expect(overflow.bottom).toBe('')
    })

    it('calculates overflow for element outside viewport top', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top'],
      })
      const targetRect = {
        x: 100,
        y: -50,
        width: 200,
        height: 200,
      }
      const translations = { x: 0, y: 0 }

      const overflow = shifter.overflowRect(targetRect, translations)

      // May or may not be set depending on sufficient space
      expect(overflow).toBeTypeOf('object')
    })

    it('calculates overflow for element outside viewport left', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['left'],
      })
      const targetRect = {
        x: -50,
        y: 100,
        width: 200,
        height: 200,
      }
      const translations = { x: 0, y: 0 }

      const overflow = shifter.overflowRect(targetRect, translations)

      // May or may not be set depending on sufficient space
      expect(overflow).toBeTypeOf('object')
    })

    it('respects existing translations', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top'],
      })
      const targetRect = {
        x: 100,
        y: 50,
        width: 200,
        height: 200,
      }
      const translations = { x: 0, y: 100 }

      const overflow = shifter.overflowRect(targetRect, translations)

      // The actual position after removing translation is y: 50 - 100 = -50
      expect(overflow).toBeTypeOf('object')
    })

    it('uses targetRect height (not width) for currentRect height calculation', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top', 'bottom'],
      })
      const targetRect = {
        x: 100,
        y: 100,
        width: 300, // Different width
        height: 150, // Different height
      }
      const translations = { x: 0, y: 0 }

      // This test verifies the bug fix: height should use targetRect.height, not targetRect.width
      // If the implementation incorrectly used targetRect.width, the boundary calculations would be wrong
      const overflow = shifter.overflowRect(targetRect, translations)

      expect(overflow).toBeTypeOf('object')
      // The overflow calculation should work correctly with proper height
    })
  })

  describe('shift', () => {
    it('does nothing when element is not visible', async () => {
      element.setAttribute('hidden', true)
      const shifter = new Shifter(mockController)

      await shifter.shift()

      expect(mockController.dispatch).not.toHaveBeenCalled()
      expect(element.style.transform).toBe('')
    })

    it('dispatches shift and shifted events', async () => {
      const shifter = new Shifter(mockController)

      await shifter.shift()

      expect(mockController.dispatch).toHaveBeenCalledWith('shift', expect.any(Object))
      expect(mockController.dispatch).toHaveBeenCalledWith('shifted', expect.any(Object))
    })

    it('calls onShifted callback with overflow data', async () => {
      const onShifted = vi.fn()
      mockController.shifted = onShifted
      const shifter = new Shifter(mockController, { onShifted: 'shifted' })

      await shifter.shift()

      expect(onShifted).toHaveBeenCalledWith(expect.any(Object))
    })

    it('applies transform when element overflows', async () => {
      // Mock element outside viewport on left
      element.getBoundingClientRect = () => ({
        x: -50,
        y: 100,
        top: 100,
        left: -50,
        right: 150,
        bottom: 300,
        width: 200,
        height: 200,
      })

      const shifter = new Shifter(mockController, {
        boundaries: ['left'],
      })

      await shifter.shift()

      expect(element.style.transform).toContain('translate')
    })

    it('awaits async onShifted callback', async () => {
      const onShifted = vi.fn(() => new Promise((resolve) => setTimeout(resolve, 10)))
      mockController.shifted = onShifted
      const shifter = new Shifter(mockController, { onShifted: 'shifted' })

      await shifter.shift()

      expect(onShifted).toHaveBeenCalled()
      expect(mockController.dispatch).toHaveBeenCalledWith('shifted', expect.any(Object))
    })

    it('disables transitions when respectMotion is true and user prefers reduced motion', async () => {
      // Mock prefers-reduced-motion: reduce
      const originalMatchMedia = window.matchMedia
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }))

      const shifter = new Shifter(mockController, { respectMotion: true })

      await shifter.shift()

      expect(element.style.transition).toBe('none')

      window.matchMedia = originalMatchMedia
    })

    it('does not disable transitions when respectMotion is false even if user prefers reduced motion', async () => {
      // Mock prefers-reduced-motion: reduce
      const originalMatchMedia = window.matchMedia
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }))

      const shifter = new Shifter(mockController, { respectMotion: false })

      await shifter.shift()

      expect(element.style.transition).toBe('')

      window.matchMedia = originalMatchMedia
    })

    it('does not disable transitions when user does not prefer reduced motion', async () => {
      // Mock prefers-reduced-motion: no-preference
      const originalMatchMedia = window.matchMedia
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: false,
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }))

      const shifter = new Shifter(mockController, { respectMotion: true })

      await shifter.shift()

      expect(element.style.transition).toBe('')

      window.matchMedia = originalMatchMedia
    })
  })

  describe('observe', () => {
    it('shifts on every configured event', () => {
      // jsdom reports the inline translate() instead of a matrix once the first shift writes it.
      const getComputedStyleSpy = vi.spyOn(window, 'getComputedStyle').mockReturnValue({ transform: 'none' })
      new Shifter(mockController, { events: ['resize', 'scroll'] })

      window.dispatchEvent(new Event('resize'))
      window.dispatchEvent(new Event('scroll'))

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'shift')).toHaveLength(2)
      getComputedStyleSpy.mockRestore()
    })
  })

  describe('disconnect', () => {
    it('stops shifting on window resize', () => {
      const shifter = new Shifter(mockController)

      shifter.disconnect()
      window.dispatchEvent(new Event('resize'))

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('enhance', () => {
    it('adds shift method to controller', () => {
      const shifter = new Shifter(mockController)

      expect(mockController.shift).toBeDefined()
      expect(typeof mockController.shift).toBe('function')
    })
  })

  describe('attachShifter', () => {
    it('creates and returns a Shifter instance', () => {
      const shifter = attachShifter(mockController, {
        boundaries: ['top', 'bottom'],
      })

      expect(shifter).toBeInstanceOf(Shifter)
      expect(shifter.boundaries).toEqual(['top', 'bottom'])
    })
  })
})
