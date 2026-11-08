# Calendar and calendar field modernization — date-only state and one grid contract

**Original date:** 2026-09-11  
**Status:** Proposed for implementation review  
**Packages:** `stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`  
**Dependencies:** [Modal modernization](./2026-09-09-modal-modernization-design.md) for
dialog presentation; overlay modernization is not required for the initial calendar field  
**Release dependency (2026-10-05):** ships with the combobox redesign, which removes `combobox-date`
([roadmap](./2026-09-11-component-modernization-roadmap.md))

## Summary

The current calendar has two renderers and several partial controllers. Client-side month, year,
and decade controllers generate DOM from JavaScript `Date`; Rails/Turbo renderers generate
similar markup from Ruby `Date`; selector controllers add click handling only. These paths have
already diverged in focusability, markup, constraints, and date formats.

The replacement defines one server-rendered grid contract enhanced by one `calendar` controller.
All internal state is date-only (`YYYY-MM-DD` and integer year/month/day), never an instant or
timezone-bearing timestamp. Rails/Turbo is the recommended navigation source: previous/next
links return a matching frame using the same renderer, while Stimulus preserves keyboard focus
and selection across replacement. Framework-neutral consumers can respond to navigation events
with the same markup contract.

The product surface is split into an inline calendar and an optional calendar field whose dialog
holds the grid. Rails native `date_field` remains the default for ordinary forms and Hotwire Native.
The calendar field is opt-in when product constraints justify maintaining a full accessible grid.

## Goals

- Make every selectable date keyboard reachable with the documented grid interaction.
- Maintain exactly one calendar-grid Tab stop.
- Eliminate timezone and end-of-month rollover defects.
- Give Rails-rendered, Turbo-replaced, and standalone-enhanced markup one semantic contract.
- Preserve focus intent when navigation replaces the visible month/year/decade.
- Keep focused date, displayed period, selected date, and today's date separate.
- Support range and disabled-date constraints consistently.
- Provide an accessible native-dialog calendar field without treating it as a listbox combobox.
- Prefer native date input on mobile/Hotwire Native unless a product requirement opts into the
  calendar field.

## Non-goals

- Date-range selection in the first release.
- Time-zone selection or timestamp editing.
- A combined date-and-time field.
- Infinite scrolling months.
- Drag or swipe navigation as the only means of changing periods.
- Shipping a Temporal polyfill as a transitive dependency.
- Treating axe scans as proof of keyboard conformance.
- Automatically replacing native platform date entry in Hotwire Native.

## Current implementation

```text
client renderer                         Rails/Turbo renderer
---------------                         --------------------
calendar-month                          Calendar::Turbo::DaysOfMonth
calendar-year                           Calendar::Turbo::MonthsOfYear
calendar-decade                         Calendar::Turbo::YearsOfDecade
Calendar plumber                        Ruby Date calculations
calendar-* selector plumbers            click-only selector controllers

                 combobox-date orchestrates both concepts
```

Verified defects and gaps:

1. Client-rendered month buttons are all assigned `tabindex="-1"`; no calendar key handler makes
   one reachable or moves focus.
2. Client year/decade buttons remain ordinary Tab stops, while Turbo-rendered equivalents use one
   roving Tab stop but have no arrow-key controller. The modes expose different behavior.
3. The documented Arrow, Home, End, Page Up, Page Down, Enter, Space, and Escape interactions are
   absent from the calendar controllers.
4. Month navigation mutates `Date#setMonth`. January 31 plus one month can become March, and leap
   day year navigation can roll into March.
5. `disabledDates` parses date-only strings with `new Date(value)` while generated calendar dates
   use local midnight; the epochs differ outside UTC.
6. The weekday seed `new Date("2024-10-06")` is a UTC instant and can be Saturday in negative UTC
   offsets.
7. Client cells serialize instants with `toISOString`; Turbo cells serialize Ruby date-only ISO
   strings.
8. Constraint options exposed by the `Calendar` plumber are not consistently exposed as
   Stimulus values or Rails helper options.
9. Client code and Ruby renderers duplicate month layout, localized labels, disabled state,
   selected state, and focus choice without shared conformance fixtures.
10. Date selection is embedded as a `combobox-date` variant even though its dialog popup moves DOM
    focus and follows a different keyboard model from listbox comboboxes.

## Design principles

1. **A civil date is not an instant.** Calendar state never depends on local offset or UTC epoch.
2. **Server markup is the first render.** Stimulus enhances semantics; it does not replace correct
   Rails HTML on connection.
