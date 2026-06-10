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
│       │   │   └── slots.rb
│       │   ├── calendar.rb               # sp_calendar_month renderer
│       │   ├── calendar/month/turbo.rb   # Turbo-compatible calendar grid
│       │   ├── calendar/month/turbo/
│       │   │   ├── days_of_month.rb
│       │   │   └── days_of_week.rb
│       │   ├── card.rb                   # sp_card renderer
│       │   ├── card/
│       │   │   └── slots.rb
│       │   ├── combobox.rb               # Shared wrapper: input-combobox + input-formatter; drives p.build_panel, threads haspopup/popup_id
│       │   ├── combobox/
│       │   │   ├── typeahead.rb          # combobox-dropdown body — panel is a wrapper; <ul role=listbox> of options + loading/empty status siblings beside it
│       │   │   ├── date.rb               # combobox-date picker body — panel IS the role=dialog (hosts the controller)
│       │   │   ├── dropdown.rb           # combobox-dropdown body — panel IS the <ul role=listbox>; options only
│       │   │   ├── options.rb            # Option list renderer
│       │   │   ├── options/
│       │   │   │   ├── option.rb
│       │   │   │   └── option_group.rb
│       │   │   ├── time.rb               # combobox-time drum picker body — panel IS the role=dialog (hosts the controller)
│       │   │   ├── time/
│       │   │   │   └── drum.rb           # Single drum column renderer
│       │   │   ├── trigger.rb            # Combobox trigger input (<input role="combobox">)
│       │   │   └── variant.rb            # Immutable popup metadata per variant (haspopup, panel_class, popup_id_suffix, default_opts)
│       │   │   ├── date/
│       │   │   │   ├── navigation.rb     # Date picker navigation bar (prev/next + view-title buttons)
│       │   │   │   └── navigator.rb      # Individual nav button (wraps Button with ghost variant)
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
│       │   ├── popover.rb                # sp_popover renderer; render (with wrapper) / build (without wrapper)
│       │   └── popover/
│       │       ├── builder.rb            # Builder DSL: p.trigger / p.panel (auto-wired) / p.build_panel (caller-wired) — yielded by render/build
│       │       ├── trigger.rb            # Renders wired <button> (popover trigger primitive)
│       │       └── panel.rb              # Hidden panel element — #render (wired element) / #build (yields panel_attrs for caller to wire)
│       ├── helpers/
│       │   ├── avatar_helper.rb          # sp_avatar
│       │   ├── button_helper.rb          # sp_button, sp_button_group
│       │   ├── calendar_helper.rb        # sp_calendar_month
│       │   ├── calendar_turbo_helper.rb  # sp_calendar_turbo, sp_calendar_turbo_month/year/decade
│       │   ├── card_helper.rb            # sp_card
│       │   ├── combobox_helper.rb        # sp_combobox_date/time/dropdown/typeahead
│       │   ├── divider_helper.rb         # sp_divider
│       │   ├── icon_helper.rb            # sp_icon
│       │   ├── link_helper.rb            # sp_link
│       │   ├── list_helper.rb            # sp_list
│       │   ├── plumber_helper.rb         # sp_dom_id
│       │   └── popover_helper.rb         # sp_popover
│       ├── form/
│       │   ├── builder.rb                # Form builder: FIELD_RENDERER/COLLECTION_FIELD_RENDERER/CHOICE_RENDERER constants + f.field/collection_field/choice
│       │   ├── base.rb                   # Form::Base — shared init, error?, described_by, render_hint/errors
│       │   ├── field.rb                  # Form::Field < Base — label + input + hint + error; TYPES, COLLECTION_TYPES, VARIANTS, hide_label
│       │   └── fields/
│       │       ├── error.rb
│       │       ├── fieldset.rb
│       │       ├── group.rb
│       │       ├── hint.rb
│       │       ├── label.rb
│       │       ├── label/
│       │       │   └── floating.rb       # Fields::Label::Floating — wrapper div + block-captured input before label; used by render_floating_field
│       │       └── inputs/
│       │           ├── checkbox.rb       # check_box, collection_check_boxes (native); render_check_box, render_collection_check_box
│       │           ├── combobox.rb       # Shared render_combobox — wires variant, panel_id, aria into Components::Combobox
│       │           ├── radio.rb          # radio_button, collection_radio_buttons (native); render_collection_radio_button
│       │           ├── datetime.rb       # date_field, time_field (native); render_combobox_date, render_combobox_time
│       │           ├── file.rb           # file_field (native); render_file_input
│       │           ├── password.rb       # password_field + reveal: (native); render_password_input
│       │           ├── search.rb         # search_field + clearable: (native); render_combobox_typeahead
│       │           ├── select.rb         # select, collection_select (native); render_combobox_dropdown, render_collection/grouped_combobox_dropdown
│       │           ├── select/
│       │           │   ├── grouped.rb    # grouped_collection_select (native); build_grouped_choices
│       │           │   ├── timezone.rb   # time_zone_select (native)
│       │           │   └── weekday.rb    # weekday_select (native, Rails 7.1+)
│       │           ├── submit.rb         # submit
│       │           ├── text.rb           # text/email/url/tel/number/range/color/month/week/datetime_local_field (native + render_*_input per type)
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
│       │   │   ├── html.rb               # Options::Html — merge_html_options (composes Theme + Stimulus)
│       │   │   ├── stimulus.rb           # Options::Stimulus — merge_stimulus_data (space-joins controller/action)
│       │   │   ├── theme.rb              # Options::Theme — extract_classes, theme key resolution
│       │   │   └── token_list.rb         # Options::TokenList — merge_token_list
│       │   ├── renderer.rb               # Plumber::Renderer — renders macro + renderers class attribute
│       │   └── slots.rb                  # Plumber::Slots — slot DSL (with_*, resolve, options_for)
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
│       ├── configuration.rb
│       ├── engine.rb
│       ├── logger.rb
│       └── version.rb
├── test/
│   ├── stimulus_plumbers/
│   │   ├── components/                   # Unit tests per component
│   │   ├── helpers/                      # Helper-level HTML output tests
│   │   ├── form/                         # Form builder + field tests
│   │   ├── plumber/                      # Plumber base class tests
│   │   └── themes/                       # Theme schema + base tests
│   ├── accessibility/                    # Accessibility tests (axe-core via Capybara)
│   │   ├── components/
│   │   └── form/
│   ├── sandbox/                          # Minimal Rails app used by a11y tests
│   ├── support/                          # Shared test helpers (HtmlAssertions, StubTheme)
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

