# Password Rule Registry + client/server `valid?` — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make password rules a declarative, extensible set that drives both the live client meter and server-side `ActiveModel` enforcement from a single definition.

**Architecture:** Rules become serializable descriptors (`{ key, label, pattern?, min, max }`) evaluated by one rule — `min ≤ n ≤ max` — where `n` is password length (no `pattern`) or occurrence count (with `pattern`). A standalone `StimulusPlumbers::Password::Requirements` owns the DSL, evaluation (`evaluate`/`valid?`), and serialization (`to_stimulus`); it is consumed by the form renderer, a `PasswordStrengthValidator`, and — via emitted JSON — a data-driven JS controller that holds no built-in rule table.

**Tech Stack:** Ruby (Rails engine, Minitest), JavaScript (Stimulus, Vitest).

Spec: `docs/superpowers/specs/2026-07-21-password-rule-registry-design.md`.

## Global Constraints

- Branch: `design`.
- Rule contract: patterns are **single-char-consuming character classes only** — no anchors (`^`/`$`/`\A`/`\z`), lookbehind, or unicode-property escapes. Evaluated **unanchored**.
- Occurrence count = non-overlapping matches: Ruby `password.scan(Regexp.new(src)).size`, JS `(pw.match(new RegExp(src, "g")) || []).length`.
- JSON contract: **count rules** emit `min` (mandatory, default 1) and `max` only when bounded (missing ⇒ `Infinity`). **Length rule** emits both `min` and `max` (both mandatory); enabling length without `max_length` (or without `min_length`) raises `ArgumentError`.
- `valid?(password)` is `true` iff every enabled rule passes (≡ level `strong`). Thresholds never affect `valid?`.
- `Password::Requirements` does **not** inherit `Plumber::Config` and holds no `template`.
- `negate: true` on a custom rule is sugar for `min: 0, max: 0`; `negate` is not a wire field.
- Tests assert literal English strings (never `I18n.t`) per gem convention.
- After each Ruby task: `bundle exec rake test:unit` and `bundle exec rake rubocop` from `stimulus-plumbers-rails/` must be green (run synchronously). After each JS task: `node --run test` from `stimulus-plumbers/` must be green.
- Paths below are relative to each package root: `stimulus-plumbers/` (npm) or `stimulus-plumbers-rails/` (gem).

---

## File Structure

**npm (`stimulus-plumbers/`)**
- Modify `src/plumbers/password_strength.js` — data-driven `RulesScorer`; drop `RULE_KEYS`/`matchers`.
- Modify `src/controllers/password_strength_controller.js` — add `rules` value; pass to scorer.
- Modify `src/index.js` — drop `RULE_KEYS` export.
- Modify `tests/unit/plumbers/password_strength.test.js` — descriptor-driven tests.
- Modify `docs/component/password-strength.md` — value + rule-descriptor docs.

**gem (`stimulus-plumbers-rails/`)**
- Create `lib/stimulus_plumbers/password/requirements.rb` — `StimulusPlumbers::Password::Requirements`.
- Create `lib/stimulus_plumbers/password_strength_validator.rb` — top-level `PasswordStrengthValidator`.
- Delete `lib/stimulus_plumbers/form/fields/inputs/password/config.rb`.
- Modify `lib/stimulus_plumbers.rb` — require the two new files; drop the deleted require.
- Modify `lib/stimulus_plumbers/form/fields/inputs/password.rb` — build `Requirements`; rename ivar.
- Modify `lib/stimulus_plumbers/form/fields/inputs/password/strength.rb` — use renamed ivar.
- Modify `lib/stimulus_plumbers/components/password_strength.rb` — consume `to_stimulus`; drop `strength_stimulus_options`.
- Create `test/stimulus_plumbers/password/requirements_test.rb` — `PasswordRequirementsTest`.
- Create `test/stimulus_plumbers/password_strength_validator_test.rb` — `PasswordStrengthValidatorTest`.
- Delete `test/stimulus_plumbers/form/fields/inputs/password_config_test.rb`.
- Modify `test/stimulus_plumbers/form/fields/inputs/password_test.rb` — new `rules`/`options` value shape.
- Modify `config/locales/en.yml` — add validator error copy.
- Modify `CLAUDE.md`, `README.md`, `docs/component/password.md` — document Requirements + validator.

**shared**
- Create `stimulus-plumbers/tests/fixtures/password_rules.json` — the parity fixture (loaded by both suites).
- The gem test copies/reads the same fixture; see Task 5 for the path resolution.

---

## Task 1: JS data-driven scorer + controller

**Files:**
- Modify: `src/plumbers/password_strength.js`
- Modify: `src/controllers/password_strength_controller.js:9-33`
- Modify: `src/index.js:19`
- Test: `tests/unit/plumbers/password_strength.test.js`
- Test: `tests/unit/controllers/password_strength_controller.test.js` — retarget markup at the new `rules-value` contract.

**Interfaces:**
- Produces: `RulesScorer.score(password, rules, options) => { value, level, rules: { key: bool } }` where `rules` is an array of `{ key, label?, pattern?, min?, max? }`. `n` = `password.length` when `pattern` absent, else non-overlapping match count. Rule passes when `(rule.min ?? 0) ≤ n ≤ (rule.max ?? Infinity)`. `level`: `strong` when all pass; else `value < (options.low ?? 34)` ⇒ `weak`, else `fine`. `PasswordStrength.register(type, scorer)` and `attachPasswordStrength(controller, { type })` unchanged. `RULE_KEYS`/`matchers` removed.
- Controller: `static values` gains `rules: { type: Array, default: [] }`; `score()` calls `this.strength.score(this.readValue(), this.rulesValue, this.optionsValue)`.

- [ ] **Step 1: Rewrite the scorer test**

Replace the entire body of `tests/unit/plumbers/password_strength.test.js` with:

```js
import { describe, it, expect } from 'vitest';
import { PasswordStrength, attachPasswordStrength } from '../../../src/plumbers/password_strength';

const score = (pw, rules, opts) => {
  const controller = {};
  attachPasswordStrength(controller, {});
  return controller.strength.score(pw, rules, opts ?? {});
};

const length = (min, max) => ({ key: 'length', min, max });
const digit = (min, max) => ({ key: 'digit', pattern: '\\d', min, max });
const upper = (min) => ({ key: 'uppercase', pattern: '[A-Z]', min });

describe('RulesScorer', () => {
  it('evaluates length against min and max', () => {
    expect(score('abc', [length(5, 12)]).rules.length).toBe(false);
    expect(score('abcde', [length(5, 12)]).rules.length).toBe(true);
    expect(score('a'.repeat(13), [length(5, 12)]).rules.length).toBe(false);
  });

  it('counts occurrences for min', () => {
    expect(score('a1', [digit(2)]).rules.digit).toBe(false);
    expect(score('a12', [digit(2)]).rules.digit).toBe(true);
  });

  it('counts occurrences for max', () => {
    expect(score('123', [digit(0, 2)]).rules.digit).toBe(false);
    expect(score('12', [digit(0, 2)]).rules.digit).toBe(true);
  });

  it('treats max 0 as a forbid rule', () => {
    const noDigits = { key: 'no_digits', pattern: '\\d', min: 0, max: 0 };
    expect(score('ab1', [noDigits]).rules.no_digits).toBe(false);
    expect(score('abc', [noDigits]).rules.no_digits).toBe(true);
  });

  it('scores 0 when nothing satisfied and 100 when all satisfied', () => {
    const rules = [length(4, 12), upper(1), digit(1)];
    expect(score('', rules).value).toBe(0);
    expect(score('Abcd1', rules).value).toBe(100);
  });

  it('is strong only when every rule passes', () => {
    const rules = [upper(1), digit(1)];
    expect(score('aB', rules).level).toBe('fine');
    expect(score('aB1', rules).level).toBe('strong');
  });

  it('splits weak from fine at low', () => {
    const rules = [upper(1), digit(1), length(1, 99)];
    expect(score('a', rules, { low: 70 }).level).toBe('weak');
    expect(score('aB', rules, {}).level).toBe('fine');
  });
});

describe('registry', () => {
  it('prefers a registered scorer', () => {
    PasswordStrength.register('entropy', { score: () => ({ value: 42, level: 'fine', rules: {} }) });
    const controller = {};
    attachPasswordStrength(controller, { type: 'entropy' });
    expect(controller.strength.score('x', [], {}).value).toBe(42);
  });

  it('falls back to rules for an unknown type', () => {
    const controller = {};
    attachPasswordStrength(controller, { type: 'nope' });
    expect(controller.strength.score('abcd', [{ key: 'length', min: 4, max: 12 }], {}).value).toBe(100);
  });
});
```

- [ ] **Step 2: Run it and watch it fail**

Run: `node --run test tests/unit/plumbers/password_strength.test.js`
Expected: FAIL (scorer still expects `options`, not a `rules` array; `RULE_KEYS` import removed).

- [ ] **Step 3: Rewrite the scorer**

Replace the entire contents of `src/plumbers/password_strength.js` with:

```js
import Plumber from './plumber';

export const STRENGTH_TYPES = {
  RULES: 'rules',
};

export const STRENGTH_LEVELS = {
  WEAK: 'weak',
  FINE: 'fine',
  STRONG: 'strong',
};

const defaultThresholds = { low: 34 };

const occurrences = (source, password) => {
  const matches = password.match(new RegExp(source, 'g'));
  return matches ? matches.length : 0;
};

// n is the password length for length rules (no pattern), else the occurrence count.
const satisfies = (rule, password) => {
  const n = rule.pattern == null ? password.length : occurrences(rule.pattern, password);
  const min = rule.min ?? 0;
  const max = rule.max ?? Infinity;
  return n >= min && n <= max;
};

const levelFor = (satisfied, total, options) => {
  if (total > 0 && satisfied === total) return STRENGTH_LEVELS.STRONG;

  const value = total === 0 ? 0 : Math.round((satisfied / total) * 100);
  const low = options.low ?? defaultThresholds.low;
  return value < low ? STRENGTH_LEVELS.WEAK : STRENGTH_LEVELS.FINE;
};

export const RulesScorer = {
  score(password, rules = [], options = {}) {
    const value = typeof password === 'string' ? password : '';
    const result = rules.reduce((acc, rule) => {
      acc[rule.key] = satisfies(rule, value);
      return acc;
    }, {});

    const satisfied = rules.filter((rule) => result[rule.key]).length;
    const score = rules.length === 0 ? 0 : Math.round((satisfied / rules.length) * 100);

    return { value: score, level: levelFor(satisfied, rules.length, options), rules: result };
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
      score: (password, rules, options) => scorer.score(password, rules ?? [], options ?? {}),
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

- [ ] **Step 4: Update the controller**

In `src/controllers/password_strength_controller.js`, add the `rules` value and pass it to the scorer. Change the `static values` block and `score()`:

```js
  static values = {
    scorer: { type: String, default: 'rules' },
    rules: { type: Array, default: [] },
    options: { type: Object, default: {} },
    labels: { type: Object, default: {} },
    announceDelay: { type: Number, default: 700 },
  };
```

```js
  score() {
    const { value, level, rules } = this.strength.score(this.readValue(), this.rulesValue, this.optionsValue);

    if (this.hasProgressOutlet) this.progressOutlet.setValue(value);
    this.drawRules(rules);
    this.announce(level);
  }
```

- [ ] **Step 4b: Retarget the controller test at the new value contract**

The controller now reads a `rules` descriptor array instead of rule config baked into `options`. In `tests/unit/controllers/password_strength_controller.test.js`, replace the `OPTIONS` constant (line 6):

```js
const RULES = JSON.stringify([{ key: 'digit', pattern: '\\d', min: 1 }]);
const OPTIONS = JSON.stringify({ low: 34 });
```

and add the rules value to the wrapper element in `markup` (alongside `data-password-strength-options-value`):

```js
    <div data-controller="password-strength"
         data-password-strength-rules-value='${RULES}'
         data-password-strength-options-value='${OPTIONS}'
         data-password-strength-labels-value='{"weak":"Weak","fine":"Fine","strong":"Strong"}'
         ${withMeter ? 'data-password-strength-progress-outlet="#pw-meter"' : ''}>
```

The single `digit` rule keeps the existing assertions valid: `abcd1`/`abc1` satisfy it (1/1 ⇒ value 100 ⇒ `strong`), `abcde1` still satisfies it (stays `strong`, so the "no re-announce within a level" test holds). No other lines change.

- [ ] **Step 5: Drop the removed export**

In `src/index.js:19`, remove `RULE_KEYS` from the password-strength export:

```js
export { PasswordStrength, attachPasswordStrength, STRENGTH_TYPES } from './plumbers/password_strength.js';
```

- [ ] **Step 6: Run the whole JS suite + lint**

Run: `node --run test` then `node --run lint`
Expected: PASS, 0 lint errors. (Rebuild dist only when snapshots run — not needed here.)

- [ ] **Step 7: Commit**

```bash
git add src/plumbers/password_strength.js src/controllers/password_strength_controller.js src/index.js tests/unit/plumbers/password_strength.test.js tests/unit/controllers/password_strength_controller.test.js
git commit -m "feat(js): data-driven password strength scorer with occurrence counts"
```

---

## Task 2: Ruby `Password::Requirements` (standalone evaluation)

**Files:**
- Create: `lib/stimulus_plumbers/password/requirements.rb`
- Test: `test/stimulus_plumbers/password/requirements_test.rb`

**Interfaces:**
- Produces: `StimulusPlumbers::Password::Requirements`.
  - `.build { |r| ... } => Requirements`; `#strength(**options)`, `#rule(key, label = nil, pattern:, min:, max:, negate:)` (both return `nil`).
  - `#strength? => Boolean`; `#rules => { key(Symbol) => label(String) }` (ordered, checklist labels); `#thresholds => { low:, high:, optimum: }`.
  - `#evaluate(password) => { rules: { key(Symbol) => Boolean }, value: Integer, level: String }` (`level` one of `"weak"/"fine"/"strong"`).
  - `#valid?(password) => Boolean` (all enabled rules pass; `false` when no rules).
  - `#to_stimulus => { rules: [descriptor,...], options: { "low" => Integer }, labels: { "weak"=>, "fine"=>, "strong"=> } }` where a descriptor is `{ key:(String), label:, min:, max?:, pattern?: }` — `min` always present, `max` omitted when `nil` (count) / always present (length), `pattern` present only for count rules.
