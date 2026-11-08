# Overlay foundation modernization — native popovers and explicit lifecycles

**Original date:** 2026-09-11  
**Rewritten:** 2026-09-15  
**Amended:** 2026-10-05 — browser/snapshot test split, input-source guidance, Escape inside a modal

**Status:** Approved for implementation; positioning decision follows browser-matrix evidence

**Packages:** `stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`  
**Implementation dependency:** None

**Release dependency:** Popover and combobox ship together under Product Decision 1A

## Summary

The library currently builds non-modal overlays by combining `popover_controller`,
`Visibility`, `Dismisser`, `Flipper`, `Shifter`, and `ContentLoader`. Those pieces do not form a
reliable lifecycle: they replace Stimulus lifecycle methods, install controller properties that
cannot be redefined, own overlapping global listeners, and mix visibility, dismissal,
positioning, focus, and remote loading.

The replacement uses the HTML Popover API for non-modal top-layer presentation and light
dismissal. A small `Popover` plumber observes the native lifecycle and exposes explicit cleanup.
CSS Anchor Positioning owns placement when it passes the supported browser matrix. Remote content
is composed with Turbo Frames rather than fetched by `popover_controller`.

This is an overlay foundation, not one universal widget. Tooltip, menu, listbox, disclosure, and
dialog semantics remain separate components that may share presentation mechanics.

“Overlay foundation” is the project name only. Public code keeps the repository's existing
`popover` vocabulary: `Popover`, `popover_controller`, and `sp_popover`. This work does not add an
`Overlay` class, `overlay_controller`, `overlay` target, or `sp_overlay` helper.

## Goals

- Survive Stimulus disconnect/reconnect and target replacement without duplicate listeners or
  non-configurable-property failures.
- Use native top-layer ordering, light dismissal, and close-request behavior.
- Keep semantic roles and keyboard interaction in the consuming component.
- Position anchored panels without overwriting application transforms or transitions.
- Work inside native dialogs without portals or moving DOM nodes.
- Make lifecycle events observable regardless of whether opening or closing came from Stimulus,
  an invoker button, light dismissal, Escape, or external code.
- Compose remote panels with Turbo Frames and their native loading lifecycle.
- Provide Rails renderers, Tailwind theme keys, migration documentation, and browser tests in the
  same release.
- Keep plumber/controller state private and test the documented public surface rather than
  implementation fields.

## Non-goals

- A React-style portal abstraction.
- A global JavaScript overlay stack manager.
- A generic focus trap.
- A single controller that infers menu, tooltip, listbox, and dialog keyboard behavior.
- Fetching and sanitizing arbitrary HTML inside the base popover controller.
- Recreating native light-dismiss behavior with document-wide click listeners.
- Guaranteeing CSS Anchor Positioning without testing the declared browser floor.
- Mapping a web popover to Hotwire Native modal navigation or a native sheet.
- Redesigning menu, tooltip, combobox, or calendar field semantics in this specification.

## Current implementation

The present overlay path is:

```text
popover_controller
  +-- Visibility       hidden/class state and aria-expanded
  +-- Dismisser        capture-phase window click observer
  +-- ContentLoader    template or fetch loading
  `-- focusFirst       component-independent focus move

visibility_controller
  +-- Visibility
  +-- Dismisser
  `-- Shifter          transform-based viewport correction

flipper_controller
  `-- Flipper          absolute top/left placement
```

Verified defects and gaps:

1. `Visibility#enhance` defines a non-configurable property on the controller. A second attach to
   the same namespace cannot safely redefine it.
2. `WindowObserver#enhance` replaces `controller.disconnect`. Reconnection and multiple plumbers
   accumulate wrapped lifecycle methods instead of owning independent disposal.
3. Replacing a `visibility` content target attaches another `Shifter` while the old observer
   remains active until the entire controller disconnects.
4. Popover Escape handling is authored on the trigger. Once focus moves into an interactive
   panel, Escape is no longer routed to `popover#close`.
5. `focusFirst()` applies one focus policy to every kind of panel, even though listboxes keep DOM
   focus on their combobox while menus and dialog popups use different focus models.
6. Popover values for `reload`, `staleAfter`, and `loadedAt` are not passed into `ContentLoader`.
7. `contentLoading()` is not called by `ContentLoader`; the packaged loader target is therefore
   not automatically shown.
8. Remote failures can leave an open panel in a partial lifecycle, with no error event or
   guaranteed cleanup.
