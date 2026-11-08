# Popover Modernization Implementation Plan

> **For agentic workers:** Implement one phase at a time. The primary agent designs and reviews
> each phase; a Luna agent implements it at high reasoning effort and does not commit. A phase is
> committed only after the primary agent reviews the complete diff and reruns its required checks.

**Goal:** Replace the legacy popover composition with a native HTML Popover API lifecycle,
CSS-owned anchor positioning, the existing `sp_popover` Rails builder, and Turbo Frame composition,
without introducing a second state machine or new public vocabulary.

**Architecture:** A purpose-built `Popover` plumber follows the repository's modern `Dialog` plus
`attachDialog` convention. `popover_controller` privately owns that adapter and exposes only
`open`, `close`, and `toggle`. Rails renders the native relationship and existing IDs; the
Tailwind theme owns positioning and transitions. Turbo Frames own remote content. Semantic
components such as combobox own roles, keyboard behavior, focus, and selection.

**Tech stack:** Stimulus 3, HTML Popover API, CSS Anchor Positioning, Turbo 8 in the existing
sandbox import map, Vitest/jsdom, Rails/Action View/Minitest, axe-core, Playwright, and Tailwind 4.

**Design:**
[`docs/superpowers/specs/2026-09-11-overlay-foundation-modernization-design.md`](../specs/2026-09-11-overlay-foundation-modernization-design.md)

## Decisions already recorded

- Product Decision 1A: implement popover first, redesign combobox immediately afterward, and
  release them together. Do not add a legacy combobox compatibility mode.
- Product Decision 2A: keep native CSS Anchor Positioning as the only production path and narrow
  the WebKit contract for a popover inside a native dialog after document scrolling. Keep the real
  WebKit assertion running as an expected failure; do not add compatibility positioning.
- `Popover` and `attachPopover` are a new implementation of an existing plumber/factory convention,
  not a new architectural layer.
- `sp_popover` remains the single public Rails builder. `Components::Popover#build` remains only
  the existing wrapper-free first-party composition seam.
- A caller-supplied stable ID is optional. Preserve `panel_id || Popover.panel_id_for(sp_dom_id)`;
  wrapper `id:` remains an ordinary HTML option.

## Global constraints

- Branch: `design`.
- Commit every accepted phase with `git commit --no-gpg-sign` and a focused message.
- The implementation agent never commits and never updates visual snapshot baselines.
- Keep runtime vocabulary to `Popover`, `popover_controller`, and `sp_popover`. Do not introduce an
  `Overlay` class/controller/target/helper or rename established theme keys without approval.
- Do not subclass the legacy `Plumber` base, call `enhance()`, define plumbing properties on a
  controller, or wrap Stimulus lifecycle methods.
- Keep the plumber and controller adapter references in true private fields. Do not expose test
  getters or inspect private state from tests.
- Do not attach state, callbacks, registries, fixtures, or assertions to `window`/`globalThis`.
- Do not add a runtime dependency. `@hotwired/turbo` is already a JavaScript development dependency
  and already loads through both Rails sandboxes' import maps.
- Do not add fetch/template loading to `popover_controller`; real Turbo Frames own remote content.
- Do not add generic focus movement, focus restoration, ARIA roles, or live-region announcements.
- Do not add `closeOnSelect`. Selection-driven closing belongs to the consuming component.
- Only unsupported `mode:` raises `ArgumentError`. Placement follows the existing theme
  warning/fallback convention; consumer-owned role/name combinations are not newly validated.
- Nested popover, popover-inside-modal, and top-layer ordering tests live under
  `test/browser/components/popover/popover.spec.js`, not the modal suite. `test/browser` owns
  engine-native behavior; `test/snapshots` owns screenshots only.
- Tests wait on controller connection, events, native state, Turbo events, or DOM outcomes. No
  fixed sleeps, global test hooks, hand-replaced Turbo DOM, or policy mutation to manufacture cases.
- The user owns Linux visual snapshot updates. Implementation phases may add or revise Playwright
  assertions but must not update files under `test/snapshots/__screenshots__`.
- Preserve unrelated worktree changes. Before every commit, inspect `git status --short` and the
  staged diff.

## Phase 0 — Approve the executable plan

**Files:**

- Modify:
  `docs/superpowers/specs/2026-09-11-overlay-foundation-modernization-design.md`
