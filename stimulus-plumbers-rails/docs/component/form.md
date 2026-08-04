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

| Level                                 | What it renders                                                 | When to use                                  |
| ------------------------------------- | --------------------------------------------------------------- | -------------------------------------------- |
| **Level 1** — native helper overrides | Input element only (theme classes, no label/hint/error wrapper) | When you control surrounding markup manually |
| **Level 2** — full-field helpers      | Label + input + hint + error, fully wired for accessibility     | Default choice                               |

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

| Helper           | Option             | Effect                                                             |
| ---------------- | ------------------ | ------------------------------------------------------------------ |
| `password_field` | `revealable: true` | Wraps input in an `input-revealable` controller                    |
| `search_field`   | `clearable: true`  | Wraps input in an `input-clearable` controller with a clear button |

### f.submit

`f.submit` renders a themed `<button type="submit">` without a field wrapper.

```erb
<%= f.submit "Save" %>
<%= f.submit "Save", icon_leading: "save" %>
<%= f.submit "Continue", icon_trailing: "arrow-right" %>
<%= f.submit "Save", icon_leading: "save", hide_label: true %>
```

| Option                             | Description                                                                                                                                                                      |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `type:` / `variant:`               | Button theme type and variant.                                                                                                                                                   |
| `icon_leading:` / `icon_trailing:` | Decorative icon name placed before or after the submit text.                                                                                                                     |
| `hide_label: true`                 | Visually hides the button's own text span while keeping it available to screen readers. This differs from `Form::Field#hide_label`, which hides an associated `<label>` element. |

Submit buttons need an accessible name: pass non-blank text, or an `aria` label such as `aria: { label: "Save changes" }`.

---

## Level 2 — Full-field helpers

Three methods render a complete, accessible field:

| Method                                                                            | `as:` values                                                                                                                                                                              |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `f.field(attr, as:, **opts)`                                                      | `:text` `:email` `:number` `:url` `:tel` `:color` `:month` `:week` `:range` `:datetime_local` `:text_area` `:file` `:password` `:date` `:time` `:select` `:search` `:code` `:credit_card` |
| `f.collection_field(attr, as:, collection:, value_method:, text_method:, **opts)` | `:collection_select` `:grouped_collection_select`                                                                                                                                         |
| `f.choice(attr, as:, **opts)`                                                     | `:radio` `:check_box`                                                                                                                                                                     |

### Shared field options

| Option       | Type                                  | Default                   | Description                                                                |
| ------------ | ------------------------------------- | ------------------------- | -------------------------------------------------------------------------- |
| `label`      | String                                | translated attribute name | Override label / legend text                                               |
| `hint`       | String                                | `nil`                     | Hint text rendered below the field                                         |
| `error`      | String / Array                        | `nil`                     | Override error message(s); suppresses `model.errors[attribute]`            |
| `required`   | Boolean                               | `false`                   | Adds `required` + `aria-required="true"`                                   |
| `hide_label` | Boolean                               | `false`                   | Renders label visually hidden (screen-reader accessible)                   |
| `layout`     | `:stacked` / `:inline`                | `:stacked`                | Label above input vs beside it                                             |
| `floating`   | `:filled` / `:outlined` / `:standard` | `nil`                     | Floating-label style (text-like inputs only; `nil` = standard label above) |

Labels and legends default to the text `f.label` renders: `helpers.label.<object_name>.<attribute>`, then the model's `human_attribute_name` (`activerecord.attributes.*` / `activemodel.attributes.*`), then the humanized attribute name when the form has no model. In `fields_for`, the nested object supplies the name.

---

## f.field