9. `Flipper` and `Shifter` write inline position, transition, and transform properties, which can
   overwrite theme/application styling.
10. The Rails popover defaults to dialog-like trigger semantics even though a generic panel is
    not necessarily a dialog.
11. `Components::Combobox` calls `Components::Popover#build`, runs `popover` beside
    `input-combobox`, and depends on `closeOnSelect`. Replacing the popover controller without a
    coordinated combobox change would break a first-party consumer.
12. `sp_popover` already provides the repository's structural builder shape, but it generates a
    random panel ID when the caller omits one, renders the panel with `hidden`, and wires Escape on
    the trigger rather than relying on native popover behavior.

The existing unit and axe suites verify individual methods and static states. They do not cover
same-instance reconnection, target replacement, native light dismissal, nested top-layer order,
or Escape after focus enters panel content.

## Design principles

1. **Presentation mechanics are not widget semantics.** A top-layer panel does not become a
   menu, listbox, dialog, or tooltip merely because it is visible.
2. **Native state is authoritative.** The popover's showing state drives controller state and
   events; no parallel `visibleValue` is maintained.
3. **Every attachment returns disposal.** Plumbers never replace Stimulus lifecycle methods.
4. **CSS owns geometry.** JavaScript coordinates compatibility, not ordinary placement styling.
5. **Focus belongs to the consumer.** The base overlay never guesses where focus should go.
6. **Remote HTML remains a Rails navigation concern.** Turbo Frames own requests, replacement,
   loading state, and matching-response contracts.
7. **Progressive enhancement remains usable.** Server-rendered content and ordinary links still
   work when JavaScript or a positioning enhancement is unavailable.
8. **Private means private.** Plumber instances, listener references, transition state, and
   positioning state use private fields. Controllers expose only documented actions and Stimulus
   target callbacks.
9. **Tests observe contracts.** Unit tests assert native calls, events, DOM state, cleanup, and
   focus. They do not read or replace private controller/plumber state.

## Repository convention guard

The redesign reuses existing repository vocabulary and composition points:

- `popover` remains the Stimulus identifier and target namespace;
- `sp_popover` remains the only public Rails builder;
- `Popover.panel_id_for` and `sp_dom_id` remain the ID-generation path, including for combobox;
- `merge_html_options` and the theme schema remain the option/class composition path;
- Turbo Frame remains the remote-content owner;
- controller manifests continue to derive actions and dispatches from source.

The only approved new implementation is the `Popover` plumber described in D3. “Plumber” and the
`attach*` factory shape are existing repository conventions; `Popover` follows the modern
`Dialog` adapter pattern rather than introducing a new architectural layer. It is needed because
the current general plumbers cannot represent native popover state and disposal without lifecycle
wrapping or controller mutation. It introduces no new public product term.

A private positioning adapter is not approved by this specification. If the native browser matrix
fails and Product Decision 2A cannot be met by the supported browser floor, implementation pauses
and presents the evidence before adding that abstraction. No other helper, controller identifier,
builder, ID resolver, global registry, or compatibility name is introduced without a separate
decision.

## Product decisions for approval

These decisions change release scope or support policy. Decision 1 is resolved before
implementation. Decision 2 is recorded after the native positioning matrix and before any
compatibility code is introduced.

### Product Decision 1 — Release boundary with combobox

The existing combobox is not merely a downstream user of public popover behavior. It composes the
current Rails popover builder without its wrapper and depends on the current controller's
`closeOnSelect` behavior.

| Option                                    | Delivery                                                                                                            | Trade-off                                                                                                     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **A — Coordinated release (recommended)** | Implement the popover foundation first, immediately follow it with the combobox redesign, and release both together | Avoids a temporary compatibility mode and gives each behavior one owner; the releasable change is larger      |
| B — One-release compatibility window      | Ship popover first while retaining a documented legacy path for the existing combobox                               | Allows an earlier popover release but adds temporary code, duplicate test obligations, and a removal deadline |
| C — Break combobox temporarily            | Release popover and restore combobox later                                                                          | Smallest first release, but knowingly breaks a first-party component and is not recommended                   |

Decision record: **1A selected on 2026-09-15. Popover is implemented first, combobox follows
immediately, and neither is released until both migrations pass their release gates. No legacy
combobox compatibility mode is added.**

### Product Decision 2 — Positioning support boundary