- Consumed by Tasks 3 and 4.

- [ ] **Step 1: Write the failing test**

Create `test/stimulus_plumbers/password/requirements_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class PasswordRequirementsTest < ActiveSupport::TestCase
  Requirements = StimulusPlumbers::Password::Requirements

  def build(&block)
    Requirements.build(&block)
  end

  def test_no_strength_by_default
    req = build

    assert_not req.strength?
    assert_empty req.rules
  end

  def test_length_requires_both_bounds
    error = assert_raises(ArgumentError) { build { |r| r.strength(min_length: 8) }.rules }
    assert_match(%r{max_length}, error.message)
  end

  def test_evaluates_length_between_min_and_max
    req = build { |r| r.strength(min_length: 5, max_length: 12) }

    assert_not req.evaluate("abc")[:rules][:length]
    assert req.evaluate("abcde")[:rules][:length]
    assert_not req.evaluate("a" * 13)[:rules][:length]
  end

  def test_true_enables_a_single_occurrence
    req = build { |r| r.strength(min_length: 1, max_length: 99, digit: true) }

    assert_not req.evaluate("ab")[:rules][:digit]
    assert req.evaluate("a1")[:rules][:digit]
  end

  def test_integer_sets_minimum_occurrences
    req = build { |r| r.strength(digit: 2) }

    assert_not req.evaluate("a1")[:rules][:digit]
    assert req.evaluate("a12")[:rules][:digit]
  end

  def test_range_sets_min_and_max_occurrences
    req = build { |r| r.strength(digit: 1..2) }

    assert req.evaluate("a1")[:rules][:digit]
    assert_not req.evaluate("a123")[:rules][:digit]
  end

  def test_valid_requires_every_rule
    req = build { |r| r.strength(min_length: 1, max_length: 99, uppercase: true, digit: true) }

    assert_not req.valid?("ab")
    assert req.valid?("aB1")
  end

  def test_valid_is_false_without_rules
    assert_not build.valid?("anything")
  end

  def test_level_is_strong_only_when_all_pass
    req = build { |r| r.strength(uppercase: true, digit: true) }

    assert_equal "fine", req.evaluate("aB")[:level]
    assert_equal "strong", req.evaluate("aB1")[:level]
  end

  def test_custom_negate_rule_forbids_matches
    req = build do |r|
      r.strength(min_length: 1, max_length: 99)
      r.rule(:no_spaces, "No spaces", pattern: %r{\s}, negate: true)
    end

    assert_not req.valid?("a b")
    assert req.valid?("abc")
  end

  def test_rule_rejects_unknown_builtin_without_pattern
    error = assert_raises(ArgumentError) { build.rule(:bogus, "Nope") }
    assert_match(%r{unknown rule key}, error.message)
  end

  def test_to_stimulus_serializes_length_descriptor
    req = build { |r| r.strength(min_length: 8, max_length: 64) }
    length = req.to_stimulus[:rules].find { |d| d[:key] == "length" }

    assert_equal({ key: "length", label: "At least 8 characters", min: 8, max: 64 }, length)
  end

  def test_to_stimulus_serializes_count_descriptor
    req = build { |r| r.strength(min_length: 8, max_length: 64, digit: 2) }
    digit = req.to_stimulus[:rules].find { |d| d[:key] == "digit" }

    assert_equal "\\d", digit[:pattern]
    assert_equal 2, digit[:min]
    assert_not digit.key?(:max)
  end

  def test_to_stimulus_carries_low_and_labels
    req = build { |r| r.strength(min_length: 8, max_length: 64, low: 20) }
    data = req.to_stimulus

    assert_equal({ "low" => 20 }, data[:options])
    assert_equal({ "weak" => "Weak", "fine" => "Fine", "strong" => "Strong" }, data[:labels])
  end
end
```

