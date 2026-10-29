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
│               ├── password_strength.rb    # PasswordStrength CSS classes (wrapper/rules_heading/rules/rule/level) — sibling of Form
│               ├── icon.rb                 # Icon CSS classes + ALIASES + Registry wiring
│               ├── icons/
│               │   ├── heroicon.rb         # Heroicons source (bundled SVGs or heroicons gem)
│               │   ├── custom.rb           # Custom icons from icons/customs/
│               │   ├── heroicons/          # Bundled heroicon SVGs (outline/ + solid/)
│               │   └── customs/            # Custom icon SVGs (e.g. spinner.svg)
│               ├── layout.rb              # Layout CSS classes
│               ├── link.rb                # Link CSS classes
│               ├── ordered_list.rb        # OrderedList CSS classes (reorderable list, drag handle)
│               ├── timeline.rb            # Timeline CSS classes
│               └── timeline/
│                   └── group.rb            # Timeline::Group CSS classes
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
│   ├── snapshots/                          # Playwright snapshot specs, nested by route category
│   │   └── __snapshots__/                  # Baselines: {form}/{device}/{os}/<spec path>/<name>.png
│   ├── browser/                            # Playwright browser specs, nested by route category
│   ├── sandbox/                            # Layout + Tailwind CSS over the core gem's sandbox app
│   │   ├── app/
│   │   │   ├── assets/
│   │   │   │   ├── stylesheets/
│   │   │   │   │   └── application.css     # Tailwind CSS v4 entry source (generator-owned imports)
│   │   │   │   └── builds/
│   │   │   │       └── stimulus_plumbers/
│   │   │   │           └── tailwind.css    # Generated gem @source partial (committed fixture)
│   │   │   └── views/layouts/              # Tailwind layout around the core sandbox's pages
│   │   ├── config/                         # Application, boot, and environments; routes come from the core sandbox
│   │   └── public/                         # Compiled tailwind.css output (gitignored)
│   ├── support/                            # Shared Minitest and Playwright helpers
│   └── test_helper.rb
├── Gemfile
├── package.json                            # Tailwind CLI + Playwright
├── playwright.base.js                      # Shared settings + device projects (desktop Chrome/Firefox/Safari, Pixel 10, iPhone 17)
├── playwright.snapshots.config.js
├── playwright.browser.config.js
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation and developer setup.
> See [docs/guide.md](docs/guide.md) for the setup/theming quick guide (source of truth for `stimulus-plumbers-mcp`'s `guide://tailwind`).

## Styling Guidelines
- **Always use CSS custom properties (CSS variables) instead of hardcoded values** — colors, spacing, sizing, and other design tokens must reference CSS variables (e.g., `var(--sp-color-primary)`) so consumers can theme the library without overriding classes.

> **Architecture decisions** (constant ownership, icon-only pattern, card style, floating fields) are documented in [docs/architecture.md](docs/architecture.md).

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`) — covers theme modules and generators
- **Snapshot tests** using Playwright (`node --run test:snapshots`) — screenshots and computed styles only. Before a screenshot, wait only on rendered state: `toBeVisible`, `toBeHidden`, `toHaveCSS`, a visible `waitForSelector()` / `waitFor()`, or `settled()` / `screenshotWithPanel()` from `test/support/playwright.js`.
- **Baselines**: committed baselines are Linux-only and regenerated by CI. On other platforms pixel comparison is skipped unless `SNAPSHOTS=compare`; `test:snapshots:update` writes local baselines under `*/*/darwin/` (gitignored), which a compare run needs first.
- **Browser tests** using Playwright (`node --run test:browser`) — engine-native behavior only (native `<dialog>`, Popover API, CSS anchor positioning); no screenshots. Logic → vitest; WCAG → Rails a11y
- **Devices**: both Playwright suites run every project in `playwright.base.js`; device and engine conditions are describe-level preconditions (`test.skip(({ isMobile }) => …)`), never project names or in-test branches; only feature checks (`CSS.supports`) skip at runtime. CI runs one job per browser engine, derived from these projects by `bin/browser-matrix`
- **Lint tests** using Rubocop (`rake rubocop`) — run synchronously from this gem's directory; never background or tail
- **Snapshot tests must be a superset of `stimulus-plumbers-rails` a11y tests** — every page + interactive state covered by an a11y test must also have a corresponding snapshot test. When adding a11y tests in the core gem, add matching snapshot coverage here.

## Visual Validation

Start the sandbox webserver (see `playwright.base.js`) to inspect rendered HTML before writing Playwright specs:

```sh
RAILS_ENV=test bundle exec puma test/sandbox/config.ru --bind tcp://127.0.0.1:4001
```

Routes: `/components/{controls,display,layout,popover,calendar,showcase}/{button,combobox,…}` and `/form/{floating_label,choices,field_error,…}` at `http://127.0.0.1:4001`.

**Never run `node --run test:snapshots:update` on Linux** — it overwrites the committed baselines, which are regenerated by running the CI snapshots workflow (`.github/workflows/ci-snapshots.yml`) with its `update_snapshots` input.

**`test/sandbox/app/assets/stylesheets/application.css`'s generator-owned imports (`@import tokens.css`, `@import builds/…/tailwind.css`) and the committed `test/sandbox/app/assets/builds/stimulus_plumbers/tailwind.css` partial must always match `stimulus_plumbers:tailwind:install`'s output** — `test/stimulus_plumbers/tailwind/sandbox_css_test.rb` enforces this. If it fails, regenerate with `STIMULUS_PLUMBERS_CSS_ENTRY=test/sandbox/app/assets/stylesheets/application.css bin/rails generate stimulus_plumbers:tailwind:install` and commit the diff — never hand-edit them.

## Sandbox View Convention

`test/sandbox` holds only the layout (Tailwind CSS) and the stylesheet build; the pages, controllers, models, and routes come from the core gem's sandbox — see "Sandbox Convention" in [stimulus-plumbers-rails/CLAUDE.md](../stimulus-plumbers-rails/CLAUDE.md). Edit pages there.

**Screenshot filenames** — `{usecase}-{state}.png`, where `{usecase}` matches the section ID suffix (`stimulus-month.png`, `date-error-open.png`). Bare `{state}.png` (`default.png`) is fine when the spec covers a single component.

## Snapshot Test Convention

**File placement:** one spec per route, path mirroring the URL — `/components/display/avatar` → `snapshots/components/display/avatar.spec.js`. Never cover two routes from one spec. Browser specs follow the same placement under `browser/`.

**Selector scoping:** Always scope element queries to a named container `#id` (snapshot and browser specs) — use `page.locator("#container-id").getByRole(...)` not `page.getByRole(...)`. Sandbox views must give each component instance a unique `id`. This prevents ambiguity when multiple instances of the same component appear on a page.

**Stimulus target selection:** Use direct CSS `page.locator("#id [data-controller-target='name']")` rather than chained `.filter({ has: trigger })`.

**State coverage:** For each component variant:
- Static states (default, error, disabled): one screenshot per variant
- Interactive states (open/close, popover, dropdown): test both closed and open
- Error + interactive combined: cover both closed and open (e.g. `date-error-closed.png` and `date-error-open.png`)
- Behavioral transitions (focus restoration, clear button hide/show): screenshot the end state after the interaction

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
