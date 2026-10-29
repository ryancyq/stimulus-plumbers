# Stimulus Plumbers Rails

## Folder Structure

```
stimulus-plumbers-rails/
├── lib/
│   └── stimulus_plumbers/
│       ├── components/
│       │   ├── avatar.rb                 # sp_avatar renderer
│       │   ├── button.rb                 # sp_button renderer
│       │   ├── button/
│       │   │   ├── group.rb
│       │   │   ├── icon_layout.rb        # Shared leading/trailing icon layout — included by Button and Form::Fields::Inputs::Submit
│       │   │   └── slots.rb
│       │   ├── calendar.rb               # sp_calendar root: settings and availability values, status region; navigation: picks the body
│       │   ├── calendar/
│       │   │   ├── configuration.rb      # Calendar::Configuration — displayed/view/selected/today and display options
│       │   │   ├── stimulus.rb           # navigation: :stimulus — label-free header, empty grid, themed cell templates
│       │   │   ├── stimulus/
│       │   │   │   └── header.rb         # Previous/next and zoom buttons, empty heading
│       │   │   ├── turbo.rb              # navigation: :turbo — period in a Turbo Frame, link builder
│       │   │   └── turbo/
│       │   │       ├── header.rb         # Previous/next links, labelling heading, zoom-out link
│       │   │       ├── grid.rb           # Base grid: table, one Tab stop, cell controls
│       │   │       ├── days_of_month.rb  # Days (buttons); weekday headers from first_day_of_week
│       │   │       ├── months_of_year.rb # Months (links that zoom in)
│       │   │       └── years_of_decade.rb # Years (links that zoom in)
│       │   ├── card.rb                   # sp_card renderer
│       │   ├── card/
│       │   │   └── slots.rb
│       │   ├── combobox.rb               # `combobox` controller markup: root + Trigger + hidden input + Panel; Dropdown and Typeahead subclass it
│       │   ├── combobox/
│       │   │   ├── trigger.rb            # Trigger (the role=combobox element) inside its TriggerGroup; the block renders the <button> or <input>
│       │   │   ├── trigger_group.rb      # InputGroup around a combobox trigger with decorative leading/trailing icons
│       │   │   ├── listbox.rb            # Popup <ul role=listbox>; option and group ids derive from its id
│       │   │   ├── panel.rb              # Manual popover panel; the block renders its content
│       │   │   ├── dropdown.rb           # Select-only component behind sp_combobox_dropdown — Combobox subclass with a <button>
│       │   │   ├── typeahead.rb          # Editable component behind sp_combobox_typeahead — Combobox subclass with an <input> and status (value_policy, match, min_length, source, param)
│       │   │   ├── turbo.rb              # Combobox::Turbo — source: listbox in a Turbo Frame that combobox-turbo reloads
│       │   │   ├── temporal.rb           # Base for Date/Time: popover + <controller> + input-formatter root, read-only trigger, hidden input, role=dialog panel; `format:` locale default
│       │   │   ├── temporal/             # Inside Date/Time a bare `Trigger` is Combobox::Trigger; write Temporal::Trigger
│       │   │   │   └── trigger.rb        # Read-only role=combobox input in a TriggerGroup; opens the popover
│       │   │   ├── date.rb               # sp_combobox_date < Temporal: panel holds sp_calendar
│       │   │   ├── time.rb               # sp_combobox_time < Temporal: panel holds hour/minute/meridiem listbox columns; `step:`, hourCycle default h12
│       │   │   ├── options.rb            # Option list renderer — option/group IDs from id_prefix; #label_for finds a value's label
│       │   │   ├── options/
│       │   │   │   ├── option.rb
│       │   │   │   └── option_group.rb
│       │   ├── divider.rb                # sp_divider renderer
│       │   ├── icon.rb                   # Icon component (SVG or span fallback)
│       │   ├── input_group.rb            # InputGroup wrapper (input + adornment)
│       │   ├── link.rb                   # sp_link renderer
│       │   ├── link/
│       │   │   └── slots.rb
│       │   ├── list.rb                   # sp_list renderer
│       │   ├── list/
│       │   │   ├── item.rb
│       │   │   ├── item/
│       │   │   │   └── slots.rb
│       │   │   └── section.rb
│       │   ├── ordered_list.rb           # sp_ordered_list renderer (reorderable JS controller-backed)
│       │   ├── ordered_list/
│       │   │   ├── item.rb
│       │   │   └── item/
│       │   │       └── slots.rb
│       │   ├── password_strength.rb     # Component: meter, level, rules checklist rendering
│       │   ├── popover.rb                # sp_popover renderer; render (with wrapper) / build (without wrapper)
│       │   ├── popover/
│       │   │   ├── trigger.rb            # Renders wired <button> (popover trigger primitive)
│       │   │   └── panel.rb              # Hidden panel element — #render (wired element) / #build (yields panel_attrs for caller to wire)
│       │   ├── modal.rb                  # sp_modal renderer; trigger and native dialog slots
│       │   ├── modal/
│       │   │   ├── turbo.rb               # sp_modal_turbo renderer; Turbo Frame adapter for modal
│       │   │   ├── slots.rb              # Modal builder slots and action buttons
│       │   │   └── trigger.rb            # Packaged/custom modal trigger rendering
│       │   ├── timeline.rb               # sp_timeline renderer
│       │   └── timeline/
│       │       ├── event.rb              # Timeline::Event — renders <li> with indicator, time, heading, description, detail, actions
│       │       └── event/
│       │           └── slots.rb          # Timeline::Event::Slots — DSL with short-name setters (indicator/time/title/trigger/description/detail/actions)
│       ├── helpers/
│       │   ├── avatar_helper.rb          # sp_avatar
│       │   ├── button_helper.rb          # sp_button, sp_button_group
│       │   ├── calendar_helper.rb        # sp_calendar
│       │   ├── card_helper.rb            # sp_card
│       │   ├── combobox_helper.rb        # sp_combobox_dropdown / sp_combobox_typeahead → Combobox::Dropdown / Typeahead; sp_combobox_date / sp_combobox_time → Combobox::Date / Time
│       │   ├── divider_helper.rb         # sp_divider
│       │   ├── icon_helper.rb            # sp_icon
│       │   ├── link_helper.rb            # sp_link
│       │   ├── list_helper.rb            # sp_list
│       │   ├── ordered_list_helper.rb    # sp_ordered_list
│       │   ├── plumber_helper.rb         # sp_dom_id
│       │   ├── popover_helper.rb         # sp_popover
│       │   ├── modal_helper.rb           # sp_modal, sp_modal_turbo, sp_modal_link_to
│       │   └── timeline_helper.rb        # sp_timeline
│       ├── form/
│       │   ├── builder.rb                # Form builder: f.field/collection_field/choice — dispatches via Fields::Renderer::FIELD/COLLECTION/CHOICE
│       │   ├── base.rb                   # Form::Base — shared init, error?, described_by, render_hint/errors
│       │   ├── field.rb                  # Form::Field < Base — label + input + hint + error; TYPES, COLLECTION_TYPES, hide_label, LABEL_MODES
│       │   └── fields/
│       │       ├── renderer.rb           # FIELD/COLLECTION/CHOICE type → render method maps + LABEL_MODE (caption association per type)
│       │       ├── error.rb
│       │       ├── fieldset.rb
│       │       ├── group.rb
│       │       ├── hint.rb
│       │       ├── label.rb
│       │       ├── label/
│       │       │   └── floating.rb       # Fields::Label::Floating — wrapper div + block-captured input before label; used by render_floating_field
│       │       └── inputs/
│       │           ├── checkbox.rb       # check_box, collection_check_boxes (native); render_check_box, render_collection_check_box
│       │           ├── combobox.rb       # Shared render_combobox — field name, label id, trigger aria + theme into Combobox::Dropdown, Typeahead, Date, or Time
│       │           ├── radio.rb          # radio_button, collection_radio_buttons (native); render_collection_radio_button
│       │           ├── datetime.rb       # date_field, time_field (native); render_combobox_date / render_combobox_time via render_combobox
│       │           ├── file.rb           # file_field (native); render_file_input
│       │           ├── password.rb       # password_field + reveal: (native); render_password_input — includes Revealable + Strength
│       │           ├── password/
│       │           │   ├── revealable.rb # Password::Revealable — reveal toggle: input group, button, icon pair
│       │           │   └── strength.rb   # Thin strength wiring (input attrs + delegates to Components::PasswordStrength)
│       │           ├── range.rb          # range_field (native); render_range_input — track/thumb visuals + optional readout
│       │           ├── search.rb         # search_field + clearable: (native); render_combobox_typeahead
│       │           ├── select.rb         # select, collection_select (native); render_combobox_dropdown, render_collection/grouped_combobox_dropdown
│       │           ├── select/
│       │           │   ├── grouped.rb    # grouped_collection_select (native); build_grouped_choices
│       │           │   ├── timezone.rb   # time_zone_select (native)
│       │           │   └── weekday.rb    # weekday_select (native, Rails 7.1+)
│       │           ├── submit.rb         # submit
│       │           ├── text.rb           # text/email/url/tel/number/color/month/week/datetime_local_field (native + render_*_input per type)
│       │           └── text_area.rb      # text_area (native); render_text_area_input
│       ├── plumber/
│       │   ├── base.rb                   # Plumber::Base (template accessor; includes Options::Html and Options::Aria)
│       │   ├── dispatcher.rb             # Dispatcher for block-based component DSL
│       │   ├── dispatcher/
│       │   │   ├── callable_inspector.rb
│       │   │   ├── instance_exec.rb
│       │   │   ├── klass_proxy.rb
│       │   │   └── method_call.rb
│       │   ├── options/
│       │   │   ├── aria.rb               # Options::Aria — labelled_aria helper (label vs labelledby)
│       │   │   ├── choice.rb             # Options::Choice — validate_choice! for one-of options
│       │   │   ├── html.rb               # Options::Html — merge_html_options (composes Theme + Stimulus)
│       │   │   ├── stimulus.rb           # Options::Stimulus — merge_stimulus_data (space-joins controller/action)
│       │   │   ├── theme.rb              # Options::Theme — extract_classes, theme key resolution
│       │   │   └── token_list.rb         # Options::TokenList — merge_token_list
│       │   ├── renderer.rb               # Plumber::Renderer — renders macro + renderers class attribute
│       │   └── slots.rb                  # Plumber::Slots — content slot DSL (private set_slot; public resolve/options_for)
│       ├── themes/
│       │   ├── base.rb                   # Base theme (no-op default)
│       │   ├── configuration.rb          # Theme registry
│       │   ├── schema.rb                 # Theme key schema
│       │   ├── schema/
│       │   │   ├── icon.rb
│       │   │   ├── ranges.rb
│       │   │   ├── avatar/
│       │   │   │   └── ranges.rb
│       │   │   ├── button/
│       │   │   │   └── ranges.rb
│       │   │   ├── card/
│       │   │   │   └── ranges.rb
│       │   │   ├── link/
│       │   │   │   └── ranges.rb
│       │   │   └── form/
│       │   │       ├── ranges.rb
│       │   │       ├── checkbox/
│       │   │       │   └── ranges.rb
│       │   │       └── radio/
│       │   │           └── ranges.rb
│       │   └── icons/
│       │       ├── external.rb           # SVG file parser (include into any icon source module)
│       │       └── registry.rb           # Lazy-loading Registry < SimpleDelegator (source-injected)
│       ├── dates.rb                      # Dates.parse_key — YYYY-MM-DD date keys
│       ├── dates/
│       │   └── availability.rb           # Dates::Availability — min/max/disabled_* the date fields offer; invalid options raise
│       ├── password/
│       │   └── requirements.rb           # Password::Requirements — rule DSL + evaluate/valid?/to_stimulus (server + client source of truth)
│       ├── password_strength_validator.rb # Top-level PasswordStrengthValidator (ActiveModel::EachValidator)
│       ├── configuration.rb
│       ├── engine.rb
│       ├── logger.rb
│       └── version.rb
├── test/
│   ├── stimulus_plumbers/
│   │   ├── components/                   # Unit tests per component
│   │   ├── dates/                        # Dates::Availability against the JS date fixtures
│   │   ├── helpers/                      # Helper-level HTML output tests
│   │   ├── form/                         # Form builder + field tests
│   │   ├── plumber/                      # Plumber base class tests
│   │   └── themes/                       # Theme schema + base tests
│   ├── accessibility/                    # Accessibility tests (axe-core via Capybara)
│   │   ├── components/                   # Nested by route category
│   │   └── form/
│   ├── sandbox/                          # The one sandbox app (a11y tests here; Tailwind Playwright specs via its layout)
│   ├── support/                          # Shared test helpers (HtmlAssertions, StubTheme, DateFixtures)
│   └── test_helper.rb
├── docs/
│   ├── analysis/                         # Design analysis documents
│   └── component/                        # Per-component HTML structure + wiring docs
├── gemfiles/                             # Appraisal-generated gemfiles (rails 6.1–edge)
├── Gemfile
├── Rakefile
└── *.gemspec
```

