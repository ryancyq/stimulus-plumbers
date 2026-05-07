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
