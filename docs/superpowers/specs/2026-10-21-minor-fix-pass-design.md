# Minor-fix pass — post-modernization maintenance

**Original date:** 2026-10-21  
**Status:** Proposed — revised after maintainer review  
**Packages:** `stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`  
**Roadmap:** Phase 5 of [component modernization](./2026-09-11-component-modernization-roadmap.md)  
**Minimum:** Turbo 8 for morph handling (M0)

## Summary

The modal, popover, combobox, and calendar redesigns have landed, so the small controllers can be
re-audited against stable boundaries. A maintainer review re-checked the roadmap's seven
candidates and found more defects. Two of them, credit-card length and revealed-password caching,
are hotfix-class and ship as a patch from `main`.

The work ships in three batches: a 0.4.18 patch, behavior and Turbo morph fixes, and one
deprecation window. Two roadmap items are dropped.

## Goals

- Fix every defect below that affects a supported public path today.
- Survive Turbo morph refreshes and stream appends/removals without app-side workarounds.
- Retire utilities with no internal consumer through one versioned compatibility window.
- Keep Turbo an optional dependency.

## Non-goals

- New features or API redesigns beyond what a fix requires.
- Hotwire Native gates. They belong to the modal, calendar, and combobox-date release.

## Release plan

| Batch                  | Base                                                    | Release                               |
| ---------------------- | ------------------------------------------------------- | ------------------------------------- |
| 1 — Hotfixes           | `main`, one PR each, merged forward into `fix/combobox` | 0.4.18                                |
| 2 — Behavior and morph | `fix/minor-fix-pass`                                    | 0.5.0, with the redesigns             |
| 3 — Deprecations       | `fix/minor-fix-pass`                                    | deprecated in 0.5.0, removed in 0.6.0 |

**Release prerequisite.** git-cliff's parsers (`stimulus-plumbers/cliff.toml`) don't match
`feat!:`/`refactor!:`, and `filter_commits = true`, so the redesign's breaking commits may be left
out of the changelog. Fix the parsers, add a Deprecations group, and confirm with
`bin/release <v> --dry-run` before 0.5.0.

## Batch 1 — Hotfixes (0.4.18)

The files involved are identical on `main` and `fix/combobox`.

### H1 — Credit-card length counts the formatter's spaces

- Rails sets `maxlength = groups.sum` (`credit_card.rb`), but the formatter inserts one space per
  group break. After 13 digits, `"4242 4242 4242 4"` reaches 16 characters and the browser blocks
  further input.
- The formatter ignores `groups` and always groups by 4 (`formatters/credit_card.js`).
  `Formatter` passes only `optionsValue` to `format`.
- Fix:
  - Rails: `maxlength = groups.sum + groups.length - 1`. The Rails `separator:` option is a
    decorative `aria-hidden` cell separator and is not counted.
  - JS: thread `groupsValue` into `attachFormatter`, and re-attach on `groupsValueChanged`.
    Without groups, keep grouping by 4.
  - Digits past `groups.sum` stay as a trailing group. No truncation on connect, so stored values
    are never rewritten.
- Tests: Rails unit for `maxlength`, updating the existing assertions of 16 and 19. vitest for
  grouped formatting. Playwright for engine-enforced `maxlength` when typing and when pasting a
  spaced full card.
- Docs: `stimulus-plumbers-rails/docs/component/form.md` (`maxlength` rule);
  `input-formatter.md` and `docs/plumber/formatter.md` (display follows groups; fix the
  `maxlength="16"` example).

### H2 — Revealed passwords persist in the page cache

- Turbo clears only `input[type="password"]` when caching. `input-revealable` switches the input to
  `type="text"` and stores `revealed` as an attribute, so Back restores the password in plain
  text.
- Fix: on `turbo:before-cache` and `pagehide`, set `revealed = false` and call `draw()`
  synchronously. Value callbacks are async, and the cache clone must already see
  `type="password"`.
- Tests: vitest asserts `type="password"` synchronously after each event is dispatched.
- Docs: `input-revealable.md` note that navigating away conceals.

## Batch 2 — Behavior and morph fixes

### B1 — Reorderable drags end cleanly (own PR)

- Handles get only `pointerdown`/`pointermove`/`pointerup`. Without `pointercancel` handling,
  `draggingItem` is never cleared. Later hovers keep reordering items, no `reordered` event fires,
  and the server order drifts. Leaving edit mode mid-drag leaves the same stuck state.
- The default handle is the whole item, and `drag()` moves the dragged item itself. The element
  holding pointer capture therefore leaves the DOM on every swap.
- Fix:
  - Move the neighbours instead: `dragging.after(previous)` / `dragging.before(next)`. The capture
    target never leaves the DOM.
  - `startDrag` attaches `pointercancel` and `lostpointercapture` through an `AbortController`.
  - `endDrag` aborts and clears state before `releasePointerCapture`, so its trailing
    `lostpointercapture` finds no drag.
  - `cancelDrag()` restores the starting position and skips `reordered`. It is a no-op with no
    active drag, and runs on `pointercancel`, lost capture, and `editingValueChanged(false)`
    (guarded with `this.reorderable?.`).
  - `disconnect` only aborts and clears, with no DOM writes.
  - Tailwind: whole-item handles get `touch-none` only while editing, so the page still scrolls
    outside edit mode.
