# password-strength

Live password meter and requirements checklist. Scoring is provided by the [password strength plumber](../plumber/password_strength.md).

## Targets

| Target                    | Element   | Description                                             |
| ------------------------- | --------- | ------------------------------------------------------- |
| `input`                   | `<input>` | Password input to score                                 |
| `rule`                    | `<li>`    | Requirement row with `data-rule` and `data-satisfied`   |
| `level`                   | Element   | Visible, polite live strength label                     |
| `checkIcon` / `closeIcon` | `<svg>`   | Paired rule-state icons; both are required for swapping |

## Values and outlet

| Name              | Type       | Default   |
| ----------------- | ---------- | --------- |
| `scorer`          | String     | `'rules'` |
| `rules`           | Array      | `[]`      |
| `options`         | Object     | `{}`      |
| `labels`          | Object     | `{}`      |
| `announceDelay`   | Number     | `700`     |
| `progress` outlet | Controller | —         |

`score()` is wired to the input event. It updates the progress outlet immediately and debounces level-label changes.

## Rule descriptors

The controller holds no built-in rule table — the server (or a standalone caller) supplies every rule as data via the `rules` value. Each descriptor is `{ key, label?, pattern?, min?, max? }` and passes when `min ≤ n ≤ max`, where `n` is:

- **length** (no `pattern`) — the password length.
- **count** (with `pattern`) — non-overlapping occurrences of `pattern`: `(pw.match(new RegExp(pattern, "g")) || []).length`.

Defaults: `min` `0`, `max` `Infinity`. So `{ pattern: "\\d", min: 2 }` requires ≥2 digits, and `{ pattern: "\\s", min: 0, max: 0 }` forbids whitespace.

**Portability constraint:** patterns must be single-char-consuming character classes — no anchors (`^`/`$`), lookbehind, or unicode-property escapes — so non-overlapping counts agree across the Ruby and JS regex engines.

The strength `level` is `strong` when every rule passes; otherwise the score (`satisfied / total × 100`) splits `weak` from `fine` at `options.low` (default `34`). `options` carries only these non-rule knobs.
