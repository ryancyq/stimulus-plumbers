import { describe, it, expect, beforeEach } from 'vitest'
import {
  Formatter,
  FORMATTER_TYPES,
  attachFormatter,
} from '../../../src/plumbers/formatter'

describe('Formatter', () => {
  let mockController

  beforeEach(() => {
    mockController = {
      identifier: 'formatter',
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
    it('exposes formatter namespace on controller', () => {
      attachFormatter(mockController)
      expect(mockController.formatter).toBeDefined()
    })

    it('exposes normalize helper', () => {
      attachFormatter(mockController)
      expect(typeof mockController.formatter.normalize).toBe('function')
    })

    it('exposes validate helper', () => {
      attachFormatter(mockController)
      expect(typeof mockController.formatter.validate).toBe('function')
    })

    it('exposes format helper', () => {
      attachFormatter(mockController)
      expect(typeof mockController.formatter.format).toBe('function')
    })

    it('exposes mask helper', () => {
      attachFormatter(mockController)
      expect(typeof mockController.formatter.mask).toBe('function')
    })

    it('exposes maskable helper', () => {
      attachFormatter(mockController)
      expect(typeof mockController.formatter.maskable).toBe('function')
    })
  })

  describe('maskable', () => {
    it('returns false for plain', () => {
      attachFormatter(mockController, { type: 'plain' })
      expect(mockController.formatter.maskable()).toBe(false)
    })

    it('returns false for creditCard', () => {
      attachFormatter(mockController, { type: 'creditCard' })
      expect(mockController.formatter.maskable()).toBe(false)
    })

    it('returns false for phone', () => {
      attachFormatter(mockController, { type: 'phone' })
      expect(mockController.formatter.maskable()).toBe(false)
    })

    it('returns false for currency', () => {
      attachFormatter(mockController, { type: 'currency' })
      expect(mockController.formatter.maskable()).toBe(false)
    })

    it('returns false for date', () => {
      attachFormatter(mockController, { type: 'date' })
      expect(mockController.formatter.maskable()).toBe(false)
    })
  })

  describe('delegation to formatters', () => {
    it('delegates normalize to creditCard formatter', () => {
      attachFormatter(mockController, { type: 'creditCard' })
      expect(mockController.formatter.normalize('4242 4242 4242 4242')).toBe('4242424242424242')
    })

    it('delegates validate to creditCard formatter', () => {
      attachFormatter(mockController, { type: 'creditCard' })
      expect(mockController.formatter.validate('4242424242424242')).toBe(true)
      expect(mockController.formatter.validate('4242424242424241')).toBe(false)
    })

    it('delegates format to creditCard formatter', () => {
      attachFormatter(mockController, { type: 'creditCard' })
      expect(mockController.formatter.format('4242424242424242')).toBe('4242 4242 4242 4242')
    })

    it('passes options to currency formatter', () => {
      attachFormatter(mockController, {
        type: 'currency',
        options: { locale: 'en-US', currency: 'USD' },
      })
      expect(mockController.formatter.format('1234.56')).toBe('$1,234.56')
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
      Formatter.register('custom-test', CustomFormatter)
      attachFormatter(mockController, { type: 'custom-test' })

      expect(mockController.formatter.normalize('hello')).toBe('HELLO')
      expect(mockController.formatter.format('HELLO')).toBe('[HELLO]')
      expect(mockController.formatter.mask('HELLO')).toBe('***LO')
      expect(mockController.formatter.maskable()).toBe(true)
    })
  })

  describe('unknown type', () => {
    it('falls back to plain formatter for unregistered type', () => {
      attachFormatter(mockController, { type: 'unknown-xyz' })
      expect(mockController.formatter.normalize('test')).toBe('test')
      expect(mockController.formatter.validate('test')).toBe(true)
    })
  })

  describe('configurable property', () => {
    it('allows re-attaching with a different type', () => {
      attachFormatter(mockController, { type: 'creditCard' })
      expect(mockController.formatter.format('4242424242424242')).toBe('4242 4242 4242 4242')

      attachFormatter(mockController, { type: 'currency' })
      expect(mockController.formatter.format('1234.56')).toBe('$1,234.56')
    })
  })

  describe('cells hint', () => {
    it('exposes the strategy cells hint through helpers', () => {
      attachFormatter(mockController, { type: 'code', options: { length: 6 } })
      expect(mockController.formatter.cells()).toEqual({ groups: [], length: 6 })
    })

    it('returns null for strategies without a cells hint', () => {
      attachFormatter(mockController, { type: 'currency' })
      expect(mockController.formatter.cells()).toBeNull()
    })
  })
})
