# Guide

## Quickstart

Requires Ruby >= 3.0 and Rails >= 6.1.

1. Add the gem and install:

   ```ruby
   # Gemfile
   gem "stimulus_plumbers"
   ```

   ```bash
   bundle install
   ```

2. Run the install generator — it copies `tokens.css` into your app and injects the import into your
   CSS entry file (see [CSS entry file detection](#css-entry-file-detection)):

   ```bash
   bin/rails generate stimulus_plumbers:install
   ```

3. Register the Stimulus controllers that back the interactive components. The gem renders the
   `data-controller` attributes; the JS package supplies the controllers themselves:

   ```bash
   npm install @stimulus-plumbers/controllers
   ```

   Register them as `guide://controller` describes — identifiers must match what the helpers emit.

4. Make the form builder the default (or pass `builder:` per `form_with`):

   ```ruby
   # config/application.rb
   config.action_view.default_form_builder = StimulusPlumbers::Form::Builder
   ```

5. Render a first form:

   ```erb
   <%= form_with model: @user do |f| %>
     <%= f.field :email, as: :email, hint: "We never share it" %>
     <%= f.field :password, as: :password, revealable: true %>
     <%= f.field :country, as: :select, choices: ["Australia", "Canada"] %>
     <%= f.submit "Create account" %>
   <% end %>
   ```

   Each `f.field` renders the label, input, hint, and error with their ARIA wiring already
   associated — no `label`/`aria-describedby` by hand.

For view components outside a form, include the helper modules you use in `ApplicationHelper` (see
the gem's
[README](https://github.com/ryancyq/stimulus-plumbers/blob/main/stimulus-plumbers-rails/README.md#installation))
and call the `sp_*` helpers described under [Building views](#building-views).

## Building forms

Use `StimulusPlumbers::Form::Builder` (set `config.action_view.default_form_builder`, or pass
`builder:` to `form_with`). Two levels:

- **Level 2 — recommended.** Full accessible field (label + input + hint + error):
  `f.field(attr, as:)`, `f.collection_field(attr, as:, collection:, ...)`, `f.choice(attr, as:)`.
  See `component://form/docs` ([form.md](https://github.com/ryancyq/stimulus-plumbers/blob/main/stimulus-plumbers-rails/docs/component/form.md))
  for valid `as:` values per builder method and
  which ones are backed by a Stimulus controller (date/time/select/search pickers).
- **Level 1.** Native helper overrides (`f.text_field`, `f.select`, `f.check_box`, ...) render
  only the themed input element — use when you control the surrounding markup.

Submit with `f.submit` (themed button; supports `icon_leading:`/`icon_trailing:` and
`hide_label:` for an icon-only button — see `component://form/docs`).

## Building views

Render components with `sp_*` helpers (`sp_button`, `sp_button_group`, `sp_card`, `sp_list`,
`sp_link`, `sp_avatar`, `sp_divider`, `sp_icon`, `sp_popover`, ...) — see the
[Components table](https://github.com/ryancyq/stimulus-plumbers/blob/main/stimulus-plumbers-rails/README.md#components)
for the full helper list (`list_components` / `list_component_docs` over MCP), and each component's
`component://{name}/docs` for its keyword options, slots, and themed params.

## Stimulus integration

Most display components are pure markup; interactive ones (combobox, popover, calendar) emit their
`data-controller` attributes automatically — no manual wiring needed in Rails views.

## CSS entry file detection

`bin/rails generate stimulus_plumbers:install` (and `stimulus_plumbers_tailwind`'s own install
generator) inject their CSS directives into the first entry file found, in order:

1. `app/assets/stylesheets/application.tailwind.css` (`tailwindcss-rails` 2.x default)
2. `app/assets/tailwind/application.css` (`tailwindcss-rails` 3.x+ default)
3. `app/assets/stylesheets/application.css` (Rails/Propshaft default manifest)
4. `app/javascript/entrypoints/application.css` (`jsbundling-rails` esbuild/webpack default)

Override with `STIMULUS_PLUMBERS_CSS_ENTRY=/path/to/entry.css` — used by both gems' generators.

## Installed CSS files

The core installer copies its token defaults to
`app/assets/stylesheets/stimulus_plumbers/tokens.css` and imports that app-local file.

This file is application-owned: later generator runs create a missing file but never overwrite an
existing one. They also replace legacy imports that pointed into an installed gem with the new
relative app-local import.
