import Plumber from '../plumber';
import { PlainInputFormatter } from './formatters/plain';
import { CreditCardInputFormatter } from './formatters/credit_card';
import { PhoneInputFormatter } from './formatters/phone';
import { CurrencyInputFormatter } from './formatters/currency';
import { DateInputFormatter } from './formatters/date';
import { TimeInputFormatter } from './formatters/time';

export { PlainInputFormatter } from './formatters/plain';
export { CreditCardInputFormatter } from './formatters/credit_card';
export { PhoneInputFormatter } from './formatters/phone';
export { CurrencyInputFormatter } from './formatters/currency';
export { DateInputFormatter } from './formatters/date';
export { TimeInputFormatter } from './formatters/time';

export const FORMATTER_TYPES = {
  PLAIN: 'plain',
  CREDIT_CARD: 'creditCard',
  PHONE: 'phone',
  CURRENCY: 'currency',
  DATE: 'date',
  TIME: 'time',
};

const registry = new Map([
  [FORMATTER_TYPES.PLAIN, PlainInputFormatter],
  [FORMATTER_TYPES.CREDIT_CARD, CreditCardInputFormatter],
  [FORMATTER_TYPES.PHONE, PhoneInputFormatter],
  [FORMATTER_TYPES.CURRENCY, CurrencyInputFormatter],
  [FORMATTER_TYPES.DATE, DateInputFormatter],
  [FORMATTER_TYPES.TIME, TimeInputFormatter],
]);

const defaultOptions = {
  type: FORMATTER_TYPES.PLAIN,
  options: {},
};

export class InputFormat extends Plumber {
  /**
   * Registers a custom input formatter for a given type identifier.
   * @param {string} type - The type identifier (e.g. 'iban')
   * @param {Object} formatter - Object with normalize, validate, and optionally format/mask methods
   */
  static register(type, formatter) {
    registry.set(type, formatter);
  }

  /**
   * Creates a new InputFormat plumber instance.
   * @param {Object} controller - Stimulus controller instance
   * @param {Object} [options] - Configuration options
   * @param {string} [options.type='plain'] - Formatter type identifier
   * @param {Object} [options.options={}] - Type-specific options (e.g. locale, currency)
   */
  constructor(controller, options = {}) {
    super(controller, options);
    this.type = options.type ?? defaultOptions.type;
    this.options = options.options ?? defaultOptions.options;
    this.enhance();
  }

  enhance() {
    const context = this;
    const formatter = registry.get(context.type) ?? registry.get(FORMATTER_TYPES.PLAIN);

    const helpers = {
      normalize: (raw) => formatter.normalize?.(raw, context.options) ?? (typeof raw === 'string' ? raw : ''),
      validate: (value) => formatter.validate?.(value, context.options) ?? true,
      format: (value) => formatter.format?.(value, context.options) ?? (typeof value === 'string' ? value : ''),
      mask: (value) => formatter.mask?.(value, context.options) ?? null,
      maskable: () => typeof formatter.mask === 'function',
    };

    Object.defineProperty(this.controller, 'inputFormat', {
      get() {
        return helpers;
      },
      configurable: true,
    });
  }
}

/**
 * Factory function to create and attach an InputFormat plumber to a controller.
 * @param {Object} controller - Stimulus controller instance
 * @param {Object} [options] - Configuration options
 * @returns {InputFormat} InputFormat plumber instance
 */
export const attachInputFormat = (controller, options) => new InputFormat(controller, options);