3. **Focus, selection, today, and display are different state.** Each has one representation.
4. **One grid contract spans every navigation source.** Local replacement and Turbo replacement
   must produce identical roles, IDs, and focus markers.
5. **Native controls are the default.** A custom calendar must be chosen for a named requirement,
   not merely for styling.
6. **Keyboard behavior is part of rendering correctness.** A grid with valid roles but no
   navigation is not complete.
7. **Latency cannot erase focus intent.** Turbo navigation records the intended date before the
   request and restores the closest valid target after replacement.

## Architecture

```text
ordinary Rails form                   calendar field
-------------------                   ----------------------
input[type=date]                      text display + choose-date button
        |                                      |
        |                              native <dialog>
        |                                      |
        |                               calendar controller
        |                                      |
        `-- platform date entry             turbo-frame period
                                               |
                                        Rails calendar renderer

inline calendar uses the same calendar controller and renderer without a dialog
```

## Decisions

### D1 — Separate native date field, inline calendar, and calendar field

The public products are:

| Product             | Default use                                             |
| ------------------- | ------------------------------------------------------- |
| Rails `date_field`  | ordinary single-date form entry and Hotwire Native      |
| `sp_calendar`       | inline calendar or date display/selection               |
| `sp_calendar_field` | date field with a calendar dialog, for explicit needs   |

`combobox-date` is deprecated. `sp_calendar_field` follows the modal dialog model: a labelled
input/display and choose-date button open a native dialog containing the grid. It does not claim
the listbox combobox focus model.

The first release does not switch one element between popover and modal presentation at a CSS
breakpoint. The calendar field uses one native-dialog lifecycle at every web breakpoint. Themes
may change its dimensions but not its modality.

Amended 2026-10-11: `sp_calendar_field` is replaced by `sp_combobox_date`, which keeps the legacy
combobox-date look: a read-only `role="combobox"` input with a decorative calendar icon opens a
non-modal popover holding the `sp_calendar` grid. See D11.

### D2 — Introduce a date-only core

Add pure, framework-independent utilities under `src/date/`:

| Function                            | Contract                                                    |
| ----------------------------------- | ----------------------------------------------------------- |
| `parseDateKey(value)`               | strict valid `YYYY-MM-DD` to `{ year, month, day }` or null |
| `dateKey(parts)`                    | normalized `YYYY-MM-DD` serialization                       |
| `compareDate(a, b)`                 | date-only ordering                                          |
| `addDays(date, amount)`             | calendar-day addition                                       |
| `addMonths(date, amount, overflow)` | month addition with explicit clamp/reject policy            |
| `addYears(date, amount, overflow)`  | year addition with explicit leap-day policy                 |
| `daysInMonth(year, month)`          | Gregorian month length                                      |
| `weekday(date)`                     | stable weekday independent of process timezone              |
| `monthGrid(date, firstDayOfWeek)`   | ordered date keys for the displayed grid                    |

Default overflow policy is `clamp`: January 31 plus one month becomes the last valid day of
February; February 29 plus one year becomes February 28.

The core does not use `new Date("YYYY-MM-DD")`, local-midnight equality, or `toISOString()` as
calendar identity. If `Date` is needed only for `Intl.DateTimeFormat`, conversion uses a stable
UTC construction and formats in `timeZone: "UTC"` so the date key cannot shift.

Native `Temporal.PlainDate` may replace the internal implementation in a future release after the
declared browser floor and bundle policy support it. The public date-key contract does not depend
on that choice.

`plumbers/plumber/date.js` stays for instant parsing in other plumbers; `src/date/` never imports
it. The core takes date keys at its boundaries and parts for arithmetic, supports years 0001–9999
(arithmetic outside returns null), and `constraintErrors(constraints)` names D9 problems for the
controller (amended 2026-10-10).

### D3 — One semantic calendar markup contract

Rails renders a semantic table:

```html
<div
  data-controller="calendar"
  data-calendar-selected-value="2026-09-15"
  data-calendar-selectable-value="true"
