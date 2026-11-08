# Combobox Modernization Implementation Plan

> **For agentic workers:** Implement one phase at a time. The primary agent designs and reviews
> each phase; an implementation agent implements it and does not commit. The user commits after
> the primary agent stages the reviewed diff.

**Goal:** Replace the `popover` + `input-combobox` + `combobox-*` composition with one `combobox`
controller on a `manual` native popover, rebuild the date/time variants on `sp_calendar` and
`input-formatter`, and ship with the popover foundation and the calendar redesign.

**Architecture:** `combobox_controller` privately owns the `Popover` plumber, the listbox state
machine, and every close path. Rails renders select-only and editable markup with stable option
IDs. The Tailwind theme anchors the panel to the input group in CSS. A Turbo Frame adapter owns
remote results. `sp_combobox_date` and `sp_combobox_time` keep the legacy look on a `popover` panel.

**Design:**

- [Combobox](../specs/2026-09-11-combobox-modernization-design.md) (amended 2026-10-05)
- [Overlay foundation](../specs/2026-09-11-overlay-foundation-modernization-design.md)
- [Modal D12](../specs/2026-09-09-modal-modernization-design.md) (Escape inside a modal)
- [Calendar and calendar field](../specs/2026-09-11-calendar-modernization-design.md)
- [Roadmap release coupling](../specs/2026-09-11-component-modernization-roadmap.md)

## Decisions already recorded

- Rework, not a stop-gap: this is roadmap Phase 2; overlay Product Decision 1A holds.
- The calendar redesign is in scope and ships in the same release.
- Panel is `popover="manual"`; the combobox owns dismissal (combobox D5).
- `aria-selected` follows the active option (APG); no `data-active` (combobox D2).
- Tab commits the active option (combobox D4).
- The panel anchors to the input group through `anchor-scope`, in the theme only.
- The `Dialog` plumber closes the most recently opened popover on Escape (modal D12).

## Global constraints

- Branch: `fix/popover` or a branch cut from it; the popover foundation must be present.
- The user commits. Agents stage only reviewed, phase-owned files.
- Never run `node --run test:snapshots:update`; CI regenerates baselines.
- `test/browser` owns engine-native behavior, one spec per route; `test/snapshots` owns
  screenshots only; vitest owns controller logic; Rails a11y tests own WCAG scans.
- Keep vocabulary to `combobox`, `Popover`, and `sp_combobox`. No new plumber for close paths;
  `Dismisser` stays deprecated.
- `data-action` wires `onX(event)` adapters only; `stimulus_contract_test.rb` must pass after every
  phase that touches wiring, so JS and Rails wiring change in the same phase.
- Private fields for the plumber reference and listener `AbortController`; no test getters.
- Docs follow the repository Doc Update Rule: one fact in one place, no test references in docs.
- Each phase leaves vitest, Rails unit, Tailwind unit, MCP, rubocop, eslint, and prettier green.

## Phase 0 — Specs and plan

**Files:** the amended specs above, `2026-09-15-popover-modernization.md`, and this plan.

- [ ] Review the amendments and this plan.
- [ ] `npx prettier --check docs/superpowers/specs docs/superpowers/plans` and `git diff --check`.

## Phase 1 — Escape inside a modal dialog

Independent of the combobox; fixes WebKit for `sp_popover` today.

**Files:**

- Modify: `stimulus-plumbers/src/plumbers/dialog.js`
- Modify: `stimulus-plumbers/tests/unit/plumbers/dialog.test.js`
- Modify: `stimulus-plumbers/docs/plumber/dialog.md`, `ARIA.md` (Modal)
- Modify: `stimulus-plumbers-tailwind/test/browser/components/popover/popover.spec.js` — split
  `in a native dialog` into a geometry test (WebKit `test.fail` inside its body) and Escape-order
  tests with no expected failure: keyboard-opened popover, and focus blurred to `body`.

Requirements (modal D12):

- Listen for `keydown` on the dialog's owner document, bubble phase, added in the constructor and
  removed in `disconnect()`. Act only while the dialog is open and the target is inside it or is
  `body`/`html`.
- Skip when the key is not Escape, the event is `defaultPrevented`, or `isComposing`.
- Skip when the dialog contains a nested open dialog; that dialog owns Escape.
- Track open order with a capture `beforetoggle` listener on the dialog that ignores non-popovers,
  falling back to document order for popovers opened before attaching. Prevent default and hide
  the most recently opened popover that is not `manual` and is still open inside the dialog.

