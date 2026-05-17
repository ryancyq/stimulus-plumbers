# Theming

Stimulus Plumbers uses a theme system to apply presentational CSS classes to form fields and components. The default theme is Tailwind CSS. Custom themes can be created by subclassing `Themes::Base`.

## Configuration

```ruby
# config/initializers/stimulus_plumbers.rb
StimulusPlumbers.configure do |config|
  config.theme.use(:tailwind)
  # config.theme.use(MyCustomTheme.new)
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

| Key                                  | Component                                         | Variants                                         |
| ------------------------------------ | ------------------------------------------------- | ------------------------------------------------ |
| `calendar`                           | `Calendar`, `Calendar::Month::Turbo`              | —                                                |
| `calendar_days_of_week`              | `Calendar::Month::Turbo::DaysOfWeek`              | —                                                |
| `calendar_days_of_month`             | `Calendar::Month::Turbo::DaysOfMonth`             | —                                                |
| `calendar_day`                       | `Calendar::Month::Turbo::DaysOfMonth` (each cell) | `today: bool`, `selected: bool`, `outside: bool` |
| `calendar_navigation`                | `DatePicker::Navigation`                          | —                                                |
| `calendar_navigation_navigator`      | `DatePicker::Navigator` (each button)             | —                                                |
| `calendar_navigation_navigator_icon` | `DatePicker::Navigator` (button icon)             | —                                                |

### Combobox

| Key                             | Component                                                                           | Variants                           |
| ------------------------------- | ----------------------------------------------------------------------------------- | ---------------------------------- |
| `combobox_listbox`              | `Combobox::Dropdown`, `Combobox::Autocomplete`, `Combobox::Time::Drum` (the `<ul>`) | —                                  |
| `combobox_option`               | `Combobox::Options::Option`                                                         | `selected: bool`, `disabled: bool` |
| `combobox_option_group`         | `Combobox::Options::OptionGroup`                                                    | —                                  |
| `combobox_autocomplete_loading` | `Combobox::Autocomplete` (loading indicator)                                        | —                                  |
| `combobox_autocomplete_empty`   | `Combobox::Autocomplete` (no-results message)                                       | —                                  |
| `combobox_time`                 | `Combobox::Time` (drum wrapper)                                                     | —                                  |

### Other components

| Key                | Component          | Variants                                                                                      |
| ------------------ | ------------------ | --------------------------------------------------------------------------------------------- |
| `button`           | `Button`           | `variant: :primary\|:secondary\|:outline\|:destructive\|:ghost\|:link`, `size: :sm\|:md\|:lg` |
| `button_group`     | `Button::Group`    | `alignment:`, `direction: :row\|:col`                                                         |
| `action_list`      | `ActionList`       | —                                                                                             |
| `action_list_item` | `ActionList::Item` | `active: bool`                                                                                |
| `avatar`           | `Avatar`           | `size:`                                                                                       |
| `card`             | `Card`             | —                                                                                             |
| `card_section`     | `Card::Section`    | —                                                                                             |
| `icon`             | `Icon`             | —                                                                                             |
| `popover`          | `Popover`          | —                                                                                             |

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

StimulusPlumbers.configure do |c|
  c.theme.register(:my_theme, MyTheme)
  c.theme.use(:my_theme)
end
```
