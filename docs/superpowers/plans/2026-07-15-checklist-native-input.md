# Checklist Native `<input>` Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Checklist component's `<button type="button" role="checkbox">` design with native `<input type="checkbox">` across `stimulus-plumbers`, `stimulus-plumbers-rails`, and `stimulus-plumbers-tailwind`, per `docs/superpowers/specs/2026-07-15-checklist-native-input-design.md`.

**Architecture:** Items become plain `<input type="checkbox">` inside a `<label>`, with no per-item Stimulus controller (native checkboxes need no JS for their own behavior). The master "select all" `<input type="checkbox">` keeps one `checklist` Stimulus controller, rebuilt on Stimulus **targets** (`master`, `item`) instead of Outlets, listening to native `change` bubbling instead of custom events.

**Tech Stack:** Same as the base Checklist component — Stimulus, Rails view components, Tailwind v4 theme module, Minitest + Capybara/axe-core, Playwright, Vitest.

## Global Constraints

- This is a confirmed breaking change. All three packages are pre-1.0 (`0.4.8`); ship a clean cutover, no compatibility shim, no dual-path rendering.
- No `appearance: none`, no custom SVG check/minus glyphs anywhere in the Checklist component. Follow the existing `CHECKBOX_TYPES` precedent in `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/form/input.rb` (native browser glyph, styled box via `size`/`border`/`bg`/`disabled:opacity-50`).
- `readonly: true` on `checklist.item` renders `disabled: true` on the `<input>`. No `aria-readonly`, no `tabindex="-1"` — native `disabled` already removes the control from the tab order and announces it as unavailable.
- `checklist_item_controller.js` is deleted in full: the controller file, its unit test, `docs/component/checklist-item.md`, its `index.js` export, and its README row. Confirmed via grep in the design spec that nothing outside the checklist component pair consumes its `checklist-item:toggle`/`toggled` events.
- The `checklist` controller uses `static targets = ['master', 'item']`, not Outlets. Action method naming follows the documented convention in `stimulus-plumbers/docs/component/combobox.md` ("Naming convention" table): `onX(event)` = thin event adapter wired via `data-action`, extracts payload and calls a programmatic method; `x(value)` = pure logic, no event awareness, directly callable and directly testable.
- `select_all:`/`select_all_label:` render options on `sp_checklist` are unchanged. `checklist.item(content, checked:, readonly:, **html_options)` keyword signature is unchanged. Only rendered HTML changes.
- Server-side rendering cannot express `indeterminate` (no HTML attribute for it — JS-only property). The master's initial `checked` attribute is only ever `true` (all items checked) or absent (every other case, including mixed); the `checklist` controller corrects to `indeterminate` on connect. This is an accepted, documented tradeoff — do not attempt to work around it with extra markup or inline scripts.
- No cross-doc duplication (root `CLAUDE.md`): JS controller API lives in `stimulus-plumbers/docs/component/checklist.md` only; Rails helper options live in `stimulus-plumbers-rails/docs/component/checklist.md` only; ARIA rationale lives in `ARIA.md` only.

---

### Task 1: JS — delete `checklist-item` controller, rebuild `checklist` controller on targets

**Files:**
- Delete: `stimulus-plumbers/src/controllers/checklist_item_controller.js`
- Delete: `stimulus-plumbers/tests/unit/controllers/checklist_item_controller.test.js`
- Modify: `stimulus-plumbers/src/controllers/checklist_controller.js`
- Modify: `stimulus-plumbers/tests/unit/controllers/checklist_controller.test.js`

**Interfaces:**
- Identifier: `checklist` (unchanged). `static targets = ['master', 'item']` (replaces `static outlets = ['checklist-item']`).
- Produces for later tasks: the `checklist` controller expects `data-checklist-target="master"` on exactly one `<input type="checkbox">` and `data-checklist-target="item"` on zero or more `<input type="checkbox">` elements within its own subtree, plus a single `data-action="change->checklist#onChange"` on the controller's element. Readonly items are plain `<input type="checkbox" disabled>` with `data-checklist-target="item"` still applied — exclusion from aggregation happens via `.disabled`, not via a missing target.

**Final controller implementation:**

```js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['master', 'item'];

  connect() {
    this.recompute();
  }

  onChange(event) {
    if (event.target === this.masterTarget) this.toggleAll(this.masterTarget.checked);
    this.recompute();
  }

  toggleAll(checked) {
    this.enabledItems().forEach((item) => {
      item.checked = checked;
    });
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
}
```