- [ ] **Step 2: Run it, watch it fail**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/password/requirements_test.rb`
Expected: FAIL — `uninitialized constant StimulusPlumbers::Password::Requirements`.

- [ ] **Step 3: Implement `Requirements`**

Create `lib/stimulus_plumbers/password/requirements.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Password
    # Declarative password rule set: DSL + evaluation + serialization. Consumed by
    # the form renderer, PasswordStrengthValidator, and the JS controller (via to_stimulus).
    class Requirements
      LEVEL_KEYS = %i[weak fine strong].freeze
      BUILTIN_KEYS = %i[length uppercase lowercase digit symbol].freeze
      DEFAULT_THRESHOLDS = { low: 34, high: 100, optimum: 100 }.freeze

      BUILTIN_PATTERNS = {
        uppercase: "[A-Z]",
        lowercase: "[a-z]",
        digit:     "\\d",
        symbol:    "[^A-Za-z0-9]"
      }.freeze

      class << self
        def build
          new.tap { |req| yield req if block_given? }
        end
      end

      def initialize
        @strength_options = nil
        @custom = {}
        @overrides = {}
      end

      def strength(**options)
        @strength_options = options
        nil
      end

      def rule(key, label = nil, pattern: nil, min: nil, max: nil, negate: false)
        key = key.to_sym
        if pattern
          if negate
            min = 0
            max = 0
          end
          @custom[key] = { pattern: source_of(pattern), min: min.nil? ? 1 : min, max: max, label: label }
        else
          raise ArgumentError, unknown_rule_message(key) unless BUILTIN_KEYS.include?(key)

          @overrides[key] = label
        end
        nil
      end

      def strength?
        !@strength_options.nil?
      end

      def rules
        descriptors.to_h { |descriptor| [descriptor[:key], descriptor[:label]] }
      end

      def thresholds
        DEFAULT_THRESHOLDS.merge((@strength_options || {}).slice(*DEFAULT_THRESHOLDS.keys))
      end

      def evaluate(password)
        password = password.to_s
        results = descriptors.to_h { |descriptor| [descriptor[:key], satisfies?(descriptor, password)] }
        satisfied = results.values.count(true)
        { rules: results, value: score(satisfied, results.size), level: level_for(satisfied, results.size) }
      end

      def valid?(password)
        result = evaluate(password)
        result[:rules].any? && result[:rules].values.all?
      end

      def to_stimulus
        { rules: descriptors.map { |descriptor| serialize(descriptor) }, options: stimulus_options, labels: level_labels }
      end

      private

      def descriptors
        return [] unless strength?

        list = BUILTIN_KEYS.filter_map { |key| builtin_descriptor(key) }
        @custom.each do |key, spec|
          list << { key: key, pattern: spec[:pattern], min: spec[:min], max: spec[:max], label: spec[:label] }
        end
        apply_overrides(list)
      end

      def builtin_descriptor(key)
        options = @strength_options
        return length_descriptor(options) if key == :length && (options.key?(:min_length) || options.key?(:max_length))

        bounds = parse_count(options[key])
        return unless bounds

        label = builtin_label(key, bounds[:min])
        { key: key, pattern: BUILTIN_PATTERNS[key], min: bounds[:min], max: bounds[:max], label: label }
      end

      def length_descriptor(options)
        unless options.key?(:min_length) && options.key?(:max_length)
          raise ArgumentError, "length rule requires both min_length and max_length"
        end

        label = builtin_label(:length, options[:min_length])
        { key: :length, min: options[:min_length], max: options[:max_length], label: label }
      end

      def parse_count(value)
        case value
        when nil, false then nil
        when true then { min: 1, max: nil }
        when Integer then { min: value, max: nil }
        when Range then { min: value.begin, max: value.end }
        else raise ArgumentError, "invalid occurrence count #{value.inspect}"
        end
      end

      def satisfies?(descriptor, password)
        n = descriptor[:pattern] ? password.scan(Regexp.new(descriptor[:pattern])).size : password.length
        min = descriptor[:min] || 0
        max = descriptor[:max] || Float::INFINITY
        n.between?(min, max)
      end

      def score(satisfied, total)
        total.zero? ? 0 : (satisfied.to_f / total * 100).round
      end

      def level_for(satisfied, total)
        return "strong" if total.positive? && satisfied == total

        score(satisfied, total) < thresholds[:low] ? "weak" : "fine"
      end

      def serialize(descriptor)
        data = { key: descriptor[:key].to_s, label: descriptor[:label], min: descriptor[:min] }
        data[:max] = descriptor[:max] unless descriptor[:max].nil?
        data[:pattern] = descriptor[:pattern] if descriptor[:pattern]
        data
      end

      def stimulus_options
        { "low" => thresholds[:low] }
      end

      def level_labels
        LEVEL_KEYS.index_with { |key| I18n.t("stimulus_plumbers.form.password.levels.#{key}") }.transform_keys(&:to_s)
      end

      def apply_overrides(list)
        return list if @overrides.empty?

        list.map do |descriptor|
          next descriptor unless @overrides.key?(descriptor[:key])

          descriptor.merge(label: @overrides[descriptor[:key]])
        end
      end

      def builtin_label(key, count)
        I18n.t("stimulus_plumbers.form.password.rules.#{key}", count: count)
      end

      def source_of(pattern)
        pattern.is_a?(Regexp) ? pattern.source : pattern.to_s
      end

      def unknown_rule_message(key)
        known = BUILTIN_KEYS.map(&:inspect).join(", ")
        "unknown rule key: #{key.inspect} (known keys: #{known}), or pass pattern: for a custom rule"
      end
    end
  end
end
```

- [ ] **Step 4: Require it**

In `lib/stimulus_plumbers.rb`, add near the other `require_relative` lines (before the form requires):

```ruby
require_relative "stimulus_plumbers/password/requirements"
```

- [ ] **Step 4b: Exclude the cohesive class from Metrics/ClassLength**

`Requirements` is a single cohesive DSL+evaluate+serialize unit (~123 lines); the repo excludes such classes rather than force-splitting them (see the existing `form/builder.rb`, `form/field.rb` entries). In `.rubocop.yml`, add the new file under the existing `Metrics/ClassLength: Exclude:` list, keeping the list's alphabetical-ish grouping:

```yaml
Metrics/ClassLength:
  Exclude:
    - lib/stimulus_plumbers/components/calendar/turbo.rb
    - lib/stimulus_plumbers/components/calendar/turbo/*.rb
    - lib/stimulus_plumbers/components/timeline/event.rb
    - lib/stimulus_plumbers/form/builder.rb
    - lib/stimulus_plumbers/form/field.rb
    - lib/stimulus_plumbers/password/requirements.rb
    - test/generators/**/*_test.rb
```

(Add only the `lib/stimulus_plumbers/password/requirements.rb` line — the surrounding lines already exist.)

- [ ] **Step 5: Run the new test + rubocop**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/password/requirements_test.rb`
Expected: PASS (14 runs, 0 failures).
Run: `bundle exec rubocop lib/stimulus_plumbers/password/requirements.rb test/stimulus_plumbers/password/requirements_test.rb`
Expected: 0 offenses.

- [ ] **Step 6: Commit**

```bash
git add lib/stimulus_plumbers/password/requirements.rb test/stimulus_plumbers/password/requirements_test.rb lib/stimulus_plumbers.rb .rubocop.yml
git commit -m "feat(rails): Password::Requirements rule set with evaluate/valid?/to_stimulus"
```

---

## Task 3: Rewire form field + component onto `Requirements`

**Files:**
- Modify: `lib/stimulus_plumbers/form/fields/inputs/password.rb:36-57`
- Modify: `lib/stimulus_plumbers/form/fields/inputs/password/strength.rb`
- Modify: `lib/stimulus_plumbers/components/password_strength.rb`
- Delete: `lib/stimulus_plumbers/form/fields/inputs/password/config.rb`
- Delete: `test/stimulus_plumbers/form/fields/inputs/password_config_test.rb`
- Modify: `lib/stimulus_plumbers/form/fields/inputs/password.rb:3` (drop `require_relative "password/config"`)
- Test: `test/stimulus_plumbers/form/fields/inputs/password_test.rb`
- Test: `test/stimulus_plumbers/components/password_strength_test.rb` — its `config` helper builds the deleted `Password::Config`; repoint at `Requirements`.
- Test: `test/stimulus_plumbers/form/builder_test.rb` — two builder tests reference the renamed reader / deleted `strength_options`.

**Interfaces:**
- Consumes: `Password::Requirements` (Task 2).
- Produces: the wrapper `div` now carries `data-password-strength-rules-value` (JSON descriptor array), `data-password-strength-options-value` (`{"low":N}`), and `data-password-strength-labels-value`. Checklist `<li data-rule="KEY">` and the meter are unchanged in structure.

