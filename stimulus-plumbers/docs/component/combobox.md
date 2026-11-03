# Combobox Controllers

`combobox` is the listbox combobox; `combobox-turbo` and `combobox-fetch` add remote results. `combobox-date`, `combobox-time`, and `combobox-datetime` keep a read-only input in step with their popover.

---

## combobox

One controller for a listbox combobox: keyboard, active option, commit, hidden value, and every close
path. The panel is a `popover="manual"` element opened through the
[popover plumber](../plumber/popover.md) with the trigger as source.

```html
<div
  data-controller="combobox"
  data-combobox-mode-value="editable"
  data-action="mousedown->combobox#onMousedown click->combobox#onClick"
>
  <input
    role="combobox"
    aria-autocomplete="list"
    aria-expanded="false"
    aria-controls="city_listbox"
    data-combobox-target="trigger"
    data-action="input->combobox#onInput keydown->combobox#onKeydown"
  />
  <input type="hidden" name="city_id" data-combobox-target="input" />
  <div popover="manual" data-combobox-target="panel">
    <ul id="city_listbox" role="listbox" data-combobox-target="listbox">
      <li id="city_sg" role="option" data-value="sg">Singapore</li>
    </ul>
    <div role="status" data-combobox-target="status"></div>
  </div>
</div>
```

Select-only uses a button trigger with no `input` action:

```html
<button
  type="button"
  role="combobox"
  aria-expanded="false"
  aria-controls="country_listbox"
  data-combobox-target="trigger"
  data-action="keydown->combobox#onKeydown"
>
  Singapore
</button>
```

**Targets**

| Target    | Element                                             | Description                                |
| --------- | --------------------------------------------------- | ------------------------------------------ |
| `trigger` | `<button type="button">` (select-only) or `<input>` | Keeps DOM focus; shows the committed label |
| `input`   | `input[type=hidden]`                                | Submitted value                            |
| `panel`   | `[popover="manual"]`                                | Popup; contains the listbox                |
| `listbox` | `[role=listbox]`                                    | Options with `role="option"`               |
| `status`  | `[role=status]` after the listbox                   | Required when editable; shows `emptyText`  |

Options read `data-value` (falls back to the label) and `data-label` (falls back to text). Options
without an `id` get one.

**Values**

| Value           | Type    | Default       | Description                                                                                                                           |
| --------------- | ------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `mode`          | String  | `select_only` | `select_only` or `editable`                                                                                                           |
| `valuePolicy`   | String  | `restricted`  | Editable only: `restricted` empties the hidden value while editing and reverts uncommitted text on close; `freeform` submits the text |
| `closeOnCommit` | Boolean | `true`        | Closes the panel after a commit                                                                                                       |
| `match`         | String  | `prefix`      | Editable only: `prefix`, `contains`, `fuzzy` (characters in order), or `none` (server-filtered results)                               |
| `minLength`     | Number  | `1`           | Editable only: a shorter query counts as empty and shows every option                                                                 |
| `emptyText`     | String  | `No results`  | Status text when a query matches no option                                                                                            |

**Methods**

| Method               | Wired via                      | Description                                                                                                        |
| -------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| `onKeydown(event)`   | `keydown` on the trigger       | Keyboard contract                                                                                                  |
| `onInput()`          | `input` on an editable trigger | Clears the active option, filters, dispatches `query` when the query changes, opens                                |
| `onClick(event)`     | `click` on the root            | Commits a clicked option; elsewhere outside the panel and other controls, toggles (select-only) or opens the panel |
| `onMousedown(event)` | `mousedown` on the root        | Keeps focus on the trigger outside the trigger itself                                                              |
| `commit(option)`     | —                              | Commits an enabled, visible option; returns `false` if refused                                                     |

**Dispatches**

