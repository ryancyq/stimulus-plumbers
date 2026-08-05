# Password Strength Meter + Test Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a live password strength meter with an accessible rules checklist, then give the password field dedicated a11y and visual-snapshot coverage.

**Architecture:** Scoring is a pure function in a JS plumber (no DOM); a Stimulus controller applies the result to the DOM and drives an existing `progress` controller through an outlet. Rails renders the whole wired structure from a `Plumber::Config` block DSL, so callers never hand-wire ids, outlet selectors, or `aria-describedby`.

**Tech Stack:** Stimulus 3, Vitest, Ruby/Rails (minitest), Capybara + axe-core, Playwright, Tailwind 4.

## Global Constraints

- Specs: `docs/superpowers/specs/2026-07-20-password-strength-meter-design.md`, then `docs/superpowers/specs/2026-07-20-password-test-coverage-design.md`. Read both before starting.
- Branch: `feature/password-strength`. Commit with `--no-gpg-sign` — signing fails in this environment.
- **Never `I18n.t(...)` in tests.** Assert literal English strings copied from `config/locales/en.yml`.
- **Icon names must be generic** (`check`, `close`) — the rails sandbox runs unthemed and heroicon compound names do not resolve.
- **Use `setHidden` from `accessibility/aria.js`, never `element.hidden`.** Icons render as `<svg>`, which has no `hidden` property; assignment silently no-ops. Test fixtures must use `<svg>`, not `<span>`, or they will not catch the regression.
- **Icon pairs are all-or-nothing.** Swap only when both icons are present, so a lone icon stays visible.
- `progress_controller.js` and `Components::ProgressMeter` are **reused unchanged**. Do not modify either.
- Rubocop runs synchronously from `stimulus-plumbers-rails/`: `bundle exec rake rubocop`. Never background it.
- `Style/EndlessMethod: disallow` — no `def x = y` anywhere in `lib/`.
- Rails theme keys render as no-ops in Base; Tailwind supplies the actual classes.

---

## File Structure

**`stimulus-plumbers` (JS)**
- Create `src/plumbers/password_strength.js` — scoring registry + default `RulesScorer` + `attachPasswordStrength`. No DOM.
- Create `src/controllers/password_strength_controller.js` — DOM only; reads value, applies rules, drives outlet, debounces announcement.
- Modify `src/index.js` — export both.
- Modify `README.md` — one Utilities row, one Controllers row.
- Create `tests/unit/plumbers/password_strength.test.js`, `tests/unit/controllers/password_strength_controller.test.js`.
- Create `docs/component/password_strength.md`, `docs/plumber/password_strength.md`.

**`stimulus-plumbers-rails`**
- Modify `lib/stimulus_plumbers/form/fields/inputs/password/config.rb` — add `strength` / `rule` / lazy merge.
- Modify `lib/stimulus_plumbers/form/fields/inputs/password.rb` — render meter, level, rules; wire ids.
- Modify `lib/stimulus_plumbers/themes/schema.rb` — five new FORM keys.
- Modify `config/locales/en.yml` — rule labels and level names.
- Modify `test/stimulus_plumbers/form/fields/inputs/password_test.rb`.
- Create `test/sandbox/app/views/form/password.html.erb`, route, controller action.
- Create `test/accessibility/form/password_accessibility_test.rb`.
- Modify `test/accessibility/form/form_accessibility_test.rb` — remove one test.
- Modify `docs/component/form.md`, `CLAUDE.md`.

**`stimulus-plumbers-tailwind`**
- Create sandbox page + route + controller action (mirroring rails).
- Create `test/snapshots/password.spec.js`.
- Modify `test/snapshots/form.spec.js` — remove two tests.
- Add theme classes for the five new keys.

---

## Task 1: Scoring plumber

**Files:**
- Create: `stimulus-plumbers/src/plumbers/password_strength.js`
- Test: `stimulus-plumbers/tests/unit/plumbers/password_strength.test.js`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `score(password, options) → { value: Number, level: 'weak'|'fine'|'strong', rules: { [key]: Boolean } }`
  - `PasswordStrength.register(type, scorer)` — scorer is `{ score(pw, opts) }`
  - `attachPasswordStrength(controller, options)` — defines a `strength` getter on `controller` returning `{ score }`
  - Option keys (camelCase): `minLength`, `maxLength`, `uppercase`, `lowercase`, `digit`, `symbol`, `low`, `high`
  - `RULE_KEYS = ['length', 'uppercase', 'lowercase', 'digit', 'symbol']`
  - Threshold defaults: `low: 34`, `high: 100` — `high` colors the `<meter>` only; `RulesScorer` derives `strong` from all-rules-satisfied and ignores it

- [ ] **Step 1: Write the failing test**

Create `stimulus-plumbers/tests/unit/plumbers/password_strength.test.js`:

