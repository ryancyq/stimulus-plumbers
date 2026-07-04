# Rails Package Architecture

## Schema Ranges Convention

Validation ranges for theme schema params live under `lib/stimulus_plumbers/themes/schema/`.

**Where ranges live — the branching rule:**

- If a component branches on the values internally (e.g. `when *FLOATING_TYPES`), the component owns the constant (`Form::Field::FLOATING_TYPES`). The schema references it directly — no alias.
- If the component only passes the value through to the theme, the schema owns the range (e.g. `Schema::Button::Ranges::TYPE`).

**Namespaces:**

- `Schema::Ranges` — cross-cutting constants (e.g. `BOOL`)
- `Schema::<Component>::Ranges` — per-component constants
- `Schema::Link::Ranges` — link-specific; uses `:default` as base instead of `:primary`
- `Schema::Form::<Input>::Ranges` — per-input-type constants
- `Schema::Form::Ranges` — form-level ranges (`LAYOUT`, `VARIANT`)

**Guidelines:**

- **No local aliases** — never re-export another module's constant inside a `Ranges` module.
- **Remove unused constants** — don't keep range constants with no call sites in `schema.rb`.

## Icon-Only Detection Contract (Button + Link)

`Button#build_button` and `Link#build_content` always wrap non-nil text/block content in `<span>`. When content is nil and no block is given (icon-only), no `<span>` is rendered.

The active theme uses `:has(> span)` / `:not(:has(> span))` CSS to distinguish icon-only from text buttons without any Ruby flag.

**Do not change this contract** without updating `stimulus-plumbers-tailwind`'s `Button::LAYOUT` and `Link::BUTTON` constants accordingly. See [tailwind architecture doc](../../stimulus-plumbers-tailwind/docs/architecture.md#icon-only-square-pattern).
