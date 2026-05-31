# Form Builder

`StimulusPlumbers::Form::Builder` extends Rails' `ActionView::Helpers::FormBuilder` with accessible form fields.

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

## Two levels of API

### Level 1 — Native helpers (theme classes only)

The standard ActionView method overrides (`email_field`, `text_area`, `check_box`, etc.) apply theme CSS classes to the input but render **no** label, hint, or error wrapper. Use them when you control the surrounding markup yourself.

```erb
<%= f.email_field    :email %>
<%= f.text_area      :bio %>
<%= f.check_box      :agree %>
<%= f.radio_button   :plan, "basic" %>
<%= f.date_field     :birthday %>
<%= f.time_field     :meeting_time %>
<%= f.select         :country, country_options %>
<%= f.collection_select :country, Country.all, :code, :name %>
<%= f.time_zone_select  :timezone %>
<%= f.search_field   :query %>
```

All native HTML options (`placeholder:`, `autocomplete:`, `class:`, `data:`, etc.) are forwarded to the underlying input.

### Level 2 — Full field helpers (label + input + hint + error)

Four builder methods render a complete accessible field: a visible label, the input widget, an optional hint, and inline error messages wired automatically to the model.

| Method                                                                            | Purpose                                                       |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `f.field(attr, as:, **opts)`                                                      | Text-like inputs, check box, combobox date/time/select/search |
| `f.collection_field(attr, as:, collection:, value_method:, text_method:, **opts)` | Combobox from a collection                                    |
| `f.choice(attr, as:, collection:, value_method:, text_method:, **opts)`           | Group of radio buttons or check boxes in a `<fieldset>`       |

## Field options

All full-field helpers accept these options in addition to their own:

| Option       | Type                                                                          | Default                  | Description                                                      |
| ------------ | ----------------------------------------------------------------------------- | ------------------------ | ---------------------------------------------------------------- |
| `label`      | String                                                                        | Humanised attribute name | Override label text                                              |
| `hint`       | String                                                                        | `nil`                    | Hint text rendered below the field                               |
| `error`      | String / Array                                                                | `nil`                    | Override error message(s); defaults to `model.errors[attribute]` |
| `required`   | Boolean                                                                       | `false`                  | Adds `required` + `aria-required="true"`                         |
| `hide_label` | Boolean                                                                       | `false`                  | Renders label for screen readers only (visually hidden)          |
| `layout`     | `:stacked` / `:inline`                                                        | `:stacked`               | Stacked puts label above input; inline puts it beside            |
| `variant`    | `:default` / `:floating_filled` / `:floating_outlined` / `:floating_standard` | `:default`               | Floating label style; label animates above the input on focus    |

## Floating label fields

Three visual styles are available via `variant:`. The label starts inside the input and animates above it on focus or when the field has a value. Only compatible with text-like inputs.

| Variant              | Style                                                |
| -------------------- | ---------------------------------------------------- |
| `:floating_filled`   | Filled background, bottom border only                |
| `:floating_outlined` | Full border, label clips through the border on float |
| `:floating_standard` | Bottom border only, no background                    |

```erb
<%= f.field :email,    as: :email, label: "Email",    variant: :floating_filled %>
<%= f.field :username, as: :text,  label: "Username", variant: :floating_outlined %>
<%= f.field :name,     as: :text,  label: "Name",     variant: :floating_standard, required: true %>
```

HTML structure (theme classes omitted):

```html
<div>
  <div>
    <input id="…" placeholder=" " aria-… />
    <label for="…" id="…">Email</label>
  </div>
  <p id="…_hint">…</p>
  <p id="…_error" role="alert">…</p>
</div>
```

## f.field

### Text-like inputs

```erb
<%= f.field :name,       as: :text %>
<%= f.field :email,      as: :email,    label: "E-mail address", required: true %>
<%= f.field :website,    as: :url %>
<%= f.field :phone,      as: :tel %>
<%= f.field :age,        as: :number,   min: 0, max: 120 %>
<%= f.field :volume,     as: :range,    min: 0, max: 100 %>
<%= f.field :bio,        as: :text_area, hint: "Tell us about yourself." %>
<%= f.field :avatar,     as: :file %>
<%= f.field :password,   as: :password, reveal: true %>
```