CSS Anchor Positioning is the intended implementation. The decision must be based on the actual
supported Chromium, Firefox, and WebKit matrix, including logical placement, collision fallback,
zoom, writing modes, transformed ancestors, and popovers inside dialogs.

| Option                                                        | Contract                                                                                                                            | Trade-off                                                                                                              |
| ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **A — Native contract where the matrix passes (recommended)** | Use CSS Anchor Positioning only; if a supported engine fails a required case, hold the release or adjust the declared browser floor | Keeps geometry in CSS and avoids a second positioning engine                                                           |
| B — Private compatibility adapter                             | Add a capability-selected, disposable JavaScript adapter only for matrix failures                                                   | Preserves a broader browser floor but adds resize/scroll observers and a second geometry path                          |
| C — Retain legacy Flipper/Shifter for failures                | Route unsupported cases through the existing plumbers                                                                               | Reduces initial implementation work but preserves the lifecycle and transform ownership being removed; not recommended |

Decision record: **2A selected on 2026-09-16 with a narrowed WebKit contract. Native CSS
Anchor Positioning remains the only production positioning path. Chromium 149 and Firefox 151
passed the complete matrix. WebKit 26.5 passed every case except an anchored popover inside a
native dialog after the document has scrolled: with the source ending at `y = 348`, the panel was
rendered at `y = -232`, while all Popover and CSS Anchor Positioning support queries returned
true. That WebKit combination is not part of the supported popover contract until the engine
behavior changes. The real assertion continues to run as an expected failure so an upstream fix
is detected. No compatibility adapter, user-agent runtime branch, or legacy Flipper/Shifter path
is approved.**

## Architecture

```text
semantic component                     overlay foundation
------------------                     ------------------
menu / combobox / calendar     ----->  native popover lifecycle
          |                                      |
          |                                      +-- top layer
          |                                      +-- light dismiss / Escape
          |                                      `-- beforetoggle / toggle
          |
          +----------------------------> CSS anchor contract
          |
          `----------------------------> optional Turbo Frame content
```

## Decisions

### D1 — Split disclosure, popover, tooltip, and dialog

The existing `visibility` controller remains only as a non-overlay disclosure utility during its
migration period. It must not position content, install outside-click behavior, or imply a popup
role.

The component categories are:

| Category          | Presentation                       | Semantic owner                                   |
| ----------------- | ---------------------------------- | ------------------------------------------------ |
| Disclosure        | normal document flow plus `hidden` | disclosure controller/author markup              |
| Non-modal popover | HTML `popover` top layer           | menu, combobox, help-panel, or other consumer    |
| Tooltip           | separate tooltip design            | tooltip controller; not generic popover defaults |
| Modal dialog      | native `<dialog>`                  | modal modernization specification                |

`popover_controller` is a presentation adapter. It does not assign a default ARIA role.

### D2 — Native HTML popover state is required

The supported panel carries `popover="auto"` or `popover="manual"`:

- `auto` is the default for ordinary interactive panels. It participates in the auto-popover
  stack, responds to close requests, and supports native light dismissal.
- `manual` is opt-in for components that explicitly own their dismissal policy. The component
  must supply every close path and must not claim light dismissal.
- `hint` is not part of the initial public API. It can be added after the browser and assistive
  technology matrix is verified for a dedicated tooltip design.

The package browser floor must support `showPopover`, `hidePopover`, `togglePopover`,
`beforetoggle`, and `toggle`.
There is no class/`hidden` fallback inside `popover_controller`: it would create a second state
machine without reproducing the top layer, native light dismissal, or close-request ordering.
Positioning support is resolved separately through Product Decision 2.

### D3 — Add a purpose-built `Popover` plumber

Add:

- `src/plumbers/popover.js`
- `attachPopover(controller, options)`
- `docs/plumber/popover.md`

This follows the existing `Dialog` plumber convention: a purpose-built adapter plus an `attach*`
factory retained privately by its controller. Do not subclass `Visibility` or the legacy
`Plumber` base, call `enhance()`, define controller properties, or wrap Stimulus lifecycle methods.

The plumber owns one panel and its native listeners:

| Member            | Meaning                                                  |
| ----------------- | -------------------------------------------------------- |
| `open`            | Read-only reflection of `panel.matches(':popover-open')` |
| `show(source?)`   | Calls `showPopover({ source })` when closed              |
| `hide()`          | Calls the native hide path when open                     |
| `toggle(source?)` | Calls `togglePopover({ source })` when appropriate       |
| `disconnect()`    | Removes listeners and clears only adapter-owned state    |

