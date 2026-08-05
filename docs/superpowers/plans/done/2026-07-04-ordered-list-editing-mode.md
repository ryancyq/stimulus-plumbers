# OrderedList + reorderable editing mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an `editingValue`/`trigger`-target gating mode to the `reorderable` JS controller, then build `OrderedList` — a new, flat-only Rails component (sibling to `List`) that is the first real consumer of `reorderable`.

**Architecture:** Part 1 (JS, `stimulus-plumbers/`) adds a Boolean `editingValue` to `ReorderableController` that gates all drag/keyboard-move handling, so any `<a>`/`<button>` inside a reorderable item is free to work normally outside editing mode. Part 2 (Rails, `stimulus-plumbers-rails/`) adds `OrderedList`/`OrderedList::Item`/`sp_ordered_list`, duplicating `List::Item`'s icon/title/description rendering (not sharing a mixin — explicit choice) but with a DOM shape where the drag handle is always a sibling of the `<a>`/`<button>`, never nested inside it.

**Tech Stack:** Vanilla JS + Stimulus (Part 1), Ruby/Rails + Minitest + Capybara/axe-core (Part 2).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-04-ordered-list-editing-mode-design.md` — read before starting if any task is unclear.
- JS: `import` statements must not end in `.js`. Lint (`node --run lint`) and tests (`node --run test`) run synchronously from `stimulus-plumbers/` — never background or tail.
- Rails: lint (`bundle exec rake rubocop`) and tests (`bundle exec rake test:unit`) run synchronously from `stimulus-plumbers-rails/` — never background or tail.
- Doc Update Rule: any change to a documented API (targets, values, actions, options, HTML structure) updates the relevant `docs/**/*.md` in the same commit as the code change. JS controller API docs live only in `stimulus-plumbers/docs/`; Rails helper docs live only in `stimulus-plumbers-rails/docs/` and link to the JS docs rather than repeating them.
- New exported Rails helper (`sp_ordered_list`) gets a row in `stimulus-plumbers-rails/README.md`'s Components table and a `docs/component/ordered_list.md` file, in the same commit that adds it.
- No comments restating WHAT code does — only WHY, and only when non-obvious.
- `id:` is required on `OrderedList::Item` — raises `ArgumentError` if missing (per spec: `Reorderable#orderedIds()` silently drops items without an `id`, and this component fails loud instead).
- No `handle: false` — every `OrderedList` item always has a pointer surface; `handle:` is `:item` (default) | `:leading` | `:trailing`.
- `OrderedList` has no `section` method — sections are structurally impossible, not runtime-guarded.

All JS commands assume working directory `/Users/ryanchang/Documents/Github/stimulus-plumbers/stimulus-plumbers`. All Rails commands assume working directory `/Users/ryanchang/Documents/Github/stimulus-plumbers/stimulus-plumbers-rails`.

---

## Part 1: `reorderable` editing mode (JS)

### Task 1: Gate `Reorderable#onKeydown` on `controller.editingValue`

**Files:**
- Modify: `src/plumbers/reorderable.js`
- Test: `tests/unit/plumbers/reorderable.test.js`

**Interfaces:**
- Consumes: `this.controller` (already set by the base `Plumber` class constructor — no new plumbing needed).
- Produces: `Reorderable#onKeydown` no-ops entirely (no `preventDefault`, no swap, no dispatch) when `this.controller.editingValue` is falsy.

- [ ] **Step 1: Add `editingValue: true` to the existing mock controller so current tests keep representing "editing" state**

In `tests/unit/plumbers/reorderable.test.js`, in the `beforeEach` block, change:

```js
    mockController = {
      identifier: 'reorderable',
      element: document.getElementById('list'),
      // Getter, not a static array — mirrors Stimulus's real `itemTargets`, which
      // re-queries the DOM on every access. A plain array here would never reflect
      // the `.before()`/`.after()` DOM mutations the plumber performs.
      get itemTargets() {
        return Array.from(document.querySelectorAll('#list li'));
      },
      dispatch: vi.fn((name, options) => true),
      moved: vi.fn(),
    };
```

to:

```js
    mockController = {
      identifier: 'reorderable',
      element: document.getElementById('list'),
      editingValue: true,
      // Getter, not a static array — mirrors Stimulus's real `itemTargets`, which
      // re-queries the DOM on every access. A plain array here would never reflect
      // the `.before()`/`.after()` DOM mutations the plumber performs.
      get itemTargets() {
        return Array.from(document.querySelectorAll('#list li'));
      },
      dispatch: vi.fn((name, options) => true),
      moved: vi.fn(),
    };
```

- [ ] **Step 2: Write the failing test**

Add this test inside the `describe('keyboard move via attachItem', ...)` block, after the existing `'ignores plain ArrowDown without the modifier'` test:

```js
    it('does nothing when controller.editingValue is false', () => {
      mockController.editingValue = false;
      const reorderable = new Reorderable(mockController);
      items.forEach((item) => reorderable.attachItem(item));

      items[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(mockController.itemTargets.map((i) => i.id)).toEqual(['row-a', 'row-b', 'row-c']);
      expect(mockController.dispatch).not.toHaveBeenCalled();
    });
```