```js
import { describe, it, expect } from 'vitest';
import { PasswordStrength, attachPasswordStrength, RULE_KEYS } from '../../../src/plumbers/password_strength';

const score = (pw, opts) => {
  const controller = {};
  attachPasswordStrength(controller, { options: opts });
  return controller.strength.score(pw, opts);
};

describe('RulesScorer', () => {
  it('evaluates length against minLength', () => {
    expect(score('abc', { minLength: 5 }).rules.length).toBe(false);
    expect(score('abcde', { minLength: 5 }).rules.length).toBe(true);
  });

  it('evaluates length against maxLength', () => {
    expect(score('abcdef', { minLength: 2, maxLength: 5 }).rules.length).toBe(false);
    expect(score('abcd', { minLength: 2, maxLength: 5 }).rules.length).toBe(true);
  });

  it('evaluates character-class rules', () => {
    const opts = { uppercase: true, lowercase: true, digit: true, symbol: true };
    const rules = score('Ab1!', opts).rules;
    expect(rules).toEqual({ uppercase: true, lowercase: true, digit: true, symbol: true });
  });

  it('only evaluates enabled rules', () => {
    expect(Object.keys(score('abc', { digit: true }).rules)).toEqual(['digit']);
  });

  it('scores 0 when nothing is satisfied and 100 when everything is', () => {
    const opts = { minLength: 4, uppercase: true, digit: true };
    expect(score('', opts).value).toBe(0);
    expect(score('Abcd1', opts).value).toBe(100);
  });

  it('maps level around low with default thresholds', () => {
    const opts = { minLength: 1, uppercase: true, digit: true };
    expect(score('a', opts).level).toBe('weak');
    expect(score('aB', opts).level).toBe('fine');
    expect(score('aB1', opts).level).toBe('strong');
  });

  it('is not strong while any rule is unsatisfied', () => {
    const configs = [
      { opts: { minLength: 1, uppercase: true, digit: true }, almost: 'aB' },
      { opts: { minLength: 1, uppercase: true, lowercase: true, digit: true }, almost: 'aB' },
      { opts: { minLength: 1, uppercase: true, lowercase: true, digit: true, symbol: true }, almost: 'aB1' },
    ];

    configs.forEach(({ opts, almost }) => {
      const result = score(almost, opts);
      expect(Object.values(result.rules).filter((ok) => !ok)).toHaveLength(1);
      expect(result.level).toBe('fine');
    });
  });

  it('raises low to move the unsatisfied end into weak', () => {
    const opts = { minLength: 1, uppercase: true, digit: true, low: 70 };
    expect(score('aB', opts).level).toBe('weak');
    expect(score('aB1', opts).level).toBe('strong');
  });

  it('exposes the known rule keys', () => {
    expect(RULE_KEYS).toEqual(['length', 'uppercase', 'lowercase', 'digit', 'symbol']);
  });
});

describe('registry', () => {
  it('prefers a registered scorer', () => {
    PasswordStrength.register('entropy', { score: () => ({ value: 42, level: 'fine', rules: {} }) });
    const controller = {};
    attachPasswordStrength(controller, { type: 'entropy' });
    expect(controller.strength.score('x', {}).value).toBe(42);
  });

  it('falls back to rules for an unknown type', () => {
    const controller = {};
    attachPasswordStrength(controller, { type: 'nope' });
    expect(controller.strength.score('abcd', { minLength: 4 }).value).toBe(100);
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/password_strength.test.js`
Expected: FAIL — `Failed to resolve import ".../password_strength"`

- [ ] **Step 3: Write the implementation**

Create `stimulus-plumbers/src/plumbers/password_strength.js`:

```js
import Plumber from './plumber';

export const STRENGTH_TYPES = {
  RULES: 'rules',
};

export const RULE_KEYS = ['length', 'uppercase', 'lowercase', 'digit', 'symbol'];

export const STRENGTH_LEVELS = {
  WEAK: 'weak',
  FINE: 'fine',
  STRONG: 'strong',
};

const defaultThresholds = { low: 34 };

const matchers = {
  uppercase: /[A-Z]/,
  lowercase: /[a-z]/,
  digit: /\d/,
  symbol: /[^A-Za-z0-9]/,
};

// A rule is evaluated only when enabled: `length` by either bound, the rest by a truthy flag.
const enabledRules = (options) =>
  RULE_KEYS.filter((key) =>
    key === 'length' ? options.minLength != null || options.maxLength != null : !!options[key]
  );

const satisfies = (key, password, options) => {
  if (key === 'length') {
    const min = options.minLength ?? 0;
    const max = options.maxLength ?? Infinity;
    return password.length >= min && password.length <= max;
  }
  return matchers[key].test(password);
};

// Strong requires every rule: "one missing" clears any fixed high (2/3=67, 3/4=75, 4/5=80).
const levelFor = (satisfied, total, options) => {
  if (total > 0 && satisfied === total) return STRENGTH_LEVELS.STRONG;

  const value = total === 0 ? 0 : Math.round((satisfied / total) * 100);
  const low = options.low ?? defaultThresholds.low;
  return value < low ? STRENGTH_LEVELS.WEAK : STRENGTH_LEVELS.FINE;
};

export const RulesScorer = {
  score(password, options = {}) {
    const value = typeof password === 'string' ? password : '';
    const keys = enabledRules(options);
    const rules = keys.reduce((acc, key) => {
      acc[key] = satisfies(key, value, options);
      return acc;
    }, {});

    const satisfied = keys.filter((key) => rules[key]).length;
    const score = keys.length === 0 ? 0 : Math.round((satisfied / keys.length) * 100);

    return { value: score, level: levelFor(satisfied, keys.length, options), rules };
  },
};

const registry = new Map([[STRENGTH_TYPES.RULES, RulesScorer]]);

export class PasswordStrength extends Plumber {
  static register(type, scorer) {
    registry.set(type, scorer);
  }

  constructor(controller, options = {}) {
    super(controller, options);
    this.type = options.type ?? STRENGTH_TYPES.RULES;
    this.enhance();
  }

  enhance() {
    const scorer = registry.get(this.type) ?? registry.get(STRENGTH_TYPES.RULES);
    const helpers = {
      score: (password, options) => scorer.score(password, options ?? {}),
    };

    Object.defineProperty(this.controller, 'strength', {
      get() {
        return helpers;
      },
      configurable: true,
    });
  }
}

export const attachPasswordStrength = (controller, options) => new PasswordStrength(controller, options);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/plumbers/password_strength.test.js`
Expected: PASS, 8 tests

- [ ] **Step 5: Lint and format**

Run: `cd stimulus-plumbers && npm run lint && npm run format:check`
Expected: no errors. If format fails, run `npm run format:write`.

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers/src/plumbers/password_strength.js stimulus-plumbers/tests/unit/plumbers/password_strength.test.js
git commit --no-gpg-sign -m "feat(js): password strength scoring plumber"
```

---

## Task 2: Strength controller

**Files:**
- Create: `stimulus-plumbers/src/controllers/password_strength_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/password_strength_controller.test.js`

**Interfaces:**
- Consumes: `attachPasswordStrength` from Task 1; `setHidden` from `../accessibility/aria`; `Requestor` from `../requestor`.
- Produces: controller identifier `password-strength`; targets `input`, `rule`, `level`, `checkIcon`, `closeIcon`; outlet `progress`; values `scorer` (String, default `'rules'`), `options` (Object, default `{}`), `announceDelay` (Number, default `700`); action method `score()`.
- Each `rule` target carries `data-rule="<key>"` and receives `data-satisfied="true|false"`. Icons are located **within** each rule target via `[data-password-strength-target="checkIcon"]` / `closeIcon`.

- [ ] **Step 1: Write the failing test**

Create `stimulus-plumbers/tests/unit/controllers/password_strength_controller.test.js`:

```js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import PasswordStrengthController from '../../../src/controllers/password_strength_controller';
import ProgressController from '../../../src/controllers/progress_controller';

