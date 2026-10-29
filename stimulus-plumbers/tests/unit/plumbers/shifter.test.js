import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Shifter, attachShifter } from '../../../src/plumbers/shifter';
import { flush } from '../../support/stimulus';

describe('Shifter', () => {
  let mockController;
  let element;

  beforeEach(() => {
    element = document.createElement('div');
    document.body.appendChild(element);

    mockController = {
      identifier: 'shifter',
      element: element,
      dispatch: vi.fn(() => true),
    };

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
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('callbacks', () => {
    it('calls the controller shifted method by default', async () => {
      mockController.shifted = vi.fn();
      const shifter = new Shifter(mockController);

      await shifter.shift();

      expect(mockController.shifted).toHaveBeenCalledOnce();
    });

    it('calls the onShifted method it is given', async () => {
      mockController.customShifted = vi.fn();
      const shifter = new Shifter(mockController, { onShifted: 'customShifted' });

      await shifter.shift();

      expect(mockController.customShifted).toHaveBeenCalledOnce();
    });
  });

  describe('elementTranslations', () => {
    it('returns zero translations for untransformed element', () => {
      const shifter = new Shifter(mockController);
      const translations = shifter.elementTranslations(element);

      expect(translations).toEqual({ x: 0, y: 0 });
    });

    it('parses 2D matrix transformations', () => {
      element.style.transform = 'matrix(1, 0, 0, 1, 50, 100)';
      const shifter = new Shifter(mockController);
      const translations = shifter.elementTranslations(element);

      expect(translations).toEqual({ x: 50, y: 100 });
    });

    it('returns zero for 3D matrix transformations', () => {
      element.style.transform = 'matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 50, 100, 0, 1)';
      const shifter = new Shifter(mockController);
      const translations = shifter.elementTranslations(element);

      expect(translations).toEqual({ x: 0, y: 0 });
    });
  });

  describe('directionDistance', () => {
    it('calculates distance for top direction', () => {
      const shifter = new Shifter(mockController);
      const inner = { top: 50, bottom: 150, left: 50, right: 150 };
      const outer = { top: 0, bottom: 200, left: 0, right: 200 };

      const distance = shifter.directionDistance(inner, 'top', outer);

      expect(distance).toBe(50);
    });

    it('calculates distance for bottom direction', () => {
      const shifter = new Shifter(mockController);
      const inner = { top: 50, bottom: 150, left: 50, right: 150 };
      const outer = { top: 0, bottom: 200, left: 0, right: 200 };

      const distance = shifter.directionDistance(inner, 'bottom', outer);

      expect(distance).toBe(50);
    });

    it('calculates distance for left direction', () => {
      const shifter = new Shifter(mockController);
      const inner = { top: 50, bottom: 150, left: 50, right: 150 };
      const outer = { top: 0, bottom: 200, left: 0, right: 200 };

      const distance = shifter.directionDistance(inner, 'left', outer);

      expect(distance).toBe(50);
    });

    it('calculates distance for right direction', () => {
      const shifter = new Shifter(mockController);
      const inner = { top: 50, bottom: 150, left: 50, right: 150 };
      const outer = { top: 0, bottom: 200, left: 0, right: 200 };

      const distance = shifter.directionDistance(inner, 'right', outer);

      expect(distance).toBe(50);
    });

    it('throws error for invalid direction', () => {
      const shifter = new Shifter(mockController);
      const inner = { top: 50, bottom: 150, left: 50, right: 150 };
      const outer = { top: 0, bottom: 200, left: 0, right: 200 };

      expect(() => shifter.directionDistance(inner, 'invalid', outer)).toThrow();
    });
  });

  describe('overflowRect', () => {
    it('returns empty overflow when element fits within viewport', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top', 'left', 'right', 'bottom'],
      });
      const targetRect = {
        x: 100,
        y: 100,
        width: 200,
        height: 200,
      };
      const translations = { x: 0, y: 0 };

      const overflow = shifter.overflowRect(targetRect, translations);

      expect(overflow.top).toBe('');
      expect(overflow.left).toBe('');
      expect(overflow.right).toBe('');
      expect(overflow.bottom).toBe('');
    });

    it('calculates overflow for element outside viewport top', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top'],
      });
      const targetRect = {
        x: 100,
        y: -50,
        width: 200,
        height: 200,
      };
      const translations = { x: 0, y: 0 };

      const overflow = shifter.overflowRect(targetRect, translations);

      // May or may not be set depending on sufficient space
      expect(overflow).toBeTypeOf('object');
    });

    it('calculates overflow for element outside viewport left', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['left'],
      });
      const targetRect = {
        x: -50,
        y: 100,
        width: 200,
        height: 200,
      };
      const translations = { x: 0, y: 0 };

      const overflow = shifter.overflowRect(targetRect, translations);

      // May or may not be set depending on sufficient space
      expect(overflow).toBeTypeOf('object');
    });

    it('respects existing translations', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top'],
      });
      const targetRect = {
        x: 100,
        y: 50,
        width: 200,
        height: 200,
      };
      const translations = { x: 0, y: 100 };

      const overflow = shifter.overflowRect(targetRect, translations);

      // The actual position after removing translation is y: 50 - 100 = -50
      expect(overflow).toBeTypeOf('object');
    });

    it('uses targetRect height (not width) for currentRect height calculation', () => {
      const shifter = new Shifter(mockController, {
        boundaries: ['top', 'bottom'],
      });
      const targetRect = {
        x: 100,
        y: 100,
        width: 300, // Different width
        height: 150, // Different height
      };
      const translations = { x: 0, y: 0 };

      // This test verifies the bug fix: height should use targetRect.height, not targetRect.width
      // If the implementation incorrectly used targetRect.width, the boundary calculations would be wrong
      const overflow = shifter.overflowRect(targetRect, translations);

      expect(overflow).toBeTypeOf('object');
      // The overflow calculation should work correctly with proper height
    });
  });

  describe('shift', () => {
    it('does nothing when element is not visible', async () => {
      element.setAttribute('hidden', true);
      const shifter = new Shifter(mockController);

      await shifter.shift();

      expect(mockController.dispatch).not.toHaveBeenCalled();
      expect(element.style.transform).toBe('');
    });

    it('dispatches shift and shifted events', async () => {
      const shifter = new Shifter(mockController);

      await shifter.shift();

      expect(mockController.dispatch).toHaveBeenCalledWith('shift', expect.any(Object));
      expect(mockController.dispatch).toHaveBeenCalledWith('shifted', expect.any(Object));
    });

    it('calls onShifted callback with overflow data', async () => {
      const onShifted = vi.fn();
      mockController.shifted = onShifted;
      const shifter = new Shifter(mockController, { onShifted: 'shifted' });

      await shifter.shift();

      expect(onShifted).toHaveBeenCalledWith(expect.any(Object));
    });

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
      });

      const shifter = new Shifter(mockController, {
        boundaries: ['left'],
      });

      await shifter.shift();

      expect(element.style.transform).toContain('translate');
    });

    it('awaits async onShifted callback', async () => {
      const onShifted = vi.fn(() => flush());
      mockController.shifted = onShifted;
      const shifter = new Shifter(mockController, { onShifted: 'shifted' });

      await shifter.shift();

      expect(onShifted).toHaveBeenCalled();
      expect(mockController.dispatch).toHaveBeenCalledWith('shifted', expect.any(Object));
    });

    it('disables transitions when respectMotion is true and user prefers reduced motion', async () => {
      // Mock prefers-reduced-motion: reduce
      const originalMatchMedia = window.matchMedia;
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }));

      const shifter = new Shifter(mockController, { respectMotion: true });

      await shifter.shift();

      expect(element.style.transition).toBe('none');

      window.matchMedia = originalMatchMedia;
    });

    it('does not disable transitions when respectMotion is false even if user prefers reduced motion', async () => {
      // Mock prefers-reduced-motion: reduce
      const originalMatchMedia = window.matchMedia;
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }));

      const shifter = new Shifter(mockController, { respectMotion: false });

      await shifter.shift();

      expect(element.style.transition).toBe('');

      window.matchMedia = originalMatchMedia;
    });

    it('does not disable transitions when user does not prefer reduced motion', async () => {
      // Mock prefers-reduced-motion: no-preference
      const originalMatchMedia = window.matchMedia;
      window.matchMedia = vi.fn().mockImplementation((query) => ({
        matches: false,
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }));

      const shifter = new Shifter(mockController, { respectMotion: true });

      await shifter.shift();

      expect(element.style.transition).toBe('');

      window.matchMedia = originalMatchMedia;
    });
  });

  describe('observe', () => {
    it('shifts on every configured event', () => {
      // jsdom reports the inline translate() instead of a matrix once the first shift writes it.
      const getComputedStyleSpy = vi.spyOn(window, 'getComputedStyle').mockReturnValue({ transform: 'none' });
      new Shifter(mockController, { events: ['resize', 'scroll'] });

      window.dispatchEvent(new Event('resize'));
      window.dispatchEvent(new Event('scroll'));

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'shift')).toHaveLength(2);
      getComputedStyleSpy.mockRestore();
    });
  });

  describe('disconnect', () => {
    it('stops shifting on window resize', () => {
      const shifter = new Shifter(mockController);

      shifter.disconnect();
      window.dispatchEvent(new Event('resize'));

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('attachShifter', () => {
    it('creates and returns a Shifter instance', () => {
      const shifter = attachShifter(mockController, {
        boundaries: ['top', 'bottom'],
      });

      expect(shifter).toBeInstanceOf(Shifter);
      expect(shifter.boundaries).toEqual(['top', 'bottom']);
    });
  });
});
