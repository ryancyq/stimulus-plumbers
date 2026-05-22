# Combobox

Rails helpers that render fully-wired combobox components. Each variant shares the same wrapper structure (`input-combobox` + `input-formatter`) and differs only in its popover body.

See [docs/component/combobox-controllers.md](../../stimulus-plumbers/docs/component/combobox.md) in the JS package for the underlying controller API.

## Helpers

### `sp_combobox_date`

Date picker backed by a calendar grid.

```erb
<%= sp_combobox_date %>
<%= sp_combobox_date(value: "2024-03-15", label: "Date of birth", class: "w-full") %>
```

| Option           | Description                                                 |
| ---------------- | ----------------------------------------------------------- |
| `value`          | ISO 8601 date string — pre-fills and navigates the calendar |
| `label`          | `aria-label` on the trigger input                           |
| `**html_options` | Forwarded to the wrapper `div`                              |

---

### `sp_combobox_dropdown`

Read-only combobox with a static listbox popover.

```erb
<%= sp_combobox_dropdown(options: [["United States", "us"], ["Canada", "ca"]], value: "us") %>
```

**Option formats:**

```ruby
# Flat
[["Label", "value"], ...]

# Grouped
[{ label: "Americas", options: [["United States", "us"], ...] }, ...]

# With description or disabled flag
[["United States", "us", { description: "North America" }], ...]
[["Unavailable",   "x",  { disabled: true }], ...]
```

| Option           | Description                       |
| ---------------- | --------------------------------- |
| `options`        | Option rows (see formats above)   |
| `value`          | Pre-selected value                |
| `label`          | `aria-label` on the trigger input |
| `**html_options` | Forwarded to the wrapper `div`    |

---

### `sp_combobox_autocomplete`

Editable trigger that filters options as the user types. Supports client-side fuzzy matching and server-side fetch.

```erb
<%# Client-side fuzzy filter %>
<%= sp_combobox_autocomplete(options: [["London", "london"], ["Paris", "paris"]]) %>

<%# Server-side — receives ?q=<query>, must return <li role="option"> HTML fragments %>
<%= sp_combobox_autocomplete(url: cities_path, label: "City") %>
```

| Option           | Description                                                      |
| ---------------- | ---------------------------------------------------------------- |
| `options`        | Initial options rendered on page load (same formats as dropdown) |
| `value`          | Pre-selected value                                               |
| `url`            | URL for server-side filtering                                    |
| `label`          | `aria-label` on the trigger input                                |
| `**html_options` | Forwarded to the wrapper `div`                                   |

---

### `sp_combobox_time`

iOS-style drum/scroll-wheel time picker.

```erb
<%= sp_combobox_time %>
<%= sp_combobox_time(format: :h24, step: 15, value: "14:30", label: "Meeting time") %>
```

| Option           | Default | Description                                   |
| ---------------- | ------- | --------------------------------------------- |
| `format`         | `:h12`  | `:h12` (1–12 + AM/PM) or `:h24` (00–23)       |
| `step`           | `1`     | Minute increment — `15` yields 00, 15, 30, 45 |
| `value`          | `nil`   | Pre-selected time as `"HH:MM"`                |
| `label`          | `nil`   | `aria-label` on the trigger input             |
| `**html_options` | —       | Forwarded to the wrapper `div`                |

---

## Form Builder

`StimulusPlumbers::Form::Builder` exposes combobox-backed fields through purpose-specific methods rather than a single generic helper. See [form_builder.md](form_builder.md) for the full API.

```erb
<%= form_with model: @user, builder: StimulusPlumbers::Form::Builder do |f| %>
  <%= f.date_field   :birthday %>
  <%= f.time_field   :meeting_time, format: :h24, step: 15 %>
  <%= f.select       :country, country_options %>
  <%= f.search_field :city, url: cities_path %>
<% end %>
```

All form field methods accept `label:`, `hint:`, `error:`, `required:`, and `hide_label:` in addition to their own options.

---

## Rendered HTML Structure

All variants share the same wrapper pattern:

```html
<div
  data-controller="input-combobox input-formatter"
  data-action="input-combobox:changed->input-formatter#format"
  data-input-combobox-value-value="[initial-value]"
>
  <input
    type="text"
    role="combobox"
    aria-haspopup="dialog|listbox"
    aria-expanded="false"
    aria-controls="[id]_popover"
    data-input-combobox-target="trigger"
    data-input-formatter-target="input"
  />

  <input type="hidden" name="[name]" data-input-combobox-target="input" />

  <!-- variant-specific popover body (see below) -->
</div>
```

`aria-haspopup` is `"listbox"` for dropdown/autocomplete, `"dialog"` for date/time.

### Popover body by variant

**date / time** — a `<div role="dialog">` wrapping the picker content:

```html
<div
  id="[id]_popover"
  role="dialog"
  aria-label="[label]"
  hidden
  data-input-combobox-target="popover"
>
  <!-- calendar grid (date) or drum columns (time) -->
</div>
```

**dropdown / autocomplete** — a `<div>` popover wrapping a `<ul role="listbox">`:

```html
<div
  id="[id]_popover"
  hidden
  data-input-combobox-target="popover"
  data-controller="combobox-dropdown"
  data-action="click->combobox-dropdown#select keydown->combobox-dropdown#onNavigate combobox-dropdown:selected->input-combobox#onSelect"
>
  <ul role="listbox" data-combobox-dropdown-target="listbox">
    <li role="option" data-value="us" aria-selected="false">United States</li>
    <li role="option" data-value="ca" aria-selected="false">Canada</li>
  </ul>
</div>
```

For autocomplete, `loading` and `empty` state elements are appended alongside the `<ul>` inside the popover `<div>`.