const OPTIONS = JSON.stringify({ minLength: 4, digit: true, low: 34, high: 67 });

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

  // Icons are <svg> on purpose: they have no `hidden` property, so a regression
  // to `element.hidden = x` silently no-ops and only an <svg> fixture catches it.
  const markup = ({ withMeter = true, icons = 'both' } = {}) => `
    <div data-controller="password-strength"
         data-password-strength-options-value='${OPTIONS}'
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
    expect(level.textContent.trim()).toBe('strong');
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
    expect(level.textContent.trim()).toBe('strong');

    level.textContent = 'SENTINEL';
    input.value = 'abcde1';
    input.dispatchEvent(new Event('input', { bubbles: true }));
    await vi.advanceTimersByTimeAsync(700);
    expect(level.textContent.trim()).toBe('SENTINEL');
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/password_strength_controller.test.js`
Expected: FAIL — cannot resolve `password_strength_controller`

- [ ] **Step 3: Write the implementation**

Create `stimulus-plumbers/src/controllers/password_strength_controller.js`:

```js
import { Controller } from '@hotwired/stimulus';
import { setHidden } from '../accessibility/aria';
import { attachPasswordStrength } from '../plumbers/password_strength';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['input', 'rule', 'level', 'checkIcon', 'closeIcon'];
  static outlets = ['progress'];
  static values = {
    scorer: { type: String, default: 'rules' },
    options: { type: Object, default: {} },
    announceDelay: { type: Number, default: 700 },
  };

  connect() {
    this._requestor = new Requestor();
    this._level = null;
    attachPasswordStrength(this, { type: this.scorerValue });
    this.score();
  }

  disconnect() {
    this._requestor?.cancel();
  }

  score() {
    const { value, level, rules } = this.strength.score(this.readValue(), this.optionsValue);

    if (this.hasProgressOutlet) this.progressOutlet.setValue(value);
    this.drawRules(rules);
    this.announce(level);
  }

  readValue() {
    return this.hasInputTarget ? this.inputTarget.value : '';
  }

  drawRules(rules) {
    this.ruleTargets.forEach((target) => {
      const satisfied = !!rules[target.dataset.rule];
      target.dataset.satisfied = String(satisfied);
      this.drawIcons(target, satisfied);
    });
  }

  // Icons swap as a pair; a lone icon stays visible rather than emptying the row.
  drawIcons(target, satisfied) {
    const check = target.querySelector('[data-password-strength-target="checkIcon"]');
    const close = target.querySelector('[data-password-strength-target="closeIcon"]');
    if (!check || !close) return;

    setHidden(check, !satisfied);
    setHidden(close, satisfied);
  }

  // Debounced, and only on change: a live region firing every keystroke interrupts
  // the screen reader's echo of the character just typed.
  announce(level) {
    if (level === this._level) return;

    this._level = level;
    if (!this.hasLevelTarget) return;

    this._requestor.schedule(() => {
      this.levelTarget.textContent = level;
    }, this.announceDelayValue);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/password_strength_controller.test.js`
Expected: PASS, 6 tests

Note: `connect()` calls `score()` once, which sets `_level` to the empty-password level (`weak`) without announcing a change. The first real level change therefore announces correctly.

- [ ] **Step 5: Run the full JS suite**

Run: `cd stimulus-plumbers && npm test`
Expected: all pass, no regressions.

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers/src/controllers/password_strength_controller.js stimulus-plumbers/tests/unit/controllers/password_strength_controller.test.js
git commit --no-gpg-sign -m "feat(js): password strength controller"
```

---

## Task 3: Export and document the JS

**Files:**
- Modify: `stimulus-plumbers/src/index.js`
- Modify: `stimulus-plumbers/README.md`
- Create: `stimulus-plumbers/docs/component/password_strength.md`
- Create: `stimulus-plumbers/docs/plumber/password_strength.md`

**Interfaces:**
- Consumes: Task 1 and Task 2 exports.
- Produces: `PasswordStrengthController`, `PasswordStrength`, `attachPasswordStrength`, `STRENGTH_TYPES` from the package root.

- [ ] **Step 1: Add the exports**

In `src/index.js`, beside the existing plumber exports (line ~18):

```js
export { PasswordStrength, attachPasswordStrength, STRENGTH_TYPES, RULE_KEYS } from './plumbers/password_strength.js';
```

And in the alphabetical controller block, after `PannerController`:

```js
export { default as PasswordStrengthController } from './controllers/password_strength_controller.js';
```

- [ ] **Step 2: Verify the export names resolve**

Run: `cd stimulus-plumbers && node --input-type=module -e "import('./src/index.js').then(m => console.log(!!m.PasswordStrengthController, !!m.attachPasswordStrength))"`
Expected: `true true`

- [ ] **Step 3: Add README rows**

Per the Doc Update Rule, add one row to the Controllers table and one to the Utilities table. Match surrounding row formatting exactly. The Controllers row links to `docs/component/password_strength.md`; the Utilities row to `docs/plumber/password_strength.md`.

- [ ] **Step 4: Write the two docs**

`docs/plumber/password_strength.md` owns the scorer contract, `RULE_KEYS`, option keys, level derivation, and `register`. `docs/component/password_strength.md` owns targets, values, outlets, actions, and events — and links to the plumber doc rather than restating the contract. Keep both concise: one-line bullets.

- [ ] **Step 5: Rebuild the manifest**

Run: `cd stimulus-plumbers && node --run build:manifest`
Expected: manifest regenerates and includes `password-strength`.

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers/src/index.js stimulus-plumbers/README.md stimulus-plumbers/docs stimulus-plumbers/dist
git commit --no-gpg-sign -m "docs(js): export and document password strength"
```

---

## Task 4: Theme keys and locale

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/config/locales/en.yml`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/themes/base/form_test.rb`

**Interfaces:**
- Produces: theme keys `password_strength_wrapper`, `password_strength_rules`, `password_strength_rule`, `password_strength_rule_icon`, `password_strength_level`; locale keys under `stimulus_plumbers.form.password`.
- `password_strength_rule` takes a `satisfied:` boolean variant so themes can style from it; the rest take no variants.

- [ ] **Step 1: Write the failing test**

Add to `test/stimulus_plumbers/themes/base/form_test.rb`:

```ruby
def test_password_strength_keys_resolve_to_no_ops
  %i[
    password_strength_wrapper password_strength_rules
    password_strength_rule_icon password_strength_level
  ].each do |key|
    assert_empty theme.resolve(key)
  end
end

def test_password_strength_rule_accepts_satisfied_variant
  assert_empty theme.resolve(:password_strength_rule, satisfied: true)
  assert_empty theme.resolve(:password_strength_rule, satisfied: false)
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/stimulus_plumbers/themes/base/form_test.rb`
Expected: FAIL — unknown theme key