```erb
<%= f.field :name,     as: :text %>
<%= f.field :email,    as: :email,    label: "E-mail", required: true %>
<%= f.field :bio,      as: :text_area, hint: "Tell us about yourself." %>
<%= f.field :avatar,   as: :file %>
<%= f.field :password, as: :password, revealable: true %>
<%= f.field :password, as: :password do |p| %>
  <% p.enforce min_length: 12, max_length: 64 %>
<% end %>
<%= f.field :verification_code, as: :code, length: 6 %>
<%= f.field :card_number, as: :credit_card %>
<%= f.field :email,    as: :email,    floating: :filled %>
<%= f.field :country,  as: :select,
      choices: [["Australia", "au"], ["Canada", "ca"], ["United States", "us"]],
      include_blank: "Select a country" %>
<%= f.field :tags,     as: :search,
      choices: ["ruby", "rails", "hotwire"], clearable: true %>
```

`f.field` can take a block when its renderer declares `&block`; that declaration opts the renderer into the block DSL. For example, the password renderer yields a `Password::Requirements` that accepts `enforce(**options)` and `rule(...)` configuration — see **Password** below. Strength renders a `password-strength` wrapper containing the input, a native `<meter>`, a polite live level, a rules heading, and a rules list. The input references the rules list with `aria-describedby`.

`choices:` takes the standard Rails shape — an array of `[label, value]` pairs (or a flat array of strings).

**Floating label variants** — label starts inside the input, animates above on focus/fill. Compatible with text-like inputs only.

| `floating:` value | Style                                     |
| ----------------- | ----------------------------------------- |
| `:filled`         | Filled background, bottom border only     |
| `:outlined`       | Full border, label clips through on float |
| `:standard`       | Bottom border only, no background         |

**Date** (`as: :date`) — calendar-grid picker backed by `combobox-date`. Use `f.date_field` for a plain `<input type="date">`.

**Time** (`as: :time`) — drum/scroll-wheel picker backed by `combobox-time`.

| Option   | Values          | Default | Description     |
| -------- | --------------- | ------- | --------------- |
| `format` | `:h12` / `:h24` | `:h12`  | Clock format    |
| `step`   | Integer         | `1`     | Minute interval |

Use `f.time_field` for a plain `<input type="time">`.

**Select** (`as: :select`) — read-only listbox backed by `combobox-dropdown`.

| Option          | Values         | Default | Description                                                   |
| --------------- | -------------- | ------- | ------------------------------------------------------------- |
| `choices`       | Array          | `[]`    | `[label, value]` pairs, or a flat array of strings            |
| `include_blank` | Boolean/String | `nil`   | Prepends a blank option; String overrides its label           |
| `prompt`        | Boolean/String | `nil`   | Prepends a disabled placeholder option                        |
| `selected`      | Value          | `nil`   | Pre-selected value; defaults to the attribute's current value |

Use `f.select` for a native `<select>`.

**Search** (`as: :search`) — editable typeahead backed by `combobox-dropdown`.

| Option      | Values  | Default | Description                                                                         |
| ----------- | ------- | ------- | ----------------------------------------------------------------------------------- |
| `choices`   | Array   | `[]`    | Client-side options to filter; omit when using `url:`                               |
| `url`       | String  | `nil`   | Server-side endpoint, receives `?q=<query>`, returns `<li role="option">` fragments |
| `clearable` | Boolean | `false` | Adds a clear button that resets the input                                           |

Use `f.search_field` for a native `<input type="search">`.

**Password** (`as: :password`) — reveal-toggle wrapper backed by `input-revealable`.

| Option         | Values                   | Default              | Description                                      |
| -------------- | ------------------------ | -------------------- | ------------------------------------------------ |
| `revealable`   | Boolean                  | `false`              | Adds a show/hide toggle button on the input      |
| `autocomplete` | String                   | `"current-password"` | Native autocomplete value                        |
| `requirements` | `Password::Requirements` | `nil`                | Prebuilt rule set that drives the strength meter |

Use `f.password_field` for a plain `<input type="password">` (also accepts `revealable:`).

**Strength rules.** Declare rules inline with a block, or pass a shared `requirements:` object. `enforce(min_length:, max_length:, uppercase:/lowercase:/digit:/symbol:)` enables built-ins — a character-class option takes `true` (≥1), an Integer (≥N), or a Range (`N..M` occurrences); the length rule requires **both** `min_length` and `max_length`. `rule(key, label, pattern:, min:, max:, negate:)` adds a custom rule (`negate: true` forbids matches).

