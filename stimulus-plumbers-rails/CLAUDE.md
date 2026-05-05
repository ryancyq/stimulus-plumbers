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
│   └── test_helper.rb
├── gemfiles/                         # Appraisal-generated gemfiles (rails 6.1–edge)
├── Gemfile
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation, usage examples, and developer setup.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Lint tests** using Rubocop (`rake rubocop`)
- **Always run linting** after appraisal command
- **System tests** generally should only be used for accessibility verification

## Component Architecture

> See `docs/compomnent/*.md` for HTML structure, Stimulus Controller + Action Wiring.