- [ ] **Step 3: Add the schema keys**

In `lib/stimulus_plumbers/themes/schema.rb`, inside the `FORM` hash, after `form_field_input_file`:

```ruby
password_strength_wrapper:              {}.freeze,
password_strength_rules:                {}.freeze,
password_strength_rule:                 {
  satisfied: { default: false, validate: Ranges::BOOL }
}.freeze,
password_strength_rule_icon:            {}.freeze,
password_strength_level:                {}.freeze,
```

- [ ] **Step 4: Add the locale keys**

In `config/locales/en.yml`, under `stimulus_plumbers.form.password` (which already has `show` / `hide`):

```yaml
        rules:
          length: "At least %{count} characters"
          uppercase: "One uppercase letter"
          lowercase: "One lowercase letter"
          digit: "One number"
          symbol: "One symbol"
        levels:
          weak: "Weak"
          fine: "Fine"
          strong: "Strong"
```

- [ ] **Step 5: Run tests and rubocop**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit && bundle exec rake rubocop`
Expected: all pass, no offenses.

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb stimulus-plumbers-rails/config/locales/en.yml stimulus-plumbers-rails/test/stimulus_plumbers/themes/base/form_test.rb
git commit --no-gpg-sign -m "feat(rails): password strength theme keys and locale"
```

---

## Task 5: `Password::Config` DSL

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/password/config.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/form/fields/inputs/password_config_test.rb` (create)

**Interfaces:**
- Consumes: `Plumber::Config` — `configure(name, value)`, `config(name)`, `configured?(name)`, all **private**.
- Produces on `Password::Config`:
  - `strength(**options)` → nil
  - `rule(key, label)` → nil; raises `ArgumentError` for keys outside `RULE_KEYS`
  - `strength?` → Boolean
  - `strength_options` → Hash (`{}` when unset)
  - `rules` → ordered Hash `{ key => label }`, derived lazily then merged
  - `thresholds` → `{ low:, high:, optimum: }` with defaults `34 / 100 / 100` — `high: 100` keeps the meter's top band aligned with the JS `strong` level (all rules satisfied)
  - `RULE_KEYS = %i[length uppercase lowercase digit symbol].freeze`

**Critical semantics:** rules merge **at read**, not at write, so `p.rule` before or after `p.strength` gives the same result. An override keeps the derived row's position; a genuinely new key is appended last.

- [ ] **Step 1: Write the failing test**

Create `test/stimulus_plumbers/form/fields/inputs/password_config_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class FormFieldsPasswordConfigTest < ActiveSupport::TestCase
  Config = StimulusPlumbers::Form::Fields::Inputs::Password::Config

  def test_no_strength_by_default
    config = Config.new

    assert_not config.strength?
    assert_empty config.rules
  end

  def test_strength_derives_default_rules_from_its_options
    config = Config.new
    config.strength min_length: 12, digit: true

    assert_predicate config, :strength?
    assert_equal %i[length digit], config.rules.keys
    assert_equal "At least 12 characters", config.rules[:length]
    assert_equal "One number", config.rules[:digit]
  end

  def test_rule_overrides_a_derived_label_in_place
    config = Config.new
    config.strength min_length: 12, digit: true, symbol: true
    config.rule :digit, "Must contain a number"

    assert_equal %i[length digit symbol], config.rules.keys
    assert_equal "Must contain a number", config.rules[:digit]
  end

  def test_rule_is_order_independent
    before = Config.new
    before.rule :digit, "Custom"
    before.strength min_length: 8, digit: true

    after = Config.new
    after.strength min_length: 8, digit: true
    after.rule :digit, "Custom"

    assert_equal after.rules, before.rules
  end

  def test_a_rule_key_not_derived_is_appended_last
    config = Config.new
    config.strength min_length: 8
    config.rule :symbol, "One symbol"

    assert_equal %i[length symbol], config.rules.keys
  end

  def test_rule_rejects_an_unknown_key
    error = assert_raises(ArgumentError) { Config.new.rule(:bogus, "Nope") }

    assert_equal "unknown rule key: :bogus (known keys: :length, :uppercase, :lowercase, :digit, :symbol)",
                 error.message
  end

  def test_thresholds_default_and_override
    assert_equal({ low: 34, high: 100, optimum: 100 }, Config.new.thresholds)

    config = Config.new
    config.strength low: 20, high: 80

    assert_equal({ low: 20, high: 80, optimum: 100 }, config.thresholds)
  end

  def test_setters_return_nil
    config = Config.new

    assert_nil config.strength(min_length: 8)
    assert_nil config.rule(:digit, "One number")
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_config_test.rb`
Expected: FAIL — `undefined method 'rule'`

- [ ] **Step 3: Write the implementation**

Replace `lib/stimulus_plumbers/form/fields/inputs/password/config.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          # Yielded to `f.field :password, as: :password` blocks — collects
          # configuration only, renders nothing.
          class Config < Plumber::Config
            RULE_KEYS = %i[length uppercase lowercase digit symbol].freeze

            DEFAULT_THRESHOLDS = { low: 34, high: 100, optimum: 100 }.freeze

            # Fallbacks for the I18n lookup, so an app with no locale file still renders labels.
            DEFAULT_LABELS = {
              length:    "At least %{count} characters",
              uppercase: "One uppercase letter",
              lowercase: "One lowercase letter",
              digit:     "One number",
              symbol:    "One symbol"
            }.freeze

            def strength(**options)
              configure(:strength, options)
            end

            def rule(key, label)
              key = key.to_sym
              raise ArgumentError, unknown_rule_message(key) unless RULE_KEYS.include?(key)

              configure(:rules, overrides.merge(key => label))
            end

            def strength?
              configured?(:strength)
            end

            def strength_options
              config(:strength) || {}
            end

            # Derived lazily so `rule` and `strength` are order-independent: deriving at
            # write time would let a `rule` written first be clobbered by a later `strength`.
            # Overrides merge onto derived keys in place; new keys append last.
            def rules
              return {} unless strength?

              derived_rules.merge(overrides)
            end

            def thresholds
              DEFAULT_THRESHOLDS.merge(strength_options.slice(*DEFAULT_THRESHOLDS.keys))
            end

            private

            def overrides
              config(:rules) || {}
            end

            def derived_rules
              options = strength_options
              RULE_KEYS.each_with_object({}) do |key, acc|
                next unless derived?(key, options)

                acc[key] = default_label(key, options)
              end
            end

            def derived?(key, options)
              key == :length ? options.key?(:min_length) || options.key?(:max_length) : !!options[key]
            end

            def default_label(key, options)
              I18n.t(
                "stimulus_plumbers.form.password.rules.#{key}",
                count:   options[:min_length],
                default: DEFAULT_LABELS.fetch(key)
              )
            end

            def unknown_rule_message(key)
              "unknown rule key: #{key.inspect} (known keys: #{RULE_KEYS.map(&:inspect).join(', ')})"
            end
          end
        end
      end
    end
  end
