# Checklist Native `<input>` Migration — Design

## Context

The Checklist component (`sp_checklist`, including the select-all master toggle added in `docs/superpowers/plans/2026-07-11-checklist-select-all.md`) currently hand-simulates a checkbox: `<button type="button" role="checkbox">` with `aria-checked` synced by JS, a custom `<span>` box, and inset SVG check/minus icons toggled via CSS.

This design hand-simulation was the direct cause of four bugs during the select-all implementation (missing glyph markup, an unstyled master button, a non-reactive icon requiring an overlay-stack rewrite, and unfixable flaky Enter/Space keyboard tests in Capybara/Cuprite that had to be deleted). Separately, the codebase already has a native-`<input>` precedent for checkbox/radio-like controls in the form builder (`stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/checkbox.rb`, `radio.rb`, styled by `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/form/input.rb`'s `CHECKBOX_TYPES`/`RADIO_TYPES`) that uses plain `<input type="checkbox">`/`<input type="radio">` with no `appearance: none` and no custom glyph markup.

This design replaces the Checklist component's `role="checkbox"` button pattern with native `<input type="checkbox">`, following that existing precedent, across all three packages (`stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`).

## Goals

- Item and master checkboxes become real `<input type="checkbox">` elements — native keyboard/focus/announce semantics, no hand-rolled ARIA sync.
- Readonly items use native `disabled` instead of `aria-readonly` + `tabindex="-1"`.
- Completed (checked) + readonly items show both the disabled look and a strikethrough title.
- Master "select all" mixed state uses native `input.indeterminate` instead of the current dual-icon overlay hack.
- Follow the codebase's existing checkbox/radio visual precedent (no `appearance: none`, no custom SVG glyphs, `CHECKBOX_TYPES`-style sizing/border/background).
- Public Ruby API (`checklist.item(checked:, readonly:)`, `select_all:`, `select_all_label:`) is unchanged — only rendered HTML changes.

## Non-goals

- No compatibility shim or opt-in flag for the old button-based markup. All packages are pre-1.0 (`0.4.8`); this ships as a normal breaking change (minor version bump under current semver-not-yet-1.0 convention), not a major-version event.
- No change to other components' checkbox/radio styling (`CHECKBOX_TYPES`/`RADIO_TYPES` in the form builder) beyond reusing the existing pattern — if those are later found to need their own tweaks (e.g. `accent-color` on checkbox), that's a separate change.
- No new "informational but focusable" readonly variant — user confirmed native `disabled` (out of tab order) covers the actual use cases in play.

## Decisions

### 1. Breaking change, no compat path
Confirmed: cut over cleanly. Old `<button role="checkbox">` markup is removed entirely, not kept behind a flag.

### 2. Item markup: `<label>` wraps `<input type="checkbox">` + content
Mirrors the form builder's existing `render_check_box_label` pattern (`builder.label { safe_join([check_box, text]) }`). No separate glyph `<span>` — the input itself is the visible box, styled directly.

```html
<label data-controller-target-scope="...">
  <input type="checkbox" checked disabled>
  <span class="content"><span class="title">Buy milk</span></span>
</label>
```

Readonly (`readonly: true`) → `disabled: true` on the input. No `aria-readonly`, no `tabindex="-1"` — native `disabled` already removes the control from the tab order and announces it as unavailable.

### 3. Visual styling: follow existing checkbox/radio precedent
No `appearance: none`, no custom SVG. New `checklist_item_input_classes` theme key follows `CHECKBOX_TYPES`'s shape (`size-(--sp-control-size) rounded-(--sp-radius-sm) border border-(--sp-color-border) bg-(--sp-color-muted) focus:ring-... disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer`). Master reuses the same input classes and the same row (`checklist_item_classes`) — `checklist_select_all_classes` is removed as a separate theme key since master and item rows are now visually identical.

### 4. Completed + readonly: disabled + strikethrough
`:checked` and `:disabled` are independent states on the same `<input>` — both can be true at once, with no interaction between them. Strikethrough is keyed off `:checked` (not `:disabled`) via a new `:has()`-based variant:

- `TITLE_BASE`'s `group-aria-checked/checklist-item:line-through` becomes `group-has-checked/checklist-item:line-through` (Tailwind v4's `:has()` support), since the input and title `<span>` are now siblings under the `<label>`, not button-descendants.
- The dimmed look comes from the existing `disabled:opacity-50 disabled:cursor-not-allowed` pattern, applied independently.

A checked + disabled item therefore gets both effects automatically — no new theme code beyond what's already specified above.

### 5. Master "select all": native `indeterminate`, no glyph markup
Master is `<input type="checkbox" data-checklist-target="master">` in a `<label>`, same row/input styling as items. No check/minus SVG icons, and therefore no `render_select_all_glyph`/`render_select_all_icon` methods — the browser's native checkbox glyph covers all three states once `checked`/`indeterminate` are set correctly.

**Accepted tradeoff**: `indeterminate` has no HTML attribute — it's JS-only. The server can render `checked` correctly for all-true/all-false, but the mixed case renders unchecked initially and flips to indeterminate once Stimulus connects (a brief flash). Today's SSR-computed `aria-checked="mixed"` had no such flash. Given Stimulus connects near-instantly, this is accepted as a minor, non-blocking regression.

