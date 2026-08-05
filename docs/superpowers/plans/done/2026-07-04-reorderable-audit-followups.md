# Reorderable Audit Follow-ups Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Resolve the open findings from `docs/superpowers/audits/2026-07-04-reorderable-consistency-audit.md` — a real key-repeat bug, a geometry-math duplication, an API-shape wart, and two documentation gaps (missing ARIA.md entry, inline ARIA restatement) — without touching drag mechanics, output events, targets, or values.

**Architecture:** Three small code changes to `stimulus-plumbers/src/plumbers/reorderable.js` (+ its two consumers, `geometry.js` and `reorderable_controller.js`), followed by a documentation pass across `ARIA.md` and the two `reorderable` doc files. Findings #3 (pointer/keyboard attach asymmetry) and #4 (controller-read coupling) are not code changes — the audit marked both as likely-justified tradeoffs, so this plan documents the rationale in `docs/plumber/reorderable.md` instead of changing the design, so a future reader finds an explicit decision rather than unexplained drift.

**Tech Stack:** Vanilla JS + Stimulus + Vitest (no Rails changes in this plan).

## Global Constraints

- Audit: `docs/superpowers/audits/2026-07-04-reorderable-consistency-audit.md` — read before starting if any task is unclear.
- `import` statements must not end in `.js`.
- Lint (`node --run lint`) and tests (`node --run test`) run synchronously from `stimulus-plumbers/` — never background or tail.
- Doc Update Rule: any change to a documented API (methods, behavior) updates the relevant `docs/**/*.md` in the same commit as the code change. ARIA/WCAG content lives only in `ARIA.md` — other docs link to it, never restate it.
- No comments restating WHAT code does — only WHY, and only when non-obvious.
- No behavior change to drag mechanics, dispatched events, targets, or values — every task here is either a bug fix (Task 1), an internal refactor with identical external behavior (Tasks 2–3), or documentation.

All commands below assume the working directory is `/Users/ryanchang/Documents/Github/stimulus-plumbers/stimulus-plumbers` unless stated otherwise.

---

### Task 1: Guard `Reorderable#onKeydown` against OS key-repeat

**Files:**
- Modify: `src/plumbers/reorderable.js`
- Test: `tests/unit/plumbers/reorderable.test.js`

**Interfaces:**
- Consumes: nothing new.
- Produces: `Reorderable#onKeydown` no-ops (no swap, no dispatch, no announce) when `event.repeat` is `true`.

Audit finding #6: holding `Alt+ArrowDown` triggers OS key-repeat every ~30–50ms. Each repeat currently does a live DOM move, dispatches `reordered`, and calls `announce()` — flooding the aria-live region and any backend consumer listening for `reorderable:reordered`.

- [ ] **Step 1: Write the failing test**

In `tests/unit/plumbers/reorderable.test.js`, add this test inside the `describe('keyboard move via attachItem', ...)` block, after the existing `'does nothing when controller.editingValue is false'` test:

```js
    it('ignores a repeated keydown (OS key-repeat) — no move, no dispatch, no announce', () => {
      const reorderable = new Reorderable(mockController, { onMoved: 'moved' });
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, repeat: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
      expect(mockController.moved).not.toHaveBeenCalled();
    });
```

- [ ] **Step 2: Run tests to verify the new test fails**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: the new test FAILS — `onKeydown` still processes a repeated keydown identically to a fresh one, so the item moves and `dispatch`/`moved` are called.

- [ ] **Step 3: Implement the guard**

In `src/plumbers/reorderable.js`, change:

```js
  onKeydown(event) {
    if (!this.controller.editingValue) return;
    if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;
```

to:

```js
  onKeydown(event) {
    if (!this.controller.editingValue) return;
    if (event.repeat) return;
    if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS, all tests green (existing + 1 new).

- [ ] **Step 5: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add src/plumbers/reorderable.js tests/unit/plumbers/reorderable.test.js
git commit -m "$(cat <<'EOF'
fix: ignore OS key-repeat in Reorderable keyboard move

Holding Alt+Arrow was firing a move + reordered dispatch + announce
on every repeat tick (~30-50ms), flooding the aria-live region and
any backend consumer listening for reorderable:reordered.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Extract `verticalCenter(rect)` into `geometry.js`, use it from `Reorderable#midpointOf`

**Files:**
- Modify: `src/plumbers/plumber/geometry.js`
- Test: `tests/unit/plumbers/plumber/geometry.test.js`
- Modify: `src/plumbers/reorderable.js`