- [ ] **Step 1: Update the two form-field strength tests that assert the old options shape**

In `test/stimulus_plumbers/form/fields/inputs/password_test.rb`, replace `test_options_json_is_camel_cased_and_carries_thresholds` with two tests, and update `test_strength_block_renders_meter_level_and_rules` to require `max_length`:

```ruby
  def test_strength_block_renders_meter_level_and_rules
    doc = build_field { |p| p.strength(min_length: 12, max_length: 64, digit: true) }

    assert_css doc, "[data-controller='password-strength']"
    assert_css doc, "meter[data-progress-target='meter'][low='34'][high='100'][optimum='100']"
    assert_css doc, "p[data-password-strength-target='level'][aria-live='polite']"
    assert_css doc, "ul li[data-rule='length']"
    assert_css doc, "ul li[data-rule='digit']", text: "One number"
  end

  # Reads a JSON data-* value attribute off the wrapper. Shared to keep each
  # test under Metrics/AbcSize (inlining JSON.parse(at_css(...)) trips it).
  def strength_value(doc, name)
    JSON.parse(doc.at_css("[#{name}]")[name])
  end

  def test_rules_value_carries_descriptors
    doc = build_field { |p| p.strength(min_length: 12, max_length: 64, digit: 2) }
    rules = strength_value(doc, "data-password-strength-rules-value")

    length = rules.find { |r| r["key"] == "length" }
    digit = rules.find { |r| r["key"] == "digit" }

    assert_equal({ "key" => "length", "label" => "At least 12 characters", "min" => 12, "max" => 64 }, length)
    assert_equal "\\d", digit["pattern"]
    assert_equal 2, digit["min"]
    assert_not digit.key?("max")
  end

  def test_options_value_carries_low_threshold
    doc = build_field { |p| p.strength(min_length: 8, max_length: 64, low: 20) }
    options = strength_value(doc, "data-password-strength-options-value")

    assert_equal({ "low" => 20 }, options)
  end
```

Then update every other `p.strength(...)` call in this file to include `max_length: 64` alongside `min_length:` (the length rule now requires it): `test_outlet_selector_matches_the_meter_id`, `test_strength_wrapper_carries_level_labels`, `test_custom_thresholds_reach_the_meter_attributes`, `test_rules_list_id_joins_described_by_without_replacing_hint_and_error`. (`test_rule_state_is_conveyed_by_icon_and_text_not_color` uses `digit: true` only — no length rule — leave it.) For `test_custom_thresholds_reach_the_meter_attributes`, keep `low: 20, high: 80` and add `max_length: 64`.

- [ ] **Step 2: Run the field tests, watch the new ones fail**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: FAIL on `test_rules_value_carries_descriptors` / `test_options_value_carries_low_threshold` (no `rules-value` attr yet).

- [ ] **Step 3: Point the form field at `Requirements`**

In `lib/stimulus_plumbers/form/fields/inputs/password.rb`: delete line 3 `require_relative "password/config"`. Rename the config ivar/reader to requirements. Replace the `attr_reader`, `render_password_input` body references, and `build_password_config`:

```ruby
          # Requirements collected from a `field` block, held for the renderer.
          attr_reader :password_requirements
```

```ruby
          def render_password_input(attribute, html_opts, opts, error, floating: nil, revealable: false, **kwargs, &block)
            @password_requirements = build_password_requirements(&block)
            input_id = html_opts[:id]
            html_options = password_html_options(html_opts, opts, error, floating, kwargs)
            html_options = apply_strength_wiring(html_options, input_id) if @password_requirements.strength?
            input = if revealable
                      render_revealable_password(error, floating: floating) do
                        revealable_html_options = merge_html_options(html_options, { data: { input_revealable_target: "input" } })
                        @template.password_field(@object_name, attribute, objectify_options(revealable_html_options))
                      end
                    else
                      @template.password_field(@object_name, attribute, objectify_options(html_options))
                    end
            return input unless @password_requirements.strength?

            wrap_with_strength(input, input_id)
          end

          def build_password_requirements(&block)
            StimulusPlumbers::Password::Requirements.build(&block)
          end
```

> **Must be fully qualified.** This method lives inside `module Password` (i.e. `Inputs::Password`), so a bare `Password::Requirements` resolves lexically to the non-existent `Inputs::Password::Requirements`. Write `StimulusPlumbers::Password::Requirements`.

- [ ] **Step 4: Update the strength wiring module**

In `lib/stimulus_plumbers/form/fields/inputs/password/strength.rb`, replace `@password_config` with `@password_requirements` in `wrap_with_strength`:

```ruby
            def wrap_with_strength(input, input_id)
              Components::PasswordStrength.new(@template).render(input: input, input_id: input_id, config: @password_requirements)
            end
```

- [ ] **Step 5: Consume `to_stimulus` in the component**

In `lib/stimulus_plumbers/components/password_strength.rb`, replace `render`, add a private `wrapper_options` helper, and delete `strength_stimulus_options`. (The helper keeps `render` under the `Metrics/AbcSize` limit — inlining the three `stimulus[:…].to_json` calls trips it. The data-hash colons are table-aligned per `Layout/HashAlignment`.)

Replace the `render` method with:

```ruby
      def render(input:, input_id:, config:)
        @config = config
        template.content_tag(:div, **wrapper_options(config, input_id)) do
          template.safe_join([input, render_meter(input_id), render_level, render_rules(input_id)])
        end
      end
```

Then insert `wrapper_options` as the first method **after the existing `private` keyword** (before `render_meter`) — do not add a second `private`:

```ruby
      def wrapper_options(config, input_id)
        stimulus = config.to_stimulus
        merge_html_options(
          theme.resolve(:password_strength_wrapper),
          data: {
            controller:                        "password-strength",
            password_strength_rules_value:     stimulus[:rules].to_json,
            password_strength_options_value:   stimulus[:options].to_json,
            password_strength_labels_value:    stimulus[:labels].to_json,
            password_strength_progress_outlet: "##{self.class.meter_id_for(input_id)}"
          }
        )
      end
```

`render_meter` still uses `@config.thresholds`; `render_rules` still uses `@config.rules`; `render_level` still uses `level_labels`. Those methods are unchanged. Delete the `strength_stimulus_options` method entirely (it referenced the deleted `Config::DEFAULT_THRESHOLDS`).

- [ ] **Step 5b: Repoint the two other tests that reference the deleted `Config`**

`Requirements` exposes `strength?` / `rules` — not `strength_options` — and enabling length now requires `max_length`. Update both files.

In `test/stimulus_plumbers/components/password_strength_test.rb`, replace the `config` helper:

```ruby
  def config
    StimulusPlumbers::Password::Requirements.build do |req|
      req.strength(min_length: 12, max_length: 64, digit: true)
    end
  end
```

In `test/stimulus_plumbers/form/builder_test.rb`, replace the two password tests:

```ruby
  def test_field_yields_password_builder_and_forwards_collected_strength_requirements
    builder = nil

    build_form do |f|
      builder = f
      f.field :password, as: :password do |password|
        password.strength min_length: 12, max_length: 64
      end
    end

    assert_predicate builder.password_requirements, :strength?
    assert_equal({ length: "At least 12 characters" }, builder.password_requirements.rules)
  end

  def test_field_without_a_block_builds_requirements_without_strength
    builder = nil

    build_form do |f|
      builder = f
      f.field :password, as: :password
    end

    assert_not builder.password_requirements.strength?
  end
```

- [ ] **Step 6: Delete the old config + its test**

```bash
git rm lib/stimulus_plumbers/form/fields/inputs/password/config.rb test/stimulus_plumbers/form/fields/inputs/password_config_test.rb
```

- [ ] **Step 7: Run the full unit suite + rubocop**

Run: `bundle exec rake test:unit`
Expected: PASS, 0 failures/errors (the component test `PasswordStrengthTest` and `PasswordTest` both green).
Run: `bundle exec rake rubocop`
Expected: 0 offenses.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor(rails): drive password strength UI from Password::Requirements"
```

---

## Task 4: `PasswordStrengthValidator` (ActiveModel enforcement)

**Files:**
- Create: `lib/stimulus_plumbers/password_strength_validator.rb`
- Modify: `lib/stimulus_plumbers.rb` (require it)
- Modify: `config/locales/en.yml` (error copy)
- Test: `test/stimulus_plumbers/password_strength_validator_test.rb`

**Interfaces:**
- Consumes: `Password::Requirements` (Task 2).
- Produces: top-level `::PasswordStrengthValidator < ActiveModel::EachValidator`, so `validates :attr, password_strength: { with: requirements }` or `validates :attr, password_strength: { min_length: 8, max_length: 64, digit: true }` resolve via Rails' symbol lookup. On failure adds one error per unmet rule using the rule label, or the `:message` option when given.

- [ ] **Step 1: Write the failing test**

Create `test/stimulus_plumbers/password_strength_validator_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class PasswordStrengthValidatorTest < ActiveSupport::TestCase
  class Account
    include ActiveModel::Validations

    attr_accessor :password

    def initialize(password)
      @password = password
    end
  end

  def account_class(**options)
    Class.new(Account) { validates :password, password_strength: options }
  end

  def test_valid_password_passes
    klass = account_class(min_length: 4, max_length: 64, digit: true)

    assert_predicate klass.new("abcd1"), :valid?
  end

  def test_unmet_rules_add_errors_by_label
    klass = account_class(min_length: 8, max_length: 64, digit: true)
    account = klass.new("abc")
    account.validate

    assert_includes account.errors[:password], "At least 8 characters"
    assert_includes account.errors[:password], "One number"
  end

  def test_accepts_a_shared_requirements_object
    requirements = StimulusPlumbers::Password::Requirements.build { |r| r.strength(min_length: 4, max_length: 64) }
    klass = Class.new(Account) { validates :password, password_strength: { with: requirements } }

    assert_predicate klass.new("abcd"), :valid?
    assert_not_predicate klass.new("ab"), :valid?
  end

  def test_custom_message_overrides_labels
    klass = account_class(min_length: 8, max_length: 64, message: "is too weak")
    account = klass.new("abc")
    account.validate

    assert_equal ["is too weak"], account.errors[:password]
  end
end
```

- [ ] **Step 2: Run it, watch it fail**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/password_strength_validator_test.rb`
Expected: FAIL — `Unknown validator: 'PasswordStrengthValidator'`.

- [ ] **Step 3: Implement the validator**

Create `lib/stimulus_plumbers/password_strength_validator.rb`:

```ruby
# frozen_string_literal: true

require_relative "password/requirements"

# Top-level so `validates :attr, password_strength: {...}` resolves via Rails' symbol lookup.
class PasswordStrengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    requirements = options[:with] || build_requirements
    result = requirements.evaluate(value.to_s)
    return if result[:rules].any? && result[:rules].values.all?

    unmet_messages(requirements, result).each { |message| record.errors.add(attribute, message) }
  end

  private

  def build_requirements
    StimulusPlumbers::Password::Requirements.build do |req|
      req.strength(**options.except(:with, :message, :on, :if, :unless, :allow_nil, :allow_blank))
    end
  end

  def unmet_messages(requirements, result)
    return [options[:message]] if options[:message]

    labels = requirements.rules
    result[:rules].reject { |_key, ok| ok }.keys.map { |key| labels[key] }
  end
end
```

- [ ] **Step 4: Require it after the engine loads**

In `lib/stimulus_plumbers.rb`, add (after the `require "stimulus_plumbers/engine"` / Active-model is available):

```ruby
require_relative "stimulus_plumbers/password_strength_validator"
```

- [ ] **Step 5: Run the validator test + rubocop**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/password_strength_validator_test.rb`
Expected: PASS (4 runs, 0 failures).
Run: `bundle exec rubocop lib/stimulus_plumbers/password_strength_validator.rb test/stimulus_plumbers/password_strength_validator_test.rb`
Expected: 0 offenses.

- [ ] **Step 6: Commit**

```bash
git add lib/stimulus_plumbers/password_strength_validator.rb test/stimulus_plumbers/password_strength_validator_test.rb lib/stimulus_plumbers.rb
git commit -m "feat(rails): PasswordStrengthValidator enforcing Requirements server-side"
```

---

## Task 5: JS/Ruby parity fixture

**Files:**
- Create: `stimulus-plumbers/tests/fixtures/password_rules.json`
- Modify: `stimulus-plumbers/tests/unit/plumbers/password_strength.test.js` (load fixture)
- Create: `stimulus-plumbers-rails/test/stimulus_plumbers/password/parity_test.rb`

**Interfaces:**
- Fixture entry: `{ "name", "rules": [descriptor...], "password", "expected": { "rules": { key: bool }, "valid": bool } }`. Descriptors use the wire shape (`min` present, `max` optional, `pattern` string). Both suites compute results and assert equality to `expected`.
- The gem test resolves the fixture at `../../stimulus-plumbers/tests/fixtures/password_rules.json` relative to the gem root (monorepo sibling). Both packages live under the same monorepo root.

- [ ] **Step 1: Create the fixture**

Create `stimulus-plumbers/tests/fixtures/password_rules.json`:

```json
[
  {
    "name": "all rules met",
    "rules": [
      { "key": "length", "min": 8, "max": 64 },
      { "key": "uppercase", "pattern": "[A-Z]", "min": 1 },
      { "key": "digit", "pattern": "\\d", "min": 2 }
    ],
    "password": "Abcdef12",
    "expected": { "rules": { "length": true, "uppercase": true, "digit": true }, "valid": true }
  },
  {
    "name": "too short and one digit",
    "rules": [
      { "key": "length", "min": 8, "max": 64 },
      { "key": "digit", "pattern": "\\d", "min": 2 }
    ],
    "password": "ab1",
    "expected": { "rules": { "length": false, "digit": false }, "valid": false }
  },
  {
    "name": "max occurrence exceeded",
    "rules": [{ "key": "digit", "pattern": "\\d", "min": 0, "max": 2 }],
    "password": "a123",
    "expected": { "rules": { "digit": false }, "valid": false }
  },
  {
    "name": "forbid whitespace",
    "rules": [{ "key": "no_spaces", "pattern": "\\s", "min": 0, "max": 0 }],
    "password": "a b",
    "expected": { "rules": { "no_spaces": false }, "valid": false }
  },
  {
    "name": "length upper bound",
    "rules": [{ "key": "length", "min": 1, "max": 4 }],
    "password": "abcde",
    "expected": { "rules": { "length": false }, "valid": false }
  }
]
```

- [ ] **Step 2: Add the JS parity test**

Append to `stimulus-plumbers/tests/unit/plumbers/password_strength.test.js`:

```js
import fixtures from '../../fixtures/password_rules.json';

