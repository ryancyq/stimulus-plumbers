import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import TimelineController from '../../../src/controllers/timeline_controller';

describe('TimelineController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('timeline', TimelineController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const buildHTML = ({ expanded1 = false, expanded2 = false, omitAriaExpanded = false } = {}) => `
    <ol data-controller="timeline">
      <li>
        <h3>
          <button data-timeline-target="trigger"
                  data-action="timeline#toggle"
                  ${omitAriaExpanded ? '' : `aria-expanded="${expanded1}"`}
                  aria-controls="detail-1">
            Event 1
          </button>
        </h3>
        <div id="detail-1" data-timeline-target="detail" ${expanded1 ? '' : 'hidden'}>
          Detail 1
        </div>
      </li>
      <li>
        <h3>
          <button data-timeline-target="trigger"
                  data-action="timeline#toggle"
                  ${omitAriaExpanded ? '' : `aria-expanded="${expanded2}"`}
                  aria-controls="detail-2">
            Event 2
          </button>
        </h3>
        <div id="detail-2" data-timeline-target="detail" ${expanded2 ? '' : 'hidden'}>
          Detail 2
        </div>
      </li>
    </ol>
  `;

  const setup = async (html) => {
    document.body.innerHTML = html;
    await new Promise((resolve) => setTimeout(resolve, 10));
  };

  describe('toggle', () => {
    it('expands a collapsed item', async () => {
      await setup(buildHTML({ expanded1: false }));

      const trigger = document.querySelectorAll('[data-timeline-target="trigger"]')[0];
      const detail = document.getElementById('detail-1');
      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(detail.hasAttribute('hidden')).toBe(false);
    });

    it('collapses an expanded item', async () => {
      await setup(buildHTML({ expanded1: true }));

      const trigger = document.querySelectorAll('[data-timeline-target="trigger"]')[0];
      const detail = document.getElementById('detail-1');
      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(detail.hasAttribute('hidden')).toBe(true);
    });
  });

  describe('toggle with missing detail', () => {
    it('does not throw when aria-controls points to a nonexistent element', async () => {
      await setup(`
        <ol data-controller="timeline">
          <li>
            <h3>
              <button data-timeline-target="trigger"
                      data-action="timeline#toggle"
                      aria-expanded="false"
                      aria-controls="nonexistent-id">
                Event
              </button>
            </h3>
          </li>
        </ol>
      `);

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      expect(() => trigger.click()).not.toThrow();
      expect(trigger.getAttribute('aria-expanded')).toBe('true');
    });
  });

  describe('expand action', () => {
    it('expands item', async () => {
      await setup(`
        <ol data-controller="timeline">
          <li>
            <h3>
              <button data-timeline-target="trigger"
                      data-action="timeline#expand"
                      aria-expanded="false"
                      aria-controls="detail-3">
                Event
              </button>
            </h3>
            <div id="detail-3" data-timeline-target="detail" hidden>Detail</div>
          </li>
        </ol>
      `);

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      const detail = document.getElementById('detail-3');
      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(detail.hasAttribute('hidden')).toBe(false);
    });
  });

  describe('collapse action', () => {
    it('collapses item', async () => {
      await setup(`
        <ol data-controller="timeline">
          <li>
            <h3>
              <button data-timeline-target="trigger"
                      data-action="timeline#collapse"
                      aria-expanded="true"
                      aria-controls="detail-4">
                Event
              </button>
            </h3>
            <div id="detail-4" data-timeline-target="detail">Detail</div>
          </li>
        </ol>
      `);

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      const detail = document.getElementById('detail-4');
      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(detail.hasAttribute('hidden')).toBe(true);
    });
  });

  describe('events', () => {
    it('dispatches timeline:expand and timeline:expanded when expanding', async () => {
      await setup(buildHTML());

      const events = [];
      document.addEventListener('timeline:expand', (e) => events.push(e.type));
      document.addEventListener('timeline:expanded', (e) => events.push(e.type));

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      trigger.click();

      expect(events).toContain('timeline:expand');
      expect(events).toContain('timeline:expanded');
    });

    it('dispatches timeline:collapse and timeline:collapsed when collapsing', async () => {
      await setup(buildHTML({ expanded1: true }));

      const events = [];
      document.addEventListener('timeline:collapse', (e) => events.push(e.type));
      document.addEventListener('timeline:collapsed', (e) => events.push(e.type));

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      trigger.click();

      expect(events).toContain('timeline:collapse');
      expect(events).toContain('timeline:collapsed');
    });

    it('dispatches timeline:expanded with trigger and detail', async () => {
      await setup(buildHTML());

      let detail;
      document.addEventListener('timeline:expanded', (e) => { detail = e.detail; });

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      trigger.click();

      expect(detail.trigger).toBe(trigger);
      expect(detail.detail).toBe(document.getElementById('detail-1'));
    });

    it('dispatches timeline:collapsed with trigger and detail', async () => {
      await setup(buildHTML({ expanded1: true }));

      let detail;
      document.addEventListener('timeline:collapsed', (e) => { detail = e.detail; });

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      trigger.click();

      expect(detail.trigger).toBe(trigger);
      expect(detail.detail).toBe(document.getElementById('detail-1'));
    });
  });

  describe('triggerTargetConnected', () => {
    it('initializes aria-expanded="false" on triggers that lack it', async () => {
      await setup(buildHTML({ omitAriaExpanded: true }));

      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers.forEach((trigger) => {
        expect(trigger.getAttribute('aria-expanded')).toBe('false');
      });
    });

    it('does not overwrite an existing aria-expanded value', async () => {
      await setup(buildHTML({ expanded1: true, expanded2: false }));

      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      expect(triggers[0].getAttribute('aria-expanded')).toBe('true');
      expect(triggers[1].getAttribute('aria-expanded')).toBe('false');
    });
  });

  describe('dateFormatValue', () => {
    const FORMAT = JSON.stringify({ month: 'long', year: 'numeric', day: 'numeric', timeZone: 'UTC' });

    it('fills empty <time datetime> elements with formatted text', async () => {
      await setup(`
        <ol data-controller="timeline" data-timeline-date-format-value='${FORMAT}'>
          <time data-timeline-target="time" datetime="2024-01-15"></time>
        </ol>
      `);

      expect(document.querySelector('time').textContent.trim()).not.toBe('');
    });

    it('does not overwrite <time> elements that already have text content', async () => {
      await setup(`
        <ol data-controller="timeline" data-timeline-date-format-value='${FORMAT}'>
          <time datetime="2024-01-15">January 2024</time>
        </ol>
      `);

      expect(document.querySelector('time').textContent.trim()).toBe('January 2024');
    });

    it('skips formatting when dateFormatValue is empty', async () => {
      await setup(`
        <ol data-controller="timeline">
          <time datetime="2024-01-15"></time>
        </ol>
      `);

      expect(document.querySelector('time').textContent.trim()).toBe('');
    });
  });

  describe('keyboard navigation', () => {
    beforeEach(async () => {
      await setup(buildHTML());
    });

    it('ArrowDown moves focus to the next trigger', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].focus();
      triggers[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
      expect(document.activeElement).toBe(triggers[1]);
    });

    it('ArrowUp moves focus to the previous trigger', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[1].focus();
      triggers[1].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true }));
      expect(document.activeElement).toBe(triggers[0]);
    });

    it('ArrowDown on last trigger wraps to first', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[triggers.length - 1].focus();
      triggers[triggers.length - 1].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
      expect(document.activeElement).toBe(triggers[0]);
    });

    it('ArrowUp on first trigger wraps to last', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].focus();
      triggers[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowUp', bubbles: true }));
      expect(document.activeElement).toBe(triggers[triggers.length - 1]);
    });

    it('Home moves focus to first trigger', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[1].focus();
      triggers[1].dispatchEvent(new KeyboardEvent('keydown', { key: 'Home', bubbles: true }));
      expect(document.activeElement).toBe(triggers[0]);
    });

    it('End moves focus to last trigger', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].focus();
      triggers[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'End', bubbles: true }));
      expect(document.activeElement).toBe(triggers[triggers.length - 1]);
    });

    it('sets tabIndex=0 on first trigger and tabIndex=-1 on others', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      expect(triggers[0].tabIndex).toBe(0);
      expect(triggers[1].tabIndex).toBe(-1);
    });

    it('updates tabIndex when focus moves via keyboard', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].focus();
      triggers[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
      expect(triggers[0].tabIndex).toBe(-1);
      expect(triggers[1].tabIndex).toBe(0);
    });

    it('updates roving tabindex when a trigger disconnects', async () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].remove();
      await new Promise((resolve) => setTimeout(resolve, 10));
      // Only one trigger remains; it should have tabIndex=0
      const remaining = document.querySelector('[data-timeline-target="trigger"]');
      expect(remaining.tabIndex).toBe(0);
    });
  });

  describe('timeTargetConnected', () => {
    const FORMAT = JSON.stringify({ month: 'long', year: 'numeric', day: 'numeric', timeZone: 'UTC' });

    it('formats a <time> element added after connect', async () => {
      await setup(`
        <ol data-controller="timeline" data-timeline-date-format-value='${FORMAT}'>
        </ol>
      `);

      const ol = document.querySelector('ol');
      const time = document.createElement('time');
      time.setAttribute('datetime', '2024-06-01');
      time.setAttribute('data-timeline-target', 'time');
      ol.appendChild(time);

      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(time.textContent.trim()).not.toBe('');
    });

    it('does not format a <time> element that already has text', async () => {
      await setup(`
        <ol data-controller="timeline" data-timeline-date-format-value='${FORMAT}'>
        </ol>
      `);

      const ol = document.querySelector('ol');
      const time = document.createElement('time');
      time.setAttribute('datetime', '2024-06-01');
      time.setAttribute('data-timeline-target', 'time');
      time.textContent = 'June 2024';
      ol.appendChild(time);

      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(time.textContent.trim()).toBe('June 2024');
    });
  });
});
