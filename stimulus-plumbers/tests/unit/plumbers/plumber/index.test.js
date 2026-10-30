import { describe, it, expect, beforeEach, vi } from 'vitest';
import Plumber from '../../../../src/plumbers/plumber';

describe('Plumber', () => {
  let mockController;
  let element;

  beforeEach(() => {
    element = document.createElement('div');
    document.body.appendChild(element);

    mockController = {
      identifier: 'test',
      element: element,
      dispatch: vi.fn((name, options) => true),
    };
  });

  describe('constructor', () => {
    it('initializes with default options', () => {
      const plumber = new Plumber(mockController);

      expect(plumber.controller).toBe(mockController);
      expect(plumber.element).toBe(element);
      expect(plumber.visibleOnly).toBe(true);
      expect(plumber.notify).toBe(true);
      expect(plumber.prefix).toBe('test');
    });

    it('accepts custom element option', () => {
      const customElement = document.createElement('span');
      const plumber = new Plumber(mockController, { element: customElement });

      expect(plumber.element).toBe(customElement);
    });

    it('accepts visible as boolean', () => {
      const plumber = new Plumber(mockController, { visible: false });

      expect(plumber.visibleOnly).toBe(false);
      expect(plumber.visibleCallback).toBe(null);
    });

    it('accepts visible as string callback name', () => {
      const plumber = new Plumber(mockController, { visible: 'customVisible' });

      expect(plumber.visibleOnly).toBe(true);
      expect(plumber.visibleCallback).toBe('customVisible');
    });

    it('accepts dispatch option', () => {
      const plumber = new Plumber(mockController, { dispatch: false });

      expect(plumber.notify).toBe(false);
    });

    it('accepts custom prefix', () => {
      const plumber = new Plumber(mockController, { prefix: 'custom' });

      expect(plumber.prefix).toBe('custom');
    });

    it('falls back to controller identifier when prefix is empty string', () => {
      const plumber = new Plumber(mockController, { prefix: '' });

      expect(plumber.prefix).toBe('test');
    });
  });

  describe('visible', () => {
    it('returns false when element is not an HTMLElement', () => {
      const plumber = new Plumber(mockController, { element: null });

      expect(plumber.visible).toBe(false);
    });

    it('returns true when visibleOnly is false', () => {
      element.setAttribute('hidden', true);
      const plumber = new Plumber(mockController, { visible: false });

      expect(plumber.visible).toBe(true);
    });

    it('returns false when element has hidden attribute', () => {
      element.setAttribute('hidden', true);
      const plumber = new Plumber(mockController);

      expect(plumber.visible).toBe(false);
    });

    it('returns true when element is visible and in viewport', () => {
      const plumber = new Plumber(mockController);
      element.getBoundingClientRect = () => ({
        top: 100,
        left: 100,
        width: 200,
        height: 200,
      });

      expect(plumber.visible).toBe(true);
    });

    it('uses custom visibility callback when provided', () => {
      const customVisible = vi.fn(() => false);
      mockController.customVisible = customVisible;
      const plumber = new Plumber(mockController, { visible: 'customVisible' });
      plumber.customVisible = customVisible;

      element.getBoundingClientRect = () => ({
        top: 100,
        left: 100,
        width: 200,
        height: 200,
      });

      expect(plumber.visible).toBe(false);
      expect(mockController.customVisible).toHaveBeenCalledWith(element);
    });
  });

  describe('isVisible', () => {
    it('returns false when target is not an HTMLElement', () => {
      const plumber = new Plumber(mockController);

      expect(plumber.isVisible(null)).toBe(false);
      expect(plumber.isVisible(undefined)).toBe(false);
      expect(plumber.isVisible({})).toBe(false);
    });

    it('returns true when element does not have hidden attribute', () => {
      const plumber = new Plumber(mockController);

      expect(plumber.isVisible(element)).toBe(true);
    });

    it('returns false when element has hidden attribute', () => {
      element.setAttribute('hidden', true);
      const plumber = new Plumber(mockController);

      expect(plumber.isVisible(element)).toBe(false);
    });

    it('uses visibleCallback when provided', () => {
      const customCallback = vi.fn(() => false);
      mockController.customVisible = customCallback;
      const plumber = new Plumber(mockController, { visible: 'customVisible' });
      plumber.customVisible = customCallback;

      plumber.isVisible(element);

      expect(customCallback).toHaveBeenCalledWith(element);
    });
  });

  describe('dispatch', () => {
    it('dispatches event when notify is true', () => {
      const plumber = new Plumber(mockController);

      plumber.dispatch('test-event');

      expect(mockController.dispatch).toHaveBeenCalledWith('test-event', {
        target: element,
        prefix: 'test',
        detail: null,
      });
    });

    it('does not dispatch when notify is false', () => {
      const plumber = new Plumber(mockController, { dispatch: false });

      plumber.dispatch('test-event');

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('accepts custom target', () => {
      const plumber = new Plumber(mockController);
      const customTarget = document.createElement('span');

      plumber.dispatch('test-event', { target: customTarget });

      expect(mockController.dispatch).toHaveBeenCalledWith('test-event', {
        target: customTarget,
        prefix: 'test',
        detail: null,
      });
    });

    it('accepts custom prefix', () => {
      const plumber = new Plumber(mockController);

      plumber.dispatch('test-event', { prefix: 'custom' });

      expect(mockController.dispatch).toHaveBeenCalledWith('test-event', {
        target: element,
        prefix: 'custom',
        detail: null,
      });
    });

    it('accepts custom detail', () => {
      const plumber = new Plumber(mockController);
      const detail = { foo: 'bar' };

      plumber.dispatch('test-event', { detail });

      expect(mockController.dispatch).toHaveBeenCalledWith('test-event', {
        target: element,
        prefix: 'test',
        detail: detail,
      });
    });
  });

  describe('findCallback', () => {
    it('returns undefined for non-string names', () => {
      const plumber = new Plumber(mockController);

      expect(plumber.findCallback(null)).toBeUndefined();
      expect(plumber.findCallback(123)).toBeUndefined();
    });

    it('finds direct method on plumber instance', () => {
      const plumber = new Plumber(mockController);
      plumber.myMethod = vi.fn();

      const callback = plumber.findCallback('myMethod');

      expect(callback).toBeTypeOf('function');
    });

    it('finds method on controller using dot notation', () => {
      mockController.nested = {
        method: vi.fn(),
      };
      const plumber = new Plumber(mockController);
      const callback = plumber.findCallback('nested.method');

      expect(callback).toBeTypeOf('function');
    });

    it('binds callback to controller context', () => {
      let capturedThis;
      const myMethod = function () {
        capturedThis = this;
      };
      mockController.myMethod = myMethod;
      const plumber = new Plumber(mockController);
      const callback = plumber.findCallback('myMethod');
      callback();

      expect(capturedThis).toBe(mockController);
    });

    it('returns undefined for non-existent paths', () => {
      const plumber = new Plumber(mockController);
      plumber['nonExistent.method'] = 'nonExistent.method';

      const callback = plumber.findCallback('nonExistent.method');

      expect(callback).toBeUndefined();
    });
  });

  describe('awaitCallback', () => {
    it('resolves string callback names', async () => {
      const mockFn = vi.fn(() => 'result');
      mockController.myMethod = mockFn;
      const plumber = new Plumber(mockController);

      const result = await plumber.awaitCallback('myMethod', 'arg1', 'arg2');

      expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
      expect(result).toBe('result');
    });

    it('handles function callbacks directly', async () => {
      const plumber = new Plumber(mockController);
      const mockFn = vi.fn(() => 'result');

      const result = await plumber.awaitCallback(mockFn, 'arg1');

      expect(mockFn).toHaveBeenCalledWith('arg1');
      expect(result).toBe('result');
    });

    it('awaits promise results', async () => {
      const plumber = new Plumber(mockController);
      const mockFn = vi.fn(() => Promise.resolve('async result'));

      const result = await plumber.awaitCallback(mockFn);

      expect(result).toBe('async result');
    });

    it('returns synchronous results', async () => {
      const plumber = new Plumber(mockController);
      const mockFn = vi.fn(() => 'sync result');

      const result = await plumber.awaitCallback(mockFn);

      expect(result).toBe('sync result');
    });

    it('returns undefined for non-existent callbacks', async () => {
      const plumber = new Plumber(mockController);
      plumber['nonExistent.path'] = 'nonExistent.path';

      const result = await plumber.awaitCallback('nonExistent.path');

      expect(result).toBeUndefined();
    });

    it('returns undefined for non-function values', async () => {
      const plumber = new Plumber(mockController);

      const result = await plumber.awaitCallback(null);

      expect(result).toBeUndefined();
    });
  });
});
