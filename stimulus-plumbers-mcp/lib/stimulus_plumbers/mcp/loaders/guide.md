# stimulus-plumbers — overview

Accessible Rails view components plus a themed form builder, backed by Stimulus controllers.
Start here, then drill into the per-package guides and per-component resources/tools below.

## Per-package guides
- `guide://component` — building forms (`f.field`/`f.collection_field`/`f.choice`) and views
  (`sp_*` helpers) with the Rails gem
- `guide://controller` — plain-JS / non-Rails setup for `@stimulus-plumbers/controllers`
- `guide://tailwind` — Tailwind theme install + icons
- `guide://theme` — implementing a custom theme (subclassing `Themes::Base`)

Tools: `list_guides`, `get_guide(name:)`.

## Building forms and views
Valid `as:` values: `get_field_as_values(builder_method:)`. Combobox-backed `as:` values' controller
identifier: `get_field_as_controller(as:)` — `component://{name}/schema` keys are renderer-level, not
`as:` values. Component helper surface: `get_component_helper(name)`; themed params:
`get_component_schema(name)`; ERB examples: `get_component_examples(name)`. List everything with
`list_components`; `list_component_docs` shows which components have full docs
(`component://{name}/docs`) and helper signatures (`component://{name}/helper`). Icon options take a
name from `component://icons` (or `list_icons`). All schema components are queryable via
`get_component_schema`; only a subset have full docs and ERB examples — use `list_component_docs` to
see what's covered. Full form builder reference: `component://form/docs`.

## Stimulus integration
Most display components are pure markup; interactive ones (combobox, popover, calendar) emit their
`data-controller` attributes automatically. Component → required controllers: `component://integration`.
Controller identifiers and details (targets/values/outlets/classes): `controller://index`,
`get_controller_schema(id)` / `list_controllers`.
Narrative docs by controller family: `get_controller_docs(name)` / `controller://docs/{name}`.

## How this server is organized
- **Resources** live under entity namespaces — `component://` (Rails `sp_*` helper surface: schema,
  docs, helper, theme, tailwind, icons facets), `controller://` (plain-JS Stimulus surface: schema,
  docs facets), `guide://` (per-package usage guides) — plus `aria://reference` and `versions://sources`.
  **Tools** (`get_*`, `list_*`) expose the same data for targeted lookups. Use whichever your client prefers.
- `aria://reference` — WCAG 2.1 AA criteria and component ARIA patterns. For generic ARIA/WCAG reference,
  connect the MDN MCP server too: `claude mcp add --transport http mdn https://mcp.mdn.mozilla.net/`
- Each source (schema, docs, theme, tailwind, icons, stimulus, stimulus_docs, guide) is read from an
  independently-versioned gem/npm package — `versions://sources` / `get_source_versions` reports what's
  actually resolved, useful if data looks stale or inconsistent with the app code you're generating for.
  `icons` versions with the Tailwind theme gem, not the schema gem, since the bundled icon set is
  Tailwind-specific.
- **View generation** uses the form builder + `sp_` helper tools/resources above. The `component://theme`
  and `component://tailwind` facets are for *theme authors* implementing a custom theme — skip them when
  generating views.
- **Errors are uniform:** a not-found tool/resource returns `{ "error": "..." }` (tools also set `isError`).
