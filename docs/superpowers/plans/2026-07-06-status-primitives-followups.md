# Status Primitives — Follow-ups

Non-blocking items from the final whole-branch review of
[2026-07-06-status-primitives-plan.md](2026-07-06-status-primitives-plan.md)
(branch `feature/status-indicator`, reviewed at commit `f7ad69f7`, approved
"Ready to merge: Yes"). Nothing here blocks merge — recorded so they aren't
lost.

## Minor findings

1. **FIXED.** Read-only checklist items (`checked:` set, `interactive:`
   omitted/false) previously rendered as `<button type="button"
   data-controller="list-item">`, and the JS controller set
   `aria-pressed` on it via `checkedValueChanged` — exposing a focusable,
   "pressed" toggle button with no click action wired. Neither of the two
   fixes originally floated here (dropping the controller, or gating
   `aria-pressed` on `interactive:`) was viable without breaking existing
   plan-mandated tests (`item_test.rb`'s controller-presence assertions,
   and the JS `checkedValueChanged` connect test). Fix used instead:
   `List::Item#render_link_or_button` now renders read-only checklist rows
   (`checked` set, `interactive: false`, no `url`) as a `<div>` instead of
   a `<button>` — controller/value data attributes are unchanged, but the
   element is no longer focusable or implicitly button-roled.
   `checkedValueChanged` in the JS controller now only sets `aria-pressed`
   when the host element matches `button, [role="button"]`, so it never
   applies `aria-pressed` to a role-less `<div>` (which would itself be an
   `aria-allowed-attr` violation). Both existing test suites pass
   unmodified; new coverage added:
   `test_read_only_checklist_item_renders_as_div_not_button` (Ruby) and
   the `checkedValueChanged on a non-button host` describe block (JS).
   — `stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb`,
   `stimulus-plumbers/src/controllers/list_item_controller.js`

2. **`setValue()` calls `this.render()` synchronously**, in addition to the
   async `valueValueChanged` value-callback that the plan's literal example
   code relied on alone. This is a necessary, correct deviation — the plan's
   own test asserts `fill.style.width` synchronously right after
   `setValue()`, which only passes because of the explicit synchronous
   render (Stimulus value-changed callbacks fire asynchronously). The
   resulting double-render (sync + async) is idempotent, so no behavior bug,
   just worth having on record as a deviation from the plan's literal code.
   — `stimulus-plumbers/src/controllers/progress_controller.js`

3. **FIXED.** `INDICATOR` schema's `color:` declared `default: nil`, but
   `color:` is a required keyword argument everywhere
   `Indicator`/`sp_indicator` is called, so the default was unreachable dead
   code. Verified via a research pass that nothing runtime-reads
   `schema[:default]` except the invalid-value fallback path in
   `themes/base.rb#cast`, and no test asserts the key's presence/shape.
   Removed the `default: nil` entry entirely (`{ validate:
   Button::Ranges::VARIANT }`) — no other schema key omits `default:`, but
   `nil` isn't a real member of `Button::Ranges::VARIANT` so a bogus
   default would have been more misleading than an absent one.
   `bundle exec rubocop` (289 files) and the full `themes/base_test.rb` /
   `components/indicator_test.rb` suites pass unchanged.
   — `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
   (`INDICATOR` block)

## Standing notes for downstream owners

- **`timeline_item_indicator_dot` theme schema key is now unused.** Task 11
  refactored `Timeline::Event` to delegate its dot/icon rendering through
  the new `Indicator` component, which no longer resolves this key. Left in
  place intentionally per the plan (don't remove pre-existing schema/dead
  code without being asked) — the Tailwind theme owner should decide
  whether to retire it.
  — `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`

- **Tailwind theme values for all new keys are intentionally out of
  scope** for this plan: `progress_bar`, `progress_bar_fill`,
  `progress_ring`, `progress_ring_track`, `progress_ring_fill`, `meter`,
  `indicator`, `indicator_pulse`, `list_item_checkbox`. All new components
  render via the Base theme's no-op defaults only; a Tailwind styling pass
  is a separate follow-up task.
