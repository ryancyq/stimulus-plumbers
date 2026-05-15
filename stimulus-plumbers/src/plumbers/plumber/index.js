import { isWithinViewport } from './geometry';
import { visibilityConfig } from './config';

const defaultOptions = {
  element: null,
  visible: null,
  dispatch: true,
  prefix: '',
};

export default class Plumber {
  /**
   * Creates a new Plumber instance.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} options - Configuration options
   * @param {HTMLElement} [options.element] - Target element (defaults to controller.element)
   * @param {boolean|string} [options.visible=true] - Visibility check configuration
   * @param {boolean} [options.dispatch=true] - Enable event dispatching
   * @param {string} [options.prefix] - Event prefix (defaults to controller.identifier)
   */
  constructor(controller, options = {}) {
    this.controller = controller;

    const config = Object.assign({}, defaultOptions, options);
    const { element, visible, dispatch, prefix } = config;
    this.element = element || controller.element;
    this.visibleOnly = typeof visible === 'boolean' ? visible : visibilityConfig.visibleOnly;
    this.visibleCallback = typeof visible === 'string' ? visible : null;
    this.notify = !!dispatch;
    this.prefix = typeof prefix === 'string' && prefix ? prefix : controller.identifier;
  }

  /**
   * Checks if the element is visible in viewport.
   * @returns {boolean} True if element is visible
   */
  get visible() {
    if (!(this.element instanceof HTMLElement)) return false;
    if (!this.visibleOnly) return true;

    return isWithinViewport(this.element) && this.isVisible(this.element);
  }

  /**
   * Determines if a target element is visible.
   * @param {HTMLElement} target - Element to check
   * @returns {boolean} True if element is visible
   */
  isVisible(target) {
    if (this.visibleCallback) {
      const callback = this.findCallback(this.visibleCallback);
      if (typeof callback == 'function') return callback(target);
    }

    if (!(target instanceof HTMLElement)) return false;
    return !target.hasAttribute('hidden');
  }

  /**
   * Dispatches a custom event from the controller.
   * @param {string} name - Event name
   * @param {Object} [options] - Event options
   * @param {HTMLElement} [options.target] - Event target element
   * @param {string} [options.prefix] - Event prefix
   * @param {*} [options.detail] - Event detail data
   * @returns {boolean|undefined} Dispatch result
   */
  dispatch(name, { target = null, prefix = null, detail = null } = {}) {
    if (!this.notify) return;

    return this.controller.dispatch(name, {
      target: target || this.element,
      prefix: prefix || this.prefix,
      detail: detail,
    });
  }

  /**
   * Finds and binds a callback function by name from controller or plumber.
   * @param {string} name - Callback name or dot-notation path
   * @returns {Function|undefined} Bound callback function
   */
  findCallback(name) {
    if (typeof name !== 'string') return;

    const context = this;
    const controllerCallback = name.split('.').reduce((acc, key) => acc && acc[key], context.controller);
    if (typeof controllerCallback === 'function') {
      return controllerCallback.bind(context.controller);
    }
    const callback = name.split('.').reduce((acc, key) => acc && acc[key], context);
    if (typeof callback === 'function') {
      return callback.bind(context);
    }
  }

  /**
   * Executes a callback function and awaits if it returns a Promise.
   * @param {string|Function} callback - Callback name or function
   * @param {...*} args - Arguments to pass to callback
   * @returns {Promise<*>} Result of callback execution
   */
  async awaitCallback(callback, ...args) {
    if (typeof callback === 'string') callback = this.findCallback(callback);
    if (typeof callback === 'function') {
      const result = callback(...args);
      if (result instanceof Promise) return await result;
      else return result;
    }
  }
}
