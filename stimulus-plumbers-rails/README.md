# stimulus-plumbers-rails

[![Version][rubygems_badge]][rubygems]
[![CI][ci_badge]][ci]
[![Coverage][coverage_badge]][coverage]

Rails helpers for accessible, WCAG 2.1 AA compliant UI components built on [Stimulus](https://stimulus.hotwired.dev/). Pairs with the [`@stimulus-plumbers/controllers`](../stimulus-plumbers) npm package.

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

## Components

| Component | Helper(s) | Docs |
|-----------|-----------|------|
| Combobox — date | `sp_combobox_date` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_date) |
| Combobox — dropdown | `sp_combobox_dropdown` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_dropdown) |
| Combobox — autocomplete | `sp_combobox_autocomplete` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_autocomplete) |
| Combobox — time | `sp_combobox_time` | [docs/component/combobox.md](docs/component/combobox.md#sp_combobox_time) |
| Calendar | `sp_calendar_month` | [docs/component/calendar.md](docs/component/calendar.md) |
| Popover | `sp_popover` | [docs/component/popover.md](docs/component/popover.md) |
| Modal | — (JS only) | [docs/component/modal.md](docs/component/modal.md) |

## Form Builder

`StimulusPlumbers::Form::Builder` wraps all components as model-aware form fields with automatic label, name/id, error, and ARIA wiring.

→ [docs/component/form_builder.md](docs/component/form_builder.md)

## Theming

Includes a Tailwind CSS theme out of the box. Supports custom themes by subclassing `Themes::Base`.

→ [docs/component/theme.md](docs/component/theme.md)

## Development

```bash
bundle install

bundle exec rake test:unit         # unit tests
bundle exec rake test:accessibility # accessibility tests
bundle exec rake rubocop           # lint
bundle exec rake coverage          # run tests with coverage + collate report
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
