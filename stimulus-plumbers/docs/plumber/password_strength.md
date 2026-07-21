# Password strength

Attaches password scoring to a controller as `this.strength.score(password, rules, options)`.

## Factory

```js
import { attachPasswordStrength } from '@stimulus-plumbers/controllers';

attachPasswordStrength(controller, { type: 'rules' });
```

## Score result

`score(password, rules, options)` returns `{ value, level, rules }`: `value` is 0–100, `level` is `weak`, `fine`, or `strong`, and the returned `rules` maps each descriptor's `key` to a boolean.

The scorer holds no built-in rule table — `rules` is a data-driven descriptor array (`{ key, label?, pattern?, min?, max? }`), each passing when `min ≤ n ≤ max`. See [password-strength.md → Rule descriptors](../component/password-strength.md#rule-descriptors) for the descriptor shape and the length-vs-occurrence-count semantics.

`strong` requires every rule; below that, `options.low` (default 34) splits `weak` from `fine`. The scorer ignores `high` — with few rules, "one rule missing" scores above any fixed high (2/3=67, 3/4=75), which would read strong while a rule is visibly unmet. `high` remains a `<meter>` coloring attribute only.

## Custom scorers

Register a scorer with `PasswordStrength.register(type, { score(password, rules, options) })` before the controller connects. Unknown types fall back to `rules`.
