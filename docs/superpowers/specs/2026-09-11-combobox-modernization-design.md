# Combobox modernization — one focus model and Rails-rendered options

**Original date:** 2026-09-11  
**Amended:** 2026-10-05 — `manual` popover (D5), APG selection-follows-active (D2), Tab commits (D4),
`onX` wiring and button host (D3), input clears active (D6), `combobox:changed` and popup events
(D9), field-group anchor (Tailwind theme); each backed by Chromium/Firefox/WebKit experiments  
**Status:** Proposed for implementation review  
**Packages:** `stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`  
**Dependency:** `2026-09-11-overlay-foundation-modernization-design.md`  
**Release dependency:** ships with the popover foundation (overlay Product Decision 1A) and the
calendar redesign, which provides `sp_calendar_field` for the removed date variant

## Summary

The current combobox is assembled from `input-combobox`, `input-formatter`, `popover`, and one
of three date, time, or dropdown controllers. The generated listbox markup installs keyboard actions on an
unfocusable sibling of the focused input, does not maintain `aria-activedescendant`, and treats
navigation state as committed selection. Date and time dialogs use a different focus model but
are presented as variants of the same abstraction.

The replacement narrows `combobox` to the WAI-ARIA combobox pattern with a listbox popup. One
controller owns input, active option, committed value, popup state, and keyboard routing. DOM
focus stays on the combobox while the active option is represented by `aria-activedescendant`.
Rails renders semantic options and optional Turbo Frame result sets. Network behavior is an
adapter around the component, not part of its state machine.

Date selection moves to the calendar redesign. Native time input is the default;
any future custom time control is a separate component with an explicit listbox or dialog design.

## Goals

- Make every advertised keyboard interaction reachable from the element that actually has focus.
- Distinguish active option, committed selection, query text, and submitted value.
- Support select-only and editable listbox comboboxes without conflating their input behavior.
- Use the native popover foundation for presentation and dismissal.
- Preserve normal text editing keys in editable inputs.
- Support local options and Rails/Turbo remote results without embedding fetch logic in the base
  controller.
- Survive option replacement, Turbo morphs, reconnects, form reset, and validation re-rendering.
- Ship coordinated JavaScript, Rails, Tailwind, migration, and real-browser coverage.

## Non-goals

- Date, calendar, or time dialog behavior.
- Grid, tree, or multiselect popups in the first release.
- Inline autocomplete completion.
- Virtualized lists.
- Arbitrary HTML fetched and injected by the base controller.
- Replacing a native `<select>` where native behavior already meets the product requirement.
- Inferring labels or submitted values from formatted display text.

## Current implementation

```text
wrapper
  data-controller="popover input-combobox input-formatter"
  |
  +-- input[role=combobox]        DOM focus and Escape action
  +-- input[type=hidden]          submitted value
  `-- panel/listbox
        data-controller="combobox-dropdown"
        data-action="keydown->combobox-dropdown#onNavigate"
```

Verified defects and gaps:

1. The combobox input and listbox are siblings. Keyboard events from the focused input do not
   reach the `combobox-dropdown` controller installed on the listbox/panel.
2. The listbox and its options are not focusable in dropdown/typeahead markup. Unit tests call
   `onNavigate()` directly, so they do not prove the production event path.
3. `aria-activedescendant` is never maintained even though DOM focus remains on the input.
4. Arrow navigation changes `aria-selected`; active navigation and committed value are not
   represented separately, so Escape cannot reliably revert exploration.
5. The popover moves focus generically. That is wrong for listbox comboboxes, which keep DOM focus
   on the combobox.
6. A query shorter than `minLength` reveals local options but does not cancel an already scheduled
   or in-flight remote result.
7. An older request's completion can hide the loading state for a newer request.
8. Remote errors only log to the console and expose no stable status contract.
9. Option replacement does not reconcile active option, selected value, or `aria-activedescendant`.
10. Dropdown, date, and time variants share a wrapper even though listbox and dialog popups have
    fundamentally different focus rules.

## Design principles

1. **One controller owns one widget.** Keyboard, ARIA, popup state, and value commit cannot be
   distributed across sibling controllers.
2. **Active is not selected.** Arrow-key exploration does not commit a value until the selected
   interaction model says it does.
3. **DOM focus stays predictable.** Listbox comboboxes keep focus on the input/control and expose
   the active option with `aria-activedescendant`.
4. **Text editing remains native.** Editable combobox logic never intercepts ordinary platform
   editing shortcuts.
5. **The server renders HTML.** Rails result endpoints return semantic option markup through a
   matching Turbo Frame.
6. **Presentation is delegated.** Native popover owns top-layer/open state; the combobox owns the
   meaning of that state.
7. **Form value is explicit.** Display label, editable query, canonical value, and submitted input
   are never silently interchangeable.

## Architecture

```text
combobox controller
  +-- control target                DOM focus, keyboard routing
  +-- hidden input target           canonical submitted value
  +-- native popover adapter        open/close observation
  +-- listbox target                semantic options
  +-- active option id              aria-activedescendant
  `-- optional source adapter
        +-- local filtering
        `-- Turbo Frame navigation
