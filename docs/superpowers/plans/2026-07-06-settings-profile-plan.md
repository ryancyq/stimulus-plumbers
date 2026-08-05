# Settings/Profile Composition + Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `Form::Builder#section` (a public, generalized fieldset-grouping API) and a new `tabs` component (Stimulus controller + `sp_tabs` Rails helper, true ARIA tabs with eager and lazy Turbo-Frame panels), then document two pure-composition recipes (profile card, sidebar nav) that need no new code.

**Architecture:** `Form::Builder#section` reuses `Fields::Label` (already used by the internal `Fields::Fieldset`) to render a `<fieldset><legend>` wrapper around a caller-supplied block — no new theme key, matching `Fieldset`'s existing lack of a themed `<fieldset>` class. `tabs` is a new `StimulusPlumbers::Components::Tabs` renderer (+ `Tabs::Builder` DSL, mirroring the `Timeline`/`Timeline::Event` block-based pattern) paired with a new `tabs_controller.js` that reuses the existing `RovingTabIndex` helper for Left/Right/Home/End roving focus, wiring "automatic activation" (focus move → immediately show that panel) via a bubble-phase keydown listener on the wrapper element plus a per-tab click listener. Lazy panels render a raw `<turbo-frame>` element (this gem has no `turbo-rails` dependency, so it's built with `content_tag`, not `turbo_frame_tag`).

**Tech Stack:** Ruby/Rails (`ActionView::Helpers::FormBuilder` subclass, `Plumber::Base` renderer pattern), Stimulus (`@hotwired/stimulus`), Vitest (JS unit tests), Minitest (Ruby unit tests), Capybara + `cuprite` + axe-core (accessibility tests).

## Global Constraints

