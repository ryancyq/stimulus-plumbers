# Combobox Controllers

The combobox family uses a layered design. `input-combobox` and `input-formatter` live on the wrapper; a picker sub-controller lives inside the popover.

```
input-combobox + input-formatter   ← wrapper
└── [popover]
      └── combobox-date         ← date picker (calendar grid)
      └── combobox-time         ← time picker (drum/scroll-wheel)
      └── combobox-dropdown     ← listbox (dropdown & typeahead)
```

---

## input-combobox

Owns the trigger input, popover visibility, and hidden value. Always co-located with `input-formatter`.

**Targets**

| Target    | Element              | Description                                     |
| --------- | -------------------- | ----------------------------------------------- |
| `trigger` | `input[type=text]`   | The combobox input (display + focus management) |
| `input`   | `input[type=hidden]` | Holds the submitted value                       |

**Values**

| Value       | Type   | Default | Description                                                            |
| ----------- | ------ | ------- | ---------------------------------------------------------------------- |
| `value`     | String | `""`    | Current selected value; setting it triggers `valueValueChanged`        |
| `minLength` | Number | `1`     | Min query length before typeahead relays to `combobox-dropdown` outlet |

**Outlets**

| Outlet              | Description                         |
| ------------------- | ----------------------------------- |
| `combobox-dropdown` | Optional; present in typeahead mode |

**Methods**

| Method            | Wired via             | Description                                                                        |
| ----------------- | --------------------- | ---------------------------------------------------------------------------------- |
| `onSelect(event)` | `combobox-*:selected` | Event adapter — writes `event.detail.value` to `valueValue`; popover handles close |
| `onInput(event)`  | `input` on trigger    | Event adapter — extracts query, relays to `comboboxDropdownOutlet.filter(query)`   |

**Dispatches**

| Event                    | Detail      | When                                              |
| ------------------------ | ----------- | ------------------------------------------------- |
| `input-combobox:changed` | `{ value }` | After `valueValue` changes (including on connect) |

---

## input-formatter

Formats and displays values. Always co-located with `input-combobox`.

**Targets**

| Target   | Element                  | Description                                                               |
| -------- | ------------------------ | ------------------------------------------------------------------------- |
| `input`  | `<input>` or any element | Write destination — sets `.value` for `<input>`, `.textContent` otherwise |
| `toggle` | `<button>`               | Reveal/conceal button (maskable/password types only)                      |

**Values**

| Value      | Type    | Default   | Description                                               |
| ---------- | ------- | --------- | --------------------------------------------------------- |
| `format`   | String  | `"plain"` | `plain` \| `password` \| `creditCard` \| `date` \| `time` |
| `options`  | Object  | `{}`      | Formatter options (e.g. `{ format: "h12" }` for time)     |
| `revealed` | Boolean | `false`   | Whether a masked value is currently revealed              |

**Methods**

| Method            | Wired via                | Description                                                                      |
| ----------------- | ------------------------ | -------------------------------------------------------------------------------- |
| `format(value)`   | —                        | Programmatic API — normalises, formats, writes to target, dispatches `formatted` |
| `onChange(event)` | `input-combobox:changed` | Event adapter — extracts `event.detail.value`, calls `format(value)`             |
| `onPaste(event)`  | `clipboard:pasted`       | Event adapter — normalises and validates pasted text, calls `format(value)`      |
| `toggle()`        | `data-action`            | Action — flips `revealedValue` (maskable / password types only)                  |

**Dispatches**

| Event                       | Detail      | When                                    |
| --------------------------- | ----------- | --------------------------------------- |
| `input-formatter:formatted` | `{ value }` | After every write to the `input` target |

---

## combobox-date

Navigates a calendar grid with month, year, and decade views. Requires a `calendar-month` outlet; `calendar-year` and `calendar-decade` are optional for drill-down. View switching hides/shows outlet elements directly — no named targets for view containers.

**Targets**

| Target      | Description                                                            |
| ----------- | ---------------------------------------------------------------------- |
| `previous`  | Button that steps backward (one month / one year / one decade by view) |
| `next`      | Button that steps forward (one month / one year / one decade by view)  |
| `viewTitle` | Button showing the current view label (e.g. "June 2025" / "2025")      |
| `day`       | Rendered day label element (display only)                              |
| `month`     | Rendered month label element (display only)                            |
| `year`      | Rendered year label element (display only)                             |

**Outlets**

| Outlet            | Description                                                  |
| ----------------- | ------------------------------------------------------------ |
| `calendar-month`  | Required — provides the day grid and calendar navigation API |
| `calendar-year`   | Optional — year view grid; shown when `view` is `"year"`     |
| `calendar-decade` | Optional — decade view grid; shown when `view` is `"decade"` |

**Values**

| Value         | Type   | Default       | Description                                                 |
| ------------- | ------ | ------------- | ----------------------------------------------------------- |
| `date`        | String | `""`          | ISO 8601 initial date; navigates calendar on outlet connect |
| `view`        | String | `"month"`     | Current view — `"month"` \| `"year"` \| `"decade"`          |
| `locales`     | Array  | `["default"]` | `Intl.DateTimeFormat` locales                               |
| `dayFormat`   | String | `"numeric"`   | Day label format                                            |
| `monthFormat` | String | `"long"`      | Month label format                                          |
| `yearFormat`  | String | `"numeric"`   | Year label format                                           |

**Methods**

