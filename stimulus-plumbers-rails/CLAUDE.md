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
│   ├── snapshots/                    # Playwright visual regression tests
│   │   ├── __screenshots__/          # Baseline screenshots (committed)
│   │   └── *.spec.js
│   ├── sandbox/                      # Minimal Rails app used by a11y + snapshot tests
│   └── test_helper.rb
├── gemfiles/                         # Appraisal-generated gemfiles (rails 6.1–edge)
├── playwright.config.js              # Playwright config (snapshot tests)
├── package.json                      # npm deps: Playwright, Tailwind CSS CLI
├── Gemfile
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation, usage examples, and developer setup.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Accessibility tests** using Capybara + axe-core (`rake test:accessibility`)
- **Snapshot tests** using Playwright (`npm run test:snapshots`); update baselines with `npm run test:snapshots:update`
- **Lint tests** using Rubocop (`rake rubocop`)
- **Always run linting** after appraisal command

## Component Architecture

> See `docs/compomnent/*.md` for HTML structure, Stimulus Controller + Action Wiring.
