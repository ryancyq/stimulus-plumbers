# @stimulus-plumbers/controllers

[![Version][npm_badge]][npm]
[![CI][ci_badge]][ci]
[![Coverage][coverage_badge]][coverage]

Accessible Stimulus controllers following WCAG 2.1+ standards.

## Requirements

- Node.js >= 18
- `@hotwired/stimulus` ^2.0 or ^3.0 (peer dependency)

## Installation

```bash
npm install @stimulus-plumbers/controllers
```

## Setup

Register the controllers you need with your Stimulus application:

```javascript
import { Application } from '@hotwired/stimulus'
import {
  InputComboboxController,
  InputFormatterController,
  InputClearableController,
  ComboboxDateController,
  ComboboxTimeController,
  ComboboxDropdownController,
  CalendarMonthController,
  CalendarMonthSelectorController,
  CalendarYearController,
  CalendarYearSelectorController,
  CalendarDecadeController,
  CalendarDecadeSelectorController,
  ModalController,
  PopoverController,
  DismisserController,
  FlipperController,
  ClipboardController,
  PannerController,
} from '@stimulus-plumbers/controllers'

const application = Application.start()

application.register('input-combobox',           InputComboboxController)
application.register('input-formatter',          InputFormatterController)
application.register('input-clearable',          InputClearableController)
application.register('combobox-date',            ComboboxDateController)
application.register('combobox-time',            ComboboxTimeController)
application.register('combobox-dropdown',        ComboboxDropdownController)
application.register('calendar-month',            CalendarMonthController)
application.register('calendar-month-selector',   CalendarMonthSelectorController)
application.register('calendar-year',             CalendarYearController)
application.register('calendar-year-selector',    CalendarYearSelectorController)
application.register('calendar-decade',           CalendarDecadeController)
application.register('calendar-decade-selector',  CalendarDecadeSelectorController)
application.register('modal',                    ModalController)
application.register('popover',                  PopoverController)
application.register('dismisser',                DismisserController)
application.register('flipper',                  FlipperController)
application.register('clipboard',                ClipboardController)
application.register('panner',                   PannerController)
```

## Controllers

| Controller | Description | Docs |
|-----------|-------------|------|
| `input-combobox` | Wrapper: trigger, popover, hidden value | [docs/component/combobox.md](docs/component/combobox.md#input-combobox) |
| `input-formatter` | Formats and displays values | [docs/component/combobox.md](docs/component/combobox.md#input-formatter) |
| `input-clearable` | Input with clear button | [docs/component/input-clearable.md](docs/component/input-clearable.md) |
| `combobox-date` | Calendar grid date picker | [docs/component/combobox.md](docs/component/combobox.md#combobox-date) |
| `combobox-time` | Drum/scroll-wheel time picker | [docs/component/combobox.md](docs/component/combobox.md#combobox-time) |
| `combobox-dropdown` | Listbox with fuzzy filter or server fetch | [docs/component/combobox.md](docs/component/combobox.md#combobox-dropdown) |
| `calendar-month` | Calendar month grid — renders days, handles clicks, dispatches selection events | [docs/component/calendar.md](docs/component/calendar.md) |
| `calendar-month-selector` | SSR/Turbo thin selector for server-rendered month grids | [docs/component/calendar.md](docs/component/calendar.md#calendar-month-selector) |
| `calendar-year` | Calendar year grid — renders month buttons, dispatches selection events | [docs/component/calendar.md](docs/component/calendar.md#calendar-year) |
| `calendar-year-selector` | SSR/Turbo thin selector for server-rendered year grids | [docs/component/calendar.md](docs/component/calendar.md#calendar-year-selector) |
| `calendar-decade` | Calendar decade grid — renders year buttons, dispatches selection events | [docs/component/calendar.md](docs/component/calendar.md#calendar-decade) |
| `calendar-decade-selector` | SSR/Turbo thin selector for server-rendered decade grids | [docs/component/calendar.md](docs/component/calendar.md#calendar-decade-selector) |
| `modal` | Native `<dialog>` or custom overlay | [docs/component/modal.md](docs/component/modal.md) |
| `popover` | Show/hide content with optional remote load | [docs/component/popover.md](docs/component/popover.md) |
| `dismisser` | Click-outside dismissal | [docs/component/dismisser.md](docs/component/dismisser.md) |
| `flipper` | Floating element positioning | [docs/component/flipper.md](docs/component/flipper.md) |
| `clipboard` | Copy-to-clipboard and paste interception | [docs/component/clipboard.md](docs/component/clipboard.md) |
| `panner` | Keeps content element within viewport on resize | [docs/component/panner.md](docs/component/panner.md) |
| `timeline` | Manages expandable timeline event items with keyboard navigation | — |

## Utilities

| Export | Description | Docs |
|--------|-------------|------|
| `announce`, `generateId`, `ensureId`, `connectTriggerToTarget` | ARIA state helpers | [docs/utility/accessibility.md](docs/utility/accessibility.md#srca11yariajs) |
| `FocusTrap`, `FocusRestoration`, `focusFirst` | Focus management | [docs/utility/accessibility.md](docs/utility/accessibility.md#srca11yfocusjs) |
| `isActivationKey`, `isArrowKey`, `RovingTabIndex` | Keyboard interaction | [docs/utility/accessibility.md](docs/utility/accessibility.md#srca11ykeyboardjs) |
| `Requestor` | Fetch wrapper with lifecycle events | [docs/utility/requestor.md](docs/utility/requestor.md) |
| `fuzzyMatcher`, `filterOptions` | Option filtering for comboboxes | [docs/utility/researcher.md](docs/utility/researcher.md) |

## Method naming convention

Controllers follow a consistent naming pattern:

| Pattern | Parameter | Role | Example |
|---------|-----------|------|---------|
| `x(value)` | raw value | Programmatic API — pure logic, callable directly | `select('us')`, `format('4242…')`, `step(1)`, `filter('query')` |
| `onX(event)` | DOM event | Event adapter — extracts payload, calls programmatic API | `onSelect(event)`, `onChange(event)`, `onPaste(event)`, `onInput(event)`, `onNavigate(event)` |
| `past()` | — | Plumber callback — called by plumber after async operation completes | `shown()`, `dismissed()`, `flipped()`, `contentLoaded()` |

Wire event adapters via `data-action`; call programmatic APIs directly from other controllers or outlets.

## Development

```bash
npm install

npm test              # run all tests (Vitest)
npm run test:ui       # Vitest UI
npm run test:coverage # coverage report
npm run lint          # ESLint
npm run format:write  # Prettier (write)
npm run build         # build dist/
```

## License

MIT © Ryan Chang

[npm_badge]: https://img.shields.io/npm/v/@stimulus-plumbers/controllers.svg
[npm]: https://www.npmjs.com/package/@stimulus-plumbers/controllers
[ci_badge]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-stimulus.yml/badge.svg
[ci]: https://github.com/ryancyq/stimulus-plumbers/actions/workflows/ci-stimulus.yml
[coverage_badge]: https://codecov.io/gh/ryancyq/stimulus-plumbers/graph/badge.svg?token=Z77H6M5GER&flag=javascript
[coverage]: https://codecov.io/gh/ryancyq/stimulus-plumbers