- Tests: vitest for cancel, restore, and no `reordered` on cancel (synthetic events). Playwright
  asserts capture survives a multi-swap drag in Chromium, Firefox, and WebKit.
- Docs: `docs/component/reorderable.md` and `docs/plumber/reorderable.md` (`reordered` not
  dispatched on cancel, a `cancelDrag()` row, the `touch-action: none` requirement for custom
  themes).

### B2 — Character-cells warning respects grouped mode

- `adopt()` warns when `cells.length < expected()` without checking grouped mode. Rails credit-card
  fields render one cell per group, so every default field warns, again on each
  `cellTargetConnected`.
- Contract: grouped mode is silent. Per-character mode with too few cells warns once per element
  (WeakSet).
- Tests: vitest grouped (silent) and short per-character (single warning across reconnects).
- Docs: `docs/plumber/character-cells.md` validation rule.

### M0 — Morph hook and harness (first morph task)

- Turbo 8 routes page-refresh morphs, frame morphs, and stream `[method=morph]` through
  `morphElements`, which dispatches `turbo:morph-element` (bubbling) for every morphed element.
- Stimulus already fires `*ValueChanged` for changed attributes and
  `*TargetConnected`/`Disconnected` for added or removed targets, but doesn't reconnect. A morph
  hook is needed only for state a morph overwrites while values stay the same: attributes JS
  writes, and the checkbox `checked` property.
- Helper: an internal, unexported `onMorph(controller, callback)` in `src/` that listens on the
  controller element and coalesces each morph into one `queueMicrotask` callback. It uses only
  the event name, never importing Turbo.
- Prefer server-rendered state where it removes the need for the hook.
- Harness: spike Turbo 8 `morphElements` under jsdom. Otherwise use synthetic
  `turbo:morph-element` events after DOM edits. One Playwright sandbox page with morph refreshes
  for end-to-end coverage.

### M1 — Progress re-renders on every input and after morphs

- Only `currentValueChanged` exists. Changing `indeterminate`, `min`, `max`, `format`,
  `segmentMode`, or `indeterminateFraction` doesn't re-render. Going from indeterminate to
  determinate at the same `current` leaves `aria-valuenow` missing.
- Rails renders the fill with no inline style, so a morph wipes the width, ring dash, and
  `--sp-progress-percent`.
- Fix:
  - Rails renders the fill style and `--sp-progress-percent`, as range already does. First paint
    is then correct and morphs keep it.
  - A value-changed callback for every value that affects rendering, guarded until `connect`.
  - `onMorph` re-render for the JS-only `sp-progress-indeterminate` class.
  - The range variant syncs `input.value` from `current` only after `connect`, so the native
    value is read first.
- Tests: vitest per value and after a morph; Rails unit for the rendered fill style.

### M2 — Checklist master stays in sync

- It recomputes only on `connect` and `change`. Stream appends/removals, morph-applied `checked`
  (no change event), form `reset`, and direct `toggleAll()` calls leave the master stale.
- Fix: `itemTargetConnected`/`Disconnected` and `masterTargetConnected` callbacks, `onMorph`, a
  form `reset` listener (recompute after the reset is applied), `recompute` inside `toggleAll()`,
  and a guard on `hasMasterTarget`.
- Tests: vitest for each trigger.

### M3 — Reorderable trigger state survives streams and morphs

- There's no `triggerTargetConnected`, so triggers streamed in while editing stay active. Rails
  markup has no `aria-disabled`/`tabindex`, so a morph also strips them from existing triggers.
- Fix: apply the edit state in `triggerTargetConnected`, and re-apply it to all triggers and the
  roving tabindex in `onMorph`.

### M4 — Password strength announces only real changes

- `connect` writes the level label into the `aria-live` region after `announceDelay`. On a normal
  load the text matches what Rails rendered. On Turbo restore, the snapshot holds the last typed
  level while the password is blank, so "Weak" is announced.
- Fix:
  - Write the label on connect synchronously, and only when the text differs.
  - On `turbo:before-cache`, reset the label to the empty-input level so the snapshot matches
    restore.
  - Re-score on rules/options/labels value changes, guarded until `connect`.
  - An initial level that really differs from the rendered one is still announced once. Splitting
    the visible label from a separate announcer is a markup change and out of scope.
- Docs: add the password-strength live-region rule to `ARIA.md`.

## Batch 3 — Deprecations and API cleanup

Deprecated APIs log one `console.warn` per identifier per page, get a migration entry in their
doc, and are removed in 0.6.0.

### D1 — Deprecate `FocusTrap`

- Nothing in `src/` has used it since the modal redesign. Its defects are a container-only keydown
  listener, wrapping only from the exact first/last element, `escapeDeactivates` off by default,
  and no inert background. Native `<dialog>` and popover replace it.
