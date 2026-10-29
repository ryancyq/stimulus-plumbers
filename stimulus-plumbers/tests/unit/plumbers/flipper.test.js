import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Flipper, attachFlipper } from '../../../src/plumbers/flipper'

describe('Flipper', () => {
  let observeSpy
  let mockController
  let element
  let anchor

  beforeEach(() => {
    observeSpy = vi.spyOn(Flipper.prototype, 'observe')
    element = document.createElement('div')
    anchor = document.createElement('button')
    document.body.appendChild(element)
    document.body.appendChild(anchor)

    mockController = {
      identifier: 'flipper',
      element: element,
      dispatch: vi.fn((name, options) => true),
    }

    // Mock getBoundingClientRect for element
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

    // Mock getBoundingClientRect for anchor
    anchor.getBoundingClientRect = () => ({
      x: 50,
      y: 50,
      top: 50,
      left: 50,
      right: 150,
      bottom: 100,
      width: 100,
      height: 50,
    })
  })

  afterEach(() => {
    observeSpy.mock.contexts.forEach((observer) => observer.disconnect())
    observeSpy.mockRestore()
    vi.clearAllMocks()
  })

  describe('constructor', () => {
    it('initializes with default options', () => {
      const flipper = new Flipper(mockController, { anchor })

      expect(flipper.controller).toBe(mockController)
      expect(flipper.anchor).toBe(anchor)
      expect(flipper.events).toEqual(['click'])
      expect(flipper.placement).toBe('bottom')
      expect(flipper.alignment).toBe('start')
      expect(flipper.onFlipped).toBe('flipped')
    })

    it('accepts custom placement', () => {
      const flipper = new Flipper(mockController, {
        anchor,
        placement: 'top',
      })

      expect(flipper.placement).toBe('top')
    })

    it('accepts custom alignment', () => {
      const flipper = new Flipper(mockController, {
        anchor,
        alignment: 'center',
      })

      expect(flipper.alignment).toBe('center')
    })

    it('accepts custom events', () => {
      const flipper = new Flipper(mockController, {
        anchor,
        events: ['mouseenter', 'focus'],
      })

      expect(flipper.events).toEqual(['mouseenter', 'focus'])
    })

    it('accepts custom onFlipped callback', () => {
      const flipper = new Flipper(mockController, {
        anchor,
        onFlipped: 'customFlipped',
      })

      expect(flipper.onFlipped).toBe('customFlipped')
    })

    it('enhances controller with flip method', () => {
      const flipper = new Flipper(mockController, { anchor })

      expect(mockController.flip).toBeTypeOf('function')
    })

    it('initializes with respectMotion enabled by default', () => {
      const flipper = new Flipper(mockController, { anchor })

      expect(flipper.respectMotion).toBe(true)
    })

    it('accepts custom respectMotion option', () => {
      const flipper = new Flipper(mockController, {
        anchor,
        respectMotion: false,
      })

      expect(flipper.respectMotion).toBe(false)
    })

    it('checks prefers-reduced-motion media query on initialization', () => {
      const matchMediaSpy = vi.spyOn(window, 'matchMedia')
      const flipper = new Flipper(mockController, { anchor })

      expect(matchMediaSpy).toHaveBeenCalledWith('(prefers-reduced-motion: reduce)')
      expect(flipper.prefersReducedMotion).toBeDefined()
      expect(typeof flipper.prefersReducedMotion).toBe('boolean')

      matchMediaSpy.mockRestore()
    })
  })

  describe('biggerRectThan', () => {
    it('returns true when big rect is larger in both dimensions', () => {
      const flipper = new Flipper(mockController, { anchor })
      const big = { width: 200, height: 200 }
      const small = { width: 100, height: 100 }

      expect(flipper.biggerRectThan(big, small)).toBe(true)
    })

    it('returns false when big rect is smaller in width', () => {
      const flipper = new Flipper(mockController, { anchor })
      const big = { width: 50, height: 200 }
      const small = { width: 100, height: 100 }

      expect(flipper.biggerRectThan(big, small)).toBe(false)
    })

    it('returns false when big rect is smaller in height', () => {
      const flipper = new Flipper(mockController, { anchor })
      const big = { width: 200, height: 50 }
      const small = { width: 100, height: 100 }

      expect(flipper.biggerRectThan(big, small)).toBe(false)
    })

    it('returns true when dimensions are equal', () => {
      const flipper = new Flipper(mockController, { anchor })
      const big = { width: 100, height: 100 }
      const small = { width: 100, height: 100 }

      expect(flipper.biggerRectThan(big, small)).toBe(true)
    })
  })

  describe('quadrumRect', () => {
    it('calculates available space in all four directions', () => {
      const flipper = new Flipper(mockController, { anchor })
      const inner = {
        x: 100,
        y: 100,
        width: 50,
        height: 50,
      }
      const outer = {
        x: 0,
        y: 0,
        width: 300,
        height: 300,
      }

      const quadrum = flipper.quadrumRect(inner, outer)

      expect(quadrum.left.width).toBe(100)
      expect(quadrum.right.width).toBe(150)
      expect(quadrum.top.height).toBe(100)
      expect(quadrum.bottom.height).toBe(150)
    })
  })

  describe('quadrumPlacement', () => {
    it('places element at top of anchor', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { width: 200, height: 100 }

      const placement = flipper.quadrumPlacement(anchorRect, 'top', reference)

      expect(placement.y).toBe(0) // 100 - 100
      expect(placement.height).toBe(100)
    })

    it('places element at bottom of anchor', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { width: 200, height: 100 }

      const placement = flipper.quadrumPlacement(anchorRect, 'bottom', reference)

      expect(placement.y).toBe(150) // 100 + 50
      expect(placement.height).toBe(100)
    })

    it('places element to left of anchor', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { width: 80, height: 100 }

      const placement = flipper.quadrumPlacement(anchorRect, 'left', reference)

      expect(placement.x).toBe(20) // 100 - 80
      expect(placement.width).toBe(80)
    })

    it('places element to right of anchor', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { width: 80, height: 100 }

      const placement = flipper.quadrumPlacement(anchorRect, 'right', reference)

      expect(placement.x).toBe(150) // 100 + 50
      expect(placement.width).toBe(80)
    })

    it('throws error for invalid direction', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { width: 80, height: 100 }

      expect(() => flipper.quadrumPlacement(anchorRect, 'invalid', reference)).toThrow()
    })
  })

  describe('quadrumAlignment', () => {
    it('aligns to start for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'start' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 0, y: 200, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'bottom', reference)

      expect(aligned.x).toBe(100)
    })

    it('aligns to center for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'center' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 0, y: 200, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'bottom', reference)

      expect(aligned.x).toBe(85) // 100 + 50/2 - 80/2
    })

    it('aligns to end for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'end' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 0, y: 200, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'bottom', reference)

      expect(aligned.x).toBe(70) // 100 + 50 - 80
    })

    it('aligns to start for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'start' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 150, y: 0, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'right', reference)

      expect(aligned.y).toBe(100)
    })

    it('aligns to center for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'center' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 150, y: 0, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'right', reference)

      expect(aligned.y).toBe(75) // 100 + 50/2 - 100/2
    })

    it('aligns to end for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'end' })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 150, y: 0, width: 80, height: 100 }

      const aligned = flipper.quadrumAlignment(anchorRect, 'right', reference)

      expect(aligned.y).toBe(50) // 100 + 50 - 100
    })

    it('throws error for invalid direction', () => {
      const flipper = new Flipper(mockController, { anchor })
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 }
      const reference = { x: 150, y: 0, width: 80, height: 100 }

      expect(() => flipper.quadrumAlignment(anchorRect, 'invalid', reference)).toThrow()
    })
  })

  describe('flip', () => {
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

      const flipper = new Flipper(mockController, { anchor, respectMotion: true })

      await flipper.flip()

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

      const flipper = new Flipper(mockController, { anchor, respectMotion: false })

      await flipper.flip()

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

      const flipper = new Flipper(mockController, { anchor, respectMotion: true })

      await flipper.flip()

      expect(element.style.transition).toBe('')

      window.matchMedia = originalMatchMedia
    })
  })

  describe('observe', () => {
    it('repositions on every configured event', () => {
      new Flipper(mockController, { anchor, events: ['click', 'focus'] })

      window.dispatchEvent(new Event('click'))
      window.dispatchEvent(new Event('focus'))

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'flip')).toHaveLength(2)
    })
  })

  describe('disconnect', () => {
    it('stops repositioning on window events', () => {
      const flipper = new Flipper(mockController, { anchor })

      flipper.disconnect()
      window.dispatchEvent(new Event('resize'))

      expect(mockController.dispatch).not.toHaveBeenCalled()
    })
  })

  describe('enhance', () => {
    it('adds flip method to controller', () => {
      const flipper = new Flipper(mockController, { anchor })

      expect(mockController.flip).toBeDefined()
      expect(typeof mockController.flip).toBe('function')
    })
  })

  describe('attachFlipper', () => {
    it('creates and returns a Flipper instance', () => {
      const flipper = attachFlipper(mockController, {
        anchor,
        placement: 'top',
      })

      expect(flipper).toBeInstanceOf(Flipper)
      expect(flipper.placement).toBe('top')
    })
  })
})
