import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { visibilityConfig } from '../../../src/plumbers/plumber/config';
import PopoverController from '../../../src/controllers/popover_controller';

describe('PopoverController', () => {
  let application;
  let visibleOnlySpy;

  const controllerFor = () =>
    application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="popover"]'), 'popover');

  beforeEach(() => {
    visibleOnlySpy = vi.spyOn(visibilityConfig, 'visibleOnly', 'get').mockReturnValue(false);
    visibilityConfig.hiddenClass = '';

    application = Application.start();
    application.register('popover', PopoverController);

    global.fetch = vi.fn(async () => ({
      ok: true,
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
          <div data-popover-target="panel" hidden>Content</div>
          <div data-popover-target="loader" hidden>Loading...</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('attaches load and visibility to controller', () => {
      const controller = controllerFor();

      expect(typeof controller.load).toBe('function');
      expect(controller.visibility).toBeDefined();
    });

    it('attaches contentLoaderVisibility when loader target is present', () => {
      expect(controllerFor().contentLoaderVisibility).toBeDefined();
    });
  });

  describe('trigger aria-expanded', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    const button = () => document.querySelector('[data-popover-target="trigger"]');

    it('sets aria-expanded="false" on connect when panel is hidden', () => {
      expect(button().getAttribute('aria-expanded')).toBe('false');
    });

    it('sets aria-expanded="true" after open', async () => {
      await controllerFor().open();

      expect(button().getAttribute('aria-expanded')).toBe('true');
    });

    it('sets aria-expanded="false" after close', async () => {
      const controller = controllerFor();
      await controller.open();
      await controller.close();

      expect(button().getAttribute('aria-expanded')).toBe('false');
    });
  });

  describe('open, close, toggle', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    const panel = () => document.querySelector('[data-popover-target="panel"]');

    it('open makes panel visible', async () => {
      await controllerFor().open();
      expect(panel().hidden).toBe(false);
    });

    it('close makes panel hidden', async () => {
      const controller = controllerFor();
      await controller.open();
      await controller.close();
      expect(panel().hidden).toBe(true);
    });

    it('toggle alternates visibility', async () => {
      const controller = controllerFor();
      await controller.toggle();
      expect(panel().hidden).toBe(false);
      await controller.toggle();
      expect(panel().hidden).toBe(true);
    });
  });

  describe('closeOnSelect', () => {
    const panel = () => document.querySelector('[data-popover-target="panel"]');

    it('closes the panel when closeOnSelect value is true (default)', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      const controller = controllerFor();
      await controller.open();
      await controller.closeOnSelect();

      expect(panel().hidden).toBe(true);
    });

    it('keeps the panel open when closeOnSelect value is false', async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-close-on-select-value="false">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      const controller = controllerFor();
      await controller.open();
      await controller.closeOnSelect();

      expect(panel().hidden).toBe(false);
    });
  });

  describe('focus management', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden><button id="first">First</button></div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('moves focus into the panel on shown', async () => {
      // jsdom reports zero dimensions for all elements; override so isVisible() is true.
      document.getElementById('first').getClientRects = () => [{}];
      await controllerFor().open();
      expect(document.activeElement).toBe(document.getElementById('first'));
    });

    it('returns focus to the trigger on hidden', async () => {
      const controller = controllerFor();
      await controller.open();
      await controller.close();
      expect(document.activeElement).toBe(document.querySelector('[data-popover-target="trigger"]'));
    });
  });

  describe('outside-click dismissal', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <button data-popover-target="trigger">Open</button>
          <div data-popover-target="panel" hidden>Content</div>
        </div>
        <button id="outside">Outside</button>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('closes the panel on outside click', async () => {
      const controller = controllerFor();
      await controller.open();

      document.getElementById('outside').click();
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(document.querySelector('[data-popover-target="panel"]').hidden).toBe(true);
    });

    it('keeps the panel open when clicking inside', async () => {
      const controller = controllerFor();
      await controller.open();

      document.querySelector('[data-popover-target="panel"]').click();
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(document.querySelector('[data-popover-target="panel"]').hidden).toBe(false);
    });
  });

  describe('loading content on show', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('fetches content after panel becomes visible', async () => {
      await controllerFor().open();

      expect(global.fetch).toHaveBeenCalledWith('/content', expect.objectContaining({ signal: expect.any(AbortSignal) }));
    });

    it('does not re-fetch when reload is "never"', async () => {
      const controller = controllerFor();

      await controller.open();
      global.fetch.mockClear();
      await controller.load();

      expect(global.fetch).not.toHaveBeenCalled();
    });
  });

  describe('canLoad', () => {
    it('returns true for regular panel target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(controllerFor().canLoad()).toBe(true);
    });

    it('sets turbo-frame src and returns false', async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <turbo-frame data-popover-target="panel" hidden>Content</turbo-frame>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      const controller = controllerFor();
      const result = controller.canLoad();

      expect(controller.panelTarget.getAttribute('src')).toBe('/content');
      expect(result).toBe(false);
    });
  });

  describe('contentLoading and contentLoaded', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="panel" hidden>Content</div>
          <div data-popover-target="loader" hidden>Loading...</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('contentLoading shows loader target', async () => {
      const loader = document.querySelector('[data-popover-target="loader"]');
      await controllerFor().contentLoading();

      expect(loader.hidden).toBe(false);
    });

    it('contentLoaded inserts content into panel target', async () => {
      const panel = document.querySelector('[data-popover-target="panel"]');
      const template = document.createElement('template');
      template.innerHTML = '<p>New content</p>';
      await controllerFor().contentLoaded({ content: template.content });

      expect(panel.querySelector('p').textContent).toBe('New content');
    });

    it('contentLoaded hides loader after content insertion', async () => {
      const loader = document.querySelector('[data-popover-target="loader"]');
      const controller = controllerFor();
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
          <div data-popover-target="panel" hidden></div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(controllerFor().contentLoader()).toBeInstanceOf(DocumentFragment);
    });

    it('returns innerHTML for non-template target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="template"><p>Static</p></div>
          <div data-popover-target="panel" hidden></div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(controllerFor().contentLoader()).toContain('<p>Static</p>');
    });

    it('returns undefined when no template target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="panel" hidden></div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(controllerFor().contentLoader()).toBeUndefined();
    });
  });

  describe('load lifecycle events', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="popover" data-popover-url-value="/content">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('dispatches load, loading, and loaded events', async () => {
      const element = document.querySelector('[data-controller="popover"]');
      const loadSpy = vi.fn();
      const loadingSpy = vi.fn();
      const loadedSpy = vi.fn();

      element.addEventListener('popover:load', loadSpy);
      element.addEventListener('popover:loading', loadingSpy);
      element.addEventListener('popover:loaded', loadedSpy);

      await controllerFor().open();

      expect(loadSpy).toHaveBeenCalledTimes(1);
      expect(loadingSpy).toHaveBeenCalledTimes(1);
      expect(loadedSpy).toHaveBeenCalledTimes(1);
    });
  });

  describe('without targets', () => {
    it('connects without panel target', async () => {
      document.body.innerHTML = '<div data-controller="popover"></div>';
      await new Promise((resolve) => setTimeout(resolve, 10));

      const controller = controllerFor();

      expect(controller.load).toBeDefined();
      expect(controller.visibility).toBeUndefined();
    });

    it('does not attach contentLoaderVisibility without loader target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(controllerFor().contentLoaderVisibility).toBeUndefined();
    });

    it('contentLoading does nothing without loader target', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      await expect(controllerFor().contentLoading()).resolves.toBeUndefined();
    });

    it('skips fetch when no url value', async () => {
      document.body.innerHTML = `
        <div data-controller="popover">
          <div data-popover-target="panel" hidden>Content</div>
        </div>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));

      await controllerFor().open();

      expect(global.fetch).not.toHaveBeenCalled();
    });
  });
});