end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_config_test.rb`
Expected: PASS, 8 tests

- [ ] **Step 5: Mutation-test the lazy merge**

Temporarily change `rules` to derive eagerly inside `strength` (populate `:rules` there). Run the suite; `test_rule_is_order_independent` must FAIL. Revert. A lazy merge no test notices is not covered.

- [ ] **Step 6: Run rubocop and commit**

```bash
cd stimulus-plumbers-rails && bundle exec rake rubocop
git add stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/password/config.rb stimulus-plumbers-rails/test/stimulus_plumbers/form/fields/inputs/password_config_test.rb
git commit --no-gpg-sign -m "feat(rails): password strength config DSL"
```

---

## Task 6: Render the strength UI

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/password.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/form/fields/inputs/password_test.rb`

**Interfaces:**
- Consumes: `Password::Config` from Task 5; `Components::ProgressMeter#render(value:, min:, max:, low:, high:, optimum:, **kwargs)` — `render` is the public forwarder; `render_meter` is private, do not call it; `Components::Icon#render(name, ...)`; `Form::Base#described_by`.
- Produces: rendered structure per the spec — wrapper carrying `data-controller="password-strength"`, options JSON, and `data-password-strength-progress-outlet="#<input_id>_meter"`; `<meter id="<input_id>_meter">`; level `<p>`; `<ul id="<input_id>_rules">`.
- **Option keys are camelCased into the JSON** (`min_length` → `minLength`). Thresholds appear in both the JSON and as `<meter>` attributes, from `config.thresholds`.
- `aria-describedby` must be `[rules_id, *existing_described_by]` — the rules id **joins** the hint/error composition, never replaces it.

- [ ] **Step 1: Write the failing tests**

Add to `test/stimulus_plumbers/form/fields/inputs/password_test.rb`:

```ruby
def test_strength_block_renders_meter_level_and_rules
  doc = build_field(:field, :password, as: :password) { |p| p.strength(min_length: 12, digit: true) }

  assert_css doc, "[data-controller='password-strength']"
  assert_css doc, "meter[data-progress-target='meter'][low='34'][high='100'][optimum='100']"
  assert_css doc, "p[data-password-strength-target='level'][aria-live='polite']"
  assert_css doc, "ul li[data-password-strength-target='rule'][data-rule='length']"
  assert_css doc, "ul li[data-rule='digit']", text: "One number"
end

def test_outlet_selector_matches_the_meter_id
  doc = build_field(:field, :password, as: :password) { |p| p.strength(min_length: 8) }

  outlet = doc.at_css("[data-password-strength-progress-outlet]")["data-password-strength-progress-outlet"]

  assert_css doc, "meter#{outlet}"
end

def test_options_json_is_camel_cased_and_carries_thresholds
  doc = build_field(:field, :password, as: :password) { |p| p.strength(min_length: 12, low: 20, high: 80) }

  options = JSON.parse(doc.at_css("[data-password-strength-options-value]")["data-password-strength-options-value"])

  assert_equal 12, options["minLength"]
  assert_equal 20, options["low"]
  assert_equal 80, options["high"]
end

def test_custom_thresholds_reach_the_meter_attributes
  doc = build_field(:field, :password, as: :password) { |p| p.strength(min_length: 8, low: 20, high: 80) }

  assert_css doc, "meter[low='20'][high='80']"
end

def test_rules_list_id_joins_described_by_without_replacing_hint_and_error
  doc = build_field(:field, :password, as: :password, hint: "Use 12+ characters", error: "is too short") do |p|
    p.strength(min_length: 12)
  end

  described = doc.at_css("input[type='password']")["aria-describedby"].split

  assert_includes described, "sign_in_form_password_rules"
  assert_includes described, "sign_in_form_password_hint"
  assert_includes described, "sign_in_form_password_error"
end

def test_rule_state_is_conveyed_by_icon_and_text_not_color
  doc = build_field(:field, :password, as: :password) { |p| p.strength(digit: true) }
  rule = doc.at_css("li[data-rule='digit']")

  assert_equal "false", rule["data-satisfied"]
  assert_includes rule.text, "One number"
end

def test_no_block_renders_no_strength_ui
  doc = build_field(:field, :password, as: :password)

  assert_no_css doc, "[data-controller='password-strength']"
  assert_no_css doc, "meter"
end
```

Note: `build_field` must accept a block. If the existing helper does not forward one, extend it — mirror `FormBuilderTest#build_form`.

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: FAIL — no `[data-controller='password-strength']`

- [ ] **Step 3: Implement the renderer**

In `password.rb`, replace `render_password_input` and add the strength builders. The input keeps its existing path; when `@password_config.strength?` the whole thing is wrapped:

```ruby
def render_password_input(attribute, html_opts, opts, error, floating: nil, revealable: false, **kwargs, &block)
  @password_config = build_password_config(&block)
  # `html_opts` arrives from Form::Field#render_default_field as
  # build_html_options(input_id, aria) — so it already carries the id and the
  # hint/error `describedby` that Form::Base composed. Read both from it.
  input_id = html_opts[:id]
  html_options = password_html_options(html_opts, opts, error, floating, kwargs)
  html_options = apply_strength_wiring(html_options, input_id) if @password_config.strength?

  input = if revealable
            render_revealable_password(error, floating: floating) do
              revealable_html_options = merge_html_options(html_options, { data: { input_revealable_target: "input" } })
              @template.password_field(@object_name, attribute, objectify_options(revealable_html_options))
            end
          else
            @template.password_field(@object_name, attribute, objectify_options(html_options))
          end

  return input unless @password_config.strength?

  wrap_with_strength(input, input_id)
end
```

Add these private methods:

