import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { visibilityConfig } from '../../../src/plumbers/plumber/config'  
import DismisserController from '../../../src/controllers/dismisser_controller';

describe('DismisserController', () => {
  let application;
  let isVisibleOnlySpy;

  beforeEach(() => {
    application = Application.start();
    application.register('dismisser', DismisserController);
    isVisibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    isVisibleOnlySpy.mockRestore();
  });

  describe('basic functionality', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="dismisser">
          <button>Inside</button>
        </div>
        <button id="outside">Outside</button>
      `;
    });

    it('dispatches dismiss event on outside click', () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const outsideButton = document.querySelector('#outside');
      const dismissSpy = vi.fn();

      element.addEventListener('dismisser:dismiss', dismissSpy);
      outsideButton.click();

      expect(dismissSpy).toHaveBeenCalled();
    });

    it('dispatches dismissed event after dismiss', async () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const outsideButton = document.querySelector('#outside');
      const dismissedSpy = vi.fn();

      element.addEventListener('dismisser:dismissed', dismissedSpy);
      outsideButton.click();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(dismissedSpy).toHaveBeenCalled();
    });

    it('does not dismiss on inside click', () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const insideButton = element.querySelector('button');
      const dismissSpy = vi.fn();

      element.addEventListener('dismisser:dismiss', dismissSpy);
      insideButton.click();

      expect(dismissSpy).not.toHaveBeenCalled();
    });

    it('dispatches events in correct order', async () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const outsideButton = document.querySelector('#outside');
      const events = [];

      element.addEventListener('dismisser:dismiss', () => events.push('dismiss'));
      element.addEventListener('dismisser:dismissed', () => events.push('dismissed'));

      outsideButton.click();
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(events).toEqual(['dismiss', 'dismissed']);
    });
  });

  describe('custom trigger', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="dismisser">
          <button data-dismisser-target="trigger">Trigger</button>
          <div>Content</div>
        </div>
        <button id="outside">Outside</button>
      `;
    });

    it('dismisses on outside click with custom trigger', () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const outsideButton = document.querySelector('#outside');
      const dismissSpy = vi.fn();

      element.addEventListener('dismisser:dismiss', dismissSpy);
      outsideButton.click();

      expect(dismissSpy).toHaveBeenCalled();
    });

    it('does not dismiss on trigger click', () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const trigger = document.querySelector('[data-dismisser-target="trigger"]');
      const dismissSpy = vi.fn();

      element.addEventListener('dismisser:dismiss', dismissSpy);
      trigger.click();

      expect(dismissSpy).not.toHaveBeenCalled();
    });

    it('does not dismiss on content click within element', () => {
      const element = document.querySelector('[data-controller="dismisser"]');
      const content = element.querySelector('div');
      const dismissSpy = vi.fn();

      element.addEventListener('dismisser:dismiss', dismissSpy);
      content.click();

      expect(dismissSpy).not.toHaveBeenCalled();
    });
  });

  describe('event cleanup', () => {
    it('removes event listeners on disconnect', async () => {
      document.body.innerHTML = `
        <div data-controller="dismisser">
          <button>Inside</button>
        </div>
        <button id="outside">Outside</button>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));
      const element = document.querySelector('[data-controller="dismisser"]');
      const dismissSpy = vi.fn();
      element.addEventListener('dismisser:dismiss', dismissSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'dismisser');
      controller.disconnect();

      document.querySelector('#outside').click();
      expect(dismissSpy).not.toHaveBeenCalled();
    });
  });
});
