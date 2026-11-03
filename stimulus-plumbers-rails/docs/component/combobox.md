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
| `value`           | `nil`            | Selected value; its option label shows in the trigger                   |
| `label`           | `nil`            | `aria-label` on the trigger and the listbox                             |
| `labelledby`      | `nil`            | `aria-labelledby` on the trigger and the listbox, for an external label |
| `id`              | `sp_dom_id`      | Trigger id; the panel and listbox ids derive from it                    |
| `close_on_select` | `true`           | `false` keeps the panel open after a selection                          |
| `icon_leading`    | `nil`            | Icon before the trigger                                                 |
| `icon_trailing`   | `"chevron-down"` | Icon after the trigger                                                  |
| `trailing`        | `nil`            | Callable rendering custom trailing content, replacing the icon          |
| `trigger`         | `{}`             | HTML options merged onto the trigger (the `role="combobox"` element)    |
| `**html_options`  | —                | Forwarded to the container `div`                                        |

---

### `sp_combobox_typeahead`

Editable combobox: a text input with a listbox of options.

```erb
<%= sp_combobox_typeahead(name: "city", options: [["London", "london"], ["Paris", "paris"]], label: "City") %>
```

| Option            | Default       | Description                                                                      |
| ----------------- | ------------- | -------------------------------------------------------------------------------- |
| `name`            | `nil`         | Hidden input name                                                                |
| `options`         | `[]`          | Option rows (same formats as `sp_combobox_dropdown`)                             |
| `value`           | `nil`         | Selected value; its option label, or the text under `:freeform`, fills the input |
| `value_policy`    | `:restricted` | `:restricted` submits only a selected option; `:freeform` submits the typed text |
| `match`           | `:prefix`     | Local filter: `:prefix`, `:contains`, or `:fuzzy`                                |
| `min_length`      | `1`           | Shorter queries show every option                                                |
| `source`          | `nil`         | Results URL loaded through `combobox-turbo`; needs `id:`, and excludes `match`   |
| `param`           | `:q`          | Query parameter sent to `source`; needs `source`                                 |
| `label`           | `nil`         | `aria-label` on the trigger and the listbox                                      |
| `labelledby`      | `nil`         | `aria-labelledby` on the trigger and the listbox, for an external label          |
| `id`              | `sp_dom_id`   | Trigger id; the panel and listbox ids derive from it                             |
| `close_on_select` | `true`        | `false` keeps the panel open after a selection                                   |
| `icon_leading`    | `nil`         | Icon before the trigger                                                          |
| `icon_trailing`   | `nil`         | Icon after the trigger                                                           |
| `trailing`        | `nil`         | Callable rendering custom trailing content, replacing the icon                   |
| `trigger`         | `{}`          | HTML options merged onto the trigger (the `role="combobox"` element)             |
| `**html_options`  | —             | Forwarded to the container `div`                                                 |

With `source:`, `options:` is the initial list; pass the selected option there so its label shows.

The `source:` endpoint renders `sp_combobox_typeahead` with the same `id:`, `source:`, and `label:` or
`labelledby:`, and the matches as `options:`; Turbo keeps only its `turbo-frame#[id]_popover_results`.

---

### `sp_combobox_date`

