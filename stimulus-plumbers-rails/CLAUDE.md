# Stimulus Plumbers Rails

## Folder Structure

```
stimulus-plumbers-rails/
├── lib/
│   └── stimulus_plumbers/
│       ├── components/
│       │   ├── combobox/             # Combobox family (date, time, dropdown, autocomplete)
│       │   │   ├── renderer.rb       # Shared wrapper: input-combobox + input-format
│       │   │   ├── date.rb           # combobox-date picker body
│       │   │   ├── time.rb           # combobox-time drum picker body
│       │   │   ├── dropdown.rb       # combobox-dropdown listbox body
│       │   │   └── autocomplete.rb   # combobox-dropdown (autocomplete mode) body
│       │   ├── time_picker/
│       │   │   └── renderer.rb       # Drum column renderer (ul[role=listbox])
│       │   ├── calendar/             # Calendar grid rendering
│       │   ├── date_picker/          # Date picker navigation
│       │   └── plumber/              # Ruby base plumber (Plumber::Base, merge helpers)
│       ├── helpers/
│       │   └── combobox_helper.rb    # sp_combobox_date/time/dropdown/autocomplete helpers
│       ├── form/
│       │   └── builder.rb            # Form builder extensions (combobox_field)
│       ├── engine.rb
│       └── version.rb
├── test/
│   ├── stimulus_plumbers/
│   │   ├── helpers/                  # Helper-level HTML output tests
│   │   └── form/                     # Form builder tests
│   ├── accessibility/                # Accessibility tests (axe-core via Capybara)
│   │   ├── components/
│   │   └── form/
│   ├── sandbox/                      # Minimal Rails app used by a11y tests
│   └── test_helper.rb
├── gemfiles/                         # Appraisal-generated gemfiles (rails 6.1–edge)
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