**Interfaces:**
- Consumes: nothing new.
- Produces: `verticalCenter(rect)` — exported function in `geometry.js`, `(rect: { top: number, height: number }) => number`. Used by `Reorderable#midpointOf` in this task; available to any future plumber needing the same calculation (matching how `Flipper`/`Shifter` already share `defineRect`/`viewportRect`/`isWithinViewport`).

Audit finding #5: `midpointOf()` reimplements rect math locally instead of extending the shared geometry module every other plumber with rect math (`Flipper`, `Shifter`) already uses. A future geometry fix (e.g. CSS transform/zoom handling) would land in `geometry.js` and be picked up by those plumbers automatically, but not by `Reorderable`, unless this is fixed.

- [ ] **Step 1: Write the failing test**

In `tests/unit/plumbers/plumber/geometry.test.js`, add this new `describe` block after the closing `});` of `describe('directionMap', ...)`:

```js
  describe('verticalCenter', () => {
    it('returns the vertical midpoint of a rect', () => {
      expect(verticalCenter({ top: 20, height: 50 })).toBe(45)
    })

    it('handles a zero-height rect', () => {
      expect(verticalCenter({ top: 100, height: 0 })).toBe(100)
    })
  })
```

Update the import at the top of the file from:

```js
import { defineRect, directionMap, viewportRect, isWithinViewport } from '../../../../src/plumbers/plumber/geometry'
```

to:

```js
import { defineRect, directionMap, viewportRect, isWithinViewport, verticalCenter } from '../../../../src/plumbers/plumber/geometry'
```

- [ ] **Step 2: Run tests to verify the new tests fail**

Run: `node --run test -- tests/unit/plumbers/plumber/geometry.test.js`
Expected: FAIL — `verticalCenter` is not exported yet (`TypeError: verticalCenter is not a function`).

- [ ] **Step 3: Implement `verticalCenter`**

In `src/plumbers/plumber/geometry.js`, add this function after `defineRect` and before `viewportRect`:

```js
export function verticalCenter(rect) {
  return rect.top + rect.height / 2;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `node --run test -- tests/unit/plumbers/plumber/geometry.test.js`
Expected: PASS, all tests green (existing + 2 new).

- [ ] **Step 5: Point `Reorderable#midpointOf` at the shared helper**

In `src/plumbers/reorderable.js`, change the import:

```js
import Plumber from './plumber';
import { announce } from '../accessibility/aria';
import { MODIFIER_KEYS } from '../accessibility/keyboard';
```

to:

```js
import Plumber from './plumber';
import { announce } from '../accessibility/aria';
import { MODIFIER_KEYS } from '../accessibility/keyboard';
import { verticalCenter } from './plumber/geometry';
```

Change `midpointOf`:

```js
  midpointOf(item) {
    const rect = item.getBoundingClientRect();
    return rect.top + rect.height / 2;
  }
```

to:

```js
  midpointOf(item) {
    return verticalCenter(item.getBoundingClientRect());
  }
```

- [ ] **Step 6: Run the full plumber test suite to confirm no regression**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS — the existing `pointer drag` tests stub `getBoundingClientRect`, so `midpointOf`'s external behavior is unchanged.

- [ ] **Step 7: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 8: Commit**

```bash
git add src/plumbers/plumber/geometry.js src/plumbers/reorderable.js tests/unit/plumbers/plumber/geometry.test.js
git commit -m "$(cat <<'EOF'
refactor: extract verticalCenter into shared geometry module

Reorderable#midpointOf reimplemented rect math inline instead of
extending plumber/geometry.js, which Flipper and Shifter already
share for this category of calculation. A future geometry fix now
reaches Reorderable automatically instead of silently missing it.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: Add bulk `attachItems`/`detachItems` to `Reorderable`, simplify the controller's `connect()`/`disconnect()`

**Files:**
- Modify: `src/plumbers/reorderable.js`
- Test: `tests/unit/plumbers/reorderable.test.js`
- Modify: `src/controllers/reorderable_controller.js`
- Test: `tests/unit/controllers/reorderable_controller.test.js` (no new tests — existing tests must still pass unchanged, since external `connect()`/`disconnect()` behavior is identical)
- Modify: `docs/plumber/reorderable.md`

**Interfaces:**
- Consumes: nothing new.
- Produces: `Reorderable#attachItems(items)` / `Reorderable#detachItems(items)` — bulk versions of the existing per-item `attachItem`/`detachItem`, each accepting an iterable of elements.

