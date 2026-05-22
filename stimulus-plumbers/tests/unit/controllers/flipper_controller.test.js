import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import FlipperController from '../../../src/controllers/flipper_controller';

describe('FlipperController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('flipper', FlipperController);

    Object.defineProperty(window, 'scrollX', { value: 0, writable: true });
    Object.defineProperty(window, 'scrollY', { value: 0, writable: true });
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  describe('basic functionality', () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div data-controller="flipper">
          <button data-flipper-target="anchor">Anchor</button>
          <div data-flipper-target="reference">Popover</div>
        </div>
      `;

      const element = document.querySelector('[data-controller="flipper"]');
      element.getBoundingClientRect = vi.fn(() => ({
        top: 50, left: 50, bottom: 250, right: 250,
        width: 200, height: 200
      }));
    });

    it('positions reference element relative to anchor', () => {
      const reference = document.querySelector('[data-flipper-target="reference"]');
      const anchor = document.querySelector('[data-flipper-target="anchor"]');

      anchor.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 120, right: 200,
        width: 100, height: 20, x: 100, y: 100
      }));

      reference.getBoundingClientRect = vi.fn(() => ({
        top: 0, left: 0, bottom: 50, right: 150,
        width: 150, height: 50, x: 0, y: 0
      }));

      document.querySelector('button').click();

      expect(reference.style.position).toBe('absolute');
      expect(reference.style.top).toBeTruthy();
      expect(reference.style.left).toBeTruthy();
    });

    it('dispatches flip event before positioning', () => {
      const element = document.querySelector('[data-controller="flipper"]');
      const reference = document.querySelector('[data-flipper-target="reference"]');
      const anchor = document.querySelector('[data-flipper-target="anchor"]');
      const flipSpy = vi.fn();

      anchor.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 120, right: 200,
        width: 100, height: 20, x: 100, y: 100
      }));

      reference.getBoundingClientRect = vi.fn(() => ({
        top: 0, left: 0, bottom: 50, right: 150,
        width: 150, height: 50, x: 0, y: 0
      }));

      element.addEventListener('flipper:flip', flipSpy);
      document.querySelector('button').click();

      expect(flipSpy).toHaveBeenCalled();
    });

    it('dispatches flipped event after positioning', async () => {
      const element = document.querySelector('[data-controller="flipper"]');
      const reference = document.querySelector('[data-flipper-target="reference"]');
      const anchor = document.querySelector('[data-flipper-target="anchor"]');
      const flippedSpy = vi.fn();

      anchor.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 120, right: 200,
        width: 100, height: 20, x: 100, y: 100
      }));

      reference.getBoundingClientRect = vi.fn(() => ({
        top: 0, left: 0, bottom: 50, right: 150,
        width: 150, height: 50, x: 0, y: 0
      }));

      element.addEventListener('flipper:flipped', flippedSpy);
      document.querySelector('button').click();

      await new Promise(resolve => setTimeout(resolve, 10));
      expect(flippedSpy).toHaveBeenCalled();
    });
  });

  describe('viewport boundaries', () => {
    it('does not position when hidden', () => {
      document.body.innerHTML = `
        <div data-controller="flipper" hidden>
          <button data-flipper-target="anchor">Anchor</button>
          <div data-flipper-target="reference">Popover</div>
        </div>
      `;

      const reference = document.querySelector('[data-flipper-target="reference"]');
      const anchor = document.querySelector('[data-flipper-target="anchor"]');

      anchor.getBoundingClientRect = vi.fn(() => ({
        top: 100, left: 100, bottom: 120, right: 200,
        width: 100, height: 20, x: 100, y: 100
      }));

      reference.getBoundingClientRect = vi.fn(() => ({
        top: 0, left: 0, bottom: 50, right: 150,
        width: 150, height: 50, x: 0, y: 0
      }));

      document.querySelector('button').click();

      expect(reference.style.top).toBeFalsy();
    });
  });


  describe('event cleanup', () => {
    it('removes event listeners on disconnect', () => {
      document.body.innerHTML = `
        <div data-controller="flipper">
          <button data-flipper-target="anchor">Anchor</button>
          <div data-flipper-target="reference">Popover</div>
        </div>
      `;

      const element = document.querySelector('[data-controller="flipper"]');
      const flipSpy = vi.fn();
      element.addEventListener('flipper:flip', flipSpy);

      application.stop();

      document.querySelector('button').click();
      expect(flipSpy).not.toHaveBeenCalled();
    });
  });

  describe('accessibility enhancements', () => {
    it('sets role="tooltip" on the reference element by default', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper">
          <button data-flipper-target="anchor">Anchor</button>
          <div data-flipper-target="reference">Tooltip</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.querySelector('[data-flipper-target="reference"]').getAttribute('role')).toBe('tooltip');
    });

    it('sets the configured role on the reference element', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper" data-flipper-role-value="menu">
          <button data-flipper-target="anchor">Button</button>
          <div data-flipper-target="reference">Menu</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.querySelector('[data-flipper-target="reference"]').getAttribute('role')).toBe('menu');
    });

    it('sets aria-haspopup on the anchor based on role', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper" data-flipper-role-value="menu">
          <button data-flipper-target="anchor">Button</button>
          <div data-flipper-target="reference">Menu</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.querySelector('[data-flipper-target="anchor"]').getAttribute('aria-haspopup')).toBe('menu');
    });

    it('does not override an existing role on the reference element', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper" data-flipper-role-value="tooltip">
          <button data-flipper-target="anchor">Anchor</button>
          <div role="dialog" data-flipper-target="reference">Content</div>
        </div>
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      expect(document.querySelector('[data-flipper-target="reference"]').getAttribute('role')).toBe('dialog');
    });
  });

  describe('guardrails', () => {
    let consoleErrorSpy;

    beforeEach(() => {
      consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
    });

    afterEach(() => {
      consoleErrorSpy.mockRestore();
    });

    it('logs error when reference target is missing', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper">
          <button data-flipper-target="anchor">Anchor</button>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'FlipperController requires a reference target. Add data-flipper-target="reference" to your element.'
      );
    });

    it('logs error when anchor target is missing', async () => {
      document.body.innerHTML = `
        <div data-controller="flipper">
          <div data-flipper-target="reference">Content</div>
        </div>
      `;

      await new Promise(resolve => setTimeout(resolve, 10));

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'FlipperController requires an anchor target. Add data-flipper-target="anchor" to your element.'
      );
    });
  });

});
