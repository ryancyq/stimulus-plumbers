import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { visibilityConfig } from '../../../src/plumbers/plumber/support';
import PopoverController from '../../../src/controllers/popover_controller';

describe('PopoverController', () => {
  let application;
  let visibleOnlySpy;

  beforeEach(() => {
    visibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
    visibilityConfig.hiddenClass = '';

    application = Application.start();
    application.register('popover', PopoverController);

    global.fetch = vi.fn(async () => ({
      text: () => Promise.resolve('<p>Loaded content</p>'),
    }));
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    visibilityConfig.hiddenClass = null;
    visibleOnlySpy.mockRestore();
  });

  describe('basic functionality', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="content" hidden>Content</div>
          <div data-popover-target="loader" hidden>Loading...</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('attaches load and visibility to controller', () => {
      const element = document.querySelector('[data-controller="popover"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'popover');

      expect(controller.load).toBeDefined();
      expect(typeof controller.load).toBe('function');
      expect(controller.visibility).toBeDefined();
    });

    it('attaches contentLoaderVisibility when loader target is present', () => {
      const element = document.querySelector('[data-controller="popover"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'popover');

      expect(controller.contentLoaderVisibility).toBeDefined();
    });
  });

  describe('activator aria-expanded', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="activator">Open</button>
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    const button = () => document.querySelector('[data-popover-target="activator"]');

    it('sets aria-expanded="false" on connect when content is hidden', () => {
      expect(button().getAttribute('aria-expanded')).toBe('false');
    });

    it('sets aria-expanded="true" after show', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'), 'popover'
      );
      await controller.show();

      expect(button().getAttribute('aria-expanded')).toBe('true');
    });

    it('sets aria-expanded="false" after hide', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'), 'popover'
      );
      await controller.show();
      await controller.hide();

      expect(button().getAttribute('aria-expanded')).toBe('false');
    });
  });

  describe('show and hide', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('show makes content visible', async () => {
      const content = document.querySelector('[data-popover-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.show();

      expect(content.hidden).toBe(false);
    });

    it('hide makes content hidden', async () => {
      const content = document.querySelector('[data-popover-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.show();
      await controller.hide();

      expect(content.hidden).toBe(true);
    });
  });

  describe('loading content on show', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('fetches content after content becomes visible', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.show();

      expect(global.fetch).toHaveBeenCalledWith('/content');
    });

    it('does not re-fetch when reload is "never"', async () => {
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.show();
      global.fetch.mockClear();
      await controller.load();

      expect(global.fetch).not.toHaveBeenCalled();
    });
  });

  describe('contentLoad', () => {
    it('returns true for regular content target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.contentLoad()).toBe(true);
    });

    it('sets turbo-frame src and returns false', async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <turbo-frame data-popover-target="content" hidden>Content</turbo-frame>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      const result = controller.contentLoad();

      expect(controller.contentTarget.getAttribute('src')).toBe('/content');
      expect(result).toBe(false);
    });
  });

  describe('contentLoading and contentLoaded', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden>Content</div>
          <div data-popover-target="loader" hidden>Loading...</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('contentLoading shows loader target', async () => {
      const loader = document.querySelector('[data-popover-target="loader"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.contentLoading();

      expect(loader.hidden).toBe(false);
    });

    it('contentLoaded inserts content into content target', async () => {
      const content = document.querySelector('[data-popover-target="content"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      const template = document.createElement('template');
      template.innerHTML = '<p>New content</p>';
      await controller.contentLoaded({ content: template.content });

      expect(content.querySelector('p').textContent).toBe('New content');
    });

    it('contentLoaded hides loader after content insertion', async () => {
      const loader = document.querySelector('[data-popover-target="loader"]');
      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.contentLoading();

      const template = document.createElement('template');
      template.innerHTML = '<p>Content</p>';
      await controller.contentLoaded({ content: template.content });

      expect(loader.hidden).toBe(true);
    });
  });

  describe('contentLoader', () => {
    it('returns template element content', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <template data-popover-target="template"><p>Static</p></template>
          <div data-popover-target="content" hidden></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.contentLoader()).toBeInstanceOf(DocumentFragment);
    });

    it('returns innerHTML for non-template target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="template"><p>Static</p></div>
          <div data-popover-target="content" hidden></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.contentLoader()).toContain('<p>Static</p>');
    });

    it('returns undefined when no template target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden></div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.contentLoader()).toBeUndefined();
    });
  });

  describe('load lifecycle events', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('dispatches load, loading, and loaded events', async () => {
      const element = document.querySelector('[data-controller="popover"]');
      const loadSpy = vi.fn();
      const loadingSpy = vi.fn();
      const loadedSpy = vi.fn();

      element.addEventListener('popover:load', loadSpy);
      element.addEventListener('popover:loading', loadingSpy);
      element.addEventListener('popover:loaded', loadedSpy);

      const controller = application.getControllerForElementAndIdentifier(element, 'popover');
      await controller.show();

      expect(loadSpy).toHaveBeenCalledTimes(1);
      expect(loadingSpy).toHaveBeenCalledTimes(1);
      expect(loadedSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('without targets', () => {
    it('connects without content target', async () => {
      document.body.innerHTML = '<div data-controller="popover"></div>';
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.load).toBeDefined();
      expect(controller.visibility).toBeUndefined();
    });

    it('does not attach contentLoaderVisibility without loader target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      expect(controller.contentLoaderVisibility).toBeUndefined();
    });

    it('contentLoading does nothing without loader target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await expect(controller.contentLoading()).resolves.toBeUndefined();
    });

    it('skips fetch when no url value', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="content" hidden>Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const controller = application.getControllerForElementAndIdentifier(
        document.querySelector('[data-controller="popover"]'),
        'popover'
      );

      await controller.show();

      expect(global.fetch).not.toHaveBeenCalled();
    });
  });
});
