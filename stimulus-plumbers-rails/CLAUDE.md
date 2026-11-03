# Stimulus Plumbers Rails

## Folder Structure

```
stimulus-plumbers-rails/
├── lib/
│   ├── stimulus_plumbers.rb              # Top-level require
│   ├── stimulus_plumbers/
│   │   ├── components/                   # <name>.rb renderer per component; <name>/ holds its parts (slots.rb, sub-elements, views)
│   │   ├── helpers/                      # <name>_helper.rb — the sp_* view helpers
│   │   ├── form/                         # Form builder: builder.rb dispatches through fields/renderer.rb
│   │   │   └── fields/                   # Field parts and the type renderer; inputs/<type>.rb per input family
│   │   ├── plumber/                      # Shared base classes; options/ holds the option mixins; Base includes the merging ones
│   │   ├── themes/                       # Base theme, registry, key schema (schema/<component>/ ranges), icons/
│   │   ├── dates/                        # Dates::Availability — the dates a date field offers; dates.rb parses date keys
│   │   ├── times/                        # Times::Availability — the times a time field offers; times.rb parses time keys
│   │   ├── password/                     # Password::Requirements — server and client rule source of truth
│   │   ├── generators/                   # Install generator helpers
│   │   └── *.rb                          # Engine, configuration, and other top-level support
│   ├── generators/                       # rails g stimulus_plumbers:install
│   └── tasks/                            # Consumer rake tasks
├── app/assets/                           # stylesheets/stimulus_plumbers/tokens.css; javascripts/ receives the JS build at release
├── config/locales/en.yml                 # Every default string
├── test/
│   ├── stimulus_plumbers/                # Unit tests mirroring lib/stimulus_plumbers/, plus parity, contract, tasks, and themes/base/ tests
│   ├── accessibility/                    # <url>_accessibility_test.rb, nested by route; application_accessibility_test_case.rb
│   ├── sandbox/                          # The one sandbox app (see "Sandbox Convention")
│   ├── generators/                       # Install generator tests
│   ├── tasks/                            # Rake-task support tests
│   ├── support/                          # Shared test helpers
│   └── test_helper.rb
├── bin/                                  # Version bump helper used by bin/release
├── tasks/                                # Gem-dev rake tasks
├── docs/                                 # component/<name>.md — one per helper or subsystem; guide.md, architecture.md
├── gemfiles/                             # Appraisal-generated gemfiles
└── vendor/                               # Build output (gitignored): controller/ and ARIA.md at release; component/manifest.json before every test:unit
```