```ruby
# The rules list id JOINS the hint/error composition rather than replacing it.
# Compose the value explicitly instead of relying on merge_html_options to append
# nested aria keys — that behaviour is not guaranteed, and a silent overwrite here
# would drop the hint and error ids from the input's accessible description.
def apply_strength_wiring(html_options, input_id)
  described = [html_options.dig(:aria, :describedby), rules_id(input_id)].compact.join(" ")

  merge_html_options(
    html_options,
    {
      aria: { describedby: described },
      data: { password_strength_target: "input", action: "input->password-strength#score" }
    }
  )
end

def wrap_with_strength(input, input_id)
  @template.content_tag(
    :div,
    **merge_html_options(
      theme.resolve(:password_strength_wrapper),
      {
        data: {
          controller:                             "password-strength",
          password_strength_options_value:        strength_options_json.to_json,
          password_strength_progress_outlet:      "##{meter_id(input_id)}"
        }
      }
    )
  ) do
    @template.safe_join([input, render_meter(input_id), render_level, render_rules(input_id)])
  end
end

# Thresholds are emitted twice from one source — into the JSON, because score()
# derives `level` from them, and onto the <meter>, which drives native coloring.
def strength_options_json
  thresholds = @password_config.thresholds.except(:optimum)
  @password_config.strength_options.except(*Password::Config::DEFAULT_THRESHOLDS.keys)
                  .transform_keys { |key| key.to_s.camelize(:lower) }
                  .merge(thresholds.transform_keys(&:to_s))
end

def render_meter(input_id)
  Components::ProgressMeter.new(@template).render(
    value: 0,
    id:    meter_id(input_id),
    **@password_config.thresholds
  )
end

def render_level
  @template.content_tag(
    :p,
    I18n.t("stimulus_plumbers.form.password.levels.weak", default: "Weak"),
    **merge_html_options(
      theme.resolve(:password_strength_level),
      { data: { password_strength_target: "level" }, aria: { live: "polite" } }
    )
  )
end

def render_rules(input_id)
  @template.content_tag(
    :ul,
    **merge_html_options(theme.resolve(:password_strength_rules), { id: rules_id(input_id) })
  ) do
    @template.safe_join(@password_config.rules.map { |key, label| render_rule(key, label) })
  end
end

def render_rule(key, label)
  @template.content_tag(
    :li,
    **merge_html_options(
      theme.resolve(:password_strength_rule, satisfied: false),
      { data: { password_strength_target: "rule", rule: key, satisfied: "false" } }
    )
  ) do
    @template.safe_join([rule_icon("check", "checkIcon", hidden: true), rule_icon("close", "closeIcon"), label])
  end
end

def rule_icon(name, target, hidden: false)
  Components::Icon.new(@template).render(
    name,
    size:   :sm,
    aria:   { hidden: "true" },
    data:   { password_strength_target: target },
    hidden: hidden,
    **theme.resolve(:password_strength_rule_icon)
  )
end

def meter_id(input_id) = "#{input_id}_meter"
def rules_id(input_id) = "#{input_id}_rules"
```

**Rubocop will reject the last two** — `Style/EndlessMethod: disallow`. Write them multi-line:

```ruby
def meter_id(input_id)
  "#{input_id}_meter"
end

def rules_id(input_id)
  "#{input_id}_rules"
end
```

`Components::Icon#render` must emit `hidden` as an **attribute** on the `<svg>`, not set a property. The existing `password_icon` helper already passes `hidden:` this way, so follow it exactly.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: PASS

- [ ] **Step 5: Run the full suite and rubocop**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit && bundle exec rake rubocop`
Expected: 0 failures, 0 offenses. Baseline before this work: 1383 runs.

- [ ] **Step 6: Update docs**

`docs/component/form.md` — extend the `f.field` block paragraph with the `p.strength` / `p.rule` API. `CLAUDE.md` folder tree — note the new responsibilities on `password/config.rb`. Do not restate the JS contract; link to `stimulus-plumbers/docs/component/password_strength.md`.

- [ ] **Step 7: Commit**

```bash
git add stimulus-plumbers-rails/lib stimulus-plumbers-rails/test stimulus-plumbers-rails/docs stimulus-plumbers-rails/CLAUDE.md
git commit --no-gpg-sign -m "feat(rails): render password strength meter and rules checklist"
```

---

## Task 7: Tailwind theme classes

**Files:**
- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/form.rb` (or the file owning `form_field_*` keys)
- Test: `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/form_test.rb`

**Interfaces:**
- Consumes: the five theme keys from Task 4.
- Produces: Tailwind classes. `password_strength_rule` must style from `satisfied:` using semantic tokens, not raw colors.

- [ ] **Step 1: Write the failing test**

Follow the "test use cases, not implementation" rule — assert semantic tokens, not layout utilities:

```ruby
def test_satisfied_rule_uses_the_success_token
  assert_includes theme.resolve(:password_strength_rule, satisfied: true)[:classes], "text-(--sp-color-success)"
end

def test_unsatisfied_rule_is_muted_not_error_colored
  classes = theme.resolve(:password_strength_rule, satisfied: false)[:classes]

  assert_includes classes, "text-(--sp-color-muted)"
  refute_includes classes, "text-(--sp-color-danger)"
end
```

An unmet requirement is not an error — it is a not-yet. Coloring it as danger reads as failure before the user has done anything wrong.

- [ ] **Step 2: Run to verify it fails**

Run: `cd stimulus-plumbers-tailwind && bundle exec rake test`
Expected: FAIL — key not themed

- [ ] **Step 3: Implement the theme entries**

Add all five keys following the surrounding style. Confirm the exact token names against existing entries before writing — do not invent tokens.

- [ ] **Step 4: Run tests, rubocop, rebuild CSS**

```bash
cd stimulus-plumbers-tailwind && bundle exec rake test && bundle exec rake rubocop && node --run build:css
```
Expected: 512+ runs pass, no offenses.

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers-tailwind/lib stimulus-plumbers-tailwind/test
git commit --no-gpg-sign -m "feat(tailwind): password strength theme keys"
```

---

## Task 8: Sandbox pages

**Files:**
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/form/password.html.erb`
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/form.rb`, `test/sandbox/app/controllers/form_controller.rb`
- Create/modify: the same three files under `stimulus-plumbers-tailwind/test/sandbox/`

**Interfaces:**
- Produces: `/form/password` in both sandboxes with five sections — `#password-default`, `#password-revealable`, `#password-strength`, `#password-strength-revealable`, `#password-error`.
- Consumes: `SignUp` form object.

- [ ] **Step 1: Add the route**

In both `test/sandbox/config/routes/form.rb`, inside the `scope "/form"` block:

```ruby
get :password
```

- [ ] **Step 2: Add the controller action**

In both `FormController`:

