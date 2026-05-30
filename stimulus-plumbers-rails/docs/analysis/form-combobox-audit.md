# Form & Combobox Code Audit

> Status: **implemented** (variant value object + naming/ARIA fixes) on
> `claude/form-components-audit-gzD9e`, plus **deferred** recommendations below.
> Scope: code quality and naming consistency across the form-field family and the
> combobox/popover components. Theme-key work is tracked separately in
> `theme-key-audit.md`.

## 1. Combobox variant metadata — replaced class methods with a value object

### Before
Each combobox panel class carried polymorphic class methods:

- `Combobox::Dropdown.haspopup` / `.popup_id`
- `Combobox::Typeahead.haspopup` / `.popup_id` / `.default_opts`
- `Combobox::Date.haspopup` / `.popup_id` / `.default_opts`
- `Combobox::Time.haspopup` / `.popup_id`

Callers read them polymorphically and repeated
`Klass.default_opts.deep_merge(...)` + `haspopup:` + `popup_id:` in five places
(`form/fields/inputs/{combobox,datetime,search,select}.rb` and the four
`sp_combobox_*` helpers). Three of those methods needed
`# rubocop:disable Metrics/AbcSize`.

### After
A single immutable value object, `Components::Combobox::Variant`
(`components/combobox/variant.rb`), holds `haspopup`, `panel_class`,
`default_opts`, and `popup_id_suffix`, and exposes `#popup_id(panel_id)` and
`#opts(**overrides)`. The four variants are registered once on the parent
(`Combobox.build_variants`, memoized via `Combobox.variant(name)`); the registry
is the single source of truth.

Callers now say `Components::Combobox.variant(:typeahead)` and use
`variant.haspopup` / `variant.popup_id(panel_id)` / `variant.opts(...)`. The
panel classes (`Dropdown`/`Typeahead`/`Date`/`Time`) keep only their render logic
and instance-relevant constants (`Date.calendar_id_for`, `STIMULUS_*`,
`Typeahead::LISTBOX_ID_SUFFIX`).

### Result
- No `def self.haspopup|popup_id|default_opts` anywhere
  (`grep -rn 'def self.haspopup\|def self.popup_id\|def self.default_opts' lib`
  → empty).
- All three `# rubocop:disable Metrics/AbcSize` pragmas in the combobox/helper
  paths removed; `rake rubocop` is green with no new excludes.
- Behavior-preserving: combobox markup (ids, `aria-haspopup`, `aria-controls`,
  the typeahead `_listbox` id suffix) is unchanged; the full unit suite passes.

## 2. Naming & ARIA consistency fixes

- **`err:` → `error:`** — `Form::Fields::Inputs::Combobox#render_combobox` and its
  call sites (`datetime.rb`, `search.rb`, `select.rb`) now use `error:`, matching
  the rest of the form family. Its `klass:` parameter is likewise now `variant:`.
- **Single label/labelledby builder** — the duplicated
  `{ label: (label unless labelledby), labelledby: labelledby }.compact` in
  `combobox/{dropdown,typeahead,date,time}.rb` is replaced by one shared
  `Plumber::Base#labelled_aria(label, labelledby)` helper, so the
  `aria-label` vs `aria-labelledby` rule lives in one place.
- **Typeahead status regions aligned** — the loading region used
  `aria: { live: "polite" }` while the empty region used `role: "status"`. Both
  are now `role="status"` (implicit polite), matching `Form::Fields::Error` and
  WCAG 2.1 §4.1.3.

### Conventions kept on purpose
The `build_*` (assemble data/attribute hashes) vs `render_*` (emit HTML) split is
already internally consistent across the form layer — documented here rather than
churned.

## 3. Deferred recommendations (not implemented this pass)

These are real but out of scope for a behavior-preserving refactor; they change
user-visible strings or accessibility semantics and want their own review:

- **Internationalize hardcoded UI strings.** `"No results"`
  (`combobox/typeahead.rb`), `"Show password"` / `"Hide password"`
  (`form/fields/inputs/password.rb`), and `"Clear search"`
  (`form/fields/inputs/search.rb`) are inline English. Route through Rails I18n
  under a `stimulus_plumbers.*` scope with sensible defaults.
- **`aria-required` on individual collection items.** For `f.choice(... as: :check_box)`
  / `:radio`, the `<fieldset>` carries `aria-invalid`/`aria-describedby`, but
  individual checkbox/radio inputs don't receive `aria-required`. Decide whether
  the requirement belongs on the group (current) or each control, and align with
  the APG pattern before changing.
