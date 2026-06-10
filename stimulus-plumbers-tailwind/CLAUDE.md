# Stimulus Plumbers Tailwind

## Folder Structure

```
stimulus-plumbers-tailwind/
├── lib/
│   ├── stimulus_plumbers_tailwind.rb       # Entry point: registers :tailwind theme
│   ├── stimulus_plumbers_tailwind/
│   │   ├── engine.rb                       # Rails::Engine — registers :tailwind theme on boot
│   │   └── version.rb
│   └── stimulus_plumbers/
│       └── themes/
│           ├── tailwind_theme.rb            # TailwindTheme < Base (includes component modules)
│           └── tailwind/
│               ├── control.rb              # Control::BASE — shared interactive foundation (required first)
│               ├── list.rb                  # List CSS classes
│               ├── avatar.rb               # Avatar CSS classes
│               ├── button.rb               # Button CSS classes
│               ├── calendar.rb             # Calendar CSS classes
│               ├── card.rb                 # Card CSS classes + Card::VARIANTS (--card-ring)
│               ├── combobox.rb             # Combobox CSS classes
│               ├── form.rb                 # Form CSS classes (form_group, form_submit, input_group)
│               ├── form/
│               │   ├── field.rb            # Form::Field — floating (form_field_floating*), label/hint/error/choice CSS classes
│               │   └── input.rb            # Form::Input — input/checkbox/radio/combobox/reveal/clearable CSS classes
│               ├── icon.rb                 # Icon CSS classes + ALIASES + Registry wiring
│               ├── icons/
│               │   ├── heroicon.rb         # Heroicons source (bundled SVGs or heroicons gem)
│               │   ├── custom.rb           # Custom icons from icons/customs/
│               │   ├── heroicons/          # Bundled heroicon SVGs (outline/ + solid/)
│               │   └── customs/            # Custom icon SVGs (e.g. spinner.svg)
│               └── layout.rb              # Layout CSS classes
├── test/
│   ├── stimulus_plumbers/
│   │   └── themes/
│   │       ├── tailwind_test.rb            # TailwindTheme integration tests
│   │       └── tailwind/                   # Per-module unit tests
│   │           ├── icons/                  # Unit tests for icon sources + registry
│   │           └── ...
│   ├── snapshots/                          # Playwright visual snapshot specs
│   ├── sandbox/                            # Minimal Rails app for snapshot tests
│   │   ├── app/views/                      # ERB views (components + form pages)
│   │   ├── config/                         # Routes, application, environment
│   │   ├── public/                         # Compiled tailwind.css output (gitignored)
│   │   └── tailwind.css                    # Tailwind CSS v4 source with @source directives
│   ├── support/
│   │   └── html_assertions.rb
│   └── test_helper.rb
├── Gemfile
├── package.json                            # Tailwind CLI + Playwright
├── playwright.config.js
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation and developer setup.

## Styling Guidelines
- **Always use CSS custom properties (CSS variables) instead of hardcoded values** — colors, spacing, sizing, and other design tokens must reference CSS variables (e.g., `var(--sp-color-primary)`) so consumers can theme the library without overriding classes.

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Snapshot tests** using Playwright (`npm run test:snapshots`); update baselines with `npm run test:snapshots:update`
- **Lint tests** using Rubocop (`rake rubocop`)
- **Snapshot tests must be a superset of `stimulus-plumbers-rails` a11y tests** — every page + interactive state covered by an a11y test must also have a corresponding snapshot test. When adding a11y tests in the core gem, add matching snapshot coverage here.

## Sandbox View Convention

Four rules for sandbox views and their matching snapshot specs:

1. **Section IDs** — `{component}-{usecase}`, unique across all pages. Encodes the render mode or variant directly in HTML (e.g. `calendar-stimulus`, `calendar-turbo`, `combobox-date-error`). Never reuse the same ID on different pages. Never use bare `{component}` alone (e.g. `id="card"` is wrong; `id="card-default"` is correct).
2. **In-section `<h2>`** — every `<section>` must open with an `<h2>` that names the usecase/variant. This makes screenshots self-documenting without referencing the URL. Example: `<h2>Turbo (SSR)</h2>`, `<h2>Filled — error</h2>`.
3. **Inner layout div** — after `<h2>`, all content must be wrapped in `<div class="sb-row">` or `<div class="sb-col">`. Never put layout classes (`sb-row`, `sb-col`) directly on `<section>`. No nested `<section>` inside another `<section>`.
4. **Screenshot filenames** — `{usecase}-{state}.png`, where `{usecase}` matches the section ID suffix. Example: `stimulus-month.png`, `date-error-open.png`. Bare `{state}.png` (e.g. `default.png`) is acceptable when the spec file already scopes to a single component with no ambiguity.

## Snapshot Test Convention

**Selector scoping:** Always scope element queries to a named container `#id` — use `page.locator("#container-id").getByRole(...)` not `page.getByRole(...)`. Sandbox views must give each component instance a unique `id`. This prevents ambiguity when multiple instances of the same component appear on a page.

