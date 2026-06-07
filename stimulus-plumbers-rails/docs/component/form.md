# Form

`StimulusPlumbers::Form::Builder` extends Rails' `ActionView::Helpers::FormBuilder` with accessible, themed form fields.

## Setup

```ruby
# config/application.rb — use globally
config.action_view.default_form_builder = StimulusPlumbers::Form::Builder
```

```erb
<%# or per form %>
<%= form_with model: @user, builder: StimulusPlumbers::Form::Builder do |f| %>
  …
<% end %>
```

---

## Two-level API

| Level | What it renders | When to use |
| ----- | --------------- | ----------- |
| **Level 1** — native helper overrides | Input element only (theme classes, no label/hint/error wrapper) | When you control surrounding markup manually |
| **Level 2** — full-field helpers | Label + input + hint + error, fully wired for accessibility | Default choice |

---

## Level 1 — Native helpers

Standard Rails helpers are overridden to apply theme CSS classes. All native HTML options (`placeholder:`, `autocomplete:`, `class:`, `data:`, etc.) are forwarded.

```erb
<%= f.text_field     :name %>
<%= f.email_field    :email %>
<%= f.number_field   :age %>
<%= f.text_area      :bio %>
<%= f.file_field     :avatar %>
<%= f.date_field     :birthday %>
<%= f.time_field     :meeting_time %>
<%= f.select         :country, country_options %>
<%= f.collection_select :country, Country.all, :code, :name %>
<%= f.time_zone_select  :timezone %>
<%= f.weekday_select    :weekday %>
<%= f.search_field   :query %>
<%= f.check_box      :agree %>
<%= f.radio_button   :plan, "basic" %>
```

Special options on native helpers:

| Helper | Option | Effect |
| ------ | ------ | ------ |
| `password_field` | `revealable: true` | Wraps input in an `input-formatter` reveal controller |
| `search_field` | `clearable: true` | Wraps input in an `input-clearable` controller with a clear button |

---

## Level 2 — Full-field helpers

Three methods render a complete, accessible field:

| Method | `as:` values |
| ------ | ------------ |
| `f.field(attr, as:, **opts)` | `:text` `:email` `:number` `:url` `:tel` `:color` `:month` `:week` `:range` `:datetime_local` `:text_area` `:file` `:password` `:date` `:time` `:select` `:search` |
| `f.collection_field(attr, as:, collection:, value_method:, text_method:, **opts)` | `:collection_select` `:grouped_collection_select` |
| `f.choice(attr, as:, **opts)` | `:radio` `:check_box` |

### Shared field options

| Option       | Type                                                                          | Default    | Description |
| ------------ | ----------------------------------------------------------------------------- | ---------- | ----------- |
| `label`      | String                                                                        | humanised attribute name | Override label / legend text |
| `hint`       | String                                                                        | `nil`      | Hint text rendered below the field |
| `error`      | String / Array                                                                | `nil`      | Override error message(s); suppresses `model.errors[attribute]` |
| `required`   | Boolean                                                                       | `false`    | Adds `required` + `aria-required="true"` |
| `hide_label` | Boolean                                                                       | `false`    | Renders label visually hidden (screen-reader accessible) |
| `layout`     | `:stacked` / `:inline`                        | `:stacked` | Label above input vs beside it |
| `floating`   | `:filled` / `:outlined` / `:standard`         | `nil`      | Floating-label style (text-like inputs only; `nil` = standard label above) |

---

## f.field

```erb
<%= f.field :name,     as: :text %>
<%= f.field :email,    as: :email,    label: "E-mail", required: true %>
<%= f.field :bio,      as: :text_area, hint: "Tell us about yourself." %>
<%= f.field :avatar,   as: :file %>
<%= f.field :password, as: :password, revealable: true %>
<%= f.field :email,    as: :email,    floating: :filled %>
```

**Floating label variants** — label starts inside the input, animates above on focus/fill. Compatible with text-like inputs only.

| `floating:` value | Style |
| ----------------- | ----- |
| `:filled`   | Filled background, bottom border only |
| `:outlined` | Full border, label clips through on float |
| `:standard` | Bottom border only, no background |

**Date** (`as: :date`) — calendar-grid picker backed by `combobox-date`. Use `f.date_field` for a plain `<input type="date">`.

