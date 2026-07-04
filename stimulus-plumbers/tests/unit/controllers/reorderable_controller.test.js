import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ReorderableController from '../../../src/controllers/reorderable_controller';

describe('ReorderableController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('reorderable', ReorderableController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const HANDLE_ACTIONS =
    'pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp';

  const buildHTML = () => `
    <ul data-controller="reorderable" data-reorderable-editing-value="true">
      <li id="row-a" data-reorderable-target="item" tabindex="0">
        <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>A
      </li>
      <li id="row-b" data-reorderable-target="item" tabindex="-1">
        <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>B
      </li>
      <li id="row-c" data-reorderable-target="item" tabindex="-1">
        <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>C
      </li>
    </ul>
  `;

  const setup = async (html = buildHTML()) => {
    document.body.innerHTML = html;
    await new Promise((resolve) => setTimeout(resolve, 10));
    return document.querySelector('[data-controller="reorderable"]');
  };

  describe('roving tabindex (plain arrows)', () => {
    it('moves focus without reordering', async () => {
      const element = await setup();
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      items()[0].focus();

      items()[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true }));

      expect(document.activeElement.id).toBe('row-b');
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
    });
  });

  describe('keyboard move (Alt+Arrow)', () => {
    it('reorders the DOM and refocuses the moved item', async () => {
      const element = await setup();
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
      expect(document.activeElement.id).toBe('row-a');
      expect(items()[Array.from(items()).findIndex((i) => i.id === 'row-a')].tabIndex).toBe(0);
    });

    it('dispatches reorderable:reordered', async () => {
      const element = await setup();
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      const spy = vi.fn();
      element.addEventListener('reorderable:reordered', spy);
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.itemIds).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('reorders correctly even if RovingTabIndex is activated before Reorderable attaches (order independence)', async () => {
      document.body.innerHTML = buildHTML();
      const element = document.querySelector('[data-controller="reorderable"]');
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      // Simulate the reverse of connect()'s current order directly against the plumber
      // API to prove the fix: RovingTabIndex no longer needs to lose the race.
      const { RovingTabIndex } = await import('../../../src/accessibility/keyboard');
      const { attachReorderable } = await import('../../../src/plumbers/reorderable');
      const rti = new RovingTabIndex(Array.from(items()), { orientation: 'vertical' });
      rti.activate();
      const reorderable = attachReorderable({ itemTargets: Array.from(items()), dispatch: () => true }, {});
      items().forEach((item) => reorderable.attachItem(item));

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });
  });

  describe('pointer drag', () => {
    const rectFor = (top) => ({ top, bottom: top + 40, height: 40, left: 0, right: 100, width: 100, x: 0, y: top });

    const stubRects = (element) => {
      const items = element.querySelectorAll('[data-reorderable-target="item"]');
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => rectFor(i * 40);
      });
      return items;
    };

    it('reorders the DOM and dispatches reorderable:reordered without moving focus', async () => {
      const element = await setup();
      const items = stubRects(element);
      const handle = items[0].querySelector('[data-reorderable-target="handle"]');
      handle.setPointerCapture = vi.fn();
      handle.releasePointerCapture = vi.fn();
      const spy = vi.fn();
      element.addEventListener('reorderable:reordered', spy);

      handle.dispatchEvent(new PointerEvent('pointerdown', { pointerId: 1, bubbles: true }));
      // row-b occupies y:40-80, midpoint 60 — cross it to trigger the swap
      handle.dispatchEvent(new PointerEvent('pointermove', { pointerId: 1, clientY: 61, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointerup', { pointerId: 1, bubbles: true }));

      const reordered = element.querySelectorAll('[data-reorderable-target="item"]');
      const order = Array.from(reordered).map((i) => i.id);
      expect(order).toEqual(['row-b', 'row-a', 'row-c']);
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.itemIds).toEqual(['row-b', 'row-a', 'row-c']);
      // A pointer drag must not steal focus (unlike a keyboard move, see spec Approach)
      expect(Array.from(reordered)).not.toContain(document.activeElement);
    });
  });

  describe('orientation="horizontal"', () => {
    const buildHorizontalHTML = () => `
      <ul data-controller="reorderable" data-reorderable-editing-value="true" data-reorderable-orientation-value="horizontal">
        <li id="row-a" data-reorderable-target="item" tabindex="0">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>A
        </li>
        <li id="row-b" data-reorderable-target="item" tabindex="-1">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>B
        </li>
        <li id="row-c" data-reorderable-target="item" tabindex="-1">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>C
        </li>
      </ul>
    `;

    it('moves the item on Alt+ArrowRight and ignores Alt+ArrowDown', async () => {
      const element = await setup(buildHorizontalHTML());
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowRight', altKey: true, bubbles: true, cancelable: true })
      );
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('reorders via x-midpoint comparison while dragging', async () => {
      const element = await setup(buildHorizontalHTML());
      const items = element.querySelectorAll('[data-reorderable-target="item"]');
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => ({
          left: i * 100, right: i * 100 + 100, width: 100, top: 0, bottom: 40, height: 40, x: i * 100, y: 0,
        });
      });
      const handle = items[0].querySelector('[data-reorderable-target="handle"]');
      handle.setPointerCapture = vi.fn();
      handle.releasePointerCapture = vi.fn();

      handle.dispatchEvent(new PointerEvent('pointerdown', { pointerId: 1, bubbles: true }));
      // row-b occupies x:100-200, midpoint 150 — cross it to trigger the swap
      handle.dispatchEvent(new PointerEvent('pointermove', { pointerId: 1, clientX: 151, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointerup', { pointerId: 1, bubbles: true }));

      const reordered = element.querySelectorAll('[data-reorderable-target="item"]');
      expect(Array.from(reordered).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });
  });

  describe('editing mode', () => {
    const buildEditingHTML = (editing) => `
      <ul data-controller="reorderable" data-reorderable-editing-value="${editing}">
        <li id="row-a" data-reorderable-target="item" tabindex="0">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>
          <a href="/a" data-reorderable-target="trigger">A</a>
        </li>
        <li id="row-b" data-reorderable-target="item" tabindex="-1">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>
          <a href="/b" data-reorderable-target="trigger">B</a>
        </li>
      </ul>
    `;

    it('defaults to not editing — Alt+Arrow does not reorder', async () => {
      const element = await setup(buildEditingHTML(false));
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-a', 'row-b']);
    });

    it('defaults to not editing — pointer drag does not reorder', async () => {
      const element = await setup(buildEditingHTML(false));
      const items = element.querySelectorAll('[data-reorderable-target="item"]');
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => ({
          top: i * 40, bottom: i * 40 + 40, height: 40, left: 0, right: 100, width: 100, x: 0, y: i * 40,
        });
      });
      const handle = items[0].querySelector('[data-reorderable-target="handle"]');
      handle.setPointerCapture = vi.fn();
      handle.releasePointerCapture = vi.fn();

      handle.dispatchEvent(new PointerEvent('pointerdown', { pointerId: 1, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointermove', { pointerId: 1, clientY: 61, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointerup', { pointerId: 1, bubbles: true }));

      const reordered = element.querySelectorAll('[data-reorderable-target="item"]');
      expect(Array.from(reordered).map((i) => i.id)).toEqual(['row-a', 'row-b']);
    });

    it('sets aria-disabled=false on triggers initially, toggleEditing enables reordering and disables triggers', async () => {
      const element = await setup(buildEditingHTML(false));
      const controller = application.getControllerForElementAndIdentifier(element, 'reorderable');
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      const triggers = () => element.querySelectorAll('[data-reorderable-target="trigger"]');

      expect(triggers()[0].getAttribute('aria-disabled')).toBe('false');

      controller.toggleEditing();
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(triggers()[0].getAttribute('aria-disabled')).toBe('true');
      expect(triggers()[0].tabIndex).toBe(-1);

      items()[0].focus();
      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a']);
    });

    it('enterEditing/exitEditing set editingValue explicitly', async () => {
      const element = await setup(buildEditingHTML(false));
      const controller = application.getControllerForElementAndIdentifier(element, 'reorderable');

      controller.enterEditing();
      expect(controller.editingValue).toBe(true);

      controller.exitEditing();
      expect(controller.editingValue).toBe(false);
    });
  });
});