**Coverage** (rewrite `checklist_controller.test.js` to drop all `ChecklistItemController` imports/usage; render raw `<input type="checkbox" data-checklist-target="...">` elements directly instead of button markup):
- On connect: master `checked=true, indeterminate=false` when all items checked; `checked=false, indeterminate=false` when all unchecked or zero items; `indeterminate=true` when partially checked.
- Disabled items (readonly) are excluded from aggregation on connect (a disabled+unchecked item mixed in with checked items must not produce `indeterminate`).
- Dispatching a native `change` event from a single item (not the master) recomputes the master without touching other items.
- Dispatching a native `change` event from the master with `checked=true` sets every enabled item's `.checked` to `true`; with `checked=false` sets every enabled item's `.checked` to `false`.
- Disabled items are never touched by a master-driven `change` (their `.checked` stays whatever it was).
- Master state stays correct across repeated master toggles (true → false → true), not just the first — this is a regression test for the exact bug found in the previous select-all implementation (`toggle()` never recomputing after the first click). Assert master `.checked` after at least 3 consecutive toggles.
- `toggleAll(checked)` is callable directly (no event object) and produces the same result as a master-driven change — this is the "programmatic API, no event awareness" half of the naming convention, so it must be tested independently of `onChange`.

- [ ] Rewrite `checklist_controller.js` to the implementation above.
- [ ] Delete `checklist_item_controller.js`.
- [ ] Rewrite `checklist_controller.test.js` per the coverage list above (raw `<input>` fixtures, no `ChecklistItemController` import).
- [ ] Delete `checklist_item_controller.test.js`.
- [ ] Run `npm test` from `stimulus-plumbers/` — full suite green, not just the changed files (confirms nothing else imports the deleted controller).
- [ ] Commit.

---

### Task 2: JS — export/register/README cleanup + doc rewrite

**Files:**
- Modify: `stimulus-plumbers/src/index.js` — remove the `ChecklistItemController` export line.
- Modify: `stimulus-plumbers/README.md` — remove `application.register('checklist-item', ...)` and its Controllers table row; update the `checklist` row's description if it references outlets.
- Delete: `stimulus-plumbers/docs/component/checklist-item.md`
- Modify: `stimulus-plumbers/docs/component/checklist.md`

**Interfaces:**
- Consumes: the final controller shape from Task 1 (`targets: ['master', 'item']`, `onChange`/`toggleAll`/`recompute`/`enabledItems`).

**Rewritten `docs/component/checklist.md` content** (replaces the Outlets section with Targets, updates Actions, updates Example HTML to native inputs — no `checklist-item.md` cross-link since that doc no longer exists):

```markdown
# Checklist

Master "select all" toggle for a group of native `<input type="checkbox">` checklist items. Aggregates their `.checked` state onto a master checkbox's `checked`/`indeterminate` properties and toggles them all at once. See [stimulus-plumbers-rails's docs/component/checklist.md](../../../stimulus-plumbers-rails/docs/component/checklist.md) for the Rails render options.

## Stimulus Identifier

`checklist`

## Targets

| Name     | Purpose                                                             |
| -------- | -------------------------------------------------------------------- |
| `master` | The "select all" `<input type="checkbox">` — receives aggregate state |
| `item`   | Each checklist item `<input type="checkbox">`                        |

## Actions

| Name        | Purpose                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------- |
| `onChange`  | Wired to `change` on the wrapper — event adapter: if the event came from the master, calls `toggleAll`; always calls `recompute` |
| `toggleAll` | Programmatic API — sets every enabled item's `.checked` to the given value                        |
| `recompute` | Programmatic API — writes the master's `.checked`/`.indeterminate` from the enabled items' aggregate state |

## Example HTML

```html
<div data-controller="checklist" data-action="change->checklist#onChange">
  <label>
    <input type="checkbox" data-checklist-target="master">
    Select all
  </label>

  <label>
    <input type="checkbox" data-checklist-target="item" checked>
    Buy milk
  </label>

  <label>
    <input type="checkbox" data-checklist-target="item">
    Walk the dog
  </label>
</div>
```

Disabled items (`disabled` attribute) are excluded from both aggregation and bulk toggling — the controller filters them out via `enabledItems()`. `indeterminate` is a JS-only property with no HTML attribute; it is set on connect and after every change, never rendered server-side.
```

- [ ] Remove the `ChecklistItemController` export from `index.js`.
- [ ] Remove the `checklist-item` registration line and README table row.
- [ ] Delete `docs/component/checklist-item.md`.
- [ ] Replace `docs/component/checklist.md` with the content above.
- [ ] Run `npm run format:docs:check` (or `format:docs` to fix) from the repo root.
- [ ] Commit.

