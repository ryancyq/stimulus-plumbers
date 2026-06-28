import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { announce, connectTriggerToTarget, disconnectTriggerFromTarget, setHidden } from '../../../src/accessibility/aria';

describe('ARIA utilities', () => {
  let trigger;
  let target;

  beforeEach(() => {
    trigger = document.createElement('button');
    trigger.id = 'trigger';
    target = document.createElement('div');
    target.id = 'target';
    document.body.appendChild(trigger);
    document.body.appendChild(target);
  });

  afterEach(() => {
    document.body.innerHTML = '';
  });

  describe('connectTriggerToTarget', () => {
    it('sets role on target element', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(target.getAttribute('role')).toBe('menu');
    });

    it('sets aria-controls on trigger', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-controls')).toBe('target');
    });

    it('sets aria-haspopup for menu role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('menu');
    });

    it('sets aria-haspopup for dialog role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'dialog'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('dialog');
    });

    it('sets aria-haspopup for listbox role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'listbox'
      });

      expect(trigger.getAttribute('aria-haspopup')).toBe('listbox');
    });

    it('sets aria-describedby for tooltip role', () => {
      connectTriggerToTarget({
        trigger,
        target,
        role: 'tooltip'
      });

      expect(trigger.getAttribute('aria-describedby')).toBe('target');
    });

    it('does not override existing role by default', () => {
      target.setAttribute('role', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(target.getAttribute('role')).toBe('existing');
    });

    it('overrides existing role with override option', () => {
      target.setAttribute('role', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu',
        override: true
      });

      expect(target.getAttribute('role')).toBe('menu');
    });

    it('does not override existing aria-controls by default', () => {
      trigger.setAttribute('aria-controls', 'existing');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.getAttribute('aria-controls')).toBe('existing');
    });

    it('returns object with set attributes separated by element', () => {
      const result = connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(result).toEqual({
        trigger: {
          'aria-controls': 'target',
          'aria-haspopup': 'menu'
        },
        target: {
          role: 'menu'
        }
      });
    });

    it('handles missing trigger gracefully', () => {
      const result = connectTriggerToTarget({
        trigger: null,
        target,
        role: 'menu'
      });

      expect(result).toEqual({ trigger: {}, target: {} });
    });

    it('handles missing target gracefully', () => {
      const result = connectTriggerToTarget({
        trigger,
        target: null,
        role: 'menu'
      });

      expect(result).toEqual({ trigger: {}, target: {} });
    });

    it('requires target id for aria-controls', () => {
      target.removeAttribute('id');

      connectTriggerToTarget({
        trigger,
        target,
        role: 'menu'
      });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
    });

    it('works without specifying role', () => {
      const result = connectTriggerToTarget({
        trigger,
        target
      });

      expect(trigger.getAttribute('aria-controls')).toBe('target');
      expect(result.trigger['aria-controls']).toBe('target');
    });
  });

  describe('disconnectTriggerFromTarget', () => {
    beforeEach(() => {
      trigger.setAttribute('aria-controls', 'target');
      trigger.setAttribute('aria-haspopup', 'menu');
      trigger.setAttribute('aria-describedby', 'target');
      target.setAttribute('role', 'menu');
    });

    it('removes all ARIA relationship attributes by default', () => {
      disconnectTriggerFromTarget({ trigger, target });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
      expect(trigger.hasAttribute('aria-haspopup')).toBe(false);
      expect(trigger.hasAttribute('aria-describedby')).toBe(false);
      expect(target.hasAttribute('role')).toBe(false);
    });

    it('removes specific attributes when specified', () => {
      disconnectTriggerFromTarget({
        trigger,
        target,
        attributes: ['aria-controls']
      });

      expect(trigger.hasAttribute('aria-controls')).toBe(false);
      expect(trigger.hasAttribute('aria-haspopup')).toBe(true);
      expect(trigger.hasAttribute('aria-describedby')).toBe(true);
      expect(target.hasAttribute('role')).toBe(true);
    });

    it('removes role when explicitly specified', () => {
      disconnectTriggerFromTarget({
        trigger,
        target,
        attributes: ['role']
      });

      expect(target.hasAttribute('role')).toBe(false);
      expect(trigger.hasAttribute('aria-controls')).toBe(true);
    });

    it('handles missing trigger gracefully', () => {
      expect(() => {
        disconnectTriggerFromTarget({ trigger: null, target });
      }).not.toThrow();
    });

    it('handles missing target gracefully', () => {
      expect(() => {
        disconnectTriggerFromTarget({ trigger, target: null });
      }).not.toThrow();
    });
  });

  describe('setHidden', () => {
    it('sets hidden attribute when true', () => {
      const el = document.createElement('div');
      document.body.appendChild(el);
      setHidden(el, true);
      expect(el.hasAttribute('hidden')).toBe(true);
    });

    it('removes hidden attribute when false', () => {
      const el = document.createElement('div');
      el.setAttribute('hidden', '');
      document.body.appendChild(el);
      setHidden(el, false);
      expect(el.hasAttribute('hidden')).toBe(false);
    });
  });

  describe('announce', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.restoreAllMocks();
      // Clean up all live regions
      document.querySelectorAll('[data-live-region]').forEach((el) => el.remove());
    });

    it('creates a live region with correct attributes', () => {
      announce('Test message');
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region).toBeTruthy();
      expect(region.className).toBe('sr-only');
      expect(region.dataset.liveRegion).toBe('polite');
      expect(region.getAttribute('aria-live')).toBe('polite');
      expect(region.getAttribute('aria-atomic')).toBe('true');
      expect(region.getAttribute('aria-relevant')).toBe('additions text');
    });

    it('sets the message text content', () => {
      announce('Test message');
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.textContent).toBe('Test message');
    });

    it('reuses existing live region for same politeness level', () => {
      announce('First message');
      vi.runAllTimers();

      announce('Second message');
      vi.runAllTimers();

      const regions = document.querySelectorAll('[data-live-region="polite"]');
      expect(regions.length).toBe(1);
      expect(regions[0].textContent).toBe('Second message');
    });

    it('creates separate regions for different politeness levels', () => {
      announce('Polite message', { politeness: 'polite' });
      vi.runAllTimers();

      announce('Assertive message', { politeness: 'assertive' });
      vi.runAllTimers();

      const politeRegion = document.querySelector('[data-live-region="polite"]');
      const assertiveRegion = document.querySelector('[data-live-region="assertive"]');

      expect(politeRegion).toBeTruthy();
      expect(assertiveRegion).toBeTruthy();
      expect(politeRegion.textContent).toBe('Polite message');
      expect(assertiveRegion.textContent).toBe('Assertive message');
    });

    it('supports assertive politeness level', () => {
      announce('Urgent message', { politeness: 'assertive' });
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="assertive"]');
      expect(region.getAttribute('aria-live')).toBe('assertive');
    });

    it('supports off politeness level', () => {
      announce('Silent message', { politeness: 'off' });
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="off"]');
      expect(region.getAttribute('aria-live')).toBe('off');
    });

    it('respects atomic option', () => {
      announce('Test message', { atomic: false });
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.getAttribute('aria-atomic')).toBe('false');
    });

    it('respects relevant option', () => {
      announce('Test message', { relevant: 'all' });
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.getAttribute('aria-relevant')).toBe('all');
    });

    it('clears previous message before announcing new one', () => {
      announce('Test message');

      // Before timer runs, content should be empty
      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.textContent).toBe('');

      // After timer runs, content should be set
      vi.runAllTimers();
      expect(region.textContent).toBe('Test message');
    });

    it('appends region to document body', () => {
      announce('Test message');
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.parentElement).toBe(document.body);
    });

    it('handles empty messages', () => {
      announce('');
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.textContent).toBe('');
    });

    it('handles multiple rapid announcements', () => {
      announce('First');
      announce('Second');
      announce('Third');
      vi.runAllTimers();

      const region = document.querySelector('[data-live-region="polite"]');
      expect(region.textContent).toBe('Third');
    });
  });
});
