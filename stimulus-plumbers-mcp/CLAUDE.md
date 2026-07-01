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
│           ├── loaders/                        # Each loads one source into store[LOADER_KEY]
│           │   ├── guide_loader.rb             # Reads guide/overview.md → guide://overview (entry-point map)
│           │   ├── guide/
│           │   │   └── overview.md             # Overview guide source (extracted from heredoc)
│           │   ├── schema_loader.rb            # Reads Themes::Base::SCHEMA + form renderer constants (live source)
│           │   ├── docs_loader.rb              # Reads docs/component/*.md via stimulus_plumbers gem_dir; sibling path as dev fallback
│           │   ├── stimulus_manifest.rb        # 3-path resolution: node_modules → gem vendor/ → sibling dist/ (dev fallback)
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

**Naming:** matches the loader class — e.g. `SchemaLoaderTest`, `DocsLoaderTest`, `StimulusManifestTest`, `ComponentControllerMapTest`.

**Pattern:** call the loader directly and assert on the returned hash structure. No Rails sandbox needed.

> **Architecture decisions** (loader/manifest distinction, store shapes, plugin contract, server build flow, dogfooding protocol) are documented in [docs/architecture.md](docs/architecture.md).

