# Reorderable Consistency Audit

Audit of `reorderable.js` (plumber) + `reorderable_controller.js` against every other plumber/controller pair in `stimulus-plumbers/src/` — looking for design drift or patterns inconsistent with the rest of the codebase.

Compared against: `Dismisser`, `Flipper`, `Shifter`, `Visibility`, `ContentLoader`, `Calendar`/`CalendarSelector`, `Timeline`, `RovingTabIndex`/`ListboxNavigation`.

## Findings

### 1. ARIA.md has no entry for Reorderable
**File:** `ARIA.md`

Every other interactive controller has a subsection under `## Component-Specific Patterns (APG)` — Modal, Popover, Combobox, Calendar, Form Fields, Password Reveal, Flipper/Visibility/Dismisser, Button, List, Avatar/Card/Icon, Timeline. Reorderable introduces a new pattern (roving tabindex + live-region move announcements + `aria-disabled`/`tabindex`-only trigger neutralization, with pointer clicks intentionally left unblocked) but has no corresponding entry.

**Risk:** a future change to the disabled/tabindex or announce behavior has no ARIA.md entry to check against, silently regressing accessibility. This is also a direct miss against the project's own CLAUDE.md rule: "ARIA/WCAG patterns → ARIA.md only."

**Verdict:** CONFIRMED

### 2. Component doc restates ARIA facts inline instead of linking to ARIA.md
**File:** `stimulus-plumbers/docs/component/reorderable.md`

