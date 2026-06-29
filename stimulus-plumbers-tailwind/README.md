# stimulus-plumbers-tailwind

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci]
[![Coverage][coverage_badge]][coverage]

Tailwind CSS v4 theme for [`stimulus_plumbers`](../stimulus-plumbers-rails). Extends the base theme with utility classes for all components.

## Requirements

- Ruby >= 3.0
- `stimulus_plumbers` >= 0.2.9
- Tailwind CSS v4 in your build toolchain

## Installation

```ruby
# Gemfile
gem "stimulus_plumbers_tailwind"
```

```bash
bundle install
```

Activate the theme in an initializer or `config/application.rb`:

```ruby
StimulusPlumbers.configure do |config|
  config.theme = :tailwind
end
```

Tell Tailwind to scan the gem's lib files so component class names are included in the generated CSS. Add an `@source` directive pointing at the gem's installed path:

```css
@import "tailwindcss";
@source "/path/to/gems/stimulus_plumbers_tailwind-VERSION/lib/**/*.rb";
```

Use `bundle show stimulus_plumbers_tailwind` to get the exact installed path.

## Theming

`StimulusPlumbers::Themes::TailwindTheme` subclasses `StimulusPlumbers::Themes::Base` and provides CSS class resolution for all component families:

| Module | Components |
|--------|------------|
| `Tailwind::ActionList` | Action list, menu items |
| `Tailwind::Avatar` | Avatar |
| `Tailwind::Button` | Button |
| `Tailwind::Calendar` | Calendar grid, date picker |
| `Tailwind::Card` | Card |
| `Tailwind::Combobox` | Combobox (date, time, dropdown, typeahead) |
| `Tailwind::Form` | Form fields, labels, errors |
| `Tailwind::Icon` | Icon (SVG rendering, icon registry) |
| `Tailwind::Layout` | Layout primitives |

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

**Built-in aliases:** `"close"` → `"x-mark"`, `"calendar"` → `"calendar-days"`.

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