Audit finding #7: `connect()` hand-rolls `this.itemTargets.forEach((item) => this.reorderable.attachItem(item))` because the plumber only exposes a per-item API, unlike `RovingTabIndex` (which takes the whole array up front via its constructor and `activate()`). This gives the controller a bulk method so `connect()`/`disconnect()` read the same shape as the rest of the file (`rovingTabIndex.activate()`/`deactivate()`).

- [ ] **Step 1: Write the failing tests**

In `tests/unit/plumbers/reorderable.test.js`, add this new `describe` block after the closing `});` of `describe('detachItem', ...)`:

```js
  describe('attachItems / detachItems', () => {
    it('attaches keydown handling to every item in one call', () => {
      const reorderable = new Reorderable(mockController);
      reorderable.attachItems(items);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-b', 'row-a', 'row-c']);
    });

    it('detaches keydown handling from every item in one call', () => {
      const reorderable = new Reorderable(mockController);
      reorderable.attachItems(items);
      reorderable.detachItems(items);

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
  });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: FAIL — `reorderable.attachItems is not a function`.

- [ ] **Step 3: Implement the bulk methods**

In `src/plumbers/reorderable.js`, change:

```js
  attachItem(item) {
    item.addEventListener('keydown', this.onKeydown);
  }

  detachItem(item) {
    item.removeEventListener('keydown', this.onKeydown);
  }