- Create: `docs/superpowers/plans/2026-09-15-popover-modernization.md`

- [ ] Confirm Product Decision 1A is definitive everywhere; remove conditional 1B implementation
      language.
- [ ] Confirm the convention guard identifies `Dialog`/`attachDialog` as the precedent and calls
      `Popover` the sole approved new implementation.
- [ ] Confirm the ID contract reuses `sp_dom_id` and `Popover.panel_id_for` without requiring a
      stable caller ID or adding another resolver.
- [ ] Run formatting and whitespace checks.

Commands from the repository root:

```sh
node_modules/.bin/prettier --check docs/superpowers/specs/2026-09-11-overlay-foundation-modernization-design.md docs/superpowers/plans/2026-09-15-popover-modernization.md
git diff --check
```

Commit after review:

```sh
git add docs/superpowers/specs/2026-09-11-overlay-foundation-modernization-design.md docs/superpowers/plans/2026-09-15-popover-modernization.md
git commit --no-gpg-sign -m "docs: plan native popover modernization"
```

## Phase 1 — Native `Popover` plumber

**Files:**

- Create: `stimulus-plumbers/src/plumbers/popover.js`
- Create: `stimulus-plumbers/tests/unit/plumbers/popover.test.js`
- Modify: `stimulus-plumbers/src/plumbers/index.js`
- Modify: `stimulus-plumbers/src/index.js`
- Create: `stimulus-plumbers/docs/plumber/popover.md`

**Public contract:**

```text
Popover.prototype = constructor, open, show, hide, toggle, disconnect
attachPopover(controller, options) -> Popover
options.element -> native popover element
options.prefix -> "popover" by default
```

Implementation requirements:

- Use private fields for the controller, panel, listener functions, and connected state.
- Treat native state as authoritative through `panel.matches(":popover-open")`.
- Listen to `beforetoggle` and `toggle` on the panel; remove exactly those listeners in an
  idempotent `disconnect()`.
- For an opening `beforetoggle`, dispatch cancellable `popover:before-open` from the panel through
  the existing Stimulus dispatch convention. If it is canceled, prevent the native transition.
- On settled native `toggle`, dispatch `popover:opened` or `popover:closed` once for that observed
  transition. Preserve `event.source` when supplied and normalize an absent source to `null`.
- `show(source?)` and `toggle(source?)` pass a real source through native options; an omitted source
  uses the no-argument native call. `hide()` uses the native hide path.
- Guard redundant open/close requests using native state. Let genuine native API errors retain
  their platform meaning; do not translate them into new package exceptions.
- An invalid element creates an inert adapter, matching the `Dialog` plumber's constructor
  convention. Configuration reporting remains the controller's responsibility.
- Do not copy Dialog focus restoration, dismissal fallbacks, timers, or result semantics: those
  solve modal-specific platform behavior and are outside the popover contract.

Tests must cover the exact prototype, factory, native calls with and without source, native state
reflection, cancellable before-open, declarative/external native events, settled events, rapid
toggle coalescing, listener removal, repeated disposal, and inert invalid elements. Native methods
may be narrowly mocked on each fixture element; no global state or production test hook.

Verification from `stimulus-plumbers/`:

```sh
node --run test -- tests/unit/plumbers/popover.test.js
node --run lint
node --run build
```

Commit after primary-agent review:

```sh
git commit --no-gpg-sign -m "feat: add native popover plumber"
```

## Phase 2 — Private Stimulus controller ownership

**Files:**

- Replace: `stimulus-plumbers/src/controllers/popover_controller.js`
- Replace: `stimulus-plumbers/tests/unit/controllers/popover_controller.test.js`
- Modify: `stimulus-plumbers/tests/unit/build-controllers-manifest.test.js`
- Generated by the existing build: `stimulus-plumbers/dist/controllers.manifest.json`
- Modify: `stimulus-plumbers/docs/component/popover.md`

Controller contract:

```text
identifier: popover
targets: trigger (optional), panel (required)
values: none
actions: open(event?), close(event?), toggle(event?)
dispatches: before-open, opened, closed
```

Implementation requirements:

- Retain the adapter as `#popover` and its panel as a private reference.
- Attach from `panelTargetConnected`; dispose the previous adapter before replacement.
- Dispose only the matching adapter from `panelTargetDisconnected`; dispose again safely from
  `disconnect`.
