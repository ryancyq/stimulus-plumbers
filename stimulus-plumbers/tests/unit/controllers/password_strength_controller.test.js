import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
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
});
