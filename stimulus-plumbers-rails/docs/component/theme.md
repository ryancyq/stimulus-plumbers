# Theming

Stimulus Plumbers uses a theme system to apply presentational CSS classes to form fields and components. The default theme is Tailwind CSS. Custom themes can be created by subclassing `Themes::Base`.

## Configuration

```ruby
# config/initializers/stimulus_plumbers.rb
StimulusPlumbers.configure do |config|
  config.theme = :tailwind   # default
  # config.theme = MyCustomTheme.new
end
```

## Theme keys

Each row lists the theme key, the component that uses it, and the variants it accepts.

### Form fields

| Key                  | Component                                      | Variants                                   |
| -------------------- | ---------------------------------------------- | ------------------------------------------ |
| `form_group`         | `Fields::Renderer` (wrapper div)               | `layout: :stacked\|:inline`, `error: bool` |
| `form_label`         | `Fields::Label`                                | `required: bool`, `hidden: bool`           |
| `form_required_mark` | `Fields::Label`                                | —                                          |
| `form_details`       | `Fields::Hint`                                 | —                                          |
| `form_error`         | `Fields::Error`                                | —                                          |
| `form_input`         | `Fields::Text`, `Fields::TextArea`             | `error: bool`                              |
| `form_file`          | `Fields::File`                                 | `error: bool`                              |
| `form_select`        | `Fields::Select`                               | `error: bool`                              |
| `form_checkbox`      | `Fields::Choice` (checkbox)                    | —                                          |
| `form_radio`         | `Fields::Choice` (radio)                       | —                                          |
| `form_input_group`   | `Fields::Password`, `Fields::Search` (wrapper) | `error: bool`                              |
| `form_combobox`      | `Fields::Combobox`                             | `error: bool`                              |
| `form_input_reveal`  | `Fields::Password` (input inside group)        | —                                          |
| `form_button_reveal` | `Fields::Password` (toggle button)             | —                                          |
| `form_submit`        | `Fields::Submit` (`Builder#submit`)            | `variant: :default\|:button`               |

### Calendar

| Key                                  | Component                                                | Variants                                         |
| ------------------------------------ | -------------------------------------------------------- | ------------------------------------------------ |
| `calendar`                           | `Calendar::Renderer`, `Calendar::Month::Turbo::Renderer` | —                                                |
| `calendar_days_of_week`              | `Calendar::Month::Turbo::DaysOfWeek`                     | —                                                |
| `calendar_days_of_month`             | `Calendar::Month::Turbo::DaysOfMonth`                    | —                                                |
| `calendar_day`                       | `Calendar::Month::Turbo::DaysOfMonth` (each cell)        | `today: bool`, `selected: bool`, `outside: bool` |
| `calendar_navigation`                | `DatePicker::Navigation`                                 | —                                                |
| `calendar_navigation_navigator`      | `DatePicker::Navigator` (each button)                    | —                                                |
| `calendar_navigation_navigator_icon` | `DatePicker::Navigator` (button icon)                    | —                                                |

### Other components

| Key                | Component                          | Variants                                                                                      |
| ------------------ | ---------------------------------- | --------------------------------------------------------------------------------------------- |
| `button`           | `Button::Renderer`                 | `variant: :primary\|:secondary\|:outline\|:destructive\|:ghost\|:link`, `size: :sm\|:md\|:lg` |
| `button_group`     | `Button::Renderer`                 | `alignment:`, `direction: :row\|:col`                                                         |
| `action_list`      | `ActionList::Renderer`             | —                                                                                             |
| `action_list_item` | `ActionList::Renderer` (each item) | `active: bool`                                                                                |
| `avatar`           | `Avatar::Renderer`                 | `size:`                                                                                       |
| `card`             | `Card::Renderer`                   | —                                                                                             |
| `card_section`     | `Card::Renderer`                   | —                                                                                             |
| `icon`             | `Icon::Renderer`                   | —                                                                                             |
| `popover`          | `Popover::Renderer`                | —                                                                                             |

## Custom theme

Subclass `Themes::Base` and implement private `*_classes` methods for the keys you want to override. Return `{ classes: "…" }`.

```ruby
class MyTheme < StimulusPlumbers::Themes::Base
  private

  def form_label_classes(hidden: false, **)
    { classes: hidden ? "sr-only label" : "label" }
  end

  def form_group_classes(layout: :stacked, **)
    { classes: layout == :inline ? "field-row" : "field" }
  end
end

StimulusPlumbers.configure { |c| c.theme = MyTheme.new }
```