- Register one `turbo:before-cache` listener during `connect`, remove it during `disconnect`, and
  synchronously hide an open panel before caching.
- `open` and `toggle` use `event.currentTarget` when invoked as actions, otherwise the optional
  trigger target. `close` needs no source. Prevent default only for an event-like argument.
- Synchronize `aria-expanded` only on an authored trigger that already has the attribute.
- A missing or non-popover panel logs one concise configuration error per invalid configuration
  and leaves actions inert. Do not raise during Stimulus connection.
- Remove all loader/template/fetch, `Visibility`, `Dismisser`, `focusFirst`, announcement,
  `closeOnSelect`, and legacy value behavior.

Tests must cover connection timing without sleeps, missing/invalid targets, actions and
programmatic calls, target replacement, same-instance reconnect, exact cleanup, authored versus
absent `aria-expanded`, external native calls, cache cleanup, and the exact generated manifest.

Verification from `stimulus-plumbers/`:

```sh
node --run test -- tests/unit/plumbers/popover.test.js tests/unit/controllers/popover_controller.test.js tests/unit/build-controllers-manifest.test.js
node --run test
node --run lint
node --run build
```

Commit after primary-agent review:

```sh
git commit --no-gpg-sign -m "refactor: adopt native popover lifecycle"
```

## Phase 3 — Preserve the Rails builder convention

**Files:**

- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/popover.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/popover/trigger.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/popover/panel.rb`
- Modify: `stimulus-plumbers-rails/test/stimulus_plumbers/components/popover_test.rb`
- Modify only as required:
  `stimulus-plumbers-rails/test/stimulus_plumbers/helpers/popover_helper_test.rb`
- Modify: `stimulus-plumbers-rails/test/tasks/support/component_manifest_test.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema/popover/ranges.rb`
- Modify: `stimulus-plumbers-rails/test/stimulus_plumbers/themes/base/layout_test.rb`

Renderer contract:

- `sp_popover` remains the only documented public builder.
- `render(panel_id: nil, mode: :auto, placement: :block_end_start, **html_options)` renders the
  existing wrapper with the `popover` controller.
- `build(panel_id: nil)` preserves the existing wrapper-free first-party seam.
- The panel ID remains `panel_id || Popover.panel_id_for(template.sp_dom_id)`.
- Wrapper `id:` remains a wrapper attribute and never becomes a panel relationship prefix.
- The packaged zero-arity trigger is a button with `popovertarget`; do not also wire a Stimulus
  click toggle.
- Preserve the one-arity trigger block's established hash-yielding shape: it receives `panel_id`,
  optional semantic ARIA, and `data-popover-target="trigger"`. It receives no inferred activation
  action because no single event is correct for both a custom button and an editable input. The
  consumer adds its appropriate `popover#open`/`popover#toggle` action or owns the plumber through
  its semantic controller.
- `haspopup:` defaults to `nil`. Only when supplied, author `aria-haspopup`,
  `aria-expanded="false"`, and `aria-controls`. Preserve the existing `controls:` override used by
  semantic consumers whose controlled widget is inside the panel.
- The panel receives `id`, `popover="auto|manual"`, `data-popover-target="panel"`, and the
  placement theme option. Remove `hidden`.
- `role`, `aria_label`, and `aria_labelledby` are panel pass-through semantics; do not infer or
  require them.
- Reject only unsupported `mode:` with `ArgumentError`. Use existing theme fallback behavior for
  an unknown placement.
- Keep all option combination through `merge_html_options`.
- Add the placement allow-list through the existing component-specific schema range convention
  (`Popover::Ranges::PLACEMENT`), matching `Modal::Ranges::SIZE`; this is theme validation data,
  not a new runtime abstraction or public product term.

Tests must cover both trigger block forms, generated and caller-supplied panel IDs, an unrelated
wrapper ID, native attributes, semantic omission/pass-through, custom classes/data/actions, manual
mode, placement fallback, wrapper-free `build`, and exact manifest wiring.

Verification from `stimulus-plumbers-rails/`:

```sh
bundle exec ruby -Itest test/stimulus_plumbers/components/popover_test.rb
bundle exec ruby -Itest test/stimulus_plumbers/helpers/popover_helper_test.rb
bundle exec ruby -Itest test/tasks/support/component_manifest_test.rb
bundle exec rake test:unit
bundle exec rake rubocop
```

