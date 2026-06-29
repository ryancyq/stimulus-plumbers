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
  constructor(items, options = {}) {
    this.items = Array.from(items);
    this.currentIndex = options.initialIndex ?? 0;
    this.orientation = options.orientation ?? 'both';
    this.wrap = options.wrap ?? true;
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

export class ListboxNavigation {
  constructor(listbox, options = {}) {
    this.listbox = listbox;
    this.itemSelector = options.itemSelector ?? '[role="option"]:not([aria-disabled="true"]):not([hidden])';
    this.wrap = options.wrap ?? false;
    this.orientation = options.orientation ?? 'vertical';
  }

  get selectedItem() {
    return this.listbox.querySelector(`${this.itemSelector}[aria-selected="true"]`) ?? null;
  }

  get currentIndex() {
    const items = Array.from(this.listbox.querySelectorAll(this.itemSelector));
    return items.indexOf(this.selectedItem);
  }

  _selectItem(item) {
    const all = Array.from(this.listbox.querySelectorAll(this.itemSelector));
    all.forEach((o) => o.setAttribute('aria-selected', 'false'));
    item.setAttribute('aria-selected', 'true');
    item.scrollIntoView({ block: 'nearest' });
  }

  step(delta) {
    const options = Array.from(this.listbox.querySelectorAll(this.itemSelector));
    if (!options.length) return;
    const current = this.listbox.querySelector(`${this.itemSelector}[aria-selected="true"]`);
    const idx = options.indexOf(current);
    let next;
    if (delta > 0) {
      next = this.wrap ? options[(idx + 1) % options.length] : options[Math.min(idx + 1, options.length - 1)];
    } else {
      next = this.wrap ? options[(idx - 1 + options.length) % options.length] : options[Math.max(idx - 1, 0)];
    }
    if (!next || next === current) return;
    this._selectItem(next);
  }

  handleKeyDown(event) {
    const verticalKeys = this.orientation !== 'horizontal' ? ['ArrowUp', 'ArrowDown'] : [];
    const horizontalKeys = this.orientation !== 'vertical' ? ['ArrowLeft', 'ArrowRight'] : [];
    const activeKeys = [...verticalKeys, ...horizontalKeys, 'Home', 'End', 'Enter', ' '];

    if (!activeKeys.includes(event.key)) return;
    event.preventDefault();

    const options = Array.from(this.listbox.querySelectorAll(this.itemSelector));

    switch (event.key) {
      case 'ArrowDown':
      case 'ArrowRight':
        this.step(1);
        break;
      case 'ArrowUp':
      case 'ArrowLeft':
        this.step(-1);
        break;
      case 'Home':
        if (options.length) this._selectItem(options[0]);
        break;
      case 'End':
        if (options.length) this._selectItem(options[options.length - 1]);
        break;
      case 'Enter':
      case ' ':
        this.listbox.querySelector(`${this.itemSelector}[aria-selected="true"]`)?.click();
        break;
    }
  }
}
