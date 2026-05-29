import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import InputComboboxController from '../../../src/controllers/input_combobox_controller';

describe('InputComboboxController', () => {
  let application;

  beforeEach(async () => {
    application = Application.start();
    application.register('input-combobox', InputComboboxController);

    document.body.innerHTML = `
      <div data-controller="input-combobox">
        <input type="text" data-input-combobox-target="trigger"
               role="combobox" aria-expanded="false" aria-haspopup="dialog">
        <input type="hidden" data-input-combobox-target="input">
      </div>
    `;
    await new Promise((resolve) => setTimeout(resolve, 10));
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="input-combobox"]'),
      'input-combobox'
    );

  describe('onSelect', () => {
    it('writes event.detail.value to the value target', async () => {
      getController().onSelect({ detail: { value: '2024-03-15' } });
      await new Promise((r) => setTimeout(r, 10));
      expect(document.querySelector('[data-input-combobox-target="input"]').value).toBe('2024-03-15');
    });

    it('ignores events without a value in detail', () => {
      getController().onSelect({ detail: {} });
      expect(document.querySelector('[data-input-combobox-target="input"]').value).toBe('');
    });

    it('does not manage panel visibility (delegated to popover)', () => {
      const controller = getController();
      expect(controller.open).toBeUndefined();
      expect(controller.close).toBeUndefined();
      expect(controller.toggle).toBeUndefined();
    });
  });

  describe('valueValueChanged', () => {
    it('dispatches input-combobox:changed with the new value', async () => {
      const el = document.querySelector('[data-controller="input-combobox"]');
      const spy = vi.fn();
      el.addEventListener('input-combobox:changed', spy);
      getController().valueValue = 'hello';
      await new Promise((r) => setTimeout(r, 10));
      expect(spy).toHaveBeenCalled();
      expect(spy.mock.calls[spy.mock.calls.length - 1][0].detail.value).toBe('hello');
    });

    it('syncs value to the value target', async () => {
      getController().valueValue = 'abc';
      await new Promise((r) => setTimeout(r, 10));
      expect(document.querySelector('[data-input-combobox-target="input"]').value).toBe('abc');
    });
  });

  describe('onInput', () => {
    const mockOutlet = () => ({ showAll: vi.fn(), filter: vi.fn() });

    function wireOutlet(ctrl, outlet) {
      Object.defineProperty(ctrl, 'hasComboboxDropdownOutlet', { get: () => true, configurable: true });
      Object.defineProperty(ctrl, 'comboboxDropdownOutlet', { get: () => outlet, configurable: true });
    }

    it('ignores input events from elements other than the trigger', () => {
      const outlet = mockOutlet();
      wireOutlet(getController(), outlet);

      const other = document.createElement('input');
      other.value = 'something';
      getController().onInput({ target: other });

      expect(outlet.showAll).not.toHaveBeenCalled();
      expect(outlet.filter).not.toHaveBeenCalled();
    });

    it('calls showAll when query is shorter than minLength', () => {
      const outlet = mockOutlet();
      wireOutlet(getController(), outlet);

      const trigger = document.querySelector('[data-input-combobox-target="trigger"]');
      trigger.value = ''; // length 0 < default minLength 1
      getController().onInput({ target: trigger });

      expect(outlet.showAll).toHaveBeenCalledOnce();
      expect(outlet.filter).not.toHaveBeenCalled();
    });

    it('calls filter(query) when query meets minLength', () => {
      const outlet = mockOutlet();
      wireOutlet(getController(), outlet);

      const trigger = document.querySelector('[data-input-combobox-target="trigger"]');
      trigger.value = 'abc';
      getController().onInput({ target: trigger });

      expect(outlet.filter).toHaveBeenCalledWith('abc');
      expect(outlet.showAll).not.toHaveBeenCalled();
    });

    it('does not throw when below minLength and no outlet is connected', () => {
      const trigger = document.querySelector('[data-input-combobox-target="trigger"]');
      trigger.value = '';
      expect(() => getController().onInput({ target: trigger })).not.toThrow();
    });

    it('does not throw when above minLength and no outlet is connected', () => {
      const trigger = document.querySelector('[data-input-combobox-target="trigger"]');
      trigger.value = 'hello';
      expect(() => getController().onInput({ target: trigger })).not.toThrow();
    });
  });
});
