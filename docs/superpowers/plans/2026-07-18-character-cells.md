# CharacterCells Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cell-based ("OTP boxes") display for `input-formatter` via a new `CharacterCells` plumber and a new `code` formatter — no new controller.

**Architecture:** A `CharacterCells` plumber paints one canonical string into author-rendered `cell` targets (data-attribute state, `aria-hidden` stamped). A `code` formatter strategy handles charset filtering + length validation. `input-formatter` attaches the plumber only when `cell` targets exist, so all existing usage is untouched. Spec: `docs/superpowers/specs/2026-07-18-character-cells-design.md`.

**Tech Stack:** Stimulus controllers, Vitest (jsdom), plain ES modules. All work in `stimulus-plumbers/` (npm package) except doc files noted in Task 5.

## Global Constraints

- Working directory for all commands: `stimulus-plumbers/` (the npm package inside the monorepo).
- Import statements must NOT end with `.js` inside `src/` module code (repo CLAUDE.md) — except `src/index.js`, which already uses `.js` suffixes; match each file's existing style.
- Test files use no semicolons at line ends where the surrounding file omits them; source files use semicolons. Match the file you're editing. Prettier (`npm run format:check`) is the arbiter.
- Cell state uses data-attributes (`data-filled`, `data-caret`, `data-group-index`, `data-group-end`, `data-inactive`), never CSS classes.
- The plumber never generates DOM and never reads the input element — it receives strings via `draw(value)`.
- Run `npm test`, `npm run lint`, and `npm run format:check` synchronously from `stimulus-plumbers/`; never background them.
- `cp` is aliased to `cp -iv` in this shell — use `\cp` if a copy is ever needed.

---

### Task 1: `code` formatter

**Files:**
- Create: `src/plumbers/formatters/code.js`
- Modify: `src/plumbers/formatter.js` (register type)
- Test: `tests/unit/plumbers/formatters/code.test.js`

**Interfaces:**
- Consumes: nothing new.
- Produces: `CodeFormatter` with `normalize(raw, opts)`, `validate(value, opts)`, `format(value)`, `cells(opts)`; `FORMATTER_TYPES.CODE === 'code'`. Options: `{ charset: 'digits'|'letters'|'alphanumeric', length: Number }`. `cells(opts)` returns `{ groups: [], length: opts.length ?? 0 }` — the grouping hint consumed by Task 4.

- [ ] **Step 1: Write the failing test**

Create `tests/unit/plumbers/formatters/code.test.js`:

```js
import { describe, it, expect } from 'vitest'
import { CodeFormatter } from '../../../../src/plumbers/formatters/code'

describe('CodeFormatter', () => {
  describe('normalize', () => {
    it('strips non-digits when charset is digits', () => {
      expect(CodeFormatter.normalize('4 8-29 13', { charset: 'digits' })).toBe('482913')
    })

    it('strips digits and symbols when charset is letters', () => {
      expect(CodeFormatter.normalize('ab-12cd', { charset: 'letters' })).toBe('ABCD')
    })

    it('keeps letters and digits when charset is alphanumeric', () => {
      expect(CodeFormatter.normalize('a1-b2 c3', { charset: 'alphanumeric' })).toBe('A1B2C3')
    })

    it('defaults to alphanumeric charset', () => {
      expect(CodeFormatter.normalize('a1!b2')).toBe('A1B2')
    })

    it('uppercases letters', () => {
      expect(CodeFormatter.normalize('abc', { charset: 'letters' })).toBe('ABC')
    })

    it('truncates to length when length is set', () => {
      expect(CodeFormatter.normalize('12345678', { charset: 'digits', length: 6 })).toBe('123456')
    })

    it('does not truncate when length is 0 or unset', () => {
      expect(CodeFormatter.normalize('12345678', { charset: 'digits' })).toBe('12345678')
    })

    it('returns empty string for non-string input', () => {
      expect(CodeFormatter.normalize(null)).toBe('')
      expect(CodeFormatter.normalize(undefined)).toBe('')
    })
  })

  describe('validate', () => {
    it('is true only at exact length when length is set', () => {
      expect(CodeFormatter.validate('482913', { length: 6 })).toBe(true)
      expect(CodeFormatter.validate('4829', { length: 6 })).toBe(false)
      expect(CodeFormatter.validate('4829131', { length: 6 })).toBe(false)
    })

    it('is true at any length when length is unset', () => {
      expect(CodeFormatter.validate('4829')).toBe(true)
    })

    it('is false for non-string input', () => {
      expect(CodeFormatter.validate(null)).toBe(false)
    })
  })

  describe('format', () => {
    it('returns the value unchanged (cells handle display)', () => {
      expect(CodeFormatter.format('482913')).toBe('482913')
    })

    it('returns empty string for non-string input', () => {
      expect(CodeFormatter.format(null)).toBe('')
    })
  })

  describe('cells', () => {
    it('hints uniform cells with the configured length', () => {
      expect(CodeFormatter.cells({ length: 6 })).toEqual({ groups: [], length: 6 })
    })

    it('hints length 0 when unset', () => {
      expect(CodeFormatter.cells()).toEqual({ groups: [], length: 0 })
    })
  })
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- tests/unit/plumbers/formatters/code.test.js`
Expected: FAIL — cannot resolve `src/plumbers/formatters/code`.