- WCAG 2.1 Level AA (see `ARIA.md`).
- **No cross-doc duplication** (root `CLAUDE.md`): JS controller API → `stimulus-plumbers/docs/component/tabs.md` only; Rails helper options → `stimulus-plumbers-rails/docs/component/tabs.md` only (links to the JS doc, doesn't repeat it).
- New exported JS controller → add a row to `stimulus-plumbers/README.md`'s Controllers table + create `stimulus-plumbers/docs/component/tabs.md` in the same commit.
- New Rails helper (`sp_*`) → add a row to `stimulus-plumbers-rails/README.md`'s Components table + create `stimulus-plumbers-rails/docs/component/tabs.md` in the same commit. Never reference a doc file in a README before it exists.
- Export name in `stimulus-plumbers/src/index.js` must match the README setup snippet and Controllers table — verify with `grep` before writing docs.
- Component unit tests assert HTML structure and ARIA, not CSS classes.
- Never use `I18n.t(...)` in Ruby tests — assert literal English strings.
- Accessibility test sandbox views: multi-variant pages get outer `<div id="component">` + inner `<section id="component-variant">`; icon names must be generic (`book`, `close`, not `book-open`), since the core sandbox has no theme.
- Out of scope (per spec): manual tab activation mode, drag/closable/dynamic tabs, nested tab groups, `f.section` layout options (`columns:`, nesting).
- No new gem dependency: lazy panels use `content_tag(:"turbo-frame", ...)`, never `turbo_frame_tag` (that helper ships in `turbo-rails`, which this gem does not depend on).

---

## Task 1: `Form::Builder#section`

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/form/builder.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/form/builder_test.rb`
- Modify (docs): `stimulus-plumbers-rails/docs/component/form.md`

**Interfaces:**
- Produces: `StimulusPlumbers::Form::Builder#section(title, **html_options, &block)` → renders `<fieldset><legend>{title}</legend>{block content}</fieldset>`. No new theme key (matches `Fields::Fieldset`, which also renders `<fieldset>` with zero `theme.resolve` call on the fieldset tag itself — only its inner group div is themed).

### Steps

1. Write a failing test in `stimulus-plumbers-rails/test/stimulus_plumbers/form/builder_test.rb`. Add before the final `end` of the class:

```ruby
  def test_section_renders_fieldset_with_legend
    doc = build_form do |f|
      f.section("Profile") { f.text_field(:email) }
    end

    assert_css doc, "fieldset > legend", text: "Profile"
  end

  def test_section_renders_block_content_inside_fieldset
    doc = build_form do |f|
      f.section("Profile") { f.text_field(:email) }
    end

    assert_css doc, "fieldset input[type='text'][name='sign_in_form[email]']"
  end

  def test_section_does_not_interfere_with_field_rendering_outside_it
    doc = build_form do |f|
      f.section("Profile") { f.text_field(:email) }
      f.field(:email, as: :text)
    end

    assert_css doc, "fieldset input[type='text']"
    assert_css doc, "label[for='sign_in_form_email']"
  end
```

2. Run it and confirm it fails (method doesn't exist yet):

```bash
cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/form/builder_test.rb
```

Expect `NoMethodError: undefined method 'section'`.

3. Implement `section` in `stimulus-plumbers-rails/lib/stimulus_plumbers/form/builder.rb`. Add as a new public method, right after `choice` and before the `private` keyword:

```ruby
      def section(title, **kwargs, &block)
        render_section(title, kwargs, &block)
      end
```

Add the private implementation right after `render_fieldset` (which already exists just below `render_choice_field`):

```ruby
      def render_section(title, html_options, &block)
        legend = Fields::Label.new(@template).render(text: title, tag: :legend)
        template.content_tag(:fieldset, **merge_html_options(html_options)) do
          template.safe_join([legend, template.capture(&block)])
        end
      end
```

Note: `Fields::Label` is already `require_relative`d in `builder.rb` (line 12: `require_relative "fields/fieldset"` pulls in `Label` transitively is NOT guaranteed — check explicitly). Confirm `require_relative "fields/label"` is present; `builder.rb`'s current requires list does not include it directly (only `fields/fieldset` does, internally, via its own `require_relative` chain in `stimulus_plumbers.rb`). Since `stimulus_plumbers.rb` already does `require_relative "stimulus_plumbers/form/fields/label"` before `require_relative "stimulus_plumbers/form/builder"`, the constant is available at runtime — no new require needed in `builder.rb` itself (same pattern `Fields::Fieldset` already relies on: `builder.rb` calls `Fields::Fieldset.new(...)` in `render_fieldset` without a local require for `Fieldset` either — it works because `require_relative "fields/fieldset"` is already in `builder.rb`'s own require list). Since `builder.rb` does NOT currently require `fields/label` directly, add it to be self-contained and consistent with how `fieldset.rb` requires `label` in the same directory. Check `stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/fieldset.rb` — it references `Label.new(...)` without a local require either, relying on load order in `stimulus_plumbers.rb`. Follow the same convention: no new require needed in `builder.rb`, since `stimulus_plumbers.rb` loads `form/fields/label` before `form/builder`.

4. Run the tests again and confirm they pass:

```bash
cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/form/builder_test.rb
```

5. Run rubocop for this file:

```bash
cd stimulus-plumbers-rails && bundle exec rubocop lib/stimulus_plumbers/form/builder.rb
```

6. Update `stimulus-plumbers-rails/docs/component/form.md`. Add a new `## f.section` section right after the `## f.choice` section (before `## Rendered HTML Structure`):

```markdown
---

## f.section

Groups arbitrary fields under a heading using native `<fieldset>`/`<legend>` semantics — no `aria-describedby`/error wiring at the section level (errors remain per-field).

```erb
<%= f.section "Profile" do %>
  <%= f.field :name,  as: :text %>
  <%= f.field :email, as: :email %>
<% end %>
```
```

Also add a row to the "Two-level API" table is not applicable (that table describes Level 1 vs Level 2, and `section` is a grouping wrapper, not a field). Instead add one line under the "Level 2 — Full-field helpers" table intro noting `f.section` groups fields; do this by adding a sentence right after the three-row method table in `form.md`:

```markdown
`f.section(title, &block)` wraps arbitrary field calls (including the three above) in a `<fieldset><legend>` for accessible grouping — see below.
```

7. Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/form/builder.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/form/builder_test.rb \
        stimulus-plumbers-rails/docs/component/form.md
git commit -m "$(cat <<'EOF'
feat(rails): add Form::Builder#section for grouping fields under a heading

Generalizes the existing internal Fields::Fieldset legend-rendering logic
into a public API for settings-page-style field grouping.
EOF
)"
```

---

## Task 2: `tabs` Stimulus controller (JS)

**Files:**
- Test: `stimulus-plumbers/tests/unit/controllers/tabs_controller.test.js`
- Create: `stimulus-plumbers/src/controllers/tabs_controller.js`
- Modify: `stimulus-plumbers/src/index.js`
- Modify: `stimulus-plumbers/README.md`
- Create: `stimulus-plumbers/docs/component/tabs.md`

**Interfaces:**
- Consumes: `RovingTabIndex` from `stimulus-plumbers/src/accessibility/keyboard.js` (constructor `new RovingTabIndex(items, { orientation, initialIndex, wrap })`; `.activate()`; `.setCurrentIndex(index)`; `.currentIndex`; `.deactivate()`), and `isArrowKey(event)` from the same file.
- Produces: default export `TabsController` — targets `tab`, `panel`; value `active` (Number, default `0`); methods `connect()`, `disconnect()`, `onKeydown(event)`, `onTabClick(event)`, `select(index)`; dispatches `tabs:changed` with `{ index, tabId, panelId }`.
- HTML contract the controller expects (produced by Task 3's Rails helper, but the JS test builds this markup by hand): root element has `data-controller="tabs"` and `data-action="keydown->tabs#onKeydown"`; each `tab` target is a `<button role="tab" data-tabs-target="tab" data-action="click->tabs#onTabClick">`; each `panel` target is a `<div role="tabpanel" data-tabs-target="panel">`.

### Steps

1. Write the failing test file `stimulus-plumbers/tests/unit/controllers/tabs_controller.test.js`:

```javascript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { Application } from '@hotwired/stimulus';
import TabsController from '../../../src/controllers/tabs_controller';