> See [README.md](README.md) for installation, usage examples, and developer setup.
> See [docs/guide.md](docs/guide.md) for the forms/views usage guide (source of truth for `stimulus-plumbers-mcp`'s `guide://component`).

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Accessibility tests** using Capybara + Cuprite + axe-core (`rake test:accessibility`) — axe per page and state plus one keyboard/focus happy path per interaction; logic edge cases belong to their owning layer (root CLAUDE.md "Testing")
- **Lint tests** using Rubocop (`rake rubocop`) — run synchronously from this gem's directory; never background or tail
- **Constant lookup** — inside `Combobox::Date` / `Combobox::Time` a bare `Trigger` resolves to `Combobox::Trigger`; write `Temporal::Trigger`

## Unit Test Convention

**Naming:** class name is CamelCase of the path under `test/stimulus_plumbers/`, with the `components/` segment dropped for component tests:
- `components/button/group_test.rb` → `ButtonGroupTest`
- `form/fields/inputs/text_test.rb` → `FormFieldsTextTest`
- `form/builder_test.rb` → `FormBuilderTest`

**Component tests** assert HTML structure and ARIA — not CSS classes (those belong in the tailwind gem). Cover all constructor options that branch the output (`type:`, `variant:`, `size:`, `hidden:`, `tag:`), and any delegation/convenience methods.

**Form field unit tests** cover both builder levels:
- Native override (`email_field`, `text_area`, …) — element type and forwarded HTML attributes
- Full-field wrapper (`f.field(as:)`) — label (explicit **and** the `human_attribute_name` default), hint, error message, `aria-invalid`, `aria-describedby`, `required`, `hide_label`, all floating variants (`:floating_filled`, `:floating_outlined`, `:floating_standard`), and combined hint+error `aria-describedby`
- When `error:` override is set, assert the override message appears **and** model errors are suppressed

## I18n / Locale Convention

**Never use `I18n.t(...)` in tests.** Assert the actual English string literal. Tests pin the rendered output — they must fail when a string changes, which `I18n.t(...)` would hide. If you need to reference a locale string in a test, copy the value from `config/locales/en.yml` as a plain string.

```ruby
# good
assert_css doc, "button[aria-label='Previous month']"
find("button[aria-label='Next month']").click

# bad — hides regressions if the locale key or value changes
assert_css doc, "button[aria-label='#{I18n.t("stimulus_plumbers.calendar.previous_month")}']"
```

This applies to all test types: unit tests, helper tests, and accessibility tests.

## Accessibility Test Convention

**File placement:** at the path root CLAUDE.md "Testing" gives (`accessibility/components/display/avatar_accessibility_test.rb`). Class names stay flat (`AvatarAccessibilityTest`).

Scope axe to a sandbox section or a component inside one, never the bare page: `assert_accessible context: "#combobox-date"` for a section, `context: "#calendar-month"` for a component; each section gets its own test. A context that matches nothing fails the test.

- For interactive states (e.g. a dialog opens), test closed and open separately; use `find(...).click` before `assert_accessible`
- For multi-view pages (e.g. calendar month/year/decade), use a controller query param (`?view=month`) to expose each view unhidden

## Sandbox Convention

`test/sandbox` is the one sandbox app for every suite: Rails a11y tests run it directly, and the Tailwind sandbox reuses its controllers, models, routes, and views behind its own layout. A page change here is a change to both suites.

- **Views** stay flat (`app/views/components/avatar.html.erb`); only routes and tests carry the category.
- **Sections** — every use case is a `<section id="{component}-{usecase}" class="sb-section">`, the ID unique across all pages and never a bare `{component}` (`card-default`, not `card`). It opens with an `<h2>` naming the use case, then wraps its content in one `<div class="sb-row">` or `<div class="sb-col">`; no layout classes on `<section>`, no nested sections. State variants (error, required, open) get their own section so a test can scope to that state alone.
- **Panels** render inline (not portaled), so the section always contains its open panel.
- **Icons** use generic names (`close`, `download`, `book`), never heroicon compound names (`x-mark`, `arrow-down-tray`); the core sandbox runs without a theme, and the Tailwind theme maps generic names in `Icon::ALIASES`.
- **Models** — one model per use case (`SignUp`, `SignIn`, `Preferences`, `Verification`, `Payment`, `Search`), never one grab-bag fixture. A view binds only attributes its model declares: `form_with` defaults to `allow_method_names_outside_object: true`, so an undeclared attribute renders `nil` instead of raising.

## Form Builder Convention

> See [docs/component/form.md](docs/component/form.md) for the two-level builder API (Level 1 native overrides, Level 2 full-field helpers, shared field options, rendered HTML structure).

- **New field type:** add it to `Fields::Renderer::FIELD` and `LABEL_MODE`. Use `:native` for labelable elements and `:aria` otherwise.

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Renderers in this package own the HTML structure and ARIA attributes for all components.

## Component Architecture

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Key subsystem docs: `plumber.md` (internal: Base / Renderer / Options::Html / Slots), `dispatcher.md` (internal: Dispatcher strategies), `form.md` (consumer: two-level field API).

> See [docs/architecture.md](docs/architecture.md) for schema ranges convention and icon-only detection contract.

## Stimulus Wiring Convention

- **`STIMULUS_CONTROLLER` constant:** declare one when the controller identifier is referenced more than once, or is composed by another component's wiring (e.g. `Combobox::Temporal` reuses `popover`). A single-use inline literal (`controller: "password-strength"`) is fine — don't manufacture a constant for one call site.
- **Stimulus values:** pass individual typed values for a small fixed set chosen by state (e.g. reveal's `reveal_label_value` / `conceal_label_value`). Use one `Object`/JSON value only when the consumer looks it up by dynamic key (e.g. strength's `labels_value`, read as `labelsValue[level]`). Don't wrap a two-label pair in JSON.
- **`data-action` targets:** follow "`onX(event)` adapts, `x(value)` computes" in [stimulus-plumbers/CLAUDE.md](../stimulus-plumbers/CLAUDE.md); `stimulus_contract_test.rb` diffs every wired action against the JS manifest.

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure, form builder keywords), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
