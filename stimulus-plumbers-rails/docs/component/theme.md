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

## Built-in themes

### Tailwind

The `TailwindTheme` provides Tailwind CSS classes for all form field slots. No additional configuration is needed — classes are applied automatically when `config.theme = :tailwind`.

**Form field slots**

| Slot                | Classes                                                                 |
| ------------------- | ----------------------------------------------------------------------- |
| Form group wrapper  | `flex gap-1 mb-3 flex-col` (stacked) / `flex-row items-center` (inline) |
| Label               | `text-sm font-medium text-gray-900`                                     |
| Required mark (`*`) | `text-red-700 ml-0.5`                                                   |
| Hint text           | `text-xs text-gray-600`                                                 |
| Error text          | `text-xs text-red-700`                                                  |
| Input (default)     | `w-full rounded-md border border-gray-500 px-3 py-2 text-sm …`          |
| Input (error)       | `… border-red-700 focus:ring-red-700`                                   |

## Custom theme

Subclass `Themes::Base` and override the `*_classes` methods for the slots you want to customise:

```ruby
class MyTheme < StimulusPlumbers::Themes::Base
  private

  def form_input_classes(error: false, **)
    { classes: error ? "input input-error" : "input" }
  end

  def form_label_classes(**)
    { classes: "label" }
  end

  def form_error_classes(**)
    { classes: "text-error text-xs" }
  end

  def form_group_classes(layout: :stacked, **)
    { classes: layout == :inline ? "field-row" : "field" }
  end
end
```

Then configure it:

```ruby
StimulusPlumbers.configure do |config|
  config.theme = MyTheme.new
end
```

## Theme resolution

The `theme.resolve(component, **variants)` method returns `{ classes: "…" }` for a given component slot. The form builder and component renderers call this automatically — you typically don't need to call it directly.

Unrecognised component keys log a warning rather than raising an error.
