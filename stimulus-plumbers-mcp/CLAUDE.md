# Stimulus Plumbers MCP

## Folder Structure

```
stimulus-plumbers-mcp/
├── bin/
│   ├── stimulus-plumbers-mcp                   # gem exec entry point (installed gem path; no clone needed)
│   ├── server                                  # MCP stdio server entry point (clone/dev path)
│   ├── mcp-query                               # Manual stdio query tool (tools/resources/tool/read subcommands)
│   └── bump-version                            # Version bump helper used by bin/release
├── lib/
│   ├── stimulus_plumbers_mcp.rb                # Top-level require: upstream gems → version → loaders → plugins → server
│   └── stimulus_plumbers/
│       └── mcp/
│           ├── version.rb                      # StimulusPlumbers::MCP::VERSION
│           ├── server.rb                       # Server.build — wires all plugins, registers resources + tools
│           ├── loaders/                        # Only classes assigned as a plugin's .loader go here — each loads
│           │   │                                # one source into store[loader_key]. Pure helpers with no source
│           │   │                                # of their own (parsers, path resolution) live in support/. Named
│           │   │                                # `<Plugin><Loader>` — loader name mirrors its owning plugin.
│           │   ├── support/
│           │   │   ├── gem_vendor_path.rb      # gem_dir/vendor/<relative> resolution, used by any loader with a vendored npm-package fallback
│           │   │   └── docs_table_parser.rb    # Parses `| Option |`/`| Slot method |` tables into the helper surface for component_docs_loader.rb
│           │   ├── guide_loader.rb             # Reads own guide.md (overview) + docs/guide.md from each package (npm/rails/tailwind) + docs/component/theme.md (theme) → guide://{overview,component,controller,tailwind,theme}
│           │   ├── guide.md                    # MCP-authored overview/index — the only guide content not sourced from another package
│           │   ├── aria_loader.rb              # Reads ARIA.md → aria://reference
│           │   ├── component_schema_loader.rb  # Reads Themes::Base::SCHEMA + form renderer constants (live source)
│           │   ├── icons_loader.rb             # Reads Tailwind theme's bundled icon SVG dirs + aliases (Tailwind-specific, not schema)
│           │   ├── component_docs_loader.rb    # Reads docs/component/*.md via stimulus_plumbers gem_dir; sibling path as dev fallback
│           │   ├── controller_schema_loader.rb # 3-path resolution: node_modules → gem vendor/ (GemVendorPath) → sibling dist/ (dev fallback)
│           │   ├── controller_docs_loader.rb   # Reads controller narrative docs from the JS package (monorepo dev path or vendored)
│           │   ├── component_requirements.rb   # Maps component keys → required Stimulus controller identifiers (live source)
│           │   ├── component_theme_loader.rb   # Extracts theme method signatures from Themes::Base; base_doc reads docs/component/theme.md (via ComponentDocsLoader.docs_dir)
│           │   ├── tailwind_loader.rb          # Extracts Tailwind CSS classes per component variant
│           │   └── versions_loader.rb          # Resolves gem/npm versions for every other loader's source
│           └── plugins/                        # One per source: subclasses Base — static_resources, templates, read(uri), register_tools
│               ├── base.rb                     # Shared contract: text_tool, json/text_resource, not_found
│               ├── guide.rb                    # guide://overview + guide://{name} resources, list_guides/get_guide tools
│               ├── aria.rb                     # aria:// resource
│               ├── component_schema.rb         # component://index/integration + component://{name}/schema + field_as tools
│               ├── icons.rb                    # component://icons + list_icons (Tailwind-sourced; kept separate from component_schema.rb so version drift is attributed correctly)
│               ├── component_docs.rb           # component://{name}/docs+helper + list_component_docs/get_component_examples/get_component_helper
│               ├── controller_schema.rb        # controller:// resources + list_controllers/get_controller_schema
│               ├── controller_docs.rb          # controller://docs resources + list_controller_docs/get_controller_docs
│               ├── component_theme.rb          # component://theme/base + component://theme resources + list_component_themes/get_component_theme
│               ├── tailwind.rb                 # component://tailwind resources + list_component_tailwind/get_component_tailwind
│               └── versions.rb                 # versions:// resource + get_source_versions
├── tasks/
│   ├── coverage.rake
│   ├── rubocop.rake
│   └── test.rake                               # Minitest::TestTask for test:unit
├── test/
│   ├── test_helper.rb
│   └── stimulus_plumbers/
│       └── mcp/
│           ├── guide_loader_test.rb
│           ├── gem_vendor_path_test.rb
│           ├── component_schema_loader_test.rb
│           ├── icons_loader_test.rb
│           ├── component_docs_loader_test.rb
│           ├── controller_schema_loader_test.rb
│           ├── controller_docs_loader_test.rb
│           ├── component_requirements_test.rb
│           ├── component_theme_loader_test.rb
│           ├── tailwind_loader_test.rb
│           ├── versions_loader_test.rb
│           ├── accuracy_test.rb               # Iterates documented components in schema; asserts valid values in parsed signature options
│           └── server_test.rb                 # Integration: drives every tool through the built server
├── Gemfile                                     # gemspec + path: sibling gems
├── Rakefile
└── stimulus_plumbers_mcp.gemspec
```

**Plugin naming:** `Component*`/`Controller*` pairs split by entity (Rails `component://` vs JS
`controller://`), not by facet — `ComponentSchema`+`ComponentDocs` mirror `ControllerSchema`+`ControllerDocs`.

**Loader naming:** a loader assigned to a plugin's `.loader` is named `<Plugin><Loader>` — e.g.
`ComponentSchema` plugin ↔ `ComponentSchemaLoader`, `ControllerDocs` plugin ↔ `ControllerDocsLoader`,
`ComponentTheme` plugin ↔ `ComponentThemeLoader`. Exceptions: `GuideLoader`/`AriaLoader` already match
their bare plugin names exactly.
`ComponentRequirements` has no `Loader` suffix — it isn't assigned as any plugin's `.loader` (it's
invoked by `ComponentSchemaLoader`), same as `loaders/support/`'s two files.

## Deployment Design

IDE setup via `gem exec` (Ruby 3.3+) — no clone, no `cwd`:

```json
{ "command": "gem", "args": ["exec", "stimulus-plumbers-mcp"] }
```

Clone path is for contributors only.

## Guidelines

- **Unit tests** using Minitest (`rake test:unit`)
- **Lint** using Rubocop (`rake rubocop`) — run synchronously from this gem's directory; never background or tail
- **Accuracy test** (`accuracy_test.rb`) — iterates every documented component that also exists in schema, asserting each valid param value appears in the parsed signature option tables (not just raw markdown); also cross-checks `field_as` values against form.md raw content; runs as part of `rake test`
- **Integration test** (`server_test.rb`) — drives every tool through `Server#handle_json`, the path that exercises `define_tool` block scope (unit tests only call loaders directly)

## Unit Test Convention

**Naming:** matches the loader class — e.g. `ComponentSchemaLoaderTest`, `ComponentDocsLoaderTest`, `ControllerSchemaLoaderTest`, `ComponentRequirementsTest`.

**Pattern:** call the loader directly and assert on the returned hash structure. No Rails sandbox needed.

> **Architecture decisions** (loader/manifest distinction, store shapes, plugin contract, server build flow, dogfooding protocol) are documented in [docs/architecture.md](docs/architecture.md).
