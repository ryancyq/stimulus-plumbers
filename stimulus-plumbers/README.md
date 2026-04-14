# @stimulus-plumbers/controllers

Accessible Stimulus controllers following WCAG 2.1+ standards.

## Installation

```bash
npm install @stimulus-plumbers/controllers
```

Requires `@hotwired/stimulus` ^2.0.0 or ^3.0.0 as a peer dependency.

## Usage

```javascript
import { Application } from '@hotwired/stimulus';
import { ModalController, DatepickerController, CalendarMonthController } from '@stimulus-plumbers/controllers';

const application = Application.start();
application.register('modal', ModalController);
application.register('datepicker', DatepickerController);
application.register('calendar-month', CalendarMonthController);
```

### ModalController

Native `<dialog>` element:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>
  <dialog data-modal-target="modal" aria-labelledby="modal-title">
    <h2 id="modal-title">Title</h2>
    <button data-action="modal#close">Close</button>
  </dialog>
</div>
```

Custom implementation with overlay:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>
  <div data-modal-target="overlay" hidden>
    <div data-modal-target="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title">
      <h2 id="modal-title">Title</h2>
      <button data-action="modal#close">Close</button>
    </div>
  </div>
</div>
```

### DatepickerController

Date picker backed by a calendar grid. Combines `datepicker` + `popover` controllers; uses `CalendarMonthController` as an outlet.

```html
<div data-controller="datepicker popover"
     data-datepicker-calendar-month-outlet="[data-controller~='calendar-month']">
  <input type="text"  data-datepicker-target="display" data-action="focus->popover#show" />
  <input type="hidden" data-datepicker-target="input" />

  <div data-popover-target="content" hidden>
    <button data-datepicker-target="previous">Prev</button>
    <button data-datepicker-target="month"></button>
    <button data-datepicker-target="year"></button>
    <button data-datepicker-target="next">Next</button>

    <div data-controller="calendar-month">
      <div data-calendar-month-target="daysOfWeek"></div>
      <div data-calendar-month-target="daysOfMonth"></div>
    </div>
  </div>
</div>
```

## Other Controllers

- `PopoverController` — show/hide content with optional remote loading
- `DismisserController` — click-outside dismissal
- `FlipperController` — element positioning
- `PannerController` — scroll management

## License

MIT © Ryan Chang
