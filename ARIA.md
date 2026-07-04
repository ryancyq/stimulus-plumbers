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

#### Password Reveal (`password_reveal_controller`)
- Toggle button: `aria-label` describes action ("Show password" / "Hide password")
- Or: `aria-pressed` on toggle button

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
