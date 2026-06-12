# Combobox

Rails helpers that render fully-wired combobox components. Each variant shares the same wrapper structure (`input-combobox` + `input-formatter`) and differs only in its popover body.

See [docs/component/combobox-controllers.md](../../stimulus-plumbers/docs/component/combobox.md) in the JS package for the underlying controller API.

## Helpers

### `sp_combobox`

Single entry point. The panel type is chosen by a method call on the yielded builder
(`c.dropdown`, `c.typeahead`, `c.date`, `c.time`) — the panel owns its `aria-haspopup`,
popup id, trigger icon, and wrapper data. The `sp_combobox_*` helpers below are thin
wrappers over this.

```erb
<%= sp_combobox(value: "us", label: "Country") do |c|
  c.dropdown(options: [["United States", "us"], ["Canada", "ca"]], value: "us")
end %>

<%= sp_combobox(label: "Meeting time") do |c|
  c.time(format: :h24, step: 15)
end %>
```

| Option            | Description                                      |
| ----------------- | ------------------------------------------------ |
| `value`           | Initial value (hidden input + trigger)           |
| `label`           | `aria-label` on the trigger input                |
| `id`              | Trigger id (defaults to a generated `sp_dom_id`) |
| `close_on_select` | `false` keeps the panel open after a selection   |
| `**html_options`  | Forwarded to the wrapper `div`                   |

Builder methods: `c.dropdown(options:, value:, label:)`, `c.typeahead(options:, value:, label:, url:)`,
`c.date(value:)`, `c.time(format:, step:, value:)`.

---

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

| Option           | Description                                             |
| ---------------- | ------------------------------------------------------- |
| `options`        | Option rows (see formats above)                         |
| `value`          | Pre-selected value                                      |
| `label`          | `aria-label` on the trigger input and the listbox panel |
| `**html_options` | Forwarded to the wrapper `div`                          |

---

### `sp_combobox_typeahead`

Editable trigger that filters options as the user types. Supports client-side fuzzy matching and server-side fetch.

```erb
<%# Client-side fuzzy filter %>
<%= sp_combobox_typeahead(options: [["London", "london"], ["Paris", "paris"]]) %>

<%# Server-side — receives ?q=<query>, must return <li role="option"> HTML fragments %>
<%= sp_combobox_typeahead(url: cities_path, label: "City") %>
```

| Option           | Description                                                      |
| ---------------- | ---------------------------------------------------------------- |
| `options`        | Initial options rendered on page load (same formats as dropdown) |
| `value`          | Pre-selected value                                               |
| `url`            | URL for server-side filtering                                    |
| `label`          | `aria-label` on the trigger input and the listbox panel          |
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

All variants share the same wrapper pattern. The `popover` controller owns panel
visibility, `aria-expanded`, outside-click dismissal, and focus; `input-combobox`
owns value/selection/filtering; `input-formatter` formats the displayed value.

```html
<div
  data-controller="popover input-combobox input-formatter"
  data-action="input-combobox:changed->input-formatter#format"
  data-input-combobox-value-value="[initial-value]"
>
  <input
    type="text"
    role="combobox"
    aria-haspopup="dialog|listbox"
    aria-expanded="false"
    aria-controls="[popup-id]"
    data-popover-target="trigger"
    data-input-combobox-target="trigger"
    data-input-formatter-target="input"
    data-action="focus->popover#open keydown.esc->popover#close"
  />

  <input type="hidden" name="[name]" data-input-combobox-target="input" />

  <!-- variant-specific popover body (see below) -->
</div>
```

`aria-haspopup` is `"listbox"` for dropdown/typeahead, `"dialog"` for date/time. The
`[popup-id]` is `[id]_popover` for dropdown/date/time and `[id]_popover_listbox` for typeahead.

Pass `close_on_select: false` to any `sp_combobox_*` helper to keep the panel open
after a selection (renders `data-popover-close-on-select-value="false"` on the wrapper).

### Popover body by variant

Each variant builds its own panel root via `Popover::Builder#build_panel` (see
[popover.md](popover.md)), adding its controller and role to the panel wiring. The
trigger's `aria-controls` points at the popup — the panel for dropdown/date/time, the
nested `<ul role="listbox">` for typeahead.

**date / time** — the panel IS the `role="dialog"` element and hosts the picker controller:

```html
<div
  id="[id]_popover"
  role="dialog"
  aria-label="[label]"
  hidden
  data-popover-target="panel"
  data-controller="combobox-date"
  data-action="combobox-date:selected->input-combobox#onSelect combobox-date:selected->popover#closeOnSelect ..."
>
  <!-- calendar grid (date) or drum columns (time) -->
</div>
```

**dropdown** — the panel IS the `<ul role="listbox">`; options are its only children:

```html
<ul
  id="[id]_popover"
  hidden
  role="listbox"
  aria-label="[label]"
  data-popover-target="panel"
  data-controller="combobox-dropdown"
  data-action="click->combobox-dropdown#select keydown->combobox-dropdown#onNavigate combobox-dropdown:selected->input-combobox#onSelect combobox-dropdown:selected->popover#closeOnSelect"
  data-combobox-dropdown-target="listbox"
>
  <li role="option" data-value="us" aria-selected="false">United States</li>
  <li role="option" data-value="ca" aria-selected="false">Canada</li>
</ul>
```

**typeahead** — the panel is a wrapper holding the controller. The `<ul role="listbox">`
holds only options; the `loading`/`empty` status regions are siblings beside it, since
`role="listbox"` permits only `option`/`group` children. Status regions stay
non-focusable (the popover focuses the first focusable element in the panel on open).

```html
<div
  id="[id]_popover"
  hidden
  data-popover-target="panel"
  data-controller="combobox-dropdown"
  data-action="click->combobox-dropdown#select keydown->combobox-dropdown#onNavigate combobox-dropdown:selected->input-combobox#onSelect combobox-dropdown:selected->popover#closeOnSelect"
  data-combobox-dropdown-url-value="[url]"
>
  <ul
    id="[id]_popover_listbox"
    role="listbox"
    aria-labelledby="[label-id]"
    data-combobox-dropdown-target="listbox"
  >
    <li role="option" ...>Paris</li>
  </ul>
  <div hidden aria-live="polite" data-combobox-dropdown-target="loading">
    <!-- spinner -->
  </div>
  <div hidden role="status" data-combobox-dropdown-target="empty">
    No results
  </div>
</div>
```

The remote `url` endpoint returns options-only HTML — it replaces the listbox's
`innerHTML`, while the `loading`/`empty` siblings persist.