Tests: only the most recent popover hides; `body` target handled; target outside the dialog,
closed dialog, handled, composing, and non-Escape keys ignored; manual-only leaves the native
cancel path; nothing after `disconnect()`; public API unchanged. Each browser Escape test fails
on WebKit without the fix.

Verification: `npx vitest run tests/unit/plumbers/dialog.test.js`, `npm run build`, then
`node --run test:browser -- test/browser/components/popover` in `stimulus-plumbers-tailwind/`.

## Phase 2 — `combobox_controller` state machine

**Files:**

- Create: `stimulus-plumbers/src/controllers/combobox_controller.js`
- Create: `stimulus-plumbers/tests/unit/controllers/combobox_controller.test.js`
- Modify: `stimulus-plumbers/src/index.js`, `stimulus-plumbers/README.md`
- Modify: `stimulus-plumbers/docs/component/combobox.md` — add a `## combobox` section; the legacy
  sections go in Phase 7.
- Modify: `stimulus-plumbers-mcp/test/stimulus_plumbers/mcp/controller_schema_loader_test.rb` —
  add `combobox` to `EXPECTED_IDENTIFIERS` (exact equality).
- Modify: `stimulus-plumbers/CLAUDE.md` "Accessibility helpers", `ARIA.md`, and
  `docs/accessibility/design.md` §2 to note that `combobox` keeps navigation private.

Requirements:

- Targets `control`, `input`, `panel`, `listbox`; values `mode` (`select_only` | `editable`),
  `valuePolicy`, `closeOnCommit`. The `status` target and `minLength` value arrive with Phase 4,
  which uses them.
- Keep listbox navigation private. `ListboxNavigation` prevents default on Space/Home/End
  unconditionally, steps Arrow Up from no option to the first, clicks on Enter, and has no
  `aria-activedescendant`; its one caller is retired in Phase 7.
- Attach with `attachPopover(this, { element: panel, prefix: 'combobox' })` and listen to
  `combobox:opened`/`combobox:closed`; the manifest assigns imported plumber dispatches to the
  controller identifier.
- The close path sets `aria-expanded`, clears `aria-activedescendant`, and restores `aria-selected`
  synchronously; the `closed` handler only reconciles external hides. `toggle` is async, so
  `turbo:before-cache` would otherwise snapshot stale ARIA.
- D2 open-state initialization; D4 keys, Escape included, in `onKeydown` on the control, never on
  the listbox; `isComposing` ignored for Enter and Escape; closed Escape not prevented.
- D5 close paths attached on open, removed on close and disconnect through one `AbortController`.
- Root `mousedown` default prevented except on the control; `Popover#show(control)` opens.
- D9 `commit(option)` shared by pointer and keyboard; events `combobox:query`,
  `combobox:before-change`, `combobox:changed`. `combobox:results` arrives with filtering in
  Phase 4.
- D11 `turbo:before-cache`, reconnect, and `listboxTargetConnected` reconciliation.
- Form reset: capture the initial option, value, and label on connect and restore them in a task
  after `reset`; a hidden input's value setter defeats native reset.
- Options without an ID get an `ensureId` fallback; Rails always renders IDs.

Tests (vitest, real `KeyboardEvent`s on the control; stub `showPopover`, `hidePopover`, and
`:popover-open`, which jsdom lacks): every row of D4, including editable Space, Home, and End
staying native and select-only Space committing; Escape restores `aria-selected`; Tab commits;
input clears the active option; listeners exist only while open; disconnect cleanup; option
replacement; form reset.

## Phase 3 — Rails renderer

Date and time stay on the legacy composition until Phase 7, in their own class; the new renderer
takes the final `Components::Combobox` name so Phase 7 is pure deletion. Each step leaves every
suite green.

1. **Legacy aside.** Move today's `Combobox#render` and constants to
   `components/combobox/legacy.rb` (`Legacy::STIMULUS_CONTROLLER = "input-combobox"`, deleted in
   Phase 7). Point `date.rb`, `time.rb`, `config.rb`, and `trigger.rb` at `Legacy`; remove
   `Config#dropdown`/`#typeahead`. Update `lib/stimulus_plumbers.rb` requires and the config, date,
   time, and trigger tests.
