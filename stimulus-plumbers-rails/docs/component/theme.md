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

| Key                    | Component                                                                                         | Variants                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `form_group`           | `Fields::Group` (wrapper div)                                                                     | `layout: :stacked\|:inline`, `error: bool` |
| `form_label`           | `Fields::Label`, `Fields::Fieldset` (`<legend>`)                                                  | `required: bool`, `hidden: bool`           |
| `form_required_mark`   | `Fields::Label`, `Fields::Fieldset` (required `*` span)                                           | —                                          |
| `form_details`         | `Fields::Hint`                                                                                    | —                                          |
| `form_error`           | `Fields::Error`                                                                                   | —                                          |
| `form_input`           | `Fields::Inputs::Text`, `Fields::Inputs::Datetime`                                                | `error: bool`                              |
| `form_textarea`        | `Fields::Inputs::TextArea`                                                                        | `error: bool`                              |
| `form_file`            | `Fields::Inputs::File`                                                                            | `error: bool`                              |
| `form_select`          | `Fields::Inputs::Select`                                                                          | `error: bool`                              |
| `form_checkbox`        | `Fields::Inputs::Choice` (single and collection checkbox)                                         | `error: bool`                              |
| `form_radio`           | `Fields::Inputs::Choice` (single and collection radio)                                            | `error: bool`                              |
| `form_input_group`     | `Fields::InputGroup` (wrapper for input + adornment)                                              | `error: bool`                              |
| `form_combobox`        | `Fields::Inputs::Select`, `Fields::Inputs::Search`, `Fields::Inputs::Datetime` (combobox wrapper) | `error: bool`                              |
| `form_input_clearable` | `Fields::Inputs::Search` (combobox trigger inside clearable wrapper)                              | —                                          |
| `form_button_clear`    | `Fields::Inputs::Search` (clear button in clearable wrapper)                                      | —                                          |
| `form_input_reveal`    | `Fields::Inputs::Password` (input inside reveal group)                                            | `error: bool`                              |
| `form_button_reveal`   | `Fields::Inputs::Password` (show/hide toggle button)                                              | —                                          |
| `form_submit`          | `Fields::Inputs::Submit` (`Builder#submit`)                                                       | `variant: :default\|:button`               |

### Calendar

| Key                             | Component                                         | Variants                                         |
| ------------------------------- | ------------------------------------------------- | ------------------------------------------------ |
| `calendar`                      | `Calendar`, `Calendar::Month::Turbo`              | —                                                |
| `calendar_days_of_week`         | `Calendar::Month::Turbo::DaysOfWeek`              | —                                                |
| `calendar_days_of_month`        | `Calendar::Month::Turbo::DaysOfMonth`             | —                                                |
| `calendar_day`                  | `Calendar::Month::Turbo::DaysOfMonth` (each cell) | `today: bool`, `selected: bool`, `outside: bool` |
| `calendar_navigation`           | `DatePicker::Navigation`                          | —                                                |
| `calendar_navigation_navigator` | `DatePicker::Navigator` (each button)             | —                                                |

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

| Key                | Component                                                       | Variants                                                                                      |
| ------------------ | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `button`           | `Button`                                                        | `variant: :primary\|:secondary\|:outline\|:destructive\|:ghost\|:link`, `size: :sm\|:md\|:lg` |
| `button_group`     | `Button::Group`                                                 | `alignment:`, `direction: :row\|:col`                                                         |
| `button_icon`      | `Button` (icon rendered via `icon_leading:` / `icon_trailing:`) | —                                                                                             |
| `action_list`      | `ActionList`                                                    | — _(accepts `role:` at render time, default `"list"`)_                                        |
| `action_list_item` | `ActionList::Item`                                              | `active: bool`                                                                                |
| `avatar`           | `Avatar`                                                        | `size:`                                                                                       |
| `card`             | `Card`                                                          | —                                                                                             |
| `card_section`     | `Card::Section`                                                 | —                                                                                             |
| `icon`             | `Icon`                                                          | —                                                                                             |
| `popover`          | `Popover`                                                       | —                                                                                             |

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
