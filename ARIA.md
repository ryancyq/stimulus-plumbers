# WCAG 2.1 AA / ARIA Reference

## Core Criteria (all components)

| Criterion                  | Level | Rule                                                                                                                                                                                   |
| -------------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.3.1 Info & Relationships | A     | Convey structure via semantic HTML or ARIA roles, not visual styling alone                                                                                                             |
| 1.4.1 Use of Color         | A     | Never use color as the only means to convey information                                                                                                                                |
| 1.4.3 Contrast (text)      | AA    | 4.5:1 normal text, 3:1 large text (18pt / 14pt bold)                                                                                                                                   |
| 1.4.11 Non-text Contrast   | AA    | 3:1 for UI component boundaries and state indicators                                                                                                                                   |
| 2.1.1 Keyboard             | A     | All functionality operable via keyboard; no mouse-only interactions                                                                                                                    |
| 2.1.2 No Keyboard Trap     | A     | Focus must be escapable from any component (Escape or documented key)                                                                                                                  |
| 2.4.3 Focus Order          | A     | Focus sequence must be logical and predictable                                                                                                                                         |
| 2.4.7 Focus Visible        | AA    | Keyboard focus indicator must be visible                                                                                                                                               |
| 4.1.2 Name, Role, Value    | A     | All UI components must have accessible name, role, and state via ARIA or native semantics; state must stay in sync dynamically (e.g. `aria-expanded`, `aria-selected`, `aria-checked`) |
| 4.1.3 Status Messages      | AA    | Status/error messages announced via `role="status"` or `aria-live` without focus move                                                                                                  |

## JS Keyboard Navigation Patterns

`RovingTabIndex` and `ActiveDescendant` handle keyboard navigation in controllers — see [`stimulus-plumbers/docs/accessibility/design.md`](stimulus-plumbers/docs/accessibility/design.md) for full API.

| Pattern           | Class              | When to use                                                                                              |
| ----------------- | ------------------ | -------------------------------------------------------------------------------------------------------- |
| Roving tabindex   | `RovingTabIndex`   | Disclosure widgets, trees, toolbars — focus moves between items                                          |
| Active descendant | `ActiveDescendant` | Listboxes whose owner keeps focus — `aria-activedescendant` and `aria-selected` follow the active option |

## Component-Specific Patterns (APG)

#### Modal (`modal_controller`)

- Use a native `<dialog>` opened with `showModal()`; it supplies modal semantics and background inertness
- Every dialog has an accessible name through `aria-labelledby` or `aria-label`; do not add redundant `aria-modal="true"`
- Initial focus is native; use `autofocus` when intentional placement is required. Focus restoration is native-first, with a narrow adapter fallback only when an engine leaves focus on the document or closed dialog
- Escape and backdrop are dismissal requests governed by `closedby`; explicit completion uses `close()` or `method="dialog"`
- Escape with a popover open inside the dialog closes only the most recently opened popover; the next Escape dismisses the dialog
- Every modal contains a visible close, cancel, or completion control; this is especially important when `closedby="none"` disables implicit dismissal
- Dismissal and explicit completion have different semantics; `modal:before-dismiss` is cancellable and `modal:closed` reports the result
- Do not add generic open/close live announcements; status and validation messages belong in a live region inside the dialog
- Ordinary modal triggers do not use `aria-expanded`

#### Popover (`popover_controller`)

- Native `popover="auto"` supplies the top layer, Escape, and light dismissal
- The consuming component chooses the panel role and accessible name (e.g. `role="region"` + `aria-label`, `role="dialog"`); the helper infers neither
- Author `aria-haspopup`, `aria-expanded`, and `aria-controls` only when the consumer owns that popup relationship; the controller updates an authored `aria-expanded` to the settled state
- The controller does not move focus or announce open/close
- `popover-fetch` marks the loading region `aria-busy="true"`, writes loading and error text to a `role="status"` outside the region, and, when the swap drops focus, moves it to the first focusable element in the new region, else to the panel, which needs `tabindex="-1"`

#### Combobox (`combobox_controller`)

