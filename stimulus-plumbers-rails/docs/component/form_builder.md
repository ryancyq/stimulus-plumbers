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

| Option       | Type                   | Default                  | Description                                                      |
| ------------ | ---------------------- | ------------------------ | ---------------------------------------------------------------- |
| `label`      | String                 | Humanised attribute name | Override label text                                              |
| `hint`       | String                 | `nil`                    | Hint text rendered below the field                               |
| `error`      | String / Array         | `nil`                    | Override error message(s); defaults to `model.errors[attribute]` |
| `required`   | Boolean                | `false`                  | Adds `required` + `aria-required="true"`                         |
| `hide_label` | Boolean                | `false`                  | Renders label for screen readers only (visually hidden)          |
| `layout`     | `:stacked` / `:inline` | `:stacked`               | Stacked puts label above input; inline puts it beside            |

## Date field

Renders a calendar-grid date picker backed by `combobox-date`. Pass `html_native: true` to fall back to the native `<input type="date">`.

```erb
<%= f.date_field :birthday %>
<%= f.date_field :birthday, html_native: true %>
```

| Option        | Type    | Default | Description                           |
| ------------- | ------- | ------- | ------------------------------------- |
| `html_native` | Boolean | `false` | Use native browser date input instead |

## Time field

Renders a drum/scroll-wheel time picker backed by `combobox-time`. Pass `html_native: true` to fall back to the native `<input type="time">`.

```erb
<%= f.time_field :meeting_time %>
<%= f.time_field :meeting_time, format: :h24, step: 15 %>
<%= f.time_field :meeting_time, html_native: true %>
```

| Option        | Type            | Default | Description                           |
| ------------- | --------------- | ------- | ------------------------------------- |
| `html_native` | Boolean         | `false` | Use native browser time input instead |
| `format`      | `:h12` / `:h24` | `:h12`  | 12-hour or 24-hour clock              |
| `step`        | Integer         | `1`     | Minute interval for the drum          |

## Select / collection select

Both render a read-only listbox backed by `combobox-dropdown`. Pass `html_native: true` to fall back to the native `<select>` element.

```erb
<%= f.select            :country, country_options %>
<%= f.select            :country, country_options, html_native: true %>
<%= f.collection_select :country, Country.all, :code, :name %>
<%= f.collection_select :country, Country.all, :code, :name, html_native: true %>
```

Options follow the same `[[label, value], …]` format as Rails' `options_for_select`. Pre-selection from the model value is automatic.

| Option        | Type    | Default | Description                           |
| ------------- | ------- | ------- | ------------------------------------- |
| `html_native` | Boolean | `false` | Use native `<select>` element instead |

## Grouped collection select

Renders a grouped listbox backed by `combobox-dropdown`. Items are grouped using `role="group"` — one per entry in the collection — with each group's label announced to screen readers via `aria-label`. Pass `html_native: true` to fall back to the native `<select>` with `<optgroup>` elements.

```erb
<%= f.grouped_collection_select :country, Continent.all, :countries, :name, :code, :name %>
<%= f.grouped_collection_select :country, Continent.all, :countries, :name, :code, :name, html_native: true %>
```

Arguments match Rails' `grouped_collection_select`: `group_method`, `group_label_method`, `option_key_method` (value), `option_value_method` (display text). Pre-selection from the model value is automatic.

| Option        | Type    | Default | Description                           |
| ------------- | ------- | ------- | ------------------------------------- |
| `html_native` | Boolean | `false` | Use native `<select>` element instead |

## Time zone select

Renders a scrollable listbox of `ActiveSupport::TimeZone` entries backed by `combobox-dropdown`. Because the list is long, the combobox trigger's built-in search is especially useful here. Pass `html_native: true` to fall back to the native `<select>`.

```erb
<%= f.time_zone_select :timezone %>
<%= f.time_zone_select :timezone, ActiveSupport::TimeZone.us_zones %>
<%= f.time_zone_select :timezone, /Australia/ %>
<%= f.time_zone_select :timezone, nil, html_native: true %>
```