| Event                    | Cancellable | Detail                     |
| ------------------------ | ----------- | -------------------------- |
| `combobox:query`         | no          | `{ query, sequence }`      |
| `combobox:results`       | no          | `{ query, count }`         |
| `combobox:before-change` | yes         | `{ value, label, option }` |
| `combobox:changed`       | no          | `{ value, label, option }` |
| `combobox:before-open`   | yes         | `{ source }`               |
| `combobox:opened`        | no          | `{ source }`               |
| `combobox:closed`        | no          | `{ source }`               |

Filtering matches each option label against the query by `match`, ignoring case and accents, and
hides non-matching options and empty groups. `results` dispatches after the listbox and status are
updated. Closing clears the filter. The panel opens only with a visible option or status text.

Popup events dispatch from the panel. The panel also closes on `turbo:before-cache`. A form reset
restores the server-rendered value. See
[ARIA.md's Combobox pattern](../../../ARIA.md#combobox-combobox_controller) for keyboard, ARIA,
and the other close paths.

---

## Remote results

`combobox` never fetches. A remote adapter sits beside it on the root, listens for
`combobox:query`, and replaces the listbox with one that keeps the same `id` and
`data-combobox-target="listbox"`. The combobox adopts the replacement and writes the empty status;
the adapter writes loading and error text to the shared `status` element. Set `match` to `none`
so the server's results are not filtered again.

Both adapters share these values and actions:

| Value         | Type   | Default                       | Description                                               |
| ------------- | ------ | ----------------------------- | --------------------------------------------------------- |
| `src`         | String | —                             | Results URL; the query is added as `param`                |
| `param`       | String | `q`                           | Query parameter name; an empty query requests `src` as is |
| `delay`       | Number | `300`                         | Debounce in ms; an empty query loads at once              |
| `loadingText` | String | `Loading…`                    | Status while a query is pending                           |
| `errorText`   | String | `Results could not be loaded` | Status after a failed request; the next query retries     |

| Method            | Wired via                     | Description                                                         |
| ----------------- | ----------------------------- | ------------------------------------------------------------------- |
| `onQuery(event)`  | `combobox:query` on the root  | Cancels the pending and in-flight request, then debounces a new one |
| `onClosed(event)` | `combobox:closed` on the root | Cancels the pending and in-flight request                           |

### combobox-turbo

Navigates a Turbo Frame around the listbox. The endpoint responds with a page containing the same
frame `id` and listbox. Removing the frame `src` cancels Turbo's request; Turbo sets `aria-busy` on
the frame while loading.

```html
<div
  data-controller="combobox combobox-turbo"
  data-combobox-mode-value="editable"
  data-combobox-match-value="none"
  data-combobox-turbo-src-value="/cities"
  data-action="mousedown->combobox#onMousedown click->combobox#onClick combobox:query->combobox-turbo#onQuery combobox:closed->combobox-turbo#onClosed"
>
  <!-- trigger and hidden input as above -->
  <div popover="manual" data-combobox-target="panel">
    <turbo-frame
      id="city_results"
      data-combobox-turbo-target="frame"
      data-action="turbo:before-fetch-response->combobox-turbo#onResponse turbo:frame-missing->combobox-turbo#onError turbo:fetch-request-error->combobox-turbo#onError"
    >
      <ul id="city_listbox" role="listbox" data-combobox-target="listbox"></ul>
    </turbo-frame>
    <div role="status" data-combobox-target="status" data-combobox-turbo-target="status"></div>
  </div>
</div>
```

| Target   | Description                          |
| -------- | ------------------------------------ |
| `frame`  | `<turbo-frame>` wrapping the listbox |
| `status` | The combobox's `status` element      |

| Method              | Wired via                                          | Description                                                                   |
| ------------------- | -------------------------------------------------- | ----------------------------------------------------------------------------- |
| `onResponse(event)` | `turbo:before-fetch-response` on the frame         | Shows `errorText` for a failed or non-HTML response for its frame             |
| `onError(event)`    | `turbo:frame-missing`, `turbo:fetch-request-error` | Shows `errorText` for its frame; prevents only Turbo's missing-frame handling |

### combobox-fetch

Loads the listbox through the [fragment loader](../plumber/fragment_loader.md): it replaces the listbox
with the response element of the same `id`. No Turbo dependency.

```html
<div
  data-controller="combobox combobox-fetch"
  data-combobox-mode-value="editable"
  data-combobox-match-value="none"
  data-combobox-fetch-src-value="/cities"
  data-action="mousedown->combobox#onMousedown click->combobox#onClick combobox:query->combobox-fetch#onQuery combobox:closed->combobox-fetch#onClosed"
>
  <!-- trigger and hidden input as above -->
  <div popover="manual" data-combobox-target="panel">
    <ul id="city_listbox" role="listbox" data-combobox-target="listbox"></ul>
    <div role="status" data-combobox-target="status" data-combobox-fetch-target="status"></div>
  </div>
</div>
```

| Target   | Description                     |
| -------- | ------------------------------- |
| `status` | The combobox's `status` element |

---

## combobox-date

Keeps a read-only date input in step with the [`calendar`](calendar.md#calendar) in its popover
([Rails `sp_combobox_date`](../../../stimulus-plumbers-rails/docs/component/combobox.md#sp_combobox_date)).
Pairs with [`popover`](popover.md), which opens the panel, and [`input-formatter`](input-formatter.md), which
formats the input from `combobox-date:changed`.

```html
<div
  data-controller="popover combobox-date input-formatter"
  data-input-formatter-format-value="date"
  data-action="calendar:changed->combobox-date#onChange focusout->combobox-date#onFocusout mousedown->combobox-date#onMousedown click->combobox-date#onClick combobox-date:changed->input-formatter#onChange"
>
  <input
    role="combobox"
    readonly
    value="2026-09-15"
    aria-haspopup="dialog"
    aria-expanded="false"
    aria-controls="birthday_popover"
    data-popover-target="trigger"
    data-combobox-date-target="trigger"
    data-input-formatter-target="input"
    data-action="focus->popover#onFocus click->popover#onOpen keydown->combobox-date#onKeydown"
  />
  <input type="hidden" name="person[birthday]" value="2026-09-15" data-combobox-date-target="input" />
  <div id="birthday_popover" popover="auto" role="dialog" data-popover-target="panel" data-combobox-date-target="panel">
    <!-- sp_calendar markup -->
  </div>
</div>
```

**Targets**

| Target    | Description                                      |
| --------- | ------------------------------------------------ |
| `trigger` | Read-only input showing the formatted date       |
| `input`   | Hidden input that submits the `YYYY-MM-DD` value |
| `panel`   | Popover holding the calendar                     |

**Actions**

| Action               | Wired on                   | Description                                                                                                              |
| -------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `onKeydown(event)`   | `keydown` on `trigger`     | ArrowDown opens the panel and focuses the calendar's Tab stop; Tab closes the panel                                      |
| `onFocusout(event)`  | `focusout` on root         | Closes the panel when focus leaves the combobox                                                                          |
| `onClick(event)`     | `click` on root            | A click on the icons or padding focuses `trigger` and opens the panel                                                    |
| `onMousedown(event)` | `mousedown` on root        | Keeps focus on `trigger` while the icons or padding are pressed                                                          |
| `onChange(event)`    | `calendar:changed` on root | Copies the value into `input`, dispatches `change` on it when the value differs, closes the panel, and focuses `trigger` |

**Dispatches**

| Event                   | Detail                     | When                                |
| ----------------------- | -------------------------- | ----------------------------------- |
| `combobox-date:changed` | `{ value }` (`YYYY-MM-DD`) | After a commit and after form reset |

Events from a nested combobox date are ignored.

---

## combobox-time

Keeps a read-only time input in step with the hour, minute, and AM/PM columns in its popover
([Rails `sp_combobox_time`](../../../stimulus-plumbers-rails/docs/component/combobox.md#sp_combobox_time)).
Pairs with [`popover`](popover.md), which opens the panel, and [`input-formatter`](input-formatter.md), which
formats the input from `combobox-time:changed`.

```html
<div
  data-controller="popover combobox-time input-formatter"
  data-input-formatter-format-value="time"
  data-action="popover:before-open->combobox-time#onOpening popover:opened->combobox-time#onOpened popover:closed->combobox-time#onClosed focusout->combobox-time#onFocusout mousedown->combobox-time#onMousedown click->combobox-time#onClick combobox-time:changed->input-formatter#onChange"
>
  <input
    role="combobox"
    readonly
    value="14:30"
    aria-haspopup="dialog"
    aria-expanded="false"
    aria-controls="meeting_popover"
    data-popover-target="trigger"
    data-combobox-time-target="trigger"
    data-input-formatter-target="input"
    data-action="focus->popover#onFocus click->popover#onOpen keydown->combobox-time#onKeydown"
  />
  <input type="hidden" name="meeting" value="14:30" data-combobox-time-target="input" />
  <div id="meeting_popover" popover="auto" role="dialog" data-popover-target="panel" data-combobox-time-target="panel">
    <ul
      role="listbox"
      tabindex="0"
      aria-label="Hour"
      aria-activedescendant="meeting_hour_2"
      data-combobox-time-target="hour"
      data-action="keydown->combobox-time#onNavigate click->combobox-time#onSelect"
    >
      <li role="option" id="meeting_hour_1" data-value="1" aria-selected="false">1</li>
      <li role="option" id="meeting_hour_2" data-value="2" aria-selected="true">2</li>
      <!-- … -->
    </ul>
    <!-- minute column; meridiem column (data-value AM / PM) for a 12-hour cycle -->
  </div>
</div>
```

**Targets**

| Target     | Description                                                                  |
| ---------- | ---------------------------------------------------------------------------- |
| `trigger`  | Read-only input showing the formatted time                                   |
| `input`    | Hidden input that submits the `HH:MM` value                                  |
| `panel`    | Popover holding the columns                                                  |
| `hour`     | Hour column; option values `1`–`12` with a `meridiem` column, else `00`–`23` |
| `minute`   | Minute column; option values `00`–`59`                                       |
| `meridiem` | Optional AM/PM column; option values `AM` and `PM`                           |

**Values**

| Value        | Type   | Default | Description                                                          |
| ------------ | ------ | ------- | -------------------------------------------------------------------- |
| `min`, `max` | String | `""`    | Range as `HH:MM`, inclusive; a `min` after `max` wraps past midnight |
| `step`       | Number | `1`     | Minutes counted from midnight; one of 1–6, 10, 12, 15, 20, 30, 60    |

An option is unavailable (`aria-disabled="true"`) when no time in `min`–`max` and on the `step` matches it and the
choices it depends on: an hour depends on the chosen AM or PM, a minute on the chosen AM or PM and hour. Arrows, Home,
and End skip unavailable options and a click on one does nothing. A choice that makes a chosen option unavailable
keeps it chosen, and nothing goes into `input` until every chosen option is available. Closing the panel then discards those choices, and the columns show the value in `input` again. Invalid `min`, `max`, or `step` values, or ones that leave no time, are reported with `console.error`.

**Actions**

| Action               | Wired on                      | Description                                                                                                                                       |
| -------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `onKeydown(event)`   | `keydown` on `trigger`        | ArrowDown opens the panel and focuses `hour`; Tab closes the panel; Escape as in `onNavigate`                                                     |
| `onOpening(event)`   | `popover:before-open` on root | Records the value Escape restores                                                                                                                 |
| `onOpened(event)`    | `popover:opened` on root      | Scrolls the chosen options into view                                                                                                              |
| `onClosed(event)`    | `popover:closed` on root      | Discards the choices that left a chosen option unavailable                                                                                        |
| `onNavigate(event)`  | `keydown` on a column         | Arrows, Home, and End choose an option; Enter closes the panel; Escape restores the value from opening and closes the panel; both focus `trigger` |
| `onSelect(event)`    | `click` on a column           | Chooses the clicked option                                                                                                                        |
| `onFocusout(event)`  | `focusout` on root            | Closes the panel when focus leaves the combobox                                                                                                   |
| `onClick(event)`     | `click` on root               | A click on the icons or padding focuses `trigger` and opens the panel                                                                             |
| `onMousedown(event)` | `mousedown` on root           | Keeps focus on `trigger` while the icons or padding are pressed                                                                                   |

Choosing an option sets `aria-selected` and the column's `aria-activedescendant`. Once hour, minute, and any AM or PM are chosen, the value goes into `input`, which dispatches `change` when the value differs.

**Dispatches**

| Event                   | Detail                | When                                                           |
| ----------------------- | --------------------- | -------------------------------------------------------------- |
| `combobox-time:changed` | `{ value }` (`HH:MM`) | After a choice that completes the time, Escape, and form reset |

---

## combobox-datetime

Extends [`combobox-time`](#combobox-time) with a [`calendar`](calendar.md#calendar) in the popover
([Rails `sp_combobox_datetime`](../../../stimulus-plumbers-rails/docs/component/combobox.md#sp_combobox_datetime)).
It has the `combobox-time` targets, actions, and keys; `input` submits the `YYYY-MM-DDTHH:MM` value. It adds:

**Targets**

| Target     | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `calendar` | The `calendar` root; its `selected` value is the chosen date |

**Values**

| Value                | Type   | Default | Description                            |
| -------------------- | ------ | ------- | -------------------------------------- |
| `min`, `max`         | String | `""`    | Range as `YYYY-MM-DDTHH:MM`, inclusive |
| `timeMin`, `timeMax` | String | `""`    | Daily window as `HH:MM`, inclusive     |
| `step`               | Number | `1`     | As in `combobox-time`                  |

The time columns offer the chosen date's times: the daily window, cut off before `min` on its date and after `max` on
its date. A daily window that wraps past midnight offers each date its own times after `timeMin` and before `timeMax`.
Before a date is chosen they offer the daily window. The calendar's own values limit the dates.
Invalid `min`, `max`, `timeMin`, `timeMax`, or `step` values, or ones that leave no time, are reported with
`console.error`.

**Actions**

| Action            | Wired on                   | Description                                                                      |
| ----------------- | -------------------------- | -------------------------------------------------------------------------------- |
| `onDateChange()`  | `calendar:changed` on root | Takes the chosen date; the panel stays open                                      |
| `onEscape(event)` | `keydown.esc` on `panel`   | Restores the date and time from opening, closes the panel, and focuses `trigger` |

ArrowDown on `trigger` focuses the calendar's Tab stop. Once a date, hour, minute, and any AM or PM are chosen and
available, the value goes into `input`.

**Dispatches**

| Event                       | Detail                           | When                                                                |
| --------------------------- | -------------------------------- | ------------------------------------------------------------------- |
| `combobox-datetime:changed` | `{ value }` (`YYYY-MM-DDTHH:MM`) | After a choice that completes the date-time, Escape, and form reset |

## Migration from the legacy combobox controllers

| Legacy                                                                                                                                  | Use                                                                                                                            |
| --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `input-combobox` + `combobox-dropdown`                                                                                                  | [`combobox`](#combobox), with a manual popover panel                                                                           |
| `combobox-date` targets `previous`, `next`, `day`, `month`, `year`, `viewTitle`; `calendar-*` outlets; `date`, `view`, `locales` values | [`combobox-date`](#combobox-date): targets `trigger`, `input`, `panel`, with a [`calendar`](calendar.md#calendar) in the panel |
| `combobox-time` `period` target                                                                                                         | `meridiem` target                                                                                                              |
| `combobox-time` columns only                                                                                                            | [`combobox-time`](#combobox-time): adds targets `trigger`, `input`, `panel`                                                    |
| `combobox-dropdown` `url` value                                                                                                         | [`combobox-fetch`](#combobox-fetch) or [`combobox-turbo`](#combobox-turbo)                                                     |
