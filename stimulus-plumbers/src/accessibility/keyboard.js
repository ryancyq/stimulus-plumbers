/**
 * Keyboard interaction utilities
 */

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