When `priority_zones` is given (array or Regexp), matching zones appear in a "Suggested" group and non-matching zones appear in an "Other" group. Priority zones are **not** duplicated in the second group.

| Option           | Type                   | Default                   | Description                                |
| ---------------- | ---------------------- | ------------------------- | ------------------------------------------ |
| `priority_zones` | Array / Regexp / `nil` | `nil`                     | Zones to show first in a separate group    |
| `model`          | Class                  | `ActiveSupport::TimeZone` | Zone model to use (must respond to `.all`) |
| `html_native`    | Boolean                | `false`                   | Use native `<select>` element instead      |

## Weekday select

_Requires Rails 7.1+._

Renders a seven-option listbox of day names backed by `combobox-dropdown`. Pass `html_native: true` to fall back to the native `<select>`.

```erb
<%= f.weekday_select :weekday %>
<%= f.weekday_select :weekday, index_as_value: true %>
<%= f.weekday_select :weekday, day_format: :abbr_day_names, beginning_of_week: :monday %>
<%= f.weekday_select :weekday, html_native: true %>
```

| Option              | Type    | Default                  | Description                                                    |
| ------------------- | ------- | ------------------------ | -------------------------------------------------------------- |
| `index_as_value`    | Boolean | `false`                  | Use 0–6 integer as the submitted value instead of the day name |
| `day_format`        | Symbol  | `:day_names`             | I18n key; `:abbr_day_names` for abbreviated names              |
| `beginning_of_week` | Symbol  | `Date.beginning_of_week` | First day of the week (e.g. `:monday`)                         |
| `html_native`       | Boolean | `false`                  | Use native `<select>` element instead                          |

## Search field

Renders an editable typeahead listbox backed by `combobox-dropdown`. Supply `options:` for pre-loaded items or `url:` for server-side filtering.

```erb
<%= f.search_field :city %>
<%= f.search_field :city, options: city_options %>
<%= f.search_field :city, url: cities_path %>
<%= f.search_field :city, clearable: true %>
```

| Option      | Type    | Default | Description                                                   |
| ----------- | ------- | ------- | ------------------------------------------------------------- |
| `options`   | Array   | `[]`    | Initial `[[label, value], …]` options to populate             |
| `url`       | String  | `nil`   | Endpoint for server-side filtering via `combobox-dropdown`    |
| `clearable` | Boolean | `false` | Adds a clear button wired to the `input-clearable` controller |

When `clearable: true`, the field is wrapped in an `input-clearable` controller div. The combobox trigger receives `data-input-clearable-target="input"` and a `<button aria-label="Clear search">` is appended with `data-input-clearable-target="clear"`. The button starts hidden and is shown by the controller whenever the input has a value; pressing it clears the input and returns focus. Escape also clears the input when it has a value.

## Password field

```erb
<%= f.password_field :password %>
<%= f.password_field :password, reveal: true %>
```

| Option   | Type    | Default | Description                                                                          |
| -------- | ------- | ------- | ------------------------------------------------------------------------------------ |
| `reveal` | Boolean | `false` | Wraps the input in an input-group with a show/hide button wired to `input-formatter` |

HTML options such as `autocomplete:`, `class:`, and `data:` are forwarded to the `<input>` in both the plain and `reveal: true` paths.

When `reveal: true`, the field renders an input-group wrapper with the `input-formatter` controller:

```html
<div class="...">
  <!-- field group -->
  <label for="[id]">Password</label>
  <div
    data-controller="input-formatter"
    data-input-formatter-format-value="password"
    class="flex items-center overflow-hidden rounded-md border border-gray-500"
  >
    <input type="password" data-input-formatter-target="input" />
    <button
      type="button"
      aria-label="Show password"
      aria-pressed="false"
      data-input-formatter-target="toggle"
      data-action="click->input-formatter#toggle"
    ></button>
  </div>
</div>
```

See [input-formatter.md](../../../stimulus-plumbers/docs/component/input-formatter.md) for the full controller API.

