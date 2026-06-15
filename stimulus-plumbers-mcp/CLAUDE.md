# Stimulus Plumbers MCP

## Folder Structure

```
stimulus-plumbers-mcp/
├── bin/
│   ├── server                                  # MCP stdio server entry point
│   └── mcp-query                               # Manual stdio query tool (tools/resources/tool/read subcommands)
├── lib/
│   ├── stimulus_plumbers_mcp.rb                # Top-level require: upstream gems → version → loaders → plugins → server
│   ├── stimulus_plumbers_mcp/
│   │   └── version.rb                          # StimulusPlumbersMcp::VERSION
│   └── stimulus_plumbers/
│       └── mcp/
│           ├── server.rb                       # Server.build — wires all plugins, registers resources + tools
│           ├── loaders/                        # Each loads one source into store[LOADER_KEY]
│           │   ├── guide_loader.rb             # Reads guide/overview.md → guide://overview (entry-point map)
│           │   ├── guide/
│           │   │   └── overview.md             # Overview guide source (extracted from heredoc)
│           │   ├── schema_loader.rb            # Reads Themes::Base::SCHEMA + form renderer constants (live source)
│           │   ├── docs_loader.rb              # Reads ../stimulus-plumbers-rails/docs/component/*.md (live source)
│           │   ├── stimulus_manifest.rb        # Reads ../stimulus-plumbers/dist/controllers.manifest.json (built artifact)
│           │   ├── component_controller_map.rb # Maps component keys → Stimulus controller identifiers (live source)
│           │   ├── theme_loader.rb             # Extracts theme method signatures from Themes::Base
│           │   └── tailwind_theme_loader.rb    # Extracts Tailwind CSS classes per component variant
│           └── plugins/                        # One per source: STATIC_RESOURCES, templates, read(uri), register_tools
│               ├── base.rb                     # Shared contract: text_tool, json/text_resource, not_found
│               ├── guide.rb                    # guide:// resource
│               ├── schema.rb                   # schema:// resources + list_components/get_component_schema/get_field_types
│               ├── docs.rb                     # docs://, helper:// resources + get_erb_examples/get_helper_signature
│               ├── stimulus.rb                 # stimulus:// resources + list_controllers/get_controller_schema
│               ├── theme.rb                    # theme:// resources + get_theme_interface
│               └── tailwind.rb                 # tailwind:// resources + get_tailwind_classes
├── tasks/
│   ├── coverage.rake
│   ├── rubocop.rake
│   └── test.rake                               # Minitest::TestTask for test:unit
├── test/
│   ├── test_helper.rb
│   └── stimulus_plumbers/
│       └── mcp/
│           ├── guide_loader_test.rb
│           ├── schema_loader_test.rb
│           ├── docs_loader_test.rb
│           ├── stimulus_manifest_test.rb
│           ├── component_controller_map_test.rb
│           ├── theme_loader_test.rb
│           ├── tailwind_theme_loader_test.rb
│           ├── accuracy_test.rb               # Iterates documented components in schema; asserts valid values in parsed signature options
│           └── server_test.rb                 # Integration: drives every tool through the built server
├── Gemfile                                     # gemspec + path: sibling gems
├── Rakefile
└── stimulus_plumbers_mcp.gemspec
```

## Guidelines

- **Unit tests** using Minitest (`rake test:unit`)
- **Lint** using Rubocop (`rake rubocop`)
- **Accuracy test** (`accuracy_test.rb`) — iterates every documented component that also exists in schema, asserting each valid param value appears in the parsed signature option tables (not just raw markdown); also cross-checks `field_as` values against form.md raw content; runs as part of `rake test`
- **Integration test** (`server_test.rb`) — drives every tool through `Server#handle_json`, the path that exercises `define_tool` block scope (unit tests only call loaders directly)

## Dogfooding (MCP Comprehension Testing)

The loaders/tools are correct in isolation but the real question is whether a **real MCP client builds the right understanding** from them. Dogfood after any tool/resource/schema change:

1. **Drive the live server over stdio** using `bin/mcp-query` (Ruby script, wraps the JSON-RPC handshake):
   ```bash
   bundle exec ruby bin/mcp-query tools                             # list tools
   bundle exec ruby bin/mcp-query resources                         # list resources
   bundle exec ruby bin/mcp-query tool <name> [args_json]           # call a tool
   bundle exec ruby bin/mcp-query read <uri>                        # read a resource
   ```