The doc inlines ARIA-relevant behavior (pointer-drag doesn't move focus/announce vs. keyboard-move does both; `aria-disabled`/tabindex neutralization; pointer clicks not blocked by JS) rather than linking out. Violates the project's "no cross-doc duplication" rule, which assigns ARIA/WCAG content exclusively to `ARIA.md`.

**Verdict:** PLAUSIBLE

### 3. Keyboard-move and pointer-drag are wired through different mechanisms
**File:** `stimulus-plumbers/src/controllers/reorderable_controller.js` vs. `stimulus-plumbers/src/plumbers/reorderable.js`

The `keydown` handling lives entirely in the **plumber**: `reorderable.js`'s `attachItem`/`detachItem` call `item.addEventListener('keydown', this.onKeydown)` itself, so the controller never sees a keydown at all. Pointer handling is the opposite split: the **controller** owns `onPointerDown`/`onPointerMove`/`onPointerUp` (wired via `data-action` in markup) and only forwards into the plumber's `startDrag`/`drag`/`endDrag`. Same component, same "reorder the list" responsibility, two different owners for where the DOM listener is attached — one self-attaches internally, the other requires the consumer's HTML to opt in.

Both are presented in the docs as equally-supported reorder mechanisms, but only one requires markup wiring.

**Risk:** a consumer who copies the item markup but forgets the handle's `data-action` wiring gets working keyboard-move and silently broken drag, with no error.

**Verdict:** PLAUSIBLE (may be an accepted tradeoff — pointer targets don't have a `handleTargetConnected` lifecycle hook today, so having the plumber self-attach pointer listeners the same way it does keydown would require adding one)

### 4. Reorderable is the only plumber that reads Stimulus-generated members off the controller
**File:** `stimulus-plumbers/src/plumbers/reorderable.js:22-23,35`

```js
get items() {
  return this.controller.itemTargets;
}
...
if (!this.controller.editingValue) return;
```

Every other plumber only *writes* to the controller (the `enhance()` pattern: `this.controller.shift = this.shift`, `this.controller.flip = this.flip`, wrapping `disconnect`) or calls the universal `dispatch()`. Concrete elements/config flow in through constructor `options` instead (Flipper takes `anchor`/`element`, Shifter takes `element`, Dismisser takes `trigger`/`element`, ContentLoader takes `url`/`content`), keeping those plumbers agnostic to any specific controller's target/value naming.

Reorderable hardcodes the target name `item` and value name `editing`, inverting the dependency direction relative to the rest of the codebase — it cannot be reused with a controller that names these differently.

**Likely justified:** both need to be read *live* (items connect/disconnect over time; editing is a live toggle), which the existing snapshot-at-construction options pattern doesn't support. Still worth naming as a reuse/consistency regression.

**Verdict:** CONFIRMED

### 5. `midpointOf()` reimplements rect math instead of using the shared geometry module
**File:** `stimulus-plumbers/src/plumbers/reorderable.js:98-101`

```js
midpointOf(item) {
  const rect = item.getBoundingClientRect();
  return rect.top + rect.height / 2;
}
```

`plumber/geometry.js` already centralizes rect/viewport math (`defineRect`, `viewportRect`, `isWithinViewport`) and is used by Flipper, Shifter, and the base `Plumber.visible` getter. Reorderable's midpoint calculation reimplements the same category of logic locally instead of extending that module.

**Risk:** a future geometry fix (e.g., accounting for CSS transforms/zoom, as `shifter.js`'s `elementTranslations` already does) lands in `geometry.js` and is picked up automatically by Flipper/Shifter, but Reorderable's inline math silently keeps the old behavior.

**Recommendation:** extract a `verticalCenter(rect)` (or similar) helper into `geometry.js`; Reorderable should import it like the others do. **Scoped out as a separate, low-risk refactor** — not done as part of this audit.

**Verdict:** CONFIRMED

### 6. No guard against keyboard auto-repeat on the move handler
**File:** `stimulus-plumbers/src/plumbers/reorderable.js:34-56` (`onKeydown`)

`keydown` is the correct event choice — it's the only key event used anywhere in this codebase (`RovingTabIndex`, `ListboxNavigation`, `FocusTrap`, `input_clearable_controller`'s Escape), and matches WAI-ARIA APG convention (arrow-key navigation always fires on keydown; keyup is reserved for button/link activation semantics). No issue with the event choice itself.

However, no code path in the codebase checks `event.repeat` (confirmed via full-repo grep — zero hits). That's harmless for `RovingTabIndex`/`ListboxNavigation`, where holding an arrow key just repeatedly moves focus/selection. It's not harmless here: each `onKeydown` firing does a live DOM move, `dispatch('reordered', ...)`, and `announce(...)`. Per the component's own docs, the intended consumer pattern is "listen for `reorderable:reordered` and send `itemIds` to your backend." Holding `Alt+ArrowDown` triggers OS key-repeat (every ~30-50ms), which will:

- flood the aria-live region with rapid position announcements, and
- flood a backend consumer following the documented persistence pattern with a request per repeat tick.

**Recommendation:** guard with `if (event.repeat) return;` (or debounce the dispatch/announce independent of the DOM move) in `onKeydown`.

**Verdict:** CONFIRMED — not yet applied.

### 7. Initial-item attach and later-item attach are two different code shapes for the same operation
**File:** `stimulus-plumbers/src/controllers/reorderable_controller.js`

```js
connect() {
  this.reorderable = attachReorderable(this, { moveKey: this.moveKeyValue, onMoved: 'moved' });
  this.itemTargets.forEach((item) => this.reorderable.attachItem(item));
  ...
}

itemTargetConnected(item) {
  this.reorderable?.attachItem(item);
  ...
}
```

Not a bug — Stimulus's `Context.connect()` starts the `targetObserver` (which fires `itemTargetConnected` for every pre-existing target) *before* calling `controller.connect()`. So `itemTargetConnected` fires for all initial items while `this.reorderable` is still `undefined`, making `this.reorderable?.attachItem(item)` a silent no-op for them; the explicit `forEach` in `connect()` is what actually attaches listeners to items present at load. `itemTargetConnected` then only does real work for items added later (Turbo Stream append, JS insertion, etc.).

Compare `timeline_controller.js`, which has the identical "initial vs. later" split but doesn't expose it as two different call shapes:

```js
connect() {
  this.rovingTabIndex = new RovingTabIndex(this.triggerTargets, { orientation: 'vertical' });
  this.rovingTabIndex.activate();
}
triggerTargetConnected(trigger) {
  ...
  this.rovingTabIndex?.updateItems(this.triggerTargets);
}
```

`RovingTabIndex` takes the whole array up front and exposes `activate()` to bulk-wire it; the controller never manually loops per item. `Reorderable`'s plumber only exposes a per-item `attachItem`/`detachItem`, forcing the controller to hand-roll the initial `forEach`.

**Recommendation:** give `Reorderable` a bulk `attachItems()` (or have it self-attach the initial set in its constructor, mirroring `RovingTabIndex`), so `connect()` reduces to `this.reorderable = attachReorderable(...)` with no manual loop, and `itemTargetConnected` remains the one path for later additions.

**Verdict:** CONFIRMED (cosmetic/API-shape issue, not a functional bug)

## Out of scope (separate follow-up)

- **KEYS constants in `keyboard.js`:** raw key-string literals (`'ArrowUp'`, `'Escape'`, `' '`, etc.) are already the consistent, codebase-wide convention (`keyboard.js`, `combobox_time_controller.js`, `input_clearable_controller.js`, `reorderable.js` all do this identically). `MODIFIER_KEYS` exists only because modifier keys need to map to a boolean event property (`Alt` → `event.altKey`), not because of a general naming convention. Introducing a `KEYS` object would be a stylistic refactor touching 5+ existing files, not a fix for anything reorderable did wrong — scoped out as independent, optional work.
