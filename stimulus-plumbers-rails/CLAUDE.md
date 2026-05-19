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
│       │   │   ├── autocomplete.rb       # combobox-dropdown (autocomplete mode) body
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
│       │   ├── combobox_helper.rb        # sp_combobox_date/time/dropdown/autocomplete
│       │   ├── divider_helper.rb         # sp_divider
│       │   ├── plumber_helper.rb         # sp_dom_id
│       │   └── popover_helper.rb         # sp_popover
│       ├── form/
│       │   ├── builder.rb                # Form builder (ActionView::Helpers::FormBuilder subclass)
│       │   ├── field.rb                  # Field wrapper: label, hint, error, aria
│       │   └── fields/
│       │       ├── error.rb
│       │       ├── fieldset.rb
│       │       ├── group.rb
│       │       ├── hint.rb
│       │       ├── input_group.rb
│       │       ├── label.rb
│       │       └── inputs/
│       │           ├── choice.rb         # check_box, radio_button, collection_check_boxes, collection_radio_buttons
│       │           ├── datetime.rb       # date_field, time_field, datetime_local_field (combobox-backed)
│       │           ├── file.rb           # file_field
│       │           ├── password.rb       # password_field
│       │           ├── search.rb         # search_field
│       │           ├── select.rb         # select, collection_select, grouped_collection_select
│       │           ├── select/
│       │           │   ├── timezone.rb   # time_zone_select
│       │           │   └── weekday.rb    # weekday_select (Rails 7.1+)
│       │           ├── submit.rb         # submit
│       │           ├── text.rb           # text_field, email_field, url_field, tel_field, number_field, …
│       │           └── text_area.rb      # text_area
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
│       │   └── schema/
│       │       ├── icon.rb
│       │       ├── ranges.rb
│       │       └── form/
│       │           └── ranges.rb
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

## Component Architecture

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
