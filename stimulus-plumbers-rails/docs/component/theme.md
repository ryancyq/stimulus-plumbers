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

| Key                          | Component                                                                        | Variants                           |
| ---------------------------- | -------------------------------------------------------------------------------- | ---------------------------------- |
| `combobox_listbox`           | `Combobox::Dropdown`, `Combobox::Typeahead`, `Combobox::Time::Drum` (the `<ul>`) | —                                  |
| `combobox_option`            | `Combobox::Options::Option`                                                      | `selected: bool`, `disabled: bool` |
| `combobox_option_group`      | `Combobox::Options::OptionGroup`                                                 | —                                  |
| `combobox_typeahead_loading` | `Combobox::Typeahead` (loading indicator)                                        | —                                  |
| `combobox_typeahead_empty`   | `Combobox::Typeahead` (no-results message)                                       | —                                  |
| `combobox_time`              | `Combobox::Time` (drum wrapper)                                                  | —                                  |

### Other components

| Key                | Component                                                       | Variants                                                                                                                                                                |
| ------------------ | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `button`           | `Button`                                                        | `type: :primary\|:secondary\|:tertiary\|:outline\|:ghost\|:fab\|:dashed`, `variant: :default\|:success\|:destructive\|:warning\|:info`, `size: :xs\|:sm\|:md\|:lg\|:xl` |
| `button_group`     | `Button::Group`                                                 | `alignment:`, `direction: :row\|:col`                                                                                                                                   |
| `button_icon`      | `Button` (icon rendered via `icon_leading:` / `icon_trailing:`) | —                                                                                                                                                                       |
| `action_list`      | `ActionList`                                                    | — _(accepts `role:` at render time, default `"list"`)_                                                                                                                  |
| `action_list_item` | `ActionList::Item`                                              | `active: bool`                                                                                                                                                          |
| `avatar`           | `Avatar`                                                        | `size:`                                                                                                                                                                 |
| `card`             | `Card`                                                          | —                                                                                                                                                                       |
| `card_section`     | `Card::Section`                                                 | —                                                                                                                                                                       |
| `icon`             | `Icon`                                                          | —                                                                                                                                                                       |
| `popover`          | `Popover`                                                       | —                                                                                                                                                                       |

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

### Providing icons

Override `icons` to supply icons to the `Icon` component. The return value must respond to `[]` and `key?`:

```ruby
class MyTheme < StimulusPlumbers::Themes::Base
  def icons
    @icons ||= {
      "check" => {
        elements: [{ tag: :path, d: "M5 13l4 4L19 7", stroke_linecap: :round, stroke_linejoin: :round }]
      }
    }
  end
end
```

Each icon is a hash with optional SVG-level keys (`fill:`, `stroke:`, `view_box:`, `stroke_width:`, `width:`, `height:`) and a required `elements:` array. Each element needs a `tag:` (`:path`, `:circle`, `:rect`, etc.) and its attributes (`d:`, `fill:`, `opacity:`, `stroke_linecap:`, etc.). Unknown keys are ignored; missing SVG keys fall back to defaults (`fill: "none"`, `stroke: "currentColor"`, `view_box: "0 0 24 24"`, `stroke_width: 1.5`).

If `icons[name]` returns `nil`, `Icon` renders an empty `<span>` fallback.

#### File-based icon sources

For SVG-file-backed icon sources, the core gem provides two utilities in `StimulusPlumbers::Themes::Icons`:

**`Icons::External`** — a module that parses SVG files into icon hashes. Include it into any module that implements `svg_path(key)`:

```ruby
module MyIcons
  include StimulusPlumbers::Themes::Icons::External
  extend self

  private

  def svg_path(key)
    File.expand_path("#{key}.svg", __dir__)
  end
end
```

`External` exposes `include?(key)` and `fetch(key)`, where `fetch` returns the parsed icon hash or `nil` if the file doesn't exist. Override `svg_defaults(key)` to inject source-specific SVG attribute defaults.

**`Icons::Registry`** — a lazy-loading `SimpleDelegator` wrapping a `Hash`. Results are memoized on first access. Takes `sources:` (array of icon source modules) and optional `aliases:`:

```ruby
ICONS = StimulusPlumbers::Themes::Icons::Registry.new(
  sources: [MyIcons],
  aliases: { "close" => "x-mark" }
)
```

Sources are tried in order; the first non-nil result wins. Aliases are resolved before querying sources, so `icons["close"]` fetches `"x-mark"` from the sources.

### Schema validators

When defining a custom schema (advanced), the `validate:` key accepts:

| Type          | Behaviour                                                                        |
| ------------- | -------------------------------------------------------------------------------- |
| Array / Range | Value must be `include?`-d                                                       |
| Symbol        | Method called on the theme; return must respond to `include?` or be truthy/falsy |
| Proc          | Called via `instance_exec`; same return conventions                              |
| `nil`         | No validation — any value accepted                                               |
