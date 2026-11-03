/**
 * Keyboard interaction utilities
 */

import { ensureId, setSelected } from './aria';

/**
 * Check if a key matches the expected key
 */
export function isKey(event, key) {
  return event.key === key;
}

/**
 * Check if Enter or Space was pressed (activation keys)
 */
export function isActivationKey(event) {
  return event.key === 'Enter' || event.key === ' ';
}

/**
 * Check if an arrow key was pressed
 */
export function isArrowKey(event) {
  return ['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(event.key);
}

/**
 * Prevent default and stop propagation
 */
export function preventDefault(event) {
  event.preventDefault();
  event.stopPropagation();
}

export const MODIFIER_KEYS = { Alt: 'altKey', Control: 'ctrlKey', Shift: 'shiftKey', Meta: 'metaKey' };

/**
 * Handle roving tabindex for a list of items
 */
export class RovingTabIndex {
  constructor(items, options = {}) {
    this.items = Array.from(items);
    this.currentIndex = options.initialIndex ?? 0;
    this.orientation = options.orientation ?? 'both';
    this.wrap = options.wrap ?? true;
    this.ignoreModifierKeys = options.ignoreModifierKeys ?? Object.keys(MODIFIER_KEYS);
    this._handleKeyDown = this._handleKeyDown.bind(this);
    this._handleClick = this._handleClick.bind(this);
  }

  activate() {
    this.updateTabIndex();
    this.items.forEach((item) => {
      item.addEventListener('keydown', this._handleKeyDown);
      item.addEventListener('click', this._handleClick);
    });
    return this;
  }

  deactivate() {
    this.items.forEach((item) => {
      item.removeEventListener('keydown', this._handleKeyDown);
      item.removeEventListener('click', this._handleClick);
    });
  }

  updateItems(items) {
    this.deactivate();
    this.items = Array.from(items);
    this.currentIndex = Math.min(this.currentIndex, Math.max(0, this.items.length - 1));
    this.activate();
  }

  setCurrentIndex(index) {
    if (index >= 0 && index < this.items.length) {
      this.currentIndex = index;
      this.updateTabIndex();
      this.items[index].focus();
    }
  }

  updateTabIndex() {
    this.items.forEach((item, i) => {
      item.tabIndex = i === this.currentIndex ? 0 : -1;
    });
  }

  _handleClick(event) {
    const index = this.items.indexOf(event.currentTarget);
    if (index !== -1) {
      this.currentIndex = index;
      this.updateTabIndex();
    }
  }

  _handleKeyDown(event) {
    if (this.ignoreModifierKeys.some((name) => event[MODIFIER_KEYS[name]])) return;

    const fromIndex = this.items.indexOf(event.currentTarget);
    if (fromIndex !== -1 && fromIndex !== this.currentIndex) {
      this.currentIndex = fromIndex;
      this.updateTabIndex();
    }

    const verticalKeys = this.orientation !== 'horizontal' ? ['ArrowUp', 'ArrowDown'] : [];
    const horizontalKeys = this.orientation !== 'vertical' ? ['ArrowLeft', 'ArrowRight'] : [];
    const activeKeys = [...verticalKeys, ...horizontalKeys, 'Home', 'End'];

    if (!activeKeys.includes(event.key)) return;
    event.preventDefault();
    const base = fromIndex !== -1 ? fromIndex : this.currentIndex;

    let newIndex;
    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowRight':
        newIndex = this.wrap ? (base + 1) % this.items.length : Math.min(base + 1, this.items.length - 1);
        break;
      case 'ArrowUp':
      case 'ArrowLeft':
        newIndex = this.wrap ? (base - 1 + this.items.length) % this.items.length : Math.max(base - 1, 0);
        break;
      case 'Home':
        newIndex = 0;
        break;
      case 'End':
        newIndex = this.items.length - 1;
        break;
    }
    this.setCurrentIndex(newIndex);
  }
}

/**
 * Tracks the active option of a listbox whose DOM focus stays on an owner element.
 * The active option is `aria-selected` and the owner's `aria-activedescendant`.
 * Passive: the controller maps keys to moves.
 */
export class ActiveDescendant {
  #owner;
  #options;
  #enabled;
  #idPrefix;
  #active = null;

  /**
   * @param {HTMLElement|() => HTMLElement} owner - Element that keeps focus and carries aria-activedescendant, or a function returning it
   * @param {Object} options
   * @param {() => HTMLElement[]} options.options - All options, in order
   * @param {(option: HTMLElement) => boolean} [options.enabled] - Whether an option can become active
   * @param {string} [options.idPrefix='option'] - Prefix for generated option ids
   */
  constructor(owner, { options, enabled = () => true, idPrefix = 'option' }) {
    this.#owner = owner;
    this.#options = options;
    this.#enabled = enabled;
    this.#idPrefix = idPrefix;
  }

  /** The active option, or null when none is active or it can no longer be. */
  get active() {
    return this.#active && this.#enabledOptions().includes(this.#active) ? this.#active : null;
  }

  activate(option) {
    if (!option) return;

    this.#active = option;
    this.#options().forEach((other) => setSelected(other, other === option));
    this.#ownerElement().setAttribute('aria-activedescendant', ensureId(option, this.#idPrefix));
    option.scrollIntoView?.({ block: 'nearest' });
  }

  /**
   * Moves by delta and stops at the ends. From a disabled active option, moves to the enabled options
   * on the delta's side of it; with no active option, starts at the first or last.
   */
  move(delta) {
    const options = this.#enabledOptions();
    const index = this.#enabledIndex(delta);
    if (index === null) this.activate(delta > 0 ? options[0] : options.at(-1));
    else this.activate(options[Math.min(Math.max(index + delta, 0), options.length - 1)]);
  }

  first() {
    this.activate(this.#enabledOptions()[0]);
  }

  last() {
    this.activate(this.#enabledOptions().at(-1));
  }

  clear() {
    this.#active = null;
    this.#ownerElement().removeAttribute('aria-activedescendant');
    this.#options().forEach((option) => setSelected(option, false));
  }

  #ownerElement() {
    return typeof this.#owner === 'function' ? this.#owner() : this.#owner;
  }

  #enabledOptions() {
    return this.#options().filter((option) => this.#enabled(option));
  }

  // The active option's index among enabled options; a disabled one sits between its neighbours.
  #enabledIndex(delta) {
    const options = this.#options();
    const position = options.indexOf(this.#active);
    if (position === -1) return null;

    const before = options.slice(0, position).filter((option) => this.#enabled(option)).length;
    return this.#enabled(this.#active) || delta < 0 ? before : before - 1;
  }
}