Under Product Decision 1A, the focused Phase 3 tests and RuboCop must pass, while the full unit
suite is expected to expose exactly five legacy-combobox boundary failures until Phase 7:

- the date, dropdown, typeahead, and time helper tests still expect the composed popover panel to
  carry `hidden`;
- `StimulusContractTest#test_every_ruby_action_exists_as_a_js_method` still finds the legacy
  combobox wiring to removed `popover#closeOnSelect`.

Do not suppress, skip, rewrite, or restore compatibility behavior to make these pass. Any other
failure blocks the phase. Phase 7 must remove all five by replacing the legacy combobox path, and
the complete Rails unit suite must then pass before release.

Resolved 2026-10-05 on `fix/popover`: the legacy `input-combobox` took over close-on-select through
a `panel` target and `closeOnSelect` value, and the helper tests assert a native `auto` panel. This
is unreleased branch state; Phase 7 replaces it with the single `combobox` controller.

Commit after primary-agent review:

```sh
git commit --no-gpg-sign -m "feat: render native Rails popovers"
```

## Phase 4 — Native positioning, theme, and browser evidence gate

**Files:**

- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/layout.rb`; keep the
  existing popover theme keys in their current module.
- Modify: `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/layout_test.rb`
- Modify: `stimulus-plumbers-tailwind/test/sandbox/app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css`
- Modify: `stimulus-plumbers-tailwind/app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css`
- Modify both sandbox popover views as needed.
- Create: the `positioning` describe in
  `stimulus-plumbers-tailwind/test/browser/components/popover/popover.spec.js`; the browser config
  already runs Chromium desktop/mobile, Firefox, and WebKit.

Implementation requirements:

- The packaged button relies on its native implicit anchor. Programmatic opening passes the input
  as `source`. The panel uses `position-anchor: auto`.
- Map the approved semantic placements to logical `position-area` values and
  `position-try-fallbacks`; do not expose physical coordinates as the Rails API.
- Keep maximum inline/block size and overflow reachable for long content.
- Theme/animation CSS owns opacity and transform transitions. Do not write inline styles or let
  placement code overwrite transforms/transitions.
- Include reduced-motion and forced-colors behavior in the existing theme conventions.

The Playwright matrix must exercise button and programmatic sources, viewport edges, scroll
containers, RTL, vertical writing mode, zoom, transformed ancestors, collision fallback,
long-content overflow, and popover placement inside a native dialog.

**Decision gate:**

- Product Decision 2A was recorded from the matrix evidence: Chromium 149 and Firefox 151 passed;
  WebKit 26.5 failed only for a popover inside a native dialog after document scrolling, rendering
  the panel at `y = -232` for a source ending at `y = 348` despite positive support queries.
- Keep that WebKit assertion active with Playwright's expected-failure contract. Do not skip it,
  weaken its geometry assertion, or add a production browser branch. An unexpected pass must fail
  the suite so the narrowed boundary is revisited when WebKit changes.
- Never route failures through `Flipper` or `Shifter` without a new product decision.

Verification from `stimulus-plumbers-tailwind/`:

```sh
bundle exec ruby -Itest test/stimulus_plumbers/themes/tailwind/layout_test.rb
bundle exec rake test:unit
bundle exec rake rubocop
node --run format:check
node --run test:browser -- test/browser/components/popover/popover.spec.js
```

Commit after the matrix matches the recorded support boundary and the primary agent reviews the
evidence:

```sh
git commit --no-gpg-sign -m "feat: position native popovers"
```

## Phase 5 — Lifecycle, Turbo, nesting, and accessibility coverage

**Files:**

- Modify: `stimulus-plumbers-rails/test/sandbox/app/views/components/popover.html.erb`
- Modify: `stimulus-plumbers-tailwind/test/sandbox/app/views/components/popover.html.erb`
- Modify the existing popover route/controller files only for real application-owned Turbo Frame
  responses.
- Modify:
  `stimulus-plumbers-rails/test/accessibility/components/popover/popover_accessibility_test.rb`
- Create or rename into the concise suite, one spec per route:
  - `stimulus-plumbers-tailwind/test/browser/components/popover/popover.spec.js`
  - `stimulus-plumbers-tailwind/test/browser/components/popover/turbo.spec.js`
  - `stimulus-plumbers-tailwind/test/snapshots/components/popover/popover.spec.js` (screenshots)

Coverage requirements:

- Declarative and programmatic opening, Escape, native light dismissal, external native calls,
  cancellable before-open, settled events, rapid transitions, and consumer-owned focus.
- Real Turbo Frame lazy loading, `[busy]`/`[complete]`, matching replacement, missing-frame
  behavior, panel target replacement, and `turbo:before-cache` restoration.
- Popover inside a real modal, nested popovers, top-layer order, and sequential Escape behavior.
- Closed/open unnamed structural content and consumer-named menu/help examples in axe coverage.
- No popover-only production endpoint, direct `window` state, synthetic frame DOM replacement,
  fixed timing sleep, or test-only policy switch.

Verification:

```sh
cd stimulus-plumbers-rails && bundle exec rake test:accessibility
cd ../stimulus-plumbers-tailwind && node --run test:browser -- test/browser/components/popover
```

Run existing visual assertions without updating their baseline. Report intended snapshot changes
to the user for the repository's Linux update workflow.

Commit after primary-agent review:

```sh
git commit --no-gpg-sign -m "test: cover native popover integration"
```

## Phase 6 — Migration and package documentation

**Files:**

- Modify: `stimulus-plumbers/README.md`
- Modify: `stimulus-plumbers/docs/component/popover.md`
- Modify: `stimulus-plumbers/docs/plumber/popover.md`
- Modify: `stimulus-plumbers-rails/docs/component/popover.md`
- Modify relevant package changelog/release source only if the repository convention requires it.

- [ ] Document the exact controller targets/actions/events and absence of values.
- [ ] Document `sp_popover` options, both block forms, optional IDs, semantic ownership, manual mode,
      and placement tokens.
- [ ] Replace fetch/template examples with server-rendered content or matching Turbo Frames.
- [ ] Include old/new markup and explicitly remove `closeOnSelect`, generic announcements,
      `controller.visibility`, `shift()`, and `flip()` dependencies.
- [ ] Document progressive enhancement and ordinary Hotwire Native WebView behavior without
      claiming native modal navigation or sheets.
- [ ] Keep wrapper-free `build` out of application-facing documentation.

Verification from the repository root:

```sh
node_modules/.bin/prettier --check docs/superpowers/specs/2026-09-11-overlay-foundation-modernization-design.md docs/superpowers/plans/2026-09-15-popover-modernization.md
git diff --check
```

Also rerun the full JS, Rails, Tailwind unit, accessibility, and cross-browser non-snapshot suites
from earlier phases.

Commit after primary-agent review:

```sh
git commit --no-gpg-sign -m "docs: document native popover migration"
```

## Phase 7 — Coordinated combobox handoff and release gate

The popover implementation can be complete at this point, but Product Decision 1A prevents an
independent release.

- [x] Re-audit
      `docs/superpowers/specs/2026-09-11-combobox-modernization-design.md` against the implemented
      `Popover` plumber, the unchanged `sp_popover` public-builder rule, and the existing combobox ID
      resolution chain. Amended 2026-10-05 (`manual` panel, APG selection, Tab commit, field-group
      anchor); the calendar redesign joins the release.
- [ ] Resolve how the new single `combobox` controller privately owns `Popover` without retaining
      the old sibling `popover` controller or `closeOnSelect` action. Reuse a renderer composition seam
      only if it preserves existing builder conventions; request a product decision before adding a
      new config object, namespace parameter, or public helper.
- [ ] Write and approve a separate task-level combobox implementation plan:
      [`2026-10-05-combobox-modernization.md`](./2026-10-05-combobox-modernization.md).
- [ ] Implement and review combobox phase by phase under the same Luna/primary-agent workflow.
- [ ] Run combined upgrade, browser, accessibility, manual AT, and user-owned snapshot gates.
- [ ] Release only when neither the old popover composition nor a temporary combobox compatibility
      mode remains in the shipped path.

## Review checklist for every phase

- The diff contains only phase-owned files and intentional generated output.
- Public names match the design and existing repository terminology.
- No new dependency, global state, test hook, temporary fallback, duplicate state machine, or
  unexplained validation has appeared.
- Stimulus lifecycle ownership is explicit and repeatable across disconnect/reconnect and target
  replacement.
- Tests assert public behavior at the owning layer and would fail for the regression they name.
- Targeted checks and the relevant full package suite pass.
- `git diff --check` passes.
- The primary agent—not the implementation agent—stages and commits with GPG signing disabled.
