# Reorderable Controller Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `reorderable` Stimulus controller + `Reorderable` plumber to `@stimulus-plumbers/controllers` that lets users drag (pointer) or keyboard-move (`Alt+ArrowUp`/`Alt+ArrowDown`) items within a single vertical list, dispatching a `reorderable:reordered` event with the new order.

**Architecture:** Following the `Calendar`/`CalendarDaySelector` precedent (`src/plumbers/calendar.js`, `src/plumbers/calendar-selector.js`), the pointer state machine, keyboard-move swap, and dispatch logic live in a new `Reorderable` plumber (`src/plumbers/reorderable.js`, extends base `Plumber`). The controller (`src/controllers/reorderable_controller.js`) stays thin: target/value declarations, a `RovingTabIndex` instance for plain Arrow/Home/End focus movement (kept in the controller — the only other `RovingTabIndex` user, `timeline_controller.js`, does the same), and adapter methods that delegate to the plumber.

**Tech Stack:** Vanilla JS, `@hotwired/stimulus`, Vitest + jsdom for unit tests.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-03-reorderable-controller-design.md` — read it before starting.
- Vertical-axis, single-list only (no orientation value, no cross-list drag) — v1 scope per spec.
- No persistence/fetch logic — only dispatches `reorderable:reordered`; app code persists.
- No placeholder/ghost element — dragged item is moved live in the DOM.
- No forced focus/announcement after a pointer drag — only after a keyboard move (see spec Approach).
- **Playwright/Tailwind visual snapshot test is out of scope for this plan** — it would require a new Tailwind theme file and sandbox ERB view in the separate `stimulus-plumbers-tailwind` package, which is a new design outside the approved "JS controller only" scope. Only Vitest unit tests are in this plan.
- Doc-update rule (project `CLAUDE.md`): controller doc, README table row, and `src/index.js`/`src/plumbers/index.js` exports must land in the same commit as the code.
- All file paths below are relative to `stimulus-plumbers/` unless stated otherwise.

---

### Task 1: `Reorderable` plumber — keyboard move + `orderedIds()`

**Files:**
- Create: `stimulus-plumbers/src/plumbers/reorderable.js`
- Test: `stimulus-plumbers/tests/unit/plumbers/reorderable.test.js`

**Interfaces:**
- Consumes: base `Plumber` (`./plumber/index.js` — constructor `(controller, options)`, inherited `this.dispatch(name, { detail })`, `this.awaitCallback(nameOrFn, ...args)`); `announce` from `../accessibility/aria`.
- Produces: `Reorderable` class with constructor `(controller, options = { moveKey: 'Alt', onMoved: null })`, getter `items` (reads `controller.itemTargets`), methods `attachItem(item)`, `detachItem(item)`, `orderedIds()` — all consumed by Task 2 (drag) and Task 3 (controller).

- [ ] **Step 1: Write the failing tests**

```javascript
// stimulus-plumbers/tests/unit/plumbers/reorderable.test.js
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { Reorderable, attachReorderable } from '../../../src/plumbers/reorderable';