## Check box / Radio button

Both default to `layout: :inline` (label beside input). All common field options apply.

```erb
<%= f.check_box    :agree %>
<%= f.radio_button :plan, "basic" %>
<%= f.radio_button :plan, "pro" %>
```

## Collection radio buttons / check boxes

Both render inputs grouped inside a `<fieldset>/<legend>` for accessibility. The `label:` option overrides the `<legend>` text. Pass a block to customise individual item rendering; pass `html_options` to add HTML attributes to each input.

```erb
<%= f.collection_radio_buttons :plan, Plan.all, :id, :name %>
<%= f.collection_check_boxes   :roles, Role.all, :id, :name %>

<%# custom item rendering %>
<%= f.collection_radio_buttons :plan, Plan.all, :id, :name do |b| %>
  <%= b.label { b.radio_button + b.text } %>
<% end %>
```

Accessibility attributes are placed on the `<fieldset>` element rather than each individual input:

| Condition          | Attribute set on `<fieldset>`                                              |
| ------------------ | -------------------------------------------------------------------------- |
| `hint:` present    | `aria-describedby` pointing to the hint element                            |
| Model has errors   | `aria-describedby` pointing to the error element(s), `aria-invalid="true"` |
| `required: true`   | `aria-required="true"`, required mark (`*`) in the `<legend>`              |
| `hide_label: true` | `<legend>` receives the screen-reader-only class                           |

Default layout for collection variants is `:inline`.

## Standard fields

These wrap Rails' built-in helpers with the field chrome (label, hint, error):

```erb
<%= f.text_field           :name %>
<%= f.email_field          :email %>
<%= f.text_area            :bio %>
<%= f.file_field           :avatar %>
<%= f.datetime_local_field :starts_at %>
```

All native ActionView HTML options are forwarded to the underlying input. Pass any attribute you would normally pass to the Rails helper directly:

```erb
<%# placeholder, autocomplete, class, data %>
<%= f.text_field  :name,     placeholder: "Full name", autocomplete: "name" %>
<%= f.email_field :email,    class: "input-lg", data: { controller: "validator" } %>

<%# number / range constraints %>
<%= f.number_field :age,     min: 0, max: 120, step: 1 %>
<%= f.range_field  :volume,  min: 0, max: 100 %>

<%# textarea sizing %>
<%= f.text_area :bio, rows: 6, cols: 40, placeholder: "Tell us about yourself" %>

<%# file restrictions %>
<%= f.file_field :avatar, accept: "image/*", multiple: false %>
```

## Non-overridden methods

The following Rails `FormBuilder` methods are intentionally not overridden. They pass through to Rails' default implementation and do not receive field chrome (label wrapper, hint, or error elements):

| Method                                          | Behavior                                                                | Reason                                              |
| ----------------------------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------- |
| `hidden_field`                                  | Renders native hidden input, no field chrome                            | No label/hint/error needed                          |
| `label`                                         | Renders native Rails label, no theme applied                            | Standalone label; use inside a custom layout        |
| `button`                                        | Renders native Rails button                                             | Use `sp_button` helper for themed buttons           |
| `fields_for` / `fields`                         | Nested builder inherits `StimulusPlumbers::Form::Builder` automatically | No override needed                                  |
| `date_select`, `time_select`, `datetime_select` | Falls through to Rails — no field chrome                                | Legacy API; use `date_field` / `time_field` instead |

## Accessibility

Every field automatically:

- Links `<label for="…">` to the input `id` (or `<fieldset>`/`<legend>` for collection fields)
- Adds `aria-describedby` pointing to hint/error elements when present
- Sets `aria-invalid="true"` when the model has errors for the attribute
- Renders errors as `<p role="alert">` so they are announced by screen readers
- Adds `required` + `aria-required="true"` when `required: true`; single inputs receive the native `required` attribute while collection fields receive `aria-required` on the `<fieldset>`
- Renders a required mark (`*`, `aria-hidden="true"`) in the `<label>` or `<legend>`
