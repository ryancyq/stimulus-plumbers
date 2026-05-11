# Form Builder

`StimulusPlumbers::Form::Builder` extends Rails' `ActionView::Helpers::FormBuilder` with accessible form fields. Each field renders a label, the input widget, an optional hint, and inline error messages automatically wired to the model.

## Setup

Use globally:

```ruby
# config/application.rb
config.action_view.default_form_builder = StimulusPlumbers::Form::Builder
```

Or per form:

```erb
<%= form_with model: @user, builder: StimulusPlumbers::Form::Builder do |f| %>
  …
<% end %>
```

## Field options

All field methods accept these options in addition to their own:

| Option             | Type                      | Default                  | Description                                                      |
| ------------------ | ------------------------- | ------------------------ | ---------------------------------------------------------------- |
| `label`            | String                    | Humanised attribute name | Override label text                                              |
| `details`          | String                    | `nil`                    | Hint text rendered below the field                               |
| `error`            | String / Array            | `nil`                    | Override error message(s); defaults to `model.errors[attribute]` |
| `required`         | Boolean                   | `false`                  | Adds `required` + `aria-required="true"`                         |
| `label_visibility` | `:visible` / `:exclusive` | `:visible`               | `:exclusive` renders label for screen readers only               |
| `layout`           | `:stacked` / `:inline`    | `:stacked`               | Stacked puts label above input; inline puts it beside            |

## Combobox field

```erb
<%= f.combobox_field :birthday,     type: :date %>
<%= f.combobox_field :country,      type: :dropdown,     options: country_options %>
<%= f.combobox_field :city,         type: :autocomplete, src: cities_path %>
<%= f.combobox_field :meeting_time, type: :time,         format: :h24, step: 15 %>
```

| `type`          | Variant                                   |
| --------------- | ----------------------------------------- |
| `:date`         | Date picker with calendar grid            |
| `:dropdown`     | Read-only listbox                         |
| `:autocomplete` | Editable listbox with fuzzy/server filter |
| `:time`         | Drum/scroll-wheel time picker             |

All combobox-specific options (`value`, `src`, `format`, `step`, `options`, `label`) are forwarded to the underlying `sp_combobox_*` helper. See [combobox.md](combobox.md) for option details.

## Password field

```erb
<%= f.password_field :password %>
<%= f.password_field :password, reveal: true %>
```

| Option   | Type    | Default | Description                                                                       |
| -------- | ------- | ------- | --------------------------------------------------------------------------------- |
| `reveal` | Boolean | `false` | Wraps the input in an input-group with a show/hide button wired to `input-format` |

When `reveal: true`, the field renders an input-group wrapper with the `input-format` controller:

```html
<div class="...">
  <!-- field group -->
  <label for="[id]">Password</label>
  <div
    data-controller="input-format"
    data-input-format-type-value="password"
    class="flex items-center overflow-hidden rounded-md border border-gray-500"
  >
    <input type="password" data-input-format-target="input" />
    <button
      type="button"
      aria-label="Show password"
      aria-pressed="false"
      data-input-format-target="toggle"
      data-action="click->input-format#toggle"
    ></button>
  </div>
</div>
```

See [input-format.md](../../../stimulus-plumbers/docs/component/input-format.md) for the full controller API.

## Search field

```erb
<%= f.search_field :query %>
<%= f.search_field :query, clearable: true %>
```

| Option      | Type    | Default | Description                                                                            |
| ----------- | ------- | ------- | -------------------------------------------------------------------------------------- |
| `clearable` | Boolean | `false` | Wraps the input in an input-group with a "Clear search" button wired to `input-search` |

When `clearable: true`, the field renders an input-group wrapper with the `input-search` controller:

```html
<div class="...">
  <!-- field group -->
  <label for="[id]">Query</label>
  <div
    role="search"
    data-controller="input-search"
    class="flex items-center overflow-hidden rounded-md border border-gray-500"
  >
    <input
      type="search"
      inputmode="search"
      data-input-search-target="input"
      ...
    />
    <button
      type="button"
      aria-label="Clear search"
      data-input-search-target="clear"
      data-action="click->input-search#clear"
    ></button>
  </div>
</div>
```

The `role="search"` landmark identifies the region for screen readers. The native webkit clear button is suppressed via CSS (`input[type=search]::-webkit-search-cancel-button { appearance: none }`) so only the controlled button is visible.

## Standard fields

These wrap Rails' built-in helpers with the field chrome (label, hint, error):

```erb
<%= f.text_field     :name %>
<%= f.email_field    :email %>
<%= f.password_field :password %>
<%= f.text_area      :bio %>
<%= f.file_field     :avatar %>
<%= f.select         :role, Role.options %>
<%= f.check_box      :agree %>
<%= f.radio_button   :plan, "basic" %>
```

## Accessibility

Every field automatically:

- Links `<label for="…">` to the input `id`
- Adds `aria-describedby` pointing to hint/error elements when present
- Sets `aria-invalid="true"` when the model has errors for the attribute
- Renders errors as `<p role="alert">` so they are announced by screen readers
- Adds `required` + `aria-required="true"` when `required: true`
