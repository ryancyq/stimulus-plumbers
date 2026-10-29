import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Reorderable, attachReorderable } from '../../../src/plumbers/reorderable';
import { advance, autoDisconnect } from '../../support/stimulus';

// A real element, so the plumber can listen for pointercancel/lostpointercapture on it.
const makeHandle = () =>
  Object.assign(document.createElement('span'), {
    setPointerCapture: vi.fn(),
    releasePointerCapture: vi.fn(),
    hasPointerCapture: vi.fn(() => true),
  });

describe('Reorderable', () => {
  let mockController;
  let items;
  const createReorderable = (options) => autoDisconnect(new Reorderable(mockController, options));

  beforeEach(() => {
    document.body.innerHTML = `
      <ul id="list">
        <li id="row-a" tabindex="0">A</li>
        <li id="row-b" tabindex="-1">B</li>
        <li id="row-c" tabindex="-1">C</li>
      </ul>
    `;
    items = Array.from(document.querySelectorAll('li'));
    mockController = {
      identifier: 'reorderable',
      element: document.getElementById('list'),
      editingValue: true,
      // Getter, not a static array — mirrors Stimulus's real `itemTargets`, which
      // re-queries the DOM on every access. A plain array here would never reflect
      // the `.before()`/`.after()` DOM mutations the plumber performs.
      get itemTargets() {
        return Array.from(document.querySelectorAll('#list li'));
      },
      dispatch: vi.fn(() => true),
      moved: vi.fn(),
    };
  });

  describe('constructor', () => {
    it('defaults moveKey to Alt', () => {
      const reorderable = createReorderable();
      expect(reorderable.moveKey).toBe('Alt');
    });

    it('falls back to Alt for an unrecognized moveKey', () => {
      const reorderable = createReorderable({ moveKey: 'Nonsense' });
      expect(reorderable.moveKey).toBe('Alt');
    });

    it('accepts Control/Shift/Meta as moveKey', () => {
      const reorderable = createReorderable({ moveKey: 'Control' });
      expect(reorderable.moveKey).toBe('Control');
    });
  });

  describe('items', () => {
    it('reads the current itemTargets from the controller', () => {
      const reorderable = createReorderable();
      expect(reorderable.items).toEqual(items);
    });
  });

  describe('orderedIds', () => {
    it('returns ids in DOM order', () => {
      const reorderable = createReorderable();
      expect(reorderable.orderedIds()).toEqual(['row-a', 'row-b', 'row-c']);
    });

    it('excludes items without an id', () => {
      items[1].removeAttribute('id');
      const reorderable = createReorderable();
      expect(reorderable.orderedIds()).toEqual(['row-a', 'row-c']);
    });
  });

  describe('keyboard move via attachItem', () => {
    it('swaps the item down on Alt+ArrowDown, dispatches, and announces', async () => {
      vi.useFakeTimers();
      const reorderable = createReorderable({ onMoved: 'moved' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      const newOrder = mockController.itemTargets.map((i) => i.id);
      expect(newOrder).toEqual(['row-b', 'row-a', 'row-c']);
      // Plumber#dispatch (base class) calls controller.dispatch(name, { target, prefix, detail }) —
      // only `detail` is asserted here, target/prefix are the base class's own concern.
      expect(mockController.dispatch).toHaveBeenCalledWith(
        'reordered',
        expect.objectContaining({ detail: { itemIds: ['row-b', 'row-a', 'row-c'] } })
      );
      expect(mockController.moved).toHaveBeenCalledWith(items[0]);

      const liveRegion = document.querySelector('[aria-live]');
      // aria.js announce() uses setTimeout(100) to set textContent
      await advance(150);
      expect(liveRegion?.textContent).toBe('Moved to position 2 of 3');
    });

    it('does not move past the first item', () => {
      const reorderable = createReorderable();
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowUp', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('ignores plain ArrowDown without the modifier', () => {
      const reorderable = createReorderable();
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true }));

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('does nothing when controller.editingValue is false', () => {
      mockController.editingValue = false;
      const reorderable = createReorderable();
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('ignores a repeated keydown (OS key-repeat) — no move, no dispatch, no announce', () => {
      const reorderable = createReorderable({ onMoved: 'moved' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, repeat: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
      expect(mockController.moved).not.toHaveBeenCalled();
    });
  });

  describe('detachItem', () => {
    it('stops handling keydown after detaching', () => {
      const reorderable = createReorderable();
      reorderable.attachItem(items[0]);
      reorderable.detachItem(items[0]);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('attachItems / detachItems', () => {
    it('attaches keydown handling to every item in one call', () => {
      const reorderable = createReorderable();
      reorderable.attachItems(items);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('detaches keydown handling from every item in one call', () => {
      const reorderable = createReorderable();
      reorderable.attachItems(items);
      reorderable.detachItems(items);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('disconnect', () => {
    it('stops keyboard moves and forgets an active drag, and is idempotent', () => {
      const reorderable = createReorderable();
      const handle = makeHandle();
      reorderable.attachItems(items);
      reorderable.startDrag(items[0], handle, 1);

      reorderable.disconnect();
      reorderable.disconnect();
      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(reorderable.endDrag(handle, 1)).toBeNull();
    });
  });

  describe('attachReorderable', () => {
    it('returns a Reorderable instance', () => {
      expect(autoDisconnect(attachReorderable(mockController))).toBeInstanceOf(Reorderable);
    });
  });

  describe('pointer drag', () => {
    const rectFor = (top) => ({ top, bottom: top + 40, height: 40, left: 0, right: 100, width: 100, x: 0, y: top });

    const stubRects = () => {
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => rectFor(i * 40);
      });
    };

    it('does nothing before startDrag is called', () => {
      stubRects();
      const reorderable = createReorderable();

      reorderable.drag({ clientY: 61 });

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
    });

    it('swaps the dragging item past a neighbor once the pointer crosses its midpoint', () => {
      stubRects();
      const reorderable = createReorderable();
      const handle = makeHandle();

      reorderable.startDrag(items[0], handle, 1);
      // row-b occupies y:40-80, midpoint 60 — cross it to trigger the swap
      reorderable.drag({ clientY: 61 });

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
      expect(handle.setPointerCapture).toHaveBeenCalledWith(1);
    });

    it('dispatches reorderable:reordered on endDrag', () => {
      stubRects();
      const reorderable = createReorderable();
      const handle = makeHandle();

      reorderable.startDrag(items[0], handle, 1);
      reorderable.drag({ clientY: 61 });
      const moved = reorderable.endDrag(handle, 1);

      expect(handle.releasePointerCapture).toHaveBeenCalledWith(1);
      expect(mockController.dispatch).toHaveBeenCalledWith(
        'reordered',
        expect.objectContaining({ detail: { itemIds: ['row-b', 'row-a', 'row-c'] } })
      );
      expect(moved.id).toBe('row-a');
    });

    it('endDrag is a no-op without a preceding startDrag', () => {
      const reorderable = createReorderable();
      const handle = makeHandle();

      const moved = reorderable.endDrag(handle, 1);

      expect(moved).toBeNull();
      expect(handle.releasePointerCapture).not.toHaveBeenCalled();
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    describe('interrupted drag', () => {
      const order = () => mockController.itemTargets.map((i) => i.id);

      it.each(['pointercancel', 'lostpointercapture'])(
        'restores the starting order without dispatching on %s',
        (type) => {
          stubRects();
          const reorderable = createReorderable();
          const handle = makeHandle();

          reorderable.startDrag(items[0], handle, 1);
          reorderable.drag({ clientY: 61 });
          handle.dispatchEvent(new Event(type));

          expect(order()).toEqual(['row-a', 'row-b', 'row-c']);
          expect(mockController.dispatch).not.toHaveBeenCalled();
        }
      );

      it('stops reordering on later pointer moves once cancelled', () => {
        stubRects();
        const reorderable = createReorderable();
        const handle = makeHandle();

        reorderable.startDrag(items[0], handle, 1);
        handle.dispatchEvent(new Event('pointercancel'));
        reorderable.drag({ clientY: 61 });

        expect(order()).toEqual(['row-a', 'row-b', 'row-c']);
      });

      it('restores an item dragged back past several neighbors', () => {
        stubRects();
        const reorderable = createReorderable();
        const handle = makeHandle();

        reorderable.startDrag(items[2], handle, 1);
        reorderable.drag({ clientY: 59 });
        reorderable.drag({ clientY: 19 });
        expect(order()).toEqual(['row-c', 'row-a', 'row-b']);
        reorderable.cancelDrag();

        expect(order()).toEqual(['row-a', 'row-b', 'row-c']);
      });

      it('releases capture on cancel', () => {
        const reorderable = createReorderable();
        const handle = makeHandle();

        reorderable.startDrag(items[0], handle, 1);
        reorderable.cancelDrag();

        expect(handle.releasePointerCapture).toHaveBeenCalledWith(1);
      });

      it('ignores the lostpointercapture that follows a completed drag', () => {
        stubRects();
        const reorderable = createReorderable();
        const handle = makeHandle();

        reorderable.startDrag(items[0], handle, 1);
        reorderable.drag({ clientY: 61 });
        reorderable.endDrag(handle, 1);
        handle.dispatchEvent(new Event('lostpointercapture'));

        expect(order()).toEqual(['row-b', 'row-a', 'row-c']);
        expect(mockController.dispatch).toHaveBeenCalledTimes(1);
      });

      it('keeps the dragging item in the DOM while neighbors move past it', () => {
        stubRects();
        const reorderable = createReorderable();
        const handle = makeHandle();
        const observer = new MutationObserver(() => {});
        observer.observe(document.getElementById('list'), { childList: true });

        reorderable.startDrag(items[0], handle, 1);
        reorderable.drag({ clientY: 61 });
        const removed = observer.takeRecords().flatMap((record) => [...record.removedNodes]);
        observer.disconnect();

        expect(removed).not.toContain(items[0]);
      });

      it('disconnect forgets the drag without moving items back', () => {
        stubRects();
        const reorderable = createReorderable();
        const handle = makeHandle();

        reorderable.startDrag(items[0], handle, 1);
        reorderable.drag({ clientY: 61 });
        reorderable.disconnect();
        handle.dispatchEvent(new Event('pointercancel'));

        expect(order()).toEqual(['row-b', 'row-a', 'row-c']);
        expect(reorderable.endDrag(handle, 1)).toBeNull();
      });
    });

    it('does not announce on drag (mouse users should not have focus stolen)', async () => {
      vi.useFakeTimers();
      stubRects();
      const reorderable = createReorderable();
      const handle = makeHandle();

      reorderable.startDrag(items[0], handle, 1);
      reorderable.drag({ clientY: 61 });
      reorderable.endDrag(handle, 1);

      await advance(150);
      const liveRegion = document.querySelector('[aria-live]');
      expect(liveRegion?.textContent).toBeFalsy();
    });
  });

  describe('horizontal orientation', () => {
    const rectFor = (left) => ({ left, right: left + 100, width: 100, top: 0, bottom: 40, height: 40, x: left, y: 0 });

    const stubRects = () => {
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => rectFor(i * 100);
      });
    };

    it('moves the item forward on Alt+ArrowRight (LTR)', () => {
      const reorderable = createReorderable({ orientation: 'horizontal' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('ignores Alt+ArrowUp/ArrowDown when orientation is horizontal', () => {
      const reorderable = createReorderable({ orientation: 'horizontal' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
    });

    it('flips ArrowLeft/ArrowRight meaning under dir="rtl"', () => {
      items.forEach((item) => item.setAttribute('dir', 'rtl'));
      const reorderable = createReorderable({ orientation: 'horizontal' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', altKey: true, bubbles: true, cancelable: true })
      );

      // ArrowRight is inert on the first item under RTL (it now means "move earlier")
      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowLeft', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('reorders via x-midpoint comparison while dragging', () => {
      stubRects();
      const reorderable = createReorderable({ orientation: 'horizontal' });
      const handle = makeHandle();

      reorderable.startDrag(items[0], handle, 1);
      // row-b occupies x:100-200, midpoint 150 — cross it to trigger the swap
      reorderable.drag({ clientX: 151 });

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });
  });
});