```

## Decisions

### D1 — `combobox` means a listbox-popup combobox

Introduce one `combobox_controller` and retire the compositional requirement that consumers place
`input-combobox`, `combobox-dropdown`, `popover`, and `input-formatter` on the same widget.

The first release supports:

| Variant       | Control                                    | Input behavior                             |
| ------------- | ------------------------------------------ | ------------------------------------------ |
| `select_only` | button-like element with `role="combobox"` | value only from an option                  |
| `editable`    | text input with `role="combobox"`          | filters options; commit policy is explicit |

The popup role is `listbox`. Grid and tree popups require separate future specifications because
their navigation models are not interchangeable with listbox options.

Date and time are removed from the Rails combobox variant registry. Existing helper calls receive
a migration path to `sp_calendar_field` or native time field.

### D2 — One controller owns the complete state machine

The controller tracks four distinct concepts:

| State              | Source of truth                                            |
| ------------------ | ---------------------------------------------------------- |
| Open               | `panel.matches(':popover-open')`                           |
| Query/display text | control value/text                                         |
| Active option      | `aria-activedescendant` plus `aria-selected` on one option |
| Committed value    | hidden input and display label                             |

Follow the APG single-select pattern: `aria-selected="true"` follows the active option and
`aria-activedescendant` references it. The committed value lives in the hidden input and the
control's display label, so Escape restores `aria-selected` to the committed option without a
second state attribute. Multiselect, which would need active and selected to diverge, is a
non-goal.

Opening initializes active option in this order:

1. committed selected option;
2. first enabled visible option when opening with Arrow Down;
3. last enabled visible option when opening with Arrow Up;
4. no active option when opening by pointer unless the selected option exists.

Closing without commit preserves the prior committed value. Editable query policy is selected by
an explicit mode rather than inferred from close source.

### D3 — Canonical markup contract

Editable example:

```html
<div
  data-controller="combobox"
  data-combobox-mode-value="editable"
  data-action="mousedown->combobox#onMousedown click->combobox#onClick"
>
  <label for="city_query">City</label>
  <input
    id="city_query"
    role="combobox"
    aria-autocomplete="list"
    aria-expanded="false"
    aria-controls="city_listbox"
    autocomplete="off"
    data-combobox-target="control"
    data-action="input->combobox#onInput keydown->combobox#onKeydown"
  />
  <input type="hidden" name="city_id" data-combobox-target="input" />

  <div id="city_panel" popover="manual" data-combobox-target="panel">
    <ul id="city_listbox" role="listbox" data-combobox-target="listbox">
      <li id="city_option_1" role="option" data-value="1">Singapore</li>
    </ul>
  </div>