```erb
<%= f.field :password, as: :password do |p| %>
  <% p.enforce min_length: 12, max_length: 64, digit: true %>
  <% p.rule :no_spaces, "No spaces", pattern: /\s/, negate: true %>
<% end %>
```

**Server enforcement.** Build one `Password::Requirements` and share it between the form meter and the model validator so they cannot drift:

```ruby
PASSWORD_RULES = StimulusPlumbers::Password::Requirements.build do |r|
  r.enforce(min_length: 12, max_length: 64, digit: true)
end

# model — PasswordStrengthValidator; valid? iff every enabled rule passes
validates :password, password_strength: { with: PASSWORD_RULES }
```

```erb
<%= f.field :password, as: :password, requirements: PASSWORD_RULES %>
```

The validator also accepts inline options (`password_strength: { min_length: 12, max_length: 64, digit: true }`) and a custom `message:`. For the rule-descriptor wire contract and meter behaviour, see the [JS controller doc](../../../stimulus-plumbers/docs/component/password-strength.md).

**Code** (`as: :code`) — character-cell entry backed by `input-formatter` and the `character-cells` plumber. The native input remains the accessible control; cells are decorative.

| Option         | Values                                   | Default                | Description                                              |
| -------------- | ---------------------------------------- | ---------------------- | -------------------------------------------------------- |
| `length`       | positive Integer                         | required               | Number of cells and input maximum length                 |
| `charset`      | `:digits` / `:letters` / `:alphanumeric` | `:digits`              | Allowed code characters                                  |
| `groups`       | Array of positive Integers               | `[]`                   | Visual cell groups; must add up to `length`              |
| `separator`    | String / `nil`                           | `nil`                  | Character between groups; `nil` shows the break as a gap |
| `autocomplete` | String                                   | `"one-time-code"`      | Native autocomplete value                                |
| `inputmode`    | String                                   | `"numeric"` for digits | Native input mode                                        |

**Credit card** (`as: :credit_card`) — grouped card-number entry backed by `input-formatter` and the `character-cells` plumber (grouped mode). Renders one cell per group; their sum sets `maxlength`.

| Option         | Values                     | Default        | Description                                                  |
| -------------- | -------------------------- | -------------- | ------------------------------------------------------------ |
| `groups`       | Array of positive Integers | `[4, 4, 4, 4]` | Cell groups — one cell per group; their sum sets `maxlength` |
| `separator`    | String / `nil`             | `nil`          | Character between cells; `nil` renders none                  |
| `autocomplete` | String                     | `"cc-number"`  | Native autocomplete value                                    |
| `inputmode`    | String                     | `"numeric"`    | Native input mode                                            |

Character-cell fields do not support `floating:` labels.

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

| Option    | Values                                                              | Default    | Description                           |
| --------- | ------------------------------------------------------------------- | ---------- | ------------------------------------- |
| `type`    | `:default` \| `:button` \| `:card`                                  | `:default` | Input/label presentation style        |
| `variant` | `:default` \| `:success` \| `:destructive` \| `:warning` \| `:info` | `:default` | Accent color for selected state       |
| `layout`  | `:stacked` \| `:inline`                                             | `:inline`  | Stack cards vertically or wrap inline |

**Card / button behaviour:**

- **Checkbox card** — input visible on the right; the card border highlights when checked
- **Radio card** — input visually hidden; the whole card is the clickable target and highlights when selected
- **Radio button** — input visually hidden; renders as an inline pill that highlights when selected

---

## Rendered HTML Structure

### Full field (Level 2)

```html
<div>
  <label for="user_email" id="user_email_label">E-mail</label>
  <input
    id="user_email"
    type="email"
    aria-describedby="user_email_hint user_email_error"
    aria-invalid="true"
    required
    aria-required="true"
  />
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
    <label
      ><input type="radio" name="user[plan]" value="1" aria-required="true" />
      Basic</label
    >
    <label
      ><input type="radio" name="user[plan]" value="2" aria-required="true" />
      Pro</label
    >
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
