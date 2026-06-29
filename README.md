# Stimulus Plumbers

[![@stimulus-plumbers/controllers][npm_badge]][npm]
[![stimulus-plumbers][rubygems_badge]][rubygems]
[![Coverage][coverage_badge]][coverage]

Accessible, WCAG 2.1 AA compliant UI components for Rails + Hotwire applications.

## Packages

| Package | Description |
|---------|-------------|
| [`@stimulus-plumbers/controllers`](stimulus-plumbers/) | Stimulus JS controllers |
| [`stimulus-plumbers`](stimulus-plumbers-rails/) | Rails view helpers and form builder |
| [`stimulus-plumbers-tailwind`](stimulus-plumbers-tailwind/) | Tailwind CSS v4 theme |
| [`stimulus-plumbers-mcp`](stimulus-plumbers-mcp/) | MCP server exposing API schema + docs to LLM IDEs |

The Rails gem renders semantic, ARIA-wired HTML; the npm package provides the Stimulus controllers that drive behavior; the Tailwind gem layers utility-class styling on top.

## MCP Server

Connect your LLM IDE to the local MCP server via `bin/mcp` at the repo root:

```json
{
  "mcpServers": {
    "stimulus-plumbers": {
      "command": "/path/to/stimulus-plumbers/bin/mcp"
    }
  }
}
```

## License

MIT © Ryan Chang

[npm_badge]: https://img.shields.io/npm/v/@stimulus-plumbers/controllers.svg
[npm]: https://www.npmjs.com/package/@stimulus-plumbers/controllers
[rubygems_badge]: https://img.shields.io/gem/v/stimulus-plumbers.svg
[rubygems]: https://rubygems.org/gems/stimulus-plumbers
[coverage_badge]: https://codecov.io/gh/ryancyq/stimulus-plumbers/graph/badge.svg?token=Z77H6M5GER
[coverage]: https://codecov.io/gh/ryancyq/stimulus-plumbers