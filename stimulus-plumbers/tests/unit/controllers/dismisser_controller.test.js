import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { visibilityConfig } from '../../../src/plumbers/plumber/config';
import DismisserController from '../../../src/controllers/dismisser_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('DismisserController', () => {
  let application;
  let isVisibleOnlySpy;

  beforeEach(() => {
    application = startApplication({ dismisser: DismisserController });
    isVisibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
  });

  afterEach(() => {
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

      await flush();
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
      await flush();

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

  describe('dismissed() callback', () => {
    it('invokes dismissed() on the controller when a subclass defines it', async () => {
      const dismissedSpy = vi.fn();

      class ExtendedDismisserController extends DismisserController {
        dismissed() {
          dismissedSpy();
        }
      }
      application.register('dismisser-ext', ExtendedDismisserController);

      document.body.innerHTML = `
        <div data-controller="dismisser-ext">
          <button>Inside</button>
        </div>
        <button id="outside">Outside</button>
      `;
      await flush();

      document.querySelector('#outside').click();
      await flush();

      expect(dismissedSpy).toHaveBeenCalledTimes(1);
    });

    it('does not invoke dismissed() when clicking inside', async () => {
      const dismissedSpy = vi.fn();

      class ExtendedDismisserController extends DismisserController {
        dismissed() {
          dismissedSpy();
        }
      }
      application.register('dismisser-ext', ExtendedDismisserController);

      document.body.innerHTML = `
        <div data-controller="dismisser-ext">
          <button id="inside">Inside</button>
        </div>
        <button id="outside">Outside</button>
      `;
      await flush();

      document.querySelector('#inside').click();
      await flush();

      expect(dismissedSpy).not.toHaveBeenCalled();
    });
  });

  describe('event cleanup', () => {
    it('dismisses once per outside click across reconnects and not after removal', async () => {
      document.body.innerHTML = `
        <div data-controller="dismisser"></div>
        <button id="outside">Outside</button>
      `;
      await flush();
      const element = document.querySelector('[data-controller="dismisser"]');
      const dismissSpy = vi.fn();
      element.addEventListener('dismisser:dismiss', dismissSpy);

      for (let i = 0; i < 3; i++) {
        element.remove();
        await flush();
        document.body.prepend(element);
        await flush();
      }

      document.querySelector('#outside').click();
      expect(dismissSpy).toHaveBeenCalledTimes(1);

      element.remove();
      await flush();
      document.querySelector('#outside').click();
      expect(dismissSpy).toHaveBeenCalledTimes(1);
    });

    it('removes event listeners on disconnect', async () => {
      document.body.innerHTML = `
        <div data-controller="dismisser">
          <button>Inside</button>
        </div>
        <button id="outside">Outside</button>
      `;

      await flush();
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
