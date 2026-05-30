# Theme Key Audit & Refactor Plan

> Status: **planned** (not yet implemented). Breaking API changes accepted.
> Goal: make every theme key accurately, consistently, and cleanly reflect how the
> component is actually styled, with names cross-referenced to major UI libraries.

## Re-validation (2026-05-30)

Every finding below was re-checked against the current `fix/combobox-popover`
tree and **still holds**. Concrete evidence:

- **Half-dead `resolve` envelope (finding 1):** `themes/base.rb#resolve` still
  returns `{ classes:, style? }`; `:style` is never produced by any theme method.
  `grep -rn '.fetch(:classes, "")' lib` → ~40 hits across components, the form
  builder (`form/builder.rb#field_theme`), and combobox/popover renderers.
- **Unstyled popover keys (finding 2):** `stimulus-plumbers-tailwind/.../tailwind/layout.rb`
  defines only `popover_classes` — no `popover_wrapper_classes` /
  `popover_trigger_classes`. `components/popover.rb` resolves `:popover_wrapper` and
  `components/popover/trigger.rb` resolves `:popover_trigger`, both hitting the
  `Logger.warn` fallback → bare, unstyled wrapper/trigger.
- **Dead schema keys (finding 3):** `form_field` / `form_collection_field` are in
  `themes/schema.rb` but no `*_classes` method resolves them.
- **Ignored variants (finding 4):** e.g. `tailwind/form.rb` `form_checkbox_classes(**)`
  and `form_radio_classes(**)` swallow the schema-declared `error:` variant;
  `calendar_day#today/#selected` are styled via `aria-*` CSS, not the theme;
  `avatar#color` is computed in `components/avatar.rb#resolve_color`, never passed
  to the theme.
- **Parallel popover/combobox vocab (finding 5)** and **naming smells (finding 6)**
  are unchanged.

**Verdict:** the architecture is sound — a single-source `Base::SCHEMA`, validated
`resolve`, and pluggable per-theme `*_classes` methods keep theme logic out of the
components. Convolution is *localized*: the unused return envelope, schema↔impl
drift, the two naming vocabularies, and avatar color leaking into the component.
None of it is structural; all of it is addressable without redesigning the system.

## Recommended sequencing (non-breaking first)

This pass does **not** modify theme code (scope: re-validate + document). When the
work is scheduled, land it in this order so downstream custom themes are not broken
all at once:

1. **Phase 1 — drop the envelope (non-breaking, internal only).** `resolve` and the
   `*_classes` methods return a bare class String; delete the ~40 `.fetch(:classes, "")`.
   No public key changes.
2. **Phase 2 — schema honesty (non-breaking).** Remove the dead keys and the ~8
   ignored variants; add the **bidirectional schema↔method coverage test**; fill the
   missing `popover_root` / `popover_trigger` implementations so popovers ship styled.
3. **Phase 3 — public key renames (breaking).** The `popover_*` / `combobox_*` /
   `calendar_*` / `form_*` renames in the tables below. Gate behind a version bump
   and a CHANGELOG/upgrade note, since they break custom `*_classes` overrides.

The detailed phase plan and rename tables below remain the reference for the
eventual implementation.

## How `theme.resolve` works today

- `Themes::Base#resolve(component, **args)` validates `args` against `Base::SCHEMA`,
  then calls the theme's private `#{component}_classes` method.
- It returns a Hash `{ classes:, style? }`. Every one of the ~40 call sites does
  `theme.resolve(X).fetch(:classes, "")`.
- `Base::SCHEMA` is the single source of truth for which keys + variants exist;
  `TailwindTheme` (in the tailwind gem) supplies the `*_classes` implementations.

## Audit findings

### 1. The `resolve` return contract is half-dead

`resolve` returns `{ classes:, style? }`, but **no theme ever returns `:style`**.
All call sites do `.fetch(:classes, "")`. The envelope buys nothing and forces
boilerplate everywhere.

### 2. Resolved keys with no theme method (silent warnings + unstyled output)

