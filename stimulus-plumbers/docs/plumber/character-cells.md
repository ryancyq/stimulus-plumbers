# character-cells

Paints one canonical string value into a row of author-rendered character cells. Attached by
[input-formatter](../component/input-formatter.md) when `cell` targets exist; usable by any
controller with `cellTargets`.

## Attach

```js
import { attachCharacterCells } from '@stimulus-plumbers/controllers';

attachCharacterCells(this, { groups: [4, 4, 4, 4], length: 16 });
```

| Option   | Type       | Default | Description                                                           |
| -------- | ---------- | ------- | --------------------------------------------------------------------- |
| `groups` | `Number[]` | `[]`    | Group widths; empty = uniform single-character cells                  |
| `length` | `Number`   | `0`     | Expected value length; `0` derives from `groups` sum, else cell count |

### Grouped mode

No separate option — inferred automatically when the adopted cell count exactly equals
`groups.length` (one cell per group, e.g. 4 cells for `groups: [4, 4, 4, 4]`). Each cell then
holds its whole slice (`value.slice(groupStart, groupEnd)`) instead of a single character.
Width-1 groups degenerate to identical per-character rendering, so a coincidental match is
harmless. Render `groups.sum` cells (one per character) instead of `groups.length` to keep
the original per-character behavior.

## Helpers (`controller.characterCells`)

| Helper                     | Description                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------ |
| `draw(value, { focused })` | Writes `value[i]` per active cell, or (grouped mode) each cell's group slice of `value`          |
| `clear()`                  | Empties every cell (`draw('')`)                                                                  |
| `active()`                 | Number of characters in play — cell count capped by expected length, or full length when grouped |

## Cell state attributes

| Attribute          | When                                                         |
| ------------------ | ------------------------------------------------------------ |
| `data-filled`      | Cell holds a character (or, grouped mode, a non-empty slice) |
| `data-caret`       | Cell at the input position, only while `focused` is true     |
| `data-group-index` | Group ordinal (0-based) when `groups` configured             |
| `data-group-end`   | Last cell of its group (non-grouped mode only)               |
| `data-inactive`    | Cell beyond the expected length                              |

## Notes

- Accessibility: see [ARIA.md's Code Input pattern](../../../ARIA.md).
- The plumber never generates DOM: render exactly as many cells as the expected length (or, in grouped mode, `groups.length`), or extras become `data-inactive`; too few logs a console warning.
- The plumber never inserts separator elements. Separators between cells/groups are authored HTML or CSS decoration — a CSS gap keyed on `[data-group-end]` in non-grouped mode, or a real authored element between cells in grouped mode (since the whole cell is already one group, `data-group-end` doesn't apply there).
