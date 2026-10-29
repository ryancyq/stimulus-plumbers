// stimulus-plumbers/tests/unit/controllers/checklist_controller.test.js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { morphElements } from '@hotwired/turbo';
import ChecklistController from '../../../src/controllers/checklist_controller';

describe('ChecklistController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('checklist', ChecklistController);
  });

  afterEach(() => {
    application.stop();
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
        <input type="checkbox" data-checklist-target="master">
        ${itemsHtml}
      </div>
    `;
    await new Promise((r) => setTimeout(r, 10));
  };

  const master = () => document.querySelector('[data-checklist-target="master"]');
  const items = () => Array.from(document.querySelectorAll('[data-checklist-target="item"]'));

  const change = (el) => el.dispatchEvent(new Event('change', { bubbles: true }));

  describe('on connect', () => {
    it('sets master checked=true, indeterminate=false when all items are checked', async () => {
      await render(item(true) + item(true));
      expect(master().checked).toBe(true);
      expect(master().indeterminate).toBe(false);
    });

    it('sets master checked=false, indeterminate=false when all items are unchecked', async () => {
      await render(item(false) + item(false));
      expect(master().checked).toBe(false);
      expect(master().indeterminate).toBe(false);
    });

    it('sets master checked=false, indeterminate=false when there are zero items', async () => {
      await render('');
      expect(master().checked).toBe(false);
      expect(master().indeterminate).toBe(false);
    });

    it('sets master indeterminate=true when items are partially checked', async () => {
      await render(item(true) + item(false));
      expect(master().indeterminate).toBe(true);
    });

    it('excludes disabled (readonly) items from aggregation', async () => {
      await render(item(true) + item(true) + readonlyItem(false));
      expect(master().checked).toBe(true);
      expect(master().indeterminate).toBe(false);
    });
  });

  describe('onChange from an item', () => {
    it('recomputes the master without touching other items', async () => {
      await render(item(false) + item(false));
      const [first, second] = items();

      first.checked = true;
      change(first);

      expect(master().indeterminate).toBe(true);
      expect(second.checked).toBe(false);
    });
  });

  describe('onChange from the master', () => {
    it('sets every enabled item checked=true when master is checked', async () => {
      await render(item(false) + item(false));

      master().checked = true;
      change(master());

      items().forEach((el) => expect(el.checked).toBe(true));
    });

    it('sets every enabled item checked=false when master is unchecked', async () => {
      await render(item(true) + item(true));

      master().checked = false;
      change(master());

      items().forEach((el) => expect(el.checked).toBe(false));
    });

    it('never touches disabled items', async () => {
      await render(item(false) + readonlyItem(false));
      const readonly = document.querySelector('[data-checklist-target="item"][disabled]');

      master().checked = true;
      change(master());

      expect(readonly.checked).toBe(false);
    });
  });

  describe('repeated master toggles', () => {
    it('keeps master checked correct across at least 3 consecutive toggles', async () => {
      await render(item(false) + item(false));

      master().checked = true;
      change(master());
      expect(master().checked).toBe(true);

      master().checked = false;
      change(master());
      expect(master().checked).toBe(false);

      master().checked = true;
      change(master());
      expect(master().checked).toBe(true);
    });
  });

  describe('toggleAll(checked)', () => {
    it('is callable directly and checks all enabled items, matching a master-driven change', async () => {
      await render(item(false) + item(false));

      getController().toggleAll(true);

      items().forEach((el) => expect(el.checked).toBe(true));
    });

    it('is callable directly and unchecks all enabled items', async () => {
      await render(item(true) + item(true));

      getController().toggleAll(false);

      items().forEach((el) => expect(el.checked).toBe(false));
    });

    it('syncs the master when called directly', async () => {
      await render(item(false) + item(true));

      getController().toggleAll(true);

      expect(master().checked).toBe(true);
      expect(master().indeterminate).toBe(false);
    });
  });

  describe('items added or removed after connect', () => {
    const tick = () => new Promise((r) => setTimeout(r, 0));

    it('drops the master out of checked when an unchecked item is appended', async () => {
      await render(item(true) + item(true));

      master().parentElement.insertAdjacentHTML('beforeend', item(false));
      await tick();

      expect(master().checked).toBe(false);
      expect(master().indeterminate).toBe(true);
    });

    it('checks the master when the only unchecked item is removed', async () => {
      await render(item(true) + item(false));

      items()[1].remove();
      await tick();

      expect(master().checked).toBe(true);
      expect(master().indeterminate).toBe(false);
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
      expect(master().indeterminate).toBe(false);
      expect(master().checked).toBe(false);
    });
  });

  describe('form reset', () => {
    it('recomputes the master once the items return to their defaults', async () => {
      document.body.innerHTML = `
        <form>
          <div data-controller="checklist" data-action="change->checklist#onChange">
            <input type="checkbox" data-checklist-target="master">
            ${item(false)}${item(false)}
          </div>
        </form>
      `;
      await new Promise((r) => setTimeout(r, 10));
      items()[0].checked = true;
      change(items()[0]);
      expect(master().indeterminate).toBe(true);

      document.querySelector('form').reset();
      await new Promise((r) => setTimeout(r, 0));

      expect(master().indeterminate).toBe(false);
      expect(master().checked).toBe(false);
    });
  });

  describe('without a master', () => {
    it('connects and handles item changes without errors', async () => {
      const error = vi.spyOn(console, 'error').mockImplementation(() => {});
      document.body.innerHTML = `
        <div data-controller="checklist" data-action="change->checklist#onChange">${item(false)}</div>
      `;
      await new Promise((r) => setTimeout(r, 10));
      change(items()[0]);

      expect(error).not.toHaveBeenCalled();
      error.mockRestore();
    });
  });
});