2. **Spawn an agent restricted to MCP-only access** — explicitly forbid reading any library source/docs; the MCP server is its sole window. Task it to build a representative artifact (e.g. a display view + a Level-2 form) and to state its understanding + an MCP call log + a gaps section.
3. **Validate against ground truth** (the actual docs/source the agent could not see). Confirm the artifact is idiomatic and the agent's mental model matches; treat its "gaps/friction" notes as a backlog of server-comprehension defects.

Why it pays off: this is the layer that catches tool-through-server crashes (e.g. a `define_tool` block calling a module-private helper) and measures whether the exposed surface is *sufficient* — not just non-erroring.


## Unit Test Convention

**Naming:** matches the loader class — e.g. `SchemaLoaderTest`, `DocsLoaderTest`, `StimulusManifestTest`, `ComponentControllerMapTest`.

**Pattern:** call the loader directly and assert on the returned hash structure. No Rails sandbox needed.

## Loader Architecture

Each loader is a plain Ruby class with a single `.call`. Naming encodes the source boundary:
**`*Loader` / `*Map`** derive live from in-process Ruby constants or source files on disk (no build step); **`*Manifest`** consumes a pre-built artifact that crossed a language/compilation boundary.

- **`GuideLoader`** — reads `loaders/guide/overview.md` → `guide://overview` (entry-point map); fails soft (returns `""`) if the file is absent; the server's `instructions` point clients here first.
- **`SchemaLoader`** — reads `Themes::Base::SCHEMA` + `Form::Fields::Renderer` constants + calls `ComponentControllerMap`; returns `{ components:, field_as:, icons:, stimulus: }`.
- **`ComponentControllerMap`** — maps component theme keys to required Stimulus controller identifiers (live Ruby introspection); called by `SchemaLoader`.
- **`DocsLoader`** — reads `../stimulus-plumbers-rails/docs/component/*.md`; returns `{ component_name: { content:, examples:, signature: } }`. `signature` parses the `| Option |` / `| Slot method |` tables into the full `sp_` helper surface (the schema only has *theme* params): `{ helpers: [{ signature:, options: }], slots: [{ slot:, description:, block: }] }` — options grouped under the heading (sub-helper signature) above them, slots flagged `block:` when block-required.
- **`StimulusManifest`** — reads `../stimulus-plumbers/dist/controllers.manifest.json`, the one built artifact (produced by `npm run build` / `npm run build:manifest` in the JS package); returns `{}` with a warning if absent.
- **`ThemeLoader`** — introspects `Themes::Base` to produce method-level theme interface docs.
- **`TailwindThemeLoader`** — resolves CSS classes for each component variant via `TailwindTheme`.

**Store shapes** — each loader puts a differently shaped value in `store[LOADER_KEY]`, so a plugin's `read`/`register_tools` knows what to expect:

- `SchemaLoader` → structured hash `{ components:, field_as:, icons:, stimulus: }`
- `DocsLoader` → `{ name => { content:, examples:, signature: } }`
- `StimulusManifest` → parsed JSON hash (or `{}` if the artifact is absent)
- `ThemeLoader` → `{ base_doc:, components: }`
- `TailwindThemeLoader` → `{ key => { "param:value" => classes } }`
- `GuideLoader` → a `String` (the overview markdown)

> Runs from a monorepo checkout: the sibling-directory paths above resolve against the repo layout, not an installed gem.

## Plugin Architecture

`server.rb` holds a `PLUGINS` list (`Guide, Schema, Docs, Stimulus, Theme, Tailwind`). Each plugin
module `extend`s `Plugins::Base` and declares: `LOADER_KEY`, `LOADER`, `STATIC_RESOURCES`,
`DYNAMIC_RESOURCE_TEMPLATES`, `read(uri, store)`, and (optionally) `register_tools(server, store)`.
Adding a source = adding one loader + one plugin and appending it to `PLUGINS`; `server.rb` itself
doesn't change. `Base` supplies the shared helpers: `text_tool` (wraps `define_tool`, strips
`:server_context`, renders `not_found` as a uniform `isError` + `{ error: }` payload),
`json_resource`/`text_resource`, and `not_found`.

## Server.build Flow

```
store = PLUGINS.to_h { |p| [p::LOADER_KEY, p::LOADER.call] }   # every loader populates the store
report_sources(store)                                          # warn loudly on any empty source

MCP::Server.new(
  resources:          PLUGINS.flat_map(&:STATIC_RESOURCES),
  resource_templates: PLUGINS.flat_map(&:DYNAMIC_RESOURCE_TEMPLATES)
)
→ resources_read_handler { |params| first plugin whose read(uri, store) matches }
→ PLUGINS.each { |p| p.register_tools(server, store) }
```

