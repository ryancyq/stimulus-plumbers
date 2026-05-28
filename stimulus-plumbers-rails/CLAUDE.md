# Stimulus Plumbers Rails

## Folder Structure

```
stimulus-plumbers-rails/
├── lib/
│   └── stimulus_plumbers/
│       ├── components/
│       │   ├── action_list.rb            # sp_action_list list/section/item renderer
│       │   ├── action_list/
│       │   │   ├── item.rb
│       │   │   └── section.rb
│       │   ├── avatar.rb                 # sp_avatar renderer
│       │   ├── button.rb                 # sp_button renderer
│       │   ├── button/
│       │   │   └── group.rb
│       │   ├── calendar.rb               # sp_calendar_month renderer
│       │   ├── calendar/month/turbo.rb   # Turbo-compatible calendar grid
│       │   ├── calendar/month/turbo/
│       │   │   ├── days_of_month.rb
│       │   │   └── days_of_week.rb
│       │   ├── card.rb                   # sp_card renderer
│       │   ├── card/
│       │   │   └── section.rb
│       │   ├── combobox.rb               # Shared wrapper: input-combobox + input-format
│       │   ├── combobox/
│       │   │   ├── typeahead.rb          # combobox-dropdown (typeahead mode) body
│       │   │   ├── date.rb               # combobox-date picker body
│       │   │   ├── dropdown.rb           # combobox-dropdown listbox body
│       │   │   ├── options.rb            # Option list renderer
│       │   │   ├── options/
│       │   │   │   ├── option.rb
│       │   │   │   └── option_group.rb
│       │   │   ├── popover.rb            # Combobox popover wrapper
│       │   │   ├── time.rb               # combobox-time drum picker body
│       │   │   ├── time/
│       │   │   │   └── drum.rb           # Single drum column renderer
│       │   │   └── trigger.rb            # Combobox trigger input
│       │   ├── date_picker/
│       │   │   ├── navigation.rb         # Month navigation bar (prev/next buttons)
│       │   │   └── navigator.rb          # Individual prev/next button
│       │   ├── divider.rb                # sp_divider renderer
│       │   ├── icon.rb                   # sp_icon renderer (SVG or span fallback)
│       │   └── popover.rb                # sp_popover renderer (activator + content)
│       │   └── popover/
│       │       └── builder.rb            # Builder DSL yielded to sp_popover block
│       ├── helpers/
│       │   ├── action_list_helper.rb     # sp_action_list, sp_action_list_section, sp_action_list_item
│       │   ├── avatar_helper.rb          # sp_avatar
│       │   ├── button_helper.rb          # sp_button, sp_button_group
│       │   ├── calendar_helper.rb        # sp_calendar_month
│       │   ├── calendar_turbo_helper.rb  # sp_calendar_month_turbo
│       │   ├── card_helper.rb            # sp_card, sp_card_section
│       │   ├── combobox_helper.rb        # sp_combobox_date/time/dropdown/typeahead
│       │   ├── divider_helper.rb         # sp_divider
│       │   ├── plumber_helper.rb         # sp_dom_id
│       │   └── popover_helper.rb         # sp_popover
│       ├── form/
│       │   ├── builder.rb                # Form builder: FIELD_RENDERER/COLLECTION_FIELD_RENDERER/CHOICE_RENDERER constants + f.field/collection_field/choice
│       │   ├── base.rb                   # Form::Base — shared init, error?, described_by, render_hint/errors
│       │   ├── field.rb                  # Form::Field < Base — label + input + hint + error; TYPES, COLLECTION_TYPES, hide_label
│       │   └── fields/
│       │       ├── error.rb
│       │       ├── fieldset.rb
│       │       ├── group.rb
│       │       ├── hint.rb
│       │       ├── input_group.rb
│       │       ├── label.rb
│       │       └── inputs/
│       │           ├── checkbox.rb       # check_box, collection_check_boxes (native); render_check_box, render_collection_check_box
│       │           ├── radio.rb          # radio_button, collection_radio_buttons (native); render_collection_radio_button
│       │           ├── datetime.rb       # date_field, time_field (native); render_combobox_date, render_combobox_time
│       │           ├── file.rb           # file_field (native); render_file_input
│       │           ├── password.rb       # password_field + reveal: (native); render_password_input
│       │           ├── search.rb         # search_field + clearable: (native); render_combobox_typeahead
│       │           ├── select.rb         # select, collection_select (native); render_combobox_dropdown, render_collection/grouped_combobox_dropdown
│       │           ├── select/
│       │           │   ├── grouped.rb    # grouped_collection_select (native); build_grouped_choices
│       │           │   ├── timezone.rb   # time_zone_select (native)
│       │           │   └── weekday.rb    # weekday_select (native, Rails 7.1+)
│       │           ├── submit.rb         # submit
│       │           ├── text.rb           # text/email/url/tel/number/range/color/month/week/datetime_local_field (native + render_*_input per type)
│       │           └── text_area.rb      # text_area (native); render_text_area_input
│       ├── plumber/
│       │   ├── base.rb                   # Plumber::Base (template accessor, theme helper)
│       │   ├── dispatcher.rb             # Dispatcher for block-based component DSL
│       │   ├── dispatcher/
│       │   │   ├── callable_inspector.rb
│       │   │   ├── instance_exec.rb
│       │   │   ├── klass_proxy.rb
│       │   │   └── method_call.rb
│       │   ├── html_options.rb           # merge_html_options helper
│       │   └── renderer.rb              # Plumber::Renderer base
│       ├── themes/
│       │   ├── base.rb                   # Base theme (no-op default)
│       │   ├── configuration.rb          # Theme registry
│       │   ├── schema.rb                 # Theme key schema
│       │   ├── schema/
│       │   │   ├── icon.rb
│       │   │   ├── ranges.rb
│       │   │   └── form/
│       │   │       └── ranges.rb
│       │   └── icons/
│       │       ├── external.rb           # SVG file parser (include into any icon source module)
│       │       └── registry.rb           # Lazy-loading Registry < SimpleDelegator (source-injected)
│       ├── configuration.rb
│       ├── engine.rb
│       ├── logger.rb
│       └── version.rb
├── test/
│   ├── stimulus_plumbers/
│   │   ├── components/                   # Unit tests per component
│   │   ├── helpers/                      # Helper-level HTML output tests
│   │   ├── form/                         # Form builder + field tests
│   │   ├── plumber/                      # Plumber base class tests
│   │   └── themes/                       # Theme schema + base tests
│   ├── accessibility/                    # Accessibility tests (axe-core via Capybara)
│   │   ├── components/
│   │   └── form/
│   ├── sandbox/                          # Minimal Rails app used by a11y tests
│   ├── support/                          # Shared test helpers (HtmlAssertions, StubTheme)
│   └── test_helper.rb
├── docs/
│   ├── analysis/                         # Design analysis documents
│   └── component/                        # Per-component HTML structure + wiring docs
├── gemfiles/                             # Appraisal-generated gemfiles (rails 6.1–edge)
├── Gemfile
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation, usage examples, and developer setup.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Accessibility tests** using Capybara + axe-core (`rake test:accessibility`)
- **Lint tests** using Rubocop (`rake rubocop`)
- **Always run linting** after appraisal command

## Form Builder Convention

The form builder operates at two levels:

### Level 1 — Native ActionView overrides (theme classes only)

Standard Rails helpers (`email_field`, `text_area`, `check_box`, `select`, `date_field`, etc.) are overridden to apply theme CSS classes but render **no** label, hint, or error wrapper. Use them when controlling surrounding markup manually.

```erb
<%= f.email_field :email %>
<%= f.select      :country, options %>
<%= f.check_box   :agree %>
```

`password_field` additionally supports `reveal: true` at the input level (renders an input-formatter wrapper). `search_field` additionally supports `clearable: true`.

### Level 2 — Full-field helpers (label + input + hint + error)

Four builder methods provide the complete accessible field pattern:

| Method | Renderer constant | `as:` values |
| --- | --- | --- |
| `f.field(attr, as:)` | `FIELD_RENDERER` | `:text`, `:email`, `:number`, `:url`, `:tel`, `:color`, `:month`, `:week`, `:range`, `:datetime_local`, `:text_area`, `:file`, `:password`, `:date`, `:time`, `:select`, `:search`, `:check_box` |
| `f.collection_field(attr, as:, collection:, value_method:, text_method:)` | `COLLECTION_FIELD_RENDERER` | `:collection_select`, `:grouped_collection_select` |
| `f.choice(attr, as:, collection:, value_method:, text_method:)` | `CHOICE_RENDERER` | `:radio`, `:check_box` |

Field-chrome options (`label:`, `hint:`, `error:`, `required:`, `hide_label:`, `layout:`) are only meaningful on the full-field helpers — they are **not** processed by native overrides.

### Private render methods

Each module under `fields/inputs/` exposes private `render_*` methods that map 1:1 to renderer constant entries. These are called by the builder via `Plumber::Dispatcher` — never called directly. The naming convention is:

- `render_<type>_input` for text-like fields (e.g. `render_email_input`)
- `render_combobox_<type>` for combobox fields (e.g. `render_combobox_date`)
- `render_collection_<type>` for collection variants

## Component Architecture

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Key internal docs: `plumber.md` (Base / Renderer / HtmlOptions), `dispatcher.md` (Dispatcher strategies), `form_builder.md` (two-level field API).
> Ensure examples provided are tested.