These five members are the complete public `Popover.prototype` surface. State, panel/controller
references, listener functions, event guards, and helpers are true private fields or methods. A
unit test locks the public prototype to this documented list.

`popover_controller` retains the instance as `#popover` and disposes it in panel-target disconnect
and controller-disconnect callbacks. Neither consumers nor `popover_controller` tests reach
through `controller.popover` or inspect plumber fields.

The adapter never replaces `controller.connect`, `controller.disconnect`, or another method.

### D4 — Native events drive the public lifecycle

The panel's `beforetoggle` and `toggle` events are the source of truth. Public events dispatch
from the panel:

| Event                 | Cancellable | Detail                        | When                        |
| --------------------- | ----------- | ----------------------------- | --------------------------- |
| `popover:before-open` | yes         | `{ source: Element \| null }` | Native opening is requested |
| `popover:opened`      | no          | `{ source: Element \| null }` | Native state settles open   |
| `popover:closed`      | no          | `{ source: Element \| null }` | Native state settles closed |

There is no custom `popover:before-close`. Native light dismissal is not a durable cancellable
application contract, and a custom event with “before” in its name would imply otherwise.
Applications that need a close policy use `popover="manual"` and provide explicit close paths.

`source` comes from the controller action source or the native toggle event and is `null` when the
platform supplies none. The adapter does not invent a permanent invoker registry.

Invoker buttons, controller methods, Escape, light dismissal, and external
`panel.showPopover()`/`panel.hidePopover()` calls converge on the same settled events. Native
`toggle` events may coalesce rapid state changes, so the contract is exactly once per observed
settled transition—not once per method invocation. A same-task hide/show browser test verifies
the final state and absence of stale lifecycle events.

### D5 — The base controller does not move focus

Remove `focusFirst()` from `popover_controller` and remove generic open/close announcements.

Consumers define focus behavior:

| Consumer              | Focus contract                                                       |
| --------------------- | -------------------------------------------------------------------- |
| Help/disclosure panel | normally stays on trigger                                            |
| Combobox listbox      | stays on input; `aria-activedescendant` identifies the active option |
| Menu button           | moves into menu according to menu-button pattern                     |
| Dialog popup          | uses the dialog/modal component, not generic popover focus           |
| Tooltip               | never moves focus                                                    |

When native light dismissal closes a panel, the consuming component decides whether explicit
focus restoration is required. The base adapter reports an available source in lifecycle event
detail but does not unconditionally focus it. Native popover focusing/restoration remains in
effect; the adapter does not counteract it. Consumers author any widget-specific initial focus or
`autofocus` behavior.

### D6 — Native light dismissal replaces `Dismisser`

`popover="auto"` owns outside-pointer dismissal and close requests. Do not attach a global
capture-phase click listener.

`Dismisser`, `dismisser_controller`, and the outside-click portion of `visibility_controller`
are deprecated as popover dependencies. They are not deleted while documented non-popover
consumers remain. The existing combobox may continue using them only in the unreleased baseline
while its redesign follows the popover implementation; that legacy path does not ship beside the
new popover foundation.

The package does not synthesize a separate `dismissed` event before native light dismissal.
Consumers observe `popover:closed` and inspect their own pending state when needed.

### D7 — CSS Anchor Positioning is the primary placement contract

The packaged `popovertarget` button is the popover's implicit anchor. For a programmatic source
such as a text input, `Popover#show(source)` calls `panel.showPopover({ source })`; the platform
then establishes that source as the same kind of implicit anchor. The panel uses
`position-anchor: auto`.

This contract needs no generated `anchor-name`, `anchor-scope`, inline style, data registry, or
JavaScript coordinate. `popover_controller#open(event)` and `toggle(event)` use
`event.currentTarget` when present and otherwise use the optional `trigger` target. Calls without
either source still open and emit lifecycle events, but do not promise anchored placement.

Themes express placement with logical `position-area` values and collision fallbacks with
`position-try-fallbacks`.

Public placement values are semantic and writing-mode aware:

- `block-end-start`
- `block-end`
- `block-end-end`
- `block-start-start`
- `block-start`
- `block-start-end`
- `inline-start`
- `inline-end`

They are not exposed as raw `top`, `left`, or transform coordinates.

The panel owns maximum inline/block size and overflow behavior. Collision fallback may change
placement, but must never make essential content unreachable.