```

to:

```js
  attachItem(item) {
    item.addEventListener('keydown', this.onKeydown);
  }

  detachItem(item) {
    item.removeEventListener('keydown', this.onKeydown);
  }

  attachItems(items) {
    items.forEach((item) => this.attachItem(item));
  }

  detachItems(items) {
    items.forEach((item) => this.detachItem(item));
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS, all tests green (existing + 2 new).

- [ ] **Step 5: Update the controller to use the bulk methods**

In `src/controllers/reorderable_controller.js`, change:

```js
  connect() {
    this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
    this.itemTargets.forEach((item) => this.reorderable.attachItem(item));

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }

  disconnect() {
    this.itemTargets.forEach((item) => this.reorderable.detachItem(item));
    this.rovingTabIndex?.deactivate();
    this.rovingTabIndex = null;
  }
```

to:

```js
  connect() {
    this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
    this.reorderable.attachItems(this.itemTargets);

    this.rovingTabIndex = new RovingTabIndex(this.itemTargets, { orientation: 'vertical' });
    this.rovingTabIndex.activate();
  }

  disconnect() {
    this.reorderable.detachItems(this.itemTargets);
    this.rovingTabIndex?.deactivate();
    this.rovingTabIndex = null;
  }
```

- [ ] **Step 6: Run the controller test suite to confirm no regression**

Run: `node --run test -- tests/unit/controllers/reorderable_controller.test.js`
Expected: PASS, all existing tests green — `connect()`/`disconnect()`'s external behavior (which items get keydown handling, in what order) is unchanged.

- [ ] **Step 7: Run the full test suite and lint**

Run: `node --run test && node --run lint`
Expected: PASS, no errors.

- [ ] **Step 8: Update `docs/plumber/reorderable.md`**

Change the Methods table from:

```markdown
## Methods

| Method                              | Purpose                                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------------------------- |
| `attachItem(item)`                   | Adds the `keydown` listener for `Alt+Arrow` move handling to `item`                           |
| `detachItem(item)`                   | Removes it                                                                                     |
```

to:

```markdown
## Methods

| Method                              | Purpose                                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------------------------- |
| `attachItem(item)`                   | Adds the `keydown` listener for `Alt+Arrow` move handling to `item`                           |
| `detachItem(item)`                   | Removes it                                                                                     |
| `attachItems(items)`                 | Calls `attachItem` for each item in `items`                                                    |
| `detachItems(items)`                 | Calls `detachItem` for each item in `items`                                                    |
```

Change the "Controller callback" example from:

```js
connect() {
  this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
  this.itemTargets.forEach((item) => this.reorderable.attachItem(item));
}
```

to:

```js
connect() {
  this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
  this.reorderable.attachItems(this.itemTargets);
}
```

- [ ] **Step 9: Commit**

```bash
git add src/plumbers/reorderable.js tests/unit/plumbers/reorderable.test.js src/controllers/reorderable_controller.js docs/plumber/reorderable.md
git commit -m "$(cat <<'EOF'
refactor: add Reorderable#attachItems/detachItems, simplify connect()

connect()/disconnect() previously hand-rolled a forEach over
attachItem/detachItem, the only plumber pair in this codebase to
expose bulk attach only as a per-item loop at the call site
(RovingTabIndex takes the full array via its own activate()).
No change to which items get wired or in what order.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: Add Reorderable's ARIA.md entry, remove doc duplication, document accepted design tradeoffs

**Files:**
- Modify: `ARIA.md`
- Modify: `stimulus-plumbers/docs/component/reorderable.md`
- Modify: `stimulus-plumbers/docs/plumber/reorderable.md`

**Interfaces:** None — documentation only, no code interfaces.

Addresses audit findings #1, #2 (both CONFIRMED/PLAUSIBLE gaps) and gives #3/#4 (accepted tradeoffs) a documented rationale instead of leaving them as unexplained drift.

- [ ] **Step 1: Add a Reorderable entry to `ARIA.md`**

In `ARIA.md`, add this new subsection at the end of the `## Component-Specific Patterns (APG)` section, after the existing `#### Timeline (\`timeline_controller\`)` block:

```markdown

#### Reorderable (`reorderable_controller`)
- Roving tabindex on `item` targets (`RovingTabIndex`) — plain Arrow/Home/End move focus only, unaffected by editing state
- Keyboard move (`Alt+ArrowUp`/`Alt+ArrowDown` by default, configurable via `moveKey`): moves the focused item, keeps focus on it, announces the new position via `role="status"`/`aria-live` (WCAG 4.1.3) — satisfies the keyboard-equivalent requirement (WCAG 2.1.1) for pointer drag
- Pointer drag: does not move focus or announce — avoids stealing focus from a mouse user who never asked for it
- `editingValue` gates both drag and keyboard-move; while `true`, every `trigger` target (`<a>`/`<button>` inside an item) gets `aria-disabled="true"` + `tabindex="-1"` — removes it from keyboard/AT activation and tab order without touching pointer clicks (apps/themes add their own `pointer-events: none` CSS rule for that half)
```

- [ ] **Step 2: Trim the same duplication out of `docs/plumber/reorderable.md`'s Dispatches table**

The plumber doc has the identical problem to `docs/component/reorderable.md` (Step 3 below) in its own "Dispatches & callbacks" table. Change:

```markdown
| After a drag ends     | `{prefix}:reordered` | — no callback, no announcement. A mouse drag deliberately does not move focus or announce — doing so would steal focus from a mouse user who never asked for it; the keyboard path already satisfies WCAG 2.1.1's keyboard-equivalent requirement. |
```

to:

```markdown
| After a drag ends     | `{prefix}:reordered` | — no callback, no announcement (see [ARIA.md's Reorderable pattern](../../../ARIA.md) for why) |
```

- [ ] **Step 3: Trim the inline ARIA restatement in `docs/component/reorderable.md`**

In `stimulus-plumbers/docs/component/reorderable.md`, change the `## Notes` list from:

```markdown
## Notes

- Persistence is not built in — listen for `reorderable:reordered` and send `event.detail.itemIds` to your backend.
- Vertical-axis, single-list only. Horizontal/grid orientation and cross-list drag are not supported.
- The dragged/moved item is repositioned live in the DOM — there is no placeholder or ghost element.
- A pointer drag does not move focus or trigger a status announcement (avoids stealing focus from mouse users); a keyboard move does both.
- Pointer clicks on a `trigger` are not blocked by JS — `editingValueChanged` only handles the keyboard/AT half (`aria-disabled` + `tabindex`) via `setDisabled()`. Apps/themes must add their own CSS rule to block pointer clicks while editing, e.g. `[data-reorderable-editing-value="true"] [data-reorderable-target="trigger"] { pointer-events: none }` — keeps the controller content-agnostic about link/button internals.
```

to:

```markdown
## Notes

- Persistence is not built in — listen for `reorderable:reordered` and send `event.detail.itemIds` to your backend.
- Vertical-axis, single-list only. Horizontal/grid orientation and cross-list drag are not supported.
- The dragged/moved item is repositioned live in the DOM — there is no placeholder or ghost element.
- See [ARIA.md's Reorderable pattern](../../../ARIA.md) for the drag/keyboard-move focus-and-announcement contract and the `trigger` neutralization rules.
- Pointer clicks on a `trigger` are not blocked by JS. Apps/themes must add their own CSS rule to block them while editing, e.g. `[data-reorderable-editing-value="true"] [data-reorderable-target="trigger"] { pointer-events: none }` — keeps the controller content-agnostic about link/button internals.
```

- [ ] **Step 4: Add a Design notes section to `docs/plumber/reorderable.md`**

In `stimulus-plumbers/docs/plumber/reorderable.md`, add this new section at the end of the file, after the "Controller callback" section:

```markdown

## Design notes

- **Keyboard and pointer attachment use different mechanisms on purpose.** `attachItem`/`detachItem` self-attach a raw `keydown` listener per item — the plumber owns this because items connect/disconnect over time and `keydown` needs no markup wiring. Pointer handling (`onPointerDown`/`onPointerMove`/`onPointerUp`) is instead wired via `data-action` in the consumer's HTML, so the controller owns it. This is an accepted asymmetry, not an oversight: pointer targets have no `handleTargetConnected`-style lifecycle hook today, so self-attaching pointer listeners the same way would require adding one, with no current driver for it. A consumer that copies item markup but omits the handle's `data-action` gets working keyboard-move and silently broken drag — if this becomes a real support burden, revisit unifying the two.
- **`Reorderable` reads `controller.itemTargets`/`controller.editingValue` directly, unlike every other plumber**, which only *writes* to the controller or takes concrete elements/config via constructor options (`Flipper` takes `anchor`/`element`, `Shifter` takes `element`, `Dismisser` takes `trigger`/`element`). This is deliberate: both values must be read live — items connect/disconnect after construction, and editing toggles at runtime — which the snapshot-at-construction options pattern the other plumbers use doesn't support. The tradeoff is that `Reorderable` cannot be reused by a controller that names its `item` target or `editing` value differently; that's accepted for now since there is exactly one consumer (`reorderable_controller.js`).
```

- [ ] **Step 5: Verify no other inline ARIA restatement remains in either doc**

Run: `grep -n "aria-disabled\|aria-live\|status announcement\|WCAG" stimulus-plumbers/docs/component/reorderable.md`
Expected: only the `trigger` Targets-table row and the CSS-rule Notes bullet remain (both describe implementation contracts the app must wire up, not ARIA rationale) — no prose explaining *why* in ARIA terms.

Run: `grep -n "WCAG\|steal.*focus\|does not move focus" stimulus-plumbers/docs/plumber/reorderable.md`
Expected: no output — Step 2 removed the only such reference.

- [ ] **Step 6: Commit**

```bash
git add ARIA.md stimulus-plumbers/docs/component/reorderable.md stimulus-plumbers/docs/plumber/reorderable.md
git commit -m "$(cat <<'EOF'
docs: add Reorderable's ARIA.md entry, dedupe ARIA prose, record tradeoffs

ARIA.md previously had no entry for Reorderable, unlike every other
interactive controller. Both docs/component/reorderable.md and
docs/plumber/reorderable.md restated ARIA rationale inline instead of
linking out, violating the no-cross-doc-duplication rule.
docs/plumber/reorderable.md also gains a Design notes
section explaining the two intentional deviations from this
codebase's usual plumber conventions (keyboard/pointer attachment
asymmetry, controller-read coupling) so they read as accepted
decisions rather than unexplained drift.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: Final full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full JS test suite, lint, and format check**

Run: `node --run test && node --run lint && node --run format:check`
Expected: PASS, no errors.

- [ ] **Step 2: Confirm each audit finding's disposition**

Read `docs/superpowers/audits/2026-07-04-reorderable-consistency-audit.md` findings #1–#7 and confirm:
- #1 (ARIA.md missing entry) — resolved by Task 4, Step 1.
- #2 (inline ARIA restatement) — resolved by Task 4, Steps 2–3 (both `docs/plumber/reorderable.md` and `docs/component/reorderable.md` had the duplication).
- #3 (attach-mechanism asymmetry) — accepted tradeoff, documented by Task 4, Step 4.
- #4 (controller-read coupling) — accepted tradeoff, documented by Task 4, Step 4.
- #5 (`midpointOf` duplication) — resolved by Task 2.
- #6 (no `event.repeat` guard) — resolved by Task 1.
- #7 (attach-order call-shape mismatch) — resolved by Task 3.

- [ ] **Step 3: Manually confirm no behavior change to drag mechanics, events, targets, or values**

Diff `src/controllers/reorderable_controller.js` and `src/plumbers/reorderable.js` against the pre-plan version (`git diff main -- src/controllers/reorderable_controller.js src/plumbers/reorderable.js`, run from `stimulus-plumbers/` on the branch this plan started on) and confirm: `static targets`/`static values` unchanged, `reorderable:reordered` detail shape unchanged, `editingValue`/`trigger` gating unchanged — only `onKeydown`'s new `event.repeat` guard, `midpointOf`'s delegation to `verticalCenter`, and the `attachItems`/`detachItems` call-shape change in `connect()`/`disconnect()`.

No commit for this task — verification-only checkpoint before merge/PR (handled outside this plan).
