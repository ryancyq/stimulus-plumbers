# stimulus-plumbers-mcp

MCP server for [`stimulus_plumbers`](../stimulus-plumbers-rails). Exposes the component API schema, documentation, and Stimulus controller metadata to LLM-powered IDEs.

## Requirements

- Ruby >= 3.0
- Node (contributors only — to build the Stimulus controller manifest)

## Installation

```bash
gem install stimulus_plumbers_mcp
```

## Resources

| URI | Content |
|-----|---------|
| `guide://overview` | **Start here** — map of the form/view/stimulus API with pointers to every tool/resource |
| `guide://{name}` | Per-package usage guide: `component` (Rails forms/views), `controller` (plain-JS/non-Rails setup), `tailwind` (Tailwind install/theming), `theme` (custom theme integration contract) |
| `aria://reference` | WCAG 2.1 AA criteria, keyboard navigation patterns, and per-component ARIA patterns |
| `component://index` | Index of all component theme keys |
| `component://icons` | All available icon names |
| `component://integration` | Map from component key → required Stimulus controller identifiers |
| `component://{name}/schema` | Params, valid values, defaults + required controllers |
| `component://{name}/docs` | Full markdown doc with ERB examples |
| `component://{name}/helper` | Full `sp_` helper surface: keyword options + defaults (grouped by helper signature) + slot methods |
| `component://theme` | Index of theme-implementable component keys |
| `component://{name}/theme` | Method name, param signature, return contract |
| `component://theme/base` | Custom theme authoring guide |
| `component://tailwind` | Index of Tailwind theme component keys |
| `component://{name}/tailwind` | Tailwind CSS classes per variant |
| `controller://index` | Index of Stimulus controller identifiers |
| `controller://{name}/schema` | Targets, values, outlets, classes for a controller |
| `controller://docs` | Index of JS controller narrative docs, grouped by controller family |
| `controller://docs/{name}` | Narrative usage doc for a controller family (plain-JS/Hotwire, no Rails helpers) |
| `versions://sources` | Resolved version (and resolution path) of each source gem/package |

## Tools

| Tool | Input | Output |
|------|-------|--------|
| `list_components` | — | All component theme keys |
| `list_component_docs` | — | Components with markdown docs + helper signatures (the `component://{name}/docs`+`/helper` set) |
| `get_component_schema` | `name` | Themed params (type/variant/size) + defaults + required controllers |
| `get_component_helper` | `name` | Full `sp_` helper surface — keyword options grouped by helper signature (incl. `icon_leading`) + slot methods |
| `get_component_examples` | `name` | ERB code fences from docs |
| `get_field_as_values` | `builder_method` (`field`/`collection_field`/`choice`) | Valid `as:` values |
| `get_field_as_controller` | `as` | Stimulus controller identifier backing a controller-backed `as:` value |
| `list_component_themes` | — | Component keys implementable in a custom theme |
| `get_component_theme` | `name` | Method signature + return contract for custom theme |
| `list_component_tailwind` | — | Component keys implemented by the Tailwind theme |
| `get_component_tailwind` | `name` | Tailwind CSS utility classes per variant |
| `list_icons` | — | All available icon names bundled with the Tailwind theme |
| `list_controllers` | — | All Stimulus controller identifiers |
| `get_controller_schema` | `name` | Targets, values, outlets, classes |
| `list_controller_docs` | — | Controller doc families available at `controller://docs/{name}` |
| `get_controller_docs` | `name` | Narrative usage doc for a controller family |
| `get_source_versions` | — | Resolved version (and resolution path) of each source |
| `list_guides` | — | Available per-package guide names (`component`/`controller`/`tailwind`/`theme`) |
| `get_guide` | `name` | Per-package usage guide content |

## IDE Setup

```json
{
  "mcpServers": {
    "stimulus-plumbers": {
      "command": "gem",
      "args": ["exec", "stimulus-plumbers-mcp"]
    }
  }
}
```

Requires Ruby >= 3.3 for the `gem exec` subcommand (the gem itself supports Ruby >= 3.0). No `cwd` required. Pin a specific version by adding it to your `Gemfile` and running `bundle exec gem exec stimulus-plumbers-mcp`.

## Stimulus Manifest

`controller://` resources require the controller manifest. The server resolves it in order:

1. `node_modules/@stimulus-plumbers/controllers/dist/controllers.manifest.json` — npm/yarn/bun projects
2. `vendor/controllers.manifest.json` inside the installed `stimulus_plumbers` gem — importmaps fallback
3. `../stimulus-plumbers/dist/controllers.manifest.json` — monorepo dev fallback

No extra steps needed for setups 1 or 2.

## Development

```bash
git clone https://github.com/ryancyq/stimulus-plumbers
cd stimulus-plumbers/stimulus-plumbers-mcp
bundle install

# Build the Stimulus controller manifest (pure Node, no toolchain install needed)
cd ../stimulus-plumbers && node --run build:manifest && cd -

# Start the server
bundle exec ruby bin/server
```

### Manual querying

`bin/mcp-query` wraps the JSON-RPC stdio protocol for quick manual inspection:

```bash
bundle exec ruby bin/mcp-query tools                                  # list tools
bundle exec ruby bin/mcp-query resources                              # list resources
bundle exec ruby bin/mcp-query tool list_components                   # call a tool (no args)
bundle exec ruby bin/mcp-query tool get_component_schema '{"name":"button"}'
bundle exec ruby bin/mcp-query read guide://overview
bundle exec ruby bin/mcp-query read component://form/docs
```

```bash
bundle exec rake test:unit  # unit tests
bundle exec rake rubocop    # lint
bundle exec rake coverage   # run tests with coverage
```

## License

[MIT](https://opensource.org/licenses/MIT)
