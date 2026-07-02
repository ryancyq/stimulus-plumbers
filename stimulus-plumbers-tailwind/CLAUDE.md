# Stimulus Plumbers Tailwind

## Folder Structure

```
stimulus-plumbers-tailwind/
├── lib/
│   ├── stimulus_plumbers_tailwind.rb       # Entry point: registers :tailwind theme
│   ├── generators/
│   │   └── stimulus_plumbers/
│   │       └── tailwind/
│   │           └── install/
│   │               └── install_generator.rb # `rails g stimulus_plumbers:tailwind:install` — injects @source into Tailwind entry CSS
│   ├── tasks/
│   │   └── stimulus_plumbers_tailwind.rake # Consumer rake task: install, hooked into assets:precompile + tailwindcss:build
│   └── stimulus_plumbers/
│       ├── tailwind/
│       │   ├── version.rb                  # StimulusPlumbers::Tailwind::VERSION
│       │   └── engine.rb                   # StimulusPlumbers::Tailwind::Engine < Rails::Engine — registers :tailwind theme on boot
│       └── themes/
│           ├── tailwind_theme.rb            # TailwindTheme < Base (includes component modules)
│           └── tailwind/
│               ├── control.rb              # Control::BASE — shared interactive foundation (required first)
│               ├── list.rb                  # List CSS classes
│               ├── avatar.rb               # Avatar CSS classes
│               ├── button.rb               # Button CSS classes
│               ├── button/
│               │   └── group.rb            # Button::Group CSS classes
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
│               ├── layout.rb              # Layout CSS classes
│               └── link.rb                # Link CSS classes
├── test/
│   ├── generators/
│   │   └── stimulus_plumbers_tailwind/
│   │       └── install_generator_test.rb   # Generator unit tests (Rails::Generators::TestCase)
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

> **Architecture decisions** (constant ownership, icon-only pattern, card style, floating fields) are documented in [docs/architecture.md](docs/architecture.md).

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`) — covers theme modules and generators
- **Snapshot tests** using Playwright (`node --run test:snapshots`)
- **Lint tests** using Rubocop (`rake rubocop`) — run synchronously from this gem's directory; never background or tail
- **Snapshot tests must be a superset of `stimulus-plumbers-rails` a11y tests** — every page + interactive state covered by an a11y test must also have a corresponding snapshot test. When adding a11y tests in the core gem, add matching snapshot coverage here.

## Visual Validation

Start the sandbox webserver (see `playwright.config.js`) to inspect rendered HTML before writing snapshot specs:

```sh
RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:4001
```

Routes: `/components/{button,combobox,calendar_stimulus,…}` and `/form/{floating_label,choices,field_error,…}` at `http://127.0.0.1:4001`.

**Never run `node --run test:snapshots:update`** — the user does this.

## Sandbox View Convention

**Icon naming:** Both the core and tailwind sandbox views must use generic icon names (e.g., `close`, `download`, `book`, `edit`, `email`), never heroicon-specific compound names (e.g., `x-mark`, `arrow-down-tray`, `book-open`, `pencil`, `envelope`). When a new generic name is needed, add a mapping to `Icon::ALIASES` in `lib/stimulus_plumbers/themes/tailwind/icon.rb`. Names that are already generic and need no alias: `arrow-right`, `arrow-left`, `check`, `bell`, `trash`, `plus`, `user`, `cog`, `folder`, `home`, `chevron-right`, `chart-bar`.

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

**Use-case rule:** tests assert visual/behavioral outcomes, not CSS implementation choices.

- **Test names** describe what the user sees or the layout behavior — never the CSS mechanism.
  - Bad: `test_track_uses_border_s`, `test_item_uses_ms_6_offset`
  - Good: `test_indicator_is_in_flow_not_absolute`, `test_dot_uses_neutral_not_primary_color`
- **Assert** semantic color tokens (`bg-(--sp-color-primary)`), visual properties (`font-semibold`, `text-sm`), and behavioral outcomes (`refute "absolute"` = in-flow, `assert "ring-4"` = halo).
- **Don't assert** spacing/offset magic numbers (`mt-1.5`, `start-3`, `ms-6`, `pb-10`) or layout mechanism choices (`flex-1`, `relative`, `absolute`) — these express *how*, not *what*.
- Exception: `refute_includes result, "absolute"` is a valid use-case assertion when the intent is "element is in normal flow".

## Generator Test Convention

**Class:** `Rails::Generators::TestCase` with `tests`, `destination`, and `setup :prepare_destination`.

**Pattern:** create CSS fixtures in `destination_root` via a `write_entry_css` helper, run the generator, then `assert_file` the modified content.

**Coverage rule:** every branch in `install` needs a test — in execution order: identical (no-op, already current), update (stale gem path), insert (after `@import`), append (no `@import`), and the no-entry-file fallback. Entry file detection also needs tests: first candidate, each fallback candidate, `TAILWIND_CSS_FILE` override (existing file), and `TAILWIND_CSS_FILE` pointing to a non-existent file (falls through to candidates).

**Idempotency logic:** the generator uses two-stage detection — `content.include?(source_line)` for an exact match (handles re-runs on the same machine), then a `GEM_NAME` regex for stale paths from old versions. Tests for idempotency count total `@source` occurrences (`css.scan("@source").length`) rather than filtering by gem name, so they work regardless of whether the path uses underscores (installed gem) or hyphens (dev path gem).

## Theme Registration

The Engine initializer registers and activates the theme automatically in Rails. Outside Rails, call directly:

```ruby
StimulusPlumbers.configure do |config|
  config.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
  config.theme.use(:tailwind)
end
```
