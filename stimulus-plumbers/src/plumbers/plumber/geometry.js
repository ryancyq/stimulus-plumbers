export const directionMap = {
  get top() {
    return 'bottom';
  },
  get bottom() {
    return 'top';
  },
  get left() {
    return 'right';
  },
  get right() {
    return 'left';
  },
};

export function defineRect({ x, y, width, height }) {
  return { x, y, width, height, left: x, right: x + width, top: y, bottom: y + height };
}

export function centerOf(rect, orientation = 'vertical') {
  return orientation === 'horizontal' ? rect.left + rect.width / 2 : rect.top + rect.height / 2;
}

export function viewportRect() {
  return defineRect({
    x: 0,
    y: 0,
    width: window.innerWidth || document.documentElement.clientWidth,
    height: window.innerHeight || document.documentElement.clientHeight,
  });
}

export function isWithinViewport(target) {
  if (!(target instanceof HTMLElement)) return false;
  const outer = viewportRect();
  const inner = target.getBoundingClientRect();
  const vertical = inner.top <= outer.height && inner.top + inner.height > 0;
  const horizontal = inner.left <= outer.width && inner.left + inner.width > 0;
  return vertical && horizontal;
}
