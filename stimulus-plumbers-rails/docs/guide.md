# Guide

## Building forms

Use `StimulusPlumbers::Form::Builder` (set `config.action_view.default_form_builder`, or pass
`builder:` to `form_with`). Two levels:

- **Level 2 — recommended.** Full accessible field (label + input + hint + error):
  `f.field(attr, as:)`, `f.collection_field(attr, as:, collection:, ...)`, `f.choice(attr, as:)`.
  See [docs/component/form.md](component/form.md) for valid `as:` values per builder method and
  which ones are backed by a Stimulus controller (date/time/select/search pickers).
- **Level 1.** Native helper overrides (`f.text_field`, `f.select`, `f.check_box`, ...) render
  only the themed input element — use when you control the surrounding markup.

Submit with `f.submit` (themed button).

## Building views

Render components with `sp_*` helpers (`sp_button`, `sp_button_group`, `sp_card`, `sp_list`,
`sp_link`, `sp_avatar`, `sp_divider`, `sp_icon`, `sp_popover`, ...) — see the
[Components table](../README.md#components) for the full helper list, and each component's
`docs/component/<name>.md` for its keyword options, slots, and themed params.

## Stimulus integration

Most display components are pure markup; interactive ones (combobox, popover, calendar) emit their
`data-controller` attributes automatically — no manual wiring needed in Rails views.
