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

/**
 * Handle roving tabindex for a list of items
 */
export class RovingTabIndex {
  constructor(items, initialIndex = 0) {
    this.items = items;
    this.currentIndex = initialIndex;
    this.updateTabIndex();
  }

  handleKeyDown(event) {
    let newIndex;

    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowRight':
        event.preventDefault();
        newIndex = (this.currentIndex + 1) % this.items.length;
        break;
      case 'ArrowUp':
      case 'ArrowLeft':
        event.preventDefault();
        newIndex = this.currentIndex === 0 ? this.items.length - 1 : this.currentIndex - 1;
        break;
      case 'Home':
        event.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        event.preventDefault();
        newIndex = this.items.length - 1;
        break;
      default:
        return;
    }

    this.setCurrentIndex(newIndex);
  }

  setCurrentIndex(index) {
    if (index >= 0 && index < this.items.length) {
      this.currentIndex = index;
      this.updateTabIndex();
      this.items[index].focus();
    }
  }

  updateTabIndex() {
    this.items.forEach((item, index) => {
      item.tabIndex = index === this.currentIndex ? 0 : -1;
    });
  }

  updateItems(items) {
    this.items = items;
    this.currentIndex = Math.min(this.currentIndex, items.length - 1);
    this.updateTabIndex();
  }
}