2. **New `Components::Combobox`** (`STIMULUS_CONTROLLER = "combobox"`) on
   `Popover#build(mode: :manual)` and `build_panel` only. Rewrite `options.rb`, `option.rb`, and
   `option_group.rb`; add `control.rb` and `listbox.rb`; move `listbox_id_for` here; rewrite `dropdown.rb` and `typeahead.rb` as thin
   components over `Combobox` in a fixed mode, matching their helpers. Pass `popover_target: false` to the panel and assert no `data-popover-target` in
   output, so a combobox nested in `sp_popover` cannot steal the outer panel target.
3. **Helpers.** Rewrite `sp_combobox_dropdown` (select-only) and `sp_combobox_typeahead`
   (editable) per D10 with Phase 3 options only. `sp_combobox` keeps only the `c.date`/`c.time`
   block form, and `sp_combobox_date`/`sp_combobox_time` call `Legacy`; all removed in Phase 7. In the same step: helper tests, the dropdown/typeahead sections
   of both sandbox `combobox.html.erb` views, `combobox_accessibility_test.rb` selectors with an
   open-panel assertion before each scan (moved from Phase 5) plus an open grouped-options case,
   and `test/snapshots/components/popover/combobox.spec.js` selectors; drop its loading/empty
   cases until Phase 4.
4. **Form builder.** `inputs/combobox.rb` becomes the shared new path for `select.rb` (including
   collection and grouped) and `search.rb`; `datetime.rb` calls `Legacy`. The search clear button
   moves into the combobox group as a trailing slot with `input-clearable` on the root; add the
   `input_clearable_controller.js` guard (Escape does nothing while `aria-expanded="true"`) and its
   vitest case (moved from Phase 7). Update select, search, datetime, and builder tests and the
   search a11y test.
5. **Tailwind.** Switch the input-group reset from `[&>input]` to `[&>[role=combobox]]` and add
   `text-start`, so the select-only button has no double border or centred text before Phase 5.
6. **MCP.** `component_schema_loader.rb` `FIELD_AS_CONTROLLERS` maps select, search, and both
   collection types to `combobox`; update `component_schema_loader_test`,
   `component_requirements_test`, the `sp_combobox_dropdown` fixture in
   `component_docs_loader_test`, and `server_test`.
7. **Docs.** Rails `combobox.md` (keep a `### sp_combobox` heading with the option-formats aside and
   a code fence for the MCP fixture; the Option table gains a Description column), Rails `form.md`
   ("backed by" notes, group `aria-labelledby`), Rails README, `ARIA.md` (option/group ID chain;
   legacy section covers dialogs only), `stimulus-plumbers-rails/CLAUDE.md` folder tree, the
   `popover.md` ad-hoc `role="combobox"` example, and the Tailwind README "dropdown, typeahead"
   wording. CHANGELOG is generated at release.

Requirements:

- Ruby wires only what the JS declares: targets `control`, `input`, `panel`, `listbox`; values
  `mode`, `valuePolicy`, `closeOnCommit`; actions `onKeydown`, `onInput`, `onClick`, `onMousedown`.
  Write keys the contract scanner sees (`"#{STIMULUS_CONTROLLER}-target"`, literal
  `"combobox-mode-value"`). No `status`, `minLength`, or `source` until Phase 4.
- Phase 3 options: `name:`, `options:`, `value:`, `label:` (`aria-label`), `id:`,
  `close_on_commit:`, icons, and root HTML options; `value_policy:` on the typeahead only.
  `as: :search` passes `value_policy: :freeform`. `source:`, `min_length:`, and `match:` are
  Phase 4. Removed: the `c.dropdown`/`c.typeahead` block form, `url:`, and `close_on_select:` on the
  dropdown and typeahead (date/time keep it until Phase 7).
- Markup: root `data-controller="combobox"` with `mousedown->combobox#onMousedown click->combobox#onClick`; the input group
  with the control and icon siblings (the button holds plain text only); the hidden input; the
  manual panel `div` containing `ul#<panel>_listbox`. No `input-formatter` on select-only or
  editable.
- Options: IDs `<listbox>_option_<n>`; `aria-selected="true"` on the committed option, `"false"`
  elsewhere; no server `aria-activedescendant`; `data-label` and `aria-labelledby`/
  `aria-describedby` on label/description spans when a description is present; groups as
  `li[role=none] > ul[role=group][aria-labelledby]` with `li[role=none]` labels (today's group
  markup fails axe four ways).