- `popover_wrapper` and `popover_trigger` are resolved in `popover.rb` /
  `popover/trigger.rb`, but `TailwindTheme` defines **neither** (`tailwind/layout.rb`
  only has `popover_classes`). They hit the `Logger.warn` fallback in `Base#resolve`
  and return `{}` → the popover wrapper and trigger ship with **zero classes**.
  This is the deferred theme gap tracked in `popover-combobox-followups.md`; this plan
  resolves it (new `popover_root_classes` + `popover_trigger_classes` in Phase 3, with
  the trigger styled as a proper button per that doc's preferred option 1).

### 3. Dead schema keys (declared, never resolved, no `_classes` method)

- `form_field` (`as:`) and `form_collection_field` (`as:`).

### 4. Declared variants the theme ignores (schema lies about what varies)

- `form_group#error`, `form_label#required`, `form_checkbox#error`,
  `form_radio#error`, `form_input_reveal#error`, `calendar_day#today`,
  `calendar_day#selected` (handled via `aria-*` CSS, not variants),
  `avatar#color` (component computes color via `resolve_color`, only passes `size`).

### 5. Two parallel vocabularies for the same concepts

Popover and Combobox each name the same floating-surface parts differently, even
though combobox builds a `Popover` internally.

### 6. Other naming / structure smells

- `calendar_navigation_navigator` — awkward triple nesting (it's the prev/next button).
- `combobox_time` is a panel-layout key, but date/dropdown/typeahead panels have none.
- `combobox_typeahead_loading/empty` are generic status regions, not typeahead-specific.
- `input_group` lives in its own `INPUT_GROUP` schema module though it's a form concern
  (impl is in `Tailwind::Form`).

## Decisions locked

- **Ignored variants (finding 4): remove from schema.** Re-add only when a theme
  actually styles them.
- **Naming: full unification**, cross-referenced to major UI libraries.

## Cross-reference: library anatomy

Sources consulted:

- Radix UI Primitives (Popover)
- Ark UI (Combobox, DatePicker, Field, Popover)
- **Tailwind — Headless UI** (Popover, Combobox) and **Catalyst** (Fieldset/Field)
- shadcn/ui (Form), react-day-picker (calendar class names), ARIA APG (roles)

### Surface vocabulary (final): `root` · `trigger` · `panel` · `positioner`

| Part             | Radix    | Ark UI     | Tailwind (Headless UI) | This gem's term                |
| ---------------- | -------- | ---------- | ---------------------- | ------------------------------ |
| container        | Root     | Root       | `<Popover>`            | —                              |
| activator        | Trigger  | Trigger    | PopoverButton          | `trigger.rb`                   |
| floating surface | Content  | Content    | **PopoverPanel**       | **`panel.rb` / `build_panel`** |
| placement        | (Anchor) | Positioner | (on Panel anchor)      | —                              |

→ surface key = **`popover_panel`** (matches Headless UI _and_ the gem's own term).

## Rename tables

### Popover

| Current           | New               | Refs                                                            |
| ----------------- | ----------------- | --------------------------------------------------------------- |
| `popover_wrapper` | `popover_root`    | Headless `<Popover>`, Radix/Ark Root · _adds missing impl_      |
| `popover_trigger` | `popover_trigger` | Headless PopoverButton, Radix/Ark Trigger · _adds missing impl_ |
| `popover`         | `popover_panel`   | Headless PopoverPanel; matches gem `panel.rb`                   |

### Combobox

Headless UI: Combobox · ComboboxInput · ComboboxButton · ComboboxOptions · ComboboxOption

| Current                      | New                     | Refs                                                    |
| ---------------------------- | ----------------------- | ------------------------------------------------------- |
| `combobox`                   | `combobox_root`         | Headless `<Combobox>`, Ark Root                         |
| `combobox_trigger_group`     | `combobox_control`      | Ark Control                                             |
| `combobox_trigger`           | `combobox_input`        | Headless ComboboxInput, Ark Input, APG `role=combobox`  |
| `combobox_popover`           | `combobox_positioner`   | Ark Positioner                                          |
| _(gap today)_                | reuse `popover_panel`   | Headless PopoverPanel · _fixes missing dropdown chrome_ |
| `combobox_listbox`           | `combobox_listbox`      | keep — `role=listbox` (Headless calls it Options)       |
| `combobox_option`            | `combobox_option`       | Headless ComboboxOption, APG option                     |
| `combobox_option_group`      | `combobox_option_group` | keep                                                    |
| `combobox_typeahead_loading` | `combobox_loading`      | drop misnomer                                           |
| `combobox_typeahead_empty`   | `combobox_empty`        | Ark Empty                                               |
| `combobox_time`              | `combobox_time`         | keep — component-specific drum body                     |

### Calendar / DatePicker

Ark UI: Table/TableHead/TableBody/TableRow/TableCell, ViewControl/PrevTrigger/NextTrigger ·
react-day-picker: month_grid/weekdays/week/day/nav/button_previous ·
(Headless UI has no calendar)

| Current                         | New                   | Refs                                   |
| ------------------------------- | --------------------- | -------------------------------------- |
| `calendar`                      | `calendar_grid`       | `role=grid`, Ark Table, rdp month_grid |
| `calendar_days_of_week`         | `calendar_weekdays`   | rdp weekdays (header row)              |
| `calendar_days_of_month`        | `calendar_weeks`      | rdp weeks / Ark TableBody              |
| `calendar_week`                 | `calendar_week`       | keep — rdp week / `role=row`           |
| `calendar_day`                  | `calendar_day`        | keep — rdp day / `role=gridcell`       |
| `calendar_navigation`           | `calendar_nav`        | rdp nav / Ark ViewControl              |
| `calendar_navigation_navigator` | `calendar_nav_button` | rdp button_previous/next               |

### Form fields

Catalyst: Fieldset · Legend · FieldGroup · Field · Label · Description · ErrorMessage ·
Ark Field: Root/Label/Input/Textarea/Select/HelperText/ErrorText/RequiredIndicator ·
shadcn: FormItem/FormLabel/FormControl/FormDescription/FormMessage

| Current                                                                                                                                                                                                                     | New                 | Refs                                                                             |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------- |
| `form_group`                                                                                                                                                                                                                | `form_field`        | Catalyst Field, Ark Field.Root, shadcn FormItem, gem `Form::Field` (4-way)       |
| `form_details`                                                                                                                                                                                                              | `form_hint`         | Ark HelperText, gem `hint.rb` (gem term wins; Catalyst/shadcn say "Description") |
| `form_error`                                                                                                                                                                                                                | `form_error`        | keep — Catalyst ErrorMessage, Ark ErrorText, gem `error.rb`                      |
| `form_collection_label`                                                                                                                                                                                                     | `form_choice_label` | gem `f.choice` API                                                               |
| `input_group`                                                                                                                                                                                                               | `form_input_group`  | bootstrap/shadcn input-group; move into FORM schema                              |
| `form_label`                                                                                                                                                                                                                | `form_label`        | keep — Catalyst Label                                                            |
| `form_input` / `form_textarea` / `form_select` / `form_file` / `form_checkbox` / `form_radio` / `form_combobox` / `form_submit` / `form_input_reveal` / `form_input_clearable` / `form_button_reveal` / `form_button_clear` | unchanged           | already aligned with Ark/Catalyst/APG                                            |

### Deliberate deviations from lib terms (kept on purpose)

- `combobox_listbox` / `combobox_option` — kept on ARIA roles rather than Headless's
  `Options` / `Option`.
- `form_required_mark` — kept rather than Ark `RequiredIndicator` (low value to churn).

## Phase plan

### Phase 1 — Simplify the `resolve` contract

1. `Base#resolve` returns a plain class **string** (drop the `{classes:}` envelope and
   the never-emitted `:style`).
2. Strip `.fetch(:classes, "")` from all ~40 call sites; `*_classes` methods return the
   `klasses(...)` string directly.
3. Verify: `rake test:unit` green; `grep .fetch(:classes` → zero hits.

### Phase 2 — Schema honesty

4. Delete dead keys: `form_field` (old), `form_collection_field`.
5. Remove the 8 ignored variants (finding 4) and their swallowing args
   (`**`, `**_rest`, `error:`, `required:`) from schema, `*_classes` methods, and
   component call sites.
6. Add a **schema-coverage test**: every `Base::SCHEMA` key ↔ a `TailwindTheme`
   `_classes` method (both directions). Prevents `popover_wrapper`-style drift.
7. Move `input_group` from `INPUT_GROUP` schema module into `FORM`.

### Phase 3 — Rename to the cross-referenced taxonomy

8. Apply the rename tables across `themes/schema*.rb`, `tailwind/*.rb` method names,
   every component/form consumer, and docs. Mechanical & greppable; run
   `rake test:unit` after each key cluster.
9. Compose `popover_panel` into the combobox dropdown (intended visual change: adds
   border/shadow chrome the dropdown currently lacks).

### Phase 4 — Document & lock

10. Rewrite the theme-key tables in root `CLAUDE.md` and `docs/component/*.md` to the
    new names, each with a one-line "(≈ Headless UI/Catalyst/Ark <Part>)" cross-ref.
11. Verify: `rake test:unit` + `rake rubocop` green; `npm run test:snapshots` in the
    tailwind gem shows only the intended diffs (popover root/trigger, combobox chrome).
    Regenerate the affected baselines with `npm run test:snapshots:update` — expected
    specs: `popover.spec.js`, `combobox.spec.js`, and **`profile.spec.js`** (the 4
    default/open × desktop/mobile baselines blocked on this work, per
    `popover-combobox-followups.md`).

## Tailwind gem changes (`stimulus-plumbers-tailwind`)

The schema lives in the rails gem, but every `*_classes` implementation lives in
`stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/`. Each phase has a
corresponding tailwind-side edit.

### Phase 1 — contract (return strings)

- **All `*_classes` methods, every `tailwind/*.rb`** (~40 methods): change the return
  from `{ classes: klasses(...) }` to the bare string `klasses(...)`. `resolve` now
  returns that string directly. `klasses` helper unchanged.
- Affected files: `action_list.rb`, `avatar.rb`, `button.rb`, `calendar.rb`, `card.rb`,
  `combobox.rb`, `form.rb`, `icon.rb`, `layout.rb`.

### Phase 2 — schema honesty (drop ignored variants)

- `form.rb`:
  - `form_group_classes(layout: :stacked, **_rest)` → `form_group_classes(layout: :stacked)`
  - `form_label_classes(hidden: false, **)` → `form_label_classes(hidden: false)`
  - `form_checkbox_classes(**)` → `form_checkbox_classes`
  - `form_radio_classes(**)` → `form_radio_classes`
  - `form_input_reveal_classes(**)` → `form_input_reveal_classes`
- `avatar.rb`: `avatar_classes(size: :md, color: nil)` → `avatar_classes(size: :md)`
  (color is computed by the component, never by the theme).
- `calendar.rb`: no signature change — `calendar_day_classes(outside:)` already omits
  `today`/`selected`; only the schema entry is removed.

### Phase 3 — rename methods + constants

`layout.rb`

| Current method (const)        | New method (const)                | Note                                                                                                                                                |
| ----------------------------- | --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `popover_classes` (`POPOVER`) | `popover_panel_classes` (`PANEL`) | the floating surface chrome                                                                                                                         |
| _(missing)_                   | `popover_root_classes`            | **NEW** — e.g. `relative`                                                                                                                           |
| _(missing)_                   | `popover_trigger_classes`         | **NEW** — style as a proper button (reuse `Button::BASE` + a default variant/size) so the default `p.trigger { … }` is not a bare native `<button>` |

> Per `popover-combobox-followups.md` option 1 (preferred): the default popover
> trigger must look like a styled button — every popover consumer benefits, and it
> unblocks the 4 deferred `profile.spec.js` baselines. Reuse `Button::BASE` +
> `Button::VARIANTS[:secondary]` (or similar) rather than inventing standalone classes.

`combobox.rb`

| Current method (const)                                     | New method (const)                           |
| ---------------------------------------------------------- | -------------------------------------------- |
| `combobox_classes` (`CONTAINER`)                           | `combobox_root_classes` (`ROOT`)             |
| `combobox_popover_classes` (`POPOVER`)                     | `combobox_positioner_classes` (`POSITIONER`) |
| `combobox_trigger_classes` (`TRIGGER`)                     | `combobox_input_classes` (`INPUT`)           |
| `combobox_trigger_group_classes` (`TRIGGER_GROUP`)         | `combobox_control_classes` (`CONTROL`)       |
| `combobox_typeahead_loading_classes` (`TYPEAHEAD_LOADING`) | `combobox_loading_classes` (`LOADING`)       |
| `combobox_typeahead_empty_classes` (`TYPEAHEAD_EMPTY`)     | `combobox_empty_classes` (`EMPTY`)           |
| `combobox_listbox/option/option_group/time_classes`        | unchanged                                    |

> **DOM marker classes inside combobox.rb**: the `INPUT` constant references
> `[.sp-combobox-group_&]:…` arbitrary variants, and `CONTROL` injects the
> `sp-combobox-group` marker. Rename both to `sp-combobox-control` for consistency, or
> leave the marker as-is — it is a CSS hook, not a theme key. Same for the
> `sp-form-combobox` marker shared with `form_combobox_classes`.

`calendar.rb`

| Current method (const)                              | New method (const)                        |
| --------------------------------------------------- | ----------------------------------------- |
| `calendar_classes` (`GRID`)                         | `calendar_grid_classes` (`GRID`)          |
| `calendar_days_of_week_classes` (`DAYS_OF_WEEK`)    | `calendar_weekdays_classes` (`WEEKDAYS`)  |
| `calendar_days_of_month_classes` (`DAYS_OF_MONTH`)  | `calendar_weeks_classes` (`WEEKS`)        |
| `calendar_navigation_classes` (`NAV`)               | `calendar_nav_classes` (`NAV`)            |
| `calendar_navigation_navigator_classes` (`NAV_BTN`) | `calendar_nav_button_classes` (`NAV_BTN`) |
| `calendar_week_classes`, `calendar_day_classes`     | unchanged                                 |

`form.rb`

| Current method (const)                                    | New method (const)                                       |
| --------------------------------------------------------- | -------------------------------------------------------- |
| `form_group_classes` (`GROUP_BASE`/`GROUP_INLINE`)        | `form_field_classes` (`FIELD_BASE`/`FIELD_INLINE`)       |
| `form_details_classes` (`DETAILS`)                        | `form_hint_classes` (`HINT`)                             |
| `form_collection_label_classes` (`COLLECTION_ITEM_LABEL`) | `form_choice_label_classes` (`CHOICE_LABEL`)             |
| `input_group_classes` (`INPUT_GROUP_BASE`/`_BORDER`)      | `form_input_group_classes` (same consts, now FORM scope) |
| all other `form_*_classes`                                | unchanged                                                |

### Phase 3 — combobox panel composition (visual change, step 9)

- Today the combobox dropdown gets only `combobox_positioner` (`absolute top-full …`)
  and **no** chrome. To add border/shadow, the **rails** `combobox.rb` should merge
  `popover_panel` + `combobox_positioner` onto the panel (via `p.build_panel`), reusing
  the tailwind `popover_panel_classes` string. No new tailwind key needed.

### Phase 4 — snapshots

- Regenerate Playwright baselines for the changed surfaces:
  `npm run test:snapshots:update` in `stimulus-plumbers-tailwind/`. Affected specs:
  `popover.spec.js`, `combobox.spec.js`, `profile.spec.js`. Expect diffs only on popover
  root/trigger and the combobox dropdown chrome; everything else byte-identical.

## Open items to confirm before implementing

- Composing `popover_panel` into combobox is a real visual change, not just a rename.
  Skip if the dropdown must stay visually identical.
- Overrule any of the deliberate deviations above if lib-exact names are preferred.