The declared WebKit boundary from Product Decision 2 applies to an anchored popover inside a
native dialog when the document is scrolled. It is a support limitation, not a runtime fallback:
production markup and CSS remain identical across engines, and the failing geometry assertion
continues to execute in the WebKit project.

### D8 — Compatibility positioning is isolated and disposable

Do not add compatibility positioning pre-emptively. First run the native acceptance matrix from
Product Decision 2. If the product decision selects a private compatibility adapter for actual
failures, it must:

- be capability-selected with `CSS.supports`, not user-agent detection;
- return `disconnect()` and own an `AbortController` for listeners;
- observe the anchor and panel with `ResizeObserver`;
- respond to relevant scroll and resize events;
- write component-scoped CSS custom properties instead of `transform` or `transition`;
- preserve logical placement and RTL behavior;
- keep every field/helper private and expose only `disconnect()` to its owner;
- avoid attaching state, registries, callbacks, or test controls to `window`/`globalThis`;
- remain internal; it is not added to package exports or application documentation.

`Flipper` and `Shifter` are not used by the redesigned overlay. They are deprecated after the
compatibility decision is complete.

### D9 — Public controller API

Controller identifier: `popover`.

Targets:

| Target    | Required | Meaning                                                  |
| --------- | -------- | -------------------------------------------------------- |
| `trigger` | no       | Default source/invoker when one trigger is owned locally |
| `panel`   | yes      | Element carrying the native `popover` attribute          |

Methods:

| Method           | Meaning                                                                |
| ---------------- | ---------------------------------------------------------------------- |
| `open(event?)`   | Show the panel using the event's current target as source when present |
| `close(event?)`  | Hide the panel                                                         |
| `toggle(event?)` | Toggle native state                                                    |

There are no `template` or `loader` targets and no `url`, `reload`, `loadedAt`, `staleAfter`,
`closeOnSelect`, `announceOpen`, or `announceClose` values. There are no public plumbing helpers,
state getters, or compatibility actions. The generated controller manifest must list exactly
`open`, `close`, and `toggle` as actions; Stimulus lifecycle and target callbacks remain excluded.

`open`, `close`, and `toggle` prevent the default activation only when invoked as Stimulus actions,
then call the private plumber. Programmatic calls accept no options object. Missing or non-popover
panel targets produce one concise configuration error and leave the controller inert; they do not
throw during connection.

`aria-expanded` is synchronized only when the trigger already carries that semantic contract.
The Rails renderer authors the initial state when the caller supplies `haspopup:`; the controller
reflects native settled state on that trigger. The base controller does not infer a role from panel
content.

### D10 — Rails composes remote content with Turbo Frames

The base popover never fetches or injects HTML. A remote panel contains a Turbo Frame:

```erb
<%= sp_popover placement: :block_end_end do |popover| %>
  <% popover.trigger { "Notifications" } %>
  <% popover.panel do %>
    <turbo-frame id="notifications_content"
                 src="<%= notifications_path %>"
                 loading="lazy">
      <%= render "shared/loading" %>
    </turbo-frame>
  <% end %>
<% end %>
```

The frame endpoint returns a matching frame. Turbo's `[busy]` and `[complete]` attributes drive
theme loading states. Errors use `turbo:frame-missing` or application-specific frame error UI;
the popover controller does not parse or sanitize response HTML.

Static template content is rendered normally by Rails. Client-side cloning is unnecessary.
Direct visits to application-owned frame routes remain usable pages where that route is publicly
navigable. Tests use real Turbo Frame requests and public Turbo events; they do not add
popover-only production endpoints, attach state to `window`, or replace frame DOM to imitate
Turbo.

Turbo is not a runtime dependency of `stimulus-plumbers` or the Rails renderer. The JavaScript
package may retain `@hotwired/turbo` as a development dependency for the Rails/Tailwind sandbox,
loaded through that sandbox's import map, matching the modal test environment.

### D11 — Rails API and semantic requirements

`sp_popover` remains the single structural builder. Do not add `sp_overlay` or separate
menu/listbox variants to this foundation:

```erb
<%= sp_popover placement: :block_end_end do |popover| %>
  <% popover.trigger(haspopup: :menu) { "Account" } %>
  <% popover.panel(role: :menu, aria_label: "Account actions") do %>
    ...
  <% end %>
<% end %>
```

Builder options:

