# Plumber::Dispatcher

Strategy factory that dispatches a callable against a target object. Used internally by `Form::Builder` to route `f.field` calls to the correct input renderer.

## Factory

```ruby
Dispatcher.build(callable, *args, **kwargs, &block)
```

| `callable` type    | Strategy       | Behaviour                                                    |
| ------------------ | -------------- | ------------------------------------------------------------ |
| `Symbol`           | `MethodCall`   | Calls the named method on `target`                           |
| `Proc`             | `InstanceExec` | Executes the proc via `instance_exec` on `target`            |
| `Module` / `Class` | `KlassProxy`   | Instantiates the class, calls `method_name:` on the instance |
| `String`           | `KlassProxy`   | Resolved via `safe_constantize`, then same as `Module`       |

All dispatchers share one interface: `dispatcher.call(target)`.

## Strategies

### MethodCall

Calls a named method on `target`. Positional args beyond the method's arity are dropped; kwargs are forwarded only when the method declares keyword parameters. Private methods are reachable.

```ruby
Dispatcher.build(:render_input, attribute).call(form_builder)
Dispatcher.build(:render_input, attribute, html_opts, as: :text).call(form_builder)

# block forwarded to the method
Dispatcher.build(:render_input, attribute) { |html| tag.div(html) }.call(form_builder)
```

### InstanceExec

Executes a `Proc` via `instance_exec` on `target`. The proc body has full access to `target`'s instance methods and instance variables.

```ruby
renderer = proc { |attribute, opts| @template.text_field(@object_name, attribute, opts) }
Dispatcher.build(renderer, attribute, html_opts).call(form_builder)
```

The `Proc` itself is the block — any `&block` passed to `build` is ignored. To compose a secondary callable, pass it as a positional argument:

```ruby
wrapper  = ->(html) { tag.div(html, class: "wrapper") }
renderer = proc { |attribute, opts, wrap| wrap.call(@template.text_field(@object_name, attribute, opts)) }
Dispatcher.build(renderer, attribute, html_opts, wrapper).call(form_builder)
```

### KlassProxy

Instantiates `callable` with `init_args:` / `init_kwargs:`, then calls `method_name:` on the instance. `target` is ignored. A `String` callable is resolved via `safe_constantize` at build time.

```ruby
Dispatcher.build(
  MyRenderer,
  attribute, html_opts,
  method_name: :render,
  init_args:   [@template]
).call(anything)

# block forwarded to the method
Dispatcher.build(
  MyRenderer,
  attribute,
  method_name: :render,
  init_args:   [@template]
) { |html| tag.div(html) }.call(anything)
```

## Block forwarding

`MethodCall` and `KlassProxy` capture a block at build time and forward it to the dispatched method. `dispatcher.block` returns `nil` when no block is given.

`InstanceExec` does not participate — the `Proc` is the block. Compose further callables as positional arguments instead.