describe('parity fixture', () => {
  fixtures.forEach((fixture) => {
    it(fixture.name, () => {
      const result = score(fixture.password, fixture.rules, {});
      expect(result.rules).toEqual(fixture.expected.rules);
      const valid = fixture.rules.length > 0 && Object.values(result.rules).every(Boolean);
      expect(valid).toBe(fixture.expected.valid);
    });
  });
});
```

- [ ] **Step 3: Run the JS suite**

Run: `node --run test tests/unit/plumbers/password_strength.test.js`
Expected: PASS (all fixture rows green).

- [ ] **Step 4: Add the Ruby parity test**

Create `stimulus-plumbers-rails/test/stimulus_plumbers/password/parity_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "json"

class PasswordParityTest < ActiveSupport::TestCase
  FIXTURE = File.expand_path("../../../../stimulus-plumbers/tests/fixtures/password_rules.json", __dir__)

  # Rebuild a Requirements from raw wire descriptors so the exact fixture rules are
  # evaluated through the same satisfies?/evaluate path the DSL produces. @strength_options
  # is set to {} (not nil) so strength? is true and descriptors are emitted; the built-ins
  # are all absent from {} so only the fixture's @custom descriptors are evaluated.
  def requirements_for(rules)
    req = StimulusPlumbers::Password::Requirements.new
    req.instance_variable_set(:@strength_options, {})
    req.instance_variable_set(:@custom, custom_from(rules))
    req
  end

  def custom_from(rules)
    rules.to_h do |rule|
      [rule["key"].to_sym, { pattern: rule["pattern"], min: rule["min"], max: rule["max"], label: rule["key"] }]
    end
  end

  JSON.parse(File.read(FIXTURE)).each do |fixture|
    define_method("test_parity_#{fixture["name"].gsub(%r{\W+}, "_")}") do
      req = requirements_for(fixture["rules"])
      result = req.evaluate(fixture["password"])
      expected = fixture["expected"]["rules"].transform_keys(&:to_sym)

      assert_equal expected, result[:rules]
      assert_equal fixture["expected"]["valid"], req.valid?(fixture["password"])
    end
  end
end
```

> Note: the fixture descriptors — including the built-in `length`/`digit` — are fed through the custom-rule path so the Ruby side evaluates the exact same wire descriptors the JS side does. `length` has no `pattern`, so `custom_from` yields `pattern: nil`, and `satisfies?` falls back to `password.length`. This deliberately exercises the same `satisfies?` code path for every descriptor.

- [ ] **Step 5: Run the Ruby parity test**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/password/parity_test.rb`
Expected: PASS (5 runs, 0 failures). If a row disagrees, the regex-engine contract was violated — fix the descriptor/pattern, not the assertion.

- [ ] **Step 6: Commit (both packages)**

```bash
cd stimulus-plumbers && git add tests/fixtures/password_rules.json tests/unit/plumbers/password_strength.test.js
cd ../stimulus-plumbers-rails && git add test/stimulus_plumbers/password/parity_test.rb
cd .. && git commit -m "test: shared JS/Ruby password rule parity fixture"
```

---

## Task 5b: Shared `requirements:` form option

Spec Section C's headline path — `f.field :password, as: :password, requirements: PASSWORD_RULES` — lets one `Requirements` object drive both the live meter and the model validator (no drift). Tasks 3–5 only wired the field block; this adds the shared-object option.

**Files:**
- Modify: `lib/stimulus_plumbers/form/fields/inputs/password.rb`
- Test: `test/stimulus_plumbers/form/fields/inputs/password_test.rb`

**Interfaces:**
- Consumes: `Password::Requirements` (Task 2).
- Produces: `render_password_input` accepts a `requirements:` field option (a prebuilt `Requirements`); when present it takes precedence over a field block. Extracted from `kwargs` (not added to the signature) so it never leaks as an HTML attribute and the signature stays within `Layout/LineLength`.

- [ ] **Step 1: Add the failing test**

Append to `test/stimulus_plumbers/form/fields/inputs/password_test.rb` (uses the existing `strength_value` helper):

```ruby
  def test_shared_requirements_object_drives_the_meter
    rules = StimulusPlumbers::Password::Requirements.build { |r| r.strength(min_length: 8, max_length: 64, digit: true) }
    doc = build_field(requirements: rules)
    descriptors = strength_value(doc, "data-password-strength-rules-value")

    assert_css doc, "[data-controller='password-strength']"
    assert(descriptors.any? { |d| d["key"] == "digit" })
  end
```

- [ ] **Step 2: Run it, watch it fail**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: FAIL — with no `requirements:` handling, the object leaks into `kwargs`/HTML and no `password-strength` wrapper renders.

- [ ] **Step 3: Extract `requirements:` in the renderer**

In `lib/stimulus_plumbers/form/fields/inputs/password.rb`, change the first line of `render_password_input`:

```ruby
          def render_password_input(attribute, html_opts, opts, error, floating: nil, revealable: false, **kwargs, &block)
            # A shared `requirements:` object (spec Section C) takes precedence over a field block.
            @password_requirements = kwargs.delete(:requirements) || build_password_requirements(&block)
```

(Keep `requirements` out of the method signature — extracting via `kwargs.delete` keeps the signature under 130 cols and strips the key before `password_html_options` turns leftover kwargs into HTML attributes.)

