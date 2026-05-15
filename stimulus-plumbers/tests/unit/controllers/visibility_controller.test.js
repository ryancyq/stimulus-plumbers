import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { visibilityConfig } from '../../../src/plumbers/plumber/config'
import VisibilityController from '../../../src/controllers/visibility_controller';

describe('VisibilityController', () => {
  let application;
  let visibleOnlySpy;
  let originalGetComputedStyle;

  beforeEach(() => {
    visibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
    visibilityConfig.hiddenClass = '';

    application = Application.start();
    application.register('visibility', VisibilityController);

    Object.defineProperty(window, 'scrollX', { value: 0, writable: true, configurable: true });
    Object.defineProperty(window, 'scrollY', { value: 0, writable: true, configurable: true });

    // jsdom returns '' for unset transforms; elementTranslations expects 'none'
    originalGetComputedStyle = window.getComputedStyle;
    window.getComputedStyle = vi.fn(() => ({ transform: 'none' }));
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    window.getComputedStyle = originalGetComputedStyle;
    visibilityConfig.hiddenClass = null;
    visibleOnlySpy.mockRestore();
  });

  describe('basic functionality', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <button data-action="visibility#toggle">Toggle</button>
          <div data-visibility-target="content" hidden>Content</div>
        </div>
        <button id="outside">Outside</button>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const content = document.querySelector('[data-visibility-target="content"]');
      content.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 200, right: 300,
        width: 200, height: 100, x: 100, y: 100
      }));
    });

    it('exposes dismissed method on connect', () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      expect(controller.dismissed).toBeDefined();
      expect(typeof controller.dismissed).toBe('function');
    });

    it('attaches visibility and shifter to content target', () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      expect(controller.visibility).toBeDefined();
      expect(controller.shift).toBeDefined();
    });

    it('toggles content visibility', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      expect(content.hidden).toBe(true);

      await controller.toggle();
      expect(content.hidden).toBe(false);

      await controller.toggle();
      expect(content.hidden).toBe(true);
    });

    it('shifts content to fit viewport on show', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 900, bottom: 200, right: 1100,
        width: 200, height: 100, x: 900, y: 100
      }));

      await controller.toggle();

      expect(content.style.transform).toBe('translate(-76px, 0px)');
    });
  });

  describe('dismisser integration', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>
            <p>Content</p>
          </div>
        </div>
        <button id="outside">Outside</button>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('hides content when dismissed', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      await controller.toggle();
      expect(content.hidden).toBe(false);

      await controller.dismissed();

      expect(content.hidden).toBe(true);
    });

    it('dismisses on outside click', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const content = document.querySelector('[data-visibility-target="content"]');
      const outsideButton = document.querySelector('#outside');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      await controller.toggle();
      expect(content.hidden).toBe(false);

      outsideButton.click();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(content.hidden).toBe(true);
    });

    it('does not dismiss on inside click', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const content = document.querySelector('[data-visibility-target="content"]');
      const insideContent = content.querySelector('p');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      await controller.toggle();
      expect(content.hidden).toBe(false);

      insideContent.click();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(content.hidden).toBe(false);
    });

    it('dispatches dismiss and dismissed events on outside click', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const outsideButton = document.querySelector('#outside');
      const dismissSpy = vi.fn();
      const dismissedSpy = vi.fn();

      element.addEventListener('visibility:dismiss', dismissSpy);
      element.addEventListener('visibility:dismissed', dismissedSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');
      await controller.toggle();

      outsideButton.click();
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(dismissSpy).toHaveBeenCalledTimes(1);
      expect(dismissedSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('without content target', () => {
    it('toggle is a no-op when content target is absent', async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <button data-action="visibility#toggle">Toggle</button>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      await expect(controller.toggle()).resolves.toBeUndefined();
    });

    it('dismissed is a no-op when content target is absent', async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <button data-action="visibility#toggle">Toggle</button>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      await expect(controller.dismissed()).resolves.toBeUndefined();
    });
  });

  describe('visibility states', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('tracks visibility state correctly', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      expect(controller.visibility.visible).toBe(false);

      await controller.toggle();
      expect(controller.visibility.visible).toBe(true);

      await controller.toggle();
      expect(controller.visibility.visible).toBe(false);
    });

    it('fires show and hide events across successive toggles', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const element = document.querySelector('[data-controller="visibility"]');
      const showSpy = vi.fn();
      const hideSpy = vi.fn();

      element.addEventListener('visibility:show', showSpy);
      element.addEventListener('visibility:hide', hideSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      expect(content.hidden).toBe(true);

      await controller.toggle();
      expect(showSpy).toHaveBeenCalledTimes(1);

      await controller.toggle();
      expect(hideSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('shifter integration', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('shifts content on window resize when visible', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 900, bottom: 200, right: 1100,
        width: 200, height: 100, x: 900, y: 100
      }));

      await controller.toggle();
      window.dispatchEvent(new Event('resize'));

      expect(content.style.transform).toBe('translate(-76px, 0px)');
    });

    it('produces zero translation for hidden content on resize', () => {
      const content = document.querySelector('[data-visibility-target="content"]');

      window.dispatchEvent(new Event('resize'));

      expect(content.style.transform).toBe('translate(0px, 0px)');
    });

    it('respects prefers-reduced-motion for shifting', async () => {
      application.stop();

      const matchMediaSpy = vi.spyOn(window, 'matchMedia').mockImplementation((query) => ({
        matches: query === '(prefers-reduced-motion: reduce)',
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
      }));

      application = Application.start();
      application.register('visibility', VisibilityController);

      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 800, bottom: 200, right: 1000,
        width: 200, height: 100, x: 800, y: 100
      }));

      await controller.toggle();

      expect(content.style.transition).toBe('none');

      matchMediaSpy.mockRestore();
    });
  });

  describe('event cleanup', () => {
    it('removes click event listener on disconnect', async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
        <button id="outside">Outside</button>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const element = document.querySelector('[data-controller="visibility"]');
      const content = document.querySelector('[data-visibility-target="content"]');
      const outsideButton = document.querySelector('#outside');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      await controller.toggle();
      expect(content.hidden).toBe(false);

      element.remove();
      await new Promise(resolve => setTimeout(resolve, 10));

      outsideButton.click();
      await new Promise(resolve => setTimeout(resolve, 10));
      expect(content.hidden).toBe(false);
    });

    it('removes resize event listener on disconnect', async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      const element = document.querySelector('[data-controller="visibility"]');
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 900, bottom: 200, right: 1100,
        width: 200, height: 100, x: 900, y: 100
      }));

      await controller.toggle();
      window.dispatchEvent(new Event('resize'));
      expect(content.style.transform).toBe('translate(-76px, 0px)');

      element.remove();
      await new Promise(resolve => setTimeout(resolve, 10));

      content.style.transform = '';
      window.dispatchEvent(new Event('resize'));
      await new Promise(resolve => setTimeout(resolve, 10));
      expect(content.style.transform).toBeFalsy();
    });
  });

  describe('visibility events', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('dispatches show event when showing', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const showSpy = vi.fn();
      element.addEventListener('visibility:show', showSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');
      await controller.toggle();

      expect(showSpy).toHaveBeenCalled();
    });

    it('dispatches shown event after showing', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const shownSpy = vi.fn();
      element.addEventListener('visibility:shown', shownSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');
      await controller.toggle();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(shownSpy).toHaveBeenCalled();
    });

    it('dispatches hide event when hiding', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const hideSpy = vi.fn();
      element.addEventListener('visibility:hide', hideSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');
      await controller.toggle();
      await controller.toggle();

      expect(hideSpy).toHaveBeenCalled();
    });

    it('dispatches hidden event after hiding', async () => {
      const element = document.querySelector('[data-controller="visibility"]');
      const hiddenSpy = vi.fn();
      element.addEventListener('visibility:hidden', hiddenSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'visibility');
      await controller.toggle();
      await controller.toggle();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(hiddenSpy).toHaveBeenCalled();
    });
  });

  describe('with CSS class visibility mode', () => {
    beforeEach(async () => {
      visibilityConfig.hiddenClass = 'hidden';
      document.body.innerHTML = `
        <div data-controller="visibility">
          <div data-visibility-target="content" class="hidden">Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('shows content by removing the hidden class', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      expect(content.classList.contains('hidden')).toBe(true);

      await controller.toggle();

      expect(content.classList.contains('hidden')).toBe(false);
      expect(content.hasAttribute('hidden')).toBe(false);
    });

    it('hides content by adding the hidden class', async () => {
      const content = document.querySelector('[data-visibility-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      await controller.toggle();
      await controller.toggle();

      expect(content.classList.contains('hidden')).toBe(true);
    });

    it('tracks visibility state via class', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="visibility"]'),
        'visibility'
      );

      expect(controller.visibility.visible).toBe(false);

      await controller.toggle();
      expect(controller.visibility.visible).toBe(true);

      await controller.toggle();
      expect(controller.visibility.visible).toBe(false);
    });
  });
});
