import WindowObserver from './plumber/window_observer';
import { defineRect, viewportRect, directionMap } from './plumber/geometry';
import { connectTriggerToTarget } from '../accessibility/aria';

const defaultOptions = {
  anchor: null,
  events: ['click'],
  placement: 'bottom',
  alignment: 'start',
  onFlipped: 'flipped',
  ariaRole: null,
  respectMotion: true,
};

export class Flipper extends WindowObserver {
  constructor(controller, options = {}) {
    super(controller, options);

    const { anchor, events, placement, alignment, onFlipped, ariaRole, respectMotion } = Object.assign(
      {},
      defaultOptions,
      options
    );
    this.anchor = anchor;
    this.events = events;
    this.placement = placement;
    this.alignment = alignment;
    this.onFlipped = onFlipped;
    this.ariaRole = ariaRole;
    this.respectMotion = respectMotion;
    this.prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    if (this.anchor && this.element) {
      connectTriggerToTarget({ trigger: this.anchor, target: this.element, role: this.ariaRole });
    }

    this.enhance();
    this.observe(this.flip);
  }

  flip = async () => {
    if (!this.visible) return;

    this.dispatch('flip');
    const positionStyle = window.getComputedStyle(this.element);
    if (positionStyle['position'] != 'absolute') this.element.style['position'] = 'absolute';

    const placement = this.flippedRect(this.anchor.getBoundingClientRect(), this.element.getBoundingClientRect());

    this.element.style.transition = this.respectMotion && this.prefersReducedMotion ? 'none' : '';

    for (const [key, value] of Object.entries(placement)) {
      this.element.style[key] = value;
    }

    await this.awaitCallback(this.onFlipped, { target: this.element, placement });
    this.dispatch('flipped', { detail: { placement } });
  };

  flippedRect(anchorRect, referenceRect) {
    const candidateRects = this.quadrumRect(anchorRect, viewportRect());
    const candidates = [this.placement, directionMap[this.placement]];
    let flipped = {};
    while (!Object.keys(flipped).length && candidates.length > 0) {
      const candidate = candidates.shift();
      if (!this.biggerRectThan(candidateRects[candidate], referenceRect)) continue;
      const placementRect = this.quadrumPlacement(anchorRect, candidate, referenceRect);
      const alignmentRect = this.quadrumAlignment(anchorRect, candidate, placementRect);
      flipped['top'] = `${alignmentRect['top'] + window.scrollY}px`;
      flipped['left'] = `${alignmentRect['left'] + window.scrollX}px`;
    }
    if (!Object.keys(flipped).length) {
      flipped['top'] = '';
      flipped['left'] = '';
    }
    return flipped;
  }

  quadrumRect(inner, outer) {
    return {
      left: defineRect({ x: outer.x, y: outer.y, width: inner.x - outer.x, height: outer.height }),
      right: defineRect({
        x: inner.x + inner.width,
        y: outer.y,
        width: outer.width - (inner.x + inner.width),
        height: outer.height,
      }),
      top: defineRect({ x: outer.x, y: outer.y, width: outer.width, height: inner.y - outer.y }),
      bottom: defineRect({
        x: outer.x,
        y: inner.y + inner.height,
        width: outer.width,
        height: outer.height - (inner.y + inner.height),
      }),
    };
  }

  quadrumPlacement(anchor, direction, reference) {
    switch (direction) {
      case 'top':
        return defineRect({
          x: reference.x,
          y: anchor.y - reference.height,
          width: reference.width,
          height: reference.height,
        });
      case 'bottom':
        return defineRect({
          x: reference.x,
          y: anchor.y + anchor.height,
          width: reference.width,
          height: reference.height,
        });
      case 'left':
        return defineRect({
          x: anchor.x - reference.width,
          y: reference.y,
          width: reference.width,
          height: reference.height,
        });
      case 'right':
        return defineRect({
          x: anchor.x + anchor.width,
          y: reference.y,
          width: reference.width,
          height: reference.height,
        });
      default:
        throw `Unable place at the quadrum, ${direction}`;
    }
  }

  quadrumAlignment(anchor, direction, reference) {
    switch (direction) {
      case 'top':
      case 'bottom': {
        let alignment = anchor.x;
        if (this.alignment === 'center') alignment = anchor.x + anchor.width / 2 - reference.width / 2;
        else if (this.alignment === 'end') alignment = anchor.x + anchor.width - reference.width;
        return defineRect({ x: alignment, y: reference.y, width: reference.width, height: reference.height });
      }
      case 'left':
      case 'right': {
        let alignment = anchor.y;
        if (this.alignment === 'center') alignment = anchor.y + anchor.height / 2 - reference.height / 2;
        else if (this.alignment === 'end') alignment = anchor.y + anchor.height - reference.height;
        return defineRect({ x: reference.x, y: alignment, width: reference.width, height: reference.height });
      }
      default:
        throw `Unable align at the quadrum, ${direction}`;
    }
  }

  biggerRectThan(big, small) {
    return big.height >= small.height && big.width >= small.width;
  }

  enhance() {
    super.enhance();
    this.controller.flip = this.flip;
  }
}

export const attachFlipper = (controller, options) => new Flipper(controller, options);
