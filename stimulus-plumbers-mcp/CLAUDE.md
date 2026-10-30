# Stimulus Plumbers MCP

## Folder Structure

```
stimulus-plumbers-mcp/
├── bin/                                        # Entry points below, plus dev scripts
│   ├── stimulus-plumbers-mcp                   # gem exec entry point (installed gem path; no clone needed)
│   └── server                                  # MCP stdio server entry point (clone/dev path)
├── lib/
│   ├── stimulus_plumbers_mcp.rb                # Top-level require: upstream gems → version → loaders → plugins → server
│   └── stimulus_plumbers/mcp/
│       ├── server.rb                           # Server.build (see docs/architecture.md "Server.build Flow")
│       ├── loaders/                            # One loader per source into store[loader_key], plus ComponentRequirements (see docs/architecture.md "Loader Naming")
│       │   ├── support/                        # Pure helpers with no source of their own (parsers, path resolution)
│       │   └── guide.md                        # MCP-authored overview — the only guide content not sourced from another package
│       └── plugins/                            # One per source, subclassing base.rb (see docs/architecture.md "Plugin Class Contract")
├── test/
│   ├── stimulus_plumbers/mcp/                  # <class>_test.rb per loader and helper, plus cross-cutting tests (see Guidelines)
│   └── test_helper.rb
├── tasks/                                      # Gem-dev rake tasks
├── docs/architecture.md
└── Gemfile                                     # gemspec + path: sibling gems
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

**Naming:** matches the loader class — e.g. `ComponentSchemaLoaderTest`, `ComponentDocsLoaderTest`, `ControllerSchemaLoaderTest`, `ComponentRequirementsTest`.

**Pattern:** call the loader directly and assert on the returned hash structure. No Rails sandbox needed.

> **Architecture decisions** (loader/manifest distinction, store shapes, plugin contract, server build flow, dogfooding protocol) are documented in [docs/architecture.md](docs/architecture.md).
