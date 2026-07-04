import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { RovingTabIndex, ListboxNavigation } from '../../../src/accessibility/keyboard';

function makeButtons(labels) {
  return labels.map((l) => {
    const btn = document.createElement('button');
    btn.textContent = l;
    document.body.appendChild(btn);
    return btn;
  });
}

function keydown(el, key) {
  el.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true }));
}

describe('RovingTabIndex', () => {
  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('activate / deactivate', () => {
    it('sets tabIndex=0 on first item and -1 on others after activate', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c]);
      rti.activate();
      expect(a.tabIndex).toBe(0);
      expect(b.tabIndex).toBe(-1);
      expect(c.tabIndex).toBe(-1);
    });

    it('removes keydown listener after deactivate — arrow keys no longer move focus', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b]);
      rti.activate();
      rti.deactivate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(a);
    });
  });

  describe('orientation: vertical', () => {
    it('ArrowDown moves to next item', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(b);
    });

    it('ArrowUp moves to previous item', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      b.focus();
      keydown(b, 'ArrowUp');
      expect(document.activeElement).toBe(a);
    });

    it('ArrowRight does NOT move focus', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowRight');
      expect(document.activeElement).toBe(a);
    });

    it('ArrowLeft does NOT move focus', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      b.focus();
      keydown(b, 'ArrowLeft');
      expect(document.activeElement).toBe(b);
    });
  });

  describe('orientation: horizontal', () => {
    it('ArrowRight moves to next item', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'horizontal' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowRight');
      expect(document.activeElement).toBe(b);
    });

    it('ArrowDown does NOT move focus', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'horizontal' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(a);
    });
  });

  describe('orientation: both (default)', () => {
    it('ArrowDown and ArrowRight both move forward', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b]);
      rti.activate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(b);

      b.focus();
      rti.setCurrentIndex(0);
      keydown(a, 'ArrowRight');
      expect(document.activeElement).toBe(b);
    });
  });

  describe('wrap', () => {
    it('wraps forward by default', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      b.focus();
      rti.setCurrentIndex(1);
      keydown(b, 'ArrowDown');
      expect(document.activeElement).toBe(a);
    });

    it('does not wrap when wrap=false', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical', wrap: false });
      rti.activate();
      b.focus();
      rti.setCurrentIndex(1);
      keydown(b, 'ArrowDown');
      expect(document.activeElement).toBe(b);
    });
  });

  describe('Home / End', () => {
    it('Home moves to first item', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      c.focus();
      rti.setCurrentIndex(2);
      keydown(c, 'Home');
      expect(document.activeElement).toBe(a);
    });

    it('End moves to last item', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      keydown(a, 'End');
      expect(document.activeElement).toBe(c);
    });
  });

  describe('click sync', () => {
    it('clicking an item updates currentIndex so next arrow key navigates from it', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      c.click(); // click third item — currentIndex should become 2
      keydown(c, 'ArrowDown'); // should wrap to a (index 0), not go to b (index 1)
      expect(document.activeElement).toBe(a);
    });
  });

  describe('updateItems', () => {
    it('reattaches listeners on new items', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a], { orientation: 'vertical' });
      rti.activate();
      rti.updateItems([a, b]);
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(b);
    });

    it('clamps currentIndex when items shrink', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      rti.setCurrentIndex(2);
      rti.updateItems([a, b]);
      expect(rti.currentIndex).toBe(1);
    });
  });

  describe('ignoreModifierKeys', () => {
    it('ignores ArrowDown with Alt held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Control held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', ctrlKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Shift held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', shiftKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Meta held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', metaKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('still moves focus on a plain (unmodified) ArrowDown', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(b);
    });

    it('a modified keydown does not sync currentIndex either', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      // physically focus c without going through setCurrentIndex, then send a modified
      // keydown on it — if the guard ran after the fromIndex sync, currentIndex would
      // become 2 as a side effect even though navigation itself is ignored
      c.focus();
      c.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(rti.currentIndex).toBe(0);
    });

    it('ignoreModifierKeys can be overridden to a narrower list', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical', ignoreModifierKeys: ['Alt'] });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a); // Alt still ignored

      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', shiftKey: true, bubbles: true }));
      expect(document.activeElement).toBe(b); // Shift no longer ignored
    });
  });
});

