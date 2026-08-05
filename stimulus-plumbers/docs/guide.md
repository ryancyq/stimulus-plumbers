# Guide

For a non-Rails / plain JS consumer of `@stimulus-plumbers/controllers`. Rails apps get this wired
automatically via the `stimulus_plumbers` gem's `sp_*` helpers — skip this guide for Rails.

## Install

```bash
npm install @hotwired/stimulus @stimulus-plumbers/controllers
```

## Register

Every controller is a named export. Import the ones you use and register each under its identifier:

```javascript
import { Application } from '@hotwired/stimulus';
import { PopoverController, ProgressController, ComboboxDateController } from '@stimulus-plumbers/controllers';

const application = Application.start();

application.register('popover', PopoverController);
application.register('progress', ProgressController);
application.register('combobox-date', ComboboxDateController);
```

The export name is the identifier in PascalCase plus `Controller` — `combobox-date` →
`ComboboxDateController`. For the full identifier list ask `list_controllers` / read
`controller://index`; each one's targets, values, classes, outlets, and events are in
`get_controller_schema(name: identifier)` — `name:` is the identifier (`combobox-date`), not the
export name. Narrative docs come from `get_controller_docs(name: family)`, which takes the family
(`combobox`) rather than the identifier; `list_controller_docs` lists the families. Outside MCP, the
[Controllers table](https://github.com/ryancyq/stimulus-plumbers/blob/main/stimulus-plumbers/README.md#controllers)
lists the same identifiers.

Registering a controller the page never uses is harmless — Stimulus only instantiates on a matching
`data-controller`.

## Wire the markup

Interactive components (combobox, popover, calendar) expect their `data-controller`, target, and
value attributes to already be present in the rendered HTML. Rails apps get these from `sp_*`
helpers; a plain-JS setup writes them by hand, following the HTML structure in each controller's
doc:

```html
<div
  role="progressbar"
  data-controller="progress"
  data-progress-current-value="30"
  data-progress-min-value="0"
  data-progress-max-value="100"
>
  <div data-progress-target="fill"></div>
</div>
```

Markup shape is per-controller — take the authoritative structure from `get_controller_docs(name:)`
rather than adapting this example.

## Styling

Controllers ship no CSS; they toggle classes and attributes only. Bring your own styles, or use the
`stimulus_plumbers_tailwind` gem's token set (`guide://tailwind`).

## Accessibility

Keyboard, focus, and ARIA behaviour per component is in `aria://reference` — read it before
hand-writing markup, since the controllers assume the documented roles and relationships are
present.
