import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Flipper, attachFlipper } from '../../../src/plumbers/flipper';

describe('Flipper', () => {
  let mockController;
  let element;
  let anchor;

  beforeEach(() => {
    element = document.createElement('div');
    anchor = document.createElement('button');
    document.body.appendChild(element);
    document.body.appendChild(anchor);

    mockController = {
      identifier: 'flipper',
      element: element,
      dispatch: vi.fn(() => true),
    };

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
    });

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
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('callbacks', () => {
    it('calls the controller flipped method by default', async () => {
      mockController.flipped = vi.fn();
      const flipper = new Flipper(mockController, { anchor });

      await flipper.flip();

      expect(mockController.flipped).toHaveBeenCalledWith(expect.objectContaining({ target: element }));
    });

    it('calls the onFlipped method it is given', async () => {
      mockController.customFlipped = vi.fn();
      const flipper = new Flipper(mockController, { anchor, onFlipped: 'customFlipped' });

      await flipper.flip();

      expect(mockController.customFlipped).toHaveBeenCalledOnce();
    });
  });

  describe('fits', () => {
    it('returns true when big rect is larger in both dimensions', () => {
      const flipper = new Flipper(mockController, { anchor });
      const big = { width: 200, height: 200 };
      const small = { width: 100, height: 100 };

      expect(flipper.fits(big, small)).toBe(true);
    });

    it('returns false when big rect is smaller in width', () => {
      const flipper = new Flipper(mockController, { anchor });
      const big = { width: 50, height: 200 };
      const small = { width: 100, height: 100 };

      expect(flipper.fits(big, small)).toBe(false);
    });

    it('returns false when big rect is smaller in height', () => {
      const flipper = new Flipper(mockController, { anchor });
      const big = { width: 200, height: 50 };
      const small = { width: 100, height: 100 };

      expect(flipper.fits(big, small)).toBe(false);
    });

    it('returns true when dimensions are equal', () => {
      const flipper = new Flipper(mockController, { anchor });
      const big = { width: 100, height: 100 };
      const small = { width: 100, height: 100 };

      expect(flipper.fits(big, small)).toBe(true);
    });
  });

  describe('spaceAround', () => {
    it('calculates available space in all four directions', () => {
      const flipper = new Flipper(mockController, { anchor });
      const inner = {
        x: 100,
        y: 100,
        width: 50,
        height: 50,
      };
      const outer = {
        x: 0,
        y: 0,
        width: 300,
        height: 300,
      };

      const space = flipper.spaceAround(inner, outer);

      expect(space.left.width).toBe(100);
      expect(space.right.width).toBe(150);
      expect(space.top.height).toBe(100);
      expect(space.bottom.height).toBe(150);
    });
  });

  describe('placeOn', () => {
    it('places element at top of anchor', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { width: 200, height: 100 };

      const placement = flipper.placeOn('top', anchorRect, reference);

      expect(placement.y).toBe(0); // 100 - 100
      expect(placement.height).toBe(100);
    });

    it('places element at bottom of anchor', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { width: 200, height: 100 };

      const placement = flipper.placeOn('bottom', anchorRect, reference);

      expect(placement.y).toBe(150); // 100 + 50
      expect(placement.height).toBe(100);
    });

    it('places element to left of anchor', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { width: 80, height: 100 };

      const placement = flipper.placeOn('left', anchorRect, reference);

      expect(placement.x).toBe(20); // 100 - 80
      expect(placement.width).toBe(80);
    });

    it('places element to right of anchor', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { width: 80, height: 100 };

      const placement = flipper.placeOn('right', anchorRect, reference);

      expect(placement.x).toBe(150); // 100 + 50
      expect(placement.width).toBe(80);
    });

    it('throws error for invalid direction', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { width: 80, height: 100 };

      expect(() => flipper.placeOn('invalid', anchorRect, reference)).toThrow();
    });
  });

  describe('alignOn', () => {
    it('aligns to start for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'start' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 0, y: 200, width: 80, height: 100 };

      const aligned = flipper.alignOn('bottom', anchorRect, reference);

      expect(aligned.x).toBe(100);
    });

    it('aligns to center for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'center' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 0, y: 200, width: 80, height: 100 };

      const aligned = flipper.alignOn('bottom', anchorRect, reference);

      expect(aligned.x).toBe(85); // 100 + 50/2 - 80/2
    });

    it('aligns to end for top/bottom placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'end' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 0, y: 200, width: 80, height: 100 };

      const aligned = flipper.alignOn('bottom', anchorRect, reference);

      expect(aligned.x).toBe(70); // 100 + 50 - 80
    });

    it('aligns to start for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'start' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 150, y: 0, width: 80, height: 100 };

      const aligned = flipper.alignOn('right', anchorRect, reference);

      expect(aligned.y).toBe(100);
    });

    it('aligns to center for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'center' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 150, y: 0, width: 80, height: 100 };

      const aligned = flipper.alignOn('right', anchorRect, reference);

      expect(aligned.y).toBe(75); // 100 + 50/2 - 100/2
    });

    it('aligns to end for left/right placement', () => {
      const flipper = new Flipper(mockController, { anchor, alignment: 'end' });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 150, y: 0, width: 80, height: 100 };

      const aligned = flipper.alignOn('right', anchorRect, reference);

      expect(aligned.y).toBe(50); // 100 + 50 - 100
    });

    it('throws error for invalid direction', () => {
      const flipper = new Flipper(mockController, { anchor });
      const anchorRect = { x: 100, y: 100, width: 50, height: 50 };
      const reference = { x: 150, y: 0, width: 80, height: 100 };

      expect(() => flipper.alignOn('invalid', anchorRect, reference)).toThrow();
    });
  });

  describe('flip', () => {
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

      const flipper = new Flipper(mockController, { anchor, respectMotion: true });

      await flipper.flip();

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

      const flipper = new Flipper(mockController, { anchor, respectMotion: false });

      await flipper.flip();

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

      const flipper = new Flipper(mockController, { anchor, respectMotion: true });

      await flipper.flip();

      expect(element.style.transition).toBe('');

      window.matchMedia = originalMatchMedia;
    });
  });

  describe('observe', () => {
    it('repositions on every configured event', () => {
      new Flipper(mockController, { anchor, events: ['click', 'focus'] });

      window.dispatchEvent(new Event('click'));
      window.dispatchEvent(new Event('focus'));

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'flip')).toHaveLength(2);
    });
  });

  describe('resize and scroll', () => {
    let frames;
    let spies;

    beforeEach(() => {
      frames = new Map();
      let id = 0;
      spies = [
        vi.spyOn(window, 'requestAnimationFrame').mockImplementation((callback) => {
          frames.set(++id, callback);
          return id;
        }),
        vi.spyOn(window, 'cancelAnimationFrame').mockImplementation((frame) => frames.delete(frame)),
      ];
    });

    afterEach(() => spies.forEach((spy) => spy.mockRestore()));

    const runFrames = () => {
      const pending = [...frames.values()];
      frames.clear();
      pending.forEach((callback) => callback());
    };
    const flips = () => mockController.dispatch.mock.calls.filter(([name]) => name === 'flip');

    it('repositions once per frame for a burst of events', () => {
      new Flipper(mockController, { anchor });

      window.dispatchEvent(new Event('scroll'));
      window.dispatchEvent(new Event('scroll'));
      window.dispatchEvent(new Event('resize'));
      runFrames();

      expect(flips()).toHaveLength(1);
    });

    it('repositions again for a burst after the frame runs', () => {
      new Flipper(mockController, { anchor });

      window.dispatchEvent(new Event('scroll'));
      runFrames();
      window.dispatchEvent(new Event('scroll'));
      runFrames();

      expect(flips()).toHaveLength(2);
    });

    it('repositions on a scroll inside a container', () => {
      new Flipper(mockController, { anchor });
      const container = document.body.appendChild(document.createElement('div'));

      container.dispatchEvent(new Event('scroll'));
      runFrames();

      expect(flips()).toHaveLength(1);
    });

    it('drops a pending repositioning on disconnect', () => {
      const flipper = new Flipper(mockController, { anchor });

      window.dispatchEvent(new Event('scroll'));
      flipper.disconnect();
      runFrames();

      expect(flips()).toHaveLength(0);
    });
  });

  describe('disconnect', () => {
    it('stops repositioning on window events', () => {
      const flipper = new Flipper(mockController, { anchor });

      flipper.disconnect();
      window.dispatchEvent(new Event('resize'));

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('attachFlipper', () => {
    it('creates and returns a Flipper instance', () => {
      const flipper = attachFlipper(mockController, {
        anchor,
        placement: 'top',
      });

      expect(flipper).toBeInstanceOf(Flipper);
      expect(flipper.placement).toBe('top');
    });
  });
});