describe('ListboxNavigation', () => {
  let listbox;

  beforeEach(() => {
    Element.prototype.scrollIntoView = vi.fn();
    listbox = document.createElement('ul');
    listbox.setAttribute('role', 'listbox');
    document.body.appendChild(listbox);
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete Element.prototype.scrollIntoView;
  });

  function addOption(value, selected = false, disabled = false) {
    const li = document.createElement('li');
    li.setAttribute('role', 'option');
    li.dataset.value = value;
    li.setAttribute('aria-selected', selected ? 'true' : 'false');
    if (disabled) li.setAttribute('aria-disabled', 'true');
    listbox.appendChild(li);
    return li;
  }

  describe('step', () => {
    it('step(1) moves aria-selected to next option', () => {
      const [a, b] = [addOption('a', true), addOption('b')];
      const nav = new ListboxNavigation(listbox);
      nav.step(1);
      expect(a.getAttribute('aria-selected')).toBe('false');
      expect(b.getAttribute('aria-selected')).toBe('true');
    });

    it('step(-1) moves aria-selected to previous option', () => {
      const [a, b] = [addOption('a'), addOption('b', true)];
      const nav = new ListboxNavigation(listbox);
      nav.step(-1);
      expect(a.getAttribute('aria-selected')).toBe('true');
      expect(b.getAttribute('aria-selected')).toBe('false');
    });

    it('does not wrap when wrap=false (default)', () => {
      const [a, b] = [addOption('a'), addOption('b', true)];
      const nav = new ListboxNavigation(listbox, { wrap: false });
      nav.step(1);
      expect(b.getAttribute('aria-selected')).toBe('true');
    });

    it('wraps when wrap=true', () => {
      const [a, b] = [addOption('a'), addOption('b', true)];
      const nav = new ListboxNavigation(listbox, { wrap: true });
      nav.step(1);
      expect(a.getAttribute('aria-selected')).toBe('true');
      expect(b.getAttribute('aria-selected')).toBe('false');
    });

    it('skips disabled options', () => {
      const [a, b, c] = [addOption('a', true), addOption('b', false, true), addOption('c')];
      const nav = new ListboxNavigation(listbox);
      nav.step(1);
      expect(c.getAttribute('aria-selected')).toBe('true');
    });

    it('calls scrollIntoView on the newly selected option', () => {
      const [a, b] = [addOption('a', true), addOption('b')];
      const nav = new ListboxNavigation(listbox);
      nav.step(1);
      expect(b.scrollIntoView).toHaveBeenCalledWith({ block: 'nearest' });
    });
  });

  describe('handleKeyDown', () => {
    function keydown(key) {
      const event = new KeyboardEvent('keydown', { key, bubbles: true });
      vi.spyOn(event, 'preventDefault');
      const nav = new ListboxNavigation(listbox);
      nav.handleKeyDown(event);
      return event;
    }

    it('ArrowDown calls step(1)', () => {
      const [a, b] = [addOption('a', true), addOption('b')];
      const event = keydown('ArrowDown');
      expect(event.preventDefault).toHaveBeenCalled();
      expect(b.getAttribute('aria-selected')).toBe('true');
    });

    it('ArrowUp calls step(-1)', () => {
      const [a, b] = [addOption('a'), addOption('b', true)];
      const event = keydown('ArrowUp');
      expect(event.preventDefault).toHaveBeenCalled();
      expect(a.getAttribute('aria-selected')).toBe('true');
    });

    it('Home selects first option', () => {
      const [a, b, c] = [addOption('a'), addOption('b'), addOption('c', true)];
      const event = keydown('Home');
      expect(event.preventDefault).toHaveBeenCalled();
      expect(a.getAttribute('aria-selected')).toBe('true');
    });

    it('End selects last option', () => {
      const [a, b, c] = [addOption('a', true), addOption('b'), addOption('c')];
      const event = keydown('End');
      expect(event.preventDefault).toHaveBeenCalled();
      expect(c.getAttribute('aria-selected')).toBe('true');
    });

    it('Enter clicks the currently selected option', () => {
      const [a] = [addOption('a', true)];
      const clickSpy = vi.fn();
      a.addEventListener('click', clickSpy);
      keydown('Enter');
      expect(clickSpy).toHaveBeenCalled();
    });

    it('Space clicks the currently selected option', () => {
      const [a] = [addOption('a', true)];
      const clickSpy = vi.fn();
      a.addEventListener('click', clickSpy);
      keydown(' ');
      expect(clickSpy).toHaveBeenCalled();
    });

    it('ignores unrecognized keys', () => {
      const [a, b] = [addOption('a', true), addOption('b')];
      const event = new KeyboardEvent('keydown', { key: 'Tab', bubbles: true });
      vi.spyOn(event, 'preventDefault');
      new ListboxNavigation(listbox).handleKeyDown(event);
      expect(event.preventDefault).not.toHaveBeenCalled();
      expect(a.getAttribute('aria-selected')).toBe('true');
    });
  });

  describe('selectedItem and currentIndex', () => {
    it('selectedItem returns null when nothing is selected', () => {
      const nav = new ListboxNavigation(listbox);
      expect(nav.selectedItem).toBeNull();
    });

    it('selectedItem returns the currently selected item', () => {
      const nav = new ListboxNavigation(listbox);
      addOption('a', true);
      addOption('b');
      nav.step(1);
      expect(nav.selectedItem).toBe(listbox.querySelectorAll('[role="option"]')[1]);
    });

    it('currentIndex returns -1 when nothing is selected', () => {
      const nav = new ListboxNavigation(listbox);
      expect(nav.currentIndex).toBe(-1);
    });

    it('currentIndex returns the index of the selected item', () => {
      const nav = new ListboxNavigation(listbox);
      addOption('a', true);
      addOption('b');
      expect(nav.currentIndex).toBe(0);
      nav.step(1);
      expect(nav.currentIndex).toBe(1);
    });
  });

  describe('step - selector scoping', () => {
    it('treats a disabled selected option as unselected when navigating', () => {
      document.body.innerHTML = `
        <div id="lb">
          <div role="option">A</div>
          <div role="option" aria-disabled="true" aria-selected="true">B</div>
          <div role="option">C</div>
        </div>
      `;
      const nav = new ListboxNavigation(document.getElementById('lb'));
      // disabled item should not be found by the scoped selector → treated as idx=-1 → A selected
      nav.step(1);
      const opts = document.querySelectorAll('[role="option"]:not([aria-disabled="true"])');
      expect(opts[0].getAttribute('aria-selected')).toBe('true'); // A
      expect(opts[1].getAttribute('aria-selected')).toBe('false'); // C
    });
  });

  describe('handleKeyDown - Home/End share _selectItem', () => {
    let listbox2, nav;

    beforeEach(() => {
      document.body.innerHTML = `
        <div id="lb2">
          <div role="option" aria-selected="true">First</div>
          <div role="option">Middle</div>
          <div role="option">Last</div>
        </div>
      `;
      listbox2 = document.getElementById('lb2');
      nav = new ListboxNavigation(listbox2);
    });

    it('Home selects the first option', () => {
      // select last first so Home actually moves
      listbox2.querySelectorAll('[role="option"]')[2].setAttribute('aria-selected', 'true');
      listbox2.querySelectorAll('[role="option"]')[0].setAttribute('aria-selected', 'false');
      nav.handleKeyDown(new KeyboardEvent('keydown', { key: 'Home', bubbles: true }));
      const opts = listbox2.querySelectorAll('[role="option"]');
      expect(opts[0].getAttribute('aria-selected')).toBe('true');
      expect(opts[2].getAttribute('aria-selected')).toBe('false');
    });

    it('End selects the last option', () => {
      nav.handleKeyDown(new KeyboardEvent('keydown', { key: 'End', bubbles: true }));
      const opts = listbox2.querySelectorAll('[role="option"]');
      expect(opts[2].getAttribute('aria-selected')).toBe('true');
      expect(opts[0].getAttribute('aria-selected')).toBe('false');
    });
  });
});
