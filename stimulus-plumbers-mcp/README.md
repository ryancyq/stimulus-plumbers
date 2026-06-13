# stimulus-plumbers-mcp

MCP server for [`stimulus_plumbers`](../stimulus-plumbers-rails). Exposes the component API schema, documentation, and Stimulus controller metadata to LLM-powered IDEs.

## Requirements

- Ruby >= 3.0
- A checkout of the [stimulus-plumbers monorepo](https://github.com/ryancyq/stimulus-plumbers) — the server reads the sibling `stimulus-plumbers-rails/` and `stimulus-plumbers/` packages directly.
- Node (only to build the Stimulus controller manifest — see [Development](#development))

## Installation

This is a dev tool run from a monorepo checkout, not a published gem. Clone the repo and install dependencies:

```bash
git clone https://github.com/ryancyq/stimulus-plumbers
cd stimulus-plumbers/stimulus-plumbers-mcp
bundle install
```

## Resources

| URI | Content |
|-----|---------|
| `guide://overview` | **Start here** — map of the form/view/stimulus API with pointers to every tool/resource |
| `schema://components` | Index of all component theme keys |
| `schema://components/{name}` | Params, valid values, defaults + required controllers |
| `schema://icons` | All available icon names |
| `schema://stimulus` | Map from component key → required Stimulus controller identifiers |
| `docs://components/{name}` | Full markdown doc with ERB examples |
| `helper://components/{name}` | Full `sp_` helper surface: keyword options + defaults (grouped by helper signature) + slot methods (with block-required flag) |
| `stimulus://controllers` | Index of Stimulus controller identifiers |
| `stimulus://controllers/{identifier}` | Targets, values, outlets, classes for a controller |
| `theme://base` | Custom theme authoring guide |
| `theme://components` | Index of theme-implementable component keys |
| `theme://components/{name}` | Method name, param signature, return contract |
| `tailwind://components` | Index of Tailwind theme component keys |
| `tailwind://components/{name}` | Tailwind CSS classes per variant |

## Tools

| Tool | Input | Output |
|------|-------|--------|
| `list_components` | — | All component theme keys |
| `list_docs` | — | Components with markdown docs + helper signatures (the `docs://`/`helper://` `{name}` set) |
| `get_component_schema` | `component` | Themed params (type/variant/size) + defaults + required controllers |
| `get_helper_signature` | `component` | Full `sp_` helper surface — keyword options grouped by helper signature (incl. `icon_leading`) + slot methods |
| `get_erb_examples` | `component` | ERB code fences from docs |
| `get_field_types` | `builder_method` (`field`/`collection_field`/`choice`) | Valid `as:` values |
| `list_controllers` | — | All Stimulus controller identifiers |
| `get_controller_schema` | `controller` | Targets, values, outlets, classes |
| `get_theme_interface` | `component` | Method signature + return contract for custom theme |
| `get_tailwind_classes` | `component` | Tailwind CSS utility classes per variant |

## IDE Setup

Add to your IDE's MCP config:

```json
{
  "mcpServers": {
    "stimulus-plumbers": {
      "command": "bundle",
      "args": ["exec", "ruby", "bin/server"],
      "cwd": "/path/to/stimulus-plumbers-mcp"
    }
  }
}
```

## Development

```bash
bundle install

# Build the Stimulus controller manifest (pure Node, no toolchain install needed)
cd ../stimulus-plumbers && npm run build:manifest && cd -

# Start the server
bundle exec ruby bin/server
```

### Manual querying

`bin/mcp-query` wraps the JSON-RPC stdio protocol for quick manual inspection:

```bash
bundle exec ruby bin/mcp-query tools                                  # list tools
bundle exec ruby bin/mcp-query resources                              # list resources
bundle exec ruby bin/mcp-query tool list_components                   # call a tool (no args)
bundle exec ruby bin/mcp-query tool get_component_schema '{"component":"button"}'
bundle exec ruby bin/mcp-query read guide://overview
bundle exec ruby bin/mcp-query read docs://components/form
```

```bash
bundle exec rake test:unit  # unit tests
bundle exec rake rubocop    # lint
bundle exec rake coverage   # run tests with coverage
```

## License

[MIT](https://opensource.org/licenses/MIT)