Because indeterminate can't be server-rendered anyway, the private helper that computes the master's initial state simplifies from a three-state string (`"true"`/`"false"`/`"mixed"`) to a boolean: `all_items_checked?` (replaces `aggregate_checked_state`), matching this codebase's `?`-suffix predicate convention (`Form::Field#required?`, `Form::Field#error?`, `Components::Icon.icon_name?`). It only needs to decide whether to render `checked: true` on the master; every non-all-checked case (including mixed) renders unchecked and lets `checklist#recompute` correct it on connect.

### 6. Item-level Stimulus controller: dropped entirely
Confirmed via grep: nothing outside the checklist/checklist-item file pair consumes `checklist-item:toggle`/`toggled` events. Native checkboxes need no JS to toggle, sync their own visual state, or announce to assistive tech, so `checklist_item_controller.js` is deleted in full: the controller file, its unit test, its doc page (`docs/component/checklist-item.md`), its `index.js` export, and its README row.

### 7. Master controller: targets, not outlets
The `checklist` controller stays on the wrapper, rebuilt around Stimulus targets instead of outlets (outlets existed specifically to reach across to the separate item controller, which no longer exists). Method shape follows this codebase's documented naming convention (`stimulus-plumbers/docs/component/combobox.md`'s "Naming convention" table: `onX(event)` = thin event adapter that extracts payload and calls a programmatic method; `x(value)` = pure logic, no event awareness, callable directly — see `input_formatter_controller.js`'s `onChange`/`format` split for the existing precedent):

```js
static targets = ['master', 'item'];

connect() {
  this.recompute();
}

onChange(event) {
  if (event.target === this.masterTarget) this.toggleAll(this.masterTarget.checked);
  this.recompute();
}

toggleAll(checked) {
  this.enabledItems().forEach((item) => { item.checked = checked; });
}

recompute() {
  const items = this.enabledItems();
  const checkedCount = items.filter((item) => item.checked).length;
  this.masterTarget.checked = items.length > 0 && checkedCount === items.length;
  this.masterTarget.indeterminate = checkedCount > 0 && checkedCount < items.length;
}

enabledItems() {
  return this.itemTargets.filter((item) => !item.disabled);
}
```

Wired via a single `data-action="change->checklist#onChange"` on the wrapper — native `change` bubbles from any checkbox (master or item), so no custom events are needed. Readonly items are excluded from aggregation and bulk-toggling via `enabledItems()`'s `!item.disabled` filter (mirrors the outlet-selector exclusion the previous design got "for free").

Clicking the master relies on native checkbox click behavior for its own state transition (indeterminate/unchecked → checked; checked → unchecked — exactly "select all"/"deselect all" semantics) with zero custom aggregate-then-invert logic; `onChange` only needs to cascade that resulting `checked` value to the items via `toggleAll`, which stays a pure, directly-testable method with no event dependency.

`select_all:`/`select_all_label:` render options and the `checklist` Stimulus identifier are unchanged; only the master's own HTML changes (no glyph markup, `data-checklist-target="master"` on the `<input>` instead of the `<button>`).

## Testing impact

- **Deleted**: `checklist_item_controller.test.js`, `docs/component/checklist-item.md`, and all references to `checklist-item:toggle`/`toggled` in tests/docs.
- **Rewritten**: `checklist_controller.test.js` (targets, not outlets); Rails unit tests (`checklist_test.rb` and `checklist/item_test.rb`) — assert `input[type=checkbox]` + `.checked`/`.disabled` instead of `button[aria-checked]`/`aria-readonly`; a11y tests (`checklist_accessibility_test.rb`) — use Capybara's native `check`/`uncheck`/`find_field` instead of `button[aria-checked=...]` selectors.
- **Likely restorable**: the Task 5 flaky Enter/Space keyboard tests that were deleted for the button version. Native checkboxes have well-defined Capybara keyboard semantics and don't hit the click-to-focus double-toggle problem `send_keys` had on `<button>`. Re-adding this coverage is in scope for this migration.
- **Playwright snapshots**: existing baselines are invalid regardless (visual change); new baselines generated by the user post-implementation, as usual — never run by an implementer.
- **`ARIA.md`**: the Checklist section shrinks substantially — most of the current custom-ARIA guidance (aria-checked sync, mixed-state rationale, readonly tabindex hack) is replaced by "this is native browser behavior," with only the indeterminate-flash tradeoff and the disabled-exclusion-from-aggregation behavior remaining as component-specific notes.

## Open items resolved during brainstorming (for the record)

- Readonly use case survey (informational/locked vs. gated/not-yet-available) → user confirmed collapsing both into native `disabled` is sufficient; no focusable-but-inert variant needed.
- Visual styling: custom box+icon vs. native browser appearance → resolved in favor of following the existing `CHECKBOX_TYPES`/`RADIO_TYPES` precedent.
- Item controller: keep a lightweight controller vs. drop entirely → resolved in favor of dropping it.
