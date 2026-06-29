# MCP Server Architecture

## Loader vs. Manifest Naming

Naming encodes the source boundary:

- **`*Loader` / `*Map`** — derive live from in-process Ruby constants or source files on disk (no build step).
- **`*Manifest`** — consumes a pre-built artifact that crossed a language/compilation boundary (e.g. the JS build output).

## Store Shapes

Each loader puts a typed value in `store[LOADER_KEY]`:

| Loader                | Key         | Shape                                             |
| --------------------- | ----------- | ------------------------------------------------- |
| `SchemaLoader`        | `:schema`   | `{ components:, field_as:, icons:, stimulus: }`   |
| `DocsLoader`          | `:docs`     | `{ name => { content:, examples:, signature: } }` |
| `StimulusManifest`    | `:stimulus` | parsed JSON hash (or `{}` if artifact absent)     |
| `ThemeLoader`         | `:theme`    | `{ base_doc:, components: }`                      |
| `TailwindThemeLoader` | `:tailwind` | `{ key => { "param:value" => classes } }`         |
| `GuideLoader`         | `:guide`    | `String` (overview markdown)                      |

## Plugin Module Contract

Each plugin `extend`s `Plugins::Base` and declares:

```ruby
LOADER_KEY   # Symbol — key into the shared store
LOADER       # Callable — single .call returns the store value
STATIC_RESOURCES        # Array of resource descriptors
DYNAMIC_RESOURCE_TEMPLATES  # Array of URI templates
def self.read(uri, store)   # Returns content for a matching URI; nil otherwise
def self.register_tools(server, store)  # Optional — registers MCP tools
```

Adding a source = one new loader + one new plugin appended to `server.rb`'s `PLUGINS` list. `server.rb` itself does not change.

## Server.build Flow

```
store = PLUGINS.to_h { |p| [p::LOADER_KEY, p::LOADER.call] }
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