>
  <div role="status" class="sr-only" data-calendar-target="status"></div>
  <turbo-frame id="calendar_frame">
  <h2 id="calendar_heading">September 2026</h2>

  <table
    role="grid"
    aria-labelledby="calendar_heading"
    data-calendar-target="grid"
    data-displayed="2026-09-01"
    data-view="month"
  >
    <thead>
      <tr>
        <th scope="col" abbr="Sunday">Su</th>
        ...
      </tr>
    </thead>
    <tbody>
      <tr>
        <td role="gridcell" aria-selected="false">
          <button
            type="button"
            tabindex="-1"
            data-calendar-target="day"
            data-date="2026-09-14"
            data-display="14 September 2026"
            aria-label="14 September 2026"
          >
            14
          </button>
        </td>
        <td role="gridcell" aria-selected="true">
          <button
            type="button"
            tabindex="0"
            data-calendar-target="day"
            data-date="2026-09-15"
            data-display="15 September 2026"
            aria-label="15 September 2026"
          >
            15
          </button>
        </td>
      </tr>
    </tbody>
  </table>
  </turbo-frame>
</div>
```

Contract:

- Exactly one enabled date button has `tabindex="0"`; all other date buttons have `-1`.
- Grid structure lives on table elements; buttons retain native activation semantics.
- `aria-selected` lives on the gridcell representing the committed date.
- `aria-current="date"` identifies today independently of selection.
- Other-month dates may be hidden or visible according to configuration, but visible selectable
  dates participate in navigation.
- Disabled cells expose unavailability consistently and are skipped by the chosen focus policy.
- Abbreviated weekday headers use `abbr` for their full localized names.
- Every navigable date has a stable `data-date` key and accessible full-date label.

This exact relationship contract is shared by Rails initial rendering, Turbo responses, and any
framework-neutral renderer.

Amended 2026-10-10: the heading that labels the grid sits inside the replaced frame, without
`aria-live`, because a live region inserted by replacement is not announced. A persistent visually
hidden `role="status"` outside the frame receives the new heading text after navigation. Each day
button also carries `data-display` with the server-localized date, so the client never formats
dates. Stable settings (selection, selectability, navigation, D9 constraints) are
`data-calendar-*-value`s on the root; the period shown (`data-displayed`, `data-view`) sits on the
grid so it travels with each replacement. Year and decade cells are links
(`data-calendar-target="period"`) that zoom in; an unavailable one has no `href`.

### D4 — Focus-date initialization is deterministic

On initial connect or dialog open, choose the focus date in this order:

1. selected date when it is displayed and enabled;
2. today when it is displayed and enabled;
3. configured display date when enabled;
4. first enabled date in the displayed period.

"Displayed" means rendered and navigable: adjacent-month dates count only when shown
(amended 2026-10-10).

The controller normalizes malformed server output to one Tab stop, but logs a development warning
because server markup should already satisfy the contract.

Focused date changes do not commit selection. Selection changes only through activation or the
public selection API.

### D5 — Complete month-grid keyboard interaction

When a day button has focus:

| Key                             | Behavior                                                                                      |
| ------------------------------- | --------------------------------------------------------------------------------------------- |
| Arrow Left / Right              | previous/next calendar day                                                                    |
| Arrow Up / Down                 | minus/plus seven days                                                                         |
| Home / End                      | first/last day in the displayed week                                                          |
| Page Up / Page Down             | previous/next month, preserving day number with clamp                                         |
| Shift+Page Up / Shift+Page Down | previous/next year, preserving date with clamp                                                |
| Enter / Space                   | commit focused date                                                                           |

If movement leaves the rendered period, the controller records the intended date and requests
navigation. It prevents default only for handled calendar commands.

Tab exits the grid normally. It does not walk through every day. Escape is not a grid command:
the enclosing calendar field dialog handles Escape; an inline calendar does nothing.

Year and decade views use the same roving-focus principles with geometry matching their visual
column count. Arrow keys move one cell/row, Home/End move to row boundaries, and activation zooms
in without committing a final date.

### D6 — Navigation is a request with a stable intent

The controller dispatches a cancellable event before changing period:

| Event                      | Cancellable | Detail                          |
| -------------------------- | ----------- | ------------------------------- |
| `calendar:before-navigate` | yes         | `{ from, to, focusDate, view }` |
| `calendar:navigate`        | no          | `{ from, to, focusDate, view }` |
| `calendar:navigated`       | no          | `{ from, to, focusDate, view }` |

The controller itself does not assume whether replacement is local or remote.

For Rails, previous/next controls and keyboard navigation target a stable Turbo Frame. The URL is
the current URL plus `<id>[displayed]=YYYY-MM-DD&<id>[view]=…`; the application reads them and
re-renders the same `sp_calendar` call, so selection, locale, and constraints come from the
application, not the URL, and the library adds no route (amended 2026-10-10).

The frame endpoint returns a matching frame. On `turbo:frame-load`, the controller:

1. verifies the loaded period/view;
2. resolves the recorded intended focus date;
3. clamps or selects the closest enabled rendered date when necessary;
4. establishes one Tab stop;
5. focuses it only when navigation originated from a focused grid command;
6. dispatches `calendar:navigated`.

Pointer navigation buttons keep focus on the corresponding navigation control unless the product
explicitly requests focus in the grid.

### D7 — Rails is the canonical dynamic renderer

The Rails package owns the recommended multi-period renderer. Consolidate:

- `Calendar`
- `Calendar::Turbo::DaysOfMonth`
- `Calendar::Turbo::MonthsOfYear`
- `Calendar::Turbo::YearsOfDecade`

behind one renderer contract and shared option normalization.

The JavaScript month/year/decade DOM generators are removed from the default Rails path. The base
JavaScript package enhances any conforming server/static markup and emits navigation requests.
Non-Rails applications provide a renderer or endpoint that returns the documented contract.

No-JavaScript navigation controls are ordinary links targeting navigable Rails routes. Selection
may be rendered as a submit button with a canonical date value where a form fallback is required.

Amended 2026-10-14: `sp_calendar(navigation: :stimulus | :turbo)`, default `:stimulus`.
`:stimulus` renders a label-free template that `calendar` fills and redraws with `Intl`;
`:turbo` keeps the Rails-rendered grid and frame navigation through a `calendar-turbo` adapter.
Both produce one markup contract. The JS package needs no Rails values: `locale` defaults to the
browser and the first day of the week to the locale's week info, then Monday (combobox plan
Phase 7b).

### D8 — Shared conformance fixtures prevent Ruby/JS drift

Keep date-only core fixtures as language-neutral JSON covering:

- month lengths and leap years;
- month/year clamp behavior;
- weekdays and first-day-of-week layouts;
- range boundaries;
- disabled dates/weekdays/months/years;
- selected/today/focus precedence;
- visible and hidden adjacent-month dates;
- locale-independent canonical keys.

JavaScript utility tests and Ruby renderer tests consume the same cases. Rendered DOM contract
tests compare roles, date keys, state attributes, IDs, and exactly-one-tab-stop invariants.

The fixture contract is authoritative; JavaScript timestamps and Ruby `Date` objects are adapters
at package boundaries only.

### D9 — Constraints use canonical date keys

Public constraints:

| Option              | Type             | Meaning                  |
| ------------------- | ---------------- | ------------------------ |
| `min`               | date key or nil  | earliest selectable date |
| `max`               | date key or nil  | latest selectable date   |
| `disabled_dates`    | date keys        | exact unavailable dates  |
| `disabled_weekdays` | integers `0..6`  | unavailable weekdays     |
| `disabled_months`   | integers `1..12` | unavailable months       |
| `disabled_years`    | integers         | unavailable years        |
| `first_day_of_week` | integer `0..6`   | displayed week start     |

Canonical APIs use numeric values rather than localized weekday/month names. Rails helpers may
accept symbols or localized convenience values only if they normalize them server-side before
rendering controller data.

Invalid, contradictory, or reversed constraints raise a Rails argument error during rendering
and produce a clear controller error for manually authored markup.

### D10 — Selection event and form behavior

Selection performs one atomic update:

1. verify the target date exists, is enabled, and is within range;
2. update the selected gridcell;
3. update the hidden canonical form input;
4. update the visible localized display;
5. dispatch `calendar:change`;
6. close the calendar field's dialog when configured.

Events:

| Event                    | Cancellable | Detail                     |
| ------------------------ | ----------- | -------------------------- |
| `calendar:before-change` | yes         | `{ value, previousValue }` |
| `calendar:change`        | no          | `{ value, previousValue }` |

Values are always canonical date keys. Epoch milliseconds are removed from the public event
contract.

Form reset restores the server-authored initial date. Rails validation re-renders both canonical
input value and localized display from the submitted model value.

### D11 — Calendar field composes the modal foundation

Conceptual Rails output:

```html
<div
  data-controller="calendar-field"
  data-action="modal:opened->calendar-field#onOpened calendar:change->calendar-field#onChange"
