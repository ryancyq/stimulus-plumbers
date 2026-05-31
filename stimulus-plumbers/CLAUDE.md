# Stimulus Plumbers

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── accessibility/               # ARIA, focus, keyboard utilities
│   │   ├── aria.js
│   │   ├── focus.js
│   │   └── keyboard.js
│   ├── controllers/                 # Stimulus controllers
│   │   ├── *_controller.js
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── index.js
│   │   │   └── support.js
│   │   └── *.js
│   ├── index.js                     # Main entry point
│   ├── requestor.js                 # HTTP request helper
│   └── researcher.js                # Fuzzy match / filter helper
├── tests/
│   ├── unit/
│   │   ├── controllers/
│   │   │   └── *.test.js
│   │   └── plumbers/
│   │       ├── plumber/
│   │       │   └── *.test.js
│   │       └── *.test.js
│   └── setup.js
├── eslint.config.js
├── package.json
├── vite.config.js
├── .prettierrc.json
├── .gitignore
└── README.md
```

> See [README.md](README.md) for installation, controller usage examples, and developer setup.

## Guidelines
- **native HTML5 first** - only use controllers when native elements have limitations
- import statements should not end with .js
- **Unit tests** using Vitest
- **Lint tests** (eslint)

## Controller / Plumber Design Principles

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Ensure examples provided are tested.

## Controller Inventory

| Controller file | Registered name | Notes |
|---|---|---|
| `calendar_month_controller.js` | `calendar-month` | Calendar grid; driven by Calendar plumber |
| `calendar_month_observer_controller.js` | `calendar-month-observer` | Click-to-select companion |
| `clipboard_controller.js` | `clipboard` | Copy-to-clipboard + paste intercept |
| `combobox_date_controller.js` | `combobox-date` | Calendar-backed date picker; stacked with `popover` + `input-formatter` |
| `combobox_dropdown_controller.js` | `combobox-dropdown` | Listbox; fuzzy filter or server fetch; stacked with `popover` + `input-formatter` |
| `combobox_time_controller.js` | `combobox-time` | Drum/scroll-wheel time picker; stacked with `popover` + `input-formatter` |
| `dismisser_controller.js` | `dismisser` | Click-outside dismissal |
| `flipper_controller.js` | `flipper` | Floating element positioning (Flipper plumber) |
| `input_clearable_controller.js` | `input-clearable` | Input + clear button |
| `input_combobox_controller.js` | `input-combobox` | Value + filtering; always stacked with `popover` (owns visibility) and `input-formatter` |
| `input_formatter_controller.js` | `input-formatter` | Value formatter (date, time, password, credit card) |
| `modal_controller.js` | `modal` | Native `<dialog>` or custom overlay |
| `panner_controller.js` | `panner` | Draggable/pannable content |
| `popover_controller.js` | `popover` | Show/hide content with optional remote load |
| `visibility_controller.js` | `visibility` | Generic show/hide |

## Plumber Inventory (`src/plumbers/`)

Plumbers are factory functions that attach reusable behaviors to a controller instance:

| File | Factory function | Exposes on controller |
|---|---|---|
| `visibility.js` | `attachVisibility(ctrl, opts)` | `this.visibility` (show/hide + `aria-expanded` sync) |
| `content_loader.js` | `attachContentLoader(ctrl, opts)` | `this.load()` |
| `flipper.js` | `attachFlipper(ctrl, opts)` | `this.flip()` |
| `calendar.js` | `attachCalendar(ctrl, opts)` | `this.calendar` |
| `dismisser.js` | `attachDismisser(ctrl, opts)` | `this.dismisser` |
| `formatter.js` | `attachFormatter(ctrl, opts)` | `this.formatter` |
| `shifter.js` | `attachShifter(ctrl, opts)` | `this.shifter` |

See `docs/plumber/*.md` for options and lifecycle callbacks.

## Method Naming Convention

| Pattern | Wired via | Role |
|---|---|---|
| `onX(event)` | `data-action` | Event adapter — extracts payload from DOM event, calls programmatic API |
| `x(value)` | called directly | Programmatic API — pure logic, no event awareness |
| `past()` | plumber callback | Called by a plumber after an async operation (e.g. `shown()`, `dismissed()`, `contentLoaded()`) |

Wire event adapters via `data-action`. Call programmatic APIs from other controllers or outlets.

## Testing Details

- **Framework**: Vitest, running in jsdom environment
- **Run**: `npm test` (all); `npm run test:ui` (Vitest UI); `npm run test:coverage`
- `axe-core` is available as a dev dependency — use it in unit tests for accessibility assertions
- Test files: `tests/unit/controllers/` and `tests/unit/plumbers/`
- `tests/setup.js` provides shared test utilities

## Import Rules

- Never end import paths with `.js` (ESM resolution handles it)
- All public exports are re-exported from `src/index.js`
- Import from `'@stimulus-plumbers/controllers'` in consumer code; use relative paths inside the package