</div>
```

Requirements:

- Every option has an instance-unique, stable ID.
- `aria-controls` points to the listbox, not merely a visual wrapper.
- `aria-activedescendant` is absent when there is no active option.
- Options are not added to the page Tab sequence.
- Disabled options use `aria-disabled="true"` and are skipped by navigation and commit.
- Status elements are siblings of the listbox, never children of `role="listbox"`.

Select-only mode uses a `<button type="button">` host with the combobox role and current value;
handled Space and Enter prevent default so the button's `click` does not toggle twice. The Rails implementation must be verified against the supported AT matrix before
finalizing whether the host is a `<button>` or a neutral element with button keyboard behavior;
the latter is accepted only if native button semantics cannot satisfy the tested combobox contract.

### D4 — Keyboard contract lives on the control

When the control has focus:

| Key             | Behavior                                                                                                                          |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Arrow Down      | open if needed, then activate next/first enabled visible option                                                                   |
| Arrow Up        | open if needed, then activate previous/last enabled visible option                                                                |
| Home / End      | editable: native text editing while closed; list navigation only under the documented open-state policy                           |
| Enter           | commit active option when open; otherwise preserve native form behavior                                                           |
| Escape          | when open: close without committing and restore `aria-selected` to the committed option; when closed: not prevented; never clears |
| Tab / Shift+Tab | commit the active option when one exists, close, and let focus move natively                                                      |
| Printable text  | editable: native input; select-only: optional typeahead search                                                                    |

The controller must not prevent default until it has handled a key. It never intercepts platform
editing shortcuts such as Command/Control+A, word navigation, selection, copy, paste, undo, or redo.
In editable mode, Space, Home, and End stay native text editing. In select-only mode, Space commits
when open. Enter and Escape are ignored while `isComposing`.

Tab commits per the APG select-only pattern. Commit is safe because typing never sets an active
option (D6); only Arrow keys or reopening on the committed option do.

Pointer selection and keyboard selection converge on the same `commit(option)` method.

### D5 — Native popover owns presentation; the combobox owns dismissal

The panel uses `popover="manual"` and the overlay foundation's `Popover` plumber, opened with
`Popover#show(control)` so the control is the source.

`auto` is rejected. Light dismissal treats a click as inside only for an open popover or a
`popovertarget`/`commandfor` invoker, and `commandfor` only works on `<button>`. Verified in
Chromium, Firefox, and WebKit: a click on an `auto` combobox input closes a panel opened on focus,
and `click->toggle` closes and immediately reopens it.

The controller supplies every close path. Listeners attach on `combobox:opened` and detach on
`combobox:closed` and disconnect through one `AbortController`:

| Close path    | Mechanism                                                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Commit        | `commit(option)` when `close_on_commit`                                                                                             |
| Escape        | D4 `onKeydown` on the control; `preventDefault()` keeps an enclosing modal dialog open                                              |
| Tab           | D4                                                                                                                                  |
| Outside click | capture-phase document `click` outside the root; `click`, not `pointerdown`, so touch scrolling does not dismiss                    |
| Focus leaves  | document `focusin` outside the root; not `focusout`, which fires with a null `relatedTarget` when a non-focusable option is clicked |
| Frame focus   | window `blur` while an iframe is the active element; entering a frame fires no `focusin` (amended 2026-10-08)                       |
| Turbo cache   | D11                                                                                                                                 |

Pointer behavior:

- The root prevents `mousedown` default everywhere except the control, so DOM focus stays on the
  control; a click on a non-focusable icon would otherwise move focus to `body` without `focusin`.
- Clicking a select-only control toggles the panel; clicking an editable control opens it, and
  further clicks move the caret without closing.
- Manual mode does not restore focus on hide; none is needed because focus never leaves the
  control.

On `combobox:opened`, synchronize `aria-expanded` and active state. On close, clear transient
active state.

Do not reuse `Dismisser` (overlay D6 deprecates it) or add a plumber for these listeners. Extract a
shared helper only when a second `manual` consumer exists.

The combobox never calls generic `focusFirst()`; DOM focus remains on the control.

### D6 — Local filtering is synchronous and replace-safe

Local options remain authored in the listbox. Querying:

- normalizes text by Unicode NFD, stripping combining marks, and locale lower case (amended
  2026-10-07), then matches the label start (`prefix`), anywhere (`contains`), or in order (`fuzzy`);
- toggles `hidden` on non-matching options;
- clears active state when the active option becomes hidden;
- never activates an option while typing; an `input` event clears the active option, and Arrow keys
  activate (inline autocomplete is a non-goal);
- updates result status after the DOM is consistent.

The existing fuzzy matcher may remain as an optional matching strategy. Prefix matching is the
default because it is predictable and easier to communicate.

