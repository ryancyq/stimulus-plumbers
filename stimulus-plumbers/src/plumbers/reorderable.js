import Plumber from './plumber';
import { announce } from '../accessibility/aria';
import { MODIFIER_KEYS } from '../accessibility/keyboard';
import { centerOf } from './plumber/geometry';

const defaultOptions = {
  moveKey: 'Alt',
  onMoved: null,
  orientation: 'vertical',
};

const MOVE_KEYS = {
  vertical: { back: 'ArrowUp', forward: 'ArrowDown' },
  horizontal: { back: 'ArrowLeft', forward: 'ArrowRight' },
};

export class Reorderable extends Plumber {
  constructor(controller, options = {}) {
    super(controller, options);

    const { moveKey, onMoved, orientation } = Object.assign({}, defaultOptions, options);
    this.moveKey = MODIFIER_KEYS[moveKey] ? moveKey : defaultOptions.moveKey;
    this.onMoved = onMoved;
    this.orientation = orientation;
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

  attachItems(items) {
    items.forEach((item) => this.attachItem(item));
  }

  detachItems(items) {
    items.forEach((item) => this.detachItem(item));
  }

  resolveMoveKeys(item) {
    const { back, forward } = MOVE_KEYS[this.orientation];
    if (this.orientation !== 'horizontal') return { back, forward };
    const rtl = getComputedStyle(item).direction === 'rtl';
    return rtl ? { back: forward, forward: back } : { back, forward };
  }

  onKeydown(event) {
    if (!this.controller.editingValue) return;
    if (event.repeat) return;

    const item = event.currentTarget;
    const { back, forward } = this.resolveMoveKeys(item);
    if (event.key !== back && event.key !== forward) return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;

    const items = this.items;
    const index = items.indexOf(item);
    const targetIndex = event.key === back ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= items.length) return;

    event.preventDefault();

    if (event.key === back) {
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

  startDrag(item, handle, pointerId) {
    this.draggingItem = item;
    handle.setPointerCapture(pointerId);
  }

  drag(event) {
    if (!this.draggingItem) return;

    const coord = this.orientation === 'horizontal' ? event.clientX : event.clientY;
    const items = this.items;
    const draggingIndex = items.indexOf(this.draggingItem);

    const previous = items[draggingIndex - 1];
    if (previous && coord < this.midpointOf(previous)) {
      previous.before(this.draggingItem);
      return;
    }

    const next = items[draggingIndex + 1];
    if (next && coord > this.midpointOf(next)) {
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
    return centerOf(item.getBoundingClientRect(), this.orientation);
  }
}

export const attachReorderable = (controller, options) => new Reorderable(controller, options);
