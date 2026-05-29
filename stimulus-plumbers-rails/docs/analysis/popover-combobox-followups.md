# Popover / Combobox unification — follow-ups

Context: the combobox family was unified onto the shared `popover` Stimulus
controller (wrapper `data-controller="popover input-combobox input-formatter"`).
`popover` owns visibility / `aria-expanded` / outside-click dismissal / focus;
`input-combobox` owns value + filtering; selection events fire both
`*:selected->input-combobox#onSelect` (commit value) and
`*:selected->popover#closeOnSelect` (dismiss). A `closeOnSelect` value /
`close_on_select:` kwarg gates the dismissal.

The pre-existing issues found during that work (password reveal arity, typeahead
listbox ARIA children, the `RegexpLiteral` lint) have since been resolved. One
theme gap remains, deferred to a tailwind-package session.

---

## Theme gap — `popover_trigger` / `popover_wrapper` unstyled in the tailwind theme

> **Folded into `theme-key-audit.md`** (finding #2 + Phase 3). That plan renames
> `popover_wrapper` → `popover_root` and adds `popover_root_classes` /
> `popover_trigger_classes` to the tailwind theme (trigger styled as a proper button —
> option 1 below), then regenerates the `profile.spec.js` baselines. Track the work
> there; the notes below remain as background.

- **File:** `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/layout.rb`
- **Current state:** the tailwind theme defines `popover_classes` (the panel:
  `rounded border bg shadow z`) but has **no** `popover_trigger_classes` or
  `popover_wrapper_classes`. Both keys exist in the schema
  (`themes/schema.rb` → `popover_wrapper: {}`, `popover_trigger: {}`) but resolve
  to empty in tailwind, so the default `p.trigger { ... }` renders a **bare,
  unstyled native `<button>`**.
- **Visible impact:** the `profile.spec.js` snapshots (default + popover-open,
  desktop + mobile) differ from baseline. The popover opens and wires correctly
  (`aria-expanded` toggles); only the trigger _appearance_ changed because the
  demo previously used a styled `sp_button` activator and now uses the default trigger.
- **Decision deferred:** do NOT update the 4 profile baselines until the theme
  decides how the default popover trigger should look. Options:
  1. Add `popover_trigger` (and possibly `popover_wrapper`) styling to the
     tailwind theme so the default trigger looks like a proper button
     (benefits every popover consumer) — preferred.
  2. Or have the profile demo use the one-arity custom trigger with `sp_button`
     (`p.trigger { |attrs| sp_button(..., aria: attrs[:aria], data: attrs[:data]) }`)
     to preserve the old styled look — demo-only.
- **After resolving:** regenerate baselines with
  `npm run test:snapshots:update` in `stimulus-plumbers-tailwind`.
