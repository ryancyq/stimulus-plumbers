# Decoupling `Plumber::Config` from `Plumber::Slots`

**Date:** 2026-07-20
**Status:** Implemented
**Packages:** `stimulus-plumbers-rails`
**Follows:** `2026-07-20-form-builder-field-block-design.md`, which is already in progress.
That work lands a `Password::Builder < Plumber::Slots` proof consumer; this spec renames and
reparents it as a second migration target alongside Combobox. Nothing in the two overlaps
except that class — `field`, `render_field`, and `accepts_block?` are untouched here.

## Problem

`Combobox::Builder < Plumber::Slots` inherits machinery it cannot use.

`Plumber::Slots` exists to capture content: `resolve` runs a slot value through
`template.capture` when the value is a `Proc`, so ERB output is returned rather than written
to whatever buffer happens to be active (`plumber/slots.rb:36`). That capture is the reason
`Slots` takes a template at all.

`Combobox::Builder` stores `set_slot(:variant, { renderer: Dropdown, options: {...} })` — a
Hash, never a Proc. `capture_block` is therefore dead code for it, along with the `slot`
class macro, `options_for`, `any?`, and `none?`. It uses three things: the template, a keyed
store, and readers.

The tell is `selected?`, which reads `@slots.key?(:variant)` directly
(`components/combobox/builder.rb:26`) because the base class exposes no predicate. Reaching
past a parent's API is the signal that the parent is wrong, not that a method is missing.

A second consumer is arriving — the password strength builder in the specs above — so the
pattern gets settled now rather than copied.

## Solution

Two sibling base classes, split by **payload**:

| | `Plumber::Slots` | `Plumber::Config` |
| --- | --- | --- |
| Holds | content — blocks rendered through the view | configuration — values, hashes, class references |
| Template used for | `capture` (essential) | passing through to renderers only |
| Declares | `slot :a, :b` macro, generating `with_*` setters | plain named methods |
| Consumers | `Card::Slots`, `Timeline::Event::Slots`, and 5 more | `Combobox::Config`, `Password::Config` |

**The test for an author: does the block body produce markup?** Yes → `Slots`. No → `Config`.

Subclass names match their base, as the `Slots` side already does (`Card::Slots <
Plumber::Slots`), so `Combobox::Config < Plumber::Config`.

### `plumber/config.rb` (new)

```ruby
module StimulusPlumbers
  module Plumber
    class Config
      attr_reader :template

      def initialize(template = nil)
        @template = template
        @config = {}
      end

      def configure(key, value)
        @config[key] = value
        nil
      end

      def config(key)
        @config[key]
      end

      def configured?(key)
        @config.key?(key)
      end
    end
  end
end
```

Multi-line definitions throughout: `.rubocop.yml:31` sets `Style/EndlessMethod: disallow`,
and `Style/SingleLineMethods` has `AllowIfMethodIsEmpty: false`. There are no endless methods
anywhere in `lib/`.

### Migration — mechanical and behaviour-preserving

```
components/combobox/builder.rb  →  components/combobox/config.rb
  class Builder < Plumber::Slots  →  class Config < Plumber::Config
  set_slot(:variant, {...})       →  configure(:variant, {...})
  resolve(:variant)               →  config(:variant)
  @slots.key?(:variant)           →  configured?(:variant)
```

Also: the `require` in `lib/stimulus_plumbers.rb`, one reference in
`components/combobox.rb`, and the test file rename
(`components/combobox/builder_test.rb` → `config_test.rb`, `ComboboxBuilderTest` →
`ComboboxConfigTest`).

`Combobox::Config` keeps its public surface unchanged — `dropdown`, `typeahead`, `date`,
`time`, `selected?`, `renderer`, `options`, `metadata`, `render_panel`. Only the storage
calls beneath them change.

### Second target: the password proof consumer

The field-block work lands `Form::Fields::Inputs::Password::Builder < Plumber::Slots`.
Rename and reparent it the same way:

```
form/fields/inputs/password/builder.rb  →  password/config.rb
  class Builder < Plumber::Slots        →  class Config < Plumber::Config
  set_slot(:strength, options)          →  configure(:strength, options)
  resolve(:strength)                    →  config(:strength)
```

Plus its call site in `render_password_input`, and the test class name. Do this *after* that
work merges — not concurrently — so the two changes stay separately reviewable.

## Testing

- **The existing combobox tests must pass unedited.** That is the proof the migration is
  behaviour-preserving. If one needs changing, the migration is not mechanical and the design
  needs revisiting.
- New `test/stimulus_plumbers/plumber/config_test.rb` (`PlumberConfigTest`): `configure`
  stores and returns nil, `config` reads, `configured?` distinguishes an unset key from one
  set to `nil`, and a `Config` built without a template does not raise.
- Mutation-test the migration: break `configure` to a no-op and confirm an existing combobox
  test fails. A rename that no test notices is not covered.

## Docs

`docs/component/plumber.md` owns the Base / Renderer / Options / Slots explanation. The
`Slots` vs `Config` boundary is documented **there only** — the payload table and the
does-it-produce-markup test. Other docs link to it.

Also update: `docs/component/combobox.md`, and the folder trees in
`stimulus-plumbers-rails/CLAUDE.md` and the root `CLAUDE.md`. The two specs above already
name `Password::Config` and need no further change.

## Out of scope

- Changing `Plumber::Slots` itself. The seven content consumers are correct as they are.
- Migrating any `Slots` subclass to `Config`. All seven hold content.
- `Plumber::Base`, which is a renderer base and unrelated to either pattern.

## Noted, not acted on

`StimulusPlumbers.config` is the gem configuration, and `Themes::Configuration` exists, so
`Plumber::Config#config(key)` sits near two established uses of the word. Different
namespaces, no conflict, and the alternative reader name `configured(key)` reads worse beside
`configured?`. Keeping `config`.
