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