Valid `as:` values for `f.field`: `:text`, `:email`, `:number`, `:url`, `:tel`, `:color`, `:month`, `:week`, `:range`, `:datetime_local`, `:text_area`, `:file`, `:password`, `:check_box`.

### Date field

Renders a calendar-grid date picker backed by `combobox-date`.

```erb
<%= f.field :birthday, as: :date %>
<%= f.field :birthday, as: :date, label: "Date of birth", icon_trailing: "calendar" %>
```

To render a plain `<input type="date">` without field chrome use the native helper:

```erb
<%= f.date_field :birthday %>
```

### Time field

Renders a drum/scroll-wheel time picker backed by `combobox-time`.

```erb
<%= f.field :meeting_time, as: :time %>
<%= f.field :meeting_time, as: :time, format: :h24, step: 15 %>
```

| Option   | Type            | Default | Description                  |
| -------- | --------------- | ------- | ---------------------------- |
| `format` | `:h12` / `:h24` | `:h12`  | 12-hour or 24-hour clock     |
| `step`   | Integer         | `1`     | Minute interval for the drum |

To render a plain `<input type="time">` without field chrome use the native helper:

```erb
<%= f.time_field :meeting_time %>
```

### Select (combobox dropdown)

Renders a read-only listbox backed by `combobox-dropdown`.

```erb
<%= f.field :country, as: :select, choices: country_options %>
<%= f.field :country, as: :select, choices: country_options, include_blank: "Choose…" %>
<%= f.field :country, as: :select, choices: country_options, prompt: "Select a country" %>
```

Options follow the `[[label, value], …]` format of Rails' `options_for_select`. Pre-selection from the model value is automatic; pass `selected:` to override.

| Option          | Type             | Default     | Description                                            |
| --------------- | ---------------- | ----------- | ------------------------------------------------------ |
| `choices`       | Array            | `[]`        | `[[label, value], …]` options                          |
| `include_blank` | Boolean / String | `nil`       | Adds a blank option; string value is used as its label |
| `prompt`        | String           | `nil`       | Adds a disabled prompt option at the top               |
| `selected`      | String           | model value | Override the pre-selected value                        |

To render a plain `<select>` without field chrome use the native helper:

```erb
<%= f.select :country, country_options %>
```

### Search field (combobox typeahead)

Renders an editable typeahead listbox backed by `combobox-dropdown`. Supply `choices:` for pre-loaded items or `url:` for server-side filtering.

```erb
<%= f.field :city, as: :search %>
<%= f.field :city, as: :search, choices: city_options %>
<%= f.field :city, as: :search, url: cities_path %>
<%= f.field :city, as: :search, clearable: true %>
```

| Option      | Type    | Default | Description                                                   |
| ----------- | ------- | ------- | ------------------------------------------------------------- |
| `choices`   | Array   | `[]`    | Initial `[[label, value], …]` options to populate             |
| `url`       | String  | `nil`   | Endpoint for server-side filtering                            |
| `clearable` | Boolean | `false` | Adds a clear button wired to the `input-clearable` controller |

When `clearable: true`, the field is wrapped in an `input-clearable` controller div with a hidden `<button aria-label="Clear search">`. The button appears when the input has a value; pressing it clears the input.

To render a plain `<input type="search">` without field chrome use the native helper (`clearable:` is still supported):

```erb
<%= f.search_field :query %>
<%= f.search_field :query, clearable: true %>
```

### Password field

```erb
<%= f.field :password, as: :password %>
<%= f.field :password, as: :password, reveal: true %>
```

| Option   | Type    | Default | Description                                                                          |
| -------- | ------- | ------- | ------------------------------------------------------------------------------------ |
| `reveal` | Boolean | `false` | Wraps the input in an input-group with a show/hide button wired to `input-formatter` |

`reveal:` also works with the native helper (no field chrome):

```erb
<%= f.password_field :password, reveal: true %>
```

## f.collection_field

