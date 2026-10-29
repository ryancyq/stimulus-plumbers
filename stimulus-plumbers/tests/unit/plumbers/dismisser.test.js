import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Dismisser, attachDismisser } from '../../../src/plumbers/dismisser';
import { flush } from '../../support/stimulus';

describe('Dismisser', () => {
  let mockController;
  let element;

  beforeEach(() => {
    element = document.createElement('div');
    document.body.appendChild(element);

    mockController = {
      identifier: 'dismisser',
      element: element,
      dispatch: vi.fn(() => true),
    };

    // Mock getBoundingClientRect for visibility checks
    element.getBoundingClientRect = () => ({
      top: 100,
      left: 100,
      width: 200,
      height: 200,
    });
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  describe('callbacks', () => {
    const clickOutside = () => {
      const outside = document.createElement('div');
      document.body.appendChild(outside);
      outside.click();
    };

    it('calls the controller dismissed method with the element as its target', () => {
      mockController.dismissed = vi.fn();
      new Dismisser(mockController);

      clickOutside();

      expect(mockController.dismissed).toHaveBeenCalledWith({ target: element });
    });

    it('calls the onDismissed method it is given with the trigger as its target', () => {
      const trigger = document.createElement('button');
      mockController.customDismissed = vi.fn();
      new Dismisser(mockController, { trigger, onDismissed: 'customDismissed' });

      clickOutside();

      expect(mockController.customDismissed).toHaveBeenCalledWith({ target: trigger });
    });
  });

  describe('dismiss', () => {
    it('does nothing when target is not an Element', async () => {
      const dismisser = new Dismisser(mockController);
      const event = { target: null };

      await dismisser.dismiss(event);

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('dispatches dismiss for a click on an SVG element outside', async () => {
      document.body.insertAdjacentHTML('beforeend', '<svg id="icon"><path></path></svg>');
      const dismisser = new Dismisser(mockController);

      await dismisser.dismiss({ target: document.querySelector('#icon path') });

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object));
    });

    it('does nothing when target is inside element', async () => {
      const child = document.createElement('span');
      element.appendChild(child);
      const dismisser = new Dismisser(mockController);
      const event = { target: child };

      await dismisser.dismiss(event);

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('does nothing when element is not visible', async () => {
      element.setAttribute('hidden', true);
      const dismisser = new Dismisser(mockController);
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);
      const event = { target: outsideElement };

      await dismisser.dismiss(event);

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });

    it('dispatches dismiss and dismissed events when clicked outside', async () => {
      const dismisser = new Dismisser(mockController);
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);
      const event = { target: outsideElement };

      await dismisser.dismiss(event);

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object));
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object));
    });

    it('calls onDismissed callback', async () => {
      const onDismissed = vi.fn();
      mockController.dismissed = onDismissed;
      const dismisser = new Dismisser(mockController, { onDismissed: 'dismissed' });
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);
      const event = { target: outsideElement };

      await dismisser.dismiss(event);

      expect(onDismissed).toHaveBeenCalledWith({ target: element });
    });

    it('awaits async onDismissed callback', async () => {
      const onDismissed = vi.fn(() => flush());
      mockController.dismissed = onDismissed;
      const dismisser = new Dismisser(mockController, { onDismissed: 'dismissed' });
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);
      const event = { target: outsideElement };

      await dismisser.dismiss(event);

      expect(onDismissed).toHaveBeenCalled();
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object));
    });
  });

  describe('observe', () => {
    it('dismisses on every configured event', () => {
      new Dismisser(mockController, { events: ['click', 'mousedown'] });
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);

      outsideElement.dispatchEvent(new MouseEvent('click', { bubbles: true }));
      outsideElement.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));

      expect(mockController.dispatch.mock.calls.filter(([name]) => name === 'dismiss')).toHaveLength(2);
    });
  });

  describe('disconnect', () => {
    it('stops dismissing on outside clicks', () => {
      const dismisser = new Dismisser(mockController);
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);

      dismisser.disconnect();
      outsideElement.click();

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });

  describe('attachDismisser', () => {
    it('creates and returns a Dismisser instance', () => {
      const dismisser = attachDismisser(mockController, { events: ['mousedown'] });

      expect(dismisser).toBeInstanceOf(Dismisser);
      expect(dismisser.events).toEqual(['mousedown']);
    });
  });

  describe('integration', () => {
    it('dismisses when clicking outside element', async () => {
      const dismisser = new Dismisser(mockController);
      const outsideElement = document.createElement('div');
      document.body.appendChild(outsideElement);

      // Simulate click event
      const clickEvent = new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      });
      Object.defineProperty(clickEvent, 'target', {
        value: outsideElement,
        enumerable: true,
      });

      await dismisser.dismiss(clickEvent);

      expect(mockController.dispatch).toHaveBeenCalledWith('dismiss', expect.any(Object));
      expect(mockController.dispatch).toHaveBeenCalledWith('dismissed', expect.any(Object));
    });

    it('does not dismiss when clicking inside element', async () => {
      const dismisser = new Dismisser(mockController);
      const insideElement = document.createElement('span');
      element.appendChild(insideElement);

      const clickEvent = new MouseEvent('click', {
        bubbles: true,
        cancelable: true,
      });
      Object.defineProperty(clickEvent, 'target', {
        value: insideElement,
        enumerable: true,
      });

      await dismisser.dismiss(clickEvent);

      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });
});
