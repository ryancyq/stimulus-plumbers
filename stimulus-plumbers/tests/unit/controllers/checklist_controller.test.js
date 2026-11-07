// stimulus-plumbers/tests/unit/controllers/checklist_controller.test.js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { morphElements } from '@hotwired/turbo';
import ChecklistController from '../../../src/controllers/checklist_controller';
import { flush, startApplication } from '../../support/stimulus';

describe('ChecklistController', () => {
  let application;

  beforeEach(() => {
    application = startApplication({ checklist: ChecklistController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="checklist"]'),
      'checklist'
    );

  const item = (checked) => `<input type="checkbox" data-checklist-target="item" ${checked ? 'checked' : ''}>`;

  const readonlyItem = (checked) =>
    `<input type="checkbox" data-checklist-target="item" disabled ${checked ? 'checked' : ''}>`;

  const render = async (itemsHtml) => {
    document.body.innerHTML = `
      <div data-controller="checklist" data-action="change->checklist#onChange">
        <input type="checkbox" data-checklist-target="selectAll">
        ${itemsHtml}
      </div>
    `;
    await flush();
  };

  const selectAll = () => document.querySelector('[data-checklist-target="selectAll"]');
  const items = () => Array.from(document.querySelectorAll('[data-checklist-target="item"]'));

  const change = (el) => el.dispatchEvent(new Event('change', { bubbles: true }));

  describe('on connect', () => {
    it('sets the select-all checkbox checked=true, indeterminate=false when all items are checked', async () => {
      await render(item(true) + item(true));
      expect(selectAll().checked).toBe(true);
      expect(selectAll().indeterminate).toBe(false);
    });

    it('sets the select-all checkbox checked=false, indeterminate=false when all items are unchecked', async () => {
      await render(item(false) + item(false));
      expect(selectAll().checked).toBe(false);
      expect(selectAll().indeterminate).toBe(false);
    });

    it('sets the select-all checkbox checked=false, indeterminate=false when there are zero items', async () => {
      await render('');
      expect(selectAll().checked).toBe(false);
      expect(selectAll().indeterminate).toBe(false);
    });

    it('sets the select-all checkbox indeterminate=true when items are partially checked', async () => {
      await render(item(true) + item(false));
      expect(selectAll().indeterminate).toBe(true);
    });

    it('excludes disabled (readonly) items from aggregation', async () => {
      await render(item(true) + item(true) + readonlyItem(false));
      expect(selectAll().checked).toBe(true);
      expect(selectAll().indeterminate).toBe(false);
    });
  });

  describe('onChange from an item', () => {
    it('recomputes the select-all checkbox without touching other items', async () => {
      await render(item(false) + item(false));
      const [first, second] = items();

      first.checked = true;
      change(first);

      expect(selectAll().indeterminate).toBe(true);
      expect(second.checked).toBe(false);
    });
  });

  describe('onChange from the select-all checkbox', () => {
    it('sets every enabled item checked=true when the select-all checkbox is checked', async () => {
      await render(item(false) + item(false));

      selectAll().checked = true;
      change(selectAll());

      items().forEach((el) => expect(el.checked).toBe(true));
    });

    it('sets every enabled item checked=false when the select-all checkbox is unchecked', async () => {
      await render(item(true) + item(true));

      selectAll().checked = false;
      change(selectAll());

      items().forEach((el) => expect(el.checked).toBe(false));
    });

    it('never touches disabled items', async () => {
      await render(item(false) + readonlyItem(false));
      const readonly = document.querySelector('[data-checklist-target="item"][disabled]');

      selectAll().checked = true;
      change(selectAll());

      expect(readonly.checked).toBe(false);
    });
  });

  describe('repeated select-all toggles', () => {
    it('keeps the select-all checkbox checked correct across at least 3 consecutive toggles', async () => {
      await render(item(false) + item(false));

      selectAll().checked = true;
      change(selectAll());
      expect(selectAll().checked).toBe(true);

      selectAll().checked = false;
      change(selectAll());
      expect(selectAll().checked).toBe(false);

      selectAll().checked = true;
      change(selectAll());
      expect(selectAll().checked).toBe(true);
    });
  });

  describe('toggleAll(checked)', () => {
    it('is callable directly and checks all enabled items, matching a select-all change', async () => {
      await render(item(false) + item(false));

      getController().toggleAll(true);

      items().forEach((el) => expect(el.checked).toBe(true));
    });

    it('is callable directly and unchecks all enabled items', async () => {
      await render(item(true) + item(true));

      getController().toggleAll(false);

      items().forEach((el) => expect(el.checked).toBe(false));
    });

    it('syncs the select-all checkbox when called directly', async () => {
      await render(item(false) + item(true));

      getController().toggleAll(true);

      expect(selectAll().checked).toBe(true);
      expect(selectAll().indeterminate).toBe(false);
    });
  });

  describe('items added or removed after connect', () => {
    const tick = () => flush();

    it('drops the select-all checkbox out of checked when an unchecked item is appended', async () => {
      await render(item(true) + item(true));

      selectAll().parentElement.insertAdjacentHTML('beforeend', item(false));
      await tick();

      expect(selectAll().checked).toBe(false);
      expect(selectAll().indeterminate).toBe(true);
    });

    it('checks the select-all checkbox when the only unchecked item is removed', async () => {
      await render(item(true) + item(false));

      items()[1].remove();
      await tick();

      expect(selectAll().checked).toBe(true);
      expect(selectAll().indeterminate).toBe(false);
    });
  });

  describe('after a Turbo morph', () => {
    it('clears the mixed state when the server unchecks every item', async () => {
      await render(item(true) + item(false));
      const container = document.querySelector('[data-controller="checklist"]');
      const next = container.cloneNode(true);
      next.querySelectorAll('[data-checklist-target="item"]').forEach((el) => el.removeAttribute('checked'));

      morphElements(container, next);
      await Promise.resolve();

      items().forEach((el) => expect(el.checked).toBe(false));
      expect(selectAll().indeterminate).toBe(false);
      expect(selectAll().checked).toBe(false);
    });
  });

  describe('form reset', () => {
    it('recomputes the select-all checkbox once the items return to their defaults', async () => {
      document.body.innerHTML = `
        <form>
          <div data-controller="checklist" data-action="change->checklist#onChange">
            <input type="checkbox" data-checklist-target="selectAll">
            ${item(false)}${item(false)}
          </div>
        </form>
      `;
      await flush();
      items()[0].checked = true;
      change(items()[0]);
      expect(selectAll().indeterminate).toBe(true);

      document.querySelector('form').reset();
      await flush();

      expect(selectAll().indeterminate).toBe(false);
      expect(selectAll().checked).toBe(false);
    });
  });

  describe('without a select-all checkbox', () => {
    it('connects and handles item changes without errors', async () => {
      const error = vi.spyOn(console, 'error').mockImplementation(() => {});
      document.body.innerHTML = `
        <div data-controller="checklist" data-action="change->checklist#onChange">${item(false)}</div>
      `;
      await flush();
      change(items()[0]);

      expect(error).not.toHaveBeenCalled();
      error.mockRestore();
    });
  });
});