---

### Task 3: Rails — `Checklist::Item#render` native input

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist/item.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist/item_test.rb`

**Interfaces:**
- `render(content = nil, checked:, readonly: false, **html_options, &block)` — signature unchanged.
- Produces for Task 4: the item's root element is now a `<label>` (was `<button>`); the checkbox is a sibling `<input type="checkbox">` inside it, styled via a new `checklist_item_input` theme key (added in Task 5). Task 4's master row must reuse this same shape (`<label>` + `<input type="checkbox">` styled via `checklist_item_input`) so both rows are visually identical, per the design spec.

**Final implementation:**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist
      class Item < Plumber::Base
        def render(content = nil, checked: nil, readonly: false, **html_options, &block)
          raise ArgumentError, "checked: is required" if checked.nil?

          slots = Checklist::Item::Slots.new(template)
          slots.with_title(content) if content
          yield slots if block_given?

          template.content_tag(:label, **merge_html_options(theme.resolve(:checklist_item), html_options)) do
            template.safe_join([render_input(checked, readonly), render_content_slot(slots)].compact)
          end
        end

        private

        def render_input(checked, readonly)
          template.tag.input(
            **merge_html_options(
              theme.resolve(:checklist_item_input),
              { type: "checkbox", checked: (checked ? true : nil), disabled: (readonly ? true : nil) }
            )
          )
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          template.content_tag(:span, **merge_html_options(theme.resolve(:checklist_item_content))) do
            template.safe_join([title, description])
          end
        end

        def render_title_slot(slots)
          slots.resolve(:title) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:checklist_item_title)))
          end
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:checklist_item_description)))
          end
        end
      end
    end
  end
end
```

This removes `state_attrs`, `checked_aria`, `checked_data`, `render_checkbox_glyph`, and `render_item_slots` entirely — no ARIA/data-controller bookkeeping, no glyph markup. `template.tag.input(...)` is this codebase's established pattern for a standalone native input not bound to a form object (see `stimulus-plumbers-rails/lib/stimulus_plumbers/components/combobox/trigger.rb:60`).

**Rewrite `item_test.rb`** — replace the button/role/aria-based assertions with:
- `test_renders_label_wrapping_a_checkbox_input` — `assert_css doc, "label input[type='checkbox']"`.
- `test_checked_true_sets_the_checked_attribute` — `assert_css doc, "input[type='checkbox'][checked]"`.
- `test_checked_false_omits_the_checked_attribute` — `assert_no_css doc, "input[checked]"`.
- `test_checked_is_a_required_keyword` — unchanged (`ArgumentError`, same message).
- `test_readonly_true_sets_disabled` — `assert_css doc, "input[type='checkbox'][disabled]"`.
- `test_readonly_false_omits_disabled` — `assert_no_css doc, "input[disabled]"` (readonly defaults to `false`).
- `test_renders_title_from_fast_path`, `test_block_title_overwrites_fast_path`, `test_renders_description` — unchanged assertions (still checking `doc.text`).
- `test_merges_custom_class` — `assert_css doc, "label.custom"` (class now merges onto the `<label>`, not the input).
- Delete `test_renders_button_with_checkbox_role`, `test_checked_true_sets_aria_checked_true`, `test_checked_false_sets_aria_checked_false`, `test_readonly_defaults_to_false_and_wires_the_controller`, `test_readonly_true_omits_the_controller_and_action`, `test_readonly_true_sets_aria_readonly_and_removes_from_tab_order`, `test_readonly_false_omits_aria_readonly_and_tabindex_override`, `test_renders_checkbox_box_and_check_glyph` — all assert removed button/ARIA/controller/glyph behavior.

- [ ] Rewrite `item.rb` to the implementation above.
- [ ] Rewrite `item_test.rb` per the list above.
- [ ] Run `bundle exec ruby -Itest test/stimulus_plumbers/components/checklist/item_test.rb` from `stimulus-plumbers-rails/` — all green.
- [ ] Run `bundle exec rubocop lib/stimulus_plumbers/components/checklist/item.rb test/stimulus_plumbers/components/checklist/item_test.rb` — clean.
- [ ] Commit.

---

