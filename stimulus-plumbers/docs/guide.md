# Guide

For a non-Rails / plain JS consumer of `@stimulus-plumbers/controllers`. Rails apps get this wired
automatically via the `stimulus_plumbers` gem's `sp_*` helpers — skip this guide for Rails.

```bash
npm install @stimulus-plumbers/controllers
```

Import and register each controller you use with your Stimulus application — see
[README.md](../README.md#setup) for the full import + `application.register(...)` list and the
[Controllers table](../README.md#controllers) for identifiers and their docs.

Interactive components (combobox, popover, calendar) expect their `data-controller` attributes to
already be present in the rendered HTML — Rails apps get these from `sp_*` helpers; a plain-JS setup
must add them manually per each controller's doc.
