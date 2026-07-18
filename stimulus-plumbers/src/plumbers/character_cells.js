import Plumber from './plumber';
import { setAriaHidden } from '../accessibility/aria';

const defaultOptions = {
  groups: [],
  length: 0,
};

/** Cumulative end indexes for group widths, e.g. [4, 4, 4] → [4, 8, 12] */
const groupBounds = (groups) => {
  const bounds = [];
  let sum = 0;
  for (const width of groups) {
    sum += width;
    bounds.push(sum);
  }
  return bounds;
};

export class CharacterCells extends Plumber {
  /**
   * Paints a canonical string value into author-rendered cell elements
   * (controller.cellTargets). Never generates DOM and never reads an input —
   * values arrive via draw().
   * @param {Object} controller - Stimulus controller with cellTargets
   * @param {Object} options - Configuration options
   * @param {number[]} [options.groups=[]] - Chunk widths (e.g. [4,4,4,4]); empty = uniform cells
   * @param {number} [options.length=0] - Expected value length; 0 derives from groups sum or cell count
   */
  constructor(controller, options = {}) {
    super(controller, options);
    this.groups = Array.isArray(options.groups) ? options.groups : defaultOptions.groups;
    this.length = options.length ?? defaultOptions.length;
    this.adopt();
    this.enhance();
  }

  get cells() {
    return this.controller.cellTargets ?? [];
  }

  /** Expected value length: explicit length, else groups sum, else cell count */
  expected() {
    if (this.length > 0) return this.length;
    const groupSum = this.groups.reduce((sum, width) => sum + width, 0);
    return groupSum > 0 ? groupSum : this.cells.length;
  }

  /** Number of cells in play — min of available cells and expected length */
  active() {
    if (this.grouped) return this.expected();
    return Math.min(this.cells.length, this.expected());
  }

  /** Grouped mode: one cell per group (holding that group's whole slice of characters),
   *  inferred when the adopted cell count exactly matches the group count. Width-1 groups
   *  degenerate to identical per-char rendering, so this is safe even on a coincidental match. */
  get grouped() {
    return this.groups.length > 0 && this.cells.length === this.groups.length;
  }

  /** Stamps aria-hidden, group attributes, and data-inactive on adopted cells */
  adopt() {
    const expected = this.expected();
    if (this.cells.length < expected) {
      console.warn(`[CharacterCells] expected ${expected} cells, found ${this.cells.length}`);
    }

    const bounds = groupBounds(this.groups);

    if (this.grouped) {
      this.cells.forEach((cell, index) => {
        setAriaHidden(cell, true);

        const start = index === 0 ? 0 : bounds[index - 1];
        const inactive = start >= expected;
        cell.toggleAttribute('data-inactive', inactive);
        if (inactive) {
          cell.textContent = '';
          cell.removeAttribute('data-filled');
          cell.removeAttribute('data-caret');
        }

        cell.setAttribute('data-group-index', index);
        cell.removeAttribute('data-group-end');
      });
      return;
    }

    this.cells.forEach((cell, index) => {
      setAriaHidden(cell, true);

      const inactive = index >= expected;
      cell.toggleAttribute('data-inactive', inactive);
      if (inactive) {
        cell.textContent = '';
        cell.removeAttribute('data-filled');
        cell.removeAttribute('data-caret');
      }

      const group = bounds.findIndex((end) => index < end);
      if (group >= 0) {
        cell.setAttribute('data-group-index', group);
        cell.toggleAttribute('data-group-end', index === bounds[group] - 1);
      } else {
        cell.removeAttribute('data-group-index');
        cell.removeAttribute('data-group-end');
      }
    });
  }

  enhance() {
    const context = this;
    const helpers = {
      draw: (value, options) => context.draw(value, options),
      clear: () => context.draw(''),
      active: () => context.active(),
    };

    Object.defineProperty(this.controller, 'characterCells', {
      get() {
        return helpers;
      },
      configurable: true,
    });
  }

  /**
   * Writes value[i] into each active cell (or, in grouped mode, each cell's group-sized
   * slice of value) and stamps state attributes.
   * @param {string} value - Canonical string to paint
   * @param {Object} [options] - Options
   * @param {boolean} [options.focused=false] - Whether the source input has focus; enables data-caret
   */
  draw(value = '', { focused = false } = {}) {
    const text = typeof value === 'string' ? value : '';

    if (this.grouped) {
      const bounds = groupBounds(this.groups);
      this.cells.forEach((cell, index) => {
        const start = index === 0 ? 0 : bounds[index - 1];
        const end = bounds[index];
        if (start >= this.expected()) {
          cell.textContent = '';
          cell.removeAttribute('data-filled');
          cell.removeAttribute('data-caret');
          return;
        }
        const slice = text.slice(start, end);
        cell.textContent = slice;
        cell.toggleAttribute('data-filled', slice.length > 0);
        cell.toggleAttribute('data-caret', focused && text.length >= start && text.length < end);
      });
      return;
    }

    const chars = text.split('');
    const activeCount = this.active();
    this.cells.forEach((cell, index) => {
      if (index >= activeCount) {
        cell.textContent = '';
        cell.removeAttribute('data-filled');
        cell.removeAttribute('data-caret');
        return;
      }
      cell.textContent = chars[index] ?? '';
      cell.toggleAttribute('data-filled', chars[index] != null);
      cell.toggleAttribute('data-caret', focused && index === chars.length);
    });
  }
}

export const attachCharacterCells = (controller, options) => new CharacterCells(controller, options);
