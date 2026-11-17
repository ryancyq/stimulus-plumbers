import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Temporal from '../../../../src/controllers/combobox/temporal';
import { installNativePopover } from '../../../support/native_popover';
import { flush, startApplication } from '../../../support/stimulus';

class TemporalController extends Temporal {
  _focusPanel() {
    this.panelTarget.querySelector('button').focus();
  }
}

describe('Combobox Temporal', () => {
  const render = async () => {
    document.body.innerHTML = `
      <form id="form">
        <div id="container" data-controller="temporal" data-action="focusout->temporal#onFocusout mousedown->temporal#onMousedown click->temporal#onClick">
          <div id="group">
            <span id="icon" aria-hidden="true"></span>
            <input id="trigger" readonly value="a" data-temporal-target="trigger" data-action="keydown->temporal#onKeydown">
          </div>
          <input type="text" hidden readonly name="value" value="a" data-temporal-target="input"
                 data-action="form:reset->temporal#onFormReset">
          <div id="panel" popover="auto" data-temporal-target="panel">
            <button type="button" id="selection">b</button>
          </div>
        </div>
      </form>`;
    const container = document.querySelector('#container');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await flush();
    return {
      container,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('[data-temporal-target="input"]'),
      selection: document.querySelector('#selection'),
    };
  };

  const keydown = (element, key) =>
    element.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));

  beforeEach(() => {
    startApplication({ temporal: TemporalController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  it('ArrowDown opens the panel from the trigger and focuses the panel', async () => {
    const { panel, trigger, selection } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(document.activeElement).toBe(selection);
  });

  it('Tab closes an open panel', async () => {
    const { panel, trigger } = await render();
    panel.showPopover();

    keydown(trigger, 'Tab');

    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('a click on an icon opens the panel and focuses the trigger', async () => {
    const { panel, trigger } = await render();
    const icon = document.querySelector('#icon');
    const mousedown = new MouseEvent('mousedown', { bubbles: true, cancelable: true });

    icon.dispatchEvent(mousedown);
    icon.click();

    expect(mousedown.defaultPrevented).toBe(true);
    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(document.activeElement).toBe(trigger);
  });

  it('a click inside the panel leaves the panel to its content', async () => {
    const { panel, selection } = await render();
    panel.showPopover();

    selection.click();

    expect(panel.showPopover).toHaveBeenCalledOnce();
  });

  it('closes the panel when focus leaves the combobox', async () => {
    const { panel, selection } = await render();
    document.body.insertAdjacentHTML('beforeend', '<button id="next">Next</button>');
    panel.showPopover();
    selection.focus();

    document.querySelector('#next').focus();

    expect(panel.hidePopover).toHaveBeenCalledOnce();
  });

  it('keeps the panel open when focus moves to no element', async () => {
    const { panel, trigger } = await render();
    panel.showPopover();
    trigger.focus();

    trigger.blur();

    expect(panel.hidePopover).not.toHaveBeenCalled();
  });

  it('keeps the panel open while focus moves inside the combobox', async () => {
    const { panel, trigger, selection } = await render();
    panel.showPopover();
    trigger.focus();

    selection.focus();

    expect(panel.hidePopover).not.toHaveBeenCalled();
  });

  it('form reset closes the panel without events', async () => {
    const { container, panel, input } = await render();
    panel.showPopover();
    input.value = 'b';
    const changed = vi.fn();
    input.addEventListener('change', changed);
    container.addEventListener('temporal:changed', changed);

    document.querySelector('#form').reset();
    input.dispatchEvent(new CustomEvent('form:reset'));

    expect(input.value).toBe('a');
    expect(panel.hidePopover).toHaveBeenCalledOnce();
    expect(changed).not.toHaveBeenCalled();
  });
});
