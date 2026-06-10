# WIP — Open Items

---

## Code

### P8 — Component registry (`register_component`) ❌

**Objective:** allow 3rd-party developers to extend or decorate rendering without monkey-patching.

Add `register_component(name, klass)` / `component_class(name)` to `Configuration`. Pre-register all defaults in an engine initializer. Update helpers, form-layer, and Combobox internal instantiation sites to resolve via `config.component_class(:key).new(template)`.

**Stable override keys (12):** `:avatar`, `:button`, `:button_group`, `:calendar`, `:calendar_turbo`, `:card`, `:divider`, `:icon`, `:input_group`, `:link`, `:list`, `:popover`

**Per-key contracts** (`COMPONENT_CONTRACTS` in `configuration.rb`):
- `:icon` — class methods: `icon_name?`; instance methods: `render`
- `:button` — instance methods: `render`, `build`
- all others — instance methods: `render` only

**Instantiation sites to update:**

| Scope | File | Key |
|---|---|---|
| helpers | `avatar/button/calendar/card/divider/link/list/popover_helper.rb` | matching key |
| form layer | `form/fields/inputs/search.rb:70`, `submit.rb:17`, `form/builder.rb:114` | `:button`, `:input_group` |
| combobox internals | `combobox/trigger.rb:86`, `typeahead.rb:73` | `:icon` |
| combobox internals | `combobox/trigger.rb:78` | `:input_group` |

**`icon_name?` call sites** — change `Components::Icon.icon_name?` →
`StimulusPlumbers.config.component_class(:icon).icon_name?` at:
- `Plumber::Base#render_icon_slot` (after P9 extracts it)
- `Card#render_icon_slot` (separate method — inline the guard change there)

**Known limitations (document in `plumber.md`):**
- `panel_id_for` on Combobox and Popover — hardcoded class methods; cannot be overridden via registry
- `STIMULUS_CONTROLLER` cross-component wiring — frozen constants at class-load time; registering a custom `:popover` does not update Stimulus action strings in `Combobox::Trigger`
- `Combobox::Date/Time/Dropdown/Typeahead.variant` / `.options(...)` — internal wiring, not in registry scope

**Ordering:** P9 must run before P8 (P8 Step 2b adds the registry call to the extracted `render_icon_slot`).

---

### P9 — Extract shared `render_icon_slot` to `Plumber::Base` ⚠️ partial

Identical private method exists in three files with the same `(slots, slot_name, theme_key:)` signature:
- `components/button.rb`
- `components/link.rb`
- `components/list/item.rb`

**Plan:** Add a `protected` method on `Plumber::Base`:
```ruby
def render_icon_slot(slots, slot_name, theme_key:)
  slots.resolve(slot_name) do |value|
    next value unless Components::Icon.icon_name?(value)
    Components::Icon.new(template).render(
      name: value, classes: theme.resolve(theme_key).fetch(:classes, ""), aria: { hidden: "true" }
    )
  end
end
```
Remove the three duplicates; call the shared method with per-component theme keys.

**Card is separate:** `Card#render_icon_slot(value)` takes a raw value, not a `Slots` object — different signature. Cannot be merged; handled separately in P8 Step 2d.

---

### P10 — Fix `button_test` invalid `type: :secondary` assertion ❌

`test/stimulus_plumbers/components/button_test.rb` asserts `type: :secondary`, which is not in `Button::Ranges::TYPE`. The test passes trivially because the base theme silently returns `{}` for unknown values — it provides no real coverage.

Replace with a valid type assertion, or add an explicit test for the invalid-type fallback that asserts the expected behavior (e.g., renders without crash, applies no type-specific classes).

---

## Docs

### P2 — Add `sp_icon` helper ❌

`icon.md` documents `sp_icon name: "check"` as usable ERB, but no `icon_helper.rb` exists and `IconHelper` is not included in `helpers.rb`.

1. Create `lib/stimulus_plumbers/helpers/icon_helper.rb`:
   ```ruby
   def sp_icon(name:, **kwargs)
     Components::Icon.new(self).render(name: name, **kwargs)
   end
   ```
2. Include `IconHelper` in `lib/stimulus_plumbers/helpers.rb`
3. Add a unit test in `test/stimulus_plumbers/helpers/`

---

### P3 — Create `docs/component/list.md` ❌

No doc exists for `sp_list`. The stale `action_list.md` should be removed/replaced.

Document:
- Helper: `sp_list(heading_level:, role:, **html_options, &block)`
- Block API: `list.section(title:, description:)` / `section.item(content, url:, active:, &block)`
- `List::Item::Slots`: `with_icon_leading`, `with_title`, `with_description`, `with_icon_trailing`
- Nested sections (recursive `s.section(...)`)
- Theme keys: `list`, `list_section`, `list_section_title`, `list_section_description`, `list_item`, `list_item_icon`, `list_item_content`, `list_item_title`, `list_item_description`
- HTML structure (role=list / role=group nesting, heading levels, active aria pattern)

---

### P5 — Fix `docs/component/plumber.md` module/method names ❌

| Wrong | Correct |
|---|---|
| `Plumber::HtmlOptions` | `Plumber::Options::Html` |
| `include StimulusPlumbers::Plumber::HtmlOptions` | `include StimulusPlumbers::Plumber::Options::Html` |
| `merge_string_option` | `merge_token_list` |
| `merge_data_options` | `merge_stimulus_data` |

Also add a `### Component Registry` section (stable keys, decorator subclass contract, known limitations) — driven by P8.

Also add a note: `Plumber::Renderer` is the extension point for **custom component authors**. Built-in components use `Plumber::Slots` directly (Pattern A) or `template.capture(self, &block)` (Pattern B).

---

### P6 — Fix `docs/component/theme.md` schema key table ❌

**Remove:** `action_list`, `action_list_item` (deleted), `card_section` (deleted), `Card::Section` row.

**Add:**
- List keys: `list`, `list_section`, `list_section_title`, `list_section_description`, `list_item`, `list_item_icon`, `list_item_content`, `list_item_title`, `list_item_description`
- Card slot keys: `card_header`, `card_icon`, `card_title`, `card_body`, `card_action`

---

### P7 — Rewrite `docs/component/card.md` ❌

Current doc still shows `sp_card_section` and the old kwarg API. The public API changed to the slot DSL.

Rewrite to show:
- `sp_card(variant:, title_tag:) { |card| }` — block yields `Card::Slots`
- Slot methods: `card.with_icon(name_or_html)`, `card.with_title(text)`, `card.with_body { content }`, `card.with_action(text, url: nil)`
- HTML structure: header div (icon + title), body div, action div
- Theme keys: `card`, `card_header`, `card_icon`, `card_title`, `card_body`, `card_action`