- Trigger: `<button type="button" role="combobox">` (select-only) or `<input role="combobox" aria-autocomplete="list">` (editable) with `aria-expanded` and `aria-controls` referencing the `role="listbox"`
- The trigger and the listbox each have an accessible name (`label:` or `labelledby:`)
- DOM focus stays on the trigger; `aria-activedescendant` references the active option and is absent when none is active
- `aria-selected` follows the active option (APG single-select); the selected value is the hidden input and the trigger's label
- Arrow Down/Up open and move through enabled, visible options; select-only Home/End jump to the ends; editable Space/Home/End stay native
- Enter (and select-only Space) selects the active option; Tab selects it and moves focus natively; Escape closes without selecting; Enter and Escape are ignored while composing
- Typing never activates an option; disabled options use `aria-disabled="true"` and are skipped
- The panel is `popover="manual"`; the combobox closes it on selection, Escape, Tab, and a click or focus outside
- Options carry instance-unique IDs. `role="listbox"` permits only `option`/`group` children (`aria-required-children`, WCAG 1.3.1), so a group is `li[role="none"] > ul[role="group"]` labelled through `aria-labelledby` by a `li[role="none"]` heading
- An option's description is linked with `aria-describedby`, never part of its name (`aria-labelledby` on the label span)
- Status messages (loading, "No results") are non-focusable `role="status"` **siblings of the listbox, never children of it**
- Remote results replace the listbox with one of the same ID and accessible name; the loading frame or listbox carries `aria-busy="true"`

#### Calendar (`sp_calendar`, `calendar`)

- Grid: `<table role="grid">` labelled by the period heading (`aria-labelledby`); weekday `<th scope="col">` carry the full name in `abbr`
- At most one enabled cell control has `tabindex="0"`, and none when no date is available; the rest `-1`
- Selected date: `aria-selected="true"` on the gridcell; today: `aria-current="date"` on the control, independent of selection
- Unavailable dates: `aria-disabled="true"`; a display-only grid is `aria-readonly="true"`; an unavailable selected date keeps `aria-selected="true"`
- Every control has a full-date `aria-label`; the heading sits inside the replaced frame without `aria-live`, and a persistent `role="status"` outside it announces period changes
- Previous/next, previous/next year in the month view, zoom, and month or year cells are buttons in stimulus mode; in Turbo mode they are links that work without JavaScript, and a control with no URL or an unavailable month or year cell is `role="link"` with `aria-disabled="true"` and no `href`
- Keys on a day: Arrow Left/Right ±1 day, Arrow Up/Down ±7 days, Home/End to the first/last day shown in the week, Page Up/Down ±1 month and Shift+Page Up/Down ±1 year (both clamp the day); Enter/Space select; leaving the shown period requests navigation and focus follows the intended date, or the nearest available date in that period
- Keys in the year and decade views: arrows move one cell or one row of four, Home/End to the row's ends; Enter or Space opens the month or year
- A period reached with no available date sends focus to the previous or next control in the direction of travel, to zoom after opening a month or year, or else to the first shown, enabled header control
- Focus never selects; arrows may land on unavailable days, which cannot be selected; Tab leaves the grid; Escape belongs to an enclosing dialog or popover

#### Date combobox (`sp_combobox_date`, `combobox-date`)

- Trigger: read-only `<input role="combobox">` with `aria-haspopup="dialog"`, `aria-expanded`, and `aria-controls` referencing a non-modal popover `role="dialog"` named "Choose <label>" or by the field label; icons are `aria-hidden`
- Focus opens the popover without moving focus, except inside an open modal (a modal moving focus on focus is a change of context); a click on the input or its icons and ArrowDown also open it
- ArrowDown moves focus to the calendar's Tab stop or, with none, to the first shown, enabled header control
- Selecting a date fills the input, closes the popover, and returns focus to the input without reopening it; Escape closes without changing the value; Tab closes it and moves on
- An unavailable value shows as given; the field's error (`aria-invalid`, `aria-describedby`) reports it. Unavailable dates not visible without exploring the grid, such as disabled weekdays or dates, belong in the field's hint (WCAG 3.3.2)

#### Time combobox (`sp_combobox_time`, `combobox-time`)

- Trigger and opening as the date combobox; ArrowDown moves focus to the hour column
- Columns: focusable `role="listbox"` named Hour, Minute, and AM/PM, with `aria-activedescendant` referencing the selected `role="option"` (`aria-selected="true"`); a minute off the step selects no minute option; Tab moves between columns
- Arrow Up/Down move one option, Home/End to the ends, skipping unavailable options; each selection updates the value
- Options outside the available times are `aria-disabled="true"`, judged against the selected AM or PM, then hour; a selected option that a later selection makes unavailable keeps `aria-selected="true"`. The available range belongs in the field's hint (WCAG 3.3.2)
- Enter closes the popover and keeps the value; Tab out of the columns, focus elsewhere, or an outside click closes and keeps it; Escape restores the value from opening, closes the popover, and keeps an enclosing modal open; Enter and Escape return focus to the input
- Columns show a visible focus indicator (WCAG 2.4.7)