describe('TabsController', () => {
  let application;

  beforeEach(() => {
    application = Application.start();
    application.register('tabs', TabsController);
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = '';
  });

  const buildHTML = ({ active } = {}) => `
    <div data-controller="tabs" data-action="keydown->tabs#onKeydown"
         ${active !== undefined ? `data-tabs-active-value="${active}"` : ''}>
      <div role="tablist">
        <button id="tab-1" role="tab" aria-controls="panel-1" data-tabs-target="tab"
                data-action="click->tabs#onTabClick">Profile</button>
        <button id="tab-2" role="tab" aria-controls="panel-2" data-tabs-target="tab"
                data-action="click->tabs#onTabClick">Password</button>
        <button id="tab-3" role="tab" aria-controls="panel-3" data-tabs-target="tab"
                data-action="click->tabs#onTabClick">Notifications</button>
      </div>
      <div id="panel-1" role="tabpanel" aria-labelledby="tab-1" data-tabs-target="panel">Profile content</div>
      <div id="panel-2" role="tabpanel" aria-labelledby="tab-2" data-tabs-target="panel">Password content</div>
      <div id="panel-3" role="tabpanel" aria-labelledby="tab-3" data-tabs-target="panel">Notifications content</div>
    </div>
  `;

  const setup = async (html = buildHTML()) => {
    document.body.innerHTML = html;
    await new Promise((resolve) => setTimeout(resolve, 10));
  };

  describe('connect', () => {
    it('shows only the initial active panel (default index 0)', async () => {
      await setup();

      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      expect(panels[0].hidden).toBe(false);
      expect(panels[1].hidden).toBe(true);
      expect(panels[2].hidden).toBe(true);
    });

    it('honors the active value for the initial panel', async () => {
      await setup(buildHTML({ active: 1 }));

      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      expect(panels[0].hidden).toBe(true);
      expect(panels[1].hidden).toBe(false);
      expect(panels[2].hidden).toBe(true);
    });

    it('sets aria-selected on the initial active tab only', async () => {
      await setup();

      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      expect(tabs[0].getAttribute('aria-selected')).toBe('true');
      expect(tabs[1].getAttribute('aria-selected')).toBe('false');
      expect(tabs[2].getAttribute('aria-selected')).toBe('false');
    });
  });

  describe('click', () => {
    it('switches the visible panel and aria-selected', async () => {
      await setup();

      document.querySelectorAll('[data-tabs-target="tab"]')[2].click();

      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      expect(tabs[2].getAttribute('aria-selected')).toBe('true');
      expect(tabs[0].getAttribute('aria-selected')).toBe('false');
      expect(panels[2].hidden).toBe(false);
      expect(panels[0].hidden).toBe(true);
    });

    it('dispatches tabs:changed with index, tabId, panelId', async () => {
      await setup();

      let detail;
      document.addEventListener('tabs:changed', (e) => { detail = e.detail; });
      document.querySelectorAll('[data-tabs-target="tab"]')[1].click();

      expect(detail).toEqual({ index: 1, tabId: 'tab-2', panelId: 'panel-2' });
    });
  });

  describe('arrow-key roving focus (automatic activation)', () => {
    it('ArrowRight moves focus and immediately switches the panel', async () => {
      await setup();

      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      tabs[0].focus();
      tabs[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(document.activeElement).toBe(tabs[1]);
      expect(tabs[1].getAttribute('aria-selected')).toBe('true');
      expect(panels[1].hidden).toBe(false);
      expect(panels[0].hidden).toBe(true);
    });

    it('End moves focus to the last tab and switches to its panel', async () => {
      await setup();

      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      tabs[0].focus();
      tabs[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'End', bubbles: true }));

      expect(document.activeElement).toBe(tabs[2]);
      expect(panels[2].hidden).toBe(false);
    });

    it('dispatches tabs:changed on arrow-key move', async () => {
      await setup();

      let detail;
      document.addEventListener('tabs:changed', (e) => { detail = e.detail; });
      const tabs = document.querySelectorAll('[data-tabs-target="tab"]');
      tabs[0].focus();
      tabs[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(detail).toEqual({ index: 1, tabId: 'tab-2', panelId: 'panel-2' });
    });

    it('does not switch panels for keydown events originating outside the tablist', async () => {
      await setup();

      const panels = document.querySelectorAll('[data-tabs-target="panel"]');
      panels[0].dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true }));

      expect(panels[0].hidden).toBe(false);
      expect(panels[1].hidden).toBe(true);
    });
  });
});
```

2. Run it and confirm it fails (module doesn't exist yet):

```bash
cd stimulus-plumbers && npm test -- tabs_controller
```

3. Implement `stimulus-plumbers/src/controllers/tabs_controller.js`:

```javascript
import { Controller } from '@hotwired/stimulus';
import { RovingTabIndex, isArrowKey } from '../accessibility/keyboard';

export default class extends Controller {
  static targets = ['tab', 'panel'];
  static values = { active: { type: Number, default: 0 } };

  connect() {
    this.rovingTabIndex = new RovingTabIndex(this.tabTargets, {
      orientation: 'horizontal',
      initialIndex: this.activeValue,
    });
    this.rovingTabIndex.activate();
    this.showPanel(this.activeValue);
  }

  disconnect() {
    this.rovingTabIndex?.deactivate();
  }

  onKeydown(event) {
    if (!this.tabTargets.includes(event.target)) return;
    if (!isArrowKey(event) && event.key !== 'Home' && event.key !== 'End') return;

    this.select(this.rovingTabIndex.currentIndex);
  }

  onTabClick(event) {
    this.select(this.tabTargets.indexOf(event.currentTarget));
  }

  select(index) {
    this.rovingTabIndex.setCurrentIndex(index);
    this.showPanel(index);
  }

  showPanel(index) {
    this.tabTargets.forEach((tab, i) => tab.setAttribute('aria-selected', String(i === index)));
    this.panelTargets.forEach((panel, i) => {
      panel.hidden = i !== index;
    });

    const tab = this.tabTargets[index];
    const panel = this.panelTargets[index];
    this.dispatch('changed', { detail: { index, tabId: tab.id, panelId: panel.id } });
  }
}
```

Design note for the implementer: `onKeydown` is wired via `data-action="keydown->tabs#onKeydown"` on the controller's *root* element (an ancestor of the `tab` targets), not on each tab directly. `RovingTabIndex.activate()` attaches its own `keydown` listener directly on each tab target; that listener runs during the event's target phase (moving focus + updating `this.rovingTabIndex.currentIndex` synchronously) strictly before the event bubbles up to the root element's listener. This ordering is standard DOM event dispatch behavior (target-phase listeners on an element always run before the event reaches ancestors in the bubble phase), so by the time `onKeydown` runs, `this.rovingTabIndex.currentIndex` already reflects the new focused tab. This is what makes automatic activation ("on any focus move, immediately calls select(newIndex)") work without duplicating `RovingTabIndex`'s wrap/orientation math. The `this.tabTargets.includes(event.target)` guard prevents unrelated keydowns bubbling from inside panel content (e.g. arrow keys pressed in a form field inside an eager panel) from triggering a tab switch.

`onTabClick` is a small event-adapter method (see the JS README's documented "Method naming convention": `onX(event)` extracts payload and calls the raw-value programmatic API `x(value)`) — it exists so `select(index)` itself stays a plain, directly-callable function taking an index, matching the spec's documented method signature exactly, while still letting a `data-action="click->tabs#onTabClick"` wire it up per tab button.

4. Run the test again and confirm it passes:

```bash
cd stimulus-plumbers && npm test -- tabs_controller
```

5. Lint:

```bash
cd stimulus-plumbers && npm run lint && npm run format:check
```

6. Add the export to `stimulus-plumbers/src/index.js`, alphabetically between `ReorderableController` and `TimelineController`:

```javascript
export { default as ReorderableController } from './controllers/reorderable_controller.js';
export { default as TabsController } from './controllers/tabs_controller.js';
export { default as TimelineController } from './controllers/timeline_controller.js';
```

7. Add a row to `stimulus-plumbers/README.md`'s Controllers table, between the `reorderable` and `timeline` rows:

```markdown
| `reorderable` | Drag (pointer) or keyboard (`Alt+Arrow`) reordering for a vertical list | [docs/component/reorderable.md](docs/component/reorderable.md) |
| `tabs` | ARIA tabs — automatic activation, roving-tabindex keyboard navigation, eager or lazy (Turbo Frame) panels | [docs/component/tabs.md](docs/component/tabs.md) |
| `timeline` | Manages expandable timeline event items with keyboard navigation | [docs/component/timeline.md](docs/component/timeline.md) |
```

8. Create `stimulus-plumbers/docs/component/tabs.md`:

```markdown
# Tabs