- Control: no `aria-haspopup` (implicit); required, invalid, and described-by as `aria-*` on the
  control; `aria-autocomplete="list"` waits for Phase 4 filtering. Keep host creation in one method
  so the D3 AT decision can swap it.
- Run `npm run build` in `stimulus-plumbers` before the contract and MCP tests; the manifests are
  gitignored and the rake task only builds a missing one.
- Theme keys are unchanged in Phase 3 apart from step 5; renames, anchor, and active styling stay in Phase 5.
- Snapshot baselines expected to change (CI regenerates): `combobox.spec` dropdown, typeahead,
  preselected, disabled-option, and error; all `search.spec`; `form/choices`, `form/field_error`
  (select), and `form/sign_up`.
- Known follow-ups: `source:` needs a caller-stable `id:` and a display-label input for a
  preselected remote value (Phase 4); floating labels assume an input.
- Phase 4: an empty listbox does not open today; revisit with the status target so a remote query
  can open on loading. The `combobox_typeahead_loading`/`_icon`/`_empty` theme keys are unused until
  then.
- Phase 5: panel width (`anchor-size`) and group heading and option description styling;
  placeholder or prompt label when nothing is committed; the `combobox_option` `selected:` param
  is unused now that styling follows `aria-selected`; the form-builder select shows no focus ring
  because of the group's `ring-0` resets (WCAG 2.4.7, pre-existing).
- Phase 8 AT gate: a `<label for>` click activates the button host and opens the panel, unlike a
  native `<select>`.
- Phase 8 AT gate: the status is written as the panel opens; confirm "No results" is announced
  from a live region that was just shown, and that the theme hiding the empty listbox while
  `aria-controls` references it reads correctly.
- Phase 8 AT gate: each keystroke on a remote typeahead rewrites the status ('' then "Loading…");
  confirm it is not re-announced per key.
- Phase 5: rename `combobox_typeahead_empty` to `combobox_status` (4b adds loading and error).
- Follow-up: removing `data-controller` while the panel is open makes `combobox#disconnect` throw
  (the `control` target no longer resolves); element removal is fine. Pre-existing, found in 4b.
- Follow-up: `combobox-turbo` can still render a superseded frame whose body Turbo already read;
  it clears "Loading…" early and the next frame load corrects the results.
- Follow-up: an empty 200 HTML response leaves "Loading…" in the status for both adapters.

## Phase 4 — Filtering and remote results

Decided 2026-10-07: two sub-phases, each reviewed and committed on its own. The combobox stays
network-free; adapters own requests. Status announces empty, loading, and error only, never
counts. An editable combobox opens to show a non-empty status when nothing matches.

### Phase 4a — Local filtering and status

1. **Controller.** Add values `match` (`prefix` default, `contains`, `fuzzy` via `fuzzyMatcher`)
   and `minLength` (default `1`), the optional `status` target, and `emptyText` (default
   `"No results"`). Editable `onInput` filters before opening. A query shorter than `minLength`
   is the empty query and shows every option. Matching compares the normalized query (NFD,
   marks stripped, locale lower case) with the start of the normalized option label.
   An editable combobox without a `status` target logs an error.
2. **Filtering.** Toggle `hidden` on options; hide a group, or its presentational `li` wrapper,
   when it has no visible option; clear the active option if it is hidden. Then write `emptyText`
   to the status when no option is visible (otherwise clear it) and dispatch
   `combobox:results { query, count }`. Dispatch `combobox:query` only when the effective query
   changes. Select-only never filters.
3. **Open and close.** `openPanel` opens when an option is visible or the status has text.
   Closing clears the filter and the status, so opening without typing shows every option.
   Adopting a replacement listbox re-applies the current query.
4. **Rails.** Typeahead and the shared component accept `match:` and `min_length:` (editable only,
   validated like `value_policy:`); the control gets `aria-autocomplete="list"`; the editable panel
   renders `div[role=status][data-combobox-target=status]` after the listbox, with `emptyText` from
   `stimulus_plumbers.combobox.typeahead.empty`. The form builder passes `match`/`min_length`.