describe('Reorderable', () => {
  let mockController;
  let items;

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
      // Getter, not a static array — mirrors Stimulus's real `itemTargets`, which
      // re-queries the DOM on every access. A plain array here would never reflect
      // the `.before()`/`.after()` DOM mutations the plumber performs.
      get itemTargets() {
        return Array.from(document.querySelectorAll('#list li'));
      },
      dispatch: vi.fn((name, options) => true),
      moved: vi.fn(),
    };
  });

  describe('constructor', () => {
    it('defaults moveKey to Alt', () => {
      const reorderable = new Reorderable(mockController);
      expect(reorderable.moveKey).toBe('Alt');
    });

    it('falls back to Alt for an unrecognized moveKey', () => {
      const reorderable = new Reorderable(mockController, { moveKey: 'Nonsense' });
      expect(reorderable.moveKey).toBe('Alt');
    });

    it('accepts Control/Shift/Meta as moveKey', () => {
      const reorderable = new Reorderable(mockController, { moveKey: 'Control' });
      expect(reorderable.moveKey).toBe('Control');
    });
  });

  describe('items', () => {
    it('reads the current itemTargets from the controller', () => {
      const reorderable = new Reorderable(mockController);
      expect(reorderable.items).toEqual(items);
    });
  });

  describe('orderedIds', () => {
    it('returns ids in DOM order', () => {
      const reorderable = new Reorderable(mockController);
      expect(reorderable.orderedIds()).toEqual(['row-a', 'row-b', 'row-c']);
    });

    it('excludes items without an id', () => {
      items[1].removeAttribute('id');
      const reorderable = new Reorderable(mockController);
      expect(reorderable.orderedIds()).toEqual(['row-a', 'row-c']);
    });
  });

  describe('keyboard move via attachItem', () => {
    it('swaps the item down on Alt+ArrowDown, dispatches, and announces', async () => {
      const reorderable = new Reorderable(mockController, { onMoved: 'moved' });
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
      await new Promise((r) => setTimeout(r, 150));
      expect(liveRegion?.textContent).toBe('Moved to position 2 of 3');
    });

    it('does not move past the first item', () => {
      const reorderable = new Reorderable(mockController);
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowUp', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('ignores plain ArrowDown without the modifier', () => {
      const reorderable = new Reorderable(mockController);
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true }));

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('detachItem', () => {
    it('stops handling keydown after detaching', () => {
      const reorderable = new Reorderable(mockController);
      reorderable.attachItem(items[0]);
      reorderable.detachItem(items[0]);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('attachReorderable', () => {
    it('returns a Reorderable instance', () => {
      expect(attachReorderable(mockController)).toBeInstanceOf(Reorderable);
    });
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/reorderable.test.js`
Expected: FAIL — `Cannot find module '../../../src/plumbers/reorderable'`

- [ ] **Step 3: Write the plumber**

```javascript
// stimulus-plumbers/src/plumbers/reorderable.js
import Plumber from './plumber';
import { announce } from '../accessibility/aria';

const MODIFIER_KEYS = { Alt: 'altKey', Control: 'ctrlKey', Shift: 'shiftKey', Meta: 'metaKey' };

const defaultOptions = {
  moveKey: 'Alt',
  onMoved: null,
};

export class Reorderable extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);

    const { moveKey, onMoved } = Object.assign({}, defaultOptions, options);
    this.moveKey = MODIFIER_KEYS[moveKey] ? moveKey : defaultOptions.moveKey;
    this.onMoved = onMoved;
    this.draggingItem = null;

    this.onKeydown = this.onKeydown.bind(this);
  }

  get items() {
    return this.controller.itemTargets;
  }

  attachItem(item) {
    item.addEventListener('keydown', this.onKeydown);
  }

  detachItem(item) {
    item.removeEventListener('keydown', this.onKeydown);
  }

  onKeydown(event) {
    if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;

    const items = this.items;
    const item = event.currentTarget;
    const index = items.indexOf(item);
    const targetIndex = event.key === 'ArrowUp' ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= items.length) return;

    event.preventDefault();
    event.stopImmediatePropagation();

    if (event.key === 'ArrowUp') {
      items[targetIndex].before(item);
    } else {
      items[targetIndex].after(item);
    }

    this.dispatch('reordered', { detail: { itemIds: this.orderedIds() } });
    this.awaitCallback(this.onMoved, item);
    announce(`Moved to position ${this.items.indexOf(item) + 1} of ${this.items.length}`);
  }

  orderedIds() {
    return this.items.filter((item) => item.id).map((item) => item.id);
  }
}

export const attachReorderable = (controller, options) => new Reorderable(controller, options);
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/reorderable.test.js`
Expected: PASS (11 tests)

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers/src/plumbers/reorderable.js stimulus-plumbers/tests/unit/plumbers/reorderable.test.js
git commit -m "feat: add Reorderable plumber with keyboard-move swap"
```

---

### Task 2: `Reorderable` plumber — pointer drag

**Files:**
- Modify: `stimulus-plumbers/src/plumbers/reorderable.js`
- Modify: `stimulus-plumbers/tests/unit/plumbers/reorderable.test.js`

**Interfaces:**
- Consumes: `orderedIds()`, `items` getter, inherited `dispatch()` from Task 1.
- Produces: `startDrag(item, handle, pointerId)`, `drag(clientY)`, `endDrag(handle, pointerId)` — consumed by Task 3's controller adapters.

- [ ] **Step 1: Write the failing tests**

Add to the test file:

```javascript
describe('pointer drag', () => {
  const rectFor = (top) => ({ top, bottom: top + 40, height: 40, left: 0, right: 100, width: 100, x: 0, y: top });

  const stubRects = () => {
    items.forEach((item, i) => {
      item.getBoundingClientRect = () => rectFor(i * 40);
    });
  };

  it('does nothing before startDrag is called', () => {
    stubRects();
    const reorderable = new Reorderable(mockController);

    reorderable.drag(61);

    expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
  });

  it('swaps the dragging item past a neighbor once the pointer crosses its midpoint', () => {
    stubRects();
    const reorderable = new Reorderable(mockController);
    const handle = { setPointerCapture: vi.fn(), releasePointerCapture: vi.fn() };

    reorderable.startDrag(items[0], handle, 1);
    // row-b occupies y:40-80, midpoint 60 — cross it to trigger the swap
    reorderable.drag(61);

    expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    expect(handle.setPointerCapture).toHaveBeenCalledWith(1);
  });

  it('dispatches reorderable:reordered on endDrag', () => {
    stubRects();
    const reorderable = new Reorderable(mockController);
    const handle = { setPointerCapture: vi.fn(), releasePointerCapture: vi.fn() };

    reorderable.startDrag(items[0], handle, 1);
    reorderable.drag(61);
    const moved = reorderable.endDrag(handle, 1);

    expect(handle.releasePointerCapture).toHaveBeenCalledWith(1);
    expect(mockController.dispatch).toHaveBeenCalledWith(
      'reordered',
      expect.objectContaining({ detail: { itemIds: ['row-b', 'row-a', 'row-c'] } })
    );
    expect(moved.id).toBe('row-a');
  });

  it('endDrag is a no-op without a preceding startDrag', () => {
    const reorderable = new Reorderable(mockController);
    const handle = { setPointerCapture: vi.fn(), releasePointerCapture: vi.fn() };

    const moved = reorderable.endDrag(handle, 1);

    expect(moved).toBeNull();
    expect(handle.releasePointerCapture).not.toHaveBeenCalled();
    expect(mockController.dispatch).not.toHaveBeenCalled();
  });

  it('does not announce on drag (mouse users should not have focus stolen)', async () => {
    stubRects();
    const reorderable = new Reorderable(mockController);
    const handle = { setPointerCapture: vi.fn(), releasePointerCapture: vi.fn() };

    reorderable.startDrag(items[0], handle, 1);
    reorderable.drag(61);
    reorderable.endDrag(handle, 1);

    await new Promise((r) => setTimeout(r, 150));
    const liveRegion = document.querySelector('[aria-live]');
    expect(liveRegion?.textContent).toBeFalsy();
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/reorderable.test.js`
Expected: FAIL — `reorderable.startDrag is not a function`

- [ ] **Step 3: Implement pointer drag**

Add to the `Reorderable` class in `stimulus-plumbers/src/plumbers/reorderable.js`:

```javascript
  startDrag(item, handle, pointerId) {
    this.draggingItem = item;
    handle.setPointerCapture(pointerId);
  }

  drag(clientY) {
    if (!this.draggingItem) return;

    const items = this.items;
    const draggingIndex = items.indexOf(this.draggingItem);

    const previous = items[draggingIndex - 1];
    if (previous && clientY < this.midpointOf(previous)) {
      previous.before(this.draggingItem);
      return;
    }

    const next = items[draggingIndex + 1];
    if (next && clientY > this.midpointOf(next)) {
      next.after(this.draggingItem);
    }
  }

  // Returns the moved item (or null if no drag was in progress) purely for test
  // assertions — the controller's onPointerUp ignores the return value, since a
  // drag deliberately does not refocus or announce (unlike a keyboard move).
  endDrag(handle, pointerId) {
    if (!this.draggingItem) return null;

    handle.releasePointerCapture(pointerId);
    const item = this.draggingItem;
    this.draggingItem = null;
    this.dispatch('reordered', { detail: { itemIds: this.orderedIds() } });
    return item;
  }

  midpointOf(item) {
    const rect = item.getBoundingClientRect();
    return rect.top + rect.height / 2;
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/reorderable.test.js`
Expected: PASS (16 tests total)

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers/src/plumbers/reorderable.js stimulus-plumbers/tests/unit/plumbers/reorderable.test.js
git commit -m "feat: add pointer drag to Reorderable plumber"
```

---

### Task 3: `reorderable` controller — thin wiring

**Files:**
- Create: `stimulus-plumbers/src/controllers/reorderable_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/reorderable_controller.test.js`
- Modify: `stimulus-plumbers/src/plumbers/index.js`

**Interfaces:**
- Consumes: `attachReorderable` from `../plumbers` (Task 1+2); `RovingTabIndex` from `../accessibility/keyboard`.
- Produces: `ReorderableController` — the full public API (`static targets = ['item', 'handle']`, `static values = { moveKey }`, `onPointerDown`/`onPointerMove`/`onPointerUp`, `moved(item)`) consumed by Task 4's docs/README/exports.

- [ ] **Step 1: Export the plumber from the barrel file**

In `stimulus-plumbers/src/plumbers/index.js`, add:

```javascript
export { attachReorderable } from './reorderable';
```

- [ ] **Step 2: Write the failing integration tests**

```javascript
// stimulus-plumbers/tests/unit/controllers/reorderable_controller.test.js
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
    <ul data-controller="reorderable">
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

    // Regression guard for connect()'s listener-attach order: reorderable.attachItem()
    // must run before rovingTabIndex.activate() (see the comment in connect()). If that
    // order is ever reversed, RovingTabIndex's plain-arrow handler runs first, moves
    // focus once on its own (ignoring altKey), and does NOT stop propagation — so the
    // plumber's handler still runs afterward too, producing exactly one swap but a
    // dispatch count / final-focus mismatch versus the assertions below. If this test
    // fails, check connect()'s attach order first.
    it('dispatches reorderable:reordered exactly once per Alt+Arrow (attach-order regression guard)', async () => {
      const element = await setup();
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      const spy = vi.fn();
      element.addEventListener('reorderable:reordered', spy);
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(spy).toHaveBeenCalledTimes(1);
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
      expect(document.activeElement.id).toBe('row-a');
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
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/reorderable_controller.test.js`
Expected: FAIL — `Cannot find module '../../../src/controllers/reorderable_controller'`

- [ ] **Step 4: Write the controller**

```javascript
// stimulus-plumbers/src/controllers/reorderable_controller.js
import { Controller } from '@hotwired/stimulus';
import { RovingTabIndex } from '../accessibility/keyboard';
import { attachReorderable } from '../plumbers';

export default class extends Controller {
  static targets = ['item', 'handle'];
  static values = {
    moveKey: { type: String, default: 'Alt' },
  };

  connect() {
    this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
    // Must attach before `rovingTabIndex.activate()` below: both add a raw `keydown`
    // listener to each item, and whichever attaches first runs first. The plumber's
    // handler calls stopImmediatePropagation() for Alt+Arrow so RovingTabIndex never
    // sees it as a plain focus move — reversing this order breaks Alt+Arrow silently
    // reverting to focus-only movement. See docs/plumber/reorderable.md.
    this.itemTargets.forEach((item) => this.reorderable.attachItem(item));

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }

  disconnect() {
    this.itemTargets.forEach((item) => this.reorderable.detachItem(item));
    this.rovingTabIndex?.deactivate();
    this.rovingTabIndex = null;
  }

  itemTargetConnected(item) {
    this.reorderable?.attachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  itemTargetDisconnected(item) {
    this.reorderable?.detachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  onPointerDown(event) {
    const item = event.currentTarget.closest('[data-reorderable-target~="item"]');
    if (!item) return;
    this.reorderable.startDrag(item, event.currentTarget, event.pointerId);
  }

  onPointerMove(event) {
    this.reorderable.drag(event.clientY);
  }

  onPointerUp(event) {
    this.reorderable.endDrag(event.currentTarget, event.pointerId);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  moved(item) {
    this.rovingTabIndex?.updateItems(this.itemTargets);
    this.rovingTabIndex.setCurrentIndex(this.itemTargets.indexOf(item));
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/reorderable_controller.test.js`
Expected: PASS (5 tests)

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers/src/controllers/reorderable_controller.js stimulus-plumbers/tests/unit/controllers/reorderable_controller.test.js stimulus-plumbers/src/plumbers/index.js
git commit -m "feat: add thin reorderable controller wiring RovingTabIndex + Reorderable plumber"
```

---

### Task 4: Docs, README, and package export

**Files:**
- Create: `stimulus-plumbers/docs/component/reorderable.md`
- Create: `stimulus-plumbers/docs/plumber/reorderable.md`
- Modify: `stimulus-plumbers/README.md`
- Modify: `stimulus-plumbers/src/index.js`

**Interfaces:**
- Consumes: final controller API from Task 3 (targets `item`/`handle`, value `moveKey`, event `reorderable:reordered`) and the plumber's public methods/options from Tasks 1–2.
- Produces: nothing further downstream — last task in this plan.

Per project `CLAUDE.md`: "Plumber factory API → `stimulus-plumbers/docs/plumber/<name>.md` only. Controller docs reference the plumber doc, not inline it." Every other plumber-backed controller in this repo has a matching `docs/plumber/<name>.md` (see `docs/plumber/dismisser.md`, `docs/plumber/calendar.md`) — `reorderable` needs the same pairing.

- [ ] **Step 1: Write the plumber doc**

```markdown
<!-- stimulus-plumbers/docs/plumber/reorderable.md -->
# Reorderable

Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system, so it can run before a separately-instantiated `RovingTabIndex` listener on the same element and take over `Alt+Arrow` before `RovingTabIndex` treats it as plain focus movement.

## Factory

```js
import { attachReorderable } from '../plumbers';
attachReorderable(controller, options);
```

## Options

| Option    | Type   | Default  | Description                                                                                   |
| --------- | ------ | -------- | ----------------------------------------------------------------------------------------------- |
| `moveKey` | String | `'Alt'`  | Modifier key name (`Alt`, `Control`, `Shift`, or `Meta`) combined with `ArrowUp`/`ArrowDown` to move an item. Falls back to `'Alt'` for any other value. |
| `onMoved` | String | `null`   | Controller method called with the moved item after a keyboard move (not called after a drag)     |

## Methods

| Method                              | Purpose                                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------------------------- |
| `attachItem(item)`                   | Adds the `keydown` listener for `Alt+Arrow` move handling to `item`                           |
| `detachItem(item)`                   | Removes it                                                                                     |
| `startDrag(item, handle, pointerId)` | Begins tracking `item` as the drag target and captures the pointer on `handle`                |
| `drag(clientY)`                      | Swaps the dragging item past its immediate previous/next sibling once `clientY` crosses its midpoint |
| `endDrag(handle, pointerId)`         | Releases the pointer, dispatches `reordered`, and returns the moved item (or `null` if no drag was in progress) |
| `orderedIds()`                       | Returns `controller.itemTargets` ids (DOM order), omitting items without an `id`               |

Reads the current item list from `controller.itemTargets` on every call (a live Stimulus target getter) — never caches it, so it stays correct across DOM mutations from either drag or keyboard moves.

## Dispatches & callbacks

| Moment          | Dispatch             | Callback     |
| ----------------- | ---------------------- | -------------- |
| After a keyboard move | `{prefix}:reordered` | `onMoved(item)`, then `announce()` |
| After a drag ends     | `{prefix}:reordered` | — no callback, no announcement. A mouse drag deliberately does not move focus or announce — doing so would steal focus from a mouse user who never asked for it; the keyboard path already satisfies WCAG 2.1.1's keyboard-equivalent requirement. |

## Controller callback

```js
connect() {
  this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
  this.itemTargets.forEach((item) => this.reorderable.attachItem(item));
}

moved(item) {
  this.rovingTabIndex?.updateItems(this.itemTargets);
  this.rovingTabIndex.setCurrentIndex(this.itemTargets.indexOf(item));
}
```
```

- [ ] **Step 2: Write the component doc**

```markdown
<!-- stimulus-plumbers/docs/component/reorderable.md -->
# Reorderable

Reorders a vertical list of items via pointer drag (a dedicated handle) or keyboard (`Alt+ArrowUp`/`Alt+ArrowDown`). No third-party drag library — built on the native Pointer Events API, backed by the [`Reorderable` plumber](../plumber/reorderable.md). Plain Arrow/Home/End keys move focus only, via [`RovingTabIndex`](../utility/accessibility.md).

## Stimulus Identifier

`reorderable`

## Targets

| Name     | Element                                     | Purpose                                                                            |
| -------- | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| `item`   | Each reorderable row (`<li>`, `<tr>`, etc.)  | Must have a stable `id` to appear in the `reorderable:reordered` event's `itemIds`   |
| `handle` | Drag grip within each `item`                 | The only pointer-drag surface — wire `pointerdown`/`pointermove`/`pointerup` to it   |

## Values

| Name      | Type   | Default | Purpose                                                                                                                        |
| --------- | ------ | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `moveKey` | String | `"Alt"` | Modifier key that, combined with `ArrowUp`/`ArrowDown` on a focused item, moves it. One of `Alt`, `Control`, `Shift`, `Meta`. |

## Actions

| Name           | Purpose                                                                       |
| -------------- | -------------------------------------------------------------------------------- |
| `onPointerDown`| Wire to `pointerdown` on the `handle` target — starts a drag                     |
| `onPointerMove`| Wire to `pointermove` on the `handle` target — live-reorders while dragging       |
| `onPointerUp`  | Wire to `pointerup` on the `handle` target — ends the drag                        |

## Keyboard

| Key                     | Behaviour                                                              |
| ------------------------ | -------------------------------------------------------------------------- |
| `ArrowDown` / `ArrowUp`  | Focus next/previous item (wraps) — unchanged `RovingTabIndex` behavior     |
| `Home` / `End`           | Focus first/last item                                                     |
| `Alt+ArrowDown`          | Move the focused item down one position, keeps focus on it                |
| `Alt+ArrowUp`            | Move the focused item up one position, keeps focus on it                  |

## Dispatches

| Event                  | Detail                  | When                                                                                          |
| ------------------------ | ------------------------- | -------------------------------------------------------------------------------------------- |
| `reorderable:reordered` | `{ itemIds: string[] }`  | After a drag ends or a keyboard move completes. Items without an `id` are omitted from `itemIds`. |

## Example HTML

```html
<ul data-controller="reorderable">
  <li id="row-1" data-reorderable-target="item" tabindex="0">
    <span data-reorderable-target="handle"
          data-action="pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp">
      ::
    </span>
    First item
  </li>
  <li id="row-2" data-reorderable-target="item" tabindex="-1">
    <span data-reorderable-target="handle"
          data-action="pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp">
      ::
    </span>
    Second item
  </li>
</ul>
```

## Notes

- Persistence is not built in — listen for `reorderable:reordered` and send `event.detail.itemIds` to your backend.
- Vertical-axis, single-list only. Horizontal/grid orientation and cross-list drag are not supported.
- The dragged/moved item is repositioned live in the DOM — there is no placeholder or ghost element.
- A pointer drag does not move focus or trigger a status announcement (avoids stealing focus from mouse users); a keyboard move does both.
```

- [ ] **Step 3: Add the package exports**

In `stimulus-plumbers/src/index.js`, after the `TimelineController` export line, add:

```javascript
export { default as ReorderableController } from './controllers/reorderable_controller.js';
```

- [ ] **Step 4: Update README.md — Setup import list**

In `stimulus-plumbers/README.md`, in the `import { ... } from '@stimulus-plumbers/controllers'` block, after `TimelineController,` add:

```javascript
  ReorderableController,
```

- [ ] **Step 5: Update README.md — Setup registration list**

After the `application.register('timeline', TimelineController)` line, add:

```javascript
application.register('reorderable',              ReorderableController)
```

- [ ] **Step 6: Update README.md — Controllers table**

After the `timeline` row, add:

```markdown
| `reorderable` | Drag (pointer) or keyboard (`Alt+Arrow`) reordering for a vertical list | [docs/component/reorderable.md](docs/component/reorderable.md) |
```

- [ ] **Step 7: Verify the full suite and lint still pass**

Run: `cd stimulus-plumbers && npx vitest run && node --run lint`
Expected: all tests pass, no lint errors

- [ ] **Step 8: Commit**

```bash
git add stimulus-plumbers/docs/component/reorderable.md stimulus-plumbers/docs/plumber/reorderable.md stimulus-plumbers/README.md stimulus-plumbers/src/index.js
git commit -m "docs: add reorderable controller and plumber documentation, export"
```