#### Date-time combobox (`sp_combobox_datetime`, `combobox-datetime`)

- Trigger and opening as the date combobox; the popover holds the calendar, then the time columns, in Tab order
- ArrowDown moves focus as in the date combobox; selecting a date keeps the popover open, and Tab moves on to the hour column
- The calendar and columns follow their own patterns above; the columns judge times against the selected date
- Escape anywhere in the popover restores the value from opening, closes it, and returns focus to the input; Enter in a column closes it and keeps the value
- The available dates and times belong in the field's hint (WCAG 3.3.2)

#### Form Fields (`form/`, `form-field_controller`)

- Every input must have a visible `<label>` via `for`/`id` or `aria-labelledby`
- Required fields: `required` attribute + `aria-required="true"`
- Invalid fields: `aria-invalid="true"` + `aria-describedby` pointing to error message
- Error message element: `role="alert"` or `aria-live="polite"` so it's announced

#### Password Reveal (`input_revealable_controller`)

- Toggle button: `aria-label` describes action ("Show password" / "Hide password")
- One toggle button swaps visible eye/eye-slash icons and its accessible name; it has no `aria-pressed` because its name describes the next action rather than a persistent state.
- A live announcement was rejected: changing the input between `password` and `text` provides an independent cue when returning focus to the field, without adding chatty feedback.

#### Code Input (`input_formatter_controller` + `character_cells`)

- The real `<input>` is the entire accessible surface; cells are stamped `aria-hidden="true"` automatically.
- The input requires a `<label>` (visually hidden allowed), `autocomplete="one-time-code"` for OTP (WCAG 1.3.5), `inputmode` matching the charset, and `maxlength` matching the code length.
- Overlay the input with `opacity: 0` — never `display: none`/`visibility: hidden`, which remove it from the tab order (WCAG 2.1.1).
- Focus visibility (WCAG 2.4.7): the caret cell (`data-caret`) appears only while the input has focus; style the wrapper with `:focus-within` plus `[data-caret]`.

#### Input Clearable (`input_clearable_controller`)

- Clear button: `hidden` attribute while the input is empty, removing it from the keyboard/AT tab order until there's something to clear
- Escape inside the input clears it (keyboard equivalent to clicking the clear button, WCAG 2.1.1), except while the input is an expanded combobox or another handler took the Escape; default is prevented so it doesn't also close a parent overlay
- Focus returns to the input after clearing (WCAG 2.4.3 Focus Order)
- No `aria-live` announcement — clearing is user-initiated and the button's disappearance is self-explanatory

#### Flipper / Visibility / Dismisser

- Trigger: `aria-expanded="true/false"` when toggling a region
- Controlled region: `aria-hidden="true"` when collapsed (or removed from DOM)
- `aria-controls` links trigger to region id

#### Button (`button/renderer`)

- Use `<button>` (not `<div>` / `<a>`) for actions
- Icon-only buttons must have `aria-label` or visually-hidden text
- Disabled: `disabled` attribute (not `aria-disabled` alone) unless intentionally focusable

#### List (`sp_list`, `sp_list_item`)

- Static list: `role="list"` + `role="listitem"` (explicitly set to preserve semantics when CSS resets strip list role)
- Active item: `aria-current="page"` on `<a>` links; `aria-current="true"` on `<button>` items — the value differs by element type per the ARIA spec

#### Checklist (`checklist_controller`, `sp_checklist`)

