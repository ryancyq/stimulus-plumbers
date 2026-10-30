import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import { morphElements } from '@hotwired/turbo';
import PasswordStrengthController from '../../../src/controllers/password_strength_controller';
import ProgressController from '../../../src/controllers/progress_controller';

const RULES = JSON.stringify([{ key: 'digit', pattern: '\\d', min: 1 }]);
const OPTIONS = JSON.stringify({ low: 34 });

describe('PasswordStrengthController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('password-strength', PasswordStrengthController);
    application.register('progress', ProgressController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
    vi.useRealTimers();
  });

  const mount = async (html) => {
    document.body.innerHTML = html;
    await new Promise((resolve) => setTimeout(resolve, 20));
  };

  const type = async (value) => {
    const input = document.querySelector('input');
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await new Promise((resolve) => setTimeout(resolve, 0));
  };

  const markup = ({ withMeter = true, icons = 'both' } = {}) => `
    <div data-controller="password-strength"
         data-password-strength-rules-value='${RULES}'
         data-password-strength-options-value='${OPTIONS}'
         data-password-strength-labels-value='{"weak":"Weak","fine":"Fine","strong":"Strong"}'
         ${withMeter ? 'data-password-strength-progress-outlet="#pw-meter"' : ''}>
      <input type="password" data-password-strength-target="input"
             data-action="input->password-strength#score">
      ${withMeter ? '<meter id="pw-meter" data-controller="progress" data-progress-target="meter" data-progress-variant-value="meter" min="0" max="100"></meter>' : ''}
      <p data-password-strength-target="level" aria-live="polite">Weak</p>
      <ul>
        <li data-password-strength-target="rule" data-rule="digit" data-satisfied="false">
          ${icons !== 'none' ? '<svg data-password-strength-target="checkIcon" hidden></svg>' : ''}
          ${icons === 'both' ? '<svg data-password-strength-target="closeIcon"></svg>' : ''}
          One number
        </li>
      </ul>
    </div>
  `;

  it('toggles data-satisfied and swaps the icon pair', async () => {
    await mount(markup());
    await type('abc1');

    const rule = document.querySelector('[data-rule="digit"]');
    expect(rule.dataset.satisfied).toBe('true');
    expect(rule.querySelector('[data-password-strength-target="checkIcon"]').hasAttribute('hidden')).toBe(false);
    expect(rule.querySelector('[data-password-strength-target="closeIcon"]').hasAttribute('hidden')).toBe(true);
  });

  it('keeps a lone icon visible but still flips data-satisfied', async () => {
    await mount(markup({ icons: 'check' }));
    await type('abc1');

    const rule = document.querySelector('[data-rule="digit"]');
    expect(rule.dataset.satisfied).toBe('true');
    expect(rule.querySelector('[data-password-strength-target="checkIcon"]').hasAttribute('hidden')).toBe(true);
  });

  it('pushes the computed value to the progress outlet', async () => {
    await mount(markup());
    await type('abcd1');

    const meter = document.querySelector('#pw-meter');
    const progress = application.getControllerForElementAndIdentifier(meter, 'progress');
    expect(progress.currentValue).toBe(100);
  });

  it('scores without error when no progress outlet is present', async () => {
    await mount(markup({ withMeter: false }));
    await expect(type('abcd1')).resolves.not.toThrow();
    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('true');
  });

  it('updates the level target only after the debounce', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    const input = document.querySelector('input');
    input.value = 'abcd1';
    input.dispatchEvent(new Event('input', { bubbles: true }));

    const level = document.querySelector('[data-password-strength-target="level"]');
    expect(level.textContent.trim()).toBe('Weak');

    await vi.advanceTimersByTimeAsync(700);
    expect(level.textContent.trim()).toBe('Strong');
  });

  it('does not re-announce when the score moves within a level', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    const input = document.querySelector('input');
    const level = document.querySelector('[data-password-strength-target="level"]');

    input.value = 'abcd1';
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await vi.advanceTimersByTimeAsync(700);
    expect(level.textContent.trim()).toBe('Strong');

    level.textContent = 'SENTINEL';
    input.value = 'abcde1';
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await vi.advanceTimersByTimeAsync(700);
    expect(level.textContent.trim()).toBe('SENTINEL');
  });

  it('writes the localized label, not the scorer token', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    const input = document.querySelector('input');
    input.value = 'abcd1';
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await vi.advanceTimersByTimeAsync(700);

    const level = document.querySelector('[data-password-strength-target="level"]');
    expect(level.textContent.trim()).toBe('Strong');
    expect(level.textContent.trim()).not.toBe('strong');
  });

  const levelMutations = () => {
    const level = document.querySelector('[data-password-strength-target="level"]');
    const records = [];
    new MutationObserver((list) => records.push(...list)).observe(level, {
      childList: true,
      characterData: true,
      subtree: true,
    });
    return records;
  };

  it('leaves a matching rendered label untouched on connect', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    const records = levelMutations();
    await vi.advanceTimersByTimeAsync(1000);

    expect(records).toHaveLength(0);
  });

  it('corrects a stale rendered label at connect without a later write', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup().replace('>Weak</p>', '>Strong</p>');
    const level = document.querySelector('[data-password-strength-target="level"]');
    await vi.advanceTimersByTimeAsync(20);
    expect(level.textContent.trim()).toBe('Weak');

    const records = levelMutations();
    await vi.advanceTimersByTimeAsync(1000);
    expect(records).toHaveLength(0);
  });

  it('does not rewrite the label when typing returns to the shown level within the delay', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);
    const records = levelMutations();

    const input = document.querySelector('input');
    for (const value of ['abcd1', 'abcd']) {
      input.value = value;
      input.dispatchEvent(new Event('input', { bubbles: true }));
    }
    await vi.advanceTimersByTimeAsync(1000);

    expect(records).toHaveLength(0);
  });

  it('shows the empty-password state before a Turbo snapshot', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    const input = document.querySelector('input');
    input.value = 'abcd1';
    input.dispatchEvent(new Event('input', { bubbles: true }));
    document.dispatchEvent(new Event('turbo:before-cache'));

    const level = document.querySelector('[data-password-strength-target="level"]');
    const rule = document.querySelector('[data-rule="digit"]');
    const progress = application.getControllerForElementAndIdentifier(document.querySelector('#pw-meter'), 'progress');
    expect(level.textContent.trim()).toBe('Weak');
    expect(rule.dataset.satisfied).toBe('false');
    expect(progress.currentValue).toBe(0);

    await vi.advanceTimersByTimeAsync(1000);
    expect(level.textContent.trim()).toBe('Weak');
  });

  it('ignores Turbo snapshots after disconnect', async () => {
    await mount(markup());
    await type('abcd1');
    const rule = document.querySelector('[data-rule="digit"]');

    rule.closest('[data-controller]').remove();
    await new Promise((resolve) => setTimeout(resolve, 0));
    document.dispatchEvent(new Event('turbo:before-cache'));

    expect(rule.dataset.satisfied).toBe('true');
  });

  it('re-scores when the rules change', async () => {
    await mount(markup());
    await type('abc');
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute(
      'data-password-strength-rules-value',
      JSON.stringify([{ key: 'digit', pattern: '\\d', min: 0 }])
    );
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('true');
    expect(document.querySelector('[data-password-strength-target="level"]').textContent.trim()).toBe('Strong');
  });

  it('re-scores when the options change', async () => {
    await mount(markup());
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute('data-password-strength-options-value', JSON.stringify({ low: 0 }));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(document.querySelector('[data-password-strength-target="level"]').textContent.trim()).toBe('Fine');
  });

  it('shows new label wording for the current level', async () => {
    await mount(markup());
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute(
      'data-password-strength-labels-value',
      JSON.stringify({ weak: 'Too weak', fine: 'Fine', strong: 'Strong' })
    );
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(document.querySelector('[data-password-strength-target="level"]').textContent.trim()).toBe('Too weak');
  });

  it('redraws the typed password after a morph resets the markup', async () => {
    await mount(markup());
    await type('abcd1');
    const element = document.querySelector('[data-controller="password-strength"]');
    const next = document.createElement('div');
    next.innerHTML = markup().replace(
      'data-action="input->password-strength#score"',
      'data-action="input->password-strength#score" value="abcd1"'
    );

    morphElements(element, next.querySelector('[data-controller="password-strength"]'));
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('true');
    expect(document.querySelector('[data-password-strength-target="level"]').textContent.trim()).toBe('Strong');
  });
});