### D7 — Remote results are an adapter, not base-controller fetch logic

The base controller dispatches:

```text
combobox:query { query, sequence }
```

It does not call `fetch` or inject response strings. The `combobox-turbo` adapter, on the same root
and used by Rails `source:`, owns the frame (decided 2026-10-07), debounces query events, and sets
the frame's `src`:

```html
<div id="city_panel" popover="manual" data-combobox-target="panel">
  <turbo-frame id="city_results" data-combobox-turbo-target="frame">
    <ul id="city_listbox" role="listbox" data-combobox-target="listbox">
      ...
    </ul>
  </turbo-frame>
  <div role="status" data-combobox-target="status" data-combobox-turbo-target="status"></div>
</div>
```

The endpoint returns the matching `city_results` frame containing a listbox with the same stable
`city_listbox` ID. Turbo manages the request and exposes `[busy]`, `[complete]`, and its load
promise. The controller uses target-connected callbacks to adopt the replacement listbox and
reconcile active/selected state.

Sequence ownership remains in the adapter so an obsolete response cannot become the current
result set. If Turbo's actual navigation behavior does not provide that guarantee in the tested
version, the adapter rejects stale completion by normalized requested URL/query before adopting
the result.

Queries shorter than `minLength` cancel pending debounce work and navigate to or restore the
configured default result set. They never allow an older query to overwrite the cleared state.

Non-Rails consumers use `combobox-fetch` (npm only), which fetches an HTML fragment and replaces
the listbox with the element of the same ID, or listen for `combobox:query` and replace the listbox
through their own data layer. This keeps the base widget network-independent.

### D8 — Loading, empty, and error states are explicit

The adapter writes loading and error text to the non-focusable status sibling; the combobox writes
the empty text when it adopts a listbox. Status never reports counts (decided 2026-10-07):

| State   | UI/ARIA behavior                                                      |
| ------- | --------------------------------------------------------------------- |
| Loading | frame (Turbo) or listbox (fetch) `aria-busy="true"`; status as debounce begins |
| Results | status cleared                                                        |
| Empty   | localized “No results” status; no active descendant                   |
| Error   | localized retryable error status; previous committed value preserved  |

The component never announces generic “opened” or “closed” messages. Result status is meaningful;
presentation state is already exposed through `aria-expanded`.

### D9 — Commit and form semantics are stable

`commit(option)` performs one atomic update:

1. validate that the option belongs to the current listbox and is enabled/visible;
2. update the hidden canonical value;
3. update the control's display label according to mode;
4. clear `aria-selected` from the previous option and set it on the committed option;
5. dispatch `combobox:changed`;
6. close when configured.

Event contract:

| Event                    | Cancellable | Detail                     |
| ------------------------ | ----------- | -------------------------- |
| `combobox:query`         | no          | `{ query, sequence }`      |
| `combobox:before-change` | yes         | `{ value, label, option }` |
| `combobox:changed`       | no          | `{ value, label, option }` |
| `combobox:results`       | no          | `{ query, count }`         |
| `combobox:before-open`   | yes         | `{ source }`               |
| `combobox:opened`        | no          | `{ source }`               |
| `combobox:closed`        | no          | `{ source }`               |

The popup events come from the `Popover` plumber attached with the `combobox` prefix.

Form reset restores the server-authored initial selected option, hidden value, and display label.
A validation response may replace the entire widget or only its option frame; both paths must
produce the same state.

Editable modes must declare one value policy:

- `restricted`: only a committed option produces a submitted value; editing clears the canonical
  hidden value until another option is committed. Closing without a
  commit after editing reverts the control text and hidden value to the last committed option.
- `freeform`: query text is the submitted value; a separate option identifier may be omitted.

Default: `restricted` for Rails association-style fields.

### D10 — Rails API

One controller and one shared `Components::Combobox`, with two helpers named by intent, each
delegating to a matching component (`Combobox::Dropdown`, `Combobox::Typeahead`) so the helper and
component APIs stay symmetrical (amended 2026-10-05). Each helper
accepts only the options valid for its mode; the shared component still rejects `value_policy` on a
select-only combobox. Select-only
and editable differ in host element, value policy, and remote options; React Aria, MUI, and
Headless UI split them the same way.

