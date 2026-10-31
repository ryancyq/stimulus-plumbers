import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import Temporal from '../../../../src/controllers/combobox/temporal';
import { installNativePopover } from '../../../support/native_popover';
import { flush, startApplication } from '../../../support/stimulus';

class TemporalController extends Temporal {
  _focusPanel() {
    this.panelTarget.querySelector('button').focus();
  }

  _snapshot() {
    return { value: this.inputTarget.value };
  }

  _restore({ value }) {
    this._commit(value);
  }
}

describe('Combobox Temporal', () => {
  const render = async () => {
    document.body.innerHTML = `
      <form id="form">
        <div id="root" data-controller="temporal" data-action="focusout->temporal#onFocusout mousedown->temporal#onMousedown click->temporal#onClick">
          <div id="group">
            <span id="icon" aria-hidden="true"></span>
            <input id="trigger" readonly value="a" data-temporal-target="trigger" data-action="keydown->temporal#onKeydown">
          </div>
          <input type="hidden" name="value" value="a" data-temporal-target="input">
          <div id="panel" popover="auto" data-temporal-target="panel">
            <button type="button" id="choice">b</button>
          </div>
        </div>
      </form>`;
    const root = document.querySelector('#root');
    const panel = document.querySelector('#panel');
    installNativePopover(panel);
    await flush();
    return {
      root,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('[type="hidden"]'),
      choice: document.querySelector('#choice'),
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
    const { panel, trigger, choice } = await render();
    trigger.focus();

    keydown(trigger, 'ArrowDown');

    expect(panel.showPopover).toHaveBeenCalledWith({ source: trigger });
    expect(document.activeElement).toBe(choice);
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
    const { panel, choice } = await render();
    panel.showPopover();

    choice.click();

    expect(panel.showPopover).toHaveBeenCalledOnce();
  });

  it('closes the panel when focus leaves the combobox', async () => {
    const { panel, choice } = await render();
    document.body.insertAdjacentHTML('beforeend', '<button id="next">Next</button>');
    panel.showPopover();
    choice.focus();

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
    const { panel, trigger, choice } = await render();
    panel.showPopover();
    trigger.focus();

    choice.focus();

    expect(panel.hidePopover).not.toHaveBeenCalled();
  });

  it('form reset restores the initial value and reports it without a change event', async () => {
    const { root, input } = await render();
    const changed = vi.fn();
    const reported = vi.fn();
    input.addEventListener('change', changed);
    root.addEventListener('temporal:changed', (event) => reported(event.detail.value));
    input.value = 'b';

    document.querySelector('#form').reset();
    await flush();

    expect(input.value).toBe('a');
    expect(reported).toHaveBeenCalledWith('a');
    expect(changed).not.toHaveBeenCalled();
  });
});