| Option           | Default                                    | Notes                                                |
| ---------------- | ------------------------------------------ | ---------------------------------------------------- |
| `panel_id:`      | `Popover.panel_id_for(template.sp_dom_id)` | Existing override for a caller-stable panel ID       |
| `mode:`          | `:auto`                                    | Native `auto` or `manual` popover behavior           |
| `placement:`     | `:block_end_start`                         | Semantic theme token, never a raw utility/coordinate |
| `**html_options` | —                                          | Forwarded to the existing outer `popover` wrapper    |

The rendered panel always has an ID because `popovertarget` references it, but callers do not have
to supply one. The builder preserves the current `panel_id || Popover.panel_id_for(sp_dom_id)`
resolution. A wrapper `id:` remains an ordinary HTML option and does not silently become a panel
ID or relationship prefix.

Combobox keeps the same convention: `Components::Combobox#render` resolves its trigger ID from the
top-level `id:`, then the trigger options' `id:`, then `sp_dom_id`; it passes that result to
`Popover.panel_id_for`. Do not introduce a second ID resolver, record/key API, or popover-specific
DOM-ID helper.

Semantic options belong to the relevant builder method:

- `popover.trigger(..., haspopup: nil)` owns trigger semantics. It does not default to
  `"dialog"`. When `haspopup:` is present, the builder also authors `aria-expanded="false"` and
  `aria-controls` for the resolved panel ID.
- `popover.panel(..., role: nil, aria_label: nil, aria_labelledby: nil)` owns optional consumer
  semantics. The generic builder does not infer a role or require a name when no named widget role
  was selected.

Keep the existing two trigger block forms. A zero-arity block renders the packaged button. A
one-arity block receives the complete relationship, ARIA, and Stimulus attributes for a
caller-rendered source such as a combobox input.

The one-arity block receives the `trigger` target but no inferred activation action. There is no
durable event that fits every caller-rendered source. The consuming component adds the appropriate
`popover#open` or `popover#toggle` action, or owns the `Popover` plumber directly as the redesigned
combobox does.

Light dismissal treats a caller-rendered source as outside the panel. With `auto`, a click on the
source closes the panel before the source's own action runs, so `click->popover#open` reopens it
and `click->popover#toggle` cannot close it. Do not open on `focus`: the click that focuses the
source then closes the panel. A source that must toggle or keep the panel open while it is clicked,
such as an editable input, uses `manual` and owns its close paths.

The packaged button uses declarative `popovertarget`; native `beforetoggle` still passes through
the plumber lifecycle, so it does not also need `click->popover#toggle`. Programmatic sources use
the controller action because text entry controls are not declarative popover buttons. Do not wire
both native activation and a Stimulus toggle to the same packaged click.

The builder uses existing option-merging and theme fallback conventions. Only an unsupported
`mode:` raises `ArgumentError`, because it selects native dismissal behavior. Unsupported visual
`placement:` values use the theme schema's existing warning and fallback path. The generic builder
does not validate consumer-owned role/name combinations.

`Components::Popover#build` remains available only as the existing wrapper-free composition seam
needed by first-party builders. The redesigned combobox may consume it, but application
documentation presents `sp_popover`, not `build`, as the public Rails entry point.

### D12 — Turbo lifecycle is explicit

Before `turbo:before-cache`, close every open package-owned popover synchronously. Cached
snapshots must not preserve top-layer state.

Target lifecycle callbacks attach and dispose the plumber when only the panel is replaced.
Reconnection to the same controller instance must be idempotent. Turbo morphing panel children
must not recreate the presentation adapter unnecessarily.

Nested popovers inside an open native dialog remain DOM descendants of that dialog. No portal or
body reparenting is allowed. Browser tests verify top-layer order and that the first Escape closes
the most recently opened dismissible popover before the dialog receives a subsequent close request.

## Tailwind theme

Retain the existing `popover_wrapper`, `popover_trigger`, and `popover` theme vocabulary where
their meaning remains valid. Extend the schema with named options rather than introducing raw
Tailwind classes into the Rails builder. Replace geometry written by JavaScript with theme-owned
classes for:

- panel surface and elevation;
- placement tokens;
- maximum inline/block size and overflow;
- open/close transition states;
- forced-colors and reduced-motion behavior;
- Turbo Frame `[busy]` and `[complete]` content states.

Top-layer transition CSS may use `@starting-style` and discrete `display`/`overlay` transitions.
The packaged animation stylesheet is the sole owner of popover open/close opacity and transform;
theme utilities do not duplicate those transition states. Theme CSS must not assign widget roles
or focus behavior.

