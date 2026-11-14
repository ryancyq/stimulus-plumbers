import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import ClipboardController from '../../../src/controllers/clipboard_controller';
import { flush, startApplication } from '../../support/stimulus';

function makePasteEvent(data = {}) {
  const event = new Event('paste', { bubbles: true, cancelable: true });
  Object.defineProperty(event, 'clipboardData', {
    value: {
      getData: (type) => data[type] ?? '',
      types: Object.keys(data),
    },
  });
  return event;
}

describe('ClipboardController', () => {
  let application;

  beforeEach(async () => {
    application = startApplication({ clipboard: ClipboardController });

    document.body.innerHTML = `
      <div data-controller="clipboard"
           data-action="paste->clipboard#onPaste">
      </div>
    `;
    await flush();
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('default behaviour (text/plain)', () => {
    it('dispatches clipboard:pasted with text on paste', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'hello world' }));

      await flush();
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.text).toBe('hello world');
    });

    it('includes types array in payload', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'hello', 'text/html': '<b>hello</b>' }));

      await flush();
      expect(spy.mock.calls[0][0].detail.types).toEqual(expect.arrayContaining(['text/plain', 'text/html']));
    });

    it('lets the native paste through when no listener cancels clipboard:pasted', () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const event = makePasteEvent({ 'text/plain': 'test' });

      element.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    });

    it('cancels the native paste when a listener cancels clipboard:pasted', () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      element.addEventListener('clipboard:pasted', (pasted) => pasted.preventDefault());
      const event = makePasteEvent({ 'text/plain': 'test' });

      element.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
    });

    it('dispatches empty text and empty types when clipboardData is null', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      const event = new Event('paste', { bubbles: true, cancelable: true });
      Object.defineProperty(event, 'clipboardData', { value: null });
      element.dispatchEvent(event);

      await flush();
      expect(spy.mock.calls[0][0].detail.text).toBe('');
      expect(spy.mock.calls[0][0].detail.types).toEqual([]);
    });

    it('dispatches event that bubbles up to parent', async () => {
      const parent = document.createElement('div');
      const element = document.querySelector('[data-controller="clipboard"]');
      parent.appendChild(element);
      document.body.appendChild(parent);

      const spy = vi.fn();
      parent.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'bubbled text' }));

      await flush();
      expect(spy).toHaveBeenCalledTimes(1);
    });
  });

  describe('configured type value', () => {
    beforeEach(async () => {
      application.stop();
      document.body.innerHTML = '';

      application = startApplication({ clipboard: ClipboardController });

      document.body.innerHTML = `
        <div data-controller="clipboard"
             data-clipboard-content-type-value="text/html"
             data-action="paste->clipboard#onPaste">
        </div>
      `;
      await flush();
    });

    it('extracts the configured MIME type from clipboardData', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(
        makePasteEvent({
          'text/plain': 'plain text',
          'text/html': '<b>bold</b>',
        })
      );

      await flush();
      expect(spy.mock.calls[0][0].detail.text).toBe('<b>bold</b>');
    });

    it('still includes all available types in payload', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(
        makePasteEvent({
          'text/plain': 'plain text',
          'text/html': '<b>bold</b>',
        })
      );

      await flush();
      expect(spy.mock.calls[0][0].detail.types).toEqual(expect.arrayContaining(['text/plain', 'text/html']));
    });

    it('returns empty text when configured type is not in clipboard', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:pasted', spy);

      element.dispatchEvent(makePasteEvent({ 'text/plain': 'only plain' }));

      await flush();
      expect(spy.mock.calls[0][0].detail.text).toBe('');
    });
  });

  describe('copy to clipboard', () => {
    beforeEach(async () => {
      application.stop();
      document.body.innerHTML = '';

      application = startApplication({ clipboard: ClipboardController });

      document.body.innerHTML = `
        <div data-controller="clipboard">
          <input value="copy this text" data-clipboard-target="source">
        </div>
      `;
      await flush();
    });

    it('writes source value to clipboard and dispatches clipboard:copied', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:copied', spy);

      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy();

      expect(writeTextSpy).toHaveBeenCalledWith('copy this text');
      await flush();
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.text).toBe('copy this text');
    });

    it('copies the source value when called from code', async () => {
      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy();

      expect(writeTextSpy).toHaveBeenCalledWith('copy this text');
    });

    it('dispatches clipboard:copy-failed when write fails', async () => {
      const element = document.querySelector('[data-controller="clipboard"]');
      const spy = vi.fn();
      element.addEventListener('clipboard:copy-failed', spy);

      const error = new Error('Not allowed');
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: vi.fn().mockRejectedValue(error) },
        configurable: true,
      });

      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy();

      await flush();
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail.error).toBe(error);
    });

    it('copies the text param of the onCopy action', async () => {
      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      element.insertAdjacentHTML(
        'beforeend',
        '<button data-action="clipboard#onCopy" data-clipboard-text-param="from params">Copy</button>'
      );
      await flush();
      element.querySelector('button').click();
      await flush();

      expect(writeTextSpy).toHaveBeenCalledWith('from params');
    });

    it('copies the source value from an onCopy action without a text param', async () => {
      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      element.insertAdjacentHTML('beforeend', '<button data-action="clipboard#onCopy">Copy</button>');
      await flush();
      element.querySelector('button').click();
      await flush();

      expect(writeTextSpy).toHaveBeenCalledWith('copy this text');
    });

    it('copies the given text when called from code', async () => {
      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy('explicit text');

      expect(writeTextSpy).toHaveBeenCalledWith('explicit text');
    });

    it('uses textContent when source has no value (e.g. a span)', async () => {
      application.stop();
      document.body.innerHTML = '';
      application = startApplication({ clipboard: ClipboardController });

      document.body.innerHTML = `
        <div data-controller="clipboard">
          <span data-clipboard-target="source">span text</span>
        </div>
      `;
      await flush();

      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy();

      expect(writeTextSpy).toHaveBeenCalledWith('span text');
    });

    it('reports copy-failed instead of clearing the clipboard when there is nothing to copy', async () => {
      application.stop();
      document.body.innerHTML = '';
      application = startApplication({ clipboard: ClipboardController });

      document.body.innerHTML = `<div data-controller="clipboard"></div>`;
      await flush();

      const writeTextSpy = vi.fn().mockResolvedValue(undefined);
      Object.defineProperty(navigator, 'clipboard', {
        value: { writeText: writeTextSpy },
        configurable: true,
      });

      const element = document.querySelector('[data-controller="clipboard"]');
      const failedSpy = vi.fn();
      element.addEventListener('clipboard:copy-failed', failedSpy);
      const controller = application.getControllerForElementAndIdentifier(element, 'clipboard');
      await controller.copy();

      expect(writeTextSpy).not.toHaveBeenCalled();
      expect(failedSpy).toHaveBeenCalledTimes(1);
    });
  });
});
