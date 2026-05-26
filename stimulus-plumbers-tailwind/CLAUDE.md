# Stimulus Plumbers Tailwind

## Folder Structure

```
stimulus-plumbers-tailwind/
├── lib/
│   ├── stimulus_plumbers_tailwind.rb       # Entry point: registers :tailwind theme
│   ├── stimulus_plumbers_tailwind/
│   │   ├── engine.rb                       # Rails::Engine — registers :tailwind theme on boot
│   │   └── version.rb
│   └── stimulus_plumbers/
│       └── themes/
│           ├── tailwind_theme.rb            # TailwindTheme < Base (includes 8 modules)
│           └── tailwind/
│               ├── action_list.rb           # ActionList CSS classes
│               ├── avatar.rb               # Avatar CSS classes
│               ├── button.rb               # Button CSS classes
│               ├── calendar.rb             # Calendar CSS classes
│               ├── card.rb                 # Card CSS classes
│               ├── combobox.rb             # Combobox CSS classes
│               ├── form.rb                 # Form CSS classes
│               ├── icon.rb                 # Icon CSS classes + ALIASES + Registry wiring
│               ├── icons/
│               │   ├── heroicon.rb         # Heroicons source (bundled SVGs or heroicons gem)
│               │   ├── custom.rb           # Custom icons from icons/customs/
│               │   ├── heroicons/          # Bundled heroicon SVGs (outline/ + solid/)
│               │   └── customs/            # Custom icon SVGs (e.g. spinner.svg)
│               └── layout.rb              # Layout CSS classes
├── test/
│   ├── stimulus_plumbers/
│   │   └── themes/
│   │       ├── tailwind_test.rb            # TailwindTheme integration tests
│   │       └── tailwind/                   # Per-module unit tests
│   │           ├── icons/                  # Unit tests for icon sources + registry
│   │           └── ...
│   ├── snapshots/                          # Playwright visual snapshot specs
│   ├── sandbox/                            # Minimal Rails app for snapshot tests
│   │   ├── app/views/                      # ERB views (components + form pages)
│   │   ├── config/                         # Routes, application, environment
│   │   ├── public/                         # Compiled tailwind.css output (gitignored)
│   │   └── tailwind.css                    # Tailwind CSS v4 source with @source directives
│   ├── support/
│   │   └── html_assertions.rb
│   └── test_helper.rb
├── Gemfile
├── package.json                            # Tailwind CLI + Playwright
├── playwright.config.js
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation and developer setup.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Snapshot tests** using Playwright (`npm run test:snapshots`); update baselines with `npm run test:snapshots:update`
- **Lint tests** using Rubocop (`rake rubocop`)

## Theme Architecture

`StimulusPlumbers::Themes::TailwindTheme` extends `StimulusPlumbers::Themes::Base` and is split into 9 concern modules under `StimulusPlumbers::Themes::Tailwind::*`. Each module provides CSS class resolution for one component family. The `Icon` module also owns the icon registry (`icons/`) which lazily parses SVG files from the bundled heroicons set and a `customs/` directory.

The theme is registered on load (via the Engine initializer in Rails, or directly otherwise):

```ruby
StimulusPlumbers.configure do |c|
  c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
end
```

Consumers activate it via:

```ruby
StimulusPlumbers.configure { |c| c.theme = :tailwind }
```
