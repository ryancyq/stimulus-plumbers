import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import PopoverController from '../../../src/controllers/popover_controller';
import { installNativePopover } from '../../support/native_popover';
import { flush, startApplication } from '../../support/stimulus';

describe('PopoverController', () => {
  let application;
  let consoleErrorSpy;

  const controllerFor = () => {
    const root = document.querySelector('[data-controller="popover"]');
    return application.getControllerForElementAndIdentifier(root, 'popover');
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
    if (panelElement) installNativePopover(panelElement);

    const root = document.querySelector('[data-controller="popover"]');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(root, 'popover'));
    return { controller: controllerFor(), panel: panelElement, trigger: document.querySelector('#trigger'), root };
  };

  beforeEach(() => {
    application = startApplication({ popover: PopoverController });
    consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
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
  });

  it('uses the action currentTarget as the native source and prevents default', async () => {
    const { controller, panel, trigger } = await render();
    const event = { currentTarget: trigger, preventDefault: vi.fn() };

    controller.onOpen(event);

    expect(event.preventDefault).toHaveBeenCalledOnce();
    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(panel.matches(':popover-open')).toBe(true);

    controller.onClose(event);
    expect(event.preventDefault).toHaveBeenCalledTimes(2);
    expect(panel.hidePopover).toHaveBeenCalledOnce();

    controller.onToggle(event);
    expect(event.preventDefault).toHaveBeenCalledTimes(3);
    expect(panel.showPopover).toHaveBeenLastCalledWith({ source: trigger });
  });

  it('uses a source passed to open and toggle', async () => {
    const { controller, panel } = await render();
    const source = document.createElement('input');
    document.body.append(source);

    controller.open(source);
    controller.close();
    controller.toggle(source);

    expect(panel.showPopover).toHaveBeenNthCalledWith(1, { source });
    expect(panel.showPopover).toHaveBeenNthCalledWith(2, { source });
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
    await vi.waitFor(() => expect(authored.trigger.getAttribute('aria-expanded')).toBe('true'));
    authored.controller.close();
    await vi.waitFor(() => expect(authored.trigger.getAttribute('aria-expanded')).toBe('false'));

    document.body.innerHTML = '';
    const absent = await render({ authoredExpanded: false });
    absent.controller.open();
    absent.controller.close();
    await Promise.resolve();
    expect(absent.trigger.hasAttribute('aria-expanded')).toBe(false);
  });

  it('observes external native open and close calls', async () => {
    const { panel, trigger } = await render();

    panel.showPopover();
    await vi.waitFor(() => expect(trigger.getAttribute('aria-expanded')).toBe('true'));
    panel.hidePopover();
    await vi.waitFor(() => expect(trigger.getAttribute('aria-expanded')).toBe('false'));
  });

  it('disposes the old adapter when the panel target is replaced', async () => {
    const { controller, panel: oldPanel } = await render();
    const oldOpened = vi.fn();
    oldPanel.addEventListener('popover:opened', oldOpened);
    const newPanel = document.createElement('div');
    newPanel.id = 'panel';
    newPanel.setAttribute('popover', 'auto');
    newPanel.dataset.popoverTarget = 'panel';
    installNativePopover(newPanel);
    oldPanel.replaceWith(newPanel);

    await flush();
    oldPanel.showPopover();
    await flush();
    expect(oldOpened).not.toHaveBeenCalled();

    controller.open();
    expect(newPanel.showPopover).toHaveBeenCalledOnce();
  });

  it('reconnects the same controller instance without duplicating cache behavior', async () => {
    const { controller, panel, root } = await render();

    root.remove();
    await vi.waitUntil(() => !controllerFor());
    document.body.appendChild(root);
    await vi.waitUntil(() => controllerFor() === controller);

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

  describe('onFocus', () => {
    const focus = (controller, trigger, relatedTarget = null) =>
      controller.onFocus({ currentTarget: trigger, relatedTarget, preventDefault: vi.fn() });

    it('opens from the trigger after user input', async () => {
      const { controller, panel, trigger } = await render();
      document.dispatchEvent(new KeyboardEvent('keydown', { key: 'Tab' }));

      focus(controller, trigger);

      expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    });

    it('stays closed for focus before any user input, such as autofocus', async () => {
      const { controller, panel, trigger } = await render();

      focus(controller, trigger);

      expect(panel.showPopover).not.toHaveBeenCalled();
    });

    it('stays closed when focus returns from the panel', async () => {
      const { controller, panel, trigger } = await render();
      document.dispatchEvent(new Event('pointerdown'));

      focus(controller, trigger, panel);

      expect(panel.showPopover).not.toHaveBeenCalled();
    });

    it('stays closed inside an open modal', async () => {
      const { controller, panel, root, trigger } = await render();
      const dialog = document.createElement('dialog');
      dialog.matches = (selector) => selector === ':modal';
      root.replaceWith(dialog);
      dialog.append(root);
      await vi.waitUntil(() => controllerFor());
      document.dispatchEvent(new Event('pointerdown'));

      focus(controllerFor(), trigger);

      expect(panel.showPopover).not.toHaveBeenCalled();
      expect(controller).toBeDefined();
    });
  });

  it('stops syncing the trigger and closing for the Turbo cache after disconnect', async () => {
    const { panel, root, trigger } = await render();

    root.remove();
    await vi.waitUntil(() => !controllerFor());
    panel.showPopover();
    await flush();
    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(trigger.getAttribute('aria-expanded')).toBe('false');
    expect(panel.hidePopover).not.toHaveBeenCalled();
  });
});
