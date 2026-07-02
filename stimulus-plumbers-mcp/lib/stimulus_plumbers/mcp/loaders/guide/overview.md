# stimulus-plumbers — overview

Accessible Rails view components plus a themed form builder, backed by Stimulus controllers.
Start here, then drill into the per-component resources/tools below.

## Tailwind theme setup
The `stimulus_plumbers_tailwind` gem provides themed CSS classes for all components. After adding it to
your Gemfile, run the install generator once:
  bin/rails generate stimulus_plumbers:tailwind:install
This injects an `@source` directive into your Tailwind CSS entry file so component classes are included
in the compiled output. The generator checks `app/assets/stylesheets/application.tailwind.css`,
`app/assets/stylesheets/application.css`, and `app/javascript/entrypoints/application.css` in that
order. Override with `TAILWIND_CSS_FILE=/path/to/entry.css`. The path updates automatically on
`assets:precompile` and `tailwindcss:build` — no re-run needed after `bundle update`.

## Building forms
Use `StimulusPlumbers::Form::Builder` (set `config.action_view.default_form_builder`, or pass
`builder:` to `form_with`). Two levels:
- **Level 2 — recommended.** Full accessible field (label + input + hint + error):
  `f.field(attr, as:)`, `f.collection_field(attr, as:, collection:, ...)`, `f.choice(attr, as:)`.
  Valid `as:` values come from `get_field_types` (pass `builder_method: "field"`, `"collection_field"`, or `"choice"`).
- **Level 1.** Native helper overrides (`f.text_field`, `f.select`, `f.check_box`, ...) render
  only the themed input element — use when you control the surrounding markup.
Submit with `f.submit` (themed button). Full form reference + examples: read `docs://components/form`.

## Building views
Render components with `sp_*` helpers (`sp_button`, `sp_button_group`, `sp_card`, `sp_list`,
`sp_link`, `sp_avatar`, `sp_divider`, `sp_icon`, `sp_popover`). For any component:
- `get_helper_signature(name)` — full helper surface: keyword options (incl. `icon_leading`) + slot methods
- `get_component_schema(name)` — themed params (type/variant/size) with valid values + defaults
- `get_erb_examples(name)` — runnable ERB snippets
List everything with `list_components`; `list_docs` shows which components have full docs
(`docs://components/{name}`) and helper signatures (`helper://components/{name}`).
Icon options take a name from `schema://icons`.
All 77 schema components are queryable via `get_component_schema`; only a subset have full docs and ERB examples — use `list_docs` to see what's covered.

## JavaScript package setup
`@stimulus-plumbers/controllers` (npm) ships the Stimulus controllers; Rails apps get it wired
automatically via the `sp_*` helpers and `stimulus_plumbers` gem — skip this section for Rails.
For a non-Rails / plain JS consumer: `npm install @stimulus-plumbers/controllers`, then import and
`application.register(identifier, ControllerClass)` for each controller you use — see the npm
package README for the full import list and identifiers. Controller identifiers and their
targets/values/outlets: `stimulus://controllers`, `get_controller_schema(id)`.

## Stimulus wiring
Most display components are pure markup; interactive ones (combobox, popover, calendar) emit their
`data-controller` wiring automatically. Component → required controllers: `schema://stimulus`.
Controller details (targets/values/outlets/classes): `get_controller_schema(id)` / `list_controllers`.

## How this server is organized
- **Resources** (`schema://`, `docs://`, `helper://`, `theme://`, `tailwind://`, `guide://`,
  `versions://`) are for browsing/pulling context; **tools** (`get_*`, `list_*`) are for targeted
  lookups. They expose the same data two ways — use whichever your client prefers.
- Each source (schema, docs, theme, tailwind, stimulus) is read from an independently-versioned
  gem/npm package — `versions://sources` / `get_source_versions` reports what's actually resolved,
  useful if data looks stale or inconsistent with the app code you're generating for.
- **View generation** uses the form builder + `sp_` helper tools/resources above. The `theme://` and
  `tailwind://` surfaces are for *theme authors* implementing a custom theme — skip them when generating views.
- **Errors are uniform:** a not-found tool/resource returns `{ "error": "..." }` (tools also set `isError`).