True ARIA tabs widget (`role="tablist"`/`role="tab"`/`role="tabpanel"`) with automatic activation:
moving focus with the keyboard immediately switches the visible panel. Roving-tabindex keyboard
navigation (Left/Right/Home/End) is provided by the shared `RovingTabIndex` helper — see
[docs/utility/accessibility.md](../utility/accessibility.md).

## Targets

| Target | Element | Description |
| --- | --- | --- |
| `tab` | `<button role="tab" aria-controls aria-selected>` | One per tab; roving-tabindex managed across this target list |
| `panel` | `<div role="tabpanel" hidden>` | One per tab; may directly contain content (eager) or wrap a `<turbo-frame src="..." loading="lazy">` (lazy) |

## Values

| Value | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | Number | `0` | Index of the initially visible panel |

## Actions

| Element | Action |
| --- | --- |
| Root (`data-controller="tabs"`) | `keydown->tabs#onKeydown` |
| Each `tab` target | `click->tabs#onTabClick` |

## Methods

- `connect()` — wires `RovingTabIndex` over the `tab` targets (orientation `horizontal`, `initialIndex` from `active`); shows the initial active panel, hides the rest.
- `onKeydown(event)` — on Left/Right/Home/End while focus is on a `tab` target, reads the new roving-tabindex position and calls `select(newIndex)` (automatic activation).
- `onTabClick(event)` — calls `select(index)` for the clicked tab.
- `select(index)` — sets `aria-selected` on the target tab (unsets on others); shows the target `panel`, hides the rest; dispatches `tabs:changed`.

## Dispatches

| Event | Detail | When |
| --- | --- | --- |
| `tabs:changed` | `{ index, tabId, panelId }` | Any time the active tab changes (click or keyboard) |

## Why automatic activation + lazy panels aren't in tension

WAI-ARIA generally recommends manual activation when switching is expensive (e.g. lazy-loaded
content), to avoid firing a fetch on every arrow keypress. Here, unhiding a panel (removing
`hidden`) is what makes a `loading="lazy"` Turbo Frame intersect the viewport and trigger its
fetch — and Turbo retains a frame's loaded content across subsequent shows/hides, so the fetch
only ever happens once, on a panel's first activation, regardless of how many times focus passes
through it afterward. Automatic activation stays simple and cheap.
```

9. Commit:

```bash
git add stimulus-plumbers/tests/unit/controllers/tabs_controller.test.js \
        stimulus-plumbers/src/controllers/tabs_controller.js \
        stimulus-plumbers/src/index.js \
        stimulus-plumbers/README.md \
        stimulus-plumbers/docs/component/tabs.md
git commit -m "$(cat <<'EOF'
feat(js): add tabs controller — ARIA tabs with automatic activation

Reuses RovingTabIndex for Left/Right/Home/End roving focus; a bubble-phase
keydown listener on the controller root lets focus movement immediately
switch the visible panel without duplicating RovingTabIndex's wrap/orientation logic.
EOF
)"
```

---

## Task 3: `sp_tabs` Rails helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs.rb`
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs/builder.rb`
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/tabs_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/tabs_test.rb`
- Modify: `stimulus-plumbers-rails/README.md`
- Create: `stimulus-plumbers-rails/docs/component/tabs.md`

