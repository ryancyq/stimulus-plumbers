import Plumber from './plumber';
import { PlainFormatter } from './formatters/plain';
import { CreditCardFormatter } from './formatters/credit_card';
import { PhoneFormatter } from './formatters/phone';
import { CurrencyFormatter } from './formatters/currency';
import { DateFormatter } from './formatters/date';
import { TimeFormatter } from './formatters/time';

export const FORMATTER_TYPES = {
  PLAIN: 'plain',
  CREDIT_CARD: 'creditCard',
  PHONE: 'phone',
  CURRENCY: 'currency',
  DATE: 'date',
  TIME: 'time',
};

const registry = new Map([
  [FORMATTER_TYPES.PLAIN, PlainFormatter],
  [FORMATTER_TYPES.CREDIT_CARD, CreditCardFormatter],
  [FORMATTER_TYPES.PHONE, PhoneFormatter],
  [FORMATTER_TYPES.CURRENCY, CurrencyFormatter],
  [FORMATTER_TYPES.DATE, DateFormatter],
  [FORMATTER_TYPES.TIME, TimeFormatter],
]);

const defaultOptions = {
  type: FORMATTER_TYPES.PLAIN,
  options: {},
};

export class Formatter extends Plumber {
  static register(type, formatter) {
    registry.set(type, formatter);
  }

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

    Object.defineProperty(this.controller, 'formatter', {
      get() {
        return helpers;
      },
      configurable: true,
    });
  }
}

export const attachFormatter = (controller, options) => new Formatter(controller, options);