- [ ] **Step 3: Run tests to verify the new test fails and existing ones still pass**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: the new test FAILS (items still reorder — `onKeydown` doesn't check `editingValue` yet); all other tests still PASS (mock now has `editingValue: true`).

- [ ] **Step 4: Implement the gate**

In `src/plumbers/reorderable.js`, change:

```js
  onKeydown(event) {
    if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;
```

to:

```js
  onKeydown(event) {
    if (!this.controller.editingValue) return;
    if (event.key !== 'ArrowUp' && event.key !== 'ArrowDown') return;
    if (!event[MODIFIER_KEYS[this.moveKey]]) return;
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `node --run test -- tests/unit/plumbers/reorderable.test.js`
Expected: PASS, all tests green.

- [ ] **Step 6: Lint**

Run: `node --run lint`
Expected: no errors.

- [ ] **Step 7: Commit**

```bash
git add src/plumbers/reorderable.js tests/unit/plumbers/reorderable.test.js
git commit -m "$(cat <<'EOF'
feat: gate Reorderable keyboard move on controller.editingValue

Prepares the plumber for the controller's upcoming editing-mode
toggle — Alt+Arrow only moves an item while editingValue is true.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 2: Add `editingValue`/`trigger`/toggle actions to `ReorderableController`, gate pointer handlers, update JS docs

**Files:**
- Modify: `src/controllers/reorderable_controller.js`
- Test: `tests/unit/controllers/reorderable_controller.test.js`
- Modify: `docs/component/reorderable.md`
- Modify: `docs/plumber/reorderable.md`

**Interfaces:**
- Consumes: `setDisabled(element, disabled)` from `src/accessibility/aria.js` (existing helper — sets `aria-disabled` and toggles `tabindex="-1"`).
- Produces: `editingValue` Boolean Stimulus value (default `false`); `trigger` target; `toggleEditing()`/`enterEditing()`/`exitEditing()` controller methods; `onPointerDown`/`onPointerMove`/`onPointerUp` no-op when `!this.editingValue`.

- [ ] **Step 1: Update the shared test fixture so existing drag/keyboard-move tests keep passing**

In `tests/unit/controllers/reorderable_controller.test.js`, change:

```js
  const buildHTML = () => `
    <ul data-controller="reorderable">
```

to:

```js
  const buildHTML = () => `
    <ul data-controller="reorderable" data-reorderable-editing-value="true">
```

- [ ] **Step 2: Write the failing tests for editing-mode gating and toggling**

Add this new `describe` block at the end of the file, just before the final closing `});`:

```js
  describe('editing mode', () => {
    const buildEditingHTML = (editing) => `
      <ul data-controller="reorderable" data-reorderable-editing-value="${editing}">
        <li id="row-a" data-reorderable-target="item" tabindex="0">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>
          <a href="/a" data-reorderable-target="trigger">A</a>
        </li>
        <li id="row-b" data-reorderable-target="item" tabindex="-1">
          <span data-reorderable-target="handle" data-action="${HANDLE_ACTIONS}">::</span>
          <a href="/b" data-reorderable-target="trigger">B</a>
        </li>
      </ul>
    `;

    it('defaults to not editing — Alt+Arrow does not reorder', async () => {
      const element = await setup(buildEditingHTML(false));
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      items()[0].focus();

      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );

      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-a', 'row-b']);
    });

    it('defaults to not editing — pointer drag does not reorder', async () => {
      const element = await setup(buildEditingHTML(false));
      const items = element.querySelectorAll('[data-reorderable-target="item"]');
      items.forEach((item, i) => {
        item.getBoundingClientRect = () => ({
          top: i * 40, bottom: i * 40 + 40, height: 40, left: 0, right: 100, width: 100, x: 0, y: i * 40,
        });
      });
      const handle = items[0].querySelector('[data-reorderable-target="handle"]');
      handle.setPointerCapture = vi.fn();
      handle.releasePointerCapture = vi.fn();

      handle.dispatchEvent(new PointerEvent('pointerdown', { pointerId: 1, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointermove', { pointerId: 1, clientY: 61, bubbles: true }));
      handle.dispatchEvent(new PointerEvent('pointerup', { pointerId: 1, bubbles: true }));

      const reordered = element.querySelectorAll('[data-reorderable-target="item"]');
      expect(Array.from(reordered).map((i) => i.id)).toEqual(['row-a', 'row-b']);
    });

    it('sets aria-disabled=false on triggers initially, toggleEditing enables reordering and disables triggers', async () => {
      const element = await setup(buildEditingHTML(false));
      const controller = application.getControllerForElementAndIdentifier(element, 'reorderable');
      const items = () => element.querySelectorAll('[data-reorderable-target="item"]');
      const triggers = () => element.querySelectorAll('[data-reorderable-target="trigger"]');

      expect(triggers()[0].getAttribute('aria-disabled')).toBe('false');

      controller.toggleEditing();

      expect(triggers()[0].getAttribute('aria-disabled')).toBe('true');
      expect(triggers()[0].tabIndex).toBe(-1);

      items()[0].focus();
      items()[0].dispatchEvent(
        new KeyboardEvent('keydown', { key: 'ArrowDown', altKey: true, bubbles: true, cancelable: true })
      );
      expect(Array.from(items()).map((i) => i.id)).toEqual(['row-b', 'row-a']);
    });

    it('enterEditing/exitEditing set editingValue explicitly', async () => {
      const element = await setup(buildEditingHTML(false));
      const controller = application.getControllerForElementAndIdentifier(element, 'reorderable');

      controller.enterEditing();
      expect(controller.editingValue).toBe(true);

      controller.exitEditing();
      expect(controller.editingValue).toBe(false);
    });
  });
```

- [ ] **Step 3: Run tests to verify the new tests fail and note which existing tests break**

Run: `node --run test -- tests/unit/controllers/reorderable_controller.test.js`
Expected: the four new tests FAIL (no `editingValue`/`trigger`/toggle methods exist yet — `application.getControllerForElementAndIdentifier` calls will error or the controller won't recognize `editing-value`/`trigger` attributes). Existing tests should still PASS since `buildHTML()` now sets `data-reorderable-editing-value="true"` but the controller doesn't declare that value yet, so the attribute is simply inert HTML for now — this is expected and resolves once Step 4 lands.

- [ ] **Step 4: Implement the controller changes**

Replace the full contents of `src/controllers/reorderable_controller.js` with:

```js
import { Controller } from '@hotwired/stimulus';
import { RovingTabIndex } from '../accessibility/keyboard';
import { setDisabled } from '../accessibility/aria';
import { attachReorderable } from '../plumbers';

export default class extends Controller {
  static targets = ['item', 'handle', 'trigger'];
  static values = {
    moveKey: { type: String, default: 'Alt' },
    editing: { type: Boolean, default: false },
  };

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

  itemTargetConnected(item) {
    this.reorderable?.attachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  itemTargetDisconnected(item) {
    this.reorderable?.detachItem(item);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  editingValueChanged(value) {
    this.triggerTargets.forEach((trigger) => setDisabled(trigger, value));
  }

  toggleEditing() {
    this.editingValue = !this.editingValue;
  }

  enterEditing() {
    this.editingValue = true;
  }

  exitEditing() {
    this.editingValue = false;
  }

  onPointerDown(event) {
    if (!this.editingValue) return;
    const item = event.currentTarget.closest('[data-reorderable-target~="item"]');
    if (!item) return;
    this.reorderable.startDrag(item, event.currentTarget, event.pointerId);
  }

  onPointerMove(event) {
    if (!this.editingValue) return;
    this.reorderable.drag(event.clientY);
  }

  onPointerUp(event) {
    if (!this.editingValue) return;
    this.reorderable.endDrag(event.currentTarget, event.pointerId);
    this.rovingTabIndex?.updateItems(this.itemTargets);
  }

  moved(item) {
    this.rovingTabIndex?.updateItems(this.itemTargets);
    this.rovingTabIndex.setCurrentIndex(this.itemTargets.indexOf(item));
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `node --run test -- tests/unit/controllers/reorderable_controller.test.js`
Expected: PASS, all tests green (existing + 4 new).

- [ ] **Step 6: Run the full JS test suite and lint**

Run: `node --run test && node --run lint`
Expected: PASS, no errors.

- [ ] **Step 7: Update `docs/component/reorderable.md`**

Change the Targets table from:

```markdown
## Targets

| Name     | Element                                     | Purpose                                                                            |
| -------- | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| `item`   | Each reorderable row (`<li>`, `<tr>`, etc.)  | Must have a stable `id` to appear in the `reorderable:reordered` event's `itemIds`   |
| `handle` | Drag grip within each `item`                 | The only pointer-drag surface — wire `pointerdown`/`pointermove`/`pointerup` to it   |
```

to:

```markdown
## Targets

| Name      | Element                                     | Purpose                                                                            |
| --------- | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| `item`    | Each reorderable row (`<li>`, `<tr>`, etc.)  | Must have a stable `id` to appear in the `reorderable:reordered` event's `itemIds`   |
| `handle`  | Drag grip within each `item`                 | The only pointer-drag surface — wire `pointerdown`/`pointermove`/`pointerup` to it   |
| `trigger` | The `<a>`/`<button>` inside an item, if any  | Neutralized (via `aria-disabled`/`tabindex`) while `editingValue` is `true`         |
```

Change the Values table from:

```markdown
## Values

| Name      | Type   | Default | Purpose                                                                                                                        |
| --------- | ------ | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `moveKey` | String | `"Alt"` | Modifier key that, combined with `ArrowUp`/`ArrowDown` on a focused item, moves it. One of `Alt`, `Control`, `Shift`, `Meta`. |
```

to:

```markdown
## Values

| Name         | Type    | Default | Purpose                                                                                                                        |
| ------------ | ------- | ------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `moveKey`    | String  | `"Alt"` | Modifier key that, combined with `ArrowUp`/`ArrowDown` on a focused item, moves it. One of `Alt`, `Control`, `Shift`, `Meta`. |
| `editing`    | Boolean | `false` | While `true`, pointer drag and `Alt+Arrow` move are active and every `trigger` target is neutralized. While `false`, drag/keyboard-move are inert no-ops and every `trigger` behaves normally. Plain Arrow/Home/End focus movement is unaffected either way. |
```

Change the Actions table from:

```markdown
## Actions

| Name           | Purpose                                                                       |
| -------------- | -------------------------------------------------------------------------------- |
| `onPointerDown`| Wire to `pointerdown` on the `handle` target — starts a drag                     |
| `onPointerMove`| Wire to `pointermove` on the `handle` target — live-reorders while dragging       |
| `onPointerUp`  | Wire to `pointerup` on the `handle` target — ends the drag                        |
```

to:

```markdown
## Actions

| Name             | Purpose                                                                       |
| ---------------- | -------------------------------------------------------------------------------- |
| `onPointerDown`  | Wire to `pointerdown` on the `handle` target — starts a drag (no-op unless `editingValue`) |
| `onPointerMove`  | Wire to `pointermove` on the `handle` target — live-reorders while dragging (no-op unless `editingValue`) |
| `onPointerUp`    | Wire to `pointerup` on the `handle` target — ends the drag (no-op unless `editingValue`) |
| `toggleEditing`  | Flips `editingValue` — wire to e.g. `click->reorderable#toggleEditing` on an app-provided Edit/Done button |
| `enterEditing`   | Sets `editingValue` to `true` explicitly                                         |
| `exitEditing`    | Sets `editingValue` to `false` explicitly                                        |
```

Add a new bullet to the `## Notes` list, after the existing four bullets:

```markdown
- Pointer clicks on a `trigger` are not blocked by JS — `editingValueChanged` only handles the keyboard/AT half (`aria-disabled` + `tabindex`) via `setDisabled()`. Apps/themes must add their own CSS rule to block pointer clicks while editing, e.g. `[data-reorderable-editing-value="true"] [data-reorderable-target="trigger"] { pointer-events: none }` — keeps the controller content-agnostic about link/button internals.
```

- [ ] **Step 8: Update `docs/plumber/reorderable.md`**

Change the opening paragraph from:

```markdown
Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system. Composes safely with a separately-instantiated `RovingTabIndex` on the same items regardless of attach order — `RovingTabIndex` ignores modified arrow keys by default (see `docs/accessibility/design.md`), so `Alt+Arrow` (or whichever `moveKey` is configured) never reaches it as plain focus movement.
```

to:

```markdown
Pointer-drag and keyboard-move state machine for reordering a list of elements. Extends `Plumber`. Attaches its own `keydown` listener directly to each item (via `attachItem`/`detachItem`), independent of Stimulus's `data-action` system. Composes safely with a separately-instantiated `RovingTabIndex` on the same items regardless of attach order — `RovingTabIndex` ignores modified arrow keys by default (see `docs/accessibility/design.md`), so `Alt+Arrow` (or whichever `moveKey` is configured) never reaches it as plain focus movement. Keyboard moves only apply while the controller's `editingValue` is `true` — see [docs/component/reorderable.md](../component/reorderable.md) for the full editing-mode contract.
```

- [ ] **Step 9: Commit**

```bash
git add src/controllers/reorderable_controller.js tests/unit/controllers/reorderable_controller.test.js docs/component/reorderable.md docs/plumber/reorderable.md
git commit -m "$(cat <<'EOF'
feat: add editing mode to ReorderableController

Adds editingValue (Boolean, default false) and a trigger target.
Pointer drag and keyboard move are inert no-ops unless editingValue
is true; toggleEditing/enterEditing/exitEditing control it.
editingValueChanged neutralizes every trigger's keyboard activation
via the existing setDisabled() helper. This lets a reorderable item
contain a real <a>/<button> that works normally outside editing mode.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Part 2: `OrderedList` Rails component

### Task 3: `OrderedList` theme schema keys

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/themes/base_test.rb`

**Interfaces:**
- Produces: `StimulusPlumbers::Themes::Schema::ORDERED_LIST` constant; `StimulusPlumbers::Themes::Base::SCHEMA` includes keys `:ordered_list`, `:ordered_list_item`, `:ordered_list_item_handle`, `:ordered_list_item_content`, `:ordered_list_item_title`, `:ordered_list_item_description`.

- [ ] **Step 1: Write the failing test**

In `test/stimulus_plumbers/themes/base_test.rb`, add this test method after `test_attribute_names_returns_keys_for_known_component`:

```ruby
  def test_schema_includes_ordered_list_keys
    %i[ordered_list ordered_list_item ordered_list_item_handle ordered_list_item_content
       ordered_list_item_title ordered_list_item_description].each do |key|
      assert StimulusPlumbers::Themes::Base::SCHEMA.key?(key), "expected SCHEMA to include #{key}"
    end
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/themes/base_test.rb`
Expected: FAIL — `ordered_list` etc. not present in `SCHEMA`.

- [ ] **Step 3: Add the `ORDERED_LIST` schema constant**

In `lib/stimulus_plumbers/themes/schema.rb`, change:

```ruby
      LIST = {
        list:                     {}.freeze,
        list_section:             {}.freeze,
        list_section_title:       {}.freeze,
        list_section_description: {}.freeze,
        list_item:                {}.freeze,
        list_item_icon:           {}.freeze,
        list_item_content:        {}.freeze,
        list_item_title:          {}.freeze,
        list_item_description:    {}.freeze
      }.freeze

      AVATAR = {
```

to:

```ruby
      LIST = {
        list:                     {}.freeze,
        list_section:             {}.freeze,
        list_section_title:       {}.freeze,
        list_section_description: {}.freeze,
        list_item:                {}.freeze,
        list_item_icon:           {}.freeze,
        list_item_content:        {}.freeze,
        list_item_title:          {}.freeze,
        list_item_description:    {}.freeze
      }.freeze

      ORDERED_LIST = {
        ordered_list:                   {}.freeze,
        ordered_list_item:              {}.freeze,
        ordered_list_item_handle:       {}.freeze,
        ordered_list_item_content:      {}.freeze,
        ordered_list_item_title:        {}.freeze,
        ordered_list_item_description:  {}.freeze
      }.freeze

      AVATAR = {
```

- [ ] **Step 4: Merge it into `Base::SCHEMA`**

In `lib/stimulus_plumbers/themes/base.rb`, change:

```ruby
      SCHEMA = {
        **Schema::LIST,
        **Schema::AVATAR,
```

to:

```ruby
      SCHEMA = {
        **Schema::LIST,
        **Schema::ORDERED_LIST,
        **Schema::AVATAR,
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/themes/base_test.rb`
Expected: PASS.

- [ ] **Step 6: Rubocop autocorrect for hash alignment, then verify**

Run: `bundle exec rubocop -a lib/stimulus_plumbers/themes/schema.rb lib/stimulus_plumbers/themes/base.rb && bundle exec rake rubocop`
Expected: no offenses.

- [ ] **Step 7: Commit**

```bash
git add lib/stimulus_plumbers/themes/schema.rb lib/stimulus_plumbers/themes/base.rb test/stimulus_plumbers/themes/base_test.rb
git commit -m "$(cat <<'EOF'
feat: add OrderedList theme schema keys

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: `OrderedList::Item::Slots` and `OrderedList::Item`

**Files:**
- Create: `lib/stimulus_plumbers/components/ordered_list/item/slots.rb`
- Create: `lib/stimulus_plumbers/components/ordered_list/item.rb`
- Test: `test/stimulus_plumbers/components/ordered_list/item_test.rb`

**Interfaces:**
- Consumes: `Plumber::Base`, `Plumber::Slots`, `Components::Icon` (existing).
- Produces: `StimulusPlumbers::Components::OrderedList::Item#render(content = nil, id:, handle: :item, url: nil, target: nil, active: false, **html_options, &block)` — used by Task 5's `OrderedList#item`.

- [ ] **Step 1: Write the failing tests**

Create `test/stimulus_plumbers/components/ordered_list/item_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class OrderedListItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::OrderedList::Item.new(self)
  end

  def test_raises_without_id
    assert_raises(ArgumentError) { renderer.render("Row") }
  end

  def test_renders_li_with_item_target_and_id
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_css doc, "li#row-1[data-reorderable-target~='item']"
  end

  def test_default_handle_is_item_wired_on_li
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_css doc, "li[data-reorderable-target~='handle']"
    assert_css doc, "li[data-action*='reorderable#onPointerDown']"
  end

  def test_handle_leading_wires_leading_span_not_li
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :leading))

    assert_no_css doc, "li[data-reorderable-target~='handle']"
    assert_css    doc, "span[data-reorderable-target='handle']"
  end

  def test_handle_trailing_wires_trailing_span_not_li
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :trailing))

    assert_no_css doc, "li[data-reorderable-target~='handle']"
    assert_css    doc, "span[data-reorderable-target='handle']"
  end

  def test_handle_leading_uses_custom_icon_when_icon_leading_set
    doc = parse_html(
      renderer.render("Row", id: "row-1", handle: :leading) { |slots| slots.with_icon_leading(:star) }
    )

    assert_css doc, "span[data-reorderable-target='handle'] svg"
  end

  def test_icon_positions_are_siblings_of_link_not_nested_inside
    doc = parse_html(
      renderer.render("Row", id: "row-1", url: "/x", handle: :leading) { |slots| slots.with_icon_leading(:star) }
    )

    assert_css doc, "li > span[data-reorderable-target='handle'] + a"
  end

  def test_trigger_target_present_when_url_given
    doc = parse_html(renderer.render("Row", id: "row-1", url: "/x"))

    assert_css doc, "a[data-reorderable-target='trigger'][href='/x']"
  end

  def test_no_wrapper_or_trigger_target_without_url
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_no_css doc, "a"
    assert_no_css doc, "button"
    assert_includes doc.text, "Row"
  end

  def test_title_and_description_render_inside_link
    doc = parse_html(
      renderer.render(id: "row-1", url: "/x") do |slots|
        slots.with_title("Title")
        slots.with_description("Description")
      end
    )

    assert_css doc, "a span"
    assert_includes doc.text, "Title"
    assert_includes doc.text, "Description"
  end

  def test_no_icon_span_rendered_when_position_unused_and_not_handle
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :leading))

    assert_css doc, "li > *:nth-child(1)[data-reorderable-target='handle']"
    # trailing position: no icon_trailing set and it's not the handle — nothing rendered there
    assert_equal 2, parse_html(renderer.render("Row", id: "row-1", handle: :leading)).css("li > *").size
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/components/ordered_list/item_test.rb`
Expected: FAIL — `StimulusPlumbers::Components::OrderedList` doesn't exist yet (`NameError`).

- [ ] **Step 3: Create the slots class**

Create `lib/stimulus_plumbers/components/ordered_list/item/slots.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList
      class Item
        class Slots < Plumber::Slots
          slot :icon_leading, :title, :description, :icon_trailing
        end
      end
    end
  end
end
```

- [ ] **Step 4: Create the item renderer**

Create `lib/stimulus_plumbers/components/ordered_list/item.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList
      class Item < Plumber::Base
        HANDLE_ACTION = "pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove " \
                         "pointerup->reorderable#onPointerUp"

        def render(content = nil, id:, handle: :item, url: nil, target: nil, active: false, **html_options, &block)
          raise ArgumentError, "id: is required so the item appears in reorderable:reordered's itemIds" if id.blank?

          @handle = handle
          slots = OrderedList::Item::Slots.new(template)
          slots.with_title(content) if content
          yield slots if block_given?

          li_options = merge_html_options(theme.resolve(:ordered_list_item), { id: id }, item_target_attrs)

          template.content_tag(:li, **li_options) do
            template.safe_join(
              [
                render_icon_position(slots, :leading),
                render_body(slots, url: url, target: target, active: active, **html_options),
                render_icon_position(slots, :trailing)
              ]
            )
          end
        end

        private

        def item_target_attrs
          if @handle == :item
            { data: { "reorderable-target": "item handle", action: HANDLE_ACTION } }
          else
            { data: { "reorderable-target": "item" } }
          end
        end

        def render_body(slots, url:, target:, active:, **html_options)
          content = render_content_slot(slots)
          return content unless url.present?

          aria  = active ? { aria: { current: "page" } } : {}
          attrs = merge_html_options(html_options, { data: { "reorderable-target": "trigger" } }, aria)
          template.content_tag(:a, content, href: url, target: target, **attrs)
        end

        def render_icon_position(slots, position)
          slot_name   = position == :leading ? :icon_leading : :icon_trailing
          is_handle   = @handle == position
          custom_icon = render_icon_slot(slots, slot_name)
          return unless custom_icon || is_handle

          html_options = merge_html_options(theme.resolve(:ordered_list_item_handle), handle_target_attrs(is_handle))
          template.content_tag(:span, custom_icon || default_handle_icon, **html_options)
        end

        def handle_target_attrs(is_handle)
          return {} unless is_handle

          { data: { "reorderable-target": "handle", action: HANDLE_ACTION } }
        end

        def render_icon_slot(slots, name)
          slots.resolve(name) do |value|
            next value unless Components::Icon.icon_name?(value)

            Components::Icon.new(template).render(
              name:    value,
              classes: theme.resolve(:ordered_list_item_handle).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
        end

        def default_handle_icon
          Components::Icon.new(template).render(
            name:    "grip-vertical",
            classes: theme.resolve(:ordered_list_item_handle).fetch(:classes, ""),
            aria:    { hidden: "true" }
          )
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          template.content_tag(:span, **merge_html_options(theme.resolve(:ordered_list_item_content))) do
            template.safe_join([title, description])
          end
        end

        def render_title_slot(slots)
          slots.resolve(:title) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:ordered_list_item_title)))
          end
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:ordered_list_item_description)))
          end
        end
      end
    end
  end
end
```

Note: `OrderedList` itself (the enclosing class referenced by `class OrderedList; class Item; ...`) doesn't exist until Task 5 — Ruby allows reopening a not-yet-defined constant this way only if the outer `OrderedList` class is already loaded first. Since Zeitwerk autoloads by constant reference, `StimulusPlumbers::Components::OrderedList::Item` will autoload `ordered_list.rb` (defining `OrderedList < Plumber::Base`) before `ordered_list/item.rb` — but `ordered_list.rb` doesn't exist until Task 5. **This task will not fully load until Task 5 creates `lib/stimulus_plumbers/components/ordered_list.rb`.** Create a minimal stub now so Task 4's tests can run in isolation:

Create `lib/stimulus_plumbers/components/ordered_list.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList < Plumber::Base
    end
  end
end
```

(Task 5 replaces this stub's body with the real `render`/`item` methods — it does not create a new file.)

- [ ] **Step 5: Run tests to verify they pass**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/components/ordered_list/item_test.rb`
Expected: PASS, all tests green.

- [ ] **Step 6: Rubocop**

Run: `bundle exec rubocop lib/stimulus_plumbers/components/ordered_list.rb lib/stimulus_plumbers/components/ordered_list/item.rb lib/stimulus_plumbers/components/ordered_list/item/slots.rb test/stimulus_plumbers/components/ordered_list/item_test.rb`
Expected: no offenses (run `rubocop -a` on the same paths first if any surface, then re-check).

- [ ] **Step 7: Commit**

```bash
git add lib/stimulus_plumbers/components/ordered_list.rb lib/stimulus_plumbers/components/ordered_list/item.rb lib/stimulus_plumbers/components/ordered_list/item/slots.rb test/stimulus_plumbers/components/ordered_list/item_test.rb
git commit -m "$(cat <<'EOF'
feat: add OrderedList::Item renderer

Icon positions (leading/trailing) are always siblings of the <a>,
never nested inside it — the structural fix motivating OrderedList
as a separate component from List. handle: :item (default) wires
the whole <li> as the drag surface; :leading/:trailing wire a
specific icon position instead, falling back to a default grip
glyph when no custom icon is set there. id: is required.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 5: `OrderedList` renderer, `sp_ordered_list` helper

**Files:**
- Modify: `lib/stimulus_plumbers/components/ordered_list.rb` (replace Task 4's stub)
- Create: `lib/stimulus_plumbers/helpers/ordered_list_helper.rb`
- Modify: `lib/stimulus_plumbers/helpers.rb`
- Test: `test/stimulus_plumbers/components/ordered_list_test.rb`
- Test: `test/stimulus_plumbers/helpers/ordered_list_helper_test.rb`

**Interfaces:**
- Consumes: `OrderedList::Item#render` (Task 4).
- Produces: `sp_ordered_list(move_key: "Alt", editing: false, **html_options, &block)`, `OrderedList#item(...)` delegating to `OrderedList::Item#render`.

- [ ] **Step 1: Write the failing tests**

Create `test/stimulus_plumbers/components/ordered_list_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class OrderedListComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::OrderedList.new(self)
  end

  def test_renders_ol
    assert_css parse_html(renderer.render { "" }), "ol"
  end

  def test_wires_reorderable_controller
    assert_css parse_html(renderer.render { "" }), "ol[data-controller='reorderable']"
  end

  def test_default_move_key_is_alt
    assert_css parse_html(renderer.render { "" }), "ol[data-reorderable-move-key-value='Alt']"
  end

  def test_move_key_can_be_overridden
    assert_css parse_html(renderer.render(move_key: "Control") { "" }), "ol[data-reorderable-move-key-value='Control']"
  end

  def test_editing_defaults_to_false
    assert_css parse_html(renderer.render { "" }), "ol[data-reorderable-editing-value='false']"
  end

  def test_editing_can_be_enabled
    assert_css parse_html(renderer.render(editing: true) { "" }), "ol[data-reorderable-editing-value='true']"
  end

  def test_item_convenience_method_delegates_to_ordered_list_item
    doc = parse_html(renderer.item("Row", id: "row-1"))

    assert_css doc, "li#row-1"
  end

  def test_has_no_section_method
    refute_respond_to renderer, :section
  end
end
```

Create `test/stimulus_plumbers/helpers/ordered_list_helper_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class OrderedListHelperTest < ActionView::TestCase
  def test_sp_ordered_list_renders_ol_with_items
    doc = parse_html(sp_ordered_list { |list| list.item("Row", id: "row-1") })

    assert_css doc, "ol[data-controller='reorderable']"
    assert_css doc, "li#row-1"
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/components/ordered_list_test.rb`
Expected: FAIL — `OrderedList#render` is the empty stub from Task 4, doesn't accept a block/produce an `<ol>` yet.

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/helpers/ordered_list_helper_test.rb`
Expected: FAIL — `sp_ordered_list` undefined (`NoMethodError`).

- [ ] **Step 3: Implement `OrderedList`**

Replace the full contents of `lib/stimulus_plumbers/components/ordered_list.rb` with:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class OrderedList < Plumber::Base
      def render(move_key: "Alt", editing: false, **kwargs, &block)
        stimulus = {
          data: {
            controller:                    "reorderable",
            "reorderable-move-key-value":  move_key,
            "reorderable-editing-value":   editing
          }
        }
        html_options = merge_html_options(theme.resolve(:ordered_list), kwargs, stimulus)
        template.content_tag(:ol, template.capture(self, &block), **html_options)
      end

      def item(content = nil, **kwargs, &block)
        OrderedList::Item.new(template).render(content, **kwargs, &block)
      end
    end
  end
end
```

- [ ] **Step 4: Create the helper**

Create `lib/stimulus_plumbers/helpers/ordered_list_helper.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module OrderedListHelper
      def sp_ordered_list(...)
        Components::OrderedList.new(self).render(...)
      end
    end
  end
end
```

- [ ] **Step 5: Register the helper**

In `lib/stimulus_plumbers/helpers.rb`, change:

```ruby
require_relative "helpers/plumber_helper"
require_relative "helpers/icon_helper"
require_relative "helpers/list_helper"
require_relative "helpers/avatar_helper"
```

to:

```ruby
require_relative "helpers/plumber_helper"
require_relative "helpers/icon_helper"
require_relative "helpers/list_helper"
require_relative "helpers/ordered_list_helper"
require_relative "helpers/avatar_helper"
```

and change:

```ruby
    include PlumberHelper
    include IconHelper
    include ListHelper
    include AvatarHelper
```

to:

```ruby
    include PlumberHelper
    include IconHelper
    include ListHelper
    include OrderedListHelper
    include AvatarHelper
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/components/ordered_list_test.rb`
Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/components/ordered_list/item_test.rb`
Run: `bundle exec rake test:unit TEST=test/stimulus_plumbers/helpers/ordered_list_helper_test.rb`
Expected: PASS, all green (item_test.rb re-run here since it depended on Task 4's stub, which this task replaces — confirms nothing regressed).

- [ ] **Step 7: Rubocop**

Run: `bundle exec rubocop lib/stimulus_plumbers/components/ordered_list.rb lib/stimulus_plumbers/helpers/ordered_list_helper.rb lib/stimulus_plumbers/helpers.rb test/stimulus_plumbers/components/ordered_list_test.rb test/stimulus_plumbers/helpers/ordered_list_helper_test.rb`
Expected: no offenses.

- [ ] **Step 8: Commit**

```bash
git add lib/stimulus_plumbers/components/ordered_list.rb lib/stimulus_plumbers/helpers/ordered_list_helper.rb lib/stimulus_plumbers/helpers.rb test/stimulus_plumbers/components/ordered_list_test.rb test/stimulus_plumbers/helpers/ordered_list_helper_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_ordered_list helper

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 6: Sandbox view, accessibility tests, docs, README

**Files:**
- Modify: `test/sandbox/config/routes.rb`
- Modify: `test/sandbox/app/controllers/components_controller.rb`
- Create: `test/sandbox/app/views/components/ordered_list.html.erb`
- Create: `test/accessibility/components/ordered_list_accessibility_test.rb`
- Create: `docs/component/ordered_list.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: `sp_ordered_list` (Task 5).

- [ ] **Step 1: Add the route**

In `test/sandbox/config/routes.rb`, change:

```ruby
    get :list
    get :card
```

to:

```ruby
    get :list
    get :ordered_list
    get :card
```

- [ ] **Step 2: Add the controller action**

In `test/sandbox/app/controllers/components_controller.rb`, change:

```ruby
  def list; end

  def card; end
```

to:

```ruby
  def list; end

  def ordered_list; end

  def card; end
```

- [ ] **Step 3: Create the sandbox view**

Create `test/sandbox/app/views/components/ordered_list.html.erb`:

```erb
<h1>OrderedList components</h1>

<div id="ordered-list-default">
  <%# ── Whole-item handle (default), content-only rows ──────────────────── %>
  <%= sp_ordered_list do |list| %>
    <%= list.item("First", id: "item-1") %>
    <%= list.item("Second", id: "item-2") %>
    <%= list.item("Third", id: "item-3") %>
  <% end %>
</div>

<div id="ordered-list-with-links">
  <%# ── Links + a dedicated leading-icon handle, editing enabled ─────────── %>
  <%= sp_ordered_list(editing: true) do |list| %>
    <%= list.item(id: "link-1", url: "/", handle: :leading) do |slots| %>
      <% slots.with_title("Dashboard") %>
      <% slots.with_description("Overview") %>
    <% end %>
    <%= list.item(id: "link-2", url: "/", handle: :leading) do |slots| %>
      <% slots.with_title("Reports") %>
    <% end %>
  <% end %>
</div>

<div id="ordered-list-custom-handle-icon">
  <%# ── Custom icon reused as the handle ──────────────────────────────────── %>
  <%= sp_ordered_list do |list| %>
    <%= list.item("Track one", id: "track-1", handle: :leading) do |slots| %>
      <% slots.with_icon_leading(:star) %>
    <% end %>
    <%= list.item("Track two", id: "track-2", handle: :leading) do |slots| %>
      <% slots.with_icon_leading(:star) %>
    <% end %>
  <% end %>
</div>
```

- [ ] **Step 4: Write the accessibility test**

Create `test/accessibility/components/ordered_list_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class OrderedListAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/ordered_list"
  end

  def test_default_ordered_list_passes_wcag
    assert_accessible context: "#ordered-list-default"
  end

  def test_ordered_list_with_links_in_editing_state_passes_wcag
    assert_accessible context: "#ordered-list-with-links"
  end

  def test_ordered_list_custom_handle_icon_passes_wcag
    assert_accessible context: "#ordered-list-custom-handle-icon"
  end
end
```

- [ ] **Step 5: Run the accessibility tests**

Run: `bundle exec rake test:accessibility TEST=test/accessibility/components/ordered_list_accessibility_test.rb`
Expected: PASS, all three tests green. If any fail on an axe-core violation, read the reported HTML/rule id first (per this gem's CLAUDE.md a11y-violation convention) before changing anything.

- [ ] **Step 6: Write `docs/component/ordered_list.md`**

Create `docs/component/ordered_list.md`:

```markdown
# OrderedList

Rails helper for a flat, reorderable list — pointer-drag and keyboard reorder via the [`reorderable`](../../../stimulus-plumbers/docs/component/reorderable.md) JS controller. Unlike [`List`](list.md), item order is semantic content (`<ol>`, not `<ul>`), there are no sections, and every item has a pointer drag surface.

## Helper

### `sp_ordered_list`

```erb
<%# Whole-item handle (default), content-only rows %>
<%= sp_ordered_list do |list| %>
  <%= list.item("First", id: "item-1") %>
  <%= list.item("Second", id: "item-2") %>
<% end %>

<%# Links + a dedicated leading-icon handle, editing enabled %>
<%= sp_ordered_list(editing: true) do |list| %>
  <%= list.item(id: "link-1", url: "/", handle: :leading) do |item| %>
    <% item.with_title("Dashboard") %>
  <% end %>
<% end %>
```

| Option           | Default | Description                                                              |
| ---------------- | ------- | -------------------------------------------------------------------------- |
| `move_key:`      | `"Alt"` | Maps to `data-reorderable-move-key-value`. One of `Alt`, `Control`, `Shift`, `Meta`. |
| `editing:`       | `false` | Initial render-time state, maps to `data-reorderable-editing-value`.       |
| `**html_options` | —       | Forwarded to the outer `<ol>`.                                             |

### `list.item(content, id:, handle:, url:, target:, active:, **html_options, &block)`

| Option           | Default  | Description                                                                                  |
| ---------------- | -------- | ---------------------------------------------------------------------------------------------- |
| `content`        | `nil`    | Item label — positional arg or via `item.with_title`.                                          |
| `id:`            | —        | **Required.** Raises `ArgumentError` if missing.                                               |
| `handle:`        | `:item`  | `:item` (whole `<li>` is the drag surface) \| `:leading` \| `:trailing` (that icon position is). |
| `url:`           | `nil`    | Renders `<a href>` around the title/description. Without it, content renders with no wrapper (no click target at all — no `<button>` fallback, unlike `List::Item`). |
| `target:`        | `nil`    | Forwarded to the `<a>` (e.g. `"_blank"`), only used when `url:` is set.                        |
| `active:`        | `false`  | Adds `aria-current="page"`, only used when `url:` is set.                                      |
| `**html_options` | —        | Forwarded to the `<a>` when `url:` is set.                                                     |

### Item slot methods (yielded as `item`)

| Slot method                     | Description                                                                                                   |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `item.with_icon_leading(name)`   | Icon at the leading position. Becomes the drag handle if `handle: :leading`; otherwise purely decorative.        |
| `item.with_title(text)`          | Title text (pre-populated when positional `content` is given).                                                   |
| `item.with_description(text)`    | Secondary text below the title.                                                                                  |
| `item.with_icon_trailing(name)`  | Icon at the trailing position. Becomes the drag handle if `handle: :trailing`; otherwise purely decorative.       |

If `handle: :leading`/`:trailing` is set and the corresponding icon slot isn't, a default `grip-vertical` glyph renders there instead.

---

## Rendered HTML Structure

### `handle: :item` (default), no link

```html
<ol data-controller="reorderable" data-reorderable-move-key-value="Alt" data-reorderable-editing-value="false">
  <li id="item-1" data-reorderable-target="item handle" data-action="pointerdown->reorderable#onPointerDown pointermove->reorderable#onPointerMove pointerup->reorderable#onPointerUp">
    First
  </li>
</ol>
```

### `handle: :leading`, with a link

```html
<li id="link-1" data-reorderable-target="item">
  <span data-reorderable-target="handle" data-action="pointerdown->reorderable#onPointerDown ...">
    <svg aria-hidden="true">...</svg> <!-- grip-vertical, or a custom icon if item.with_icon_leading was set -->
  </span>
  <a href="/" data-reorderable-target="trigger">
    <span>
      <span>Dashboard</span>
      <span>Overview</span>
    </span>
  </a>
</li>
```

Icon positions (leading/trailing) are always siblings of the `<a>`, never nested inside it — this is what lets a real link coexist with drag reordering without one accidentally triggering the other. See [reorderable's editing mode](../../../stimulus-plumbers/docs/component/reorderable.md) for how the link itself is neutralized while editing.

---

## Theme keys

| Key                             | Element                                          | Variants |
| -------------------------------- | --------------------------------------------------- | -------- |
| `ordered_list`                   | Outer `<ol>`                                        | —        |
| `ordered_list_item`              | `<li>`                                              | —        |
| `ordered_list_item_handle`       | Leading/trailing `<span>` (decorative-or-handle)    | —        |
| `ordered_list_item_content`      | Content wrapper `<span>` inside `<a>` (or bare)     | —        |
| `ordered_list_item_title`        | Title `<span>`                                      | —        |
| `ordered_list_item_description`  | Description `<span>`                                | —        |

---

## ARIA

- See [ARIA.md](../../../ARIA.md) for WCAG 2.1 AA criteria.
- For the `reorderable` JS controller's targets, values, and actions (including `editingValue`/`trigger`/`toggleEditing`), see the [stimulus-plumbers JS controller doc](../../../stimulus-plumbers/docs/component/reorderable.md).
```

- [ ] **Step 7: Add the README row**

In `README.md`, change:

```markdown
| Modal | — (JS only) | [docs/component/modal.md](docs/component/modal.md) |
| Popover | `sp_popover` | [docs/component/popover.md](docs/component/popover.md) |
```

to:

```markdown
| Modal | — (JS only) | [docs/component/modal.md](docs/component/modal.md) |
| OrderedList | `sp_ordered_list` | [docs/component/ordered_list.md](docs/component/ordered_list.md) |
| Popover | `sp_popover` | [docs/component/popover.md](docs/component/popover.md) |
```

- [ ] **Step 8: Commit**

```bash
git add test/sandbox/config/routes.rb test/sandbox/app/controllers/components_controller.rb test/sandbox/app/views/components/ordered_list.html.erb test/accessibility/components/ordered_list_accessibility_test.rb docs/component/ordered_list.md README.md
git commit -m "$(cat <<'EOF'
docs: add OrderedList sandbox view, accessibility tests, and docs

First real consumer of the reorderable controller, so this is where
the earlier a11y/snapshot-test deferral for reorderable ends.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

### Task 7: Final full verification

**Files:** none (verification only)

- [ ] **Step 1: Run the full JS test suite and lint**

Run (from `stimulus-plumbers/`): `node --run test && node --run lint && node --run format:check`
Expected: PASS, no errors.

- [ ] **Step 2: Run the full Rails unit test suite, accessibility suite, and rubocop**

Run (from `stimulus-plumbers-rails/`): `bundle exec rake test:unit && bundle exec rake test:accessibility && bundle exec rake rubocop`
Expected: PASS, no errors, no offenses.

- [ ] **Step 3: Manually confirm the core design decisions landed**

Read the final `src/controllers/reorderable_controller.js` and confirm: `editingValue` defaults `false`, `onPointerDown`/`onPointerMove`/`onPointerUp` all check `this.editingValue` first, `editingValueChanged` calls `setDisabled` on `triggerTargets`.

Read the final `lib/stimulus_plumbers/components/ordered_list/item.rb` and confirm: `id:` raises when missing, `handle: :item` puts target attrs on the `<li>` itself, icon positions are always siblings of `render_body`'s output (never nested inside it), no `<button>` fallback when `url:` is absent.

No commit for this task — verification-only checkpoint before merge/PR (handled outside this plan).
