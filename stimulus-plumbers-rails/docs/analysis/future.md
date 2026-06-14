# Future — Proposals Not Yet Started

---

## 1. Accordion Component

### Pattern decision: Accordion, not Tree

Use **Accordion** (disclosure pattern) for nav sidebars and collapsible panels. `role="tree"` support is inconsistent across screen readers, requires keeping `aria-level`/`aria-setsize`/`aria-posinset` in sync dynamically, and doesn't match a link-based nav where users expect Tab (not arrow) navigation.

A genuine tree widget (file browser, nested checklist) should be implemented separately as `Tree` + `Tree::Node` with the full treeitem ARIA pattern. Do not repurpose `Accordion`.

### ARIA shape

```html
<div data-controller="accordion">
  <div>
    <button
      aria-expanded="false"
      aria-controls="acc-panel-1"
      data-accordion-target="trigger"
      data-action="click->accordion#toggle keydown->accordion#onKey"
    >
      Reports
    </button>
    <div id="acc-panel-1" hidden data-accordion-target="panel">
      <!-- arbitrary content -->
    </div>
  </div>
</div>
```

### Stimulus controller (`accordion_controller`)

- Targets: `trigger` (`<button>`), `panel` (hidden region)
- Toggle: flip `aria-expanded` + `hidden` on the paired panel
- Values: `single: Boolean` — if true, close other panels on open
- Keyboard: roving tabindex across triggers (reuse `RovingTabIndex` from `keyboard.js`)

### Ruby component

```ruby
sp_accordion do |a|
  a.item(title: "Reports", icon: "chart-bar") do |panel|
    panel.content { "arbitrary content or nested sp_list" }
  end
  a.item(title: "Settings", icon: "cog")
end
```

### Theme keys needed

`accordion`, `accordion_item`, `accordion_trigger`, `accordion_trigger_open`, `accordion_panel`, `accordion_icon` (chevron rotation on open)

---

## 2. Combobox Popover Redesign ✅ Implemented

Replaced `Combobox::Variant` with a builder DSL: `sp_combobox(value:, label:) { |c| c.dropdown/typeahead/date/time }`.

`Combobox::Builder` (a `Plumber::Slots` subclass) is yielded to the block; `c.*` methods record `(renderer, options)` in a single `:variant` slot and return `nil` (ERB-safe). Each variant renderer (`Combobox::Dropdown/Typeahead/Date/Time`) carries a nested `Metadata` module (`haspopup`, `popup_id_for`, `trigger_icon`, `trigger_options`, `stimulus_data`); the builder exposes `#metadata` (or `DefaultMetadata`) + `#render_panel`. `c.custom` is deferred. `sp_combobox_*` helpers are thin wrappers.

**As-built spec + deltas:** [`combobox-popover-redesign.md`](combobox-popover-redesign.md)

---

## 3. List Reuse in Combobox Dropdown

> `ActionList` was renamed to `List` — all ActionList references mean List/`sp_list`.

`List` renders `role="list"` groups. Combobox dropdown manages its own option rendering with `role="option"` + `role="listbox"`. The goal is to unify by using `List` as the rendering backbone for combobox dropdown options.

### What already works

- `List#render_list` accepts `role:` as a kwarg → pass `role: "listbox"` for combobox use, no change needed
- `List::Section` renders inner `<ul aria-label="...">` with `role="group"` — matches combobox option group requirements

### Item role — two options

**Option A — pass-through kwargs (recommended to start):**

```ruby
list.item("Monthly", role: "option", aria: { selected: "false" }, data: { value: "monthly" })
```

Works today; no code change needed. `List::Item#build` passes `**kwargs` through `merge_html_options`.

**Option B — typed item mode:**

```ruby
list.item("Monthly", type: :option, value: "monthly", selected: false)
```

Cleaner API but adds Item complexity. Introduce only if Option A reveals consistent boilerplate.

### Constraints

- `role="listbox"` requires direct children with `role="option"` or `role="group"`. The `<li>` section wrapper (`List::Section`) currently has no role — it would need `role="presentation"` or `role="none"` in listbox mode to avoid required-children violations.
- `combobox_dropdown_controller` queries `[role="option"]` for ↑↓ navigation — works regardless of whether List or a raw template produced the HTML.
- Validate against axe when integrating.

---

## 4. Dashboard v3 Gaps

Eleven missing components and four partial gaps identified against the fundravel dashboard-v3 design (5 screens: Upcoming, Empty State, Discover, New Trip sheet, Success).

**Top missing components by priority:**

1. **Date range mode for `sp_combobox_date`** (A11) — start + end date selection; controller needs range mode with two-date state machine
2. **`sp_sheet`** bottom sheet / drawer (A3) — slide-up modal with scrim + drag handle; `modal_controller` currently targets dialog only
3. **`sp_bottom_nav`** (A1) — 4-item bottom navigation bar; pure markup + theme work
4. **`sp_tabs`** pill variant (A2) — needs `role="tablist"` ARIA + tab controller with keyboard navigation
5. **`sp_badge` / `sp_chip`** (A4) — trip countdown chips, destination tags, list item badges
6. **`sp_progress_bar`** (A5) — `role="progressbar"`, `aria-valuenow/min/max`

**Partial gaps in existing components:** `sp_card` cover slot (B1), `sp_button` FAB variant (B2), `sp_button` notification badge (B3), `sp_divider` center label (B4).

**Full screen-by-screen breakdown:** [`dashboard-v3-gap-analysis.md`](dashboard-v3-gap-analysis.md)
