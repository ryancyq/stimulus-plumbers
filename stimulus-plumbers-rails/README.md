# stimulus-plumbers-rails

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci]
[![Coverage][coverage_badge]][coverage]

Rails helpers for accessible, WCAG 2.1 AA compliant UI components built on [Stimulus](https://stimulus.hotwired.dev/). Pairs with the [`@stimulus-plumbers/controllers`](../stimulus-plumbers) npm package.

See [docs/guide.md](docs/guide.md) for a quick guide to building forms and views with this gem.

## Requirements

- Ruby >= 3.0
- Rails >= 6.1
- `@stimulus-plumbers/controllers` registered in your Stimulus app

## Installation

```ruby
# Gemfile
gem "stimulus_plumbers"
```

```bash
bundle install
```

Include the helpers in your `ApplicationHelper`:

```ruby
module ApplicationHelper
  include StimulusPlumbers::Helpers::ComboboxHelper
  include StimulusPlumbers::Helpers::PopoverHelper
  include StimulusPlumbers::Helpers::CalendarHelper
end
```

Or use the form builder globally:

```ruby
# config/application.rb
config.action_view.default_form_builder = StimulusPlumbers::Form::Builder
```

Run the install generator once to inject the `tokens.css` import into your CSS entry file — see [docs/guide.md#css-entry-file-detection](docs/guide.md#css-entry-file-detection) for how the entry file is found/overridden:

```bash
bin/rails generate stimulus_plumbers:install
```

The import stays current automatically after that — the engine hooks `stimulus_plumbers:install` as a prerequisite of `assets:precompile`.

## Components

| Component | Helper(s) | Docs |
|-----------|-----------|------|
| Avatar | `sp_avatar` | [docs/component/avatar.md](docs/component/avatar.md) |
| Button | `sp_button`, `sp_button_group` | [docs/component/button.md](docs/component/button.md) |
| Calendar | `sp_calendar_month` | [docs/component/calendar.md](docs/component/calendar.md) |
| Calendar (Turbo) | `sp_calendar_turbo`, `sp_calendar_turbo_month`, `sp_calendar_turbo_year`, `sp_calendar_turbo_decade` | [docs/component/calendar.md](docs/component/calendar.md) |
| Card | `sp_card` | [docs/component/card.md](docs/component/card.md) |
| Combobox — date | `sp_combobox_date` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_date) |
| Combobox — dropdown | `sp_combobox_dropdown` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_dropdown) |
| Combobox — typeahead | `sp_combobox_typeahead` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_typeahead) |
| Combobox — time | `sp_combobox_time` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_time) |
| Divider | `sp_divider` | [docs/component/divider.md](docs/component/divider.md) |
| Icon | `sp_icon` | [docs/component/icon.md](docs/component/icon.md) |
| Link | `sp_link` | [docs/component/link.md](docs/component/link.md) |
| List | `sp_list` | [docs/component/list.md](docs/component/list.md) |
| Modal | — (JS only) | [docs/component/modal.md](docs/component/modal.md) |
| Popover | `sp_popover` | [docs/component/popover.md](docs/component/popover.md) |
| Timeline | `sp_timeline`, `sp_timeline_group` | [docs/component/timeline.md](docs/component/timeline.md) |

## Form Builder

`StimulusPlumbers::Form::Builder` wraps all components as model-aware form fields with automatic label, name/id, error, and ARIA wiring.

→ [docs/component/form.md](docs/component/form.md)

## Theming

Supports custom themes by subclassing `StimulusPlumbers::Themes::Base`. A ready-made Tailwind CSS v4 theme is available via the [`stimulus_plumbers_tailwind`](../stimulus-plumbers-tailwind) gem.

→ [docs/component/theme.md](docs/component/theme.md)

## Development

```bash
bundle install

bundle exec rake test:unit          # unit tests
bundle exec rake test:accessibility # accessibility tests (Capybara + axe-core)
bundle exec rake rubocop            # lint
bundle exec rake coverage           # run tests with coverage + collate report
```

Test against a specific Rails version:

```bash
BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bundle exec rake test:unit
```

Available appraisals: `rails_6.1`, `rails_7.0`, `rails_7.1`, `rails_7.2`, `rails_8.0`, `rails_8.1`, `rails_edge`.

## License

[MIT](https://opensource.org/licenses/MIT)

[rubygems_badge]: https://img.shields.io/gem/v/stimulus_plumbers.svg
[rubygems]: https://rubygems.org/gems/stimulus_plumbers
[ci_badge]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-rails.yml/badge.svg
[ci]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-rails.yml
[coverage_badge]: https://codecov.io/gh/ryancyq/stimulus-plumbers/graph/badge.svg?token=Z77H6M5GER&flag=ruby
[coverage]: https://codecov.io/gh/ryancyq/stimulus-plumbers