Select-only (`mode: :select_only`):

```erb
<%= sp_combobox_dropdown name: "country_id", options: countries, label: "Country" %>
```

Editable (`mode: :editable`):

```erb
<%= sp_combobox_typeahead name: "city_id",
                          label: "City",
                          source: cities_path,
                          min_length: 2,
                          match: :prefix %>
```

| Option             | Helpers   | Default       | Notes                                           |
| ------------------ | --------- | ------------- | ----------------------------------------------- |
| `name:`            | both      | `nil`         | hidden input name; the form builder passes it   |
| `options:`         | both      | `[]`          | server-rendered local choices                   |
| `value:`           | both      | `nil`         | committed value                                 |
| `label:`           | both      | `nil`         | `aria-label` on the control                     |
| `close_on_commit:` | both      | `true`        | popup close policy; replaces `close_on_select:` |
| `value_policy:`    | typeahead | `:restricted` | `:restricted` or `:freeform`                    |
| `source:`          | typeahead | `nil`         | Turbo Frame endpoint for remote choices         |
| `param:`           | typeahead | `:q`          | query parameter sent to `source:`               |
| `min_length:`      | typeahead | `1`           | remote/local query threshold                    |
| `match:`           | typeahead | `:prefix`     | local match strategy                            |

The form builder maps `as: :select` to the dropdown and `as: :search` to the typeahead with
`value_policy: :freeform`.

The options builder continues to support label, canonical value, description, disabled state,
and selected state. Rendered option IDs become part of the required contract.

Date/time helper compatibility is not implemented by silently routing through the new helpers.
Migration warnings point to `sp_calendar_field`, native `date_field`, or native `time_field`.

### D11 — Turbo lifecycle and morphing

- Close open combobox popovers before `turbo:before-cache`.
- Reconnection to the same controller instance is idempotent.
- Listbox target replacement clears references to removed options before adopting new ones.
- A selected value that exists in replacement results is re-associated with the new option node.
- A selected value absent from replacement results remains committed in the form but is not
  represented by a false `aria-selected` option.
- Frame loading does not move DOM focus from the control.
- Morphing the control preserves cursor/selection for editable text unless the server explicitly
  replaces the value.

### D12 — Hotwire Native

Native `<select>`, platform date/time controls, or purpose-built Bridge components are preferred
when native presentation is a product requirement. The web combobox remains a valid WebView
fallback and requires no bridge to submit Rails form values.

The helper does not automatically change markup based solely on `hotwire_native_app?` in the
first release. An application may choose a native control or Bridge component explicitly so the
server contract remains understandable and testable.

## Tailwind theme

Add or revise named theme keys for:

- control and open state;
- listbox panel anchored to the field group;
- option default, active (`aria-selected`), and disabled states;
- descriptions and grouped options;
- loading, empty, and error status;
- high contrast, forced colors, reduced motion, and touch target sizing.

The panel anchors to the input group (control plus icons), not the bare control, in CSS only:

```css
/* root */
anchor-scope: --sp-field;
/* group */
anchor-name: --sp-field;
/* panel */
position-anchor: --sp-field;
min-inline-size: anchor-size(inline);
```

`anchor-scope` keeps the shared name unique per instance; verified flush in Chromium, Firefox, and
WebKit with two instances on one page and inside a modal dialog. The JavaScript keeps the control as
`source` and has no field-group concept. This is the one exception to the overlay D7
`position-anchor: auto` rule. No `absolute`/`top-full` positioning remains.

The active option is not indicated by color alone; its style survives forced colors. The theme does
not make options focusable or add ARIA behavior.

## Accessibility contract

- DOM focus remains on the combobox control for listbox navigation.
- `aria-activedescendant` references exactly one current, enabled, visible option or is absent.
- `aria-selected` follows the active option (APG single-select); the committed value is the hidden
  input and display label.
- `aria-expanded` reflects native popup state.
- `aria-controls` references the `role="listbox"` element.
- Editable controls declare the correct `aria-autocomplete` value.
- Options and popup descendants do not enter the normal Tab sequence.
- Escape closes without committing exploration.
- Status elements are live-region siblings of the listbox.
- Accessible name, required, invalid, and described-by relationships survive Rails validation
  rendering.

