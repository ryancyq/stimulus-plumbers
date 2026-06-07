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

| Key                            | Component                                                               | Variants                                          |
| ------------------------------ | ----------------------------------------------------------------------- | ------------------------------------------------- |
| `form_group`                   | `Fields::Group` (wrapper div)                                           | `layout: :stacked\|:inline`, `error: bool`        |
| `form_field_label`             | `Fields::Label`, `Fields::Fieldset` (`<legend>`)                        | `required: bool`, `hidden: bool`                  |
| `form_field_required_mark`     | Required `*` span in label/legend                                       | —                                                 |
| `form_field_hint`              | `Fields::Hint`                                                          | —                                                 |
| `form_field_error`             | `Fields::Error`                                                         | —                                                 |
| `form_field_choice_items`      | Collection wrapper (the items container inside a fieldset)              | `layout: :stacked\|:inline`                       |
| `form_field_checkbox_label`    | `<label>` wrapping each checkbox in a collection                        | `type: :default\|:button\|:card`, `variant:`      |
| `form_field_radio_label`       | `<label>` for each radio button in a collection                         | `type: :default\|:button\|:card`, `variant:`      |
| `form_field_input`             | Text-like `<input>` (text, email, number, url, tel, …)                  | `error: bool`                                     |
| `form_field_floating`          | `<input>` inside a floating-label field                                 | `type: :filled\|:outlined\|:standard`, `error: bool` |
| `form_field_floating_group`    | Wrapper `<div>` that groups floating input + label                      | `type: :filled\|:outlined\|:standard`             |
| `form_field_floating_label`    | Animated `<label>` that floats above the input                          | `type: :filled\|:outlined\|:standard`, `error: bool` |
| `form_field_input_textarea`    | `<textarea>`                                                            | `error: bool`                                     |
| `form_field_input_file`        | `<input type="file">`                                                   | `error: bool`                                     |
| `form_field_input_select`      | Native `<select>`                                                       | `error: bool`                                     |
| `form_field_input_checkbox`    | `<input type="checkbox">` element in a collection                       | `type: :default\|:button\|:card`, `variant:`, `error: bool` |
| `form_field_input_radio`       | `<input type="radio">` element in a collection                          | `type: :default\|:button\|:card`, `variant:`, `error: bool` |
| `form_field_input_combobox`    | Combobox wrapper input (resets child input/trigger styles)              | `error: bool`                                     |
| `form_field_input_reveal`      | Password reveal wrapper (resets child input styles)                     | `error: bool`                                     |
| `form_field_input_clearable`   | Clearable wrapper (resets child input styles)                           | —                                                 |
| `form_field_input_button_reveal` | Show/hide toggle button inside a password field                       | —                                                 |
| `form_field_input_button_clear`  | Clear button inside a search/clearable field                           | —                                                 |
| `form_submit`                  | Submit button (`Builder#submit`)                                        | `type: :link\|:default\|…`, `variant:`            |
| `input_group`                  | `Fields::InputGroup` (input + adornment wrapper)                        | `error: bool`                                     |

### Calendar

| Key                       | Component                                              | Variants                        |
| ------------------------- | ------------------------------------------------------ | ------------------------------- |
| `calendar`                | `Calendar`, `Calendar::Turbo`                          | —                               |
| `calendar_days_of_week`   | `Calendar::Turbo::DaysOfWeek`                          | —                               |
| `calendar_days_of_month`  | `Calendar::Turbo::DaysOfMonth`                         | —                               |
| `calendar_row`            | `Calendar::Turbo::DaysOfMonth` (each week row)         | —                               |
| `calendar_day`            | `Calendar::Turbo::DaysOfMonth` (each day cell)         | `outside: bool`                 |
| `calendar_months_of_year` | `Calendar::Turbo::MonthsOfYear` (rowgroup wrapper)     | —                               |
| `calendar_month`          | `Calendar::Turbo::MonthsOfYear` (each month cell)      | —                               |
| `calendar_years_of_decade`| `Calendar::Turbo::YearsOfDecade` (rowgroup wrapper)    | —                               |
| `calendar_year`           | `Calendar::Turbo::YearsOfDecade` (each year cell)      | —                               |
| `calendar_quarter_grid`   | `Calendar::Turbo` year/decade grid wrapper (4-col grid)| —                               |

### Combobox

| Key                                  | Component                                                                        | Variants                           |
| ------------------------------------ | -------------------------------------------------------------------------------- | ---------------------------------- |
| `combobox_listbox`                   | `Combobox::Dropdown`, `Combobox::Typeahead`, `Combobox::Time::Drum` (the `<ul>`) | —                                  |
| `combobox_option`                    | `Combobox::Options::Option`                                                      | `selected: bool`, `disabled: bool` |
| `combobox_option_group`              | `Combobox::Options::OptionGroup`                                                 | —                                  |
| `combobox_typeahead_loading`         | `Combobox::Typeahead` (loading indicator)                                        | —                                  |
| `combobox_typeahead_empty`           | `Combobox::Typeahead` (no-results message)                                       | —                                  |
| `combobox_time`                      | `Combobox::Time` (drum wrapper)                                                  | —                                  |
| `combobox_date_navigation`           | `Combobox::Date::Navigation` (nav bar)                                           | —                                  |
| `combobox_date_navigation_navigator` | `Combobox::Date::Navigator` (each prev/next/title button)                        | —                                  |

### Other components

| Key                | Component                                                       | Variants                                                                                                                                                                |
| ------------------ | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `button`           | `Button`                                                        | `type: :default\|:outline\|:ghost\|:fab\|:fab_outline\|:dashed\|:card`, `variant: :primary\|:secondary\|:tertiary\|:success\|:destructive\|:warning\|:info`, `size: :xs\|:sm\|:md\|:lg\|:xl` |
| `button_group`     | `Button::Group`                                                 | `layout: :inline\|:stacked`                                                                                                                                             |
| `button_icon`      | `Button` (icon rendered via `icon_leading:` / `icon_trailing:`) | —                                                                                                                                                                       |
| `link`             | `Link`                                                          | `type: :default\|:button\|:card`, `variant: :default\|:success\|:destructive\|:warning\|:info`                                                                         |
| `link_icon`        | `Link` (icon rendered via `icon_leading:` / `icon_trailing:`)   | —                                                                                                                                                                       |
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
