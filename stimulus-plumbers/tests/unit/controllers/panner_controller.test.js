import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { visibilityConfig } from '../../../src/plumbers/plumber/config';
import PannerController from '../../../src/controllers/panner_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('PannerController', () => {
  let application;
  let isVisibleOnlySpy;
  let originalGetComputedStyle;

  beforeEach(() => {
    application = startApplication({ panner: PannerController });
    isVisibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);

    Object.defineProperty(window, 'scrollX', { value: 0, writable: true, configurable: true });
    Object.defineProperty(window, 'scrollY', { value: 0, writable: true, configurable: true });

    // jsdom returns '' for unset transforms; elementTranslations expects 'none'
    originalGetComputedStyle = window.getComputedStyle;
    window.getComputedStyle = vi.fn(() => ({ transform: 'none' }));
  });

  afterEach(() => {
    document.body.innerHTML = '';
    window.getComputedStyle = originalGetComputedStyle;
    isVisibleOnlySpy.mockRestore();
  });

  describe('basic functionality', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="panner">
          <div data-panner-target="content">Content</div>
        </div>
      `;

      const element = document.querySelector('[data-controller="panner"]');
      element.getBoundingClientRect = vi.fn(() => ({
        top: 50,
        left: 50,
        bottom: 250,
        right: 250,
        width: 200,
        height: 200,
        x: 50,
        y: 50,
      }));
    });

    it('shifts content when overflowing viewport', () => {
      const content = document.querySelector('[data-panner-target="content"]');

      // Mock content overflowing right edge of viewport
      content.getBoundingClientRect = vi.fn(() => ({
        top: 100,
        left: 800,
        bottom: 200,
        right: 1000,
        width: 200,
        height: 100,
        x: 800,
        y: 100,
      }));

      // Trigger resize event to cause shift
      window.dispatchEvent(new Event('resize'));

      // Content should have transform applied
      expect(content.style.transform).toBeTruthy();
    });

    it('dispatches shift event before shifting', () => {
      const element = document.querySelector('[data-controller="panner"]');
      const content = document.querySelector('[data-panner-target="content"]');
      const shiftSpy = vi.fn();

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100,
        left: 800,
        bottom: 200,
        right: 1000,
        width: 200,
        height: 100,
        x: 800,
        y: 100,
      }));

      element.addEventListener('panner:shift', shiftSpy);
      window.dispatchEvent(new Event('resize'));

      expect(shiftSpy).toHaveBeenCalled();
    });

    it('dispatches shifted event after shifting', async () => {
      const element = document.querySelector('[data-controller="panner"]');
      const content = document.querySelector('[data-panner-target="content"]');
      const shiftedSpy = vi.fn();

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100,
        left: 800,
        bottom: 200,
        right: 1000,
        width: 200,
        height: 100,
        x: 800,
        y: 100,
      }));

      element.addEventListener('panner:shifted', shiftedSpy);
      window.dispatchEvent(new Event('resize'));

      await flush();
      expect(shiftedSpy).toHaveBeenCalled();
    });
  });

  describe('without content target', () => {
    it('works with element as default content', async () => {
      document.body.innerHTML = `
        <div data-controller="panner">
          <p>Direct content</p>
        </div>
      `;

      await flush();
      const element = document.querySelector('[data-controller="panner"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'panner');

      expect(controller).toBeTruthy();
      expect(controller.shift).toBeDefined();
    });
  });

  describe('viewport boundaries', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="panner">
          <div data-panner-target="content">Content</div>
        </div>
      `;
    });

    it('does not shift when hidden', () => {
      document.body.innerHTML = `
        <div data-controller="panner" hidden>
          <div data-panner-target="content">Content</div>
        </div>
      `;

      const content = document.querySelector('[data-panner-target="content"]');
      content.getBoundingClientRect = vi.fn(() => ({
        top: 100,
        left: 800,
        bottom: 200,
        right: 1000,
        width: 200,
        height: 100,
        x: 800,
        y: 100,
      }));

      window.dispatchEvent(new Event('resize'));

      expect(content.style.transform).toBeFalsy();
    });
  });

  describe('event cleanup', () => {
    it('removes event listeners on disconnect', () => {
      document.body.innerHTML = `
        <div data-controller="panner">
          <div data-panner-target="content">Content</div>
        </div>
      `;

      const element = document.querySelector('[data-controller="panner"]');
      const content = document.querySelector('[data-panner-target="content"]');
      const shiftSpy = vi.fn();

      content.getBoundingClientRect = vi.fn(() => ({
        top: 100,
        left: 800,
        bottom: 200,
        right: 1000,
        width: 200,
        height: 100,
        x: 800,
        y: 100,
      }));

      element.addEventListener('panner:shift', shiftSpy);

      application.stop();

      window.dispatchEvent(new Event('resize'));
      expect(shiftSpy).not.toHaveBeenCalled();
    });
  });
});
