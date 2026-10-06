import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import PopoverController from '../../../src/controllers/popover_controller';

describe('PopoverController', () => {
  let application;
  let consoleErrorSpy;

  const controllerFor = () => {
    const root = document.querySelector('[data-controller="popover"]');
    return application.getControllerForElementAndIdentifier(root, 'popover');
  };

  const nativeEvent = (type, newState, source = null, oldState = newState === 'open' ? 'closed' : 'open') => {
    const event = new Event(type, { cancelable: type === 'beforetoggle' });
    Object.defineProperty(event, 'oldState', { value: oldState });
    Object.defineProperty(event, 'newState', { value: newState });
    Object.defineProperty(event, 'source', { value: source });
    return event;
  };

  const installNativeMethods = (panel) => {
    let openState = false;
    panel.matches = vi.fn((selector) => selector === ':popover-open' && openState);
    panel.showPopover = vi.fn((options) => {
      const beforetoggle = nativeEvent('beforetoggle', 'open', options?.source ?? null);
      if (!panel.dispatchEvent(beforetoggle)) return;

      openState = true;
      panel.dispatchEvent(nativeEvent('toggle', 'open', options?.source ?? null));
    });
    panel.hidePopover = vi.fn(() => {
      if (!openState) return;

      panel.dispatchEvent(nativeEvent('beforetoggle', 'closed'));
      openState = false;
      panel.dispatchEvent(nativeEvent('toggle', 'closed'));
    });
    panel.togglePopover = vi.fn((options) => {
      if (openState) {
        panel.hidePopover();
        return;
      }

      panel.showPopover(options);
    });
  };

  const render = async ({ trigger = true, authoredExpanded = true, panel = true } = {}) => {
    const triggerMarkup = trigger
      ? '<button id="trigger" data-popover-target="trigger"' +
        (authoredExpanded ? ' aria-expanded="false"' : '') +
        '>Open</button>'
      : '';
    const panelMarkup = panel ? '<div id="panel" popover="auto" data-popover-target="panel">Content</div>' : '';
    document.body.innerHTML = '<div data-controller="popover">' + triggerMarkup + panelMarkup + '</div>';

    const panelElement = document.querySelector('#panel');
    if (panelElement) installNativeMethods(panelElement);

    const root = document.querySelector('[data-controller="popover"]');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'popover'));
    return { controller: controllerFor(), panel: panelElement, trigger: document.querySelector('#trigger'), root };
  };

  beforeEach(() => {
    application = Application.start();
    application.register('popover', PopoverController);
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    consoleErrorSpy.mockRestore();
  });

  it('declares only the trigger and panel targets and no values', () => {
    expect(PopoverController.targets).toEqual(['trigger', 'panel']);
    expect(PopoverController.values).toEqual({});
  });

  it('reports a missing panel once and leaves actions inert', async () => {
    document.body.innerHTML = '<div data-controller="popover"></div>';
    const root = document.querySelector('[data-controller="popover"]');
    await vi.waitFor(() => expect(consoleErrorSpy).toHaveBeenCalledOnce());

    const controller = application.getControllerForElementAndIdentifier(root, 'popover');
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'PopoverController requires a panel target. Add data-popover-target="panel" to your element.'
    );
    expect(() => controller.open()).not.toThrow();
    expect(() => controller.close()).not.toThrow();
    expect(() => controller.toggle()).not.toThrow();
  });

  it('reports a non-popover panel once and leaves actions inert', async () => {
    document.body.innerHTML = '<div data-controller="popover"><div data-popover-target="panel">Content</div></div>';
    await vi.waitFor(() => expect(consoleErrorSpy).toHaveBeenCalledOnce());

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'PopoverController requires data-popover-target="panel" to be a native popover element.'
    );
    expect(() => controllerFor().open()).not.toThrow();
  });

  it('requires every native popover method', async () => {
    const panel = document.createElement('div');
    panel.setAttribute('popover', 'auto');
    panel.showPopover = vi.fn();
    panel.hidePopover = vi.fn();
    document.body.innerHTML = '<div data-controller="popover"></div>';
    document.querySelector('[data-controller="popover"]').append(panel);
    panel.dataset.popoverTarget = 'panel';

    await vi.waitFor(() => expect(consoleErrorSpy).toHaveBeenCalledOnce());

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'PopoverController requires data-popover-target="panel" to be a native popover element.'
    );
    expect(controllerFor().open).toBeTypeOf('function');
  });

  it('uses action currentTarget as the native source and prevents default', async () => {
    const { controller, panel, trigger } = await render();
    const event = { currentTarget: trigger, preventDefault: vi.fn() };

    controller.open(event);

    expect(event.preventDefault).toHaveBeenCalledOnce();
    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(panel.matches(':popover-open')).toBe(true);

    controller.close(event);
    expect(event.preventDefault).toHaveBeenCalledTimes(2);
    expect(panel.hidePopover).toHaveBeenCalledOnce();

    controller.toggle(event);
    expect(event.preventDefault).toHaveBeenCalledTimes(3);
    expect(panel.showPopover).toHaveBeenLastCalledWith({ source: trigger });
  });

  it('uses the optional trigger target for programmatic open and toggle calls', async () => {
    const { controller, panel, trigger } = await render();

    controller.open();
    controller.close();
    controller.toggle();

    expect(panel.showPopover).toHaveBeenNthCalledWith(1, { source: trigger });
    expect(panel.showPopover).toHaveBeenNthCalledWith(2, { source: trigger });
    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('opens without a source when no trigger target is present', async () => {
    const { controller, panel } = await render({ trigger: false });

    controller.open();

    expect(panel.showPopover).toHaveBeenCalledWith();
  });

  it('synchronizes aria-expanded only when the trigger authored it', async () => {
    const authored = await render();
    authored.controller.open();
    expect(authored.trigger.getAttribute('aria-expanded')).toBe('true');
    authored.controller.close();
    expect(authored.trigger.getAttribute('aria-expanded')).toBe('false');

    document.body.innerHTML = '';
    const absent = await render({ authoredExpanded: false });
    absent.controller.open();
    absent.controller.close();
    expect(absent.trigger.hasAttribute('aria-expanded')).toBe(false);
  });

  it('observes external native open and close calls', async () => {
    const { panel, trigger } = await render();

    panel.showPopover();
    expect(trigger.getAttribute('aria-expanded')).toBe('true');
    panel.hidePopover();
    expect(trigger.getAttribute('aria-expanded')).toBe('false');
  });

  it('disposes the old adapter when the panel target is replaced', async () => {
    const { controller, panel: oldPanel, root } = await render();
    const oldRemove = vi.spyOn(oldPanel, 'removeEventListener');
    const newPanel = document.createElement('div');
    newPanel.id = 'panel';
    newPanel.setAttribute('popover', 'auto');
    newPanel.dataset.popoverTarget = 'panel';
    installNativeMethods(newPanel);
    oldPanel.replaceWith(newPanel);

    await vi.waitFor(() => expect(oldRemove).toHaveBeenCalledWith('beforetoggle', expect.any(Function)));
    expect(root.querySelector('#panel')).toBe(newPanel);
    expect(oldRemove).toHaveBeenCalledWith('beforetoggle', expect.any(Function));
    expect(oldRemove).toHaveBeenCalledWith('toggle', expect.any(Function));

    controller.open();
    expect(newPanel.showPopover).toHaveBeenCalledOnce();
  });

  it('reconnects the same controller instance without duplicating cache behavior', async () => {
    const { controller, panel, root } = await render();
    const removePanelListener = vi.spyOn(panel, 'removeEventListener');
    const removeDocumentListener = vi.spyOn(document, 'removeEventListener');
    const addDocumentListener = vi.spyOn(document, 'addEventListener');

    root.remove();
    await vi.waitFor(() => expect(removePanelListener).toHaveBeenCalledWith('beforetoggle', expect.any(Function)));
    expect(removeDocumentListener).toHaveBeenCalledWith('turbo:before-cache', expect.any(Function));
    document.body.appendChild(root);
    await vi.waitUntil(() => controllerFor() === controller);
    await vi.waitFor(() =>
      expect(addDocumentListener).toHaveBeenCalledWith('turbo:before-cache', expect.any(Function))
    );

    controller.open();
    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(panel.showPopover).toHaveBeenCalledOnce();
    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('closes an open panel synchronously before Turbo caches the page', async () => {
    const { controller, panel } = await render();
    controller.open();
    expect(panel.matches(':popover-open')).toBe(true);

    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(panel.matches(':popover-open')).toBe(false);
  });

  it('removes native, lifecycle, and cache listeners on disconnect', async () => {
    const { panel, root } = await render();
    const remove = vi.spyOn(panel, 'removeEventListener');
    const removeDocumentListener = vi.spyOn(document, 'removeEventListener');

    root.remove();
    await vi.waitFor(() => expect(remove).toHaveBeenCalledWith('beforetoggle', expect.any(Function)));

    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(remove).toHaveBeenCalledWith('beforetoggle', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('toggle', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('popover:opened', expect.any(Function));
    expect(remove).toHaveBeenCalledWith('popover:closed', expect.any(Function));
    expect(removeDocumentListener).toHaveBeenCalledWith('turbo:before-cache', expect.any(Function));
    expect(panel.hidePopover).not.toHaveBeenCalled();
  });
});
