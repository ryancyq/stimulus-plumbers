# Tailwind Theme Architecture

## Module Layout

`TailwindTheme` extends `Base` and is split into concern modules under `StimulusPlumbers::Themes::Tailwind::*`. Each module provides CSS class resolution for one component family. The `Icon` module also owns the icon registry (`icons/`).

## Constant Ownership Rules

- **No local aliases** — never re-export another module's constant (e.g. `MY_CONST = Other::CONST`). Reference the constant directly at the call site.
- **No prefix redundancy** — name constants after what they represent, not where they live. `Button::VARIANTS` not `Button::BUTTON_VARIANTS`; `Card::VARIANTS` not `Card::CARD_VARIANTS`.
- **Remove unused constants** — if a constant has no call sites in `schema.rb`, delete it.

## Shared Interactive Foundation — `Control::BASE`

`Control::BASE` holds CSS shared by all focusable, disableable controls: font weight, transition, focus ring tokens, `disabled:*` states. Components include it via array splat and add their own ring color variable on top.

```ruby
# Composition — correct
[*Control::BASE, *Button::BASE, "extra-class"].freeze

# Duplication — wrong
["font-medium", "transition-colors", "extra-class"].freeze
```

`Control::BASE` is always included first; never duplicate its classes in component constants.

## Icon-Only Square Pattern

The core gem wraps button/link text in `<span>`. Icon-only renders no `<span>`. The theme detects this via CSS:

- `Button::LAYOUT` carries `[&:not(:has(>span))]:aspect-square [&:not(:has(>span))]:px-0`
- `Link::BUTTON` carries the same two classes
- `fab`/`fab_outline` types become circles via this mechanism

**Do not change the Ruby renderer's `<span>` wrapping contract without updating these theme constants.**

## Card Style Pattern

Button, Link, Checkbox, and Radio all share a unified card style via the `--card-ring` CSS variable.

- `Card::VARIANTS` maps `:default/:success/:destructive/:warning/:info` to `--sp-color-*` values
- All card-type components reference `Card::VARIANTS.fetch(variant, Card::VARIANTS[:default])`
- **Button card** (`type: :card`) — `Button::BASE + Button::CARD + Button::TYPES[:card]`; `size:` ignored
- **Link card** — `Link::CARD` composes `Control::BASE + Card::BASE + Button::CARD`
- **Checkbox card** — input visible; label uses `has-[:checked]:border-(--card-ring)`
- **Radio card/button** — input is `hidden peer`; label uses `peer-checked:border-(--card-ring)`

## Floating Field Key Ownership

Floating-label theme keys (`form_field_floating`, `form_field_floating_group`, `form_field_floating_label`) and their constants (`FLOATING_INPUT_*`, `FLOATING_GROUP_TYPES`, `FLOATING_LABEL_*`) live in `Form::Field` (`form/field.rb`), **not** `Form::Input`. Floating is a field-layout concern, not an input-element concern.