**Interfaces:**
- Consumes: `StimulusPlumbers::Plumber::Base` (`merge_html_options`, `theme`, `template`), `theme.resolve(:tabs | :tabs_list | :tabs_tab | :tabs_panel)`, `template.sp_dom_id` (from `PlumberHelper`), `template.capture(&block)`.
- Produces: `sp_tabs(active: 0, **kwargs, &block)` helper → yields a `Tabs::Builder` with `t.tab(title, lazy: false, src: nil, &block)`.
- HTML contract produced (consumed by Task 2's controller): root `<div data-controller="tabs" data-action="keydown->tabs#onKeydown" data-tabs-active-value="{active}">` wrapping a `role="tablist"` div of `<button role="tab" data-tabs-target="tab" data-action="click->tabs#onTabClick" aria-controls="{panel_id}" aria-selected>` and a sibling `role="tabpanel"` `<div data-tabs-target="panel" aria-labelledby="{tab_id}" hidden>` per tab, in eager (block content) or lazy (`<turbo-frame id="{panel_id}" src="{src}" loading="lazy">`) form.

### Steps

1. Register theme keys first (needed so `theme.resolve` doesn't warn in tests). Add to `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`, right after the `TIMELINE` block closes (before the next constant, alphabetically `TABS` sorts before `TIMELINE`; since `TIMELINE` is already the last block in the file, add `TABS` right before it):

```ruby
      TABS = {
        tabs:       {}.freeze,
        tabs_list:  {}.freeze,
        tabs_tab:   {}.freeze,
        tabs_panel: {}.freeze
      }.freeze

      TIMELINE = {
```

2. Add `**Schema::TABS` to `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`'s `SCHEMA` hash, right before `**Schema::TIMELINE`:

```ruby
        **Schema::LINK,
        **Schema::TABS,
        **Schema::TIMELINE
```

3. Write the failing component unit test `stimulus-plumbers-rails/test/stimulus_plumbers/components/tabs_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class TabsComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Tabs.new(self)
  end

  def render_tabs(**kwargs, &block)
    parse_html(renderer.render(**kwargs, &block))
  end

  def test_root_has_tabs_controller
    doc = render_tabs { |t| t.tab("Profile") { "Profile content" } }

    assert_css doc, "div[data-controller='tabs']"
  end

  def test_renders_tablist_with_tab_buttons
    doc = render_tabs do |t|
      t.tab("Profile") { "Profile content" }
      t.tab("Password") { "Password content" }
    end

    assert_css doc, "[role='tablist'] button[role='tab']", count: 2
    assert_includes doc.text, "Profile"
    assert_includes doc.text, "Password"
  end

  def test_tab_button_has_action_and_aria_controls_matching_panel_id
    doc = render_tabs { |t| t.tab("Profile") { "Profile content" } }

    tab = doc.at_css("button[role='tab']")
    panel = doc.at_css("[role='tabpanel']")
    assert_equal panel["id"], tab["aria-controls"]
    assert_equal "click->tabs#onTabClick", tab["data-action"]
  end

  def test_panel_has_aria_labelledby_matching_tab_id
    doc = render_tabs { |t| t.tab("Profile") { "Profile content" } }

    tab = doc.at_css("button[role='tab']")
    panel = doc.at_css("[role='tabpanel']")
    assert_equal tab["id"], panel["aria-labelledby"]
  end

  def test_first_tab_is_selected_by_default
    doc = render_tabs do |t|
      t.tab("Profile") { "Profile content" }
      t.tab("Password") { "Password content" }
    end

    tabs = doc.css("button[role='tab']")
    assert_equal "true",  tabs[0]["aria-selected"]
    assert_equal "false", tabs[1]["aria-selected"]
  end

  def test_active_option_selects_a_different_initial_tab
    doc = render_tabs(active: 1) do |t|
      t.tab("Profile") { "Profile content" }
      t.tab("Password") { "Password content" }
    end

    assert_css doc, "div[data-controller='tabs'][data-tabs-active-value='1']"
  end

  def test_non_lazy_tab_renders_block_content_inline
    doc = render_tabs { |t| t.tab("Profile") { content_tag(:p, "Profile content") } }

    assert_css doc, "[role='tabpanel'] p", text: "Profile content"
    assert_no_css doc, "turbo-frame"
  end

  def test_lazy_tab_renders_turbo_frame_with_src_and_loading_lazy
    doc = render_tabs { |t| t.tab("Password", lazy: true, src: "/settings/password") }

    frame = doc.at_css("[role='tabpanel'] turbo-frame")
    refute_nil frame
    assert_equal "/settings/password", frame["src"]
    assert_equal "lazy", frame["loading"]
  end

  def test_lazy_tab_without_src_raises
    assert_raises ArgumentError do
      render_tabs { |t| t.tab("Password", lazy: true) }
    end
  end
end
```

4. Run it and confirm it fails (constants don't exist yet):

```bash
cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/tabs_test.rb
```

5. Implement `stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs/builder.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Tabs
      class Builder
        Tab = Struct.new(:title, :lazy, :src, :block, :tab_id, :panel_id) do
          def content(template)
            if lazy
              template.content_tag(:"turbo-frame", nil, id: panel_id, src: src, loading: "lazy")
            else
              template.capture(&block)
            end
          end
        end

        attr_reader :tabs

        def initialize(template)
          @template = template
          @tabs = []
        end

        def tab(title, lazy: false, src: nil, &block)
          raise ArgumentError, "lazy tab requires src:" if lazy && src.nil?

          base = @template.sp_dom_id
          @tabs << Tab.new(title, lazy, src, block, "#{base}_tab", "#{base}_panel")
        end
      end
    end
  end
end
```

6. Implement `stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Tabs < Plumber::Base
      def render(active: 0, **kwargs, &block)
        builder = Tabs::Builder.new(template)
        yield builder
        tabs = builder.tabs

        html_options = merge_html_options(
          theme.resolve(:tabs),
          kwargs,
          { data: { controller: "tabs", action: "keydown->tabs#onKeydown", "tabs-active-value": active } }
        )
        template.content_tag(:div, **html_options) do
          template.safe_join([render_tablist(tabs), render_panels(tabs)])
        end
      end

      private

      def render_tablist(tabs)
        html_options = merge_html_options(theme.resolve(:tabs_list), { role: "tablist" })
        template.content_tag(:div, **html_options) do
          template.safe_join(tabs.each_with_index.map { |tab, index| render_tab(tab, index) })
        end
      end

      def render_tab(tab, index)
        html_options = merge_html_options(
          theme.resolve(:tabs_tab),
          {
            id:   tab.tab_id,
            role: "tab",
            type: "button",
            aria: { selected: (index.zero? ? "true" : "false"), controls: tab.panel_id },
            data: { "tabs-target": "tab", action: "click->tabs#onTabClick" }
          }
        )
        template.content_tag(:button, tab.title, **html_options)
      end

      def render_panels(tabs)
        template.safe_join(tabs.each_with_index.map { |tab, index| render_panel(tab, index) })
      end

      def render_panel(tab, index)
        html_options = merge_html_options(
          theme.resolve(:tabs_panel),
          {
            id:   tab.panel_id,
            role: "tabpanel",
            aria: { labelledby: tab.tab_id },
            data: { "tabs-target": "panel" }
          }.merge(index.zero? ? {} : { hidden: "" })
        )
        template.content_tag(:div, **html_options) { tab.content(template) }
      end
    end
  end
end
```

7. Wire up requires. Add to `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, right after the `require_relative "stimulus_plumbers/components/popover/panel"` line and before the `# -- Calendar --` comment:

```ruby
require_relative "stimulus_plumbers/components/tabs"
require_relative "stimulus_plumbers/components/tabs/builder"
```

8. Create `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/tabs_helper.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module TabsHelper
      def sp_tabs(...)
        Components::Tabs.new(self).render(...)
      end
    end
  end
end
```

9. Wire it into `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb` — add the require alphabetically after `popover_helper` and before `timeline_helper`, and the `include` in the same position:

```ruby
require_relative "helpers/popover_helper"
require_relative "helpers/tabs_helper"
require_relative "helpers/timeline_helper"

module StimulusPlumbers
  module Helpers
    # ...
    include PopoverHelper
    include TabsHelper
    include TimelineHelper
  end
end
```

10. Run the test again and confirm it passes:

```bash
cd stimulus-plumbers-rails && bundle exec rake test:unit TEST=test/stimulus_plumbers/components/tabs_test.rb
```

11. Run the full unit suite (schema/theme changes are global) and rubocop:

```bash
cd stimulus-plumbers-rails && bundle exec rake test:unit
cd stimulus-plumbers-rails && bundle exec rubocop lib/stimulus_plumbers/components/tabs.rb lib/stimulus_plumbers/components/tabs/builder.rb lib/stimulus_plumbers/helpers/tabs_helper.rb lib/stimulus_plumbers/themes/schema.rb lib/stimulus_plumbers/themes/base.rb lib/stimulus_plumbers/helpers.rb lib/stimulus_plumbers.rb
```

12. Add a row to `stimulus-plumbers-rails/README.md`'s Components table, alphabetically between `Popover` and `Timeline`:

```markdown
| Popover | `sp_popover` | [docs/component/popover.md](docs/component/popover.md) |
| Tabs | `sp_tabs` | [docs/component/tabs.md](docs/component/tabs.md) |
| Timeline | `sp_timeline`, `sp_timeline_group` | [docs/component/timeline.md](docs/component/timeline.md) |
```

13. Create `stimulus-plumbers-rails/docs/component/tabs.md`:

```markdown
# Tabs

`sp_tabs` renders a true ARIA tabs widget (`role="tablist"`/`role="tab"`/`role="tabpanel"`) backed
by the `tabs` Stimulus controller — see
[the JS controller doc](../../../stimulus-plumbers/docs/component/tabs.md) for targets, values,
keyboard behavior, and dispatched events.

## Usage

```erb
<%= sp_tabs(active: 0) do |t| %>
  <% t.tab("Profile") { f.field :name, as: :text } %>
  <% t.tab("Password", lazy: true, src: settings_password_path) %>
  <% t.tab("Notifications", lazy: true, src: settings_notifications_path) %>
<% end %>
```

## Options

| Option | Values | Default | Description |
| --- | --- | --- | --- |
| `active` | Integer | `0` | Index of the initially visible tab/panel |

## `t.tab`

| Option | Values | Default | Description |
| --- | --- | --- | --- |
| `lazy` | Boolean | `false` | Render the panel as a `<turbo-frame loading="lazy">` instead of the block content |
| `src` | String | `nil` | Turbo Frame `src:` — required when `lazy: true` |

Non-lazy tabs render the given block directly inside the panel. `lazy: true` requires `src:`
(raises `ArgumentError` otherwise) and ignores any block given.

## Theme keys

| Key | Element |
| --- | --- |
| `tabs` | outer wrapper |
| `tabs_list` | `role="tablist"` row |
| `tabs_tab` | individual `<button role="tab">` |
| `tabs_panel` | individual `role="tabpanel"` div |
```

14. Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/components/tabs/builder.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/tabs_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/tabs_test.rb \
        stimulus-plumbers-rails/README.md \
        stimulus-plumbers-rails/docs/component/tabs.md
git commit -m "$(cat <<'EOF'
feat(rails): add sp_tabs helper with eager and lazy (Turbo Frame) panels

Mirrors the Timeline block-based builder DSL; lazy panels emit a raw
<turbo-frame> element via content_tag since this gem has no turbo-rails
dependency.
EOF
)"
```

---

## Task 4: Tabs accessibility tests (sandbox view + eager/lazy mix)

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/tabs.html.erb`
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/tabs_panel.html.erb`
- Test: `stimulus-plumbers-rails/test/accessibility/components/tabs_accessibility_test.rb`

**Interfaces:**
- Consumes: `sp_tabs` (Task 3), `assert_accessible(context:)` from `ApplicationAccessibilityTestCase`.
- Produces: sandbox route `GET /components/display/tabs` (view exercised by the test), `GET /components/display/tabs/panel` (the lazy `src:` target — its content doesn't matter since the sandbox has no Turbo JS runtime loaded, only `@hotwired/stimulus`; the route exists so `src:` points at something real).

### Steps

1. Add the sandbox controller actions to `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb` — add `def tabs; end` and `def tabs_panel; end` right after the existing `def timeline; end`:

```ruby
  def timeline; end

  def tabs; end

  def tabs_panel; end
```

2. Add routes to `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`:

```ruby
scope "/display", controller: "components" do
  get :list
  get :ordered_list
  get :avatar
  get :icon
  get :timeline
  get :tabs
  get "tabs/panel", action: :tabs_panel
end
```

3. Create `stimulus-plumbers-rails/test/sandbox/app/views/components/tabs_panel.html.erb` (rendered without the app layout, since it's the lazy-panel fetch target):

```erb
<p>Lazily loaded panel content.</p>
```

Add `layout: false` for this action in the controller (append to `tabs_panel`):

```ruby
  def tabs_panel
    render layout: false
  end
```

4. Create `stimulus-plumbers-rails/test/sandbox/app/views/components/tabs.html.erb`:

```erb
<h1>Tabs components</h1>

<div id="tabs">
  <section id="tabs-eager">
    <h2>Eager panels</h2>
    <%= sp_tabs do |t| %>
      <% t.tab("Profile") { content_tag(:p, "Profile settings go here.") } %>
      <% t.tab("Appearance") { content_tag(:p, "Appearance settings go here.") } %>
    <% end %>
  </section>

  <section id="tabs-mixed">
    <h2>Mixed eager and lazy panels</h2>
    <%= sp_tabs do |t| %>
      <% t.tab("Profile") { content_tag(:p, "Profile settings go here.") } %>
      <% t.tab("Password", lazy: true, src: "/components/display/tabs/panel") %>
      <% t.tab("Notifications", lazy: true, src: "/components/display/tabs/panel") %>
    <% end %>
  </section>
</div>
```

5. Write the accessibility test `stimulus-plumbers-rails/test/accessibility/components/tabs_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class TabsAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/tabs"
  end

  def test_eager_tabs_pass_wcag_on_initial_render
    assert_accessible context: "#tabs-eager"
  end

  def test_mixed_tabs_pass_wcag_on_initial_render
    assert_accessible context: "#tabs-mixed"
  end

  def test_mixed_tabs_pass_wcag_after_switching_to_a_lazy_tab
    within("#tabs-mixed") { find("button[role='tab']", text: "Password").click }

    assert_accessible context: "#tabs-mixed"
  end

  def test_switching_tabs_updates_aria_selected_and_visible_panel
    within("#tabs-mixed") do
      find("button[role='tab']", text: "Password").click

      assert_selector "button[role='tab'][aria-selected='true']", text: "Password"
      assert_selector "[role='tabpanel']", text: "Lazily loaded panel content.", visible: :visible
    end
  end
end
```

6. Run it:

```bash
cd stimulus-plumbers-rails && bundle exec rake test:accessibility TEST=test/accessibility/components/tabs_accessibility_test.rb
```

If any test fails on ARIA/markup, fix `Tabs`/`Tabs::Builder`/`tabs_controller.js` from Tasks 2–3 (do not weaken the test).

Note for `test_switching_tabs_updates_aria_selected_and_visible_panel`: the built JS bundle at `/dist/index.es.js` (loaded by the sandbox layout) must include `TabsController` — rebuild the JS package before running accessibility tests if the dist bundle is stale:

```bash
cd stimulus-plumbers && npm run build
```

7. Commit:

```bash
git add stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb \
        stimulus-plumbers-rails/test/sandbox/config/routes/display.rb \
        stimulus-plumbers-rails/test/sandbox/app/views/components/tabs.html.erb \
        stimulus-plumbers-rails/test/sandbox/app/views/components/tabs_panel.html.erb \
        stimulus-plumbers-rails/test/accessibility/components/tabs_accessibility_test.rb
git commit -m "$(cat <<'EOF'
test(rails): add accessibility coverage for sp_tabs (eager + lazy panels)

Covers initial render and the post-lazy-activation state (WAI-ARIA calls
out lazy content as a case where axe should be re-run after the panel
that triggers the fetch becomes visible).
EOF
)"
```

---

## Task 5: Profile card and sidebar nav doc recipes (no new code)

**Files:**
- Modify: `stimulus-plumbers-rails/docs/guide.md`

**Interfaces:**
- Consumes: `sp_card`, `sp_avatar`, `sp_link` (profile card recipe); `sp_list` with `active:` (sidebar nav recipe) — all pre-existing, unchanged.
- Produces: nothing code-facing. This task adds a new `## Composing a settings/profile page` section to the guide.

**Why no test step:** this task adds zero new Ruby/JS code — it only documents existing, already-tested components composed together. There is no new behavior to assert; `sp_card`, `sp_avatar`, `sp_link`, and `sp_list`'s `active:` → `aria-current="page"` wiring are already covered by their own component test suites (verified in Task exploration: `active:` → `aria-current="page"` is implemented and tested in `components/list/item.rb`'s `render_link_or_button`). Adding a doc-only recipe cannot regress or newly break anything a test could catch; the "test" for this task is a manual proofread of the rendered markdown and a check that every helper/option named actually exists (done in step 1 below).

