# WCAG 2.1 AA / ARIA Reference

## Core Criteria (all components)

| Criterion | Level | Rule |
|-----------|-------|------|
| 1.3.1 Info & Relationships | A | Convey structure via semantic HTML or ARIA roles, not visual styling alone |
| 1.4.1 Use of Color | A | Never use color as the only means to convey information |
| 1.4.3 Contrast (text) | AA | 4.5:1 normal text, 3:1 large text (18pt / 14pt bold) |
| 1.4.11 Non-text Contrast | AA | 3:1 for UI component boundaries and state indicators |
| 2.1.1 Keyboard | A | All functionality operable via keyboard; no mouse-only interactions |
| 2.1.2 No Keyboard Trap | A | Focus must be escapable from any component (Escape or documented key) |
| 2.4.3 Focus Order | A | Focus sequence must be logical and predictable |
| 2.4.7 Focus Visible | AA | Keyboard focus indicator must be visible |
| 4.1.2 Name, Role, Value | A | All UI components must have accessible name, role, and state via ARIA or native semantics; state must stay in sync dynamically (e.g. `aria-expanded`, `aria-selected`, `aria-checked`) |
| 4.1.3 Status Messages | AA | Status/error messages announced via `role="status"` or `aria-live` without focus move |

## JS Keyboard Navigation Patterns

Two helper classes handle keyboard navigation in controllers — see [`stimulus-plumbers/docs/accessibility/design.md`](stimulus-plumbers/docs/accessibility/design.md) for full API.

| Pattern | Class | When to use |
| --- | --- | --- |
| Roving tabindex | `RovingTabIndex` | Disclosure widgets, trees, toolbars — focus moves between items |
| Managed focus / listbox | `ListboxNavigation` | Combobox listbox, `role="listbox"` — input keeps focus, `aria-selected` moves |

## Component-Specific Patterns (APG)

#### Modal (`modal_controller`)
- `role="dialog"`, `aria-modal="true"`, `aria-labelledby` pointing to heading
- Focus moves into dialog on open; returns to trigger on close
- Focus trapped inside — Tab/Shift+Tab cycle within; Escape closes
- Status announcements ("Modal opened"/"Modal closed") via `aria-live` on open/close (WCAG 4.1.3)

#### Popover (`popover_controller`)
- `role="dialog"` or `role="tooltip"` depending on interactivity
- Trigger: `<button>` with `aria-haspopup="dialog"` and `aria-expanded="false"` initially
- `aria-expanded` toggled to `"true"` / `"false"` by the controller via the `trigger` Stimulus target
- `aria-controls` linking trigger to panel id is recommended but optional
- Escape closes and returns focus to trigger

#### Combobox (`input_combobox_controller`, `combobox/`)
- Trigger: `<input role="combobox">` with `aria-haspopup` (`listbox`/`dialog`) and `aria-controls` referencing the **popup element** (the `role="listbox"`/`role="dialog"`)
- `role="listbox"` permits only `option`/`group` children (`aria-required-children`, WCAG 1.3.1). Status messages (loading, "No results") must be `role="status"`/`aria-live` **siblings of the listbox, never children of it** — for typeahead the listbox is nested in a wrapper panel so the status regions can sit beside it
- Status/loading regions inside the popover panel must stay **non-focusable** (the popover moves focus into the panel on open)

#### Calendar / Date Picker (`calendar-month`, `combobox-date`)
- Grid: `role="grid"`, `role="row"`, `role="gridcell"`
- Navigation buttons: `aria-label="Previous Month"` / `"Next Month"` (via `Combobox::Date::Navigation`)
- Selected date: `aria-selected="true"`; today: `aria-current="date"`
- Disabled dates: `aria-disabled="true"`, `tabindex="-1"`
- Three views: month (days grid), year (months grid), decade (years grid); zoom out via `combobox-date#zoomOut`
- Arrow keys navigate cells; Enter/Space select; Escape closes picker

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
- Escape inside the input clears it (keyboard equivalent to clicking the clear button, WCAG 2.1.1); default is prevented so it doesn't also close a parent overlay
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

#### Reorderable (`reorderable_controller`)
- Roving tabindex on `item` targets (`RovingTabIndex`) — plain Arrow/Home/End move focus only, unaffected by editing state
- Keyboard move (`Alt+Arrow` on the axis matching `orientation`, default `ArrowUp`/`ArrowDown`; configurable modifier via `moveKey`; horizontal move-key meaning flips under `dir="rtl"`): moves the focused item, keeps focus on it, announces the new position via `role="status"`/`aria-live` (WCAG 4.1.3) — satisfies the keyboard-equivalent requirement (WCAG 2.1.1) for pointer drag
- Pointer drag: does not move focus or announce — avoids stealing focus from a mouse user who never asked for it
- `editingValue` gates both drag and keyboard-move; while `true`, every `trigger` target (`<a>`/`<button>` inside an item) gets `aria-disabled="true"` + `tabindex="-1"` — removes it from keyboard/AT activation and tab order without touching pointer clicks (apps/themes add their own `pointer-events: none` CSS rule for that half)
