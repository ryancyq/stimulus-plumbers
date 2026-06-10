# Plumber Internals

The `Plumber` namespace provides the shared infrastructure that all renderers and the form builder are built on: a base class, a renderer declaration macro, and an HTML option merge utility.

See [dispatcher.md](dispatcher.md) for the `Plumber::Dispatcher` strategy factory.

---

## Plumber::Base

The foundation class for all component renderers. Inherit from it to get `template`, `theme`, `merge_html_options`, and the `renders` macro in one shot.

```ruby
class MyRenderer < StimulusPlumbers::Plumber::Base
  renders :my_component, with: MyComponent

  def render(...)
    my_component(...)
  end
end
```

### Included modules

| Module                   | What it adds                                                    |
| ------------------------ | --------------------------------------------------------------- |
| `Plumber::Options::Html` | `merge_html_options`, `merge_stimulus_data`, `merge_token_list` |
| `Plumber::Renderer`      | `renders` class macro; `renderers` class attribute              |

### Instance interface

```ruby
renderer = MyRenderer.new(view_context)
renderer.template  # => the ActionView template / view context
renderer.theme     # => StimulusPlumbers.config.theme.current
```

`theme` delegates to the global configuration so renderers always read the active theme at call time — no need to pass it in.

---

## Plumber::Renderer

`ActiveSupport::Concern` that adds the `renders` class macro. Included by `Plumber::Base`; can also be included standalone.

### `renders`

Declares a public method on the class and wires it to a callable via `Plumber::Dispatcher`.

```ruby
renders :method_name, with: callable
renders :method_name { |*args| ... }    # block form — Proc/InstanceExec strategy
```

`callable` follows the same type rules as `Dispatcher.build` (Symbol, Proc, Class/Module, String). A block is sugar for `with: proc { ... }`.

When the generated method is called, it:

1. Looks up `renderers.fetch(:method_name)` for the registered callable.
2. Builds a dispatcher via `Dispatcher.build(callable, *args, method_name: :method_name, init_args: [template], **kwargs)`.
3. Calls `dispatcher.call(self)`.

The `method_name:` and `init_args: [template]` are injected automatically — you never pass them when calling the generated method.

### Strategy mapping

| `with:` type       | Dispatcher strategy | Effective call                                      |
| ------------------ | ------------------- | --------------------------------------------------- |
| `Symbol`           | `MethodCall`        | `self.send(symbol, *args, **kwargs)`                |
| `Proc` / block     | `InstanceExec`      | `self.instance_exec(*args, **kwargs, &proc)`        |
| `Class` / `Module` | `KlassProxy`        | `Class.new(template).method_name(*args, **kwargs)`  |
| `String`           | `KlassProxy`        | Resolved via `safe_constantize`, then same as Class |

### Example

```ruby
class ComboboxHelper
  include StimulusPlumbers::Plumber::Renderer
  include StimulusPlumbers::Plumber::Options::Html

  attr_reader :template

  def initialize(template)
    @template = template
  end

  renders :sp_combobox_dropdown, with: Components::Combobox::Dropdown
  renders :sp_combobox_date,     with: Components::Combobox::Date
end
```

Calling `helper.sp_combobox_dropdown(*args, **opts)` instantiates `Components::Combobox::Dropdown.new(template)` and calls `.sp_combobox_dropdown(*args, **opts)` on it.

### `renderers` class attribute

`renderers` is an inheritable `class_attribute` (hash). Subclasses inherit the parent's renderers and can extend or override them without affecting the parent.

```ruby
class MyHelper < ComboboxHelper
  renders :sp_combobox_dropdown, with: MyCustomDropdown  # overrides parent's entry
end
```

---

## Plumber::Options::Html

Mixin for safely deep-merging HTML attribute hashes. Handles three concerns that a plain `Hash#merge` gets wrong:

1. **`class:` accumulation** — theme classes and caller-supplied classes must both appear, not overwrite each other.
2. **Stimulus space-joining** — `data-controller` and `data-action` are additive; multiple controllers/actions must be space-joined, not replaced.
3. **`classes:` key** — theme resolution returns `{ classes: "..." }` rather than `{ class: "..." }` to avoid conflicts; `merge_html_options` unifies both keys.

### `merge_html_options(*hashes)`

Merges any number of HTML option hashes into one. Order matters — later hashes win on plain key conflicts, but `class`/`classes`/`data-controller`/`data-action` are always accumulated.

```ruby
merge_html_options(
  { class: "text-sm",   data: { controller: "toggle" } },
  { classes: "border",  data: { controller: "flip", action: "click->flip#run" } },
  { class: "font-bold", data: { action: "keydown->flip#key" } }
)
# => {
#   class: "text-sm border font-bold",
#   data: {
#     controller: "toggle flip",
#     action: "click->flip#run keydown->flip#key"
#   }
# }
```

Typical call site in an input renderer:

```ruby
html_options = merge_html_options(caller_opts, field_theme(:form_input, error: error))
```

`field_theme` returns `{ class: theme_classes }` (via `{ classes: ... }` internally); `merge_html_options` folds both into a single `class:` value.

### `merge_token_list(*parts, delimiter: " ")`

Joins string-like values into a single space-separated string, deduplicating tokens. Accepts heterogeneous inputs:

| Input type    | Behaviour                                                            |
| ------------- | -------------------------------------------------------------------- |
| `String`      | Split by delimiter, each token kept                                  |
| `Hash`        | Keys whose value is truthy become tokens (conditional class pattern) |
| `Array`       | Recursively merged                                                   |
| anything else | Ignored                                                              |

```ruby
merge_token_list("btn",  "btn-sm", "btn")         # => "btn btn-sm"
merge_token_list({ "hidden" => false, "active" => true })  # => "active"
merge_token_list(["flex", "items-center"], "gap-2")        # => "flex items-center gap-2"
```

### `merge_stimulus_data(*hashes, spacejoin:)`

Deep-merges `data:` sub-hashes. Keys listed in `spacejoin:` (default: `[:controller, :action]`) are space-joined when they conflict; all other keys use last-wins semantics.

```ruby
merge_stimulus_data(
  { controller: "toggle", value: "1" },
  { controller: "flip",   value: "2" }
)
# => { controller: "toggle flip", value: "2" }
```

Pass `spacejoin: []` to disable space-joining entirely (plain deep merge).

### Extending the space-join set

If a Stimulus controller uses a custom multi-valued data key (e.g. `data-targets`), override `merge_stimulus_data` with an extended `spacejoin:` list:

```ruby
def merge_html_options(*hashes)
  super.tap do |result|
    result[:data] = merge_stimulus_data(*hashes.map { |h| h[:data] || {} },
                                        spacejoin: STIMULUS_SPACEJOIN_KEYS + %i[targets])
  end
end
```