## Guidelines
- **Unit tests** using Rails minitest (`rake test:unit`)
- **Accessibility tests** using Capybara + axe-core (`rake test:accessibility`)
- **Lint tests** using Rubocop (`rake rubocop`)
- **Always run linting** after appraisal command

## Unit Test Convention

**Naming:** class name is CamelCase of the path under `test/stimulus_plumbers/`, with the `components/` segment dropped for component tests:
- `components/button/group_test.rb` → `ButtonGroupTest`
- `form/fields/inputs/text_test.rb` → `FormFieldsTextTest`
- `form/builder_test.rb` → `FormBuilderTest`

**Component tests** assert HTML structure and ARIA — not CSS classes (those belong in the tailwind gem). Cover all constructor options that branch the output (`type:`, `variant:`, `size:`, `hidden:`, `tag:`), and any delegation/convenience methods.

**Form field unit tests** cover both builder levels:
- Native override (`email_field`, `text_area`, …) — element type and forwarded HTML attributes
- Full-field wrapper (`f.field(as:)`) — label, hint, error message, `aria-invalid`, `aria-describedby`, `required`, `hide_label`, all floating variants (`:floating_filled`, `:floating_outlined`, `:floating_standard`), and combined hint+error `aria-describedby`
- When `error:` override is set, assert the override message appears **and** model errors are suppressed

## Accessibility Test Convention

Always pass `context:` to `assert_accessible` to scope axe to the component, not the full page:

```ruby
assert_accessible context: "#combobox-date"
```

Sandbox views must have matching wrapper IDs:
- Single-component pages: `<div id="component-name">` around all variants
- Multi-variant pages: outer `<div id="component">` + inner `<section id="component-variant">` per variant
- Form pages: `<div id="page-name">` around the form
- State variants (error, required, etc.) get their own `<section id="component-state">` so tests can scope axe to that state alone
- Panels render inline (not portaled) — the nearest wrapper always contains the open panel
- For interactive states (e.g. a dialog opens), test closed and open separately; use `find(...).click` before `assert_accessible`
- For multi-view pages (e.g. calendar month/year/decade), use a controller query param (`?view=month`) to expose each view unhidden

