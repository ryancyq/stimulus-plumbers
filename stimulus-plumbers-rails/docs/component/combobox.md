# Combobox

Rails helpers that render a listbox combobox wired to the
[`combobox` controller](../../../stimulus-plumbers/docs/component/combobox.md#combobox).
`sp_combobox_dropdown` is select-only; `sp_combobox_typeahead` is editable. Each helper delegates to
its component, `Components::Combobox::Dropdown` or `Components::Combobox::Typeahead`, which take the
same options. Keyboard and ARIA
behavior live in [ARIA.md](../../../ARIA.md#combobox-combobox_controller).

## Helpers

### `sp_combobox_dropdown`

Select-only combobox: a button trigger and a listbox of options.

```erb
<%= sp_combobox_dropdown(name: "country", options: [["United States", "us"], ["Canada", "ca"]], value: "us") %>
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

| Option            | Default          | Description                                                             |
| ----------------- | ---------------- | ----------------------------------------------------------------------- |
| `name`            | `nil`            | Hidden input name                                                       |
| `options`         | `[]`             | Option rows (see formats above)                                         |
| `value`           | `nil`            | Committed value; its option label shows in the trigger                  |
| `label`           | `nil`            | `aria-label` on the trigger and the listbox                             |
| `labelledby`      | `nil`            | `aria-labelledby` on the trigger and the listbox, for an external label |
| `id`              | `sp_dom_id`      | Trigger id; the panel and listbox ids derive from it                    |
| `close_on_commit` | `true`           | `false` keeps the panel open after a commit                             |
| `icon_leading`    | `nil`            | Icon before the trigger                                                 |
| `icon_trailing`   | `"chevron-down"` | Icon after the trigger                                                  |
| `trailing`        | `nil`            | Callable rendering custom trailing content, replacing the icon          |
| `trigger`         | `{}`             | HTML options merged onto the trigger (the `role="combobox"` element)    |
| `**html_options`  | —                | Forwarded to the root `div`                                             |

---

### `sp_combobox_typeahead`

Editable combobox: a text input with a listbox of options.

```erb
<%= sp_combobox_typeahead(name: "city", options: [["London", "london"], ["Paris", "paris"]], label: "City") %>
```

| Option            | Default       | Description                                                                       |
| ----------------- | ------------- | --------------------------------------------------------------------------------- |
| `name`            | `nil`         | Hidden input name                                                                 |
| `options`         | `[]`          | Option rows (same formats as `sp_combobox_dropdown`)                              |
| `value`           | `nil`         | Committed value; its option label, or the text under `:freeform`, fills the input |
| `value_policy`    | `:restricted` | `:restricted` submits only a committed option; `:freeform` submits the typed text |
| `match`           | `:prefix`     | Local filter: `:prefix`, `:contains`, or `:fuzzy`                                 |
| `min_length`      | `1`           | Shorter queries show every option                                                 |
| `source`          | `nil`         | Results URL loaded through `combobox-turbo`; needs `id:`, and excludes `match`    |
| `param`           | `:q`          | Query parameter sent to `source`; needs `source`                                  |
| `label`           | `nil`         | `aria-label` on the trigger and the listbox                                       |
| `labelledby`      | `nil`         | `aria-labelledby` on the trigger and the listbox, for an external label           |
| `id`              | `sp_dom_id`   | Trigger id; the panel and listbox ids derive from it                              |
| `close_on_commit` | `true`        | `false` keeps the panel open after a commit                                       |
| `icon_leading`    | `nil`         | Icon before the trigger                                                           |
| `icon_trailing`   | `nil`         | Icon after the trigger                                                            |
| `trailing`        | `nil`         | Callable rendering custom trailing content, replacing the icon                    |
| `trigger`         | `{}`          | HTML options merged onto the trigger (the `role="combobox"` element)              |
| `**html_options`  | —             | Forwarded to the root `div`                                                       |

With `source:`, `options:` is the initial list; pass the committed option there so its label shows.

The `source:` endpoint renders `sp_combobox_typeahead` with the same `id:`, `source:`, and `label:` or
`labelledby:`, and the matches as `options:`; Turbo keeps only its `turbo-frame#[id]_popover_results`.

---

### `sp_combobox_date`

Calendar-grid date combobox on the legacy `input-combobox` composition.

```erb
<%= sp_combobox_date(value: "2024-03-15", label: "Date of birth") %>
```

| Option            | Default | Description                                    |
| ----------------- | ------- | ---------------------------------------------- |
| `value`           | `nil`   | ISO 8601 date — pre-fills and navigates        |
| `label`           | `nil`   | `aria-label` on the trigger input              |
| `close_on_select` | `nil`   | `false` keeps the panel open after a selection |
| `**html_options`  | —       | Forwarded to the wrapper `div`                 |

---

### `sp_combobox_time`

Drum/scroll-wheel time combobox on the legacy composition. The `sp_combobox` block form
(`c.date`, `c.time`) renders the same comboboxes.

```erb
<%= sp_combobox_time(format: :h24, step: 15, value: "14:30", label: "Meeting time") %>
```

| Option            | Default | Description                                   |
| ----------------- | ------- | --------------------------------------------- |
| `format`          | `:h12`  | `:h12` (1–12 + AM/PM) or `:h24` (00–23)       |
| `step`            | `1`     | Minute increment — `15` yields 00, 15, 30, 45 |
| `value`           | `nil`   | Pre-selected time as `"HH:MM"`                |
| `label`           | `nil`   | `aria-label` on the trigger input             |
| `close_on_select` | `false` | `true` closes the panel after a selection     |
| `**html_options`  | —       | Forwarded to the wrapper `div`                |

---

## Form Builder

`StimulusPlumbers::Form::Builder` exposes combobox-backed fields through purpose-specific methods.
See [form.md](form.md) for the full API.

```erb
<%= form_with model: @user, builder: StimulusPlumbers::Form::Builder do |f| %>
  <%= f.field :country, as: :select, choices: country_options %>
  <%= f.field :city,    as: :search, choices: city_options %>
<% end %>
```

`as: :select` renders `sp_combobox_dropdown`; `as: :search` renders `sp_combobox_typeahead`
(defaults in [form.md](form.md)).

---

## Rendered HTML Structure

```html
<div
  data-controller="combobox"
  data-combobox-mode-value="select_only"
  data-action="mousedown->combobox#onMousedown click->combobox#onClick"
>
  <div class="[combobox_trigger_group theme classes]">
    <button
      type="button"
      id="[id]"
      role="combobox"
      aria-expanded="false"
      aria-controls="[id]_popover_listbox"
      data-combobox-target="trigger"
      data-action="keydown->combobox#onKeydown"
    >
      [committed label]
    </button>
    <!-- trailing icon -->
  </div>
  <input
    type="hidden"
    name="[name]"
    value="[value]"
    data-combobox-target="input"
  />
  <div id="[id]_popover" popover="manual" data-combobox-target="panel">
    <ul
      id="[id]_popover_listbox"
      role="listbox"
      aria-label="[label]"
      data-combobox-target="listbox"
    >
      <li
        id="[id]_popover_listbox_option_1"
        role="option"
        data-value="us"
        aria-selected="false"
      >
        United States
      </li>
      <li role="none">
        <ul role="group" aria-labelledby="[id]_popover_listbox_group_1">
          <li id="[id]_popover_listbox_group_1" role="none">Americas</li>
          <li
            id="[id]_popover_listbox_option_2"
            role="option"
            data-value="ca"
            aria-selected="true"
          >
            Canada
          </li>
        </ul>
      </li>
    </ul>
  </div>
</div>
```

The editable trigger is `<input type="text" autocomplete="off" aria-autocomplete="list">` with
`input->combobox#onInput` added to its actions, and the panel adds
`<div role="status" data-combobox-target="status">` after the listbox; the root carries
`data-combobox-empty-text-value` from `stimulus_plumbers.combobox.typeahead.empty`. With `source:`,
the root adds `combobox-turbo` with `source:` as `data-combobox-turbo-src-value`, and the listbox sits in `<turbo-frame id="[id]_popover_results">`; the
loading and error text come from `stimulus_plumbers.combobox.typeahead.loading` and `.error`. An option with a description adds
`data-label`, `aria-labelledby`, and `aria-describedby` pointing at its label and description
spans.

## Theme keys

| Key                           | Element                        |
| ----------------------------- | ------------------------------ |
| `combobox`                    | Root `div`                     |
| `combobox_trigger_group`      | Input group around the trigger |
| `combobox_trigger`            | Trigger                        |
| `combobox_trigger_icon`       | Leading/trailing icons         |
| `combobox_popover`            | Panel                          |
| `combobox_listbox`            | Listbox                        |
| `combobox_option`             | Option (`disabled:`)           |
| `combobox_option_description` | Option description             |
| `combobox_option_group`       | Group item                     |
| `combobox_option_group_label` | Group label                    |
| `combobox_status`             | Editable status                |

## Migration from the legacy combobox

| Legacy                                   | Use                                                                    |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| `sp_combobox { \|c\| c.dropdown(...) }`  | `sp_combobox_dropdown`                                                 |
| `sp_combobox { \|c\| c.typeahead(...) }` | `sp_combobox_typeahead`                                                |
| `url:`                                   | `source:` on `sp_combobox_typeahead`                                   |
| `close_on_select:`                       | `close_on_commit:`                                                     |
| `input: { name:, value: }`               | `name:` and `value:`                                                   |
| `trigger: { id:, ... }`                  | `id:`; `trigger:` holds HTML options for the `role="combobox"` element |
