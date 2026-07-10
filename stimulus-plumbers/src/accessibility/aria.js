/**
 * Get or create a live region for screen reader announcements
 */
const getLiveRegion = (politeness, atomic, relevant) => {
  let region = document.querySelector(`[data-live-region="${politeness}"]`);

  if (!region) {
    region = document.createElement('div');
    region.className = 'sr-only';
    region.dataset.liveRegion = politeness;
    region.setAttribute('aria-live', politeness);
    region.setAttribute('aria-atomic', atomic.toString());
    region.setAttribute('aria-relevant', relevant);
    document.body.appendChild(region);
  }

  return region;
};

/**
 * Announce a message to screen readers using an aria-live region
 */
export function announce(message, options = {}) {
  const { politeness = 'polite', atomic = true, relevant = 'additions text' } = options;
  const region = getLiveRegion(politeness, atomic, relevant);

  region.textContent = '';
  setTimeout(() => {
    region.textContent = message;
  }, 100);
}

/**
 * Generate a unique ID for ARIA relationships
 */
export const generateId = (prefix = 'a11y') => `${prefix}-${Math.random().toString(36).substr(2, 9)}`;

/**
 * Ensure element has an ID, generate one if needed
 */
export const ensureId = (element, prefix = 'element') => element.id || (element.id = generateId(prefix));

/**
 * Generic function to set ARIA state attributes
 */
export const setAriaState = (element, attribute, value) => {
  element.setAttribute(attribute, value.toString());
};

/**
 * Update aria-expanded state
 */
export const setExpanded = (element, expanded) => setAriaState(element, 'aria-expanded', expanded);

/**
 * Read aria-expanded state
 */
export const isExpanded = (element) => element.getAttribute('aria-expanded') === 'true';

/**
 * Update aria-pressed state
 */
export const setPressed = (element, pressed) => setAriaState(element, 'aria-pressed', pressed);

/**
 * Update aria-checked state
 */
export const setChecked = (element, checked) => setAriaState(element, 'aria-checked', checked);

/**
 * Update aria-selected state
 */
export const setSelected = (element, selected) => setAriaState(element, 'aria-selected', selected);

/**
 * Set aria-current to a token (e.g. "date", "month", "year"), or remove it
 */
export const setCurrent = (element, value) =>
  value ? element.setAttribute('aria-current', value) : element.removeAttribute('aria-current');

/**
 * Set or remove the hidden attribute
 */
export const setHidden = (element, hidden) =>
  hidden ? element.setAttribute('hidden', '') : element.removeAttribute('hidden');

/**
 * Update aria-hidden state
 */
export const setAriaHidden = (element, hidden) => setAriaState(element, 'aria-hidden', hidden);

/**
 * Update aria-disabled state only (see setDisabled for the interactive-control variant that also manages tabindex)
 */
export const setAriaDisabled = (element, disabled) => setAriaState(element, 'aria-disabled', disabled);

/**
 * Read aria-disabled state
 */
export const isAriaDisabled = (element) => element.getAttribute('aria-disabled') === 'true';

/**
 * Update aria-disabled state and manage tabindex
 */
export function setDisabled(element, disabled) {
  setAriaState(element, 'aria-disabled', disabled);
  disabled ? element.setAttribute('tabindex', '-1') : element.removeAttribute('tabindex');
}

/**
 * Update aria-valuemin
 */
export const setValueMin = (element, value) => setAriaState(element, 'aria-valuemin', value);

/**
 * Update aria-valuemax
 */
export const setValueMax = (element, value) => setAriaState(element, 'aria-valuemax', value);

/**
 * Set aria-valuenow, or remove it when value is null/undefined (e.g. indeterminate progress)
 */
export const setValueNow = (element, value) =>
  value == null ? element.removeAttribute('aria-valuenow') : setAriaState(element, 'aria-valuenow', value);

/**
 * Maps ARIA roles to their appropriate aria-haspopup values
 */
export const ARIA_HASPOPUP_VALUES = {
  menu: 'menu',
  listbox: 'listbox',
  tree: 'tree',
  grid: 'grid',
  dialog: 'dialog',
};

/**
 * Apply attributes to element if they should be set
 */
const applyAttributes = (element, attributes, result) => {
  Object.entries(attributes).forEach(([attr, value]) => {
    element.setAttribute(attr, value);
    result[attr] = value;
  });
};

/**
 * Check if attribute should be set based on override and existing value
 */
const shouldSet = (element, attribute, override) => override || !element.hasAttribute(attribute);

/**
 * Connects a trigger element to a target element with ARIA relationships
 * @param {Object} options - Configuration options
 * @param {HTMLElement} options.trigger - Trigger/anchor element (e.g., button)
 * @param {HTMLElement} options.target - Target/reference element (e.g., menu, dialog)
 * @param {string} [options.role] - ARIA role for the target element
 * @param {boolean} [options.override=false] - Override existing attributes
 * @returns {Object} Object containing set attributes with trigger and target subobjects
 */
export function connectTriggerToTarget({ trigger, target, role = null, override = false }) {
  const result = { trigger: {}, target: {} };

  if (!trigger || !target) return result;

  const triggerAttrs = {};
  const targetAttrs = {};

  // Set target role
  if (role && shouldSet(target, 'role', override)) {
    targetAttrs.role = role;
  }

  // Set trigger attributes if target has an ID
  if (target.id) {
    if (shouldSet(trigger, 'aria-controls', override)) {
      triggerAttrs['aria-controls'] = target.id;
    }

    if (role === 'tooltip' && shouldSet(trigger, 'aria-describedby', override)) {
      triggerAttrs['aria-describedby'] = target.id;
    }
  }

  // Set aria-haspopup based on role
  if (role && shouldSet(trigger, 'aria-haspopup', override)) {
    const haspopup = ARIA_HASPOPUP_VALUES[role] || 'true';
    if (haspopup) triggerAttrs['aria-haspopup'] = haspopup;
  }

  applyAttributes(target, targetAttrs, result.target);
  applyAttributes(trigger, triggerAttrs, result.trigger);

  return result;
}

/**
 * Remove attributes from element if they exist
 */
const removeAttributes = (element, attributes) => {
  attributes.forEach((attr) => {
    if (element.hasAttribute(attr)) {
      element.removeAttribute(attr);
    }
  });
};

/**
 * Disconnects a trigger element from a target element by removing ARIA relationships
 * @param {Object} options - Configuration options
 * @param {HTMLElement} options.trigger - Trigger element
 * @param {HTMLElement} options.target - Target element
 * @param {string[]} [options.attributes] - Specific attributes to remove (default: all)
 */
export function disconnectTriggerFromTarget({ trigger, target, attributes = null }) {
  if (!trigger || !target) return;

  const defaultAttrs = ['aria-controls', 'aria-haspopup', 'aria-describedby'];
  const attrsToRemove = attributes || defaultAttrs;

  removeAttributes(trigger, attrsToRemove);

  if (!attributes || attributes.includes('role')) {
    removeAttributes(target, ['role']);
  }
}