## Accessibility contract

- The base component never invents a role.
- Triggers receive `aria-haspopup` only for a known popup widget type.
- `aria-expanded` follows native open state when the semantic trigger requires it.
- Escape and light dismissal come from `popover="auto"`; manual mode documents its explicit
  alternatives.
- Inside a modal dialog, one Escape closes only the most recently opened popover. WebKit otherwise closes the
  popover and the dialog together; the `Dialog` plumber owns the fix (modal D12).
- Focus behavior is tested per consuming widget, not once against the presentation primitive.
- Open/close is not announced through a generic global live region.
- Panels remain in their authored DOM context and retain label/description relationships.
- Reduced motion and forced colors have explicit theme acceptance tests.

## Testing

Test behavior at the layer that owns it. jsdom may mock native popover methods for adapter logic;
it is not evidence for native top-layer, dismissal, focus, geometry, or event ordering.

### JavaScript unit tests (`stimulus-plumbers`)

`tests/unit/plumbers/popover.test.js` owns the adapter contract:

- the prototype exposes exactly `open`, `show`, `hide`, `toggle`, and `disconnect`;
- explicit attach/disconnect and repeated disposal remove every listener;
- native method guards and external toggle observation;
- `popover:before-open` cancellation;
- opened/closed events reflect settled state without duplicates;
- rapid hide/show does not leave stale adapter state.

`tests/unit/controllers/popover_controller.test.js` owns Stimulus integration:

- a missing or invalid panel logs one configuration error and remains inert;
- same-instance connect/disconnect/connect;
- panel target replacement disposes the old adapter;
- action methods prevent default and drive observable panel behavior;
- trigger `aria-expanded` synchronization only when authored;
- `turbo:before-cache` closes an open panel;
- the generated manifest lists only `open`, `close`, and `toggle` actions.

Tests wait for controller connection, events, or DOM outcomes with `vi.waitFor`/`vi.waitUntil`.
They do not use zero-delay sleeps, inspect private fields, replace controller lifecycle methods, or
attach test state to globals.

### Rails and theme tests

- `stimulus-plumbers-rails/test/stimulus_plumbers/components/popover_test.rb` verifies the single
  builder, both trigger block forms, native attributes, option merging, panel IDs, semantic
  pass-through, Turbo Frame composition, and the existing `sp_dom_id`/`panel_id_for` convention.
- Manifest tests verify exact targets, values, actions, and public dispatches from generated
  output.
- `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/popover_test.rb` verifies
  named theme keys, all semantic placements, overflow, reduced motion, and forced colors.
- Accessibility tests scan closed, open, named menu/help examples, and remote-content states.

### Browser tests

Run Chromium desktop/mobile, Firefox, and WebKit. Engine-native behavior lives in `test/browser`
with one spec per route; `test/snapshots` holds screenshots only:

- `test/browser/components/popover/popover.spec.js` — declarative and programmatic sources,
  Escape, light dismissal, settled events, and focus remaining consumer-owned; `nested`,
  `positioning` (scroll containers, viewport edges, overflow, RTL, vertical writing mode,
  transformed ancestors, collision fallback), and `in a native dialog` describes;
- `test/browser/components/popover/turbo.spec.js` — real frame lazy loading, Turbo Stream target
  replacement, and cache restoration;
- `test/snapshots/components/popover/popover.spec.js` — closed and open screenshots.

The nested cases live under the popover suite, not the modal suite. Fixtures render through
`sp_popover`; tests do not construct replacement markup, mutate policy attributes to manufacture a
case, or use test-only production hooks/endpoints. Geometry expectations derive tolerances from
the rendered environment rather than hardcoding browser-specific pixels.

axe scans remain part of the suite but do not substitute for keyboard, focus, lifecycle, and
geometry assertions.

### Manual and release gates

Before release:

| Environment                 | Required verification                                                  |
| --------------------------- | ---------------------------------------------------------------------- |
| VoiceOver + Safari on macOS | role/name supplied by consumer, expansion state, Escape, light dismiss |
| NVDA + Firefox on Windows   | same contract                                                          |
| iOS Safari, real device     | viewport edges, zoom, touch dismissal, nested dialog behavior          |
| Hotwire Native iOS/Android  | ordinary web-view behavior; no modal-navigation or native-sheet claim  |