### Steps

1. Before writing, verify every helper option referenced actually exists (avoids documenting an invented API):

```bash
cd stimulus-plumbers-rails && grep -n "def sp_card\|def with_title\|def with_action" lib/stimulus_plumbers/components/card/slots.rb lib/stimulus_plumbers/helpers/card_helper.rb
grep -n "def sp_avatar" lib/stimulus_plumbers/helpers/avatar_helper.rb
grep -n "def sp_link" lib/stimulus_plumbers/helpers/link_helper.rb
grep -n "active" lib/stimulus_plumbers/components/list/item.rb
```

2. Add a new section to `stimulus-plumbers-rails/docs/guide.md`, right after the `## Stimulus integration` section and before `## CSS entry file detection`:

```markdown
## Composing a settings/profile page

These are pure compositions of existing components — no new helpers, no new behavior.

### Profile summary card

`sp_card` wrapping `sp_avatar`, a name/heading, and an `sp_link` edit action:

\`\`\`erb
<%= sp_card do |card| %>
  <% card.with_title(current_user.name) %>
  <% card.with_body do %>
    <%= sp_avatar(src: current_user.avatar_url, alt: current_user.name) %>
  <% end %>
  <% card.with_action("Edit profile", url: edit_profile_path) %>
<% end %>
\`\`\`

See [docs/component/card.md](component/card.md), [docs/component/avatar.md](component/avatar.md),
and [docs/component/link.md](component/link.md) for each component's full option list.

### Sidebar settings nav

`sp_list` with `active:` set on the current section's item — this already renders
`aria-current="page"` on the active item's link (see [docs/component/list.md](component/list.md));
no behavior change is needed, this is purely a usage example:

\`\`\`erb
<%= sp_list do |list| %>
  <% list.with_item("Profile",       url: settings_profile_path,       active: current_page?(settings_profile_path)) %>
  <% list.with_item("Password",      url: settings_password_path,      active: current_page?(settings_password_path)) %>
  <% list.with_item("Notifications", url: settings_notifications_path, active: current_page?(settings_notifications_path)) %>
<% end %>
\`\`\`
```