- Each item: native `<input type="checkbox">` inside a `<label>` — role, keyboard activation (Space), focus, and checked-state announcement are all handled by the browser. The component sets no ARIA attributes on items.
- Read-only item (`readonly: true`): native `disabled` attribute — removes the control from the tab order and announces it as unavailable to assistive tech. No `aria-readonly`/`tabindex` hack.
- Master "select all" toggle (`select_all:`): same `<input type="checkbox">` shape as an item. Its `indeterminate` property (JS-only, no HTML attribute) is set client-side by the `checklist` controller when some but not all enabled items are checked — modern browsers map `indeterminate` to the accessibility tree's `mixed` checked state automatically, satisfying WCAG 4.1.2 with no manual ARIA.
- Accepted tradeoff: because `indeterminate` has no HTML attribute, the server can only render the master's initial `checked` state for the all-true case; every other case (including mixed) renders unchecked and is corrected to `indeterminate` once the `checklist` controller connects — a brief, accepted flash for the mixed case only.
- Disabled (readonly) items are excluded from the master's aggregate and from bulk toggling — the `checklist` controller filters them out via their own `.disabled` property, mirroring their exclusion from tab order and AT interaction.

#### Progress (`progress_controller`, `sp_progress_*`)

- `role="progressbar"` is read-only and never focusable — it reports a value, it does not accept one. An interactive equivalent is a native `<input type="range">` (or `role="slider"`), not a progressbar with `tabindex`
- Value: `aria-valuemin`/`aria-valuemax` always; `aria-valuenow` omitted while indeterminate (an omitted `valuenow` is what signals "unknown progress" to AT)
- `aria-valuetext` only when the readout text is not derivable from `aria-valuenow` — set for the `value`/`value_max` formats, deliberately **not** for `percent`, where AT already computes the percentage and a duplicate would be announced twice
- On-screen readout is `aria-hidden="true"` — the value reaches AT through `aria-valuenow`/`aria-valuetext`, so exposing the span too would double-announce it
- Name: `aria-label` standalone, or `aria-labelledby` → a visible caption. `<label for>` cannot name a progressbar — `for=` is only valid against a labelable element (`button`, `input`, `meter`, `output`, `progress`, `select`, `textarea`), so a `<div role="progressbar">` targeted by one is silently left unnamed (WCAG 4.1.2). Form fields rendering a progressbar therefore emit a `<span>` caption, not a `<label>`
- No `aria-invalid`/`aria-required` on a progressbar — neither is supported on the role, and it submits nothing that could be invalid. Errors still attach via `aria-describedby`
- Segment slots are decorative (`aria-hidden="true"`) — the value is announced once, by the container
- The `range` variant drives a native `<input type="range">` and writes **no** ARIA: the native control already exposes slider role, value, and keyboard operation, and duplicating them announces worse than leaving them alone. It keeps an ordinary `<label for>` because an `input` is labelable

#### Avatar / Card / Icon

- Decorative images/icons: `aria-hidden="true"` or `alt=""`
- Meaningful images: descriptive `alt` text

#### Timeline (`timeline_controller`)

- List: `<ol>` (ordered) for chronological events; static timelines need no ARIA additions beyond semantic HTML
- Each item: `<li>`; timestamp displayed via `<time datetime="YYYY-MM-DD">`
- Indicators (dots, icons, avatars): decorative — always `aria-hidden="true"`
- Expandable items: trigger `<button>` with `aria-expanded="false/true"` + `aria-controls` → detail element id; detail has `hidden` attribute toggled by controller
- Trigger lives inside `<h3>` (`<h3><button aria-expanded>Title</button></h3>`) — WAI-ARIA Accordion pattern
- Keyboard (interactive): Up/Down arrows move focus between item triggers; Home/End jump to first/last trigger; Enter/Space toggle expansion (native button behaviour)
- No live announcement on expand/collapse — `aria-expanded` on the focused trigger already conveys the change

#### Reorderable (`reorderable_controller`)

- Roving tabindex on `item` targets (`RovingTabIndex`) — plain Arrow/Home/End move focus only, unaffected by editing state
- Keyboard move (`Alt+Arrow` on the axis matching `orientation`, default `ArrowUp`/`ArrowDown`; configurable modifier via `moveKey`; horizontal move-key meaning flips under `dir="rtl"`): moves the focused item, keeps focus on it, announces the new position via `role="status"`/`aria-live` (WCAG 4.1.3) — satisfies the keyboard-equivalent requirement (WCAG 2.1.1) for pointer drag
- Pointer drag: does not move focus or announce — avoids stealing focus from a mouse user who never asked for it
- `editingValue` gates both drag and keyboard-move; while `true`, every `trigger` target (`<a>`/`<button>` inside an item) gets `aria-disabled="true"` + `tabindex="-1"` — removes it from keyboard/AT activation and tab order without touching pointer clicks (apps/themes add their own `pointer-events: none` CSS rule for that half)
