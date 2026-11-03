import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { ActiveDescendant, RovingTabIndex } from '../../../src/accessibility/keyboard';

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

describe('ActiveDescendant', () => {
  let owner;
  let listbox;
  let descendant;

  const option = (label) => listbox.querySelector(`[data-label="${label}"]`);

  beforeEach(() => {
    document.body.innerHTML = `
      <input id="owner">
      <ul role="listbox">
        <li role="option" data-label="a">A</li>
        <li role="option" data-label="b" aria-disabled="true">B</li>
        <li role="option" data-label="c">C</li>
        <li role="option" data-label="d">D</li>
      </ul>`;
    owner = document.querySelector('#owner');
    listbox = document.querySelector('[role="listbox"]');
    Element.prototype.scrollIntoView = vi.fn();
    descendant = new ActiveDescendant(owner, {
      options: () => [...listbox.querySelectorAll('[role="option"]')],
      enabled: (item) => item.getAttribute('aria-disabled') !== 'true',
      idPrefix: 'test-option',
    });
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete Element.prototype.scrollIntoView;
  });

  it('activates an option: selected, referenced by the owner, and scrolled into view', () => {
    descendant.activate(option('c'));

    expect(option('c').getAttribute('aria-selected')).toBe('true');
    expect(option('a').getAttribute('aria-selected')).toBe('false');
    expect(owner.getAttribute('aria-activedescendant')).toBe(option('c').id);
    expect(option('c').id).toMatch(/^test-option/);
    expect(option('c').scrollIntoView).toHaveBeenCalledWith({ block: 'nearest' });
    expect(descendant.active).toBe(option('c'));
  });

  it('moves over disabled options and stops at the ends', () => {
    descendant.first();
    descendant.move(1);
    expect(descendant.active).toBe(option('c'));

    descendant.move(5);
    expect(descendant.active).toBe(option('d'));

    descendant.move(-5);
    expect(descendant.active).toBe(option('a'));
  });

  it('moves from a disabled active option to the enabled option on that side', () => {
    descendant.activate(option('b'));
    descendant.move(1);
    expect(descendant.active).toBe(option('c'));

    descendant.activate(option('b'));
    descendant.move(-1);
    expect(descendant.active).toBe(option('a'));
  });

  it('moves from a disabled active option to the other side when that side has none', () => {
    option('a').setAttribute('aria-disabled', 'true');
    descendant.activate(option('a'));
    descendant.move(-1);
    expect(descendant.active).toBe(option('c'));
  });

  it('starts from the first or last option when none is active', () => {
    descendant.move(1);
    expect(descendant.active).toBe(option('a'));

    descendant.clear();
    descendant.move(-1);
    expect(descendant.active).toBe(option('d'));
  });

  it('first and last skip disabled options', () => {
    option('a').setAttribute('aria-disabled', 'true');

    descendant.first();
    expect(descendant.active).toBe(option('c'));

    descendant.last();
    expect(descendant.active).toBe(option('d'));
  });

  it('clears the active option', () => {
    descendant.activate(option('a'));

    descendant.clear();

    expect(descendant.active).toBeNull();
    expect(owner.hasAttribute('aria-activedescendant')).toBe(false);
    expect(option('a').getAttribute('aria-selected')).toBe('false');
  });

  it('resolves an owner given as a function on every change', () => {
    const replacement = document.createElement('input');
    let current = owner;
    descendant = new ActiveDescendant(() => current, {
      options: () => [...listbox.querySelectorAll('[role="option"]')],
    });
    current = replacement;

    descendant.activate(option('a'));

    expect(replacement.getAttribute('aria-activedescendant')).toBe(option('a').id);
    expect(owner.hasAttribute('aria-activedescendant')).toBe(false);
  });

  it('reports no active option once it is removed or disabled', () => {
    descendant.activate(option('c'));
    option('c').setAttribute('aria-disabled', 'true');

    expect(descendant.active).toBeNull();
  });
});