>
  <label for="birthday_display">Birthday</label>
  <input id="birthday_display" readonly aria-describedby="birthday_format" />
  <span id="birthday_format">Format: day month year</span>
  <input type="hidden" name="person[birthday]" value="2026-09-15" />

  <div data-controller="modal">
    <button type="button" commandfor="birthday_dialog" command="show-modal">Choose date</button>
    <dialog id="birthday_dialog" aria-label="Choose birthday" data-modal-target="dialog">
      <div data-controller="calendar">...</div>
      <button type="button" data-action="modal#dismiss">Cancel</button>
    </dialog>
  </div>
</div>
```

Opening focuses the selected date, otherwise today, otherwise the first enabled date. Selecting a
date updates the field and explicitly completes/closes the dialog. Cancel/Escape closes without
changing the committed value.

The calendar-field controller coordinates field value and dialog result; it does not duplicate the
modal lifecycle or focus trap.

Amended 2026-10-10: "Choose date" is the `sp_modal` trigger slot, not a `calendar-field#open`
action. On `modal:opened` the calendar field focuses the grid's one Tab stop, which Rails rendered
per D4; `autofocus` is not used because Turbo re-applies it on every frame render. Without outlets,
the calendar-field root wires `calendar:change->calendar-field#onChange`, which copies the value into the
hidden input and the activated day's `data-display` into the display field, then completes the
dialog with a native `close(value)`; the Dialog plumber reports it as `modal:closed` with that result
and restores focus.

