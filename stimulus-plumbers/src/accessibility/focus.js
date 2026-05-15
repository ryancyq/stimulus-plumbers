/**
 * Query selector for all focusable elements
 */
export const FOCUSABLE_SELECTOR = [
  'a[href]',
  'area[href]',
  'button:not([disabled])',
  'input:not([disabled])',
  'select:not([disabled])',
  'textarea:not([disabled])',
  '[tabindex]:not([tabindex="-1"])',
  'audio[controls]',
  'video[controls]',
  '[contenteditable]:not([contenteditable="false"])',
].join(',');

/**
 * Get all focusable elements within a container
 */
export function getFocusableElements(container) {
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter((el) => isVisible(el));
}

/**
 * Check if an element is visible
 */
export function isVisible(element) {
  return !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);
}

/**
 * Focus the first focusable element in a container
 */
export function focusFirst(container) {
  const elements = getFocusableElements(container);
  if (elements.length > 0) {
    elements[0].focus();
    return true;
  }
  return false;
}

/**
 * Create a focus trap within a container
 */
export class FocusTrap {
  constructor(container, options = {}) {
    this.container = container;
    this.previouslyFocused = null;
    this.options = options;
    this.isActive = false;
  }

  activate() {
    if (this.isActive) return;

    this.previouslyFocused = document.activeElement;
    this.isActive = true;

    // Focus initial element or first focusable
    if (this.options.initialFocus) {
      this.options.initialFocus.focus();
    } else {
      focusFirst(this.container);
    }

    // Add event listeners
    this.container.addEventListener('keydown', this.handleKeyDown);
  }

  deactivate() {
    if (!this.isActive) return;

    this.isActive = false;
    this.container.removeEventListener('keydown', this.handleKeyDown);

    // Return focus to previously focused element
    const returnElement = this.options.returnFocus || this.previouslyFocused;
    if (returnElement && isVisible(returnElement)) {
      returnElement.focus();
    }
  }

  handleKeyDown = (event) => {
    if (event.key === 'Escape' && this.options.escapeDeactivates) {
      event.preventDefault();
      this.deactivate();
      return;
    }

    if (event.key !== 'Tab') return;

    const focusableElements = getFocusableElements(this.container);
    if (focusableElements.length === 0) return;

    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    // Trap focus within container
    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault();
      lastElement.focus();
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault();
      firstElement.focus();
    }
  };
}

/**
 * Save and restore focus utility
 */
export class FocusRestoration {
  constructor() {
    this.savedElement = null;
  }

  save() {
    this.savedElement = document.activeElement;
  }

  restore() {
    if (this.savedElement && isVisible(this.savedElement)) {
      this.savedElement.focus();
      this.savedElement = null;
    }
  }
}