Run the repository's Linux snapshot-update workflow only after fixtures are final. Review and
commit the generated baselines before merge. Implementation agents must not update snapshots.
The release-generated changelog must label the controller/helper changes as breaking and include
before/after markup plus remote-content migration.

## Deprecation and migration

Deprecated:

- `Visibility` as an overlay mechanism;
- `Dismisser` and `dismisser_controller` for outside-click behavior;
- `Flipper`, `Shifter`, `flipper_controller`, and `panner_controller` for popover placement;
- `ContentLoader` integration in `popover_controller`;
- generic popover open/close announcements;
- the default dialog-like Rails popover semantics.

Migration requirements:

1. Add a native `popover` attribute to panel markup.
2. Move menu/listbox/dialog roles and keyboard behavior into their semantic component.
3. Replace outside-click actions with `popover="auto"` where light dismissal is intended.
4. Replace remote `url` values and templates with rendered content or a Turbo Frame.
5. Replace raw placement coordinates with semantic placement tokens.
6. Remove application code that depends on `controller.visibility`, `shift()`, or `flip()`.
7. Replace `closeOnSelect` with an explicit consumer-owned `popover#close` action when selection
   should close the panel; omit that action when it should remain open.

Old generic markup:

```html
<div
  data-controller="popover"
  data-popover-url-value="/account/actions"
  data-popover-announce-open-value="Panel opened"
>
  <button
    data-popover-target="trigger"
    data-action="click->popover#toggle keydown.esc->popover#close"
    aria-haspopup="dialog"
    aria-expanded="false"
  >
    Account
  </button>
  <div data-popover-target="panel" hidden role="dialog">...</div>
</div>
```

New structural markup:

The panel ID below illustrates the value resolved by the builder; it does not imply that the
caller supplied a stable ID.

```html
<div data-controller="popover">
  <button
    popovertarget="account-actions_popover"
    data-popover-target="trigger"
    aria-haspopup="menu"
    aria-expanded="false"
    aria-controls="account-actions_popover"
  >
    Account
  </button>
  <div
    id="account-actions_popover"
    popover="auto"
    data-popover-target="panel"
    role="menu"
    aria-label="Account actions"
  >
    ...
  </div>
</div>
```

Remote content moves inside the new panel as an ordinary matching Turbo Frame. No `url`,
`template`, `loader`, reload timestamp, or controller-owned HTML insertion remains.

This is a breaking release. The popover and combobox migrations ship together and no compatibility
mode is added. The existing combobox remains unchanged only while the coordinated redesign is in
progress; it is replaced before release. Legacy plumbing must not leak into the new `Popover`
adapter.

## Packaging and documentation

Ship the coordinated popover-and-combobox release with:

- the JavaScript controller and private-state `Popover` plumber;
- the existing `sp_popover` Rails builder updated to native markup;
- Tailwind schema/theme updates and component-scoped animation CSS;
- JavaScript, Rails, accessibility, Turbo Frame, migration, and theme documentation;
- real static, programmatic-source, remote-frame, nested-dialog, RTL, and long-content examples;
- unit, renderer, cross-browser, accessibility, and user-owned snapshot coverage.

Documentation uses “popover” for the primitive and reserves menu, listbox, tooltip, dialog, and
disclosure for their actual semantic components. It does not advertise the wrapper-free `build`
method as a second public builder.

## Implementation order

1. Build the native `Popover` plumber and lifecycle browser harness without releasing it
   independently.
2. Establish the CSS anchor matrix and record Product Decision 2 from test evidence.
3. Rewrite `popover_controller` with private target ownership and exact manifest coverage.
4. Update the existing Rails builder and Tailwind theme without adding a second public entry point.
5. Add real Turbo Frame, cache, positioning, nested-dialog, and accessibility tests.
6. Migrate current generic popover examples and documentation.
7. Deprecate legacy visibility/dismissal/positioning use only where replacement coverage exists.
8. Complete the combobox redesign on the new popover foundation before release.
9. Run the user-owned snapshot workflow, manual matrix, and release changelog gates.

## References

- [HTML Standard: popovers](https://html.spec.whatwg.org/multipage/popover.html)
- [CSS Anchor Positioning Level 1](https://drafts.csswg.org/css-anchor-position/)
- [Turbo Frames reference](https://turbo.hotwired.dev/reference/frames)
- [Turbo Frames handbook](https://turbo.hotwired.dev/handbook/frames)