Amended 2026-10-11: superseded by `sp_combobox_date` (combobox plan Phase 7):

- The input is the trigger (`aria-haspopup="dialog"`, `aria-expanded`, `aria-controls`) and
  opens the popover on focus, except inside an open modal; focus stays in the input, and
  ArrowDown moves it to the grid's Tab stop.
- The panel is a non-modal popover (`role="dialog"`, named "Choose <label>") with no Cancel button;
  Escape and Tab close it without changing the value.
- `input-formatter` renders the display from the hidden date key, so day buttons drop
  `data-display` (D3); `format:` is passed as the formatter's options, with `locale` defaulting
  to `I18n.locale`.

### D12 — Rails API

Inline calendar:

```erb
<%= sp_calendar id: "availability",
                displayed: Date.current,
                selected: @booking.date,
                min: Date.current,
                navigation: :turbo,
                selectable: true %>
```

Date combobox (amended 2026-10-11):

```erb
<%= sp_combobox_date name: "person[birthday]",
                  value: @person.birthday,
                  label: "Birthday",
                  format: { month: "long", day: "numeric", year: "numeric" },
                  min: 120.years.ago.to_date,
                  max: Date.current %>
```

Proposed calendar options:

| Option               | Default        | Notes                             |
| -------------------- | -------------- | --------------------------------- |
| `id:`                | required       | stable frame/grid/heading prefix  |
| `displayed:`         | `Date.current` | displayed period                  |
| `selected:`          | `nil`          | committed value                   |
| `today:`             | `Date.current` | current-date marker/test override |
| `view:`              | `:month`       | `:month`, `:year`, or `:decade`   |
| `navigation:`        | `:stimulus`    | `:stimulus` or `:turbo` (amended) |
| `selectable:`        | `false`        | enables date activation           |
| `show_other_months:` | `false`        | shows adjacent-month dates        |
| constraints          | none           | canonical options from D9         |

The helper derives `first_day_of_week` from explicit configuration or Rails locale configuration,
then emits the resolved integer. Client and server never infer different defaults.

`displayed:` and `view:` come from the URL, so an invalid value falls back to its default instead of
raising; every other option stays strict. `url:` sets the base of the period links when the page was
rendered from a POST (amended 2026-10-10).

### D13 — Hotwire Native uses native date entry by default

For ordinary Hotwire Native forms, render the native Rails `date_field`. It allows the WebView or
Bridge strategy selected by the application to use platform date entry without shipping the
custom calendar interaction.

Applications that require a native Swift/Kotlin date control may add an opt-in Bridge component
with the canonical date-key form contract. The HTML calendar field remains the fallback.

The server does not infer that every native visit should hide the custom calendar. The helper or
application explicitly selects native versus custom behavior so validation and direct visits stay
predictable.

## Tailwind theme

Theme keys cover:

- calendar container, semantic table, rows, headers, and cells;
- day default, hover, focus, today, selected, disabled, and outside-month states;
- month/year heading and navigation controls;
- month/year/decade grid geometry;
- date-field trigger and dialog layout;
- Turbo Frame busy state;
- forced colors, high contrast, reduced motion, touch targets, and 400% zoom.

