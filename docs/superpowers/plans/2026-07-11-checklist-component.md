# Checklist Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a standalone `Checklist`/`checklist-item` component (JS controller + Rails renderer + Tailwind theme + a11y/snapshot tests) that replaces the `checked:`/`interactive:` bolt-on currently living on `List::Item`.

**Architecture:** A `role="group"` wrapper (`sp_checklist`) contains `role="checkbox"` items rendered as `<button type="button" role="checkbox" aria-checked>` (native `<button>` gives free keyboard activation/focus; `role="checkbox"` overrides the announced role). No `<ul>`/`<li>` — `role="checkbox"` is not a valid owned element of `role="list"`, so list markup would trip axe's `aria-required-children` rule. State is carried entirely by the real `aria-checked` attribute — no parallel `data-checked` attribute, no `checkbox`/`content` Stimulus targets. Tailwind's built-in `aria-checked:` / `group-aria-checked/name:` variants read that attribute directly, so the same styling rule drives both the server-rendered initial paint and the post-toggle paint.

**Tech Stack:** Stimulus (`@hotwired/stimulus`), Rails view components (`Plumber::Base`/`Plumber::Slots`), Tailwind v4 theme module, Minitest + Capybara/axe-core (a11y), Playwright (visual snapshots), Vitest (JS unit tests).

## Global Constraints

- `checked:` is a **required** keyword arg on `Checklist::Item#render` (unlike `List::Item`, where `nil` meant "not a checklist item" — a `Checklist::Item` is *always* a checkbox, so there's no nil case to branch on).
- `interactive:` defaults to `true` (the old `List::Item` default was `false`, which made the common case verbose).
- No theme-schema `checked:` variant kwargs anywhere in this feature — styling reads the live `aria-checked` attribute via Tailwind variants, not a Ruby-side boolean branch. (This sidesteps the exact bug class found in the existing `list_item_title`/`list_item_description` `checked:` variants, which are declared in `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb:28-29` but never implemented with a matching arity in `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/list.rb`, causing `ArgumentError: wrong number of arguments (given 1, expected 0)` at render time today.)
- Out of scope: fixing or removing the existing broken `checked:`/`interactive:` support on `List::Item`/`list-item` controller. That bug is pre-existing and unrelated to this new component; leave it as a follow-up. Do not touch `stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb`, `stimulus-plumbers/src/controllers/list_item_controller.js`, or their tests/docs in this plan.
- Follow the "no cross-doc duplication" rule from the root `CLAUDE.md`: JS controller API lives only in `stimulus-plumbers/docs/component/checklist-item.md`; Rails helper options live only in `stimulus-plumbers-rails/docs/component/checklist.md`; ARIA/WCAG rules live only in `ARIA.md`.

---

### Task 1: JS — `checklist-item` Stimulus controller

**Files:**
- Create: `stimulus-plumbers/src/controllers/checklist_item_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/checklist_item_controller.test.js`

**Interfaces:**
- Produces: default-exported Stimulus controller class with `checkedValue: Boolean` (default `false`), action method `toggle()`, value-changed callback `checkedValueChanged(checked)`. Dispatches `checklist-item:toggled` with `detail: { checked }`.
- Consumes: `setChecked` from `stimulus-plumbers/src/accessibility/aria.js` (already exported, already tested — do not modify that file).

- [ ] **Step 1: Write the failing test**

```js
// stimulus-plumbers/tests/unit/controllers/checklist_item_controller.test.js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { Application } from '@hotwired/stimulus';
import ChecklistItemController from '../../../src/controllers/checklist_item_controller';

describe('ChecklistItemController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('checklist-item', ChecklistItemController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="checklist-item"]'),
      'checklist-item'
    );

  describe('toggle()', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <button type="button" role="checkbox" data-controller="checklist-item"
                data-action="click->checklist-item#toggle"
                data-checklist-item-checked-value="false" aria-checked="false">
          Buy milk
        </button>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('flips checkedValue from false to true', () => {
      getController().toggle();
      expect(getController().checkedValue).toBe(true);
    });

    it('flips checkedValue back to false on a second toggle', () => {
      getController().toggle();
      getController().toggle();
      expect(getController().checkedValue).toBe(false);
    });

    it('dispatches checklist-item:toggled with the new checked state', () => {
      const el = document.querySelector('[data-controller="checklist-item"]');
      const spy = vi.fn();
      el.addEventListener('checklist-item:toggled', spy);
      getController().toggle();
      expect(spy).toHaveBeenCalledTimes(1);
      expect(spy.mock.calls[0][0].detail).toEqual({ checked: true });
    });

    it('updates aria-checked when toggled', () => {
      getController().toggle();
      expect(document.querySelector('[data-controller="checklist-item"]').getAttribute('aria-checked')).toBe('true');
    });
  });

  describe('checkedValueChanged (programmatic / external set)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <button type="button" role="checkbox" data-controller="checklist-item"
                data-checklist-item-checked-value="false" aria-checked="false">
          Buy milk
        </button>
      `;
      await new Promise((resolve) => setTimeout(resolve, 10));
    });

    it('sets aria-checked to match the value on connect', () => {
      expect(document.querySelector('[data-controller="checklist-item"]').getAttribute('aria-checked')).toBe('false');
    });

    it('updates aria-checked when the attribute is set directly, without calling toggle()', async () => {
      const el = document.querySelector('[data-controller="checklist-item"]');
      el.setAttribute('data-checklist-item-checked-value', 'true');
      await new Promise((resolve) => setTimeout(resolve, 10));

      expect(el.getAttribute('aria-checked')).toBe('true');
    });
  });
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/checklist_item_controller.test.js`
Expected: FAIL — `Failed to resolve import "../../../src/controllers/checklist_item_controller"`

- [ ] **Step 3: Write minimal implementation**

```js
// stimulus-plumbers/src/controllers/checklist_item_controller.js
import { Controller } from '@hotwired/stimulus';
import { setChecked } from '../accessibility/aria';

