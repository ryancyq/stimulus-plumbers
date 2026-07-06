# MCP Server Architecture

## Loader Naming

A loader assigned to a plugin's `.loader` is named `<Plugin><Loader>` — e.g. the `ComponentSchema`
plugin's loader is `ComponentSchemaLoader`, `ControllerDocs`' is `ControllerDocsLoader`, `ComponentTheme`'s
is `ComponentThemeLoader`. `GuideLoader` and `AriaLoader` already match their bare plugin names exactly,
so they're unchanged.

Not every class in `loaders/` is a plugin's `.loader`: `ComponentRequirements` (invoked by
`ComponentSchemaLoader`, not a plugin itself) and `loaders/support/`'s `DocsTableParser`/`GemVendorPath`
(pure parsing/path-resolution helpers, not sources) sit outside this naming rule — they don't get a
`Loader` suffix because they aren't one.

## Store Shapes

Each loader puts a typed value in `store[loader_key]`:

| Loader                    | Key                                    | Shape                                                                                                                                                                                                                  |
| ------------------------- | -------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ComponentDocsLoader`     | `:component_docs`                      | `{ name => { content:, examples:, signature: } }`                                                                                                                                                                      |
| `ComponentSchemaLoader`   | `:component_schema`                    | `{ components:, field_as:, field_as_controllers:, controllers: }`                                                                                                                                                      |
| `ComponentThemeLoader`    | `:component_theme`                     | `{ base_doc:, components: }` — `base_doc` reads `docs/component/theme.md`, same file `ComponentDocsLoader` also serves at `component://theme/docs`                                                                     |
| `ControllerDocsLoader`    | `:controller_docs`                     | `{ name => markdown String }`                                                                                                                                                                                          |
| `ControllerSchemaLoader`  | `:controller_schema`                   | parsed JSON hash (or `{}` if artifact absent) — each identifier's entry also gets a merged-in `wiring: { actions:, listens:, targets:, values: }` sourced from `ComponentManifestLoader`, defaulting to empty arrays   |
| `ComponentManifestLoader` | n/a (merged into `:controller_schema`) | `{ identifier => { actions:, listens:, targets:, values: } }` — merged into `ControllerSchemaLoader`'s output under each identifier's `wiring` key, not a standalone store entry                                       |
| `IconsLoader`             | `:icons`                               | `Array` of icon name strings                                                                                                                                                                                           |
| `TailwindLoader`          | `:tailwind`                            | `{ component_key => { default: String, "param:value" => classes } }`                                                                                                                                                   |
| `AriaLoader`              | `:aria`                                | `String` (ARIA reference markdown)                                                                                                                                                                                     |
| `GuideLoader`             | `:guide`                               | `{ overview:, component:, controller:, tailwind:, theme: }` — each a markdown `String` read from its own package's `docs/guide.md` (or `docs/component/theme.md` for `theme`); only `overview` is MCP-authored         |
| `VersionsLoader`          | `:versions`                            | `{ source_key => { version:, resolved_from: } }` — `resolved_from` is only present for npm-backed sources (`controller_schema`/`controller_docs`/`controller_guide`); plain gem-backed sources are just `{ version: }` |

## Plugin Class Contract

Each plugin subclasses `Plugins::Base`. Required members raise `NotImplementedError` naming the
offending plugin if left undefined; optional members inherit a working default:

```ruby
class << self
  def loader_key           # required — Symbol key into the shared store
  def loader                # required — Callable, single .call returns the store value
  def read(uri, store)      # required — content for a matching URI, or nil

  def static_resources            # optional — defaults to []
  def dynamic_resource_templates  # optional — defaults to []
  def register_tools(server, store)  # optional — defaults to no-op

  private  # per-tool register_ helpers, missing/not_found, etc.
end
```

Adding a source = one new loader + one new plugin class inserted into `server.rb`'s `PLUGINS` list
(grouped by family, alphabetical within each — see the list itself for the grouping). `build`/`read`/
`register_tools` are generic over `PLUGINS` and never need to change.

## Server.build Flow

```
store = PLUGINS.to_h { |p| [p.loader_key, p.loader.call] }
report_sources(store)   # warns loudly on any empty source

MCP::Server.new(resources: ..., resource_templates: ...)
  → resources_read_handler { |params| first plugin whose read(uri, store) matches }
  → PLUGINS.each { |p| p.register_tools(server, store) }
```

## Dogfooding Protocol

After any tool/resource/schema change, validate that a real MCP client builds the right understanding:

1. Drive the live server over stdio with `bin/mcp-query` (list tools/resources, call tools, read resources).
2. Spawn an agent restricted to MCP-only access (no library source/docs). Task it to build a representative artifact and report its mental model + gaps.
3. Validate the artifact against ground truth. Treat gaps as server-comprehension defects.