| Method                 | Wired via                   | Description                                                                              |
| ---------------------- | --------------------------- | ---------------------------------------------------------------------------------------- |
| `previous()`           | click on `previous` target  | Steps back: one month (month view), one year (year view), one decade (decade view)       |
| `next()`               | click on `next` target      | Steps forward: one month (month view), one year (year view), one decade (decade view)    |
| `zoomOut()`            | click on `viewTitle` target | Zooms out: month → year → decade view                                                    |
| `onDaySelect(event)`   | `calendar-month:selected`   | Event adapter — updates `dateValue`, redraws labels, dispatches `combobox-date:selected` |
| `onMonthSelect(event)` | `calendar-year:selected`    | Event adapter — navigates calendar to selected month, switches to month view             |
| `onYearSelect(event)`  | `calendar-decade:selected`  | Event adapter — navigates calendar to selected year, switches to year view               |

**Dispatches**

| Event                    | Detail                 | When                      |
| ------------------------ | ---------------------- | ------------------------- |
| `combobox-date:selected` | `{ value }` (ISO 8601) | After a date is confirmed |

---

## combobox-time

Drum/scroll-wheel time picker. Each drum is a `ul[role=listbox]`.

**Targets:** `hour`, `minute`, `period` (period only present in h12 mode)

**Methods**

| Method              | Wired via                | Description                                                                         |
| ------------------- | ------------------------ | ----------------------------------------------------------------------------------- |
| `select(value)`     | —                        | Programmatic API — dispatches `combobox-time:selected` with the given 24-hour value |
| `onSelect(event)`   | `click` on a drum option | Event adapter — marks clicked option `aria-selected="true"`, calls `select(value)`  |
| `onNavigate(event)` | `keydown` on a drum      | Event adapter — ArrowUp/ArrowDown call `step(drum, delta)`                          |
| `step(drum, delta)` | —                        | Programmatic API — moves selection by `delta` steps in the given drum element       |

**Dispatches**

| Event                    | Detail                          | When                                                          |
| ------------------------ | ------------------------------- | ------------------------------------------------------------- |
| `combobox-time:selected` | `{ value }` (`"HH:MM"` 24-hour) | On connect (if pre-selected) and after every user interaction |

---

## combobox-dropdown

Listbox with client-side fuzzy filter or server-side fetch. Used by both dropdown and typeahead variants.

**Targets**

| Target    | Description                               |
| --------- | ----------------------------------------- |
| `listbox` | `ul[role=listbox]` containing the options |
| `loading` | Shown during server fetch                 |
| `empty`   | Shown when no options match               |

**Values**

| Value   | Type   | Default | Description                                                 |
| ------- | ------ | ------- | ----------------------------------------------------------- |
| `url`   | String | `""`    | Fetch URL — empty string activates client-side fuzzy filter |
| `field` | String | `"q"`   | Query parameter name appended to `url`                      |
| `delay` | Number | `300`   | Debounce delay in ms before issuing a server fetch          |

**Methods**

| Method              | Wired via                | Description                                                                                   |
| ------------------- | ------------------------ | --------------------------------------------------------------------------------------------- |
| `select(value)`     | —                        | Programmatic API — sets `aria-selected` on matching option, dispatches `selected`             |
| `onSelect(event)`   | `click` on an option     | Event adapter — extracts value from click target, calls `select(value)`                       |
| `onNavigate(event)` | `keydown` on listbox     | Event adapter — ArrowUp/ArrowDown call `step(delta)`; Enter/Space activates current selection |
| `step(delta)`       | —                        | Programmatic API — moves `aria-selected` by `delta` steps (+1 down, -1 up)                    |
| `filter(query)`     | `input-combobox` outlet  | Programmatic API — routes to fuzzy filter (client) or debounced fetch (server)                |
| `showAll()`         | `input-combobox#onInput` | Programmatic API — unhides all options when query drops below `minLength`                     |

**Dispatches**

| Event                        | Detail      | When                        |
| ---------------------------- | ----------- | --------------------------- |
| `combobox-dropdown:selected` | `{ value }` | After an option is selected |

**Filter implementation**

`combobox-dropdown` uses two standalone utilities internally:

- **Client-side** (`url` is empty): calls `filterOptions(listboxTarget, query)` from `researcher.js` — hides non-matching `[role="option"]` elements using fuzzy matching by default. See [Researcher docs](../utility/researcher.md) for strategy and field options.
- **Server-side** (`url` is set): debounces requests via `Requestor` from `requestor.js`, then issues `GET {url}?{field}={query}`. See [Requestor docs](../utility/requestor.md) for abort and debounce behaviour.

**Server fetch contract**

`GET {url}?{field}={query}` — expected response: an HTML fragment of `<li role="option" data-value="...">` elements, which replaces the inner HTML of the `listbox` target.

---

## Event flow

```
user picks value
  └─ combobox-*:selected { value }
       └─ input-combobox#onSelect       ← event adapter
            └─ valueValue = value        → valueValueChanged
                 ├─ inputTarget.value = value
                 └─ dispatch input-combobox:changed { value }
                      └─ input-formatter#onChange  ← event adapter
                           └─ format(value)       ← programmatic API
                                ├─ formats value
                                ├─ writes to inputTarget
                                └─ dispatch input-formatter:formatted { value }

(popover closes separately via popover#closeOnSelect)
```

---

## Naming convention

| Pattern      | Wired via             | Role                                                       | Example                                                                                       |
| ------------ | --------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `onX(event)` | DOM or Stimulus event | Event adapter — extracts payload, calls programmatic API   | `onSelect(event)`, `onChange(event)`, `onPaste(event)`, `onInput(event)`, `onNavigate(event)` |
| `x(value)`   | — (called directly)   | Programmatic API — pure logic, no event awareness          | `select('us')`, `format('4242…')`, `step(1)`, `filter('query')`                               |
| `past()`     | Plumber               | Plumber callback — called by plumber after async operation | `shown()`, `dismissed()`, `contentLoaded()`                                                   |