- Keep `focusFirst` (used by `popover-fetch`) and `getFocusableElements` (public, used by
  `focusFirst`).
- Docs: `docs/utility/accessibility.md`, `docs/accessibility/design.md` §3 and its later
  references, `stimulus-plumbers/README.md`, `stimulus-plumbers/CLAUDE.md` guidelines.

### D2 — Deprecate visibility, dismisser, flipper, panner and their plumbers

- No Rails helper or internal code uses the controllers, and popover covers their use cases. The
  Dismisser, Flipper, Shifter, and Visibility plumbers retire with them.
- Known defects, documented rather than fixed:
  - the visibility controller never passes an `activator`, so `aria-expanded` is never set;
  - visibility checks the root's visibility rather than the content's, adds a window listener per
    `contentTargetConnected`, and a second `contentTargetConnected` throws because
    `controller.visibility` isn't `configurable`;
  - dismisser ignores clicks on SVG elements;
  - flipper repositions only on click.
- Docs: deprecation notes in each component and plumber doc. Fix the stale dismisser docs
  (`click`, not `mousedown`; no modal consumer). Update the `stimulus-plumbers/README.md` register
  snippet and table rows. Mark the `ARIA.md` toggle pattern as deprecated.

### D3 — `connectTriggerToTarget` sets `aria-haspopup` only for popup roles

- The `|| 'true'` fallback (`aria.js`) gives every unmapped role, including `tooltip`, `region`,
  and `status`, `aria-haspopup="true"`, which means menu (WCAG 4.1.2).
- Fix: set `aria-haspopup` only for roles in `ARIA_HASPOPUP_VALUES`. `tooltip` keeps
  `aria-describedby` only, with no `aria-controls`.
- Docs: fix the positional signature and the false `aria-expanded` claim in
  `docs/accessibility/design.md`. Add the tooltip rule to `ARIA.md`.

### D4 — Clipboard paste is cancelled only when used

- `onPaste` always cancels the native paste, and `input-formatter#onPaste` drops anything that
  fails full validation, so a partial paste such as `"4242 4242"` is lost.
- Fix: dispatch `clipboard:pasted` as cancelable, and cancel the native paste only when a listener
  cancelled the event. `input-formatter#onPaste` cancels only when it applies the paste. `copy()`
  guards a missing event and reports failure on an empty value.
- Docs: `docs/component/clipboard.md` notes and events, plus a migration entry.

### D5 — Localizable live announcements

- `reorderable` and `timeline` hard-code English announcement strings. Timeline's announcement
  also repeats its `aria-expanded` change.
- Fix:
  - `reorderable` gets a `movedMessage` value with `{position}` and `{total}` tokens and an
    English default. `sp_ordered_list` passes an I18n default, as password strength does.
  - Drop timeline's redundant announcement.
- Docs: the reorderable component doc (value) and the Rails `ordered_list.md` (option). The MCP
  schema follows the manifest.

## Dropped

- **Progress `setValue` double render** (status-primitives follow-up 2). The second render does the
  same thing as the first, and the synchronous render is required by `setValue`'s contract.
- **Password reacting to `scorer` changes.** Nothing sets that value at runtime.

## Phase 4 upgrade-path check

The roadmap's "representative Rails app" step runs alongside this pass and does not gate it. M0's
sandbox morph page is its first deliverable.

## Testing

- vitest: logic and ARIA state for every item.
- Rails unit: H1 `maxlength`, M1 fill style.
- Playwright browser, engine-native behavior only: H1 `maxlength` (typing and paste), B1 pointer
  capture across engines, M0 morph sandbox.
- Tailwind snapshots: B1 `touch-none` doesn't change visuals, so no regeneration is expected.

## Migration

Observable changes:

- **0.4.18:** credit-card `maxlength` includes the group spaces; non-default groups display and
  submit with spaces at their own breaks; inputs conceal on page cache.
- **0.5.0:**
  - a cancelled drag reverts and dispatches no `reordered`;
  - triggers whose roles aren't popup roles lose `aria-haspopup`, and tooltips lose
    `aria-controls`;
  - native paste proceeds unless a `clipboard:pasted` listener cancels it;
  - the timeline expand/collapse announcement is removed;
  - deprecation warnings for D1 and D2.
- **0.6.0:** D1 and D2 APIs removed.

## Implementation order

1. H1, H2 as separate PRs against `main` → 0.4.18 → merge forward.
2. Changelog prerequisite (cliff parsers, Deprecations group).
3. B1 as its own PR, then B2.
4. M0, then M1–M4.
5. D1–D5, with docs and warnings in the same commits.

## Open questions

1. **Drag cancel:** revert and skip `reordered`. Agreed by review.
2. **Deprecation signal:** warn once per identifier per page, plus docs. Agreed by review.
3. **Deprecate the toggle controllers together with `FocusTrap`:** yes. Agreed by review.
4. **Version targets:** 0.4.18 patch, deprecate in 0.5.0, remove in 0.6.0. Confirm.
5. **M4 announcer split:** accept one announcement when the initial level really differs, or split
   into a visible label and an initially empty announcer (a markup change)? Recommended: accept.