### Task 4: Rails — `Checklist#render` master "select all" native input

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist_test.rb`

**Interfaces:**
- Consumes from Task 3: `theme.resolve(:checklist_item)` (row classes) and `theme.resolve(:checklist_item_input)` (input classes) — the master row reuses both, unchanged keys.
- `render(label: nil, labelledby: nil, select_all: false, select_all_label: "Select all", **kwargs, &block)` — signature unchanged. `item(content = nil, **kwargs, &block)` — signature and readonly-exclusion logic unchanged.

**Final implementation:**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist < Plumber::Base
      def render(label: nil, labelledby: nil, select_all: false, select_all_label: "Select all", **kwargs, &block)
        @item_states = [] if select_all
        captured = template.capture(self, &block)
        master = select_all ? render_select_all(select_all_label) : nil
        html_options = merge_html_options(
          theme.resolve(:checklist),
          kwargs,
          { role: "group", aria: labelled_aria(label, labelledby: labelledby) }
        )
        html_options = merge_html_options(html_options, select_all_wrapper_attrs) if select_all
        template.content_tag(:div, template.safe_join([master, captured].compact), **html_options)
      end

      def item(content = nil, **kwargs, &block)
        @item_states << kwargs[:checked] if @item_states && !kwargs[:readonly]
        Checklist::Item.new(template).render(content, **kwargs, &block)
      end

      private

      def render_select_all(select_all_label)
        template.content_tag(:label, **merge_html_options(theme.resolve(:checklist_item))) do
          template.safe_join([render_master_input, template.content_tag(:span, select_all_label)])
        end
      end

      def render_master_input
        template.tag.input(
          **merge_html_options(
            theme.resolve(:checklist_item_input),
            { type: "checkbox", checked: (all_items_checked? ? true : nil), data: { checklist_target: "master" } }
          )
        )
      end

      def select_all_wrapper_attrs
        { data: { controller: "checklist", action: "change->checklist#onChange" } }
      end

      def all_items_checked?
        @item_states.present? && @item_states.all? { |state| state == true }
      end
    end
  end
end
```

Notes:
- No `aria-label` on the master input — the wrapping `<label>` already gives it an accessible name from `select_all_label`'s visible text, same as an item's title. Adding `aria-label` too would be redundant.
- No `id:`/`sp_dom_id` on the wrapper — that only existed to scope the old Outlet selector (`##{id} [...]`). Stimulus targets resolve within the controller's own subtree automatically, so the id serves no purpose now. Dropping it is a real simplification, not an oversight — confirm this in review rather than adding it back defensively.
- `all_items_checked?` replaces `aggregate_checked_state`. It only decides the master's initial `checked` attribute (`true` for all-checked, otherwise omitted — including the mixed case, per the accepted server-can't-render-indeterminate tradeoff in Global Constraints). The `checklist` controller corrects to `indeterminate` on connect for the mixed case.