5. **Tailwind.** The status uses `combobox_typeahead_empty` and collapses when blank.
6. **Tests.** Vitest for the matchers, normalization, groups, threshold, query dedupe, status,
   `results`, opening with no match, and reset on close. Rails tests for the attributes and
   validation; an a11y case for the open no-results state; a snapshot of that state.
7. **Docs.** JS `combobox.md` (values, `status` target, `results` event, filtering rules), Rails
   `combobox.md` and `form.md` options, `ARIA.md` status bullet, spec D6 normalization.

### Phase 4b — Remote adapters

Adapter contract (documented in JS `combobox.md`): sit beside `combobox` on the root, listen for
`combobox:query`, cancel on `combobox:closed`, rely on `aria-busy` on the frame (Turbo) or the
listbox (fetch), write loading/error text to a shared `status` element, and replace the listbox
element in place with one carrying the same ID and the `combobox` listbox target. The combobox
adopts it through `listboxTargetConnected`. The Rails `source:` sets `match` to `none` so local
filtering never runs on server results.

1. **`combobox-turbo`** (like `modal-turbo`): owns the `frame` target, debounces with `delay`,
   sets the frame `src` with the query param; Turbo 8 cancels the superseded request. An empty
   query navigates to the default set without debounce. Errors come from
   `turbo:before-fetch-response` (a non-HTML failure fires nothing else), `turbo:frame-missing`,
   and `turbo:fetch-request-error`;
   a new query or closing removes the frame `src`, which cancels the in-flight request.
2. **`combobox-fetch`**: same values; fetches through `Requestor` (abort on supersede), parses
   the response, and replaces the listbox with the response listbox of the same ID. No Turbo
   dependency; npm only (decided 2026-10-07), Rails does not render it.
3. **Rails.** `source:` (requires a caller-stable `id:`) always uses `combobox-turbo`; `param:`
   (default `q`), loading and error I18n; a results helper renders the matching frame from `id:`
   and `options:`. A preselected remote value passes its option in
   `options:`.
4. **Sandbox.** A results endpoint and a remote typeahead section.
5. **Tests.** Vitest per adapter: debounce, supersede, empty query, error, busy, disconnect.
   Rails: helper output, results helper, direct endpoint visit. Snapshots: loading and error.
6. **Docs.** Adapter sections in JS `combobox.md`, Rails options, spec D7/D8 (adapter owns the
   frame; `combobox-fetch`), migration from `url:`.

## Phase 5 — Tailwind theme and sandbox

Decided 2026-10-07: two sub-phases, each reviewed and committed on its own. The active option
keeps its tint and adds a 2px inset outline, which survives forced colors.

### Phase 5a — Theme

