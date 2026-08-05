# `Form::Builder#field` Block Support

**Date:** 2026-07-20
**Status:** Implemented
**Packages:** `stimulus-plumbers-rails`
**Consumed by:** `2026-07-20-password-strength-meter-design.md` (that spec assumes this API;
this one ships the mechanism and no password feature)

## Problem

`Form::Builder#field` (`form/builder.rb:50`) takes no block, so a field type cannot accept
sub-configuration that keyword arguments express badly — a variable-length list of rows, each
with a key and a label:

```ruby
f.field :password, as: :password, revealable: true do |p|
  p.strength min_length: 12
  p.rule :digit,  "One number"
  p.rule :symbol, "One symbol"
end
```

Every other block DSL in the gem already reads this way (`sp_card`, `sp_button`,
`sp_combobox`), so `field` is the outlier.

## Solution

Forward a block from `field` to the renderer method, and let the renderer build its own
`Plumber::Config` subclass.

**Most of the plumbing already exists.** `Dispatcher.build` accepts and forwards `&block`
(`plumber/dispatcher.rb:12`), `MethodCall#call` passes it to the target
(`plumber/dispatcher/method_call.rb:24`), and `render_combobox` already declares `&block` and
forwards it to `Components::Combobox` (`form/fields/inputs/combobox.rb:10`). The only gap is
that `field` does not accept a block and `render_field` does not pass one.

### Three edits

1. **`form/builder.rb:50`** — `field` accepts `&block` and forwards it:

   ```ruby
   def field(attribute, as:, **options, &block)
     field_opts = options.slice(*Field::OPTIONS)
     input_opts = options.except(*Field::OPTIONS)
     render_field(as, attribute, field_opts, input_opts, &block)
   end
   ```

2. **`form/builder.rb:74`** — `render_field` guards, then passes `&block` into the existing
   `Dispatcher.build(...)` call. Nothing inside `Dispatcher` changes.

3. **`plumber/dispatcher/callable_inspector.rb`** — add `accepts_block?`, mirroring the
   `accepts_kwargs?` already in that file:

   ```ruby
   def accepts_block?(callable)
     callable.parameters.any? { |type, _| type == :block }
   end
   ```

### Opt-in is by declaration

A renderer accepts a block by declaring `&block` and building its own DSL object, the way
`form/fields/inputs/submit.rb:46` already builds `Components::Button::Slots.new(@template)`:

```ruby
def render_password_input(attribute, html_opts, opts, error, **kwargs, &block)
  config = Password::Config.new(@template)
  block&.call(config)
  ...
end
```

**No registry, no allowlist.** Declaring `&block` *is* registering. A second list mapping
types to DSL classes would be a fourth place to forget when adding a renderer — the same
drift that let a stale vendored manifest mask a real MCP test failure.

Pass `template` to the constructor. `Config` only forwards it to renderers, but every
existing site passes one, and a `Slots` built without it silently loses ERB capture.

### The yielded object is a `Config`, not a `Slots`

Password strength is configuration — option values and rule labels, with nothing captured or
rendered from the block — so it subclasses `Plumber::Config`, not `Plumber::Slots`. See
`2026-07-20-plumber-config-pattern-design.md` for the boundary between the two patterns; that
spec must land first.

```ruby
Password::Config.new(@template)
```

Naming it `Config` also removes an ambiguity: renderer methods are mixed into `Form::Builder`
(`form/builder.rb:31`), so a class named `Password::Builder` would read as the form builder
inside `render_password_input`.

### Guard

A block given to a type whose renderer does not declare one raises `ArgumentError` from
`render_field`, beside the existing `unknown field type` raise:

```ruby
f.field :email, as: :email do |x| ... end
# => ArgumentError: field type :email does not accept a block
```

**The guard belongs in `render_field`, not in `MethodCall#call`.** `Plumber::Renderer`'s
generated methods already pass blocks through `Dispatcher` (`plumber/renderer.rb:113`,
`&slot_block_for`) with Symbol targets, so a raise inside `MethodCall` would fire on existing
component slot rendering. Scoping the check to `render_field` keeps the blast radius to the
one new path.

## Backward compatibility

No behavior change when no block is passed. The existing suite must stay green with no edits:

```
bundle exec rake test:unit           # 1366 runs / 2503 assertions at baseline
bundle exec rake test:accessibility
bundle exec rake rubocop             # run synchronously from the gem dir
```

If an existing test needs changing to accommodate this, stop — that means the change is not
backward compatible and the design needs revisiting.

## Testing

`test/stimulus_plumbers/form/builder_test.rb` (`FormBuilderTest`):

- a block on an accepting type is yielded the Config object, and its collected state reaches
  the renderer
- a block on a non-accepting type raises `ArgumentError`; assert the literal message
- no block → output identical to today, for both an accepting and a non-accepting type
- the Config receives the template — assert it is passed, not that it captures. `Config`
  performs no capture; that is `Slots` behaviour and does not apply here.

Regression, since this is the path the design nearly broke:

- component slot rendering through `Plumber::Renderer` still works — a `renders ..., with:`
  Symbol target with a Proc slot set

Mutation-test the forwarding: drop `&block` from `render_field` and confirm the first test
fails. A test that passes against a no-op is not proof.

## Proof consumer

`render_password_input` declares `&block` and builds a
`Form::Fields::Inputs::Password::Config < Plumber::Config` exposing exactly one setter,
`strength(**options)`, which stores its options and renders nothing. That is enough to prove
the block is yielded, the collected state survives the dispatch, and the template reached the
constructor. Rendered output is unchanged whether or not the block is passed.

The full `p.strength` / `p.rule` DSL, the rules-merge semantics, the scorer, the meter, and
the checklist belong to the password strength spec and are out of scope here.

## Out of scope

- `collection_field` and `choice`, and everything under `Fields::Renderer::COLLECTION` /
  `CHOICE`. `field` only.
- `KlassProxy` block guarding. Symmetry with `MethodCall` is not a reason on its own; add it
  when something needs it.
- The password strength meter, scorer, and rules checklist.

## Docs

Update `docs/component/form.md` — the two-level builder API is documented there and nowhere
else. A few lines: one example, and the rule that a renderer opts in by declaring `&block`.
Do not restate it in any README or CLAUDE.md.
