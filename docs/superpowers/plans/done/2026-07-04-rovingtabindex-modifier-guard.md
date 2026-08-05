# RovingTabIndex Modifier Guard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `RovingTabIndex` ignore modified arrow/Home/End keys by default, so `Reorderable` and `RovingTabIndex` no longer depend on which one attaches its `keydown` listener first.

**Architecture:** `RovingTabIndex` (`src/accessibility/keyboard.js`) gains an `ignoreModifierKeys` option (default: all four modifiers) and an early-return guard in `_handleKeyDown`. `MODIFIER_KEYS` moves from `src/plumbers/reorderable.js` into `keyboard.js` as the single source of truth; `reorderable.js` imports it and drops its now-unnecessary `event.stopImmediatePropagation()` call. `reorderable_controller.js` drops the attach-order comment since ordering no longer matters.

**Tech Stack:** Vanilla JS, Vitest, ESLint/Prettier. No new dependencies.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-04-rovingtabindex-modifier-guard-design.md` — read before starting if any task is unclear.
- `import` statements must not end in `.js` (project convention, see `stimulus-plumbers/CLAUDE.md`).
- Lint (`node --run lint` from `stimulus-plumbers/`) and tests (`node --run test`) must be run synchronously from `stimulus-plumbers/` — never background or tail.
- Doc Update Rule: any change to a documented API (options, behavior) must update the relevant `docs/**/*.md` in the same commit as the code change.
- No comments restating WHAT code does — only WHY, and only when non-obvious.

All commands below assume the working directory is `/Users/ryanchang/Documents/Github/stimulus-plumbers/stimulus-plumbers`.

---

### Task 1: Add `ignoreModifierKeys` guard to `RovingTabIndex`

**Files:**
- Modify: `src/accessibility/keyboard.js`
- Test: `tests/unit/accessibility/keyboard.test.js`

**Interfaces:**
- Produces: `MODIFIER_KEYS` — exported `const` map `{ Alt: 'altKey', Control: 'ctrlKey', Shift: 'shiftKey', Meta: 'metaKey' }` in `keyboard.js`, used by Task 2.
- Produces: `RovingTabIndex` constructor accepts `options.ignoreModifierKeys` (array of `'Alt' | 'Control' | 'Shift' | 'Meta'`), default `['Alt', 'Control', 'Shift', 'Meta']`.

- [ ] **Step 1: Write the failing tests**

Add this new `describe` block inside `tests/unit/accessibility/keyboard.test.js`, right after the closing `});` of the `describe('updateItems', ...)` block (before the outer `RovingTabIndex` `describe`'s closing `});` on line 191):

```js
  describe('ignoreModifierKeys', () => {
    it('ignores ArrowDown with Alt held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Control held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', ctrlKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Shift held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', shiftKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('ignores ArrowDown with Meta held (default)', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', metaKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a);
    });

    it('still moves focus on a plain (unmodified) ArrowDown', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical' });
      rti.activate();
      a.focus();
      keydown(a, 'ArrowDown');
      expect(document.activeElement).toBe(b);
    });

    it('a modified keydown does not sync currentIndex either', () => {
      const [a, b, c] = makeButtons(['a', 'b', 'c']);
      const rti = new RovingTabIndex([a, b, c], { orientation: 'vertical' });
      rti.activate();
      // physically focus c without going through setCurrentIndex, then send a modified
      // keydown on it — if the guard ran after the fromIndex sync, currentIndex would
      // become 2 as a side effect even though navigation itself is ignored
      c.focus();
      c.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(rti.currentIndex).toBe(0);
    });

    it('ignoreModifierKeys can be overridden to a narrower list', () => {
      const [a, b] = makeButtons(['a', 'b']);
      const rti = new RovingTabIndex([a, b], { orientation: 'vertical', ignoreModifierKeys: ['Alt'] });
      rti.activate();
      a.focus();
      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true }));
      expect(document.activeElement).toBe(a); // Alt still ignored

      a.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', shiftKey: true, bubbles: true }));
      expect(document.activeElement).toBe(b); // Shift no longer ignored
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `node --run test -- tests/unit/accessibility/keyboard.test.js`
Expected: 7 new failures in the `ignoreModifierKeys` block (`RovingTabIndex` doesn't yet know about `ignoreModifierKeys`, so modified arrows currently move focus).

- [ ] **Step 3: Implement the guard**

In `src/accessibility/keyboard.js`, add the shared modifier map near the top of the file (after the existing helper functions, before `export class RovingTabIndex`):

```js
export const MODIFIER_KEYS = { Alt: 'altKey', Control: 'ctrlKey', Shift: 'shiftKey', Meta: 'metaKey' };
```

Update the `RovingTabIndex` constructor to accept the new option:

```js
  constructor(items, options = {}) {
    this.items = Array.from(items);
    this.currentIndex = options.initialIndex ?? 0;
    this.orientation = options.orientation ?? 'both';
    this.wrap = options.wrap ?? true;
    this.ignoreModifierKeys = options.ignoreModifierKeys ?? Object.keys(MODIFIER_KEYS);
    this._handleKeyDown = this._handleKeyDown.bind(this);
    this._handleClick = this._handleClick.bind(this);
  }
```

Add the guard as the first line of `_handleKeyDown`, before the existing `fromIndex` sync:

```js
  _handleKeyDown(event) {
    if (this.ignoreModifierKeys.some((name) => event[MODIFIER_KEYS[name]])) return;

    const fromIndex = this.items.indexOf(event.currentTarget);
    // ... rest of the method unchanged
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `node --run test -- tests/unit/accessibility/keyboard.test.js`
Expected: PASS, all tests in the file green (existing + 7 new).

- [ ] **Step 5: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add src/accessibility/keyboard.js tests/unit/accessibility/keyboard.test.js
git commit -m "$(cat <<'EOF'
feat: RovingTabIndex ignores modified arrow/Home/End keys by default

Adds an ignoreModifierKeys option (default: all four modifiers) so
RovingTabIndex no longer reacts to Alt/Control/Shift/Meta+Arrow. This
lets it coexist with another keydown listener on the same items
(e.g. Reorderable) without depending on listener attach order.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Point `Reorderable` at the shared `MODIFIER_KEYS` and drop `stopImmediatePropagation`

**Files:**
- Modify: `src/plumbers/reorderable.js`
- Test: `tests/unit/plumbers/reorderable.test.js` (no new tests — existing tests must still pass unchanged)

**Interfaces:**
- Consumes: `MODIFIER_KEYS` from `src/accessibility/keyboard.js` (Task 1).

- [ ] **Step 1: Run the existing plumber tests to confirm current green baseline**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS (baseline before this task's changes).

- [ ] **Step 2: Update the import and remove the local `MODIFIER_KEYS` declaration**

In `src/plumbers/reorderable.js`, change:

```js
import Plumber from './plumber';
import { announce } from '../accessibility/aria';

const MODIFIER_KEYS = { Alt: 'altKey', Control: 'ctrlKey', Shift: 'shiftKey', Meta: 'metaKey' };
```

to:

```js
import Plumber from './plumber';
import { announce } from '../accessibility/aria';
import { MODIFIER_KEYS } from '../accessibility/keyboard';
```

- [ ] **Step 3: Remove `stopImmediatePropagation()` from `onKeydown`**

In `src/plumbers/reorderable.js`, in `onKeydown`, change:

```js
    event.preventDefault();
    event.stopImmediatePropagation();

    if (event.key === 'ArrowUp') {
```

to:

```js
    event.preventDefault();

    if (event.key === 'ArrowUp') {
```

- [ ] **Step 4: Run tests to verify they still pass**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS — no test in this file asserted on `stopImmediatePropagation` directly, so behavior observed at this layer is unchanged.

- [ ] **Step 5: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add src/plumbers/reorderable.js
git commit -m "$(cat <<'EOF'
refactor: Reorderable uses shared MODIFIER_KEYS, drops stopImmediatePropagation

RovingTabIndex now self-excludes modified arrow keys (previous
commit), so Reorderable no longer needs to forcibly stop propagation
to prevent it from double-handling Alt+Arrow.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Remove the attach-order dependency and its regression test from the controller

**Files:**
- Modify: `src/controllers/reorderable_controller.js`
- Test: `tests/unit/controllers/reorderable_controller.test.js`

**Interfaces:**
- Consumes: `Reorderable`/`RovingTabIndex` behavior from Tasks 1–2 (no API changes to either — this task only removes now-obsolete comments/tests).

- [ ] **Step 1: Run the existing controller tests to confirm current green baseline**

Run: `node --run test -- tests/unit/controllers/reorderable_controller.test.js`
Expected: PASS (baseline before this task's changes, including the soon-to-be-removed regression-guard test).

- [ ] **Step 2: Remove the attach-order comment in `connect()`**

In `src/controllers/reorderable_controller.js`, change:

```js
  connect() {
    this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
    // Must attach before `rovingTabIndex.activate()` below: both add a raw `keydown`
    // listener to each item, and whichever attaches first runs first. The plumber's
    // handler calls stopImmediatePropagation() for Alt+Arrow so RovingTabIndex never
    // sees it as a plain focus move — reversing this order breaks Alt+Arrow silently
    // reverting to focus-only movement. See docs/plumber/reorderable.md.
    this.itemTargets.forEach((item) => this.reorderable.attachItem(item));

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }
```

to:

```js
  connect() {
    this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
    this.itemTargets.forEach((item) => this.reorderable.attachItem(item));

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }
```

- [ ] **Step 3: Remove the now-obsolete attach-order regression test**

In `tests/unit/controllers/reorderable_controller.test.js`, delete this entire block (the comment plus the `it(...)` that follows it, currently right after the `'dispatches reorderable:reordered'` test):

```js
    // Regression guard for connect()'s listener-attach order: reorderable.attachItem()
    // must run before rovingTabIndex.activate() (see the comment in connect()). If that
    // order is ever reversed, RovingTabIndex's plain-arrow handler runs first, moves
    // focus once on its own (ignoring altKey), and does NOT stop propagation — so the
    // plumber's handler still runs afterward too, producing exactly one swap but a
    // dispatch count / final-focus mismatch versus the assertions below. If this test
    // fails, check connect()'s attach order first.
    it('dispatches reorderable:reordered exactly once per Alt+Arrow (attach-order regression guard)', async () => {
      const element = await setup();
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      const spy = vi.fn();
      element.addEventListener('reorderable:reordered', spy);
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(spy).toHaveBeenCalledTimes(1);
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
      expect(document.activeElement.id).toBe('row-a');
    });
```

This premise (order-dependence) no longer holds after Tasks 1–2, and the assertions it made (single dispatch, correct final focus) are already covered by the `'reorders the DOM and refocuses the moved item'` and `'dispatches reorderable:reordered'` tests directly above it.

- [ ] **Step 4: Add a replacement test proving order no longer matters**

Add this test in the same `describe('keyboard move (Alt+Arrow)', ...)` block, replacing the one just deleted:

```js
    it('reorders correctly even if RovingTabIndex is activated before Reorderable attaches (order independence)', async () => {
      document.body.innerHTML = buildHTML();
      const element = document.querySelector('[data-controller="reorderable"]');
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      // Simulate the reverse of connect()'s current order directly against the plumber
      // API to prove the fix: RovingTabIndex no longer needs to lose the race.
      const { RovingTabIndex } = await import('../../../src/accessibility/keyboard');
      const { attachReorderable } = await import('../../../src/plumbers/reorderable');
      const rti = new RovingTabIndex(Array.from(items()), { orientation: 'vertical' });
      rti.activate();
      const reorderable = attachReorderable({ itemTargets: Array.from(items()), dispatch: () => true }, {});
      items().forEach((item) => reorderable.attachItem(item));

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `node --run test -- tests/unit/controllers/reorderable_controller.test.js`
Expected: PASS.

- [ ] **Step 6: Run the full test suite**

Run: `node --run test`
Expected: PASS, all suites green.

- [ ] **Step 7: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add src/controllers/reorderable_controller.js tests/unit/controllers/reorderable_controller.test.js
git commit -m "$(cat <<'EOF'
refactor: remove attach-order dependency from ReorderableController

RovingTabIndex now ignores modified arrow keys on its own, so
Reorderable#attachItem() and rovingTabIndex.activate() no longer need
to run in a specific order. Removes the obsolete order comment and
its regression test; adds a test proving order independence directly.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Update documentation

**Files:**
- Modify: `stimulus-plumbers/docs/accessibility/design.md`
- Modify: `stimulus-plumbers/docs/plumber/reorderable.md`

**Interfaces:**
- None — documentation only, no code interfaces.

- [ ] **Step 1: Document `ignoreModifierKeys` in `design.md`**

In `stimulus-plumbers/docs/accessibility/design.md`, in the "Roving Tabindex" section, update the **Options** list (currently three bullets: `orientation`, `wrap`, `initialIndex`) by adding a fourth bullet immediately after `initialIndex`:

```markdown
- `ignoreModifierKeys` (array of `'Alt' | 'Control' | 'Shift' | 'Meta'`) — modifier keys that suppress arrow/Home/End handling entirely when held; default: all four. A modified key is ignored before any internal state changes (no `currentIndex` sync either). Narrow this list (or pass `[]`) if a specific modifier combination should still move focus.
```

- [ ] **Step 2: Add two Decision Log entries to `design.md`**

In the "Decision Log" section, add these two bullets after the existing `RovingTabIndex self-manages via activate()` entry:

```markdown
- **`RovingTabIndex` ignores all modifier keys by default, not just `Alt`** — the guard must be correct for any `moveKey` a co-located plumber might use (`Reorderable`'s `moveKey` is configurable to `Control`/`Shift`/`Meta`), and for any future `RovingTabIndex` consumer, without that consumer needing to know about a specific plumber. `ignoreModifierKeys` is a list, not a boolean, precisely so a future consumer that wants a modified combination (e.g. `Shift+Arrow` range-select) to still move focus can narrow it.
- **Prefer a reserved-key guard over attach order for two listeners sharing one item** — if a future plumber needs to attach its own raw `keydown` listener to items also managed by `RovingTabIndex`, extend `ignoreModifierKeys` (or add an equivalent reserved-key convention) rather than relying on which `addEventListener` call runs first plus `stopImmediatePropagation()`. The latter is an implicit ordering that silently breaks if reordered; the former partitions the keyspace structurally.
```

- [ ] **Step 3: Update `docs/plumber/reorderable.md`**

In `stimulus-plumbers/docs/plumber/reorderable.md`, change the opening paragraph from:

```markdown
Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system, so it can run before a separately-instantiated `RovingTabIndex` listener on the same element and take over `Alt+Arrow` before `RovingTabIndex` treats it as plain focus movement.
```

to:

```markdown
Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system. Composes safely with a separately-instantiated `RovingTabIndex` on the same items regardless of attach order — `RovingTabIndex` ignores modified arrow keys by default (see `docs/accessibility/design.md`), so `Alt+Arrow` (or whichever `moveKey` is configured) never reaches it as plain focus movement.
```

And update the "Controller callback" example's surrounding text — change the sentence directly above the code block from:

```markdown
## Controller callback
```

(no change needed to this heading itself — only remove the stale ordering claim if present elsewhere in the file). Re-read the file after Step 3's edit above to confirm no other attach-order language remains (the original doc only had the one paragraph referencing it, per the design spec).

- [ ] **Step 4: Verify no other attach-order references remain**

Run: `grep -rn "attach.*order\|stopImmediatePropagation\|before.*RovingTabIndex\|before.*rovingTabIndex" stimulus-plumbers/docs/`
Expected: no output (all such references removed or already didn't exist outside the two files touched above).

- [ ] **Step 5: Commit**

```bash
git add stimulus-plumbers/docs/accessibility/design.md stimulus-plumbers/docs/plumber/reorderable.md
git commit -m "$(cat <<'EOF'
docs: document RovingTabIndex modifier guard, remove attach-order language

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Final full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full test suite**

Run: `node --run test`
Expected: PASS, all suites green, including `keyboard.test.js`, `reorderable.test.js` (plumber), `reorderable_controller.test.js`.

- [ ] **Step 2: Run lint and format checks**

Run: `node --run lint && node --run format:check`
Expected: no errors.

- [ ] **Step 3: Manually confirm the fix addresses the original problem**

In a scratch file or REPL-style check, confirm by reading the final `src/controllers/reorderable_controller.js` that `connect()` no longer contains any comment or code implying `attachItem` must run before `rovingTabIndex.activate()`. Confirm `src/accessibility/keyboard.js` exports `MODIFIER_KEYS` and `RovingTabIndex` accepts `ignoreModifierKeys`. Confirm `src/plumbers/reorderable.js` imports `MODIFIER_KEYS` from `../accessibility/keyboard` and no longer calls `stopImmediatePropagation`.

No commit for this task — it's a verification-only checkpoint before moving on (e.g. to PR creation, handled outside this plan).