## Form Builder Convention

The form builder operates at two levels:

### Level 1 — Native ActionView overrides (theme classes only)

Standard Rails helpers (`email_field`, `text_area`, `check_box`, `select`, `date_field`, etc.) are overridden to apply theme CSS classes but render **no** label, hint, or error wrapper. Use them when controlling surrounding markup manually.

```erb
<%= f.email_field :email %>
<%= f.select      :country, options %>
<%= f.check_box   :agree %>
```

`password_field` additionally supports `revealable: true` at the input level (renders an input-formatter wrapper). `search_field` additionally supports `clearable: true`.

### Level 2 — Full-field helpers (label + input + hint + error)

Three builder methods provide the complete accessible field pattern:

| Method | Renderer constant | `as:` values |
| --- | --- | --- |
| `f.field(attr, as:)` | `FIELD_RENDERER` | `:text`, `:email`, `:number`, `:url`, `:tel`, `:color`, `:month`, `:week`, `:range`, `:datetime_local`, `:text_area`, `:file`, `:password`, `:date`, `:time`, `:select`, `:search` |
| `f.collection_field(attr, as:, collection:, value_method:, text_method:)` | `COLLECTION_FIELD_RENDERER` | `:collection_select`, `:grouped_collection_select` |
| `f.choice(attr, as:, collection:, value_method:, text_method:)` | `CHOICE_RENDERER` | `:radio`, `:check_box` |

Field-chrome options (`label:`, `hint:`, `error:`, `required:`, `hide_label:`, `layout:`) are only meaningful on the full-field helpers — they are **not** processed by native overrides.

## Schema Ranges Convention

Validation ranges for theme schema params live under `lib/stimulus_plumbers/themes/schema/`.

**Where ranges live — the branching rule:**
- If a component branches on the values internally (e.g. `when *FLOATING_TYPES`), the component owns the constant (`Form::Field::FLOATING_TYPES`). The schema references it directly at the call site — no alias.
- If the component only passes the value through to the theme, the schema owns the range (`Schema::Button::Ranges::TYPE`, `Schema::Link::Ranges::TYPE`/`VARIANT`).

**Namespace rules:**
- `Schema::Ranges` — cross-cutting ranges only (`BOOL`). `SIZE`, `LAYOUT`, and `VARIANT` are **not** global — each component owns its own copy.
- `Schema::<Component>::Ranges` — component-owned ranges (e.g. `Schema::Avatar::Ranges::SIZE`, `Schema::Button::Ranges::TYPE/SIZE/LAYOUT/VARIANT`).
- `Schema::Link::Ranges` — link-specific ranges (`TYPE`, `VARIANT` — uses `:default` base instead of `:primary`).
- `Schema::Form::<Input>::Ranges` — ranges for a form input sub-component (e.g. `Schema::Form::Checkbox::Ranges::TYPE/VARIANT`, `Schema::Form::Radio::Ranges::TYPE/VARIANT`).
- `Schema::Form::Ranges` — form-level ranges (`LAYOUT`, `VARIANT`).
- **No local aliases** — never re-export another module's constant inside a `Ranges` module. Reference it directly at the call site.
- **Remove unused constants** — don't keep range constants with no call sites in `schema.rb`.

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Renderers in this package own the HTML structure and ARIA attributes for all components.

## Component Architecture

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Key internal docs: `plumber.md` (Base / Renderer / Options::Html), `dispatcher.md` (Dispatcher strategies), `form.md` (two-level field API).
> Ensure examples provided are tested.

### Icon-only detection (Button + Link)

`Button#build_button` and `Link#build_content` always wrap non-nil text/block content in a `<span>`. When content is nil and no block is given (icon-only), nothing is rendered — no `<span>`. The active theme can use `:has(> span)` / `:not(:has(> span))` to distinguish icon-only from text buttons without any Ruby flag. Do not change this contract without updating the theme accordingly.

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure, form builder keywords), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
