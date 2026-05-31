# Stimulus Plumbers

## Project Overview

A library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/         # npm: @stimulus-plumbers/controllers
├── src/                   # core library
├── tests/                 # test cases
├── */
├── package.json           # package manager
├── CLAUDE.md
└── README.md
stimulus-plumbers-rails/   # Ruby gem: stimulus-plumbers
├── lib/                   # core library
├── test/                  # test cases (unit, accessibility)
├── */
├── Gemfile                # package manager
├── CLAUDE.md
└── README.md
stimulus-plumbers-tailwind/ # Ruby gem: stimulus_plumbers_tailwind
├── lib/                   # theme library
├── test/                  # test cases (unit, snapshots)
├── */
├── Gemfile                # package manager
├── package.json           # Tailwind CLI + Playwright
├── CLAUDE.md
└── README.md
stimulus-plumbers-react/   # npm: @stimulus-plumbers/react
├── */
├── package.json
├── CLAUDE.md
└── README.md
```

## Design Principle
- Follow WCAG 2.1 Level AA standards and work with screen readers

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
- Keep docs concise — match the style of existing entries (one-line bullets, minimal prose).

## Testing Guideline
- **Keyboard navigation tests** (Tab, Enter, Space, Escape, Arrows)
- **Focus management tests** (focus traps, restoration)
- **ARIA attribute tests** (roles, labels, states)
- **Visual snapshot tests** using Playwright (`npm run test:snapshots` in `stimulus-plumbers-tailwind/`)
- read html output from test output first during a11y violation analysis

## WCAG 2.1 AA Quick Reference

### Core Criteria (all components)

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

### Component-Specific Patterns (APG)

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

#### Calendar / Date Picker (`calendar_month_controller`, `date_picker/`)
- Grid: `role="grid"`, `role="row"`, `role="gridcell"`
- Navigation buttons: `aria-label="Previous month"` / `"Next month"`
- Selected date: `aria-selected="true"`; today: `aria-current="date"`
- Disabled dates: `aria-disabled="true"`, `tabindex="-1"`
- Arrow keys navigate cells; Enter/Space select; Escape closes picker

#### Action List (`action_list/`)
- Static list: `role="list"` + `role="listitem"`
- Interactive menu: `role="menu"` + `role="menuitem"`; Arrow keys navigate; Enter activates
- Selected item: `aria-selected` (listbox) or `aria-checked` (menuitemcheckbox)

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

#### Avatar / Card / Icon
- Decorative images/icons: `aria-hidden="true"` or `alt=""`
- Meaningful images: descriptive `alt` text
