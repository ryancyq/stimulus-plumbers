import { describe, it, expect, beforeEach } from 'vitest'
import {
  InputFormat,
  FORMATTER_TYPES,
  attachInputFormat,
} from '../../../src/plumbers/input_format'

describe('InputFormat', () => {
  let mockController

  beforeEach(() => {
    mockController = {
      identifier: 'input-format',
      element: document.createElement('div'),
      dispatch: () => {},
    }
  })

  describe('FORMATTER_TYPES', () => {
    it('defines plain type', () => {
      expect(FORMATTER_TYPES.PLAIN).toBe('plain')
    })

    it('defines creditCard type', () => {
      expect(FORMATTER_TYPES.CREDIT_CARD).toBe('creditCard')
    })

    it('defines phone type', () => {
      expect(FORMATTER_TYPES.PHONE).toBe('phone')
    })

    it('defines currency type', () => {
      expect(FORMATTER_TYPES.CURRENCY).toBe('currency')
    })

    it('defines date type', () => {
      expect(FORMATTER_TYPES.DATE).toBe('date')
    })
  })

  describe('enhance', () => {
    it('exposes inputFormat namespace on controller', () => {
      attachInputFormat(mockController)
      expect(mockController.inputFormat).toBeDefined()
    })

    it('exposes normalize helper', () => {
      attachInputFormat(mockController)
      expect(typeof mockController.inputFormat.normalize).toBe('function')
    })

    it('exposes validate helper', () => {
      attachInputFormat(mockController)
      expect(typeof mockController.inputFormat.validate).toBe('function')
    })

    it('exposes format helper', () => {
      attachInputFormat(mockController)
      expect(typeof mockController.inputFormat.format).toBe('function')
    })

    it('exposes mask helper', () => {
      attachInputFormat(mockController)
      expect(typeof mockController.inputFormat.mask).toBe('function')
    })

    it('exposes maskable helper', () => {
      attachInputFormat(mockController)
      expect(typeof mockController.inputFormat.maskable).toBe('function')
    })
  })

  describe('maskable', () => {
    it('returns false for plain', () => {
      attachInputFormat(mockController, { type: 'plain' })
      expect(mockController.inputFormat.maskable()).toBe(false)
    })

    it('returns false for creditCard', () => {
      attachInputFormat(mockController, { type: 'creditCard' })
      expect(mockController.inputFormat.maskable()).toBe(false)
    })

    it('returns false for phone', () => {
      attachInputFormat(mockController, { type: 'phone' })
      expect(mockController.inputFormat.maskable()).toBe(false)
    })

    it('returns false for currency', () => {
      attachInputFormat(mockController, { type: 'currency' })
      expect(mockController.inputFormat.maskable()).toBe(false)
    })

    it('returns false for date', () => {
      attachInputFormat(mockController, { type: 'date' })
      expect(mockController.inputFormat.maskable()).toBe(false)
    })
  })

  describe('delegation to formatters', () => {
    it('delegates normalize to creditCard formatter', () => {
      attachInputFormat(mockController, { type: 'creditCard' })
      expect(mockController.inputFormat.normalize('4242 4242 4242 4242')).toBe('4242424242424242')
    })

    it('delegates validate to creditCard formatter', () => {
      attachInputFormat(mockController, { type: 'creditCard' })
      expect(mockController.inputFormat.validate('4242424242424242')).toBe(true)
      expect(mockController.inputFormat.validate('4242424242424241')).toBe(false)
    })

    it('delegates format to creditCard formatter', () => {
      attachInputFormat(mockController, { type: 'creditCard' })
      expect(mockController.inputFormat.format('4242424242424242')).toBe('4242 4242 4242 4242')
    })

    it('passes options to currency formatter', () => {
      attachInputFormat(mockController, {
        type: 'currency',
        options: { locale: 'en-US', currency: 'USD' },
      })
      expect(mockController.inputFormat.format('1234.56')).toBe('$1,234.56')
    })
  })

  describe('register', () => {
    it('allows registering a custom formatter type', () => {
      const CustomFormatter = {
        normalize: (raw) => raw.toUpperCase(),
        validate: () => true,
        format: (value) => `[${value}]`,
        mask: (value) => `***${value.slice(-2)}`,
      }
      InputFormat.register('custom-test', CustomFormatter)
      attachInputFormat(mockController, { type: 'custom-test' })

      expect(mockController.inputFormat.normalize('hello')).toBe('HELLO')
      expect(mockController.inputFormat.format('HELLO')).toBe('[HELLO]')
      expect(mockController.inputFormat.mask('HELLO')).toBe('***LO')
      expect(mockController.inputFormat.maskable()).toBe(true)
    })
  })

  describe('unknown type', () => {
    it('falls back to plain formatter for unregistered type', () => {
      attachInputFormat(mockController, { type: 'unknown-xyz' })
      expect(mockController.inputFormat.normalize('test')).toBe('test')
      expect(mockController.inputFormat.validate('test')).toBe(true)
    })
  })

  describe('configurable property', () => {
    it('allows re-attaching with a different type', () => {
      attachInputFormat(mockController, { type: 'creditCard' })
      expect(mockController.inputFormat.format('4242424242424242')).toBe('4242 4242 4242 4242')

      attachInputFormat(mockController, { type: 'currency' })
      expect(mockController.inputFormat.format('1234.56')).toBe('$1,234.56')
    })
  })
})
