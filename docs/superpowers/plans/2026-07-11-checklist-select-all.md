# Checklist Select-All Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional master "select all" toggle to `sp_checklist` — a `role="checkbox"` control that reflects the aggregate state of all interactive items (`true` / `false` / `mixed`) and checks/unchecks all of them on click.

**Architecture:** New JS controller `checklist` lives on the existing `role="group"` wrapper, alongside the per-item `checklist-item` controllers (unchanged). It reaches each item via a Stimulus **Outlet** (`static outlets = ['checklist-item']`) — the same cross-controller pattern already used by `input_combobox_controller.js` and `combobox_date_controller.js` — rather than merging item state into a shared controller. This preserves the item-level Values-driven design (mirrors `progress_controller`) and keeps readonly items (no `checklist-item` controller attached) automatically excluded from both aggregation and bulk toggling.

Outlet selectors resolve document-wide in Stimulus, not scoped to the host element's subtree, so the selector must be scoped by the wrapper's own DOM id to avoid crosstalk between multiple checklists on one page:
```
data-checklist-checklist-item-outlet="#<wrapper-id> [data-controller~='checklist-item']"
```
(Stimulus's outlet attribute format doubles the controller identifier: `data-${identifier}-${outletName}-outlet` — confirmed against `@hotwired/stimulus`'s `outletAttributeForScope`. Corrected here 2026-07-12 after Task 3 review caught the plan's original single-prefix form as a bug.)

Master button state: `aria-checked="true"` (all items checked) / `"false"` (none checked, or zero items) / `"mixed"` (some checked) — `"mixed"` is ARIA-legal for `role="checkbox"` and is the standard indeterminate value read by screen readers. Recomputed on connect and whenever a `checklist-item:toggled` event bubbles up from an item (native DOM bubbling — no extra wiring needed beyond one `data-action` on the wrapper). Clicking the master button when `mixed` or `false` checks all items; when `true`, unchecks all — standard "select all" semantics. Bulk-setting `outlet.checkedValue = ...` reuses the item controller's existing external-mutation path (`checkedValueChanged`), already covered by an existing test — **no changes to `checklist_item_controller.js` needed.**

**Tech Stack:** Same as the base Checklist component — Stimulus, Rails view components, Tailwind v4 theme module, Minitest + Capybara/axe-core, Playwright, Vitest.

## Global Constraints

- Do not modify `stimulus-plumbers/src/controllers/checklist_item_controller.js` or its dispatch contract (`checklist-item:toggle`/`checklist-item:toggled`) — the new controller only reads/sets `checkedValue` via outlets and listens for the existing bubbled event.
- Readonly items (`readonly: true` on `Checklist::Item`) never render `data-controller="checklist-item"` — they must be excluded from the master's aggregate computation and from bulk check/uncheck, which falls out for free from the outlet selector (`[data-controller~='checklist-item']` never matches them). Do not special-case them elsewhere.
- `select_all:` defaults to `false` on `Checklist#render` — existing `sp_checklist` call sites must render unchanged output with no code changes.
- New theme keys reuse `checklist_item_box`/`checklist_item_check` for the master's glyph box (checked state); indeterminate state uses `name: "minus"` — already a bundled, generic heroicon (`minus.svg`), no new `Icon::ALIASES` entry needed. One new theme key, `checklist_select_all`, styles the master `<button>` itself (parallel to `checklist_item`).
- Follow the "no cross-doc duplication" rule from the root `CLAUDE.md`: JS controller API → `stimulus-plumbers/docs/component/checklist.md` (new file — the group-level controller doc, distinct from the existing `checklist-item.md`); Rails helper options → `stimulus-plumbers-rails/docs/component/checklist.md`; ARIA rationale → `ARIA.md` only.

---

### Task 1: JS — `checklist` Stimulus controller

**Files:**
- Create: `stimulus-plumbers/src/controllers/checklist_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/checklist_controller.test.js`

**Interfaces:**
- Identifier: `checklist`. `static targets = ['master']`, `static outlets = ['checklist-item']`.
- `checklistItemOutletConnected(outlet)` / `checklistItemOutletDisconnected()` — recompute aggregate.
- `recompute()` — action method, wired via `data-action="checklist-item:toggled->checklist#recompute"` on the wrapper; also called from outlet connect/disconnect.
- `toggle()` — action method for the master button's click; checks all if aggregate is `false`/`mixed`, unchecks all if `true`.
- Uses `setChecked` from `../accessibility/aria` (existing export) to write `aria-checked`. Confirmed: `setChecked` calls `element.setAttribute('aria-checked', value.toString())` with no boolean coercion, so passing the string `'mixed'` already works today — no change needed to `aria.js`.

**Coverage:** all-checked → master `true`; all-unchecked (or zero items) → master `false`; mixed → master `mixed`; clicking master when `mixed`/`false` sets all outlets' `checkedValue = true`; clicking when `true` sets all to `false`; recomputes when an item dispatches `checklist-item:toggled` without going through the master; readonly items (no outlet) are excluded from aggregation.

### Task 2: JS — export, register, README, docs

**Files:**
- Modify: `stimulus-plumbers/src/index.js` (export `ChecklistController`)
- Modify: `stimulus-plumbers/README.md` (Controllers table row + `application.register('checklist', ChecklistController)` — alphabetical placement before `checklist-item`)
- Create: `stimulus-plumbers/docs/component/checklist.md` (Stimulus Identifier, Targets, Outlets, Actions, Dispatches — if any —, Example HTML; cross-link to `checklist-item.md` and to the Rails doc)

### Task 3: Rails — `Checklist#render` select-all option

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist_test.rb`

**Interfaces:**
- `render(label: nil, labelledby: nil, select_all: false, select_all_label: "Select all", **kwargs, &block)`.
- When `select_all:` truthy: wrapper gets `id: template.sp_dom_id`, `data-controller="checklist"`, `data-checklist-checklist-item-outlet: "##{id} [data-controller~='checklist-item']"`; renders a master `<button type="button" role="checkbox" aria-checked="false" data-checklist-target="master" data-action="click->checklist#toggle" aria-label="#{select_all_label}">` before the yielded items.
- When `select_all:` false (default): wrapper output is byte-for-byte unchanged from today.
- **Initial `aria-checked` on the master button is computed server-side — no flash of the wrong state.** Reorder `Checklist#render` to capture items (`template.capture(self, &block)`) *before* building the wrapper's `html_options`/master button, and have `Checklist#item` push each non-readonly item's `checked:` onto an accumulator (only when `select_all:` is truthy, so the no-op path stays exactly as-is):
  ```ruby
  def render(label: nil, labelledby: nil, select_all: false, select_all_label: "Select all", **kwargs, &block)
    @item_states = [] if select_all
    captured = template.capture(self, &block)
    master = select_all ? render_select_all(select_all_label) : nil
    html_options = merge_html_options(theme.resolve(:checklist), kwargs, { role: "group", aria: labelled_aria(label, labelledby: labelledby) })
    html_options = merge_html_options(html_options, select_all_wrapper_attrs) if select_all
    template.content_tag(:div, template.safe_join([master, captured].compact), **html_options)
  end

  def item(content = nil, **kwargs, &block)
    @item_states << kwargs[:checked] if @item_states && !kwargs[:readonly]
    Checklist::Item.new(template).render(content, **kwargs, &block)
  end
  ```
  Aggregate: empty or all-false → `"false"`; all-true → `"true"`; otherwise → `"mixed"`. This touches only `checklist.rb` — `Checklist::Item`/`checklist_item.rb` stays untouched, matching the Global Constraints.

### Task 4: Tailwind — theme keys

**Files:**
- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/checklist.rb` (add `checklist_select_all_classes`)
- Test: `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/checklist_test.rb`

**Coverage:** master button base styling parallels `checklist_item_classes`; verify Tailwind v4's `aria-checked:` variant syntax covers the `mixed` case (may need the arbitrary form `aria-[checked=mixed]:` rather than a built-in shorthand — confirm during implementation) for showing the minus glyph vs. the check glyph vs. neither.

### Task 5: Rails a11y tests + sandbox

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/app/views/components/checklist.html.erb` (add a `select_all: true` section)
- Modify: `stimulus-plumbers-rails/test/accessibility/components/checklist_accessibility_test.rb`

**Coverage:** axe-core passes with `aria-checked="mixed"` present; keyboard (Enter/Space) toggles all via the native button; clicking master with all-checked unchecks all; readonly items unaffected by select-all.

### Task 6: Tailwind Playwright snapshots

**Files:**
- Modify: `stimulus-plumbers-tailwind/test/sandbox/app/views/components/checklist.html.erb`
- Modify: `stimulus-plumbers-tailwind/test/snapshots/checklist.spec.js`

**Coverage:** mixed (default fixture), all-checked, all-unchecked, click-to-check-all, click-to-uncheck-all. Per this gem's CLAUDE.md, `test:snapshots:update` stays user-run — do not run it from the implementer role.

### Task 7: Docs — ARIA.md + cross-references

**Files:**
- Modify: `ARIA.md` (extend the Checklist section with the master-toggle `mixed` rationale)
- Modify: `stimulus-plumbers-rails/docs/component/checklist.md` (`select_all:`/`select_all_label:` options + example + rendered HTML)

---

## Open Design Decisions

1. **Naming**: `select_all:`/`select_all_label:` vs. some other keyword — no existing precedent in this codebase for this exact shape, so this is a fresh naming call. Flag for review during Task 3, not a blocker.
