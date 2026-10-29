import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import InputClearableController from '../../../src/controllers/input_clearable_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('InputClearableController', () => {
  let application;

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-clearable"]'),
      'input-clearable'
    );

  const setup = async (html) => {
    document.body.innerHTML = html;
    await flush();
  };

  beforeEach(() => {
    application = startApplication({ 'input-clearable': InputClearableController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('connect — empty input', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('hides the clear button when input is empty', () => {
      expect(document.querySelector('[data-input-clearable-target="clear"]').hidden).toBe(true);
    });
  });

  describe('connect — pre-filled input', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="rails" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('shows the clear button when input has a value', () => {
      expect(document.querySelector('[data-input-clearable-target="clear"]').hidden).toBe(false);
    });
  });

  describe('input event', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('shows the clear button when input receives a value', async () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      input.value = 'hello';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      await flush();
      expect(document.querySelector('[data-input-clearable-target="clear"]').hidden).toBe(false);
    });

    it('hides the clear button when input is cleared', async () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      input.value = 'hello';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      await flush();

      input.value = '';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      await flush();
      expect(document.querySelector('[data-input-clearable-target="clear"]').hidden).toBe(true);
    });
  });

  describe('clear()', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="hello" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('sets input value to empty string', () => {
      getController().clear();
      expect(document.querySelector('[data-input-clearable-target="input"]').value).toBe('');
    });

    it('hides the clear button', () => {
      getController().clear();
      expect(document.querySelector('[data-input-clearable-target="clear"]').hidden).toBe(true);
    });

    it('dispatches a bubbling input event on the input element', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      const spy = vi.fn();
      document.body.addEventListener('input', spy);
      getController().clear();
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].target).toBe(input);
    });

    it('returns focus to the input', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      getController().clear();
      expect(document.activeElement).toBe(input);
    });
  });

  describe('Escape key', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="hello" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('clears the input when Escape is pressed with a value', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true });
      input.dispatchEvent(event);
      expect(input.value).toBe('');
      expect(event.defaultPrevented).toBe(true);
    });

    it('does nothing when Escape is pressed on an empty input', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      input.value = '';
      const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true });
      input.dispatchEvent(event);
      expect(event.defaultPrevented).toBe(false);
    });

    it('ignores non-Escape keys', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      const event = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true });
      input.dispatchEvent(event);
      expect(input.value).toBe('hello');
    });

    it('leaves Escape to an expanded combobox', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      input.setAttribute('aria-expanded', 'true');
      const event = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true });
      input.dispatchEvent(event);
      expect(input.value).toBe('hello');
      expect(event.defaultPrevented).toBe(false);
    });

    it('leaves an Escape that a combobox already handled', () => {
      const input = document.querySelector('[data-input-clearable-target="input"]');
      input.addEventListener('keydown', (event) => event.preventDefault(), { capture: true });
      input.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', bubbles: true, cancelable: true }));
      expect(input.value).toBe('hello');
    });
  });

  describe('missing targets', () => {
    beforeEach(async () => {
      await setup(`<div data-controller="input-clearable"></div>`);
    });

    it('does not throw on connect when targets are absent', () => {
      expect(() => getController().connect()).not.toThrow();
    });

    it('does not throw when clear() is called without targets', () => {
      expect(() => getController().clear()).not.toThrow();
    });
  });

  describe('input target replaced', () => {
    beforeEach(async () => {
      await setup(`
        <div data-controller="input-clearable">
          <input type="search" value="old" data-input-clearable-target="input">
          <button type="button" aria-label="Clear search"
                  data-input-clearable-target="clear"
                  data-action="click->input-clearable#clear">
          </button>
        </div>
      `);
    });

    it('ignores Escape on the removed input', async () => {
      const removed = document.querySelector('[data-input-clearable-target="input"]');
      removed.outerHTML = '<input type="search" value="rails" data-input-clearable-target="input">';
      await flush();

      removed.dispatchEvent(new KeyboardEvent('keydown', { key: 'Escape', cancelable: true }));

      expect(document.querySelector('[data-input-clearable-target="input"]').value).toBe('rails');
    });
  });
});