Before finalizing, confirm `sp_list`'s item DSL method name (`with_item` vs something else) and its exact keyword for the URL/active options by reading `stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb` and `stimulus-plumbers-rails/docs/component/list.md`, and correct the snippet above to match exactly — do not guess.

3. Run the docs formatter check:

```bash
cd stimulus-plumbers && npm run format:docs:check
```

If it reformats `guide.md`, run `npm run format:docs` and re-check.

4. Commit:

```bash
git add stimulus-plumbers-rails/docs/guide.md
git commit -m "$(cat <<'EOF'
doc(rails): add settings/profile page composition recipes

Profile summary card and sidebar settings nav are pure compositions of
existing sp_card/sp_avatar/sp_link/sp_list — no new code.
EOF
)"
```

---

## Self-Review

### 1. Spec coverage

| Spec section | Task |
| --- | --- |
| Part 1 — Profile summary card | Task 5 |
| Part 2 — Sidebar settings nav | Task 5 |
| Part 3 — `Form::Builder#section` (design, testing, docs) | Task 1 |
| Part 4 — Tabs: design, targets, methods, dispatches | Task 2 (controller) |
| Part 4 — Tabs: Rails helper, `lazy:`/`src:` | Task 3 |
| Part 4 — Tabs: theme keys | Task 3, step 1–2 |
| Part 4 — Tabs: JS unit test coverage | Task 2, step 1 |
| Part 4 — Tabs: Rails component unit test coverage | Task 3, step 3 |
| Part 4 — Tabs: accessibility test (incl. post-lazy-activation state) | Task 4 |
| Part 4 — Tabs: docs (JS + Rails, README rows) | Task 2 steps 7–8; Task 3 steps 12–13 |
| "Why automatic activation + lazy panels aren't in tension" | Reproduced in Task 2's `docs/component/tabs.md` (step 8) |
| Out-of-scope items (manual activation, drag/closable/dynamic/nested tabs, `f.section` layout options) | Called out explicitly in Global Constraints; no task implements them |