export default class extends Controller {
  static values = {
    checked: { type: Boolean, default: false },
  };

  toggle() {
    this.checkedValue = !this.checkedValue;
    this.dispatch('toggled', { detail: { checked: this.checkedValue } });
  }

  checkedValueChanged(checked) {
    setChecked(this.element, checked);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd stimulus-plumbers && npx vitest run tests/unit/controllers/checklist_item_controller.test.js`
Expected: PASS (7 tests)

- [ ] **Step 5: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers/src/controllers/checklist_item_controller.js stimulus-plumbers/tests/unit/controllers/checklist_item_controller.test.js
git commit -m "feat(js): add checklist-item controller"
```

---

### Task 2: JS — export, README, controller doc

**Files:**
- Modify: `stimulus-plumbers/src/index.js`
- Modify: `stimulus-plumbers/README.md`
- Create: `stimulus-plumbers/docs/component/checklist-item.md`

**Interfaces:**
- Consumes: `ChecklistItemController` from Task 1 (`stimulus-plumbers/src/controllers/checklist_item_controller.js`).

- [ ] **Step 1: Add the export**

In `stimulus-plumbers/src/index.js`, insert alphabetically between `CalendarYearSelectorController` and `ClipboardController`:

```js
export { default as ChecklistItemController } from './controllers/checklist_item_controller.js';
```

- [ ] **Step 2: Add the README Controllers table row**

In `stimulus-plumbers/README.md`, insert a row before the existing `list-item` row (find the line starting `| \`list-item\` |`):

```markdown
| `checklist-item` | Checklist item toggle (`aria-checked`, group semantics) | [docs/component/checklist-item.md](docs/component/checklist-item.md) |
```

Also add the controller to the registration example near the top of the README (find the line `application.register('list-item', ListItemController);` around line 68) — add directly above it:

```js
application.register('checklist-item', ChecklistItemController);
```

- [ ] **Step 3: Write the controller doc**

```markdown
<!-- stimulus-plumbers/docs/component/checklist-item.md -->
# Checklist Item

Interactive checkbox-style toggle for a checklist item. Wired automatically by the Rails `sp_checklist` helper's `checklist.item` when `interactive:` is left at its default (`true`) — see [stimulus-plumbers-rails's docs/component/checklist.md](../../../stimulus-plumbers-rails/docs/component/checklist.md) for the render options. Read-only items (`interactive: false`) render `aria-checked`/`aria-readonly` directly from the server and never get this controller.

## Stimulus Identifier

`checklist-item`

## Values

| Name      | Type    | Default | Purpose                 |
| --------- | ------- | ------- | ------------------------ |
| `checked` | Boolean | `false` | Current checklist state |

## Actions

| Name     | Purpose                                                     |
| -------- | ------------------------------------------------------------ |
| `toggle` | Flips `checkedValue`, syncs `aria-checked`, dispatches `checklist-item:toggled` |

## Dispatches

| Event                   | Detail        | When                             |
| ------------------------ | ------------- | --------------------------------- |
| `checklist-item:toggled` | `{ checked }` | After `toggle()` flips the value |

## Example HTML

```html
<button type="button" role="checkbox" aria-checked="false"
        data-controller="checklist-item" data-action="click->checklist-item#toggle"
        data-checklist-item-checked-value="false">
  Buy milk
</button>
```

State is read from `aria-checked` alone — there is no separate `data-checked` attribute or child target. Styling hooks off `aria-checked` directly (see the Tailwind theme's `checklist_item_*` classes).
```

- [ ] **Step 4: Verify docs formatting**

Run: `cd stimulus-plumbers && npm run format:docs:check` (root-level command per `stimulus-plumbers/../CLAUDE.md`; run from repo root: `npm run format:docs:check`)
Expected: PASS, or run `npm run format:docs` to auto-fix if it flags formatting.

- [ ] **Step 5: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers/src/index.js stimulus-plumbers/README.md stimulus-plumbers/docs/component/checklist-item.md
git commit -m "docs(js): export checklist-item controller and document it"
```

---

### Task 3: Rails — theme schema `CHECKLIST` block

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/themes/base_test.rb` (add assertions to the existing schema test if present; otherwise skip — this task has no new test file, verified via Task 5/6's component tests and Task 9's theme tests)

**Interfaces:**
- Produces: theme keys `checklist`, `checklist_item`, `checklist_item_box`, `checklist_item_check`, `checklist_item_content`, `checklist_item_title`, `checklist_item_description` — all with an **empty** schema (no variant kwargs), resolvable via `theme.resolve(:checklist_item)` etc.

- [ ] **Step 1: Add the schema block**

In `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`, insert after the existing `LIST` block (after its closing `}.freeze` around line 30):

```ruby
      CHECKLIST = {
        checklist:                   {}.freeze,
        checklist_item:              {}.freeze,
        checklist_item_box:          {}.freeze,
        checklist_item_check:        {}.freeze,
        checklist_item_content:      {}.freeze,
        checklist_item_title:        {}.freeze,
        checklist_item_description:  {}.freeze
      }.freeze
```

- [ ] **Step 2: Wire it into the aggregate `SCHEMA`**

In `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`, add `**Schema::CHECKLIST` to the `SCHEMA` hash, right after `**Schema::LIST`:

```ruby
      SCHEMA = {
        **Schema::LIST,
        **Schema::CHECKLIST,
        **Schema::ORDERED_LIST,
        # ... (rest unchanged)
```

- [ ] **Step 3: Verify with a quick REPL check**

Run:
```bash
cd stimulus-plumbers-rails && bundle exec ruby -Itest -e '
require "test_helper"
p StimulusPlumbers::Themes::Base::SCHEMA.key?(:checklist_item)
'
```
Expected output: `true`

- [ ] **Step 4: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb
git commit -m "feat(rails): add checklist theme schema keys"
```

---

### Task 4: Rails — `Checklist::Item::Slots`

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist/item/slots.rb`

**Interfaces:**
- Produces: `StimulusPlumbers::Components::Checklist::Item::Slots < Plumber::Slots` with slots `title`, `description` (each gets `with_title`/`title`/`title?` etc. per `Plumber::Slots.slot` macro — see `stimulus-plumbers-rails/lib/stimulus_plumbers/plumber/slots.rb`).

- [ ] **Step 1: Write the file (no test — this is a declarative DSL class, exercised by Task 5's component tests)**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist
      class Item
        class Slots < Plumber::Slots
          slot :title, :description
        end
      end
    end
  end
end
```

- [ ] **Step 2: Verify it loads**

Run:
```bash
cd stimulus-plumbers-rails && bundle exec ruby -Itest -e '
require "test_helper"
s = StimulusPlumbers::Components::Checklist::Item::Slots.new
s.with_title("Buy milk")
puts s.title
'
```
Expected output: `Buy milk`

- [ ] **Step 3: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist/item/slots.rb
git commit -m "feat(rails): add Checklist::Item::Slots"
```

---

### Task 5: Rails — `Checklist::Item` component

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist/item.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist/item_test.rb`

**Interfaces:**
- Consumes: `Checklist::Item::Slots` (Task 4), `StimulusPlumbers::Components::Icon#render` (existing, `name:`/`size:`/`classes:`/`aria:` kwargs), `theme.resolve` for keys from Task 3.
- Produces: `StimulusPlumbers::Components::Checklist::Item < Plumber::Base` with `#render(content = nil, checked:, interactive: true, **html_options, &block)` returning a `<button type="button" role="checkbox" aria-checked="...">` HTML string.

- [ ] **Step 1: Write the failing tests**

```ruby
# frozen_string_literal: true

require "test_helper"

class ChecklistItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Checklist::Item.new(self)
  end

  def test_renders_button_with_checkbox_role
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "button[type='button'][role='checkbox']"
  end

  def test_checked_true_sets_aria_checked_true
    assert_css parse_html(renderer.render("Buy milk", checked: true)), "[aria-checked='true']"
  end

  def test_checked_false_sets_aria_checked_false
    assert_css parse_html(renderer.render("Buy milk", checked: false)), "[aria-checked='false']"
  end

  def test_checked_is_a_required_keyword
    assert_raises(ArgumentError) { renderer.render("Buy milk") }
  end

  def test_interactive_defaults_to_true_and_wires_the_controller
    doc = parse_html(renderer.render("Buy milk", checked: false))

    assert_css doc, "[data-controller='checklist-item']"
    assert_css doc, "[data-action='click->checklist-item#toggle']"
    assert_css doc, "[data-checklist-item-checked-value='false']"
  end

  def test_interactive_false_omits_the_controller_and_action
    doc = parse_html(renderer.render("Buy milk", checked: false, interactive: false))

    assert_no_css doc, "[data-controller]"
    assert_no_css doc, "[data-action]"
  end

  def test_interactive_false_sets_aria_readonly_and_removes_from_tab_order
    doc = parse_html(renderer.render("Buy milk", checked: true, interactive: false))

    assert_css doc, "[aria-readonly='true']"
    assert_css doc, "[tabindex='-1']"
  end

  def test_interactive_true_omits_aria_readonly_and_tabindex_override
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_no_css doc, "[aria-readonly]"
    assert_no_css doc, "[tabindex='-1']"
  end

  def test_renders_title_from_fast_path
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_includes doc.text, "Buy milk"
  end

  def test_block_title_overwrites_fast_path
    doc = parse_html(renderer.render("First", checked: true) { |item| item.with_title("Second") })

    assert_includes doc.text, "Second"
    refute_includes doc.text, "First"
  end

  def test_renders_description
    doc = parse_html(renderer.render("Buy milk", checked: true) { |item| item.with_description("2%, whole") })

    assert_includes doc.text, "2%, whole"
  end

  def test_renders_checkbox_box_and_check_glyph
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render("Buy milk", checked: true, class: "custom")), ".custom"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/checklist/item_test.rb`
Expected: FAIL — `uninitialized constant StimulusPlumbers::Components::Checklist`

- [ ] **Step 3: Write minimal implementation**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist
      class Item < Plumber::Base
        def render(content = nil, checked:, interactive: true, **html_options, &block)
          slots = Checklist::Item::Slots.new(template)
          slots.with_title(content) if content
          yield slots if block_given?

          @checked     = checked
          @interactive = interactive

          template.content_tag(
            :button,
            type: "button",
            role: "checkbox",
            **merge_html_options(theme.resolve(:checklist_item), html_options, state_attrs)
          ) { render_item_slots(slots) }
        end

        private

        def state_attrs
          {
            aria:     checked_aria,
            data:     checked_data,
            tabindex: (@interactive ? nil : "-1")
          }
        end

        def checked_aria
          aria = { checked: @checked.to_s }
          aria[:readonly] = "true" unless @interactive
          aria
        end

        def checked_data
          return {} unless @interactive

          {
            controller:                        "checklist-item",
            "checklist-item-checked-value":    @checked,
            action:                             "click->checklist-item#toggle"
          }
        end

        def render_item_slots(slots)
          template.safe_join([render_checkbox_glyph, render_content_slot(slots)])
        end

        def render_checkbox_glyph
          template.content_tag(
            :span,
            **merge_html_options(theme.resolve(:checklist_item_box), { aria: { hidden: "true" } })
          ) do
            Components::Icon.new(template).render(
              name:    "check",
              size:    :sm,
              classes: theme.resolve(:checklist_item_check).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
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

- [ ] **Step 4: Require the new files**

Rails autoloads `lib/stimulus_plumbers/**/*.rb` via `config.autoload_paths` in `stimulus-plumbers-rails/lib/stimulus_plumbers/engine.rb:9` — no manual `require` needed as long as the file path matches the constant path exactly: `components/checklist/item.rb` → `StimulusPlumbers::Components::Checklist::Item`. Confirm `checklist.rb` (the wrapper, Task 6) will also exist at `components/checklist.rb` for `StimulusPlumbers::Components::Checklist` to resolve — until Task 6 lands, reference `Checklist::Item` directly from the test (as written above) rather than through the wrapper.

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/checklist/item_test.rb`
Expected: PASS (13 tests) — note `Checklist` (the outer class, empty except for nesting `Item`) must exist as a bare `class Checklist; end` for `Checklist::Item` to resolve without NameError. Add a minimal stub now if Task 6 hasn't run yet:

```ruby
# stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb (stub — filled in by Task 6)
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist < Plumber::Base
    end
  end
end
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist/item.rb stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist/item_test.rb
git commit -m "feat(rails): add Checklist::Item component"
```

---

### Task 6: Rails — `Checklist` wrapper component

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb` (fill in the stub from Task 5)
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist_test.rb`

**Interfaces:**
- Consumes: `Checklist::Item#render` (Task 5), `labelled_aria` (from `Plumber::Options::Aria`, included via `Plumber::Base`).
- Produces: `#render(label: nil, labelledby: nil, **kwargs, &block)` returning `<div role="group">`; `#item(content = nil, **kwargs, &block)` delegating to `Checklist::Item.new(template).render`.

- [ ] **Step 1: Write the failing tests**

```ruby
# frozen_string_literal: true

require "test_helper"

class ChecklistTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Checklist.new(self)
  end

  def test_renders_div_with_group_role
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[role='group']"
  end

  def test_renders_items_via_block
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_includes doc.text, "Buy milk"
  end

  def test_label_sets_aria_label
    doc = parse_html(renderer.render(label: "Groceries") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[aria-label='Groceries']"
  end

  def test_labelledby_sets_aria_labelledby_and_omits_label
    doc = parse_html(renderer.render(labelledby: "heading-id") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[aria-labelledby='heading-id']"
    assert_no_css doc, "div[aria-label]"
  end

  def test_omits_aria_label_and_labelledby_when_neither_given
    doc = parse_html(renderer.render { |c| c.item("Buy milk", checked: true) })

    assert_no_css doc, "div[aria-label]"
    assert_no_css doc, "div[aria-labelledby]"
  end

  def test_merges_custom_class
    doc = parse_html(renderer.render(class: "custom") { |c| c.item("Buy milk", checked: true) })

    assert_css doc, ".custom"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/checklist_test.rb`
Expected: FAIL — `NoMethodError: undefined method 'render' for #<StimulusPlumbers::Components::Checklist>` (stub from Task 5 has no `#render`/`#item`)

- [ ] **Step 3: Write minimal implementation**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Checklist < Plumber::Base
      def render(label: nil, labelledby: nil, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:checklist),
          kwargs,
          { role: "group", aria: labelled_aria(label, labelledby: labelledby) }
        )
        template.content_tag(:div, template.capture(self, &block), **html_options)
      end

      def item(content = nil, **kwargs, &block)
        Checklist::Item.new(template).render(content, **kwargs, &block)
      end
    end
  end
end
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/checklist_test.rb`
Expected: PASS (6 tests)

- [ ] **Step 5: Run the full unit suite to check for regressions**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit`
Expected: PASS, no failures in unrelated files

- [ ] **Step 6: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/checklist.rb stimulus-plumbers-rails/test/stimulus_plumbers/components/checklist_test.rb
git commit -m "feat(rails): add Checklist wrapper component"
```

---

### Task 7: Rails — `sp_checklist` helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/checklist_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`

**Interfaces:**
- Consumes: `Components::Checklist#render` (Task 6).
- Produces: `sp_checklist(...)` view helper, available on any `ActionView::Base` once `StimulusPlumbers::Helpers` is included (done automatically via the engine initializer).

- [ ] **Step 1: Write the helper**

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ChecklistHelper
      def sp_checklist(...)
        Components::Checklist.new(self).render(...)
      end
    end
  end
end
```

- [ ] **Step 2: Register it**

In `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`, add the require near `require_relative "helpers/list_helper"`:

```ruby
require_relative "helpers/checklist_helper"
```

And add the include inside `module Helpers`, near `include ListHelper`:

```ruby
    include ChecklistHelper
```

- [ ] **Step 3: Verify via a helper-level test**

```ruby
# stimulus-plumbers-rails/test/stimulus_plumbers/helpers/checklist_helper_test.rb
# frozen_string_literal: true

require "test_helper"

class ChecklistHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ChecklistHelper

  def test_sp_checklist_renders_a_group
    doc = parse_html(sp_checklist { |c| c.item("Buy milk", checked: true) })

    assert_css doc, "div[role='group']"
  end
end
```

Run: `cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/helpers/checklist_helper_test.rb`
Expected: PASS (1 test)

- [ ] **Step 4: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/checklist_helper.rb stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb stimulus-plumbers-rails/test/stimulus_plumbers/helpers/checklist_helper_test.rb
git commit -m "feat(rails): add sp_checklist helper"
```

---

### Task 8: Rails — README, component doc, ARIA.md pattern

**Files:**
- Modify: `stimulus-plumbers-rails/README.md`
- Create: `stimulus-plumbers-rails/docs/component/checklist.md`
- Modify: `ARIA.md`

**Interfaces:**
- Documents the public API from Tasks 5–7. No code changes.

- [ ] **Step 1: Add the README Components table row**

In `stimulus-plumbers-rails/README.md`, insert between the `Card` row and the `Combobox — date` row:

```markdown
| Checklist | `sp_checklist` | [docs/component/checklist.md](docs/component/checklist.md) |
```

- [ ] **Step 2: Write the component doc**

```markdown
<!-- stimulus-plumbers-rails/docs/component/checklist.md -->
# Checklist

Rails helper for rendering an accessible group of checkbox-style items. Unlike [`List`](list.md), items use `role="checkbox"` (not `role="listitem"`), so a `Checklist` is not a `role="list"` — mixing checkbox semantics into a list would violate the ARIA `list`/`listitem` owned-elements contract.

## Helper

### `sp_checklist`

```erb
<%= sp_checklist(label: "Groceries") do |checklist| %>
  <%= checklist.item("Buy milk", checked: true) %>
  <%= checklist.item("Walk the dog", checked: false) %>
<% end %>

<%# With a description %>
<%= sp_checklist(label: "Onboarding") do |checklist| %>
  <%= checklist.item("Verify email", checked: true) do |item| %>
    <% item.with_description("Sent to you at signup") %>
  <% end %>
<% end %>

<%# Read-only summary (e.g. an activity feed) %>
<%= sp_checklist(label: "Completed steps") do |checklist| %>
  <%= checklist.item("Account created", checked: true, interactive: false) %>
<% end %>
```

| Option         | Default | Description                                                          |
| -------------- | ------- | ---------------------------------------------------------------------- |
| `label:`       | `nil`   | Sets `aria-label` on the group wrapper                                |
| `labelledby:`  | `nil`   | Sets `aria-labelledby`; takes precedence over `label:` when both given |
| `**html_options` | —    | Forwarded to the `<div role="group">`                                 |

### `checklist.item(content, checked:, interactive:, **html_options, &block)`

Renders a `<button type="button" role="checkbox">`.

| Option         | Default   | Description                                                                                       |
| -------------- | --------- | --------------------------------------------------------------------------------------------------- |
| `content`      | `nil`     | Item label — positional arg or via `item.with_title`                                               |
| `checked:`     | —         | **Required.** Sets `aria-checked`                                                                  |
| `interactive:` | `true`    | `true` wires the `checklist-item` controller's click-to-toggle behavior. `false` renders a read-only item: `aria-readonly="true"` + `tabindex="-1"`, no controller |
| `**html_options` | —      | Forwarded to the `<button>`                                                                        |

See [stimulus-plumbers's docs/component/checklist-item.md](../../../stimulus-plumbers/docs/component/checklist-item.md) for the controller's Values/Actions/Dispatches.

### Item slot methods (yielded as `item`)

| Slot method                   | Description                                                   |
| ------------------------------ | --------------------------------------------------------------- |
| `item.with_title(text)`        | Title text (pre-populated when positional `content` is given) |
| `item.with_description(text)`  | Secondary text below the title                                |

---

## Rendered HTML Structure

```html
<div role="group" aria-label="Groceries" class="[checklist theme classes]">
  <button type="button" role="checkbox" aria-checked="true"
          data-controller="checklist-item" data-action="click->checklist-item#toggle"
          data-checklist-item-checked-value="true"
          class="[checklist_item theme classes]">
    <span aria-hidden="true" class="[checklist_item_box theme classes]">
      <svg aria-hidden="true" class="[checklist_item_check theme classes]">...</svg>
    </span>
    <span class="[checklist_item_content theme classes]">
      <span class="[checklist_item_title theme classes]">Buy milk</span>
    </span>
  </button>
</div>
```

### Read-only item (`interactive: false`)

```html
<button type="button" role="checkbox" aria-checked="true" aria-readonly="true" tabindex="-1"
        class="[checklist_item theme classes]">
  ...
</button>
```

---

## Theme keys

| Key                          | Element                                    | Variants |
| ----------------------------- | -------------------------------------------- | -------- |
| `checklist`                   | Outer `<div role="group">`                  | —        |
| `checklist_item`              | Item `<button>`                              | —        |
| `checklist_item_box`          | Decorative checkbox box `<span>`             | —        |
| `checklist_item_check`        | Check glyph inside the box                   | —        |
| `checklist_item_content`      | Content wrapper `<span>` (title + description) | —      |
| `checklist_item_title`        | Title `<span>`                               | —        |
| `checklist_item_description`  | Description `<span>`                         | —        |

Checked-state styling (strikethrough title, filled box, visible check glyph) reads the live `aria-checked` attribute via Tailwind's `aria-checked:`/`group-aria-checked/checklist-item:` variants — there is no `checked:` theme-resolver kwarg to pass.

---

## ARIA

See [ARIA.md's Checklist pattern](../../../ARIA.md) for the full `role="group"`/`role="checkbox"` contract, the read-only `aria-readonly` behavior, and why this component does not use `role="list"`.
```

- [ ] **Step 3: Add the ARIA.md pattern section**

In `ARIA.md`, insert a new subsection after `#### List (\`sp_list\`, \`sp_list_item\`)` (around line 84):

```markdown
#### Checklist (`checklist-item_controller`, `sp_checklist`)
- Group: `role="group"` with `aria-label`/`aria-labelledby` (optional but recommended when multiple checklists share a page)
- Each item: `<button type="button" role="checkbox" aria-checked="true/false">` — the native `<button>` gives free keyboard activation (Space *and* Enter) and focusability; `role="checkbox"` overrides the announced role. Note: unlike a native `<input type="checkbox">`, Enter also toggles here since the host element is a `<button>` — an accepted, low-risk deviation from the strict APG checkbox pattern (which only assigns Space)
- Not `role="list"`/`role="listitem"`: `role="checkbox"` is not a valid owned element of `role="list"` per the ARIA spec's required-owned-elements rule — using list markup here would trigger axe's `aria-required-children` violation
- Read-only item (`interactive: false`): `aria-readonly="true"` + `tabindex="-1"` — keeps the checked state announced to AT while removing the item from the tab order (nothing to activate)
- Checked-state styling hooks off the live `aria-checked` attribute directly (no parallel `data-checked` attribute) — the same attribute drives both AT semantics and CSS, so server-rendered initial paint and post-toggle paint always agree
```

- [ ] **Step 4: Verify docs formatting**

Run: `npm run format:docs:check` (from repo root)
Expected: PASS, or run `npm run format:docs` to auto-fix

- [ ] **Step 5: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/README.md stimulus-plumbers-rails/docs/component/checklist.md ARIA.md
git commit -m "docs(rails): document sp_checklist and the Checklist ARIA pattern"
```

---

### Task 9: Tailwind — theme classes

**Files:**
- Create: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/checklist.rb`
- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind_theme.rb`
- Test: `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/checklist_test.rb`

**Interfaces:**
- Produces: private instance methods `checklist_classes`, `checklist_item_classes`, `checklist_item_box_classes`, `checklist_item_check_classes`, `checklist_item_content_classes`, `checklist_item_title_classes`, `checklist_item_description_classes`, each returning `{ classes: "..." }`, matching the theme keys from Task 3 exactly (arity: zero args, per the `Global Constraints` note above — this is what the existing `list_item_title_classes` bug got wrong).

- [ ] **Step 1: Write the failing tests**

```ruby
# frozen_string_literal: true

require "test_helper"

class TailwindThemeChecklistTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_checklist_returns_a_classes_string
    result = classes_for(:checklist)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_checklist_item_styles_checked_state_via_aria_checked
    assert_includes classes_for(:checklist_item_title), "aria-checked"
  end

  def test_checklist_item_box_is_in_flow_not_absolute
    refute_includes classes_for(:checklist_item_box), "absolute"
  end

  def test_checklist_item_check_starts_hidden_and_reveals_on_checked
    result = classes_for(:checklist_item_check)

    assert_includes result, "opacity-0"
    assert_includes result, "aria-checked"
  end

  def test_checklist_item_content_uses_flex_col
    result = classes_for(:checklist_item_content)

    assert_includes result, "flex-col"
  end

  def test_checklist_item_title_uses_muted_color_when_checked
    assert_includes classes_for(:checklist_item_title), "--sp-color-muted-fg"
  end

  def test_resolving_with_no_kwargs_does_not_raise
    # Regression guard for the arity bug found in list_item_title_classes/list_item_description_classes
    assert_silent { @theme.resolve(:checklist_item_title) }
    assert_silent { @theme.resolve(:checklist_item_description) }
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd stimulus-plumbers-tailwind && bundle exec rake test:unit TEST=test/stimulus_plumbers/themes/tailwind/checklist_test.rb`
Expected: FAIL — warnings logged + empty `classes` (module not yet included), most assertions fail

- [ ] **Step 3: Write minimal implementation**

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
          "focus-visible:ring-(--sp-color-primary-ring)",
          "hover:bg-(--sp-color-muted)",
          "aria-readonly:cursor-default aria-readonly:hover:bg-transparent"
        ].freeze

        BOX_BASE = %w[
          flex items-center justify-center shrink-0
          size-(--sp-icon-size-sm) rounded-(--sp-radius-xs)
          border-(length:--sp-border-width) border-(--sp-color-border)
          group-aria-checked/checklist-item:bg-(--sp-color-primary)
          group-aria-checked/checklist-item:border-(--sp-color-primary)
        ].freeze

        CHECK_BASE = %w[
          text-(--sp-color-primary-fg) opacity-0
          group-aria-checked/checklist-item:opacity-100
        ].freeze

        CONTENT_BASE = %w[flex flex-col flex-1 min-w-0].freeze

        TITLE_BASE = %w[
          text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)
          group-aria-checked/checklist-item:line-through
          group-aria-checked/checklist-item:text-(--sp-color-muted-fg)
        ].freeze

        DESCRIPTION_BASE = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze

        private

        def checklist_classes
          { classes: klasses(*WRAPPER_BASE) }
        end

        def checklist_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def checklist_item_box_classes
          { classes: klasses(*BOX_BASE) }
        end

        def checklist_item_check_classes
          { classes: klasses(*CHECK_BASE) }
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

- [ ] **Step 4: Register the module**

In `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind_theme.rb`, add the require near `require_relative "tailwind/list"`:

```ruby
require_relative "tailwind/checklist"
```

And add the include near `include Tailwind::List`:

```ruby
      include Tailwind::Checklist
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd stimulus-plumbers-tailwind && bundle exec rake test:unit TEST=test/stimulus_plumbers/themes/tailwind/checklist_test.rb`
Expected: PASS (7 tests)

- [ ] **Step 6: Run rubocop**

Run: `cd stimulus-plumbers-tailwind && bundle exec rake rubocop`
Expected: no offenses in the new file

- [ ] **Step 7: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/checklist.rb stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind_theme.rb stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/checklist_test.rb
git commit -m "feat(tailwind): add checklist theme classes"
```

---

### Task 10: Rails-core — sandbox view, route, a11y tests

**Files:**
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/checklist.html.erb`
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`
- Create: `stimulus-plumbers-rails/test/accessibility/components/checklist_accessibility_test.rb`

**Interfaces:**
- Consumes: `sp_checklist` (Task 7). No new Ruby interfaces produced.

- [ ] **Step 1: Add the route**

In `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`, add `get :checklist` to the existing `scope "/display"` block (alongside `get :list`).

- [ ] **Step 2: Write the sandbox view**

```erb
<%# stimulus-plumbers-rails/test/sandbox/app/views/components/checklist.html.erb %>
<h1>Checklist components</h1>

<div id="checklist-default">
  <%= sp_checklist(label: "Groceries") do |checklist| %>
    <%= checklist.item("Buy milk", checked: true) %>
    <%= checklist.item("Walk the dog", checked: false) %>
  <% end %>
</div>

<div id="checklist-with-description">
  <%= sp_checklist(label: "Onboarding") do |checklist| %>
    <%= checklist.item("Verify email", checked: true) do |item| %>
      <% item.with_description("Sent to you at signup") %>
    <% end %>
    <%= checklist.item("Add payment method", checked: false) %>
  <% end %>
</div>

<div id="checklist-read-only">
  <%= sp_checklist(label: "Completed steps") do |checklist| %>
    <%= checklist.item("Account created", checked: true, interactive: false) %>
    <%= checklist.item("Profile complete", checked: false, interactive: false) %>
  <% end %>
</div>
```

- [ ] **Step 3: Write the failing a11y tests**

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
    find("#checklist-default button[aria-checked='false']").click

    assert_accessible context: "#checklist-default"
  end
end
```

- [ ] **Step 4: Run the a11y tests**

Run: `cd stimulus-plumbers-rails && bundle exec rake test:accessibility TEST=test/accessibility/components/checklist_accessibility_test.rb`
Expected: PASS (4 tests) — if `test_checklist_passes_wcag_after_toggling_an_item` fails because JS asset compilation is stale in the sandbox, check `test/sandbox/config/environment.rb`'s asset pipeline setup for how other interactive a11y tests (e.g. `list_accessibility_test.rb`'s toggle-based tests, if any — otherwise use `popover_accessibility_test.rb` or `timeline_accessibility_test.rb` as a reference) get fresh JS; this sandbox should already serve `stimulus-plumbers`'s built JS including `checklist-item` once Task 1–2 land, since the sandbox imports the whole package.

- [ ] **Step 5: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-rails/test/sandbox/app/views/components/checklist.html.erb stimulus-plumbers-rails/test/sandbox/config/routes/display.rb stimulus-plumbers-rails/test/accessibility/components/checklist_accessibility_test.rb
git commit -m "test(rails): add checklist a11y coverage"
```

---

### Task 11: Tailwind — sandbox view, route, snapshot tests

**Files:**
- Create: `stimulus-plumbers-tailwind/test/sandbox/app/views/components/checklist.html.erb`
- Modify: `stimulus-plumbers-tailwind/test/sandbox/config/routes/display.rb`
- Create: `stimulus-plumbers-tailwind/test/snapshots/checklist.spec.js`

**Interfaces:**
- Consumes: `sp_checklist` (Task 7), Tailwind theme classes (Task 9). Mirrors Task 10's sandbox content exactly (same section IDs) since "Tailwind snapshot tests must be a superset of stimulus-plumbers-rails a11y tests" per `stimulus-plumbers-tailwind/CLAUDE.md`.

- [ ] **Step 1: Add the route**

In `stimulus-plumbers-tailwind/test/sandbox/config/routes/display.rb`, add `get :checklist` to the existing `scope "/display"` block.

- [ ] **Step 2: Write the sandbox view**

Follow this gem's `sb-section`/`sb-col` convention (see `stimulus-plumbers-tailwind/CLAUDE.md`'s Sandbox View Convention: `{component}-{usecase}` IDs, in-section `<h2>`, `sb-row`/`sb-col` wrapper), covering the same three states as Task 10 plus a toggled state for the visual diff:

```erb
<%# stimulus-plumbers-tailwind/test/sandbox/app/views/components/checklist.html.erb %>
<h1>Checklist components</h1>

<section id="checklist-default" class="sb-section">
  <h2>Default</h2>
  <div class="sb-col">
    <%= sp_checklist(label: "Groceries") do |checklist| %>
      <%= checklist.item("Buy milk", checked: true) %>
      <%= checklist.item("Walk the dog", checked: false) %>
    <% end %>
  </div>
</section>

<section id="checklist-with-description" class="sb-section">
  <h2>With description</h2>
  <div class="sb-col">
    <%= sp_checklist(label: "Onboarding") do |checklist| %>
      <%= checklist.item("Verify email", checked: true) do |item| %>
        <% item.with_description("Sent to you at signup") %>
      <% end %>
      <%= checklist.item("Add payment method", checked: false) %>
    <% end %>
  </div>
</section>

<section id="checklist-read-only" class="sb-section">
  <h2>Read-only</h2>
  <div class="sb-col">
    <%= sp_checklist(label: "Completed steps") do |checklist| %>
      <%= checklist.item("Account created", checked: true, interactive: false) %>
      <%= checklist.item("Profile complete", checked: false, interactive: false) %>
    <% end %>
  </div>
</section>
```

- [ ] **Step 3: Write the snapshot spec**

```js
// stimulus-plumbers-tailwind/test/snapshots/checklist.spec.js
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
    const item = page.locator("#checklist-default [role='checkbox']").first();
    await item.click();
    await expect(page.locator("#checklist-default")).toHaveScreenshot("default-toggled.png");
  });
});
```

- [ ] **Step 4: Start the sandbox and visually inspect before trusting the diff**

Run: `cd stimulus-plumbers-tailwind && RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:4001`
Then open `http://127.0.0.1:4001/components/display/checklist` and confirm: unchecked box is an outlined square, checked box is filled with a visible check glyph, checked titles are struck through, read-only items show no hover affordance.

- [ ] **Step 5: Run the snapshot tests**

Run: `cd stimulus-plumbers-tailwind && node --run test:snapshots -- checklist.spec.js`
Expected: new baseline screenshots generated (first run) or PASS against existing baselines. **Do not run `test:snapshots:update`** — per this gem's CLAUDE.md, the user runs that.

- [ ] **Step 6: Commit**

```bash
cd /Users/ryanchang/Documents/Github/stimulus-plumbers
git add stimulus-plumbers-tailwind/test/sandbox/app/views/components/checklist.html.erb stimulus-plumbers-tailwind/test/sandbox/config/routes/display.rb stimulus-plumbers-tailwind/test/snapshots/checklist.spec.js
git commit -m "test(tailwind): add checklist snapshot coverage"
```

---

## Self-Review

**Spec coverage:**
- JS controller (state, toggle, dispatch) → Task 1
- JS export/README/docs → Task 2
- Theme schema (no broken `checked:` variant) → Task 3
- Slots → Task 4
- Item component (required `checked:`, `interactive:` default `true`, `role="checkbox"`, read-only `aria-readonly`/`tabindex`) → Task 5
- Wrapper component (`role="group"`, `label:`/`labelledby:`) → Task 6
- Helper → Task 7
- Rails docs + ARIA.md pattern → Task 8
- Tailwind theme classes (`aria-checked:` driven, arity regression guard) → Task 9
- Rails a11y tests → Task 10
- Tailwind snapshot tests (superset of a11y states) → Task 11

**Placeholder scan:** none found — every step has complete code or an exact command.

**Type consistency:** `checked:` (boolean, required) and `interactive:` (boolean, default `true`) are used identically in Task 5's implementation, Task 6/7's call sites, Task 8's docs, Task 10/11's sandbox views. Theme key names (`checklist`, `checklist_item`, `checklist_item_box`, `checklist_item_check`, `checklist_item_content`, `checklist_item_title`, `checklist_item_description`) match exactly across Task 3 (schema), Task 5 (`theme.resolve` calls), Task 9 (Tailwind method names), and Task 8 (docs table). Controller identifier `checklist-item` matches across Task 1 (JS), Task 5 (`data-controller`), Task 8/ARIA.md docs.