- [ ] **Step 3: Write the formatter**

Create `src/plumbers/formatters/code.js`:

```js
/** Strip patterns per charset — everything NOT in the charset is removed */
const CHARSETS = {
  digits: /[^0-9]/g,
  letters: /[^a-zA-Z]/g,
  alphanumeric: /[^0-9a-zA-Z]/g,
};

export const CodeFormatter = {
  /**
   * Converts raw input to the canonical stored form: charset-filtered, uppercased,
   * truncated to `length` when set.
   * e.g. normalize('4 8-29 13', { charset: 'digits' }) → '482913'
   * @param {string} raw - Raw input
   * @param {Object} [opts={}] - Options
   * @param {string} [opts.charset='alphanumeric'] - 'digits' | 'letters' | 'alphanumeric'
   * @param {number} [opts.length=0] - Truncation length; 0 disables truncation
   * @returns {string} Canonical code string, or '' for non-string input
   */
  normalize(raw, opts = {}) {
    if (typeof raw !== 'string') return '';
    const strip = CHARSETS[opts.charset] ?? CHARSETS.alphanumeric;
    const value = raw.replace(strip, '').toUpperCase();
    const length = opts.length ?? 0;
    return length > 0 ? value.slice(0, length) : value;
  },

  /**
   * Validates the canonical code: exact length match when `length` is set.
   * @param {string} value - Canonical value from normalize()
   * @param {Object} [opts={}] - Options
   * @param {number} [opts.length=0] - Expected length; 0 accepts any
   * @returns {boolean}
   */
  validate(value, opts = {}) {
    if (typeof value !== 'string') return false;
    const length = opts.length ?? 0;
    return length > 0 ? value.length === length : true;
  },

  /**
   * Codes display as-is — CharacterCells handles visual chunking.
   * @param {string} value - Canonical value from normalize()
   * @returns {string}
   */
  format(value) {
    return typeof value === 'string' ? value : '';
  },

  /**
   * CharacterCells hint: uniform single-character cells, `length` cells expected.
   * @param {Object} [opts={}] - Formatter options
   * @returns {{ groups: number[], length: number }}
   */
  cells(opts = {}) {
    return { groups: [], length: opts.length ?? 0 };
  },
};
```

Register in `src/plumbers/formatter.js` — three edits:

```js
import { TimeFormatter } from './formatters/time';
import { CodeFormatter } from './formatters/code';
```

```js
export const FORMATTER_TYPES = {
  PLAIN: 'plain',
  CREDIT_CARD: 'creditCard',
  PHONE: 'phone',
  CURRENCY: 'currency',
  DATE: 'date',
  TIME: 'time',
  CODE: 'code',
};
```

```js
  [FORMATTER_TYPES.TIME, TimeFormatter],
  [FORMATTER_TYPES.CODE, CodeFormatter],
]);
```

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- tests/unit/plumbers/formatters/code.test.js`
Expected: PASS (all cases).

- [ ] **Step 5: Commit**

```bash
git add src/plumbers/formatters/code.js src/plumbers/formatter.js tests/unit/plumbers/formatters/code.test.js
git commit -m "feat: code formatter for fixed-alphabet values"
```

---

### Task 2: CharacterCells plumber

**Files:**
- Create: `src/plumbers/character_cells.js`
- Modify: `src/plumbers/index.js` (export), `src/index.js` (public export)
- Test: `tests/unit/plumbers/character_cells.test.js`

**Interfaces:**
- Consumes: `Plumber` base (`src/plumbers/plumber`), `setAriaHidden` (`src/accessibility/aria`), `controller.cellTargets` (array of elements).
- Produces: `attachCharacterCells(controller, { groups: Number[], length: Number })` → defines `controller.characterCells` with `draw(value, { focused = false })`, `clear()`, `active()`. Task 4 calls exactly these.

- [ ] **Step 1: Write the failing test**

Create `tests/unit/plumbers/character_cells.test.js`. The plumber only needs a controller-shaped object (`element`, `identifier`, `dispatch`, `cellTargets`) — no Stimulus application required, matching how it stays input-free:

```js
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { attachCharacterCells } from '../../../src/plumbers/character_cells'