**Stimulus target selection:** Use direct CSS `page.locator("#id [data-controller-target='name']")` rather than chained `.filter({ has: trigger })`.

**State coverage:** For each component variant:
- Static states (default, error, disabled): one screenshot per variant
- Interactive states (open/close, popover, dropdown): test both closed and open
- Error + interactive combined: cover both closed and open (e.g. `date-picker-error-closed.png` and `date-picker-error-open.png`)
- Behavioral transitions (focus restoration, clear button hide/show): test the end state after the interaction

## Unit Test Convention

**Naming:** `TailwindTheme<Module>Test` — e.g. `TailwindThemeFormTest`, `TailwindThemeButtonTest`.

**Pattern:** each test resolves `@theme.resolve(component, **args)[:classes]` and asserts specific Tailwind tokens with `assert_includes` / `refute_includes`.

**Coverage rule:** every resolver param that branches the output (`error:`, `variant:`, `size:`, `selected:`, `disabled:`, `hidden:`, `layout:`, `color:`, `type:`) needs both a positive assertion (`assert_includes`) and the corresponding negative case (`refute_includes` for the excluded class when the flag is off).

## Theme Architecture

`StimulusPlumbers::Themes::TailwindTheme` extends `StimulusPlumbers::Themes::Base` and is split into concern modules under `StimulusPlumbers::Themes::Tailwind::*`. Each module provides CSS class resolution for one component family. The `Icon` module also owns the icon registry (`icons/`) which lazily parses SVG files from the bundled heroicons set and a `customs/` directory.

### Constant ownership rules

- **No local aliases** — never re-export another module's constant (e.g. `MY_CONST = Other::CONST`). Always reference it directly at the call site.
- **No `TYPES`/`VARIANTS` prefix redundancy** — name constants after what they represent, not where they live. `Button::VARIANTS` not `Button::BUTTON_VARIANTS`; `Card::VARIANTS` not `Card::CARD_VARIANTS`.
- **Shared interactive foundation** — `Control::BASE` holds the CSS shared by all focusable, disableable controls (`font-medium`, `transition-colors`, focus ring tokens, `disabled:*`). Components add their ring color variable on top. Do not duplicate these classes in individual component constants.
- **Composition over duplication** — when a constant is a superset of existing constants, compose with array splat: `[*Control::BASE, *Card::BASE, *Button::CARD, "extra-class"].freeze`.

### Icon-only square pattern

The core gem wraps button/link text in `<span>`; icon-only renders no `<span>`. The theme detects this via CSS:

- `Button::LAYOUT` carries `[&:not(:has(>span))]:aspect-square [&:not(:has(>span))]:px-0` — applies to all non-card types. `fab`/`fab_outline` become circles.
- `Link::BUTTON` carries the same two classes. `type: :card` is unaffected (wide `flex-1` layout).

### Card style pattern

Button, link, checkbox, and radio all share a unified card style. Key rules:

- **`--card-ring` variable** — set by `Card::VARIANTS`, which maps `:default/:success/:destructive/:warning/:info` to the matching `--sp-color-*` value. Referenced by all card-type components via `Card::VARIANTS.fetch(variant, Card::VARIANTS[:default])`.
- **Button card** (`type: :card`) — `Button::BASE` + `Button::CARD` layout + `Button::VARIANTS` (sets `--btn-*` vars) + `Button::TYPES[:card]`; `size:` is ignored.
- **Link card** (`type: :card`) — `Link::CARD` composes `Control::BASE + Card::BASE + Button::CARD`; `Card::VARIANTS` sets `--card-ring`.
- **Checkbox card** (`type: :card`) — input visible; label uses `has-[:checked]:border-(--card-ring)`; `Card::VARIANTS` applied to both input and label. Checkbox `button` type does not use `--card-ring`.
- **Radio card/button** (`type: :card` or `type: :button`) — input is `hidden peer`; label uses `peer-checked:border-(--card-ring)`; `Card::VARIANTS` applied to both input and label for both types. The `variant:` param on `f.choice` selects the `Card::VARIANTS` entry.

### Floating field keys

Floating-label theme keys (`form_field_floating`, `form_field_floating_group`, `form_field_floating_label`) and their constants (`FLOATING_INPUT_*`, `FLOATING_GROUP_TYPES`, `FLOATING_LABEL_*`) live in `Form::Field` (`form/field.rb`), not `Form::Input`. Floating is a field-layout concern, not an input-element concern.

The theme is registered on load (via the Engine initializer in Rails, or directly otherwise):

```ruby
StimulusPlumbers.configure do |c|
  c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
end
```

Consumers activate it via:

```ruby
StimulusPlumbers.configure { |c| c.theme = :tailwind }
```
