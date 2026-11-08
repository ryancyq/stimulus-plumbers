import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ComboboxController from '../../../src/controllers/combobox_controller';
import { installNativePopover } from '../../support/native_popover';

describe('ComboboxController', () => {
  let application;

  const options = `
    <li id="opt-sg" role="option" data-value="sg">Singapore</li>
    <li id="opt-sy" role="option" data-value="sy" aria-disabled="true">Sydney</li>
    <li id="opt-se" role="option" data-value="se">Seoul</li>
    <li id="opt-sf" role="option" data-value="sf" hidden>San Francisco</li>
    <li id="opt-st" role="option" data-value="st">Stockholm</li>`;

  const render = async ({
    mode = 'select_only',
    value = '',
    label = '',
    attrs = '',
    items = options,
    status = mode === 'editable',
  } = {}) => {
    const trigger =
      mode === 'editable'
        ? `<input id="trigger" role="combobox" aria-expanded="false" value="${label}"
             data-combobox-target="trigger" data-action="input->combobox#onInput keydown->combobox#onKeydown" />`
        : `<button id="trigger" type="button" role="combobox" aria-expanded="false"
             data-combobox-target="trigger" data-action="keydown->combobox#onKeydown">${label}</button>`;
    document.body.innerHTML = `
      <form id="form">
        <div id="container" data-controller="combobox" data-combobox-mode-value="${mode}" ${attrs}
             data-action="mousedown->combobox#onMousedown click->combobox#onClick">
          ${trigger}
          <svg id="icon" aria-hidden="true"></svg>
          <button id="other" type="button">Other</button>
          <input type="hidden" name="city" value="${value}" data-combobox-target="input" />
          <div id="panel" popover="manual" data-combobox-target="panel">
            <ul id="listbox" role="listbox" data-combobox-target="listbox">
              ${items}
            </ul>
            ${status ? '<div id="status" role="status" data-combobox-target="status"></div>' : ''}
          </div>
        </div>
      </form>
      <button id="outside">Outside</button>`;
    const panel = document.querySelector('#panel');
    installNativePopover(panel);

    const container = document.querySelector('#container');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'combobox'));
    return {
      container,
      panel,
      trigger: document.querySelector('#trigger'),
      input: document.querySelector('input[type="hidden"]'),
      option: (id) => document.querySelector(`#opt-${id}`),
    };
  };

  const key = (target, keyName, init = {}) => {
    const event = new KeyboardEvent('keydown', { key: keyName, bubbles: true, cancelable: true, ...init });
    target.dispatchEvent(event);
    return event;
  };

  const isOpen = (panel) => panel.matches(':popover-open');
  const settle = () => new Promise((resolve) => setTimeout(resolve));
  const active = (trigger) => trigger.getAttribute('aria-activedescendant');
  const selected = () => [...document.querySelectorAll('[aria-selected="true"]')].map((option) => option.id);

  beforeEach(() => {
    application = Application.start();
    application.register('combobox', ComboboxController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  it('reports a panel that is not a native popover', async () => {
    const error = vi.spyOn(console, 'error').mockImplementation(() => {});
    document.body.innerHTML = `
      <div id="container" data-controller="combobox">
        <button type="button" role="combobox" data-combobox-target="trigger"></button>
        <input type="hidden" data-combobox-target="input" />
        <div data-combobox-target="panel"></div>
      </div>`;
    const container = document.querySelector('#container');
    await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'combobox'));

    expect(error).toHaveBeenCalledWith(expect.stringContaining('native popover'));
    error.mockRestore();
  });

  it('declares its targets and values', () => {
    expect(ComboboxController.targets).toEqual(['trigger', 'input', 'panel', 'listbox', 'status']);
    expect(Object.keys(ComboboxController.values)).toEqual([
      'mode',
      'valuePolicy',
      'closeOnSelect',
      'match',
      'minLength',
      'emptyText',
    ]);
  });

  describe('opening', () => {
    it('opens with Arrow Down on the first enabled visible option', async () => {
      const { trigger, panel } = await render();

      expect(key(trigger, 'ArrowDown').defaultPrevented).toBe(true);
      expect(isOpen(panel)).toBe(true);
      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(active(trigger)).toBe('opt-sg');
      expect(selected()).toEqual(['opt-sg']);
    });

    it('opens with Arrow Up on the last enabled visible option', async () => {
      const { trigger } = await render();

      key(trigger, 'ArrowUp');

      expect(active(trigger)).toBe('opt-st');
    });

    it('opens on the selected option', async () => {
      const { trigger } = await render({ value: 'se', label: 'Seoul' });

      key(trigger, 'ArrowDown');

      expect(active(trigger)).toBe('opt-se');
    });

    it('opens by pointer with no active option unless one is selected', async () => {
      const { trigger, panel } = await render();

      trigger.click();

      expect(isOpen(panel)).toBe(true);
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });

    it('reconciles an external open', async () => {
      const { trigger, panel } = await render();

      panel.showPopover();
      await settle();

      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });

    it('opens with Home or End on the first or last option in select-only mode', async () => {
      const { trigger, panel } = await render();

      key(trigger, 'End');

      expect(isOpen(panel)).toBe(true);
      expect(active(trigger)).toBe('opt-st');
    });

    it('opens from a click elsewhere in the field, such as an icon', async () => {
      const { trigger, panel } = await render();

      document.querySelector('#icon').dispatchEvent(new MouseEvent('click', { bubbles: true }));

      expect(isOpen(panel)).toBe(true);
      expect(document.activeElement).toBe(trigger);
    });

    it('ignores clicks on other buttons inside the field', async () => {
      const { panel } = await render();

      document.querySelector('#other').click();

      expect(isOpen(panel)).toBe(false);
    });

    it('focuses a clicked select-only trigger', async () => {
      const { trigger } = await render();

      trigger.click();

      expect(document.activeElement).toBe(trigger);
    });

    it('does not open when before-open is cancelled', async () => {
      const { container, trigger, panel } = await render();
      container.addEventListener('combobox:before-open', (event) => event.preventDefault());

      key(trigger, 'ArrowDown');
      key(trigger, 'End');

      expect(isOpen(panel)).toBe(false);
      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });
  });

  describe('navigation', () => {
    it('skips disabled and hidden options and stops at the ends', async () => {
      const { trigger } = await render();
      key(trigger, 'ArrowDown');

      key(trigger, 'ArrowDown');
      expect(active(trigger)).toBe('opt-se');
      key(trigger, 'ArrowDown');
      expect(active(trigger)).toBe('opt-st');
      key(trigger, 'ArrowDown');
      expect(active(trigger)).toBe('opt-st');
      key(trigger, 'ArrowUp');
      expect(active(trigger)).toBe('opt-se');
    });

    it('moves from no active option to the last with Arrow Up', async () => {
      const { trigger } = await render();
      trigger.click();

      key(trigger, 'ArrowUp');

      expect(active(trigger)).toBe('opt-st');
    });

    it('does not open an empty listbox', async () => {
      const { trigger, panel } = await render();
      document.querySelector('#listbox').replaceChildren();

      key(trigger, 'ArrowDown');
      trigger.click();

      expect(isOpen(panel)).toBe(false);
      expect(trigger.getAttribute('aria-expanded')).toBe('false');
    });

    it('moves to the first and last option with Home and End in select-only mode', async () => {
      const { trigger } = await render();
      key(trigger, 'ArrowDown');

      expect(key(trigger, 'End').defaultPrevented).toBe(true);
      expect(active(trigger)).toBe('opt-st');
      key(trigger, 'Home');
      expect(active(trigger)).toBe('opt-sg');
    });

    it('leaves Home, End, and Space to text editing in editable mode', async () => {
      const { trigger } = await render({ mode: 'editable' });
      key(trigger, 'ArrowDown');

      expect(key(trigger, 'Home').defaultPrevented).toBe(false);
      expect(key(trigger, 'End').defaultPrevented).toBe(false);
      expect(key(trigger, ' ').defaultPrevented).toBe(false);
      expect(active(trigger)).toBe('opt-sg');
    });

    it('ignores modified keys', async () => {
      const { trigger, panel } = await render();

      expect(key(trigger, 'ArrowDown', { metaKey: true }).defaultPrevented).toBe(false);
      expect(isOpen(panel)).toBe(false);
    });
  });

  describe('select', () => {
    it('selects the active option with Enter and closes', async () => {
      const { container, trigger, input, panel } = await render();
      const changed = vi.fn();
      container.addEventListener('combobox:changed', changed);
      key(trigger, 'ArrowDown');
      key(trigger, 'ArrowDown');

      expect(key(trigger, 'Enter').defaultPrevented).toBe(true);
      expect(input.value).toBe('se');
      expect(trigger.textContent).toBe('Seoul');
      expect(isOpen(panel)).toBe(false);
      expect(changed.mock.calls[0][0].detail).toMatchObject({ value: 'se', label: 'Seoul' });
      expect(selected()).toEqual(['opt-se']);
    });

    it('selects with Space in select-only mode', async () => {
      const { trigger, input } = await render();
      key(trigger, 'ArrowDown');

      expect(key(trigger, ' ').defaultPrevented).toBe(true);
      expect(input.value).toBe('sg');
    });

    it('leaves Enter alone when closed or while composing', async () => {
      const { trigger, input } = await render();

      expect(key(trigger, 'Enter').defaultPrevented).toBe(false);
      key(trigger, 'ArrowDown');
      expect(key(trigger, 'Enter', { isComposing: true }).defaultPrevented).toBe(false);
      expect(input.value).toBe('');
    });

    it('selects a clicked option and keeps focus on the trigger', async () => {
      const { trigger, input, option } = await render();
      trigger.focus();
      trigger.click();

      const mousedown = new MouseEvent('mousedown', { bubbles: true, cancelable: true });
      option('st').dispatchEvent(mousedown);
      option('st').click();

      expect(mousedown.defaultPrevented).toBe(true);
      expect(input.value).toBe('st');
      expect(document.activeElement).toBe(trigger);
    });

    it('does not select a disabled option', async () => {
      const { trigger, input, option } = await render();
      trigger.click();

      option('sy').click();

      expect(input.value).toBe('');
    });

    it('lets before-change cancel the select', async () => {
      const { container, trigger, input } = await render();
      container.addEventListener('combobox:before-change', (event) => event.preventDefault());
      key(trigger, 'ArrowDown');

      key(trigger, 'Enter');

      expect(input.value).toBe('');
    });

    it('stays open after a selection when closeOnSelect is false', async () => {
      const { trigger, panel } = await render({ attrs: 'data-combobox-close-on-select-value="false"' });
      key(trigger, 'ArrowDown');

      key(trigger, 'Enter');

      expect(isOpen(panel)).toBe(true);
      expect(active(trigger)).toBe('opt-sg');
    });

    it('selects the active option on Tab without preventing focus movement', async () => {
      const { trigger, input, panel } = await render();
      key(trigger, 'ArrowDown');

      expect(key(trigger, 'Tab').defaultPrevented).toBe(false);
      expect(input.value).toBe('sg');
      expect(isOpen(panel)).toBe(false);
    });

    it('does not re-select the selected option on Tab', async () => {
      const { container, trigger } = await render({ value: 'sg', label: 'Singapore' });
      const changed = vi.fn();
      container.addEventListener('combobox:changed', changed);
      trigger.click();

      key(trigger, 'Tab');

      expect(changed).not.toHaveBeenCalled();
    });

    it('selects programmatically while closed without an active option', async () => {
      const { trigger, input, option, container } = await render();
      const controller = application.getControllerForElementAndIdentifier(container, 'combobox');

      expect(controller.select(option('se'))).toBe(true);
      expect(controller.select(option('sy'))).toBe(false);
      expect(input.value).toBe('se');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
      expect(selected()).toEqual(['opt-se']);
    });

    it('closes on Tab without selecting when no option is active', async () => {
      const { trigger, input, panel } = await render();
      trigger.click();

      key(trigger, 'Tab');

      expect(input.value).toBe('');
      expect(isOpen(panel)).toBe(false);
    });
  });

  describe('closing', () => {
    it('closes on Escape and restores the selection', async () => {
      const { trigger, input, panel } = await render({ value: 'sg', label: 'Singapore' });
      key(trigger, 'ArrowDown');
      key(trigger, 'ArrowDown');

      expect(key(trigger, 'Escape').defaultPrevented).toBe(true);
      expect(isOpen(panel)).toBe(false);
      expect(input.value).toBe('sg');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
      expect(selected()).toEqual(['opt-sg']);
    });

    it('leaves Escape alone while closed or composing', async () => {
      const { trigger, panel } = await render();

      expect(key(trigger, 'Escape').defaultPrevented).toBe(false);
      key(trigger, 'ArrowDown');
      expect(key(trigger, 'Escape', { isComposing: true }).defaultPrevented).toBe(false);
      expect(isOpen(panel)).toBe(true);
    });

    it('toggles a select-only trigger on click', async () => {
      const { trigger, panel } = await render();

      trigger.click();
      trigger.click();

      expect(isOpen(panel)).toBe(false);
    });

    it('keeps an editable trigger open on further clicks', async () => {
      const { trigger, panel } = await render({ mode: 'editable' });

      trigger.click();
      trigger.click();

      expect(isOpen(panel)).toBe(true);
    });

    it('closes on a click or focus outside', async () => {
      const { trigger, panel } = await render();
      const outside = document.querySelector('#outside');

      trigger.click();
      outside.click();
      expect(isOpen(panel)).toBe(false);

      trigger.click();
      outside.focus();
      expect(isOpen(panel)).toBe(false);
    });

    it('closes when focus moves into an iframe', async () => {
      const { trigger, panel } = await render();
      const frame = document.createElement('iframe');
      document.body.append(frame);

      trigger.click();
      // Browsers move focus into a frame without a focusin on this document.
      const focused = vi.spyOn(document, 'activeElement', 'get').mockReturnValue(frame);
      window.dispatchEvent(new Event('blur'));
      focused.mockRestore();

      expect(isOpen(panel)).toBe(false);
    });

    it('stays open when the window loses focus from the page', async () => {
      const { panel } = await render();

      panel.showPopover();
      await settle();
      window.dispatchEvent(new Event('blur'));

      expect(isOpen(panel)).toBe(true);
    });

    it('stays open when the window loses focus', async () => {
      const { trigger, panel } = await render();

      trigger.click();
      window.dispatchEvent(new Event('blur'));

      expect(isOpen(panel)).toBe(true);
    });

    it('settles ARIA synchronously when closed for the Turbo cache', async () => {
      const { trigger, panel } = await render();
      key(trigger, 'ArrowDown');

      document.dispatchEvent(new Event('turbo:before-cache'));

      expect(isOpen(panel)).toBe(false);
      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });

    it('reconciles an external hide', async () => {
      const { trigger, panel } = await render();
      key(trigger, 'ArrowDown');

      panel.hidePopover();
      await settle();

      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });

    it('closes on disconnect', async () => {
      const { container, trigger, panel } = await render();
      trigger.click();

      container.remove();
      await vi.waitUntil(() => !application.getControllerForElementAndIdentifier(container, 'combobox'));

      expect(isOpen(panel)).toBe(false);
    });

    it('settles closed state when the open panel is replaced', async () => {
      const { trigger, panel } = await render();
      key(trigger, 'ArrowDown');

      panel.remove();
      await vi.waitUntil(() => trigger.getAttribute('aria-expanded') === 'false');

      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
    });
  });

  describe('editable', () => {
    const type = (trigger, text) => {
      trigger.value = text;
      trigger.dispatchEvent(new Event('input', { bubbles: true }));
    };

    it('opens on input without an active option and dispatches query', async () => {
      const { container, trigger, panel } = await render({ mode: 'editable' });
      const queries = [];
      container.addEventListener('combobox:query', (event) => queries.push(event.detail));

      type(trigger, 'S');
      type(trigger, 'Se');

      expect(isOpen(panel)).toBe(true);
      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
      expect(queries).toEqual([
        { query: 'S', sequence: 1 },
        { query: 'Se', sequence: 2 },
      ]);
    });

    it('clears the active option on input', async () => {
      const { trigger } = await render({ mode: 'editable' });
      key(trigger, 'ArrowDown');

      type(trigger, 'S');

      expect(trigger.hasAttribute('aria-activedescendant')).toBe(false);
      expect(selected()).toEqual([]);
    });

    it('shows the selected label in the trigger', async () => {
      const { trigger } = await render({ mode: 'editable' });
      key(trigger, 'ArrowDown');

      key(trigger, 'Enter');

      expect(trigger.value).toBe('Singapore');
    });

    it('reverts unselected edits on close in restricted mode', async () => {
      const { trigger, input } = await render({ mode: 'editable', value: 'sg', label: 'Singapore' });

      type(trigger, 'Sto');
      expect(input.value).toBe('');
      key(trigger, 'Escape');

      expect(trigger.value).toBe('Singapore');
      expect(input.value).toBe('sg');
    });

    it('submits the typed text in freeform mode', async () => {
      const { trigger, input } = await render({
        mode: 'editable',
        attrs: 'data-combobox-value-policy-value="freeform"',
      });

      type(trigger, 'Somewhere');
      key(trigger, 'Escape');

      expect(input.value).toBe('Somewhere');
      expect(trigger.value).toBe('Somewhere');
    });

    it('keeps typed freeform text when reopened and tabbed away', async () => {
      const { trigger, input } = await render({
        mode: 'editable',
        value: 'sg',
        label: 'Singapore',
        attrs: 'data-combobox-value-policy-value="freeform"',
      });

      type(trigger, 'Somewhere');
      key(trigger, 'Escape');
      trigger.click();
      key(trigger, 'Tab');

      expect(input.value).toBe('Somewhere');
      expect(trigger.value).toBe('Somewhere');
    });
  });

  describe('filtering', () => {
    const type = (trigger, text) => {
      trigger.value = text;
      trigger.dispatchEvent(new Event('input', { bubbles: true }));
    };
    const visible = () =>
      [...document.querySelectorAll('[role="option"]')]
        .filter((option) => !option.closest('[hidden]'))
        .map((o) => o.id);
    const status = () => document.querySelector('#status').textContent;

    it('shows options whose label starts with the query, ignoring case and accents', async () => {
      const { trigger } = await render({
        mode: 'editable',
        items: `
          <li id="opt-sp" role="option" data-value="sp">São Paulo</li>
          <li id="opt-sa" role="option" data-value="sa">Santiago</li>
          <li id="opt-ls" role="option" data-value="ls">Lisbon São</li>`,
      });

      type(trigger, 'SAO');

      expect(visible()).toEqual(['opt-sp']);
    });

    it('matches anywhere in the label with match contains', async () => {
      const { trigger } = await render({ mode: 'editable', attrs: 'data-combobox-match-value="contains"' });

      type(trigger, 'ul');

      expect(visible()).toEqual(['opt-se']);
    });

    it('matches characters in order with match fuzzy', async () => {
      const { trigger } = await render({ mode: 'editable', attrs: 'data-combobox-match-value="fuzzy"' });

      type(trigger, 'skm');

      expect(visible()).toEqual(['opt-st']);
    });

    it('keeps every option with match none', async () => {
      const { trigger } = await render({ mode: 'editable', attrs: 'data-combobox-match-value="none"' });

      type(trigger, 'zz');

      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
    });

    it('keeps authored hidden options hidden when the query clears', async () => {
      const { trigger } = await render({ mode: 'editable' });

      type(trigger, 'Se');
      type(trigger, '');

      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
    });

    it('hides a group with no matching option', async () => {
      const { trigger } = await render({
        mode: 'editable',
        items: `
          <li id="asia" role="none">
            <ul role="group" aria-labelledby="asia-label">
              <li id="asia-label" role="none">Asia</li>
              <li id="opt-sg" role="option" data-value="sg">Singapore</li>
            </ul>
          </li>
          <li id="europe" role="none">
            <ul role="group" aria-labelledby="europe-label">
              <li id="europe-label" role="none">Europe</li>
              <li id="opt-li" role="option" data-value="li">Lisbon</li>
            </ul>
          </li>`,
      });

      type(trigger, 'Li');

      expect(document.querySelector('#asia').hidden).toBe(true);
      expect(document.querySelector('#europe').hidden).toBe(false);
    });

    it('treats a query shorter than minLength as empty', async () => {
      const { container, trigger } = await render({ mode: 'editable', attrs: 'data-combobox-min-length-value="2"' });
      const queries = [];
      container.addEventListener('combobox:query', (event) => queries.push(event.detail.query));

      type(trigger, 'S');
      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
      type(trigger, 'Se');
      type(trigger, 'S');

      expect(queries).toEqual(['Se', '']);
    });

    it('dispatches query only when the query changes', async () => {
      const { container, trigger } = await render({ mode: 'editable' });
      const queries = [];
      container.addEventListener('combobox:query', (event) => queries.push(event.detail.query));

      type(trigger, 'Se');
      type(trigger, 'Se');

      expect(queries).toEqual(['Se']);
    });

    it('reports results after the listbox is filtered', async () => {
      const { container, trigger } = await render({ mode: 'editable', status: true });
      const results = [];
      container.addEventListener('combobox:results', (event) => results.push([event.detail, visible().length]));

      type(trigger, 'Se');

      expect(results).toEqual([[{ query: 'Se', count: 1 }, 1]]);
    });

    it('opens to announce no results when nothing matches', async () => {
      const { trigger, panel } = await render({ mode: 'editable', status: true });

      type(trigger, 'zz');

      expect(isOpen(panel)).toBe(true);
      expect(visible()).toEqual([]);
      expect(status()).toBe('No results');
      type(trigger, 'S');
      expect(status()).toBe('');
    });

    it('announces the configured empty text', async () => {
      const { trigger } = await render({
        mode: 'editable',
        status: true,
        attrs: 'data-combobox-empty-text-value="Aucun résultat"',
      });

      type(trigger, 'zz');

      expect(status()).toBe('Aucun résultat');
    });

    it('reports an editable combobox without a status', async () => {
      const error = vi.spyOn(console, 'error').mockImplementation(() => {});
      await render({ mode: 'editable', status: false });

      expect(error).toHaveBeenCalledWith(expect.stringContaining('status target'));
      error.mockRestore();
    });

    it('clears a filter left without a status on form reset', async () => {
      vi.spyOn(console, 'error').mockImplementation(() => {});
      const { trigger } = await render({ mode: 'editable', status: false });

      type(trigger, 'zz');
      document.querySelector('#form').reset();
      await settle();

      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
      console.error.mockRestore();
    });

    it('clears the filter before a Turbo cache snapshot', async () => {
      vi.spyOn(console, 'error').mockImplementation(() => {});
      const { trigger } = await render({ mode: 'editable', status: false });

      type(trigger, 'zz');
      document.dispatchEvent(new Event('turbo:before-cache'));

      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
      console.error.mockRestore();
    });

    it('dispatches the same query again after closing', async () => {
      const { container, trigger } = await render({ mode: 'editable' });
      const queries = [];
      container.addEventListener('combobox:query', (event) => queries.push(event.detail.query));

      type(trigger, 'Se');
      key(trigger, 'Escape');
      type(trigger, 'Se');

      expect(queries).toEqual(['Se', 'Se']);
    });

    it('keeps an authored hidden option hidden when it matches', async () => {
      const { trigger } = await render({ mode: 'editable' });

      type(trigger, 'San');

      expect(document.querySelector('#opt-sf').hidden).toBe(true);
      expect(status()).toBe('No results');
    });

    it('hides a bare group with no matching option', async () => {
      const { trigger } = await render({
        mode: 'editable',
        items: `
          <ul id="asia" role="group" aria-label="Asia">
            <li id="opt-sg" role="option" data-value="sg">Singapore</li>
          </ul>
          <li id="opt-li" role="option" data-value="li">Lisbon</li>`,
      });

      type(trigger, 'Li');

      expect(document.querySelector('#asia').hidden).toBe(true);
    });

    it('treats a blank query as empty', async () => {
      const { trigger } = await render({ mode: 'editable' });

      type(trigger, '  ');

      expect(status()).toBe('');
      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
    });

    it('selects nothing in a replacement listbox while typing', async () => {
      const { trigger } = await render({ mode: 'editable', value: 'se', label: 'Seoul' });
      type(trigger, 'Se');

      document.querySelector('#listbox').outerHTML = `
        <ul id="listbox" role="listbox" data-combobox-target="listbox">
          <li id="opt-se" role="option" data-value="se">Seoul</li>
        </ul>`;
      await settle();

      expect(selected()).toEqual([]);
    });

    it('clears the filter and status on close', async () => {
      const { trigger, panel } = await render({ mode: 'editable', status: true });

      type(trigger, 'zz');
      key(trigger, 'Escape');
      key(trigger, 'ArrowDown');

      expect(isOpen(panel)).toBe(true);
      expect(status()).toBe('');
      expect(visible()).toEqual(['opt-sg', 'opt-sy', 'opt-se', 'opt-st']);
    });

    it('applies the query to a replacement listbox', async () => {
      const { trigger } = await render({ mode: 'editable', status: true });
      type(trigger, 'Se');

      document.querySelector('#listbox').outerHTML = `
        <ul id="listbox" role="listbox" data-combobox-target="listbox">
          <li id="opt-sv" role="option" data-value="sv">Seville</li>
          <li id="opt-lx" role="option" data-value="lx">Luxor</li>
        </ul>`;
      await settle();

      expect(visible()).toEqual(['opt-sv']);
    });
  });

  describe('lifecycle', () => {
    it('restores the initial selection after a form reset', async () => {
      vi.useFakeTimers();
      try {
        const { trigger, input } = await render({ value: 'sg', label: 'Singapore' });
        key(trigger, 'ArrowDown');
        key(trigger, 'ArrowDown');
        key(trigger, 'Enter');

        document.querySelector('#form').reset();
        vi.runAllTimers();

        expect(input.value).toBe('sg');
        expect(trigger.textContent).toBe('Singapore');
        expect(selected()).toEqual(['opt-sg']);
      } finally {
        vi.useRealTimers();
      }
    });

    it('ignores a cancelled form reset', async () => {
      vi.useFakeTimers();
      try {
        const { trigger, input } = await render({ value: 'sg', label: 'Singapore' });
        key(trigger, 'ArrowDown');
        key(trigger, 'ArrowDown');
        key(trigger, 'Enter');
        const form = document.querySelector('#form');
        form.addEventListener('reset', (event) => event.preventDefault());

        form.reset();
        vi.runAllTimers();

        expect(input.value).toBe('se');
      } finally {
        vi.useRealTimers();
      }
    });

    it('keeps the server-rendered state for reset across a reconnect', async () => {
      const { container, trigger, input } = await render({ value: 'sg', label: 'Singapore' });
      key(trigger, 'ArrowDown');
      key(trigger, 'ArrowDown');
      key(trigger, 'Enter');

      const form = document.querySelector('#form');
      const wrapper = document.createElement('div');
      form.appendChild(wrapper);
      wrapper.appendChild(container);
      await vi.waitUntil(() => application.getControllerForElementAndIdentifier(container, 'combobox'));
      vi.useFakeTimers();
      try {
        form.reset();
        vi.runAllTimers();
      } finally {
        vi.useRealTimers();
      }

      expect(input.value).toBe('sg');
      expect(trigger.getAttribute('aria-expanded')).toBe('false');
    });

    it('re-associates the selected value with replacement options', async () => {
      const { trigger } = await render({ value: 'se', label: 'Seoul' });
      const listbox = document.querySelector('#listbox');

      listbox.outerHTML = `<ul id="listbox" role="listbox" data-combobox-target="listbox">
        <li role="option" data-value="se">Seoul</li>
        <li role="option" data-value="sg">Singapore</li>
      </ul>`;
      await vi.waitUntil(() => document.querySelector('#listbox [role="option"]').id);
      key(trigger, 'ArrowDown');

      const [seoul] = document.querySelectorAll('#listbox [role="option"]');
      expect(active(trigger)).toBe(seoul.id);
      expect(selected()).toEqual([seoul.id]);
    });

    it('drops the active option when a replacement reuses its id', async () => {
      const { trigger } = await render();
      key(trigger, 'ArrowDown');

      document.querySelector('#listbox').outerHTML = `<ul id="listbox" role="listbox" data-combobox-target="listbox">
        <li id="opt-sg" role="option" data-value="sy">Sydney</li>
      </ul>`;
      await vi.waitUntil(() => !trigger.hasAttribute('aria-activedescendant'));
      key(trigger, 'Enter');

      expect(selected()).toEqual([]);
      expect(document.querySelector('input[type="hidden"]').value).toBe('');
    });

    it('drops an active option that replacement removed', async () => {
      const { trigger } = await render();
      key(trigger, 'ArrowDown');

      document.querySelector('#listbox').outerHTML = `<ul id="listbox" role="listbox" data-combobox-target="listbox">
        <li id="opt-new" role="option" data-value="new">New</li>
      </ul>`;
      await vi.waitUntil(() => !trigger.hasAttribute('aria-activedescendant'));

      expect(selected()).toEqual([]);
    });
  });
});
