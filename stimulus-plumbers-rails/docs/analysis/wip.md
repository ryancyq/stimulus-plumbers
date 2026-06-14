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

| Scope              | File                                                                     | Key                       |
| ------------------ | ------------------------------------------------------------------------ | ------------------------- |
| helpers            | `avatar/button/calendar/card/divider/link/list/popover_helper.rb`        | matching key              |
| form layer         | `form/fields/inputs/search.rb:70`, `submit.rb:17`, `form/builder.rb:114` | `:button`, `:input_group` |
| combobox internals | `combobox/trigger.rb:86`, `typeahead.rb:73`                              | `:icon`                   |
| combobox internals | `combobox/trigger.rb:78`                                                 | `:input_group`            |

**`icon_name?` call sites** — change `Components::Icon.icon_name?` →
`StimulusPlumbers.config.component_class(:icon).icon_name?` at:

- `Plumber::Base#render_icon_slot` (after P9 extracts it)
- `Card#render_icon_slot` (separate method — inline the guard change there)

**Known limitations (document in `plumber.md`):**

- `panel_id_for` on Combobox and Popover — hardcoded class methods; cannot be overridden via registry
- `STIMULUS_CONTROLLER` cross-component wiring — frozen constants at class-load time; registering a custom `:popover` does not update Stimulus action strings in `Combobox::Trigger`
- `Combobox::Date/Time/Dropdown/Typeahead::Metadata` (+ `Combobox::Builder`) — variant wiring, not in registry scope

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
