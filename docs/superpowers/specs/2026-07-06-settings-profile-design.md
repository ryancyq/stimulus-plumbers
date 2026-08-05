# Settings/Profile composition + Tabs design

## Scope

Fourth and last of the four Flowbite-inspired sub-projects (see `2026-07-06-status-primitives-design.md`, `2026-07-06-qr-code-design.md`, `2026-07-06-map-design.md` for the first three). Covers:

1. **Profile summary card** — pure composition of existing components, doc recipe only, no new code.
2. **Sidebar settings nav** — pure composition of existing `sp_list` + `active:`, doc recipe only, no new code.
3. **`Form::Builder#section`** — new small public API generalizing the existing internal `Fields::Fieldset` into a way to group arbitrary fields under a heading.
4. **Tabs** — new component: a true ARIA tabs widget (tablist/tab/tabpanel), automatic activation, supporting both eagerly-rendered and lazy (Turbo Frame) panels.

## Part 1 & 2: Profile card and sidebar nav (doc recipes, no new code)

No new components. Documented in `stimulus-plumbers-rails/docs/guide.md` under a new "Composing a settings/profile page" section:

- **Profile summary card**: `sp_card` wrapping `sp_avatar` + a name/heading + `sp_link` (edit action) — links to each component's own doc rather than re-explaining their options.
- **Sidebar nav**: `sp_list` with `active:` set on the current section's item — already renders `aria-current="page"` (verified in `components/list/item.rb`'s `render_link_or_button`). No behavior change needed; this is purely a usage example.

## Part 3: `Form::Builder#section`

### Problem

`Fields::Fieldset` (`lib/stimulus_plumbers/form/fields/fieldset.rb`) already renders a themed `<fieldset><legend>` wrapper with correct ARIA (`aria-describedby`, `aria-invalid`), but it's only reachable internally, for checkbox/radio choice groups. Settings pages need the same grouping (heading + fieldset semantics) around arbitrary sets of fields (e.g. "Profile" section containing a text field and an email field, not a choice group).

### Design

- New public method on `Form::Builder`: `f.section(title, &block)`.
- Renders `<fieldset><legend>title</legend>{block content}</fieldset>` — reuses `Fields::Fieldset`'s legend-rendering logic (via `Label.new(template).render(text:, tag: :legend)`, already used there), generalized to accept a caller-supplied block instead of a fixed choice-group renderer.
- No new ARIA behavior beyond what `<fieldset><legend>` provides natively (groups fields for assistive tech, associates the heading). No `aria-describedby`/error wiring at the section level — errors remain per-field, unchanged.
- No layout options beyond the wrapping itself (no `columns:`, no nested sections) — matches the "minimal API" precedent set in the other three sub-project designs.

### Testing

- `test/stimulus_plumbers/form/builder_test.rb`: `f.section` renders `<fieldset>`/`<legend>` with the given title; block content renders inside; nested `f.field` calls inside a section render normally (no interference with existing field rendering).

### Docs

`stimulus-plumbers-rails/docs/component/form.md` gains an `f.section` entry.

## Part 4: Tabs

### Design

True ARIA tabs widget — `role="tablist"`/`role="tab"`/`role="tabpanel"`, automatic activation (arrow-key focus movement immediately switches the visible panel), reusing the existing `RovingTabIndex` helper (`src/accessibility/*` — the same roving-tabindex mechanism already used by `reorderable` and the calendar controllers for Arrow/Home/End focus movement) rather than writing new keyboard-handling logic.

### Targets

| Target | Element | Description |
| --- | --- | --- |
| `tab` | `<button role="tab" aria-controls aria-selected>` | One per tab; roving-tabindex managed across this target list |
| `panel` | `<div role="tabpanel" hidden>` | One per tab; may directly contain content (eager) or wrap a `<turbo-frame src="..." loading="lazy">` (lazy) |

### Methods

- `connect()` — wires `RovingTabIndex` over `tab` targets; shows the initial active panel (index from `active:` render option, default `0`), hides the rest.
- `onKeydown(event)` — delegates to `RovingTabIndex` for Left/Right/Home/End; on any focus move, immediately calls `select(newIndex)` (this is the automatic-activation behavior).
- `select(index)` (wired to both keydown-roving and `click`) — sets `aria-selected` on the target tab, unsets on others; shows the target `panel`, hides others; dispatches `tabs:changed`.

### Why automatic activation + lazy panels aren't actually in tension

WAI-ARIA generally recommends manual activation when switching is expensive (e.g. lazy-loaded content), to avoid firing a fetch on every arrow keypress while a user tabs through. Here, unhiding a panel (removing `hidden`) is what makes a `loading="lazy"` Turbo Frame intersect the viewport and trigger its fetch — and Turbo retains a frame's loaded content across subsequent shows/hides. So the fetch only ever happens once, on a given panel's *first* activation, regardless of how many times focus passes through it afterward. Automatic activation stays simple and cheap.

### Dispatches

`tabs:changed` — `{ index, tabId, panelId }`

### Rails helper

```ruby
sp_tabs(active: 0) do |t|
  t.tab("Profile") { f.field :name, as: :text }
  t.tab("Password", lazy: true, src: settings_password_path)
  t.tab("Notifications", lazy: true, src: settings_notifications_path)
end
```

`lazy: true` + `src:` renders the panel's content as `<turbo-frame id="..." src="..." loading="lazy">` instead of rendering the block inline. Non-lazy tabs render the given block directly inside the `panel` div.

### Theme keys

| Key | Element |
| --- | --- |
| `tabs` | outer wrapper |
| `tabs_list` | `role="tablist"` row |
| `tabs_tab` | individual `<button role="tab">` |
| `tabs_panel` | individual `role="tabpanel"` div |

### Testing

- `tests/unit/controllers/tabs_controller.test.js`: arrow-key roving focus triggers `select()` and dispatches `tabs:changed`; click on a tab does the same; `connect()` hides all but the initial active panel.
- `test/stimulus_plumbers/components/tabs_test.rb`: `aria-controls`/`aria-labelledby`/`aria-selected` wiring correct across tabs/panels; `lazy: true` renders a `turbo-frame` with `loading="lazy"` and the given `src`; non-lazy renders the block content inline.
- `test/accessibility/components/tabs_test.rb`: sandbox view with a mix of eager and lazy tabs; `assert_accessible` on initial render and again after switching to a lazy tab (post-activation state).

### Docs

New `stimulus-plumbers/docs/component/tabs.md` (controller targets/actions/values/dispatches) and `stimulus-plumbers-rails/docs/component/tabs.md` (Rails helper options, `lazy:`/`src:`, linking to the JS doc per no-cross-doc-duplication rule). README Components/Controllers table rows in both gems.

## Out of scope

- Manual activation mode.
- Drag-reorderable tabs, closable tabs, dynamically added/removed tabs at runtime.
- Nested tab groups (a tabpanel containing its own nested tablist).
- `f.section` layout options (columns, nesting) beyond the single `<fieldset><legend>` wrap.
