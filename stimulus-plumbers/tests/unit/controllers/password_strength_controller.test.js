import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { morphElements } from '@hotwired/turbo';
import PasswordStrengthController from '../../../src/controllers/password_strength_controller';
import ProgressController from '../../../src/controllers/progress_controller';
import { flush, startApplication } from '../../support/stimulus';

const RULES = JSON.stringify([{ key: 'digit', pattern: '\\d', min: 1 }]);
const OPTIONS = JSON.stringify({ low: 34 });

describe('PasswordStrengthController', () => {
  beforeEach(() => {
    startApplication({ 'password-strength': PasswordStrengthController, progress: ProgressController });
  });

  afterEach(() => {
    document.body.innerHTML = '';
    vi.useRealTimers();
  });

  const mount = async (html) => {
    document.body.innerHTML = html;
    await flush();
  };

  const type = async (value) => {
    const input = document.querySelector('input');
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await flush();
  };

  const markup = ({ withMeter = true, icons = 'both' } = {}) => `
    <div data-controller="password-strength"
         data-password-strength-rules-value='${RULES}'
         data-password-strength-options-value='${OPTIONS}'
         data-password-strength-labels-value='{"weak":"Weak","fine":"Fine","strong":"Strong"}'>
      <input type="password" data-password-strength-target="input"
             data-action="input->password-strength#score">
      ${withMeter ? '<meter data-controller="progress" data-progress-target="meter" data-password-strength-target="meter" data-progress-variant-value="meter" data-progress-current-value="0" min="0" max="100" value="0"></meter>' : ''}
      <p data-password-strength-target="level">Weak</p>
      <ul>
        <li data-password-strength-target="rule" data-rule="digit" data-satisfied="false">
          ${icons !== 'none' ? '<svg data-password-strength-target="checkIcon" hidden></svg>' : ''}
          ${icons === 'both' ? '<svg data-password-strength-target="closeIcon"></svg>' : ''}
          One number
        </li>
      </ul>
    </div>
  `;

  const level = () => document.querySelector('[data-password-strength-target="level"]');
  const announced = () => document.querySelector('[data-live-region="polite"]')?.textContent ?? null;

  const typeNow = (value) => {
    const input = document.querySelector('input');
    input.value = value;
    input.dispatchEvent(new Event('input', { bubbles: true }));
  };

  const mutationsOf = (element) => {
    const records = [];
    new MutationObserver((list) => records.push(...list)).observe(element, {
      attributes: true,
      childList: true,
      characterData: true,
      subtree: true,
    });
    return records;
  };

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

  it('drives the meter through its current-value attribute', async () => {
    await mount(markup());
    const meter = document.querySelector('meter');

    await type('abcd1');
    await flush();

    expect(meter.dataset.progressCurrentValue).toBe('100');
    expect(meter.value).toBe(100);
  });

  it('scores without error when no meter is present', async () => {
    await mount(markup({ withMeter: false }));
    await expect(type('abcd1')).resolves.not.toThrow();
    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('true');
  });

  it('shows the level at once and announces it after a pause in typing', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    typeNow('abcd1');

    expect(level().textContent.trim()).toBe('Strong');
    expect(announced()).toBe(null);
    await vi.advanceTimersByTimeAsync(800);
    expect(announced()).toBe('Strong');
  });

  it('does not announce when the score moves within a level', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);
    typeNow('abcd1');
    await vi.advanceTimersByTimeAsync(800);
    document.querySelector('[data-live-region="polite"]').textContent = 'SENTINEL';

    typeNow('abcde1');
    await vi.advanceTimersByTimeAsync(800);

    expect(announced()).toBe('SENTINEL');
  });

  it('does not announce when typing returns to the shown level within the delay', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    typeNow('abcd1');
    typeNow('abcd');
    await vi.advanceTimersByTimeAsync(800);

    expect(level().textContent.trim()).toBe('Weak');
    expect(announced()).toBe(null);
  });

  it('shows and announces the localized label, not the scorer token', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);

    typeNow('abcd1');
    await vi.advanceTimersByTimeAsync(800);

    expect(level().textContent.trim()).toBe('Strong');
    expect(announced()).toBe('Strong');
  });

  it('writes nothing on connect over matching markup', async () => {
    document.body.innerHTML = markup();
    const records = mutationsOf(document.querySelector('[data-controller="password-strength"]'));

    await flush();

    expect(records.filter((record) => record.target.tagName !== 'METER')).toHaveLength(0);
  });

  it('redraws stale markup on connect without announcing', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup()
      .replace('>Weak</p>', '>Strong</p>')
      .replace('data-satisfied="false"', 'data-satisfied="true"');

    await vi.advanceTimersByTimeAsync(1000);

    expect(level().textContent.trim()).toBe('Weak');
    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('false');
    expect(announced()).toBe(null);
  });

  it('drops the pending announcement when a morph clears the password', async () => {
    vi.useFakeTimers();
    document.body.innerHTML = markup();
    await vi.advanceTimersByTimeAsync(20);
    const element = document.querySelector('[data-controller="password-strength"]');
    const next = document.createElement('div');
    next.innerHTML = markup();

    typeNow('abcd1');
    morphElements(element, next.querySelector('[data-controller="password-strength"]'));
    await vi.advanceTimersByTimeAsync(1000);

    expect(document.querySelector('input').value).toBe('');
    expect(level().textContent.trim()).toBe('Weak');
    expect(announced()).toBe(null);
  });

  it('re-scores when the rules change', async () => {
    await mount(markup());
    await type('abc');
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute(
      'data-password-strength-rules-value',
      JSON.stringify([{ key: 'digit', pattern: '\\d', min: 0 }])
    );
    await flush();

    expect(document.querySelector('[data-rule="digit"]').dataset.satisfied).toBe('true');
    expect(level().textContent.trim()).toBe('Strong');
  });

  it('re-scores when the options change', async () => {
    await mount(markup());
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute('data-password-strength-options-value', JSON.stringify({ low: 0 }));
    await flush();

    expect(level().textContent.trim()).toBe('Fine');
  });

  it('shows new label wording for the current level', async () => {
    await mount(markup());
    const element = document.querySelector('[data-controller="password-strength"]');

    element.setAttribute(
      'data-password-strength-labels-value',
      JSON.stringify({ weak: 'Too weak', fine: 'Fine', strong: 'Strong' })
    );
    await flush();

    expect(level().textContent.trim()).toBe('Too weak');
  });
});
