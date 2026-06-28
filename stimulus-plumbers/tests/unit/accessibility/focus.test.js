import { describe, it, expect, beforeEach, vi } from 'vitest'
import {
  FOCUSABLE_SELECTOR,
  getFocusableElements,
  isVisible,
  focusFirst,
  FocusTrap,
} from '../../../src/accessibility/focus'

// jsdom returns offsetWidth=0 and getClientRects()=[] for all elements.
// Override getClientRects on an element to make isVisible() return true.
function makeVisible(el) {
  el.getClientRects = () => [{}]
}

describe('focus', () => {
  describe('FOCUSABLE_SELECTOR', () => {
    it('is a non-empty string', () => {
      expect(typeof FOCUSABLE_SELECTOR).toBe('string')
      expect(FOCUSABLE_SELECTOR.length).toBeGreaterThan(0)
    })

    it('includes button, input, a[href], and [tabindex] selectors', () => {
      expect(FOCUSABLE_SELECTOR).toContain('button')
      expect(FOCUSABLE_SELECTOR).toContain('input')
      expect(FOCUSABLE_SELECTOR).toContain('a[href]')
      expect(FOCUSABLE_SELECTOR).toContain('[tabindex]')
    })
  })

  describe('isVisible', () => {
    it('returns true when offsetWidth is non-zero', () => {
      const el = document.createElement('div')
      Object.defineProperty(el, 'offsetWidth', { get: () => 10, configurable: true })
      expect(isVisible(el)).toBe(true)
    })

    it('returns true when offsetHeight is non-zero', () => {
      const el = document.createElement('div')
      Object.defineProperty(el, 'offsetHeight', { get: () => 10, configurable: true })
      expect(isVisible(el)).toBe(true)
    })

    it('returns true when getClientRects returns a non-empty array', () => {
      const el = document.createElement('div')
      makeVisible(el)
      expect(isVisible(el)).toBe(true)
    })

    it('returns false when all dimensions are zero and no client rects', () => {
      const el = document.createElement('div')
      // jsdom default: offsetWidth=0, offsetHeight=0, getClientRects()=[]
      expect(isVisible(el)).toBe(false)
    })
  })

  describe('getFocusableElements', () => {
    let container

    beforeEach(() => {
      container = document.createElement('div')
      document.body.appendChild(container)
    })

    it('returns visible focusable elements', () => {
      container.innerHTML = '<button>A</button><button>B</button>'
      container.querySelectorAll('button').forEach(makeVisible)
      const els = getFocusableElements(container)
      expect(els.length).toBe(2)
    })

    it('excludes non-semantic elements with tabindex="-1"', () => {
      container.innerHTML = '<div tabindex="-1">Skip</div><button>Keep</button>'
      container.querySelectorAll('div, button').forEach(makeVisible)
      const els = getFocusableElements(container)
      expect(els.length).toBe(1)
      expect(els[0].textContent).toBe('Keep')
    })

    it('excludes disabled inputs', () => {
      container.innerHTML = '<input disabled><input>'
      container.querySelectorAll('input').forEach(makeVisible)
      const els = getFocusableElements(container)
      expect(els.length).toBe(1)
    })

    it('excludes invisible elements', () => {
      container.innerHTML = '<button>Hidden</button><button>Visible</button>'
      const [hidden, visible] = container.querySelectorAll('button')
      makeVisible(visible)
      // hidden button has no getClientRects override → isVisible returns false
      const els = getFocusableElements(container)
      expect(els.length).toBe(1)
      expect(els[0]).toBe(visible)
    })

    it('returns empty array when container has no focusable elements', () => {
      container.innerHTML = '<p>No focusable</p>'
      expect(getFocusableElements(container).length).toBe(0)
    })
  })

  describe('focusFirst', () => {
    let container

    beforeEach(() => {
      container = document.createElement('div')
      document.body.appendChild(container)
    })

    it('focuses the first focusable element and returns true', () => {
      container.innerHTML = '<button>A</button><button>B</button>'
      container.querySelectorAll('button').forEach(makeVisible)
      const result = focusFirst(container)
      expect(result).toBe(true)
      expect(document.activeElement).toBe(container.querySelector('button'))
    })

    it('returns false when container has no focusable elements', () => {
      container.innerHTML = '<p>Nothing</p>'
      const result = focusFirst(container)
      expect(result).toBe(false)
    })
  })

  describe('FocusTrap', () => {
    let container, first, last

    beforeEach(() => {
      container = document.createElement('div')
      container.innerHTML = '<button>First</button><button>Last</button>'
      document.body.appendChild(container)
      ;[first, last] = container.querySelectorAll('button')
      makeVisible(first)
      makeVisible(last)
    })

    describe('activate', () => {
      it('saves previouslyFocused and sets isActive', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        expect(trap.isActive).toBe(true)
        expect(trap.previouslyFocused).not.toBeNull()
      })

      it('focuses the first focusable element', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        expect(document.activeElement).toBe(first)
      })

      it('focuses initialFocus option when provided', () => {
        const trap = new FocusTrap(container, { initialFocus: last })
        trap.activate()
        expect(document.activeElement).toBe(last)
      })

      it('is a no-op when already active', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        const savedElement = trap.previouslyFocused
        trap.activate()
        expect(trap.previouslyFocused).toBe(savedElement)
      })
    })

    describe('deactivate', () => {
      it('sets isActive to false', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        trap.deactivate()
        expect(trap.isActive).toBe(false)
      })

      it('restores focus to previouslyFocused', () => {
        const trigger = document.createElement('button')
        makeVisible(trigger)
        document.body.appendChild(trigger)
        trigger.focus()

        const trap = new FocusTrap(container)
        trap.activate()
        trap.deactivate()
        expect(document.activeElement).toBe(trigger)
      })

      it('restores focus to returnFocus option when provided', () => {
        const returnEl = document.createElement('button')
        makeVisible(returnEl)
        document.body.appendChild(returnEl)

        const trap = new FocusTrap(container, { returnFocus: returnEl })
        trap.activate()
        trap.deactivate()
        expect(document.activeElement).toBe(returnEl)
      })

      it('skips focus restore when previously focused element is not visible', () => {
        const trigger = document.createElement('button')
        // not made visible — isVisible returns false
        document.body.appendChild(trigger)
        trigger.focus()

        const trap = new FocusTrap(container)
        trap.activate()
        const focusSpy = vi.spyOn(trigger, 'focus')
        trap.deactivate()
        expect(focusSpy).not.toHaveBeenCalled()
      })

      it('is a no-op when not active', () => {
        const trap = new FocusTrap(container)
        expect(() => trap.deactivate()).not.toThrow()
        expect(trap.isActive).toBe(false)
      })

      it('calls onDeactivate callback when deactivate() is called', () => {
        const container = document.createElement('div')
        const btn = document.createElement('button')
        makeVisible(btn)
        container.appendChild(btn)
        document.body.appendChild(container)

        const onDeactivate = vi.fn()
        const trap = new FocusTrap(container, { onDeactivate })
        trap.activate()
        trap.deactivate()

        expect(onDeactivate).toHaveBeenCalledOnce()
      })

      it('does not call onDeactivate twice when deactivate is re-entered via callback', () => {
        const container = document.createElement('div')
        const btn = document.createElement('button')
        makeVisible(btn)
        container.appendChild(btn)
        document.body.appendChild(container)

        const onDeactivate = vi.fn(() => trap.deactivate()) // re-entrant call
        const trap = new FocusTrap(container, { onDeactivate })
        trap.activate()
        trap.deactivate()

        expect(onDeactivate).toHaveBeenCalledOnce() // guard works
      })
    })

    describe('handleKeyDown — Tab wrapping', () => {
      it('wraps Tab from last element to first', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        last.focus()

        const event = new KeyboardEvent('keydown', { key: 'Tab', shiftKey: false, bubbles: true, cancelable: true })
        const spy = vi.spyOn(event, 'preventDefault')
        container.dispatchEvent(event)

        expect(spy).toHaveBeenCalled()
        expect(document.activeElement).toBe(first)
      })

      it('wraps Shift+Tab from first element to last', () => {
        const trap = new FocusTrap(container)
        trap.activate()
        first.focus()

        const event = new KeyboardEvent('keydown', { key: 'Tab', shiftKey: true, bubbles: true, cancelable: true })
        const spy = vi.spyOn(event, 'preventDefault')
        container.dispatchEvent(event)

        expect(spy).toHaveBeenCalled()
        expect(document.activeElement).toBe(last)
      })

      it('does not preventDefault for Tab from a middle element', () => {
        const middle = document.createElement('button')
        makeVisible(middle)
        container.insertBefore(middle, last)

        const trap = new FocusTrap(container)
        trap.activate()
        middle.focus()

        const event = new KeyboardEvent('keydown', { key: 'Tab', shiftKey: false, bubbles: true, cancelable: true })
        const spy = vi.spyOn(event, 'preventDefault')
        container.dispatchEvent(event)

        expect(spy).not.toHaveBeenCalled()
      })

      it('is a no-op when container has no focusable elements', () => {
        const empty = document.createElement('div')
        document.body.appendChild(empty)
        const trap = new FocusTrap(empty)
        trap.activate()

        const event = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true, cancelable: true })
        expect(() => empty.dispatchEvent(event)).not.toThrow()
      })
    })

    describe('handleKeyDown — Escape', () => {
      it('calls deactivate and preventDefault when escapeDeactivates is true', () => {
        const trap = new FocusTrap(container, { escapeDeactivates: true })
        trap.activate()

        const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
        const preventSpy = vi.spyOn(event, 'preventDefault')
        const deactivateSpy = vi.spyOn(trap, 'deactivate')
        container.dispatchEvent(event)

        expect(preventSpy).toHaveBeenCalled()
        expect(deactivateSpy).toHaveBeenCalled()
      })

      it('ignores Escape when escapeDeactivates is not set', () => {
        const trap = new FocusTrap(container)
        trap.activate()

        const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true })
        const deactivateSpy = vi.spyOn(trap, 'deactivate')
        container.dispatchEvent(event)

        expect(deactivateSpy).not.toHaveBeenCalled()
      })
    })
  })
})