A read-only date input whose popover holds [`sp_calendar`](calendar.md); `combobox-date` and
`input-formatter` ([JS](../../../stimulus-plumbers/docs/component/combobox.md#combobox-date)) fill it.

```erb
<%= sp_combobox_date(name: "person[birthday]", value: @person.birthday, label: "Birthday",
                     format: { month: "long", day: "numeric", year: "numeric" },
                     min: 120.years.ago.to_date, max: Date.current) %>
```

| Option                         | Default          | Description                                                                             |
| ------------------------------ | ---------------- | --------------------------------------------------------------------------------------- |
| `name`                         | `nil`            | Hidden input name; submits `YYYY-MM-DD`                                                 |
| `value`                        | `nil`            | `Date`, time, or `YYYY-MM-DD`; other text shows as is and selects nothing               |
| `label` / `labelledby`         | `nil`            | Names the input; the popover is "Choose `label`" or `labelledby`                        |
| `id`                           | generated        | Input id; the popover is `<id>_popover`, the calendar `<id>_calendar`                   |
| `format`                       | `{}`             | `input-formatter` options, passed as given; `locale` defaults to `I18n.locale`          |
| `open_on_focus`                | `true`           | Wires [`popover#onFocus`](../../../stimulus-plumbers/docs/component/popover.md#methods) |
| `icon_leading`/`icon_trailing` | `nil`/`calendar` | Decorative icons                                                                        |
| `trigger`                      | `{}`             | Attributes for the input                                                                |
| `calendar`                     | `{}`             | [`sp_calendar`](calendar.md) `:stimulus` options (`displayed`, `today`, …)              |
| `min`, `max`, `disabled_*`     | —                | Available dates, as in [`sp_calendar`](calendar.md)                                     |
| `**html_options`               | —                | Forwarded to the wrapper `div`                                                          |

```html
<div
  data-controller="popover combobox-date input-formatter"
  data-input-formatter-format-value="date"
  data-input-formatter-options-value="{}"
  data-action="calendar:changed->combobox-date#onChange focusout->combobox-date#onFocusout mousedown->combobox-date#onMousedown click->combobox-date#onClick combobox-date:changed->input-formatter#onChange"
>
  <div class="[combobox_trigger_group theme classes]">
    <input
      id="[id]"
      type="text"
      value="2026-09-15"
      readonly
      inputmode="none"
      role="combobox"
      aria-label="[label]"
      aria-haspopup="dialog"
      aria-expanded="false"
      aria-controls="[id]_popover"
      data-action="focus->popover#onFocus click->popover#onOpen keydown->combobox-date#onKeydown"
    />
    <!-- decorative calendar icon -->
  </div>
  <input
    type="hidden"
    name="[name]"
    value="2026-09-15"
    data-combobox-date-target="input"
  />
  <div
    id="[id]_popover"
    popover="auto"
    role="dialog"
    aria-label="Choose [label]"
  >
    <!-- sp_calendar id="[id]_calendar", selectable -->
  </div>
</div>
```

---

### `sp_combobox_time`

A read-only time input whose popover holds hour, minute, and AM/PM columns; `combobox-time` and
`input-formatter` ([JS](../../../stimulus-plumbers/docs/component/combobox.md#combobox-time)) fill it.
It takes the `sp_combobox_date` options `name`, `label`/`labelledby`, `id`, `open_on_focus`,
`icon_leading`/`icon_trailing` (default `nil`/`clock`), `trigger`, and `**html_options`, plus:

```erb
<%= sp_combobox_time(name: "event[starts_at]", value: @event.starts_at, label: "Starts at",
                     format: { hourCycle: "h23" }, min: "09:00", max: "17:00", step: 15) %>
```

| Option       | Default | Description                                                                                                                                 |
| ------------ | ------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `value`      | `nil`   | A time, read by its clock without seconds, or `HH:MM`; submits `HH:MM`; other text shows as is and selects nothing                          |
| `format`     | `{}`    | `input-formatter` options, passed as given; `locale` defaults to `I18n.locale` and `hourCycle` to `h12`                                     |
| `min`, `max` | `nil`   | Available range as times or `HH:MM`, inclusive; a `min` after `max` wraps past midnight; options outside it are unavailable                 |
| `step`       | `1`     | Minutes counted from midnight, one of 1–6, 10, 12, 15, 20, 30, 60; `15` lists 00, 15, 30, 45; a minute off it selects no minute and is kept |

A `min` or `max` that is not a time or `HH:MM`, a `min`–`max` with no time on the `step`, or another `step` raises
`ArgumentError`. An unavailable `value` stays selected; validate it in the model.

`hourCycle: "h11"`/`"h12"` or `hour12: true` adds the AM/PM column with hours 1–12; otherwise hours run 00–23.
Column names come from `stimulus_plumbers.combobox.time.*_label`; AM and PM labels from
`stimulus_plumbers.combobox.time.am`/`.pm`, then Rails' `time.am`/`time.pm`.

```html
<div
  data-controller="popover combobox-time input-formatter"
  data-combobox-time-step-value="1"
  data-input-formatter-format-value="time"
  data-input-formatter-options-value='{"hourCycle":"h12","locale":"en"}'
  data-action="popover:before-open->combobox-time#onOpening popover:opened->combobox-time#onOpened popover:closed->combobox-time#onClosed focusout->combobox-time#onFocusout mousedown->combobox-time#onMousedown click->combobox-time#onClick combobox-time:changed->input-formatter#onChange"
>
  <div class="[combobox_trigger_group theme classes]">
    <input
      id="[id]"
      type="text"
      value="14:30"
      readonly
      inputmode="none"
      role="combobox"
      aria-label="[label]"
      aria-haspopup="dialog"
      aria-expanded="false"
      aria-controls="[id]_popover"
      data-action="focus->popover#onFocus click->popover#onOpen keydown->combobox-time#onKeydown"
    />
    <!-- decorative clock icon -->
  </div>
  <input
    type="hidden"
    name="[name]"
    value="14:30"
    data-combobox-time-target="input"
  />
  <div
    id="[id]_popover"
    popover="auto"
    role="dialog"
    aria-label="Choose [label]"
  >
    <ul
      role="listbox"
      tabindex="0"
      aria-label="Hour"
      aria-activedescendant="[id]_hour_2"
      data-combobox-time-target="hour"
    >
      <li id="[id]_hour_1" role="option" data-value="1" aria-selected="false">
        1
      </li>
      <!-- … -->
    </ul>
    <!-- Minute column ([id]_minute_00 …); AM/PM column ([id]_meridiem_AM, [id]_meridiem_PM) -->
  </div>
</div>
```

---

### `sp_combobox_datetime`

A read-only date-time input whose popover holds [`sp_calendar`](calendar.md) and the `sp_combobox_time` columns;
`combobox-datetime` and `input-formatter` ([JS](../../../stimulus-plumbers/docs/component/combobox.md#combobox-datetime))
fill it. It takes the `sp_combobox_time` options, but `min` and `max` are moments and `step` goes in `time:`:

```erb
<%= sp_combobox_datetime(name: "booking[starts_at]", value: @booking.starts_at, label: "Starts at",
                         min: Time.current, max: 30.days.from_now, disabled_weekdays: [0],
                         time: { min: "18:00", max: "23:00", step: 15 }) %>
```

| Option          | Default    | Description                                                                                                                                |
| --------------- | ---------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `value`         | `nil`      | A time, read in `Time.zone` without seconds, or `YYYY-MM-DDTHH:MM`; submits `YYYY-MM-DDTHH:MM`; other text shows as is and selects nothing |
| `format`        | `{}`       | `input-formatter` `datetime` options; `locale` defaults to `I18n.locale` and `hourCycle` to `h12`                                          |
| `min`, `max`    | `nil`      | Available moments as times or `YYYY-MM-DDTHH:MM`, inclusive                                                                                |
| `disabled_*`    | —          | Unavailable dates, as in [`sp_calendar`](calendar.md)                                                                                      |
| `time`          | `{}`       | The daily window: `sp_combobox_time` `min`, `max`, and `step`                                                                              |
| `calendar`      | `{}`       | [`sp_calendar`](calendar.md) `:stimulus` options (`displayed`, `today`, …)                                                                 |
| `icon_trailing` | `calendar` | Decorative icon                                                                                                                            |

The calendar and the columns offer what `combobox-datetime` does. Unusable options raise
`ArgumentError`, including a `min` and `max` on the same or neighbouring dates with no time left on either; an
unavailable `value` stays selected, so validate it in the model.

```html
<div
  data-controller="popover combobox-datetime input-formatter"
  data-combobox-datetime-min-value="[min]"
  data-combobox-datetime-max-value="[max]"
  data-combobox-datetime-time-min-value="[time min]"
  data-combobox-datetime-time-max-value="[time max]"
  data-combobox-datetime-step-value="1"
  data-combobox-datetime-disabled-weekdays-value="[disabled weekdays]"
  data-input-formatter-format-value="datetime"
  data-action="calendar:changed->combobox-datetime#onDateChange popover:before-open->combobox-datetime#onOpening popover:opened->combobox-datetime#onOpened popover:closed->combobox-datetime#onClosed focusout->combobox-datetime#onFocusout mousedown->combobox-datetime#onMousedown click->combobox-datetime#onClick combobox-datetime:changed->input-formatter#onChange"
>
  <!-- trigger group and hidden input as in sp_combobox_date; the hidden input submits YYYY-MM-DDTHH:MM -->
  <div
    id="[id]_popover"
    popover="auto"
    role="dialog"
    aria-label="Choose [label]"
    data-action="keydown.esc->combobox-datetime#onEscape"
  >
    <!-- sp_calendar id="[id]_calendar", selectable, data-combobox-datetime-target="calendar" -->
    <div class="[combobox_time theme classes]">
      <!-- Hour, Minute, and AM/PM columns as in sp_combobox_time -->
    </div>
  </div>
</div>
```

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

`as: :select` renders `sp_combobox_dropdown`, `as: :search` `sp_combobox_typeahead`, `as: :date`
`sp_combobox_date`, `as: :time` `sp_combobox_time`, and `as: :datetime` `sp_combobox_datetime` (defaults in
[form.md](form.md)).

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
      [selected label]
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
`<div role="status" data-combobox-target="status">` after the listbox; the container carries
`data-combobox-empty-text-value` from `stimulus_plumbers.combobox.typeahead.empty`. With `source:`,
the container adds `combobox-turbo` with `source:` as `data-combobox-turbo-src-value`, and the listbox sits in `<turbo-frame id="[id]_popover_results">`; the
loading and error text come from `stimulus_plumbers.combobox.typeahead.loading` and `.error`. An option with a description adds
`data-label`, `aria-labelledby`, and `aria-describedby` pointing at its label and description
spans.

## Theme keys

| Key                           | Element                                |
| ----------------------------- | -------------------------------------- |
| `combobox`                    | Container `div`                        |
| `combobox_trigger_group`      | Input group around the trigger         |
| `combobox_trigger`            | Trigger                                |
| `combobox_trigger_icon`       | Leading/trailing icons                 |
| `combobox_dropdown_popover`   | `sp_combobox_dropdown` panel           |
| `combobox_typeahead_popover`  | `sp_combobox_typeahead` panel          |
| `combobox_date_popover`       | `sp_combobox_date` panel               |
| `combobox_time_popover`       | `sp_combobox_time` panel               |
| `combobox_datetime_popover`   | `sp_combobox_datetime` panel           |
| `combobox_listbox`            | Listbox                                |
| `combobox_option`             | Option                                 |
| `combobox_option_description` | Option description                     |
| `combobox_option_group`       | Group item                             |
| `combobox_option_group_label` | Group label                            |
| `combobox_status`             | Editable status                        |
| `combobox_time`               | Time and date-time panel columns row   |
| `combobox_datetime`           | Date-time panel: calendar and columns  |
| `combobox_time_drum`          | Time column (`type: :unit\|:meridiem`) |
