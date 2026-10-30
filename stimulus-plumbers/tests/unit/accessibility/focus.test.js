import { describe, it, expect, beforeEach, vi } from 'vitest';
import { FOCUSABLE_SELECTOR, getFocusableElements, isVisible, focusFirst } from '../../../src/accessibility/focus';

// jsdom returns offsetWidth=0 and getClientRects()=[] for all elements.
// Override getClientRects on an element to make isVisible() return true.
function makeVisible(el) {
  el.getClientRects = () => [{}];
}

describe('focus', () => {
  describe('FOCUSABLE_SELECTOR', () => {
    it('is a non-empty string', () => {
      expect(typeof FOCUSABLE_SELECTOR).toBe('string');
      expect(FOCUSABLE_SELECTOR.length).toBeGreaterThan(0);
    });

    it('includes button, input, a[href], and [tabindex] selectors', () => {
      expect(FOCUSABLE_SELECTOR).toContain('button');
      expect(FOCUSABLE_SELECTOR).toContain('input');
      expect(FOCUSABLE_SELECTOR).toContain('a[href]');
      expect(FOCUSABLE_SELECTOR).toContain('[tabindex]');
    });
  });

  describe('isVisible', () => {
    it('returns true when offsetWidth is non-zero', () => {
      const el = document.createElement('div');
      Object.defineProperty(el, 'offsetWidth', { get: () => 10, configurable: true });
      expect(isVisible(el)).toBe(true);
    });

    it('returns true when offsetHeight is non-zero', () => {
      const el = document.createElement('div');
      Object.defineProperty(el, 'offsetHeight', { get: () => 10, configurable: true });
      expect(isVisible(el)).toBe(true);
    });

    it('returns true when getClientRects returns a non-empty array', () => {
      const el = document.createElement('div');
      makeVisible(el);
      expect(isVisible(el)).toBe(true);
    });

    it('returns false when all dimensions are zero and no client rects', () => {
      const el = document.createElement('div');
      // jsdom default: offsetWidth=0, offsetHeight=0, getClientRects()=[]
      expect(isVisible(el)).toBe(false);
    });
  });

  describe('getFocusableElements', () => {
    let container;

    beforeEach(() => {
      container = document.createElement('div');
      document.body.appendChild(container);
    });

    it('returns visible focusable elements', () => {
      container.innerHTML = '<button>A</button><button>B</button>';
      container.querySelectorAll('button').forEach(makeVisible);
      const els = getFocusableElements(container);
      expect(els.length).toBe(2);
    });

    it('excludes non-semantic elements with tabindex="-1"', () => {
      container.innerHTML = '<div tabindex="-1">Skip</div><button>Keep</button>';
      container.querySelectorAll('div, button').forEach(makeVisible);
      const els = getFocusableElements(container);
      expect(els.length).toBe(1);
      expect(els[0].textContent).toBe('Keep');
    });

    it('excludes disabled inputs', () => {
      container.innerHTML = '<input disabled><input>';
      container.querySelectorAll('input').forEach(makeVisible);
      const els = getFocusableElements(container);
      expect(els.length).toBe(1);
    });

    it('excludes invisible elements', () => {
      container.innerHTML = '<button>Hidden</button><button>Visible</button>';
      const [hidden, visible] = container.querySelectorAll('button');
      makeVisible(visible);
      // hidden button has no getClientRects override → isVisible returns false
      const els = getFocusableElements(container);
      expect(els.length).toBe(1);
      expect(els[0]).toBe(visible);
    });

    it('returns empty array when container has no focusable elements', () => {
      container.innerHTML = '<p>No focusable</p>';
      expect(getFocusableElements(container).length).toBe(0);
    });
  });

  describe('focusFirst', () => {
    let container;

    beforeEach(() => {
      container = document.createElement('div');
      document.body.appendChild(container);
    });

    it('focuses the first focusable element and returns true', () => {
      container.innerHTML = '<button>A</button><button>B</button>';
      container.querySelectorAll('button').forEach(makeVisible);
      const result = focusFirst(container);
      expect(result).toBe(true);
      expect(document.activeElement).toBe(container.querySelector('button'));
    });

    it('returns false when container has no focusable elements', () => {
      container.innerHTML = '<p>Nothing</p>';
      const result = focusFirst(container);
      expect(result).toBe(false);
    });
  });
});