- [ ] **Step 4: Run test + rubocop + full suite**

Run: `bundle exec ruby -Itest test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: PASS (42 runs, 0 failures).
Run: `bundle exec rubocop lib/stimulus_plumbers/form/fields/inputs/password.rb test/stimulus_plumbers/form/fields/inputs/password_test.rb`
Expected: 0 offenses.
Run: `bundle exec rake test:unit`
Expected: green (1,420 runs).

- [ ] **Step 5: Commit**

```bash
git add lib/stimulus_plumbers/form/fields/inputs/password.rb test/stimulus_plumbers/form/fields/inputs/password_test.rb
git commit -m "feat(rails): shared requirements: option on password field"
```

---

## Task 6: Docs, locale, and conventions

**Files:**
- Modify: `stimulus-plumbers/docs/component/password-strength.md`
- Modify: `stimulus-plumbers-rails/docs/component/form.md` (there is **no** `password.md`; the password field is documented inline in `form.md`)
- Modify: `stimulus-plumbers-rails/README.md`
- Modify: `stimulus-plumbers-rails/CLAUDE.md` (folder structure: drop `config.rb`, add `password/requirements.rb` + `password_strength_validator.rb`)
- `config/locales/en.yml` — unchanged (see locale note)

**Interfaces:** documentation only; no code behavior.

- [ ] **Step 1: Update the JS controller doc**

In `stimulus-plumbers/docs/component/password-strength.md`, add the `rules` value row (Array, `[]`) to the Values table and a "Rule descriptors" section: descriptor shape `{ key, label?, pattern?, min?, max? }`, the `min ≤ n ≤ max` semantics (length vs occurrence count with the JS `match(/…/g)` count), defaults (`min` 0 / `max` Infinity), the character-class portability constraint, and the `level`/`options.low` rule. This is the single home of the wire contract. Keep it concise.

- [ ] **Step 2: Update the Rails form doc (form.md, not password.md)**

`stimulus-plumbers-rails/docs/component/password.md` does not exist — the password field lives in `docs/component/form.md`. Three edits there:
- The `f.field` erb example: `p.strength min_length: 12` → add `, max_length: 64`.
- The block-DSL paragraph: replace the `[Plumber::Config](plumber.md#plumberconfig)` reference with `Password::Requirements` (accepts `strength(**options)` and `rule(...)`; "see **Password** below").
- The **Password** section: add a `requirements` option row, a "Strength rules" paragraph (DSL: `strength` built-ins take `true`/Int/Range, length needs both bounds; `rule(key, label, pattern:, min:, max:, negate:)`), and a "Server enforcement" block showing the shared `PASSWORD_RULES` driving both `validates :password, password_strength: { with: PASSWORD_RULES }` and `f.field :password, requirements: PASSWORD_RULES`, plus the inline-options + `message:` forms. Link the wire contract to the JS doc; do not restate it.
- Run `npm run format:docs` from the monorepo root afterward (prettier reflows the option tables).

- [ ] **Step 3: Update CLAUDE.md folder structure**

In `stimulus-plumbers-rails/CLAUDE.md`, delete the now-removed `config.rb` line from the `inputs/password/` block:

```
│       │           │   ├── config.rb     # Password::Config — field block DSL (strength options, rule label overrides, thresholds)
```

and add these two entries among the top-level `lib/stimulus_plumbers/` files (before `configuration.rb`):

```
│       ├── password/
│       │   └── requirements.rb           # Password::Requirements — rule DSL + evaluate/valid?/to_stimulus (server + client source of truth)
│       ├── password_strength_validator.rb # Top-level PasswordStrengthValidator (ActiveModel::EachValidator)
```

(Match the exact tree indentation of the surrounding lines.)

- [ ] **Step 4: Update the README**

`stimulus-plumbers-rails/README.md` has no per-password row; add one line to the **Form Builder** section (after its intro sentence): password fields support strength rules that also enforce server-side via `validates :password, password_strength:`.

- [ ] **Step 5: Docs format check + full suites**

Run: `npm run format:docs:check` (monorepo root) — expected: all files pass (run `npm run format:docs` first if it flags the edited docs).
Run: `bundle exec rake test:unit && bundle exec rake rubocop` (gem) and `node --run test` (npm).
Expected: all green (gem 1,420 runs; JS 1,096 tests).

- [ ] **Step 6: Commit** (docs only — commit Task 5b's code separately first)

```bash
cd stimulus-plumbers && git add docs/component/password-strength.md
cd ../stimulus-plumbers-rails && git add docs/component/form.md README.md CLAUDE.md
cd .. && git commit -m "docs: password rule registry, valid?, and validator usage"
```

Do not `git add -A` — the implementation-plan file under `docs/superpowers/` is intentionally left unstaged.

> **Locale note (Step for Task 4, revisit here):** the validator uses rule labels for messages, so no new locale key is strictly required. If a default fallback message is wanted when `message:` is absent and labels are empty, add `stimulus_plumbers.errors.password_strength: "is not strong enough"` to `config/locales/en.yml` and use it in `unmet_messages`. Left out by default (YAGNI) — only add if a reviewer wants a non-label fallback.

---

## Self-Review

**Spec coverage:**
- Section A (rename + standalone, no `Plumber::Config`) → Task 2 (`Requirements` standalone) + Task 3 (delete `config.rb`, rewire). ✓
- Section B (uniform descriptor, count model, portability, serialization rule) → Task 2 (`descriptors`/`serialize`/`satisfies?`) + Global Constraints. ✓
- Section C (evaluate/valid?, count DSL true/int/range, length requires both, shared Requirements, validator) → Tasks 2 + 4. ✓
- Section D (JS data-driven, no built-in table, rules value) → Task 1. ✓
- Section E (Ruby unit, JS unit, parity fixture) → Tasks 2, 1, 5. ✓
- `negate` sugar → Task 2 (`rule`) + fixture forbid row. ✓

**Type consistency:** `to_stimulus` keys (`:rules`/`:options`/`:labels`) match the component's `stimulus[:rules|:options|:labels]` (Task 3) and the controller's `rulesValue`/`optionsValue`/`labelsValue` (Task 1). Descriptor wire keys (`key`/`label`/`pattern`/`min`/`max`) match across Ruby `serialize`, JS `satisfies`, and the fixture. `evaluate` returns `level` as a String (`"weak"`) matching JS. ✓

**Placeholder scan:** no TBD/TODO; every code step shows complete code. The locale note is an explicit optional, not a placeholder. ✓

**Open flag for the executor:** Task 4 defines a **top-level** `PasswordStrengthValidator` (required for the `password_strength:` symbol to resolve). If polluting the top-level namespace is unacceptable, the fallback is `validates_with StimulusPlumbers::PasswordStrengthValidator` with a namespaced class — but that changes the approved usage syntax.