Renders a combobox dropdown built from a collection.

### collection_select

```erb
<%= f.collection_field :country, as: :collection_select,
      collection: Country.all, value_method: :code, text_method: :name %>
```

### grouped_collection_select

Items are grouped using `role="group"` with each group's label announced via `aria-label`.

```erb
<%= f.collection_field :country, as: :grouped_collection_select,
      collection:          Continent.all,
      value_method:        :code,
      text_method:         :name,
      group_method:        :countries,
      group_label_method:  :name %>
```

To render native `<select>`/`<optgroup>` elements without field chrome use the native helpers:

```erb
<%= f.collection_select         :country, Country.all, :code, :name %>
<%= f.grouped_collection_select :country, Continent.all, :countries, :name, :code, :name %>
<%= f.time_zone_select          :timezone %>
<%= f.weekday_select            :weekday %>
```

## f.field (check_box)

Renders a single check box with an explicit `<label for="…">` associated via `for`/`id`.

```erb
<%= f.field :agree,      as: :check_box %>
<%= f.field :newsletter, as: :check_box, label: "Subscribe to newsletter" %>
<%= f.field :terms,      as: :check_box, required: true, hint: "You must accept the terms." %>
```

## f.choice

Renders a group of inputs inside a `<fieldset>`/`<legend>` for accessibility. The `label:` option overrides the `<legend>` text. Each item uses an explicit `<label for="…">` associated via `for`/`id`.

```erb
<%# Radio buttons %>
<%= f.choice :plan, as: :radio,
      collection: Plan.all, value_method: :id, text_method: :name %>

<%# Check boxes %>
<%= f.choice :roles, as: :check_box,
      collection: Role.all, value_method: :id, text_method: :name %>

<%# With field options %>
<%= f.choice :plan, as: :radio,
      collection:   Plan.all,
      value_method: :id,
      text_method:  :name,
      label:        "Subscription plan",
      hint:         "Choose the plan that fits your needs.",
      required:     true %>
```

Accessibility attributes are placed on the `<fieldset>` element:

| Condition          | Attribute set on `<fieldset>`                                          |
| ------------------ | ---------------------------------------------------------------------- |
| `hint:` present    | `aria-describedby` pointing to the hint element                        |
| Model has errors   | `aria-describedby` pointing to error element(s), `aria-invalid="true"` |
| `required: true`   | required mark (`*`) in the `<legend>`                                  |
| `hide_label: true` | `<legend>` receives the screen-reader-only class                       |

To render themed inputs without the fieldset wrapper use the native helpers:

```erb
<%= f.radio_button          :plan, "basic" %>
<%= f.collection_radio_buttons :plan, Plan.all, :id, :name %>
<%= f.check_box             :agree %>
<%= f.collection_check_boxes   :roles, Role.all, :id, :name %>
```

## Non-overridden methods

The following Rails `FormBuilder` methods are intentionally not overridden. They pass through to Rails' default implementation:

| Method                                          | Reason                                                                  |
| ----------------------------------------------- | ----------------------------------------------------------------------- |
| `hidden_field`                                  | No label/hint/error needed                                              |
| `label`                                         | Standalone label; use inside a custom layout                            |
| `button`                                        | Use `sp_button` helper for themed buttons                               |
| `fields_for` / `fields`                         | Nested builder inherits `StimulusPlumbers::Form::Builder` automatically |
| `date_select`, `time_select`, `datetime_select` | Legacy API; use `f.field(as: :date/time)` instead                       |

## Accessibility

Every full-field helper automatically:

- Links `<label for="…">` to the input `id` (or `<fieldset>`/`<legend>` for collection fields)
- Adds `aria-describedby` pointing to hint/error elements when present
- Sets `aria-invalid="true"` when the model has errors for the attribute
- Renders errors as `<p role="alert">` so they are announced by screen readers
- Adds `required` + `aria-required="true"` when `required: true`; single inputs receive the native `required` attribute while collection fields receive `aria-required` on the `<fieldset>`
- Renders a required mark (`*`, `aria-hidden="true"`) in the `<label>` or `<legend>`