> See [README.md](README.md) for installation, usage examples, and developer setup.
> See [docs/guide.md](docs/guide.md) for the forms/views usage guide (source of truth for `stimulus-plumbers-mcp`'s `guide://component`).

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Accessibility tests** using Capybara + axe-core (`rake test:accessibility`)
- **Lint tests** using Rubocop (`rake rubocop`) — run synchronously from this gem's directory; never background or tail

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

**File placement:** test path mirrors the URL it visits — `/components/display/avatar` → `accessibility/components/display/avatar_accessibility_test.rb`. Class names stay flat (`AvatarAccessibilityTest`).

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
> Key internal docs: `plumber.md` (Base / Renderer / Options::Html / Slots), `dispatcher.md` (Dispatcher strategies), `form.md` (two-level field API).

> See [docs/architecture.md](docs/architecture.md) for schema ranges convention and icon-only detection contract.

## Stimulus Wiring Convention

- **`STIMULUS_CONTROLLER` constant:** declare one when the controller identifier is referenced more than once, or is composed by another component's wiring (e.g. `Combobox::Temporal` reuses `popover`). A single-use inline literal (`controller: "password-strength"`) is fine — don't manufacture a constant for one call site.
- **Stimulus values:** pass individual typed values for a small fixed set chosen by state (e.g. reveal's `reveal_label_value` / `conceal_label_value`). Use one `Object`/JSON value only when the consumer looks it up by dynamic key (e.g. strength's `labels_value`, read as `labelsValue[level]`). Don't wrap a two-label pair in JSON.
- **`data-action` targets:** follow "`onX(event)` adapts, `x(value)` computes" in [stimulus-plumbers/CLAUDE.md](../stimulus-plumbers/CLAUDE.md); `stimulus_contract_test.rb` diffs every wired action against the JS manifest.

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure, form builder keywords), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