## Testing

### Unit tests

- State initialization for both modes.
- Open/close synchronization with native toggle events.
- Active versus selected state transitions.
- Every keyboard command dispatched on the actual control target.
- Disabled/hidden option skipping.
- Escape rollback with `preventDefault()`, and Tab commit.
- Close-path listeners attached only while open and removed on close and disconnect.
- Restricted/freeform value policy.
- Pointer and keyboard commit parity.
- Form reset.
- Listbox target replacement and stale-node cleanup.
- Query threshold and sequence behavior.
- Reconnect and Turbo cache cleanup.

### Rails integration tests

- Stable option/listbox IDs and relationships.
- Local and remote helper output.
- Matching Turbo Frame response extraction.
- Loading, empty, error, and replacement states.
- Validation response retains canonical value and accessible description.
- Direct visit to the remote endpoint renders a usable page or documented frame response.

### Browser and assistive-technology tests

Behavior specs live in `stimulus-plumbers-tailwind/test/browser/`, one spec per sandbox route
(`components/popover/combobox.spec.js`, `components/popover/search.spec.js`); snapshot specs in
`test/snapshots` hold screenshots only. Run Chromium, Firefox, and WebKit with real key
events against generated Rails markup:

- open with pointer, Arrow Down, and Arrow Up;
- a click opens and the panel stays open; a second click closes select-only; caret clicks keep
  editable open;
- navigate and commit with input focus retained, including clicks on non-focusable options;
- Escape without commit;
- Tab commits and moves on without trapping;
- outside click, outside tap, and focus leaving close the panel; touch scrolling does not;
- text editing and platform shortcuts;
- local filtering and remote replacement while focused;
- inside a native modal dialog: Escape closes only the panel;
- panel aligned to the field group;
- 400% zoom, forced colors, RTL, and reduced motion.

Rails accessibility tests assert the panel is open before scanning an open state.

Manual gates cover VoiceOver/Safari and NVDA/Firefox for name, expanded state, active option,
selection commit, result status, and validation errors.

## Migration

Old controller composition:

```html
<div data-controller="popover input-combobox input-formatter">
  ...
  <ul data-controller="combobox-dropdown">
    ...
  </ul>
</div>
```

New composition:

```html
<div data-controller="combobox">
  <input role="combobox" data-combobox-target="control" />
  <input type="hidden" data-combobox-target="input" />
  <div popover="manual" data-combobox-target="panel">
    <ul role="listbox" data-combobox-target="listbox">
      ...
    </ul>
  </div>
</div>
```

Migration requirements:

- Replace `input-combobox` and `combobox-dropdown` actions with `combobox` actions.
- Add stable IDs to every option and the listbox.
- Remove focusable/listbox key handlers from the popup; route keys through the control.
- Migrate custom fetch responses from bare `<li>` fragments to matching Turbo Frames, or listen
  for `combobox:query` with an application adapter.
- Replace date/time combobox variants with their dedicated helpers.
- Replace `close_on_select:` with `close_on_commit:`.
- Update listeners from `input-combobox:changed`/`combobox-dropdown:selected` to
  `combobox:changed`.

This is a breaking release and requires side-by-side old/new examples plus a server endpoint
migration example.

## Implementation order

1. Land and validate the native overlay foundation.
2. Implement the controller state machine against static Rails markup.
3. Add select-only and editable Rails renderers.
4. Add local filtering.
5. Add the Turbo Frame result adapter and stale-result tests.
6. Add Tailwind active/selected/status states.
7. Run cross-browser and AT gates.
8. Deprecate the old controller composition and date/time variants.

## References

- [WAI-ARIA APG: Combobox Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)
- [WAI-ARIA APG: Keyboard Interface](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)
- [WAI-ARIA 1.2: `aria-activedescendant`](https://www.w3.org/TR/wai-aria/#aria-activedescendant)
- [HTML Standard: popovers](https://html.spec.whatwg.org/multipage/popover.html)
- [Turbo Frames reference](https://turbo.hotwired.dev/reference/frames)
