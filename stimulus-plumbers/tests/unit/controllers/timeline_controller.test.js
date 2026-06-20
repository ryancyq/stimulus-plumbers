import { describe, it, expect, beforeEach, afterEach } from 'vitest';
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
      <li data-timeline-target="item">
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
      <li data-timeline-target="item">
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

  describe('toggle', () => {
    it('expands a collapsed item', async () => {
      document.body.innerHTML = buildHTML({ expanded1: false });
      await new Promise(resolve => setTimeout(resolve, 10));

      const trigger = document.querySelectorAll('[data-timeline-target="trigger"]')[0];
      const detail = document.getElementById('detail-1');

      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(detail.hasAttribute('hidden')).toBe(false);
    });

    it('collapses an expanded item', async () => {
      document.body.innerHTML = buildHTML({ expanded1: true });
      await new Promise(resolve => setTimeout(resolve, 10));

      const trigger = document.querySelectorAll('[data-timeline-target="trigger"]')[0];
      const detail = document.getElementById('detail-1');

      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(detail.hasAttribute('hidden')).toBe(true);
    });
  });

  describe('expand action', () => {
    it('expands item', async () => {
      document.body.innerHTML = `
        <ol data-controller="timeline">
          <li data-timeline-target="item">
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
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      const detail = document.getElementById('detail-3');

      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('true');
      expect(detail.hasAttribute('hidden')).toBe(false);
    });
  });

  describe('collapse action', () => {
    it('collapses item', async () => {
      document.body.innerHTML = `
        <ol data-controller="timeline">
          <li data-timeline-target="item">
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
      `;
      await new Promise(resolve => setTimeout(resolve, 10));

      const trigger = document.querySelector('[data-timeline-target="trigger"]');
      const detail = document.getElementById('detail-4');

      trigger.click();

      expect(trigger.getAttribute('aria-expanded')).toBe('false');
      expect(detail.hasAttribute('hidden')).toBe(true);
    });
  });

  describe('connect', () => {
    it('initializes aria-expanded="false" on triggers that lack it', async () => {
      document.body.innerHTML = buildHTML({ omitAriaExpanded: true });
      await new Promise(resolve => setTimeout(resolve, 10));

      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers.forEach((trigger) => {
        expect(trigger.getAttribute('aria-expanded')).toBe('false');
      });
    });

    it('does NOT overwrite existing aria-expanded value', async () => {
      document.body.innerHTML = buildHTML({ expanded1: true, expanded2: false });
      await new Promise(resolve => setTimeout(resolve, 10));

      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      expect(triggers[0].getAttribute('aria-expanded')).toBe('true');
      expect(triggers[1].getAttribute('aria-expanded')).toBe('false');
    });
  });

  describe('keyboard navigation', () => {
    beforeEach(async () => {
      document.body.innerHTML = buildHTML();
      await new Promise(resolve => setTimeout(resolve, 10));
    });

    it('ArrowDown moves focus to next trigger', () => {
      const triggers = document.querySelectorAll('[data-timeline-target="trigger"]');
      triggers[0].focus();
      triggers[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true }));
      expect(document.activeElement).toBe(triggers[1]);
    });

    it('ArrowUp moves focus to previous trigger', () => {
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
  });
});