```ruby
def password
  @form = SignUp.new
end
```

- [ ] **Step 3: Write the view**

Create `password.html.erb` in both sandboxes, mirroring `floating_label.html.erb`'s locals pattern:

```erb
<h1>Password</h1>

<% fresh = SignUp.new %>
<% error_form = SignUp.new.tap { |f| f.errors.add(:password, "is too short") } %>

<section id="password-default">
  <h2>Default</h2>
  <%= form_with(model: fresh, url: "/demo", builder: StimulusPlumbers::Form::Builder) do |f| %>
    <%= f.field :password, as: :password, label: "Password", required: true %>
  <% end %>
</section>

<section id="password-revealable">
  <h2>Revealable</h2>
  <%= form_with(model: fresh, url: "/demo", builder: StimulusPlumbers::Form::Builder) do |f| %>
    <%= f.field :password, as: :password, label: "Password", required: true, revealable: true %>
  <% end %>
</section>

<section id="password-strength">
  <h2>Strength</h2>
  <%= form_with(model: fresh, url: "/demo", builder: StimulusPlumbers::Form::Builder) do |f| %>
    <%= f.field :password, as: :password, label: "Password", required: true do |p| %>
      <% p.strength min_length: 12, uppercase: true, digit: true, symbol: true %>
    <% end %>
  <% end %>
</section>

<section id="password-strength-revealable">
  <h2>Strength + reveal</h2>
  <%= form_with(model: fresh, url: "/demo", builder: StimulusPlumbers::Form::Builder) do |f| %>
    <%= f.field :password, as: :password, label: "Password", required: true, revealable: true do |p| %>
      <% p.strength min_length: 12, digit: true %>
    <% end %>
  <% end %>
</section>

<section id="password-error">
  <h2>Error</h2>
  <%= form_with(model: error_form, url: "/demo", builder: StimulusPlumbers::Form::Builder) do |f| %>
    <%= f.field :password, as: :password, label: "Password", required: true, revealable: true %>
  <% end %>
</section>
```

**Verify the block form works in ERB.** `f.field ... do |p|` inside `<%= %>` requires the helper to return the rendered string while yielding for configuration. If ERB capture interferes, use `<% end %>` with the field assigned to a local, and fix the plan step rather than working around it in the view.

- [ ] **Step 4: Verify both pages render**

```bash
cd stimulus-plumbers-rails && bundle exec rake test:accessibility
```
Expected: existing 149 runs still pass. Then boot each sandbox and load `/form/password` to confirm no exceptions.

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers-rails/test/sandbox stimulus-plumbers-tailwind/test/sandbox
git commit --no-gpg-sign -m "test: password sandbox page in both gems"
```

---

## Task 9: Accessibility test

**Files:**
- Create: `stimulus-plumbers-rails/test/accessibility/form/password_accessibility_test.rb`
- Modify: `stimulus-plumbers-rails/test/accessibility/form/form_accessibility_test.rb`

**Interfaces:**
- Consumes: `/form/password` from Task 8; `ApplicationAccessibilityTestCase`.

- [ ] **Step 1: Write the test**

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class PasswordAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/password"
  end

  def test_default_passes_wcag
    assert_accessible context: "#password-default"
  end

  def test_revealable_passes_wcag
    assert_accessible context: "#password-revealable"
  end

  def test_revealable_revealed_passes_wcag
    find("#password-revealable button[aria-label='Show password']").click

    assert_accessible context: "#password-revealable"
  end

  def test_strength_passes_wcag
    assert_accessible context: "#password-strength"
  end

  def test_strength_populated_passes_wcag
    find("#password-strength input[type='password']").fill_in with: "Abcdef123456!"

    assert_accessible context: "#password-strength"
  end

  def test_error_passes_wcag
    assert_accessible context: "#password-error"
  end

  # WCAG 1.4.1 Use of Color is not machine-checkable, and rule state is the one place
  # in this component where color could silently become the sole signal.
  def test_satisfied_rule_is_not_indicated_by_color_alone
    find("#password-strength input[type='password']").fill_in with: "Abcdef123456!"
    rule = find("#password-strength li[data-rule='digit']")

    assert_equal "true", rule["data-satisfied"]
    assert_includes rule.text, "One number"
  end
end
```

- [ ] **Step 2: Run it**

Run: `cd stimulus-plumbers-rails && bundle exec ruby -Itest test/accessibility/form/password_accessibility_test.rb`
Expected: PASS, 7 tests. Any axe violation is a real defect — read the HTML in the failure output before changing the test.

- [ ] **Step 3: Remove the superseded test**

Delete `test_passes_wcag_with_password_revealed` from `form_accessibility_test.rb`. Leave `test_passes_wcag` and `test_passes_wcag_with_icon_only_submit`.

- [ ] **Step 4: Run the full a11y suite**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:accessibility`
Expected: 155 runs (149 − 1 + 7), 0 failures.

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers-rails/test/accessibility
git commit --no-gpg-sign -m "test: dedicated password accessibility coverage"
```

---

## Task 10: Snapshot spec

**Files:**
- Create: `stimulus-plumbers-tailwind/test/snapshots/password.spec.js`
- Modify: `stimulus-plumbers-tailwind/test/snapshots/form.spec.js`
- Delete: 4 baseline PNGs

**Interfaces:**
- Consumes: `/form/password` from Task 8.
- Produces: 9 tests → 18 baselines (`desktop` + `mobile`).

- [ ] **Step 1: Write the spec**