**Rewrite `checklist_test.rb`** select-all-related tests (non-select-all tests like `test_renders_div_with_group_role`, `test_label_sets_aria_label`, etc. are unaffected):
- `test_select_all_false_by_default_leaves_output_unchanged` — update to assert `assert_no_css doc, "input[data-checklist-target='master']"` and `assert_no_css doc, "div[data-controller='checklist']"` (drop the old `assert_no_css doc, "div[id]"` — id is no longer part of this component's output at all, so keep or drop per what else in the page might set an id; safest is to just remove that specific assertion since it's no longer this component's concern).
- `test_select_all_renders_master_input` (renamed from `_master_button`) — `assert_css doc, "label input[type='checkbox'][data-checklist-target='master']"`.
- `test_select_all_wraps_wrapper_with_checklist_controller` (renamed) — assert `div["data-controller"] == "checklist"` and `div["data-action"] == "change->checklist#onChange"`; drop the outlet-attribute assertion and the `div["id"]` presence assertion entirely.
- `test_select_all_label_customizes_input_accessible_text` (renamed) — render with `select_all_label: "Toggle all"`, assert `assert_includes doc.text, "Toggle all"` (drop the `aria-label` assertion — no longer set).
- `test_select_all_checked_when_all_items_checked` (renamed) — both items `checked: true` → `assert_css doc, "input[data-checklist-target='master'][checked]"`.
- `test_select_all_unchecked_when_all_items_unchecked` — both `checked: false` → `assert_no_css doc, "input[data-checklist-target='master'][checked]"`.
- `test_select_all_unchecked_when_items_are_mixed` (renamed from `_aria_checked_mixed`) — one checked, one not → `assert_no_css doc, "input[data-checklist-target='master'][checked]"` (mixed renders unchecked server-side per the accepted tradeoff — this test documents that tradeoff, don't let it silently regress into "should be checked").
- `test_select_all_unchecked_when_zero_items` — `render(select_all: true) { nil }` → `assert_no_css doc, "input[data-checklist-target='master'][checked]"`.
- `test_select_all_excludes_readonly_items_from_aggregate` — one unchecked interactive item + one `checked: true, readonly: true` item → master still unchecked (`assert_no_css doc, "input[data-checklist-target='master'][checked]"`), proving the readonly item's `checked: true` didn't count toward the aggregate.
- Delete `test_select_all_renders_checkbox_box_glyph`, `test_select_all_renders_both_check_and_minus_icons_regardless_of_state`, `test_select_all_renders_both_icons_when_all_checked` — all assert removed glyph markup.

- [ ] Rewrite `checklist.rb` to the implementation above.
- [ ] Rewrite `checklist_test.rb` per the list above.
- [ ] Run `bundle exec ruby -Itest test/stimulus_plumbers/components/checklist_test.rb` — all green.
- [ ] Run `bundle exec rubocop lib/stimulus_plumbers/components/checklist.rb test/stimulus_plumbers/components/checklist_test.rb` — clean.
- [ ] Commit.

---

### Task 5: Tailwind — theme rewrite

**Files:**
- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/checklist.rb`
- Test: `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/checklist_test.rb`

**Interfaces:**
- Consumes: `theme.resolve(:checklist_item)` and `theme.resolve(:checklist_item_input)` are the two keys Tasks 3 and 4 call.
- Produces: `checklist_item_input_classes` is new; `checklist_select_all_classes`, `checklist_item_box_classes`, `checklist_item_check_classes`, `checklist_select_all_minus_classes` are deleted.

**Final implementation:**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Checklist
        WRAPPER_BASE = %w[flex flex-col gap-(--sp-space-1)].freeze

        ITEM_BASE = [
          *Control::BASE,
          "group/checklist-item flex items-center gap-(--sp-space-2) w-full text-start",
          "px-(--sp-space-2) py-(--sp-space-1)",
          "rounded-(--sp-radius-sm) text-(length:--sp-text-sm)",
          "cursor-pointer select-none text-(--sp-color-fg)",
          "hover:bg-(--sp-color-muted)",
          "has-disabled:cursor-default has-disabled:hover:bg-transparent"
        ].freeze

        INPUT_BASE = %w[
          size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
          border border-(--sp-color-border) bg-(--sp-color-muted)
          focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none
          disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
        ].freeze

        CONTENT_BASE = %w[flex flex-col flex-1 min-w-0].freeze

        TITLE_BASE = %w[
          text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)
          group-has-checked/checklist-item:line-through
          group-has-checked/checklist-item:text-(--sp-color-muted-fg)
        ].freeze

        DESCRIPTION_BASE = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze

        private

        def checklist_classes
          { classes: klasses(*WRAPPER_BASE) }
        end

        def checklist_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def checklist_item_input_classes
          { classes: klasses(*INPUT_BASE) }
        end

        def checklist_item_content_classes
          { classes: klasses(*CONTENT_BASE) }
        end

        def checklist_item_title_classes
          { classes: klasses(*TITLE_BASE) }
        end

        def checklist_item_description_classes
          { classes: klasses(*DESCRIPTION_BASE) }
        end
      end
    end
  end
end
```

Notes:
- `ITEM_BASE`'s `focus-visible:ring-(--sp-color-primary-ring)` line is dropped — the `<label>` row is no longer itself a focusable/interactive element (a native `<input>` inside it is), so the focus ring moves to `INPUT_BASE` (`focus:ring-...`), matching the existing `CHECKBOX_TYPES` precedent's `:focus` (not `:focus-visible`) variant exactly.
- `ITEM_BASE`'s readonly/disabled row styling changes from `aria-readonly:cursor-default aria-readonly:hover:bg-transparent` to `has-disabled:cursor-default has-disabled:hover:bg-transparent` (Tailwind v4's `:has()` variant) — the disabled state now lives on the sibling `<input>`, not on the row element itself, so the row needs `:has(:disabled)` to react to it.
- `TITLE_BASE`'s two `group-aria-checked/checklist-item:` lines become `group-has-checked/checklist-item:` for the same sibling-not-descendant reason (input and title are both children of the `<label>`, not ancestor/descendant).
- `checklist_select_all_classes` is deleted — the master row now resolves `checklist_item_classes` directly (Task 4 calls `theme.resolve(:checklist_item)` for the master's `<label>`, matching an item's row exactly, per the design spec's decision to make master and item rows visually identical).
- `checklist_item_box_classes`, `checklist_item_check_classes`, `checklist_select_all_minus_classes` are deleted outright — no glyph markup exists to style.

**Rewrite `checklist_test.rb`** (Tailwind theme test) — replace glyph/aria-checked-variant assertions with `:has()`-based ones:
- `test_checklist_returns_a_classes_string` — unchanged.
- `test_checklist_item_input_is_a_real_checkbox_control` — `assert_includes classes_for(:checklist_item_input), "cursor-pointer"` (use-case assertion: it's an interactive control, not decorative).
- `test_checklist_item_input_dims_when_disabled` — `assert_includes classes_for(:checklist_item_input), "disabled:opacity-50"`.
- `test_checklist_item_title_strikes_through_when_checked` (renamed) — `assert_includes classes_for(:checklist_item_title), "group-has-checked"` and `assert_includes ..., "line-through"`.
- `test_checklist_item_content_uses_flex_col` — unchanged.
- `test_checklist_item_title_uses_muted_color_when_checked` — unchanged assertion (`--sp-color-muted-fg`), still true.
- `test_resolving_with_no_kwargs_does_not_raise` — unchanged.
- `test_checklist_item_row_dims_hover_when_disabled` (new, replaces the box/glyph tests) — `assert_includes classes_for(:checklist_item), "has-disabled"`.
- Delete `test_checklist_item_box_is_in_flow_not_absolute`, `test_checklist_item_check_starts_hidden_and_reveals_on_checked`, `test_checklist_select_all_returns_a_classes_string`, `test_checklist_select_all_is_focusable_and_keyboard_operable`, `test_checklist_item_box_shows_filled_state_when_mixed`, `test_checklist_select_all_minus_reveals_glyph_when_mixed`, `test_checklist_item_check_does_not_reveal_when_mixed`, `test_checklist_select_all_check_and_minus_glyphs_overlay_the_same_spot` — all assert removed glyph/box/select-all-specific keys.

- [ ] Rewrite `checklist.rb` (Tailwind theme) to the implementation above.
- [ ] Rewrite `checklist_test.rb` per the list above.
- [ ] Run `bundle exec ruby -Itest test/stimulus_plumbers/themes/tailwind/checklist_test.rb` from `stimulus-plumbers-tailwind/` — all green.
- [ ] Run `bundle exec rubocop lib/stimulus_plumbers/themes/tailwind/checklist.rb test/stimulus_plumbers/themes/tailwind/checklist_test.rb` — clean.
- [ ] Commit.

---

### Task 6: Rails a11y tests + sandbox — native input assertions, restore keyboard coverage

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/app/views/components/checklist.html.erb` (no structural change needed — same `sp_checklist`/`checklist.item` calls; verify it still renders correctly with Tasks 3–4's output)
- Modify: `stimulus-plumbers-rails/test/accessibility/components/checklist_accessibility_test.rb`

**Interfaces:**
- Consumes: the final rendered HTML from Tasks 3–4 (`<label><input type="checkbox">...</label>` for both items and the master).

**Rewrite `checklist_accessibility_test.rb`**:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ChecklistAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/checklist"
  end

  def test_default_checklist_passes_wcag
    assert_accessible context: "#checklist-default"
  end

  def test_checklist_with_description_passes_wcag
    assert_accessible context: "#checklist-with-description"
  end

  def test_read_only_checklist_passes_wcag
    assert_accessible context: "#checklist-read-only"
  end

  def test_checklist_passes_wcag_after_toggling_an_item
    within("#checklist-default") { check("Buy milk", allow_label_click: true) }

    assert_accessible context: "#checklist-default"
  end

  def test_select_all_checklist_passes_wcag_with_mixed_state
    within("#checklist-select-all") do
      assert_field("Select all", checked: false)
    end

    assert_accessible context: "#checklist-select-all"
  end

  def test_select_all_checklist_passes_wcag_after_click
    within("#checklist-select-all") { check("Select all", allow_label_click: true) }

    assert_accessible context: "#checklist-select-all"
  end

  def test_clicking_master_with_mixed_state_checks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: true)
      assert_field("Walk the dog", checked: true)
    end
  end

  def test_clicking_master_with_all_checked_unchecks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)
      uncheck("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: false)
      assert_field("Walk the dog", checked: false)
    end
  end

  def test_clicking_master_twice_unchecks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)
      uncheck("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: false)
      assert_field("Walk the dog", checked: false)
    end
  end

  def test_readonly_item_unaffected_by_select_all
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)

      assert_field("Archived (read-only)", checked: false, disabled: true)
    end
  end

  def test_master_toggles_via_space_key
    within("#checklist-select-all") do
      find_field("Select all").send_keys(:space)

      assert_field("Buy milk", checked: true)
      assert_field("Walk the dog", checked: true)
    end
  end
end
```

Notes on the rewrite:
- Capybara's `check`/`uncheck`/`assert_field`/`find_field` operate on real form controls by accessible label text — no CSS attribute selectors needed, and no click-to-focus ambiguity since these are Capybara's native checkbox helpers, not raw `send_keys` on a non-form element.
- `test_master_toggles_via_space_key` is restored (was deleted in the previous button-based implementation because Cuprite's `send_keys` always clicks-to-focus first on a non-native-semantic element, causing a double-toggle). A real `<input type="checkbox">` is natively focusable; confirm this test is stable by running it twice in a row before committing — if `send_keys(:space)` still exhibits the click-to-focus double-toggle on an `<input>` in this Cuprite version, use `find_field("Select all").click` to focus first (`.focus` behavior differs from `.click` for a real input, so a preceding explicit click is legitimate here, not the same hack as before) then `send_keys(:space)`, and note why in a comment. Do not delete this test without first genuinely attempting it — restoring keyboard coverage is a stated goal of this migration, not optional.
- No Enter-key test — Enter does not activate a native `<input type="checkbox">` (only Space does, per the HTML/APG spec); the old Enter test was only valid because the previous design used a `<button>`, which activates on both. Do not restore it — restoring it would test a behavior native checkboxes correctly do NOT have.

- [ ] Rewrite `checklist_accessibility_test.rb` per the code above.
- [ ] Run `bundle exec ruby -Itest test/accessibility/components/checklist_accessibility_test.rb` from `stimulus-plumbers-rails/` — all green, run twice to confirm the keyboard test isn't flaky.
- [ ] Run `bundle exec rake test:accessibility` (full suite) — confirm no other test depended on the old button/ARIA markup.
- [ ] Commit.

---

### Task 7: Tailwind Playwright sandbox + snapshots

**Files:**
- Modify: `stimulus-plumbers-tailwind/test/snapshots/checklist.spec.js`
- Verify (no expected changes needed, confirm visually): `stimulus-plumbers-tailwind/test/sandbox/app/views/components/checklist.html.erb`

**Interfaces:**
- Consumes: the same rendered HTML as Task 6, via the Tailwind theme from Task 5.

**Rewrite `checklist.spec.js`** — the only functional change needed is the `[role='checkbox']` CSS attribute selector, which no longer matches (native inputs have an *implicit* role, not an explicit `role` attribute):

```js
import { test, expect } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.goto("/components/display/checklist");
  await page.waitForSelector("[role='group']");
});

test.describe("checklist", () => {
  test("default", async ({ page }) => {
    await expect(page.locator("#checklist-default")).toHaveScreenshot("default.png");
  });

  test("with description", async ({ page }) => {
    await expect(page.locator("#checklist-with-description")).toHaveScreenshot(
      "with-description.png",
    );
  });

  test("read-only", async ({ page }) => {
    await expect(page.locator("#checklist-read-only")).toHaveScreenshot("read-only.png");
  });

  test("toggled via click", async ({ page }) => {
    const item = page.locator("#checklist-default input[type='checkbox']").first();
    await item.click();
    await expect(page.locator("#checklist-default")).toHaveScreenshot("default-toggled.png");
  });

  test("select all - mixed", async ({ page }) => {
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot("select-all-mixed.png");
  });

  test("select all - all checked", async ({ page }) => {
    const item = page
      .locator("#checklist-select-all")
      .getByRole("checkbox", { name: "Walk the dog" });
    await item.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-all-checked.png",
    );
  });

  test("select all - all unchecked", async ({ page }) => {
    const item = page.locator("#checklist-select-all").getByRole("checkbox", { name: "Buy milk" });
    await item.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-all-unchecked.png",
    );
  });

  test("select all - click to check all", async ({ page }) => {
    const master = page.locator("#checklist-select-all [data-checklist-target='master']");
    await master.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-check-all.png",
    );
  });

  test("select all - click to uncheck all", async ({ page }) => {
    const master = page.locator("#checklist-select-all [data-checklist-target='master']");
    await master.click();
    await master.click();
    await expect(page.locator("#checklist-select-all")).toHaveScreenshot(
      "select-all-uncheck-all.png",
    );
  });
});
```

`getByRole("checkbox", { name })` calls are unaffected — Playwright resolves the accessible role/name from the native `<input type="checkbox">` + wrapping `<label>` text exactly as it did from the old `role="checkbox"` button + `aria-label`, so those lines don't change.

- [ ] Rewrite `checklist.spec.js` per the code above (only the one `[role='checkbox']` → `input[type='checkbox']` selector actually changes).
- [ ] Start the sandbox server (`RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:4001` from `stimulus-plumbers-tailwind/`) and visually check `/components/display/checklist` in a browser — confirm items/master render as real checkboxes with correct checked/disabled/strikethrough states before handing off for snapshot regeneration.
- [ ] Do NOT run `node --run test:snapshots:update` — flag in your report that new baselines are needed; the user runs this.
- [ ] Commit (spec file only; no snapshot images to commit yet).

---

### Task 8: Docs — ARIA.md + Rails component doc

**Files:**
- Modify: `ARIA.md`
- Modify: `stimulus-plumbers-rails/docs/component/checklist.md`

**Interfaces:**
- Consumes: the final behavior from all prior tasks — this task only documents, no code changes.

**Rewrite `ARIA.md`'s Checklist section** (replace the existing `#### Checklist (`checklist-item_controller`, `sp_checklist`)` block with):

```markdown
#### Checklist (`checklist_controller`, `sp_checklist`)
- Each item: native `<input type="checkbox">` inside a `<label>` — role, keyboard activation (Space), focus, and checked-state announcement are all handled by the browser. The component sets no ARIA attributes on items.
- Read-only item (`readonly: true`): native `disabled` attribute — removes the control from the tab order and announces it as unavailable to assistive tech. No `aria-readonly`/`tabindex` hack.
- Master "select all" toggle (`select_all:`): same `<input type="checkbox">` shape as an item. Its `indeterminate` property (JS-only, no HTML attribute) is set client-side by the `checklist` controller when some but not all enabled items are checked — modern browsers map `indeterminate` to the accessibility tree's `mixed` checked state automatically, satisfying WCAG 4.1.2 with no manual ARIA.
- Accepted tradeoff: because `indeterminate` has no HTML attribute, the server can only render the master's initial `checked` state for the all-true case; every other case (including mixed) renders unchecked and is corrected to `indeterminate` once the `checklist` controller connects — a brief, accepted flash for the mixed case only.
- Disabled (readonly) items are excluded from the master's aggregate and from bulk toggling — the `checklist` controller filters them out via their own `.disabled` property, mirroring their exclusion from tab order and AT interaction.
```

**Rewrite `stimulus-plumbers-rails/docs/component/checklist.md`** — update the intro line (no longer "items render as `<button role="checkbox">`"), the `checklist.item` Rendered HTML sections, and the Theme keys table:

- Intro: `Rails helper for rendering an accessible group of checkbox-style items. Items render as native <label><input type="checkbox"></label> pairs, no <li> wrapper — see [ARIA.md's Checklist pattern](../../../ARIA.md) for why.`
- `checklist.item(...)` description row: `Renders a <label> wrapping a native <input type="checkbox">.`
- `readonly:` option row: `true renders **disabled** on the input — removed from the tab order, no controller`.
- Rendered HTML Structure section: replace the `<button role="checkbox">` example with:
  ```html
  <div role="group" aria-label="Groceries" class="[checklist theme classes]">
    <label class="[checklist_item theme classes]">
      <input type="checkbox" checked class="[checklist_item_input theme classes]">
      <span class="[checklist_item_content theme classes]">
        <span class="[checklist_item_title theme classes]">Buy milk</span>
      </span>
    </label>
  </div>
  ```
- `select_all: true` example: replace with the master `<label><input type="checkbox" data-checklist-target="master">Select all</label>` shape (no glyph spans, no outlet attribute — `data-controller="checklist" data-action="change->checklist#onChange"` on the wrapper, no `id`).
- Read-only item example: `<label class="[checklist_item theme classes]"><input type="checkbox" checked disabled class="[checklist_item_input theme classes]">...</label>`.
- Theme keys table: remove `checklist_select_all`, `checklist_select_all_minus`, `checklist_item_box`, `checklist_item_check` rows; add `checklist_item_input` (`Item/master checkbox <input>` — `—`).
- Final paragraph ("Checked-state styling..."): replace with `Checked-state styling (strikethrough title) reads the sibling <input>'s :checked state via Tailwind's :has()-based group-has-checked/checklist-item: variant — there is no aria-checked or checked: theme-resolver kwarg to pass.`

- [ ] Rewrite the ARIA.md Checklist section per the content above.
- [ ] Rewrite `stimulus-plumbers-rails/docs/component/checklist.md` per the changes above.
- [ ] Run `npm run format:docs:check` from the repo root (fix with `format:docs` if it fails).
- [ ] Commit.
