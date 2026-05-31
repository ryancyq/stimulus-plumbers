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

## Dependency

Requires `stimulus_plumbers >= 0.2.9` and Tailwind CSS v4 in the consuming app's build pipeline.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Snapshot tests** using Playwright (`npm run test:snapshots`); update baselines with `npm run test:snapshots:update`
- **Lint tests** using Rubocop (`rake rubocop`)
- **Snapshot tests must be a superset of `stimulus-plumbers-rails` a11y tests** — every page + interactive state covered by an a11y test must also have a corresponding snapshot test. When adding a11y tests in the core gem, add matching snapshot coverage here.

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

## Tailwind v4 `@source` Setup

Add an `@source` directive to your Tailwind CSS entry file so component class names are detected at build time:

```css
@import "tailwindcss";
@source "/path/to/gems/stimulus_plumbers_tailwind-VERSION/lib/**/*.rb";
```

Get the installed path: `bundle show stimulus_plumbers_tailwind`.

## Sandbox App

`test/sandbox/` is a minimal Rails app used by both unit tests and Playwright snapshot tests:
- `app/views/` — ERB pages for each component and form field variant
- `config/` — routes and minimal app config
- `tailwind.css` — Tailwind v4 source with `@source` pointing at gem lib

Run it locally: `bundle exec puma test/sandbox/config.ru`

## Adding a New Theme Module

1. Create `lib/stimulus_plumbers/themes/tailwind/{component}.rb` with `module StimulusPlumbers::Themes::Tailwind::{Component}`
2. Implement private `{theme_key}_classes(**variants)` methods returning `{ classes: "..." }`
3. Include the new module in `TailwindTheme` (`lib/stimulus_plumbers/themes/tailwind_theme.rb`)
4. Add unit tests in `test/stimulus_plumbers/themes/tailwind/{component}_test.rb`
5. Add a sandbox view and Playwright snapshot spec; add theme key(s) to `StimulusPlumbers::Themes::Schema` in the Rails gem

## Known Theme Gaps

- `popover_trigger` / `popover_root` (`layout.rb`): schema keys exist but no Tailwind classes defined yet — default `p.trigger { ... }` renders an unstyled native `<button>`. Do **not** regenerate profile snapshots until this is resolved.