const buildCells = (count) =>
  Array.from({ length: count }, () => {
    const cell = document.createElement('div')
    document.body.appendChild(cell)
    return cell
  })

const buildController = (cells) => ({
  element: document.body,
  identifier: 'input-formatter',
  dispatch: vi.fn(),
  cellTargets: cells,
})

describe('CharacterCells', () => {
  beforeEach(() => {
    document.body.innerHTML = ''
  })

  describe('adoption', () => {
    it('stamps aria-hidden on every cell', () => {
      const cells = buildCells(4)
      attachCharacterCells(buildController(cells), { length: 4 })
      cells.forEach((cell) => expect(cell.getAttribute('aria-hidden')).toBe('true'))
    })

    it('marks cells beyond the expected length as data-inactive', () => {
      const cells = buildCells(8)
      attachCharacterCells(buildController(cells), { length: 6 })
      expect(cells[5].hasAttribute('data-inactive')).toBe(false)
      expect(cells[6].hasAttribute('data-inactive')).toBe(true)
      expect(cells[7].hasAttribute('data-inactive')).toBe(true)
    })

    it('warns once when there are fewer cells than expected', () => {
      const warn = vi.spyOn(console, 'warn').mockImplementation(() => {})
      attachCharacterCells(buildController(buildCells(4)), { length: 6 })
      expect(warn).toHaveBeenCalledTimes(1)
      warn.mockRestore()
    })

    it('stamps group attributes when groups are configured', () => {
      const cells = buildCells(8)
      attachCharacterCells(buildController(cells), { groups: [4, 4] })
      expect(cells[0].getAttribute('data-group-index')).toBe('0')
      expect(cells[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells[4].getAttribute('data-group-index')).toBe('1')
      expect(cells[4].hasAttribute('data-group-end')).toBe(false)
      expect(cells[7].hasAttribute('data-group-end')).toBe(true)
    })

    it('derives expected length from groups sum when length is unset', () => {
      const cells = buildCells(8)
      const controller = buildController(cells)
      attachCharacterCells(controller, { groups: [4, 4] })
      expect(controller.characterCells.active()).toBe(8)
    })

    it('derives expected length from cell count when nothing is configured', () => {
      const controller = buildController(buildCells(5))
      attachCharacterCells(controller, {})
      expect(controller.characterCells.active()).toBe(5)
    })
  })

  describe('draw', () => {
    let cells, controller

    beforeEach(() => {
      cells = buildCells(6)
      controller = buildController(cells)
      attachCharacterCells(controller, { length: 6 })
    })

    it('writes one character per cell and clears the rest', () => {
      controller.characterCells.draw('482')
      expect(cells.map((cell) => cell.textContent)).toEqual(['4', '8', '2', '', '', ''])
    })

    it('stamps data-filled on cells holding a character', () => {
      controller.characterCells.draw('482')
      expect(cells[2].hasAttribute('data-filled')).toBe(true)
      expect(cells[3].hasAttribute('data-filled')).toBe(false)
    })

    it('stamps data-caret at the input position only when focused', () => {
      controller.characterCells.draw('482', { focused: true })
      expect(cells[3].hasAttribute('data-caret')).toBe(true)
      controller.characterCells.draw('482', { focused: false })
      expect(cells[3].hasAttribute('data-caret')).toBe(false)
    })

    it('stamps no caret when the value is full', () => {
      controller.characterCells.draw('482913', { focused: true })
      expect(cells.some((cell) => cell.hasAttribute('data-caret'))).toBe(false)
    })

    it('clear() empties every cell', () => {
      controller.characterCells.draw('482913')
      controller.characterCells.clear()
      expect(cells.every((cell) => cell.textContent === '')).toBe(true)
      expect(cells.some((cell) => cell.hasAttribute('data-filled'))).toBe(false)
    })

    it('ignores non-string values', () => {
      controller.characterCells.draw(null)
      expect(cells.every((cell) => cell.textContent === '')).toBe(true)
    })
  })
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `npm test -- tests/unit/plumbers/character_cells.test.js`
Expected: FAIL — cannot resolve `src/plumbers/character_cells`.

- [ ] **Step 3: Write the plumber**

Create `src/plumbers/character_cells.js`:

```js
import Plumber from './plumber';
import { setAriaHidden } from '../accessibility/aria';

const defaultOptions = {
  groups: [],
  length: 0,
};

/** Cumulative end indexes for group widths, e.g. [4, 4, 4] → [4, 8, 12] */
const groupBounds = (groups) => {
  const bounds = [];
  let sum = 0;
  for (const width of groups) {
    sum += width;
    bounds.push(sum);
  }
  return bounds;
};

export class CharacterCells extends Plumber {
  /**
   * Paints a canonical string value into author-rendered cell elements
   * (controller.cellTargets). Never generates DOM and never reads an input —
   * values arrive via draw().
   * @param {Object} controller - Stimulus controller with cellTargets
   * @param {Object} options - Configuration options
   * @param {number[]} [options.groups=[]] - Chunk widths (e.g. [4,4,4,4]); empty = uniform cells
   * @param {number} [options.length=0] - Expected value length; 0 derives from groups sum or cell count
   */
  constructor(controller, options = {}) {
    super(controller, options);
    this.groups = Array.isArray(options.groups) ? options.groups : defaultOptions.groups;
    this.length = options.length ?? defaultOptions.length;
    this.adopt();
    this.enhance();
  }

  get cells() {
    return this.controller.cellTargets ?? [];
  }

  /** Expected value length: explicit length, else groups sum, else cell count */
  expected() {
    if (this.length > 0) return this.length;
    const grouped = this.groups.reduce((sum, width) => sum + width, 0);
    return grouped > 0 ? grouped : this.cells.length;
  }

  /** Number of cells in play — min of available cells and expected length */
  active() {
    return Math.min(this.cells.length, this.expected());
  }

  /** Stamps aria-hidden, group attributes, and data-inactive on adopted cells */
  adopt() {
    const expected = this.expected();
    if (this.cells.length < expected) {
      console.warn(`[CharacterCells] expected ${expected} cells, found ${this.cells.length}`);
    }

    const bounds = groupBounds(this.groups);
    this.cells.forEach((cell, index) => {
      setAriaHidden(cell, true);
      cell.toggleAttribute('data-inactive', index >= expected);

      const group = bounds.findIndex((end) => index < end);
      if (group >= 0) {
        cell.setAttribute('data-group-index', group);
        cell.toggleAttribute('data-group-end', index === bounds[group] - 1);
      }
    });
  }

  enhance() {
    const context = this;
    const helpers = {
      draw: (value, options) => context.draw(value, options),
      clear: () => context.draw(''),
      active: () => context.active(),
    };

    Object.defineProperty(this.controller, 'characterCells', {
      get() {
        return helpers;
      },
      configurable: true,
    });
  }

  /**
   * Writes value[i] into each active cell and stamps state attributes.
   * @param {string} value - Canonical string to paint
   * @param {Object} [options] - Options
   * @param {boolean} [options.focused=false] - Whether the source input has focus; enables data-caret
   */
  draw(value = '', { focused = false } = {}) {
    const chars = typeof value === 'string' ? value.split('') : [];
    this.cells.slice(0, this.active()).forEach((cell, index) => {
      cell.textContent = chars[index] ?? '';
      cell.toggleAttribute('data-filled', chars[index] != null);
      cell.toggleAttribute('data-caret', focused && index === chars.length);
    });
  }
}

export const attachCharacterCells = (controller, options) => new CharacterCells(controller, options);
```

Add exports (alphabetical position):

`src/plumbers/index.js`:

```js
export { attachCharacterCells } from './character_cells';
```

(placed before `export { attachContentLoader } from './content_loader';`)

`src/index.js` (this file uses `.js` suffixes — keep them):

```js
export { CharacterCells, attachCharacterCells } from './plumbers/character_cells.js';
```

(placed near `export { Formatter, FORMATTER_TYPES } from './plumbers/formatter.js';`)

- [ ] **Step 4: Run test to verify it passes**

Run: `npm test -- tests/unit/plumbers/character_cells.test.js`
Expected: PASS (all cases).

- [ ] **Step 5: Commit**

```bash
git add src/plumbers/character_cells.js src/plumbers/index.js src/index.js tests/unit/plumbers/character_cells.test.js
git commit -m "feat: CharacterCells plumber"
```

---

### Task 3: `cells()` hint plumbing — Formatter helper + creditCard hint

**Files:**
- Modify: `src/plumbers/formatter.js` (helpers), `src/plumbers/formatters/credit_card.js` (add `cells`)
- Test: `tests/unit/plumbers/formatters/credit_card.test.js` (append), `tests/unit/plumbers/formatter.test.js` (append — file exists; reuse its imports and controller stub if present, otherwise use the standalone form below)

**Interfaces:**
- Consumes: `CodeFormatter.cells(opts)` from Task 1.
- Produces: `controller.formatter.cells()` → `{ groups, length }` or `null` when the strategy has no hint. Task 4 calls this.

- [ ] **Step 1: Write the failing tests**

Append to `tests/unit/plumbers/formatters/credit_card.test.js`:

```js
  describe('cells', () => {
    it('hints four groups of four, sixteen characters', () => {
      expect(CreditCardFormatter.cells()).toEqual({ groups: [4, 4, 4, 4], length: 16 })
    })
  })
```

Append to `tests/unit/plumbers/formatter.test.js` (inside the top-level describe; reuse the file's existing controller stub pattern — if creating the file fresh, use this standalone form):

```js
import { describe, it, expect, vi } from 'vitest'
import { attachFormatter } from '../../../src/plumbers/formatter'

const buildController = () => ({
  element: document.body,
  identifier: 'input-formatter',
  dispatch: vi.fn(),
})

describe('Formatter cells hint', () => {
  it('exposes the strategy cells hint through helpers', () => {
    const controller = buildController()
    attachFormatter(controller, { type: 'code', options: { length: 6 } })
    expect(controller.formatter.cells()).toEqual({ groups: [], length: 6 })
  })

  it('returns null for strategies without a cells hint', () => {
    const controller = buildController()
    attachFormatter(controller, { type: 'currency' })
    expect(controller.formatter.cells()).toBeNull()
  })
})
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npm test -- tests/unit/plumbers/formatters/credit_card.test.js tests/unit/plumbers/formatter.test.js`
Expected: FAIL — `cells is not a function` / `toEqual` mismatch.

- [ ] **Step 3: Implement**

In `src/plumbers/formatter.js`, add to the `helpers` object in `enhance()` (after the `maskable` line):

```js
      maskable: () => typeof formatter.mask === 'function',
      cells: () => (typeof formatter.cells === 'function' ? formatter.cells(context.options) : null),
```

In `src/plumbers/formatters/credit_card.js`, add to the `CreditCardFormatter` object after `format`:

```js
  /**
   * CharacterCells hint: four groups of four digits (standard 16-digit PAN).
   * @returns {{ groups: number[], length: number }}
   */
  cells() {
    return { groups: [4, 4, 4, 4], length: 16 };
  },
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `npm test -- tests/unit/plumbers/formatters/credit_card.test.js tests/unit/plumbers/formatter.test.js`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/plumbers/formatter.js src/plumbers/formatters/credit_card.js tests/unit/plumbers/formatters/credit_card.test.js tests/unit/plumbers/formatter.test.js
git commit -m "feat: cells hint on formatter strategies"
```

---

### Task 4: input-formatter controller integration

**Files:**
- Modify: `src/controllers/input_formatter_controller.js`
- Test: `tests/unit/controllers/input_formatter_controller.test.js` (append)

**Interfaces:**
- Consumes: `attachCharacterCells(this, { groups, length })` / `this.characterCells.draw(value, { focused })` (Task 2); `this.formatter.cells()` (Task 3).
- Produces: `cell` target, `groups` Array value, `onInput(event)` / `onFocus()` / `onBlur()` actions, `input-formatter:filled` `{ value }` dispatch. These names are final — docs in Task 5 use them verbatim.

- [ ] **Step 1: Write the failing tests**

Append to `tests/unit/controllers/input_formatter_controller.test.js` (inside the top-level `describe('InputFormatterController')`, reusing the existing `application`/`getController` setup):

```js
  describe('code type with cells', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter"
             data-input-formatter-format-value="code"
             data-input-formatter-options-value='{"charset":"digits","length":6}'>
          ${'<div data-input-formatter-target="cell"></div>'.repeat(6)}
          <input data-input-formatter-target="input"
                 data-action="input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    const cells = () => [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
    const input = () => document.querySelector('[data-input-formatter-target="input"]')

    it('attaches characterCells on connect', () => {
      expect(getController().characterCells).toBeDefined()
    })

    it('stamps aria-hidden on cells', () => {
      cells().forEach((cell) => expect(cell.getAttribute('aria-hidden')).toBe('true'))
    })

    it('paints typed characters into cells on input', () => {
      input().value = '482'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells().map((cell) => cell.textContent)).toEqual(['4', '8', '2', '', '', ''])
    })

    it('filters non-charset characters and writes back to the input', () => {
      input().value = '4 8-29 13'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(input().value).toBe('482913')
    })

    it('dispatches input-formatter:filled at configured length', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '482913'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: '482913' })
    })

    it('does not dispatch filled below configured length', () => {
      const spy = vi.fn()
      document.querySelector('[data-controller="input-formatter"]').addEventListener('input-formatter:filled', spy)
      input().value = '4829'
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(spy).not.toHaveBeenCalled()
    })

    it('shows the caret cell only while focused', () => {
      input().value = '48'
      input().focus()
      input().dispatchEvent(new Event('input', { bubbles: true }))
      expect(cells()[2].hasAttribute('data-caret')).toBe(true)
      input().blur()
      expect(cells()[2].hasAttribute('data-caret')).toBe(false)
    })
  })

  describe('creditCard type with cells', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          ${'<div data-input-formatter-target="cell"></div>'.repeat(16)}
          <input data-input-formatter-target="input" data-action="input->input-formatter#onInput" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('derives 4-4-4-4 grouping from the formatter hint', () => {
      const cells = [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
      expect(cells[3].hasAttribute('data-group-end')).toBe(true)
      expect(cells[4].getAttribute('data-group-index')).toBe('1')
    })

    it('paints the canonical (unformatted) value into cells', () => {
      const input = document.querySelector('[data-input-formatter-target="input"]')
      input.value = '4242 4242'
      input.dispatchEvent(new Event('input', { bubbles: true }))
      const cells = [...document.querySelectorAll('[data-input-formatter-target="cell"]')]
      expect(cells.slice(0, 8).map((cell) => cell.textContent)).toEqual(['4', '2', '4', '2', '4', '2', '4', '2'])
    })
  })

  describe('without cell targets (regression)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="input-formatter" data-input-formatter-format-value="creditCard">
          <input data-input-formatter-target="input" />
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('does not attach characterCells', () => {
      expect(getController().characterCells).toBeUndefined()
    })
  })
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `npm test -- tests/unit/controllers/input_formatter_controller.test.js`
Expected: new cases FAIL (`characterCells` undefined, no cell painting); pre-existing cases still PASS.

- [ ] **Step 3: Implement controller changes**

In `src/controllers/input_formatter_controller.js`:

Imports and declarations:

```js
import { attachCharacterCells } from '../plumbers/character_cells';
```

```js
  static targets = ['input', 'toggle', 'cell'];
  static values = {
    format: { type: String, default: 'plain' },
    options: { type: Object, default: {} },
    revealed: { type: Boolean, default: false },
    groups: { type: Array, default: [] },
  };
```

`connect()` and the value-changed callbacks gain one call — final shapes:

```js
  connect() {
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.format(this.readValue());
    this.drawToggle();
  }

  formatValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.format(this.readValue());
    this.drawToggle();
  }

  optionsValueChanged() {
    if (!this.formatter) return;
    attachFormatter(this, { type: this.formatValue, options: this.optionsValue });
    this.attachCells();
    this.format(this.readValue());
  }
```

New methods (place after `onPaste`):

```js
  attachCells() {
    if (!this.hasCellTarget) return;
    const hints = this.formatter.cells() ?? {};
    attachCharacterCells(this, {
      groups: this.groupsValue.length ? this.groupsValue : (hints.groups ?? []),
      length: hints.length ?? 0,
    });
  }

  onInput() {
    this.format(this.readValue());
  }

  onFocus() {
    this.drawCells(this.formatter?.normalize(this.readValue()) ?? '');
  }

  onBlur() {
    this.drawCells(this.formatter?.normalize(this.readValue()) ?? '');
  }

  drawCells(value) {
    if (!this.hasCellTarget) return;
    const focused = this.hasInputTarget && document.activeElement === this.inputTarget;
    this.characterCells?.draw(value, { focused });
  }
```

In `onFormatting(raw)`, after the `this.dispatch('formatted', …)` line, append:

```js
    this.drawCells(value);
    const expected = this.formatValue === 'code' ? (this.optionsValue.length ?? 0) : 0;
    if (expected > 0 && value.length === expected) {
      this.dispatch('filled', { detail: { value } });
    }
```

Note: no special write-back code is needed for `code` — `CodeFormatter.format()` returns the normalized value, so the existing `inputTarget.value = formatted` line already writes the filtered string back.

- [ ] **Step 4: Run the full controller suite**

Run: `npm test -- tests/unit/controllers/input_formatter_controller.test.js`
Expected: PASS — every pre-existing case and every new case.

- [ ] **Step 5: Run everything + lint**

Run: `npm test` then `npm run lint` then `npm run format:check`
Expected: all PASS. If prettier complains, run `npm run format` (if the script exists — check `package.json`; otherwise fix manually) and re-check.

- [ ] **Step 6: Commit**

```bash
git add src/controllers/input_formatter_controller.js tests/unit/controllers/input_formatter_controller.test.js
git commit -m "feat: cell display, code entry, and filled event in input-formatter"
```

---

### Task 5: Docs + ARIA + manifest verification

**Files:**
- Modify: `docs/component/input-formatter.md`, `../ARIA.md` (repo root)
- Create: `docs/plumber/character-cells.md`
- Verify: manifests + MCP tests (monorepo)

- [ ] **Step 1: Update `docs/component/input-formatter.md`**

Targets table — add row:

```markdown
| `cell`   | `<div>` (any element)    | Optional character cells; when present, the canonical value is painted one character per cell — see [character-cells](../plumber/character-cells.md) |
```

Values table — add row:

```markdown
| `groups`   | Array   | `[]`      | Cell group widths (e.g. `[4,4,4,4]`); overrides the formatter's own grouping hint |
```

Methods table — add rows:

```markdown
| `onInput(event)`  | `input` DOM event        | Event adapter — re-formats from the input's current value                                      |
| `onFocus(event)`  | `focus` DOM event        | Event adapter — redraws cells so the caret cell appears                                        |
| `onBlur(event)`   | `blur` DOM event         | Event adapter — redraws cells so the caret cell clears                                         |
```

Dispatches table — add row:

```markdown
| `input-formatter:filled`    | `{ value }` | When a `code` value reaches its configured `length` — auto-submit hook  |
```

Formatters table — add row:

```markdown
| `"code"`       | Charset-filtered fixed-length codes (OTP, PIN); options `{ charset: "digits"\|"letters"\|"alphanumeric", length }` |
```

Examples — add after the credit card example:

````markdown
### One-time code entry (cells)

```html
<div data-controller="input-formatter"
     data-input-formatter-format-value="code"
     data-input-formatter-options-value='{"charset":"digits","length":6}'>
  <label for="otp" class="sr-only">Verification code</label>
  <div class="cells-row">
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
    <div data-input-formatter-target="cell"></div>
  </div>
  <input id="otp" data-input-formatter-target="input"
         autocomplete="one-time-code" inputmode="numeric" maxlength="6"
         data-action="input->input-formatter#onInput focus->input-formatter#onFocus blur->input-formatter#onBlur" />
</div>
```

The input overlays the cell row invisibly (`opacity: 0` — never `display: none`). Cells are decoration; style them via `[data-filled]`, `[data-caret]`, `[data-group-end]`, `[data-inactive]`.
````

Accessibility section — add bullet:

```markdown
- Cell display: cells are `aria-hidden` (stamped automatically); the real input remains the accessible field. See [ARIA.md's Code Input pattern](../../../ARIA.md).
```

- [ ] **Step 1b: Add the README Utilities row**

`src/index.js` gained a new export in Task 2, so per the repo doc rule `README.md`'s Utilities table needs a row (place after the `Formatter` row at README.md:118, matching its column format):

```markdown
| `CharacterCells`, `attachCharacterCells` | Character-cell display plumber (attach to a controller; used by `input-formatter`) | [docs/plumber/character-cells.md](docs/plumber/character-cells.md) |
```

- [ ] **Step 2: Create `docs/plumber/character-cells.md`**

Follow the structure of `docs/plumber/formatter.md` (read it first for exact section conventions). Content to cover:

````markdown
# character-cells

Paints one canonical string value into a row of author-rendered character cells. Attached by
[input-formatter](../component/input-formatter.md) when `cell` targets exist; usable by any
controller with `cellTargets`.

## Attach

```js
import { attachCharacterCells } from '@stimulus-plumbers/controllers';

attachCharacterCells(this, { groups: [4, 4, 4, 4], length: 16 });
```

| Option   | Type       | Default | Description                                                            |
| -------- | ---------- | ------- | ---------------------------------------------------------------------- |
| `groups` | `Number[]` | `[]`    | Chunk widths; empty = uniform single-character cells                   |
| `length` | `Number`   | `0`     | Expected value length; `0` derives from `groups` sum, else cell count  |

## Helpers (`controller.characterCells`)

| Helper                      | Description                                                             |
| --------------------------- | ----------------------------------------------------------------------- |
| `draw(value, { focused })`  | Writes `value[i]` per active cell; stamps state attributes              |
| `clear()`                   | Empties every cell (`draw('')`)                                         |
| `active()`                  | Number of cells in play (min of cell count and expected length)         |

## Cell state attributes

| Attribute          | When                                                          |
| ------------------ | ------------------------------------------------------------- |
| `data-filled`      | Cell holds a character                                        |
| `data-caret`       | Cell at the input position, only while `focused` is true      |
| `data-group-index` | Group ordinal (0-based) when `groups` configured              |
| `data-group-end`   | Last cell of its group                                        |
| `data-inactive`    | Cell beyond the expected length                               |

## Notes

- Cells are stamped `aria-hidden="true"` at attach — they are decoration; the source input
  remains the accessible field.
- The plumber never generates DOM: render exactly as many cells as the expected length, or
  extras become `data-inactive`; too few logs a console warning.
- Separators between groups are authored CSS/HTML (style `[data-group-end]`), never inserted
  by the plumber.
````

- [ ] **Step 3: Add the ARIA.md pattern**

In `../ARIA.md` (repo root), under `## Component-Specific Patterns (APG)`, add (mirror the sibling subsection format exactly — read one first):

```markdown
#### Code Input (`input_formatter_controller` + `character_cells`)

- The real `<input>` is the entire accessible surface; cells are stamped `aria-hidden="true"` automatically.
- The input requires a `<label>` (visually hidden allowed), `autocomplete="one-time-code"` for OTP (WCAG 1.3.5), `inputmode` matching the charset, and `maxlength` matching the code length.
- Overlay the input with `opacity: 0` — never `display: none`/`visibility: hidden`, which remove it from the tab order (WCAG 2.1.1).
- Focus visibility (WCAG 2.4.7): the caret cell (`data-caret`) appears only while the input has focus; style the wrapper with `:focus-within` plus `[data-caret]`.
```

- [ ] **Step 4: Format docs and run monorepo checks**

From the repo root:

```bash
npm run format:docs
```

Then verify the MCP/rails pipeline still passes with the manifest picking up the new target/value:

```bash
cd stimulus-plumbers && node --run build:manifest
cd ../stimulus-plumbers-rails && bundle exec rake build:manifest
mkdir -p vendor/controller && \cp ../stimulus-plumbers/dist/controllers.manifest.json vendor/controller/manifest.json
cd ../stimulus-plumbers-mcp && bundle exec rake test:unit
```

Expected: manifest reports the same 23 controllers (no new identifier); MCP tests PASS (`EXPECTED_IDENTIFIERS` unchanged).

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers/docs/component/input-formatter.md stimulus-plumbers/docs/plumber/character-cells.md stimulus-plumbers/README.md ARIA.md
git commit -m "doc: character-cells plumber and code input pattern"
```

(Include any manifest files the build regenerated only if they are already git-tracked.)

---

### Task 6: End-to-end verification

- [ ] **Step 1: Full suite from `stimulus-plumbers/`**

```bash
npm test && npm run lint && npm run format:check
```

Expected: all PASS.

- [ ] **Step 2: Manual smoke (verify skill)**

Build a scratch HTML fixture exercising the canonical OTP markup from Task 5 with the built package (or drive via the existing test harness) and confirm: typing paints cells, paste of `"4 8-29 13"` yields `482913`, the `filled` event fires at 6 characters, caret cell tracks focus. Use the project `verify` skill if available.

- [ ] **Step 3: Final review**

Run the `superpowers:requesting-code-review` flow before merging; spec is `docs/superpowers/specs/2026-07-18-character-cells-design.md`.