**Time** (`as: :time`) — drum/scroll-wheel picker backed by `combobox-time`.

| Option | Values | Default | Description |
| ------ | ------ | ------- | ----------- |
| `format` | `:h12` / `:h24` | `:h12` | Clock format |
| `step` | Integer | `1` | Minute interval |

Use `f.time_field` for a plain `<input type="time">`.

**Select** (`as: :select`) — read-only listbox backed by `combobox-dropdown`. Accepts `choices:`, `include_blank:`, `prompt:`, `selected:`. Use `f.select` for a native `<select>`.

**Search** (`as: :search`) — editable typeahead backed by `combobox-dropdown`. Accepts `choices:`, `url:`, `clearable:`. Use `f.search_field` for a native `<input type="search">`.

---

## f.collection_field

```erb
<%= f.collection_field :country, as: :collection_select,
      collection: Country.all, value_method: :code, text_method: :name %>

<%= f.collection_field :country, as: :grouped_collection_select,
      collection:         Continent.all,
      value_method:       :code,
      text_method:        :name,
      group_method:       :countries,
      group_label_method: :name %>
```

Groups render with `role="group"` and `aria-label` on each group. Use native `f.collection_select` / `f.grouped_collection_select` to skip the field wrapper.

---

## f.choice

Renders a `<fieldset>` / `<legend>` for accessible grouping, or a single checkbox with an explicit label.

```erb
<%# Single checkbox %>
<%= f.choice :agree, as: :check_box, required: true, hint: "You must accept the terms." %>

<%# Radio group %>
<%= f.choice :plan, as: :radio,
      collection: Plan.all, value_method: :id, text_method: :name %>

<%# Checkbox group %>
<%= f.choice :roles, as: :check_box,
      collection: Role.all, value_method: :id, text_method: :name %>
```

**Collection-only options:**

| Option | Values | Default | Description |
| ------ | ------ | ------- | ----------- |
| `type` | `:default` \| `:button` \| `:card` | `:default` | Input/label presentation style |
| `variant` | `:default` \| `:success` \| `:destructive` \| `:warning` \| `:info` | `:default` | Accent color for selected state |
| `layout` | `:stacked` \| `:inline` | `:inline` | Stack cards vertically or wrap inline |

**Card / button behaviour:**
- **Checkbox card** — input visible on right; card border changes on check via `has-[:checked]:`
- **Radio card** — input hidden (`hidden peer`); entire card is the clickable area via `peer-checked:`
- **Radio button** — input hidden (`hidden peer`); inline pill style via `peer-checked:`

---

## Rendered HTML Structure

### Full field (Level 2)

```html
<div>
  <label for="user_email" id="user_email_label">E-mail</label>
  <input id="user_email" type="email" aria-describedby="user_email_hint" required aria-required="true" />
  <p id="user_email_hint">We'll never share your email.</p>
  <p id="user_email_error" role="alert">can't be blank</p>
</div>
```

### Floating label field

```html
<div>
  <div>
    <input id="user_email" placeholder=" " />
    <label for="user_email" id="user_email_label">Email</label>
  </div>
</div>
```

### Choice fieldset

```html
<fieldset aria-describedby="user_plan_hint">
  <legend>Plan <span aria-hidden="true">*</span></legend>
  <div>
    <p id="user_plan_hint">Choose the plan that fits your needs.</p>
    <label><input type="radio" name="user[plan]" value="1" aria-required="true" /> Basic</label>
    <label><input type="radio" name="user[plan]" value="2" aria-required="true" /> Pro</label>
  </div>
</fieldset>
```

---

## ARIA

Every full-field helper automatically:

- Links `<label for="…">` to the input `id` (or `<fieldset>` / `<legend>` for collections)
- Adds `aria-describedby` pointing to hint and/or error elements when present
- Sets `aria-invalid="true"` when the model has errors for the attribute
- Renders errors as `<p role="alert">` for screen reader announcement
- Adds `required` + `aria-required="true"` when `required: true`; collection fields set `aria-required="true"` on each individual input (not the `<fieldset>`)
- Renders a required mark (`*`, `aria-hidden="true"`) in the `<label>` or `<legend>`
