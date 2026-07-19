# stimulus-plumbers-tailwind

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci]
[![Coverage][coverage_badge]][coverage]

Tailwind CSS v4 theme for [`stimulus_plumbers`](../stimulus-plumbers-rails). Extends the base theme with utility classes for all components.

See [docs/guide.md](docs/guide.md) for a quick setup/theming guide.

## Requirements

- Ruby >= 3.0
- `stimulus_plumbers` >= 0.3.1
- Tailwind CSS v4 in your build toolchain

## Installation

```ruby
# Gemfile
gem "stimulus_plumbers_tailwind"
```

```bash
bundle install
```

In a Rails app, the theme registers and activates automatically — no config needed. Outside Rails, it only registers; activate it explicitly:

```ruby
StimulusPlumbers.configure do |config|
  config.theme.use(:tailwind)
end
```

Run the install generator once to copy `stimulus_plumbers/tokens.css` and `stimulus_plumbers/tailwind/animations.css` into your app, then inject their relative imports and the required `@source` directive into your Tailwind CSS entry file — see [docs/guide.md](docs/guide.md) for file-detection/override details:

```bash
bin/rails generate stimulus_plumbers:tailwind:install
```

After that, the `@source` path is kept current automatically — no manual re-run needed after `bundle update`. The copied CSS remains application-owned and is never overwritten; update it intentionally when adopting new defaults. The engine hooks `stimulus_plumbers:tailwind:install` as a prerequisite of:

- `assets:precompile` (Sprockets and Propshaft both define this task)
- `tailwindcss:build` (when `tailwindcss-rails` is present)

To trigger an update manually without a full compile (useful for debugging or after `bundle update`):

```bash
bin/rails stimulus_plumbers:tailwind:install
```

## Theming

`StimulusPlumbers::Themes::TailwindTheme` subclasses `StimulusPlumbers::Themes::Base` and provides CSS class resolution for all component families:

| Module | Components |
|--------|------------|
| `Tailwind::Avatar` | Avatar |
| `Tailwind::Button` | Button |
| `Tailwind::Calendar` | Calendar grid, date picker |
| `Tailwind::Card` | Card |
| `Tailwind::Combobox` | Combobox (date, time, dropdown, typeahead) |
| `Tailwind::Form` | Form fields, labels, errors |
| `Tailwind::Icon` | Icon (SVG rendering, icon registry) |
| `Tailwind::Indicator` | Indicator (dot, pulse, badge) |
| `Tailwind::Layout` | Layout primitives |
| `Tailwind::Link` | Link |
| `Tailwind::List` | List |
| `Tailwind::OrderedList` | Reorderable list (drag handle, item styling) |
| `Tailwind::Progress` | Progress bar, progress ring, meter |
| `Tailwind::Timeline` | Timeline |

Custom themes can subclass `TailwindTheme` to override individual methods, or subclass `StimulusPlumbers::Themes::Base` directly.

## Icons

The theme bundles the [Heroicons](https://heroicons.com/) 2.x set. Pass a kebab-case icon name to `sp_icon` or any component accepting `icon_leading:` / `icon_trailing:`. Append `/solid` for the filled variant:

```erb
<%= sp_icon "arrow-left" %>
<%= sp_icon "arrow-left/solid" %>
<%= sp_button "Next", icon_trailing: "arrow-right" %>
```

Icons render as inline `<svg>` with `size-6` by default. Override with `class:`:

```erb
<%= sp_icon "arrow-left", class: "size-4 text-gray-500" %>
```

**Built-in aliases:** `"close"` → `"x-mark"`, `"download"` → `"arrow-down-tray"`, `"book"` → `"book-open"`, `"edit"` → `"pencil"`, `"email"` → `"envelope"`, `"calendar"` → `"calendar-days"`, `"external-link"` → `"arrow-top-right-on-square"`, `"reveal"` → `"eye"`, `"grip-vertical"` → `"bars-3"`.

**Optional `heroicons` gem:** add `gem "heroicons"` to your `Gemfile` to load icons from the gem instead of the bundled files. The theme detects it automatically.

## Development

```bash
bundle install
npm install

bundle exec rake test:unit    # unit tests
node --run test:snapshots         # visual snapshot tests (Playwright)
node --run test:snapshots:update  # regenerate baseline screenshots
bundle exec rake rubocop       # lint
bundle exec rake coverage      # run tests with coverage + collate report
```

The sandbox Rails app lives in `test/sandbox/`. Run it with:

```bash
bundle exec puma test/sandbox/config.ru
```

## License

[MIT](https://opensource.org/licenses/MIT)

[rubygems_badge]: https://img.shields.io/gem/v/stimulus_plumbers_tailwind.svg
[rubygems]: https://rubygems.org/gems/stimulus_plumbers_tailwind
[ci_badge]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-tailwind.yml/badge.svg
[ci]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-tailwind.yml
[coverage_badge]: https://codecov.io/gh/ryancyq/stimulus-plumbers/graph/badge.svg?token=Z77H6M5GER&flag=tailwind
[coverage]: https://codecov.io/gh/ryancyq/stimulus-plumbers