```js
import { test, expect } from "@playwright/test";

// A dead controller can render identical pixels, so every test asserts state
// before screenshotting — the rule form.spec.js already applies to reveal.
test.describe("password", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/form/password");
    await page.waitForSelector("#password-default form");
  });

  test("default", async ({ page }) => {
    await expect(page.locator("#password-default")).toHaveScreenshot("default.png");
  });

  test.describe("revealable", () => {
    test("hidden", async ({ page }) => {
      const section = page.locator("#password-revealable");
      await expect(section.locator("input[data-input-revealable-target='input']")).toHaveAttribute("type", "password");
      await expect(section).toHaveScreenshot("revealable-hidden.png");
    });

    test("revealed", async ({ page }) => {
      const section = page.locator("#password-revealable");
      await section.getByLabel("Show password").click();

      await expect(section.locator("input[data-input-revealable-target='input']")).toHaveAttribute("type", "text");
      await expect(section.getByLabel("Hide password")).toBeVisible();
      await expect(section).toHaveScreenshot("revealable-revealed.png");
    });
  });

  test.describe("strength", () => {
    const fill = async (page, value) => {
      const section = page.locator("#password-strength");
      await section.locator("input[type='password']").fill(value);
      return section;
    };

    test("empty", async ({ page }) => {
      const section = page.locator("#password-strength");
      await expect(section.locator("meter")).toHaveAttribute("value", "0");
      await expect(section).toHaveScreenshot("strength-empty.png");
    });

    test("weak", async ({ page }) => {
      const section = await fill(page, "abcd");
      await expect(section.locator("li[data-rule='digit']")).toHaveAttribute("data-satisfied", "false");
      await expect(section).toHaveScreenshot("strength-weak.png");
    });

    test("fine", async ({ page }) => {
      const section = await fill(page, "Abcdefghijkl");
      await expect(section.locator("li[data-rule='uppercase']")).toHaveAttribute("data-satisfied", "true");
      await expect(section.locator("li[data-rule='symbol']")).toHaveAttribute("data-satisfied", "false");
      await expect(section).toHaveScreenshot("strength-fine.png");
    });

    test("strong", async ({ page }) => {
      const section = await fill(page, "Abcdef123456!");
      await expect(section.locator("li[data-rule='symbol']")).toHaveAttribute("data-satisfied", "true");
      await expect(section).toHaveScreenshot("strength-strong.png");
    });
  });

  test("strength revealed", async ({ page }) => {
    const section = page.locator("#password-strength-revealable");
    await section.locator("input[type='password']").fill("Abcdef123456!");
    await section.getByLabel("Show password").click();

    await expect(section.locator("input[data-input-revealable-target='input']")).toHaveAttribute("type", "text");
    await expect(section).toHaveScreenshot("strength-revealed.png");
  });

  test("error", async ({ page }) => {
    await expect(page.locator("#password-error")).toHaveScreenshot("error.png");
  });
});
```

**Tune the fill values to your actual thresholds** before generating baselines. With `min_length: 12, uppercase, digit, symbol` (4 rules): `abcd` satisfies 0 → weak; `Abcdefghijkl` satisfies length+uppercase = 50 → fine; `Abcdef123456!` satisfies all 4 = 100 → strong. Verify by asserting the `<meter>` value, and correct the strings rather than the thresholds if they disagree.

- [ ] **Step 2: Remove the superseded tests**

From `form.spec.js` `sign up form` describe, delete `test("password revealed")` and `test("floating labels — password revealed")`. Keep `default`, `floating labels`, `floating labels — filled`, `icon-only submit`. Leave the whole `floating label form` describe untouched.

- [ ] **Step 3: Delete their baselines**

```bash
cd stimulus-plumbers-tailwind/test/snapshots/__screenshots__/form.spec.js
git rm sign-up-password-revealed-desktop-linux.png sign-up-password-revealed-mobile-linux.png \
       sign-up-floating-password-revealed-desktop-linux.png sign-up-floating-password-revealed-mobile-linux.png
```

- [ ] **Step 4: Verify locally without writing baselines**

**Do not run `npm run test:snapshots` on macOS.** Baselines are linux-only; Playwright will find none matching and write a parallel `-darwin` set into the repo. Confirm the spec's selectors and state assertions by loading the sandbox in a browser manually.

- [ ] **Step 5: Generate baselines in CI**

Dispatch `ci-snapshots.yml` to produce the 18 `-linux` baselines. Commit the generated PNGs on the branch.

- [ ] **Step 6: Commit**

```bash
git add stimulus-plumbers-tailwind/test/snapshots
git commit --no-gpg-sign -m "test: dedicated password snapshot coverage"
```

---

## Task 11: Reconcile the specs

**Files:**
- Modify: `docs/superpowers/specs/2026-07-20-password-strength-meter-design.md`
- Modify: `docs/superpowers/specs/2026-07-20-password-test-coverage-design.md`

- [ ] **Step 1: Cut the superseded sections**

In the strength spec, replace the **Accessibility** and **Visual snapshots** sections under `## Testing` with:

```markdown
### Accessibility and visual snapshots

Owned by `2026-07-20-password-test-coverage-design.md`.
```

Leave **JS unit** and **Ruby unit** exactly as written — they are feature tests, not coverage design.

- [ ] **Step 2: Mark both specs implemented**

Change both `**Status:**` lines to `Implemented`.

- [ ] **Step 3: Full verification across all four packages**

```bash
cd stimulus-plumbers      && npm test && npm run lint
cd ../stimulus-plumbers-rails    && bundle exec rake test:unit && bundle exec rake test:accessibility && bundle exec rake rubocop
cd ../stimulus-plumbers-tailwind && bundle exec rake test && bundle exec rake rubocop
cd ../stimulus-plumbers-mcp      && bundle exec rake test
cd .. && npm run format:docs:check
```
Expected: everything green. Report actual counts; do not assert success without the output.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/specs
git commit --no-gpg-sign -m "docs: mark password strength and coverage specs implemented"
```

---

## Self-Review Notes

**Spec coverage.** Every section of the strength spec maps to a task: scoring plumber → 1; controller → 2; exports and docs → 3; theme keys and locale → 4; Rails DSL with lazy merge and unknown-key raise → 5; rendered structure, dual threshold emission, `aria-describedby` composition → 6; Tailwind classes → 7. Coverage spec: sandbox pages → 8; a11y → 9; snapshots and removals → 10; spec reconciliation → 11.

**Known risks, flagged rather than hidden:**

1. **ERB block capture (Task 8, Step 3).** `<%= f.field ... do |p| %>` mixes output and configuration in one block. The `Password::Config` path yields for configuration only and returns markup, which should work, but this is the first sandbox use of a `field` block and is unproven. If it misbehaves, fix the renderer — do not paper over it in the view.
2. **`aria-describedby` composition (Task 6).** Resolved by construction: `apply_strength_wiring` joins the existing value explicitly rather than trusting `merge_html_options` to append nested aria keys. `test_rules_list_id_joins_described_by_without_replacing_hint_and_error` guards it. If that test fails, the bug is real — do not "fix" it by dropping the hint/error assertion.
3. **Snapshot fill values (Task 10).** Level boundaries depend on the sandbox's configured rules. Assert the `<meter>` value in each test so a mismatch fails loudly instead of baking a wrong baseline.
4. **`Components::Icon` `hidden:` on `<svg>`.** Task 6 passes `hidden: true` to the check icon. Confirm `Icon#render` emits the `hidden` **attribute**, not a `hidden` property — the same class of bug the spec warns about for JS.