1. **Anchor.** Root `[anchor-scope:--sp-field]`, group `[anchor-name:--sp-field]`, panel
   `[&[popover]]:[position-anchor:--sp-field]` (beats the popover's `auto`) and
   `[min-inline-size:anchor-size(inline)]`. In a form field the root is the visible box, so the
   form theme moves the name to the root and clears it on the group. The legacy date/time comboboxes
   share these keys and the option outline, so their open snapshots change; accepted, since
   Phase 7 removes them.
2. **Option.** Active: tint plus `outline-solid outline-2 -outline-offset-2` in primary. New keys
   `combobox_option_description` (own line, muted, small) and `combobox_option_group_label`; the
   Rails option and group render them. Drop the unused `selected:` theme param.
3. **Status.** Rename `combobox_typeahead_empty` to `combobox_status`; remove the unused
   `combobox_typeahead_loading` and `_icon` keys.
4. **Form focus.** The form-builder combobox root shows the focus ring (`focus-within`); the
   floating variant shows the primary border.
5. **Tests.** Theme unit tests on semantic tokens only; Rails option/group/status tests; an a11y
   active-option state; snapshot cases for the active option, forced colors (Chromium), and a
   focused form field; a browser spec that the panel is flush with and at least as wide as the
   field (standalone and form).
6. **Docs.** Rails `theme.md` and `combobox.md` theme keys.
7. Placeholder for an empty select-only control is dropped: the form builder's `prompt:` and
   `include_blank:` already render a labelled empty option.

### Phase 5b — Browser behavior

Decided 2026-10-08: the spec's browser list splits by engine. Behavior that is the same in every
engine is a Rails a11y test (Chromium); `test/browser` keeps what differs by engine, touch, or CSS.

- Sandbox: a combobox-in-modal section on both combobox pages; a clearable search with choices on
  both search pages.
- Rails a11y (`combobox_accessibility_test.rb`, `search_accessibility_test.rb`): open with click,
  Arrow Down, and Arrow Up; a second click closes select-only, editable stays open; commit by Enter
  and option click with focus kept; Escape without commit; Tab commits and moves on; outside click
  and focus leaving close; local filtering and remote results keep focus; in a modal, Escape closes
  only the panel; search's first Escape closes the panel, the second clears; scans of new states.
- Browser (`combobox.spec.js`, `search.spec.js`): clicks on the select-only control, an option,
  and the icon keep focus on the control; tap outside closes; touch scrolling does not (Chromium);
  focus moving into an iframe closes (not Firefox: Playwright fires no blur there); in a modal,
  Escape closes only the panel and the panel is anchored to the field; RTL anchoring; 320px reflow;
  search's clear button keeps focus. Reduced motion is a popover theme check in `popover.spec.js`.
- Controller: a window `blur` closes the panel while an iframe has focus (spec D5 amended).
- Snapshots for the new sections, closed and open.
- Not automated: Escape during IME composition; dragging the panel scrollbar (headless engines
  have overlay or hidden scrollbars); iframe focus in Firefox.
- Follow-up: in Firefox, a panel under an RTL ancestor of an LTR document sits 16px off its field.

## Phase 6 — Calendar and calendar field

Task-level plan: [calendar and calendar field](./2026-10-10-calendar.md) (6a–6f). It
covers the date-only core, the `calendar_controller` with the D5 grid keyboard contract, Turbo
navigation, and `sp_calendar_field`, which Phase 7a replaces. This phase gates Phase 7.

## Phase 7 — Date/time comboboxes and legacy retirement

Decisions (2026-10-11), replacing `sp_calendar_field`:

- `sp_combobox_date` and `sp_combobox_time` match the legacy `date-*`/`time-*` snapshots: a
  read-only `role="combobox"` input with a decorative trailing icon and a panel anchored below.
- The panel is a non-modal popover (`aria-haspopup="dialog"`); "dialog" names stay with `sp_modal`.
- `input-formatter` renders the display for both; `format:` is passed as its options, with
  `locale` defaulting to `I18n.locale`. A hidden input submits `YYYY-MM-DD` or `HH:MM`.
- Desktop and mobile share one behaviour: the same popover, focus, click (input, icons, padding),
  ArrowDown, Tab or focus leaving, outside click, and Escape rules.
- API follows the combobox family: `name:`, `value:`, `label:`/`labelledby:`, `id:`, `control:`;
  the form builder supplies them for `as: :date`/`as: :time`.
- Open on focus is on by default (`open_on_focus:`); `popover#onFocus` skips it inside an open
  modal, after focus returns from the panel, and before any user input since connect.
- Focus stays in the input on open; ArrowDown moves to the grid's Tab stop or the first column.
- Floating labels work as for the other combobox variants; `icon_leading`/`icon_trailing` decorate.
- Theme keys: `combobox_date_popover`, `combobox_time_popover`; `combobox_popover` splits into
  `combobox_dropdown_popover` and `combobox_typeahead_popover`.

### Phase 7a — `sp_combobox_date`

- Replace legacy `combobox-date` (JS, Rails, helper) in place with the `sp_calendar` grid; remove
  `sp_calendar_field`, `CalendarField`, `calendar-field`, and the `calendar_field*` theme keys.
- `popover` gains `onFocus`/`onClick`/`onKeydown` adapters behind `open_on_focus:`.
- `as: :date` renders `sp_combobox_date`; MCP `FIELD_AS_CONTROLLERS` follows.
- Snapshots match the legacy `date-*` baselines; Rails a11y covers focus, ArrowDown, Escape, Tab,
  commit, the in-modal case, and axe.

### Phase 7b — Calendar render modes

Decisions (2026-10-14), amending spec D7:

- `sp_calendar(navigation: :stimulus | :turbo)`, default `:stimulus`; `sp_combobox_date` uses the
  default.
- `:stimulus`: Ruby renders the template (root, status, header, grid skeleton) without labels or
  cells; `calendar` renders and redraws the period with `Intl`. Previous, next, and zoom are
  buttons; changing period needs no request.
- `:turbo`: Ruby renders the full period with Rails I18n inside `turbo-frame#<id>_frame`; a
  `calendar-turbo` adapter loads periods from the period URL (links and keys) and maps Turbo
  response, frame-missing, and fetch errors to `calendar-turbo:failed->calendar#onFailed`.
- The JS package works without Rails: every value is optional. `locale` defaults to the browser
  locale; `firstDayOfWeek` to `Intl.Locale#getWeekInfo`/`weekInfo` for that locale, then Monday.
  Rails passes `I18n.locale` and its resolved first day; the JS controller API is the interface.
- `calendar` keeps keys, selection, the single Tab stop, focus intent, the status, and events in
  both modes; `navigate` carries the period `url`. Turbo frames set `aria-busy` while loading;
  stimulus mode draws synchronously.
- Drift guard: JS renders with `src/date` on the shared fixtures; a parity test renders the same
  inputs in both modes and compares roles, ids, `data-date`, `aria-*`, and the Tab stop; the
  calendar a11y tests and snapshots run in both modes.
- Tests: vitest for rendering, locale/week defaults, the adapter, `onFailed`, and busy; Rails unit
  for each mode's template and wiring; a11y and snapshots per mode.

### Phase 7c — `sp_combobox_time`

- `Combobox::Temporal` holds the shared read-only trigger, hidden input, popover, and `format:` locale default;
  `Date` and `Time` subclass it, and `TriggerGroup` renders the icon group for it and `Control`.
- Port the legacy hour/minute/period columns onto it as listbox columns with `aria-activedescendant`;
  `as: :time` renders it with `format:` (Intl options; `hourCycle` defaults to `h12` and picks the columns) and `step:`.
- Each column choice updates the value; Enter, Tab, focus leaving, or an outside click closes
  and keeps it; Escape closes and restores the value from when the panel opened.
- The input text uses `Intl` with the locale and hour cycle, so AM/PM is localized; the period
  column labels come from Rails I18n.
- Remove the Rails legacy composition it replaces: `Combobox::Legacy`, `Config`, the legacy `Trigger`, and `sp_combobox`.

### Phase 7d — Retire legacy

- Delete `input_combobox_controller.js`, `combobox_dropdown_controller.js`, the legacy calendar
  controllers, selectors, plumbers, the unused `ContentLoader` and `plumber/date.js`, `sp_calendar_month`, `sp_calendar_turbo*`,
  `Calendar::Turbo::*`, legacy `Calendar#month/year/decade`, and the orphaned
  `ListboxNavigation`, with their tests, exports, sandbox pages, snapshots, legacy theme keys, and locale keys.
- Modify `ARIA.md`, both READMEs, both `combobox.md` and `calendar.md` docs, the accessibility docs, and MCP.
- Regenerate manifests; update MCP tests.
- `Calendar.frame_id_for` keeps its name and the `<id>_frame` id that Turbo responses match.

### Phase 7e — Shared listbox and loading helpers

- `ActiveDescendant` (`src/accessibility/keyboard.js`): the passive active-option helper behind
  `combobox` and each `combobox-time` column; the controllers keep their key mapping.
- `FragmentLoader` plumber: fetch, same-id swap, `aria-busy`, cancel, and reject on failure.
  `combobox-fetch` adds the query, debounce, and status text on top; the new `popover-fetch` adds
  load-on-open, optional reload, status text, and focus continuity.

### Phase 7f — Rename `Control` to `Trigger`

- Rename `Combobox::Control` to `Combobox::Trigger`, the `control:` option to `trigger:`, and the JS
  `control` target to `trigger`, following the `Popover::Trigger`/`Modal::Trigger` convention, with
  the docs, tests, and contract wiring.

## Phase 8 — Release gates

- [x] Full suites: vitest, Rails unit and a11y, Tailwind unit, MCP, browser (all projects).
- [ ] Manual AT: VoiceOver/Safari and NVDA/Firefox for name, expanded state, active option,
      commit, result status, and validation errors.
- [ ] CI snapshot regeneration, handled by the user.
- [x] Changelog: generated automatically at release.
- [x] No legacy combobox composition or compatibility mode ships.

## Review checklist for every phase

- The diff contains only phase-owned files and intentional generated output.
- Tests assert public behavior at the owning layer and fail for the regression they name.
- Targeted checks and the full package suites pass; `git diff --check` passes.
- Docs and CLAUDE.md sections that reference changed APIs are updated in the same phase.