Focus, today, and selection must remain visually distinct without relying only on color. Grid
layout must tolerate long localized month and weekday labels.

## Accessibility contract

- Exactly one enabled cell control in the active grid is in the Tab sequence.
- Arrow/Home/End/Page navigation follows the documented grid behavior.
- Focus movement never commits selection.
- Selection, today, disabled, and outside-month state are semantically distinct.
- The grid has an accessible name tied to the visible month/year heading.
- Month/year heading changes are politely announced without re-announcing the entire grid.
- Weekday abbreviations expose full localized names.
- The calendar field's dialog has a visible or programmatic accessible name and a visible cancel path.
- Escape cancels the calendar field's dialog without changing its committed value.
- Native date fields remain the recommended mobile-first path.

## Testing

### Date-only core

- Run the same fixtures under at least `UTC`, `Asia/Singapore`, `America/Los_Angeles`, and a DST
  transition zone.
- January 29/30/31 month stepping in leap and non-leap years.
- February 29 year stepping.
- Century leap-year rules.
- Minimum/maximum boundaries and disabled sets.
- Every first-day-of-week value.
- Invalid and partial date keys.

### Controller tests

- Exactly one initial Tab stop for each view.
- Real key events dispatched on focused rendered controls.
- Arrow/Home/End navigation within a period.
- Page navigation and intended-focus restoration.
- Selection versus focus separation.
- Disabled-date skipping and boundary behavior.
- Turbo target replacement, stale navigation, reconnect, and cache cleanup.
- Form reset and Rails validation replacement.

### Browser and assistive-technology tests

Amended 2026-10-10: the full keyboard contract runs as Rails a11y tests; the browser matrix keeps
zoom, touch, reduced motion, native `date_field`, and dialog initial focus. Text direction is out of
scope for now.

Run Chromium, Firefox, and WebKit against generated Rails markup:

- modal open, initial focus, selection, cancel, Escape, and focus restore;
- Turbo month navigation under latency and failed responses;
- localized long labels;
- 400% zoom, forced colors, reduced motion, and touch viewport;
- native `date_field` behavior on supported desktop and mobile environments.

Manual gates cover VoiceOver/Safari, NVDA/Firefox, iOS Safari, and both Hotwire Native platforms.
The WAI-ARIA APG example is guidance, not proof; production acceptance requires the library's own
AT matrix.

## Migration

Deprecated:

- `calendar-month`, `calendar-year`, and `calendar-decade` DOM-generating controllers;
- `calendar-month-selector`, `calendar-year-selector`, and `calendar-decade-selector` as
  click-only adapters;
- `combobox-date`;
- epoch timestamps in selection events;
- localized string values in canonical disabled-date configuration.

Migration requirements:

1. Replace split calendar controllers with `data-controller="calendar"` on conforming rendered
   markup.
2. Replace `calendar-month:selected`/`combobox-date:selected` listeners with `calendar:change`.
3. Consume `detail.value` as `YYYY-MM-DD`, not `detail.epoch` or an ISO instant.
4. Replace custom date combobox helpers with native `date_field` or `sp_calendar_field`.
5. Convert navigation endpoints to return a matching stable Turbo Frame.
6. Convert disabled configuration to canonical date keys and numeric weekday/month values.
7. Remove application assumptions about client-generated calendar DOM.

This is a breaking release. Provide before/after Rails examples for inline, selectable, Turbo-
navigated, and calendar field usage.

## Implementation order

1. Implement the date-only core and cross-timezone fixtures.
2. Consolidate the Rails renderer around the canonical markup contract.
3. Implement the enhancing `calendar_controller` and complete keyboard navigation.
4. Add Turbo navigation and focus-intent restoration.
5. Compose `sp_calendar_field` with the native modal foundation.
6. Add Tailwind states and responsive dialog layout.
7. Complete browser and AT gates.
8. Deprecate split client renderers, selector controllers, and `combobox-date`.

## References

- [WAI-ARIA APG: modal dialog example with a date grid](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/examples/datepicker-dialog/)
- [WAI-ARIA APG: Grid Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/grid/)
- [WAI-ARIA APG: Keyboard Interface](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)
- [Turbo Frames reference](https://turbo.hotwired.dev/reference/frames)
- [Turbo Frames handbook](https://turbo.hotwired.dev/handbook/frames)