Gap found and closed: the spec's Rails helper example uses `settings_password_path`/`settings_notifications_path`, real app routes that don't exist in the sandbox. Closed by using a real sandbox route (`/components/display/tabs/panel`) in Task 4 instead of inventing undefined path helpers.

Gap found and closed: the spec doesn't say whether `Form::Builder#section` needs a new theme key. Closed by mirroring `Fields::Fieldset`'s existing behavior (verified: it has zero `theme.resolve` call on the `<fieldset>` tag itself) — Task 1 adds no new theme key, consistent with existing convention and the spec's "no new ARIA behavior beyond native fieldset/legend" note.

Gap found and closed: the spec's Tabs "Methods" list doesn't mention a click-event adapter, but `select(index)` (raw value) can't itself be a `data-action` target that also receives a click `Event`. Closed in Task 2 by adding `onTabClick(event)` as an adapter, per this JS package's own documented "Method naming convention" (`onX(event)` extracts payload, calls `x(value)`) — noted explicitly in Task 2's implementation step so this isn't mistaken for scope creep.

### 2. Placeholder scan

Searched this plan for "TBD", "similar to Task", "add appropriate error handling", undefined types — none found. Every task has full, runnable code (controller, component, builder, helper, schema, tests, docs). Task 5's steps include a live `grep` verification step instead of asserting unverified helper names, and explicitly instruct the implementer to correct the `sp_list` snippet against the real source rather than leaving it approximate.

### 3. Type consistency

- `RovingTabIndex` constructor options (`orientation`, `initialIndex`, `wrap`) and methods (`.activate()`, `.setCurrentIndex(index)`, `.currentIndex`, `.deactivate()`) are used identically in Task 2 as in the real `stimulus-plumbers/src/accessibility/keyboard.js` (confirmed by reading the file — no invented methods).
- `tabs_controller.js`'s target names (`tab`, `panel`), value name (`active` → `data-tabs-active-value`), and dispatched event (`tabs:changed` with `{ index, tabId, panelId }`) are identical across Task 2 (JS test + controller + doc) and Task 3 (Rails component's emitted `data-tabs-target`, `aria-controls`/`aria-labelledby`, and `data-tabs-active-value` attributes) and Task 4 (accessibility test assertions).
- `Tabs::Builder::Tab` struct fields (`title`, `lazy`, `src`, `block`, `tab_id`, `panel_id`) are used consistently between `builder.rb` (produces) and `tabs.rb` (consumes: `tab.title`, `tab.tab_id`, `tab.panel_id`, `tab.content(template)`).
- `f.section(title, **kwargs, &block)` signature is identical across Task 1's test calls (`f.section("Profile") { ... }`) and its `builder.rb` implementation.
