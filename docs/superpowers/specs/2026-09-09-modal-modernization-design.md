# Modal modernization — native dialog and Hotwire modal navigation

**Original date:** 2026-09-09\
**Rewritten:** 2026-09-10\
**Status:** Automated implementation complete; release and manual/device gates remain.\
**Packages:** `stimulus-plumbers`, `stimulus-plumbers-rails`, `stimulus-plumbers-tailwind`\
**Integrations:** Turbo Drive, Turbo Frames, Turbo Streams, Hotwire Native iOS/Android

## Summary

The library currently uses one `modal_controller` for two rendering mechanisms: native
`<dialog>` and a custom overlay. The replacement uses native `<dialog>` exclusively, but it
does not treat every modal-looking experience as the same component.

There are two products:

1. **In-document dialog** — confirmation, alert, or local form rendered in the current page.
   It is implemented with `<dialog>` and a small Stimulus adapter.
2. **Modal navigation** — a Rails route such as `/projects/42/edit`. On the web it may be
   progressively enhanced into a `<dialog>` through a Turbo Frame. In Hotwire Native the same
   URL is presented by the native modal navigation stack.

The distinction is architectural. A dialog is a DOM element with a local lifecycle. A modal
route is navigation with history, redirects, validation responses, and native presentation.
Neither abstraction should pretend to be the other.

## Goals

- Eliminate the custom-overlay implementation and its focus, inertness, and cleanup defects.
- Make every native close path observable: Escape, backdrop, `method="dialog"`, explicit
  `close()`, and external code.
- Give dismissals and explicit completion different semantics.
- Survive Turbo replacement, morphing, caching, and controller reconnection.
- Provide one complete Rails component and Tailwind theme in the same release as the JS API.
- Let route-level forms render as dialogs on the web and native modal screens in Hotwire Native.
- Support mobile browser layout, safe areas, long forms, and the on-screen keyboard without
  claiming unverified device behavior.
- Keep popovers, combobox panels, and date/time panel positioning outside the modal controller.

## Non-goals

- A portal abstraction.
- A general overlay stack manager.
- Remote loading inside the base modal controller.
- A custom focus trap for native dialogs.
- Automatic conversion of arbitrary web dialogs into native sheets.
- Drag-to-dismiss, detents, or snap points in web CSS.
- Positioning or responsive mode-switching for date/time panels.
- Managing more than one open modal.

## Current implementation

`stimulus-plumbers/src/controllers/modal_controller.js` has two paths:

| Concern              | Native `<dialog>`               | Custom overlay                       |
| -------------------- | ------------------------------- | ------------------------------------ |
| Open/close           | `showModal()` / `close()`       | `hidden` plus body overflow mutation |
| Focus                | browser plus manual restoration | `FocusTrap`                          |
| Escape               | native `cancel`                 | `FocusTrap` key handler              |
| Outside click        | dialog rectangle hit-test       | `Dismisser`                          |
| Background inertness | browser                         | none                                 |
| Events               | none                            | none                                 |
| Announcements        | hardcoded English               | hardcoded English                    |

Verified defects and gaps:

1. Removing an open custom modal can leave `body.style.overflow = "hidden"` behind.
2. Closing a custom modal overwrites any pre-existing inline body overflow value.
3. The native path does not listen for `close`, so `method="dialog"` and external `.close()`
   bypass controller state and announcements.
4. Native focus restoration is duplicated with a delayed manual focus call.
5. The custom path does not make background content inert to assistive technology.
6. Announcements are hardcoded and the global live region is outside an open modal dialog.
7. There is no Rails helper or Tailwind modal theme.
8. The current unit tests mock `showModal()` and `close()` in jsdom, so they do not verify native
   focus, top-layer, form, Escape, or backdrop behavior.

Correction to the previous draft: calling `showModal()` on a dialog that is already open
modally is a no-op in the current HTML algorithm. It throws when the element is already open
_non-modally_. An `open` guard is still useful, but the former defect description was wrong.

Native modality also does not by itself guarantee page scroll locking. Inertness prevents
interaction with background elements; scroll chaining and viewport scrolling are separate
behaviors and require a CSS contract plus browser testing.

## Design principles

1. **The DOM is the state store.** `dialog.open` is authoritative; no duplicate `isOpen` value.
2. **Use native vocabulary.** Author `closedby`; do not mirror it into two booleans.
3. **Dismissal is not completion.** Escape and backdrop request dismissal. Save, Delete, and
   Confirm explicitly complete the dialog.
4. **Controllers adapt; Rails composes.** JS exposes behavior. Rails helpers own semantic markup.
   Themes own classes.
5. **URLs remain URLs.** Remote forms are normal routes before they are modal presentations.
6. **Progressive enhancement is reversible.** Direct visits and failed JavaScript render usable
   full pages.
7. **Unverified device behavior is a test gate, not a design claim.**

## Architecture

```text
                         GET /projects/42/edit
                                  |
                +-----------------+-----------------+
                |                 |                 |
         Browser + Turbo     Browser, no JS    Hotwire Native
                |                 |                 |
         load modal frame     full HTML page     native modal stack
                |                                   |
         native <dialog>                      same Rails screen
```

## Decisions

### D1 — Native `<dialog>` is the only modal element

Remove the custom overlay path, `overlay` target, `FocusTrap` attachment, `Dismisser`
attachment, and direct `body.style.overflow` mutation from `modal_controller`.

The supported element is `<dialog>` opened with `showModal()`. The controller logs a clear
configuration error and remains inert if its required target is not an `HTMLDialogElement`.

`FocusTrap` remains public API for non-dialog consumers. Its existing defects are not part of
this implementation.

This is a breaking markup change and must ship with a migration guide.

### D2 — Add a purpose-built `Dialog` plumber

Do not subclass `Visibility`. `Visibility` models class/attribute visibility; a dialog models
request cancellation, explicit close, `returnValue`, focus restoration, top-layer membership,
and queued native events.

Add:

- `src/plumbers/dialog.js`
- `attachDialog(controller, options)` export
- `docs/plumber/dialog.md`

The plumber owns listeners and returns an explicit `disconnect()` cleanup operation. It exposes:

| Member             | Meaning                                  |
| ------------------ | ---------------------------------------- |
| `open`             | Read-only reflection of `element.open`   |
| `show(invoker?)`   | Open with `showModal()`                  |
| `dismiss(result?)` | Request a cancellable dismissal          |
| `close(result?)`   | Explicitly complete and close            |
| `disconnect()`     | Remove all native and fallback listeners |

Native `beforetoggle`, `toggle`, `cancel`, and `close` events drive the public lifecycle. The
adapter adds pointer listeners only when it must polyfill unsupported `closedby="any"` behavior.
Canceling `modal:before-open` cancels the native opening `beforetoggle`; canceling
`modal:before-dismiss` cancels the native `cancel` event.

The Stimulus controller attaches the plumber when its dialog target connects and disconnects it
when that target disconnects. This supports Turbo replacing the target without replacing the
controller root.

The adapter serializes transitions. If code closes and immediately reopens the same element,
the reopen waits until the queued native `close` event has completed, preventing a stale close
handler from reporting the newly reopened dialog as closed.

### D3 — Public controller API and events

Controller identifier: `modal`.

Targets:

| Target   | Required | Meaning                   |
| -------- | -------- | ------------------------- |
| `dialog` | yes      | Native `<dialog>` element |

There is no `overlay`, `trigger`, `initialFocus`, `template`, or `loader` target.

Actions and programmatic methods:

| Method                    | Meaning                                                |
| ------------------------- | ------------------------------------------------------ |
| `open(event?)`            | Open the dialog; repeated calls while open are ignored |
| `dismiss(eventOrResult?)` | Request cancellation; respects policy and guards       |
| `close(eventOrResult?)`   | Explicit completion; bypasses dismissal policy         |

For Stimulus actions, `close` and `dismiss` read an optional `result` action parameter. For
programmatic calls they accept a string. Values are normalized to strings before reaching the
native API.

Events are dispatched from the `<dialog>` with prefix `modal`:

| Event                  | Cancellable | Detail       | When                                              |
| ---------------------- | ----------- | ------------ | ------------------------------------------------- |
| `modal:before-open`    | yes         | `{}`         | Immediately before a controller/invoker open      |
| `modal:opened`         | no          | `{}`         | Native dialog reaches the open state              |
| `modal:before-dismiss` | yes         | `{ result }` | Escape, backdrop, or `dismiss()` requests closure |
| `modal:closed`         | no          | `{ result }` | Native `close` fires, regardless of close source  |

`modal:closed` fires exactly once for controller close, Escape, backdrop, `method="dialog"`,
Invoker Commands, and external `.close()`.

External `.close()` and `method="dialog"` do not emit `modal:before-dismiss`; they are explicit
developer mechanisms. Applications needing to guard form submission guard the form submission,
not the modal's dismissal event.

### D4 — `closedby` is the dismissal policy

Rails and HTML author the platform attribute directly:

| `closedby`     | Escape/platform close request | Backdrop | Explicit `close()` / form completion |
| -------------- | ----------------------------- | -------- | ------------------------------------ |
| `any`          | allowed                       | allowed  | allowed                              |
| `closerequest` | allowed                       | ignored  | allowed                              |
| `none`         | ignored                       | ignored  | allowed                              |

Default: `closerequest`. This matches the platform default for a modal dialog and is safer for
forms. Ordinary informational dialogs may opt into `any`.

`dismiss()` respects this policy before calling `requestClose()`. `close()` always uses the
explicit native close path.

Compatibility behavior:

- Set the `closedby` attribute unconditionally; unknown attributes are harmless.
- Feature-detect the `closedBy` IDL property.
- On engines without it, Escape is mediated through `cancel` and backdrop dismissal uses a
  `pointerdown`/`pointerup` pair, matching the platform's same-target rule.
- Use `requestClose()` when present. Otherwise dispatch an equivalent cancellable path before
  calling `.close()`.
- Never implement backdrop dismissal with a lone `click` rectangle test.

An unsaved-changes controller listens to `modal:before-dismiss` and calls `preventDefault()`.
Dirty-form tracking and confirmation UI remain separate from the modal controller.

### D5 — Focus is native-first and placement is intentional

Delete `focusFirst()` and the delayed, unconditional restoration in the modal controller. The
`Dialog` adapter keeps only a narrow cross-engine restoration fallback.

Rules:

- The browser restores focus when it does so correctly. The adapter remembers the Stimulus action
  invoker, native `beforetoggle.source`, or active element and restores it only if focus remains on
  the document or inside the closed dialog after native close handling and application listeners.
- The fallback does not override focus moved elsewhere and ignores a removed invoker.
- Authors select initial focus with `autofocus`.
- Without `autofocus`, the browser normally chooses the first focusable descendant; it does not
  promise to focus the dialog itself.
- Confirmation helpers default `autofocus` to Cancel or the least destructive action.
- Long or semantically rich dialogs may autofocus a static heading or introductory element made
  programmatically focusable with `tabindex="-1"`.
- If the invoking element is removed, choosing the next workflow focus is application-specific
  and belongs in a `modal:closed` listener.

Every dialog requires an accessible name through `aria-labelledby` or `aria-label`. The Rails
helper prefers a visible heading and `aria-labelledby`.

Do not author redundant `aria-modal="true"` on a native dialog opened with `showModal()`.

### D6 — Form and result semantics

`<form method="dialog">` is the preferred local confirmation mechanism.

Before each successful open, reset `dialog.returnValue` to `""`. This prevents a previous
confirmation result from leaking into a later Escape dismissal.

Examples of stable results:

- `cancel`
- `confirm`
- `delete`
- an application-defined identifier

`modal:closed` always reports `{ result: dialog.returnValue }`.

The controller does not claim to provide a Promise API. Applications can wrap the one-shot
`modal:closed` event in a Promise when that calling style is useful.

### D7 — No generic open/close announcements

Remove `announceOpen` and `announceClose` from the modal API.

Opening a correctly named modal moves focus into it and exposes its dialog role and name. A
second “Modal opened” announcement is redundant. A live region appended to `body` is outside the
active modal and is inert, so it is not a reliable announcement channel while the dialog is open.

Status, validation, loading, and save messages inside a dialog use a live region located inside
that dialog. Improving the general `announce()` utility for modal-local status is a separate
accessibility task.

### D8 — Responsive web presentation is CSS-only

The same dialog element has two web presentations:

- `sm` and wider: centered surface with tokenized maximum width.
- below `sm`: full-screen surface.

Required layout contract:

- Reset UA margin, padding, border, maximum inline/block size, and box sizing.
- Use grid or flex rows for header, body, and footer.
- Apply `min-block-size: 0`, `overflow-y: auto`, and `overscroll-behavior: contain` to the body.
- Keep primary actions visible when content scrolls.
- Apply `env(safe-area-inset-*)` padding on full-screen layouts.
- Use `100vh` as the block-size fallback, then override it inside `@supports (height: 100dvh)`
  with `100dvh`; use the same ordered fallback/support override for the desktop maximum height.
- Respect text zoom and allow the dialog body to scroll at 400% zoom.

Page scroll contract:

```css
html:has(dialog.sp-modal) {
  scrollbar-gutter: stable;
}

html:has(dialog.sp-modal[open]) {
  overflow: hidden;
}

dialog.sp-modal {
  overscroll-behavior: contain;
}
```

The final selectors belong to the theme and must be scoped to this component. The supported
contract allows one active modal at a time. Opening another modal while one is open is unsupported;
applications should close or replace the active modal first. No JavaScript lock counter or saved
inline style is required.

Animation uses `@starting-style` and discrete transitions for both `display` and `overlay`, plus
matching backdrop transitions. The packaged animation stylesheet is the sole opacity/transform
owner for the dialog surface and backdrop; theme utilities do not duplicate those states. All
animation is disabled under `prefers-reduced-motion: reduce`.

The full-screen layout is expected to work better with software keyboards because its body is a
normal scroll container. That remains a real-device acceptance test, not a universal guarantee.

### D9 — Turbo lifecycle is explicit

The controller handles `turbo:before-cache` by synchronously closing an open dialog. Cached page
snapshots must never contain an open modal, an active backdrop, or a pending closing state.

Stimulus target lifecycle callbacks own native listener attachment and cleanup. The design must
support:

- the entire controller being replaced;
- only the dialog target being replaced by a Turbo Stream;
- a body replacement during a Turbo visit;
- Turbo morphing attributes or children;
- controller disconnection and later reconnection to the same element.

Turbo modals are not `data-turbo-permanent` by default. Persistence across visits is a product
decision and can preserve stale form state, so applications must opt into it deliberately.

### D10 — Remote forms use a Turbo modal, not `ContentLoader`

The application layout may render one Turbo modal:

```erb
<%= sp_modal_turbo id: "modal" %>
```

Conceptual output:

```html
<div
  data-controller="modal modal-turbo"
  data-modal-turbo-close-on-success-value="true"
  data-action="modal:closed->modal-turbo#onClosed"
>
  <dialog
    class="sp-modal"
    data-modal-target="dialog"
    aria-labelledby="modal-title"
  >
    <turbo-frame
      id="modal"
      data-modal-turbo-target="frame"
      data-action="turbo:before-fetch-request->modal-turbo#onBeforeFetchRequest
                              turbo:frame-render->modal-turbo#onFrameRender
                              turbo:submit-end->modal-turbo#onSubmitEnd"
    ></turbo-frame>
  </dialog>
</div>
```

`modal-turbo` is the Turbo Frame adapter for `modal`. It does not fetch directly. It:

- opens after a non-empty successful `turbo:frame-render` event;
- leaves HTTP 422 validation responses open;
- optionally closes after a successful form submission;
- clears stale frame content after close, not before the exit transition;
- closes and clears itself before Turbo caches the page.

The controller resets pending successful-submit state when `turbo:before-fetch-request` starts a new
frame request. The frame-render action reads the event's `fetchResponse`; `turbo:frame-load` has
no response detail and is not used. If a successful submission's frame render arrives after
`turbo:submit-end`, the controller clears that response without reopening the dialog. The four
actions are `onBeforeFetchRequest(event)`, `onFrameRender(event)`, `onSubmitEnd(event)`, and
`onClosed(event)`. `close_on_success` defaults to `true` and may be set to `false`.

Communication between `modal-turbo` and `modal` uses their public methods or explicit request
events; `modal-turbo` must not duplicate the dialog state machine.

The Rails endpoint remains a complete navigable page. A Turbo Frame request returns a matching
frame, while a direct request renders the normal page layout. No modal-only endpoint is created.
The matching frame response has direct `<header>`, body `<div>`, and optional `<footer>` region
children. When `aria-labelledby` is used, the header contains the visible `h2#modal-title`; a
footer submit may target the body form with the standard HTML `form` attribute.

### D11 — Hotwire Native uses modal navigation for routes

A route-level form is not wrapped in a web dialog inside Hotwire Native. Its URL is assigned
`context: "modal"` through Hotwire Native path configuration.

The Rails link helper renders:

- a Turbo Frame-targeted link in a web browser;
- a normal application link for `hotwire_native_app?`, allowing Hotwire Native to make a visit
  proposal and present the route on its native modal stack.

After successful mutation, Rails uses the navigation-aware redirect helpers provided by
`turbo-rails`, such as `recede_or_redirect_to`, `refresh_or_redirect_to`, or
`resume_or_redirect_to`, according to whether the underlying screen must refresh.

Native configuration owns native presentation:

- iOS `modal_style` chooses large, medium, full, page-sheet, or form-sheet presentation.
- Android path configuration chooses the registered modal destination URI.
- Pull-to-refresh is disabled on modal form routes.
- `modal_dismiss_gesture_enabled` is disabled statically for routes that must never be swiped
  away with unsaved data.

If native gesture dismissal must change dynamically with dirty form state, that is an opt-in
Hotwire Native Bridge component. The web modal controller does not reach into Swift or Kotlin.

Small local confirmations may still use `<dialog>` inside the web view. Replacing a particular
confirmation with `UIAlertController`, an Android dialog, or a bottom sheet is an optional Bridge
enhancement with an HTML fallback.

### D12 — Layered date and time panels are a separate design

The modal project does not modernize popover, combobox, calendar, or time panels.
Those responsibilities are specified in the
[overlay](./2026-09-11-overlay-foundation-modernization-design.md),
[combobox](./2026-09-11-combobox-modernization-design.md), and
[calendar](./2026-09-11-calendar-modernization-design.md)
redesigns.

Requirements for that follow-up design:

- Use the Popover API for top-layer rendering without moving DOM nodes.
- Use programmatic `showPopover()` for text combobox inputs; a text input is not a declarative
  `popovertarget` button.
- Define anchor ownership, uniqueness/scoping, unsupported-anchor fallback, and browser tests.
- Do not claim CSS can switch an element between `showPopover()` and `showModal()`.
- Prefer native `input[type="date"]` and `input[type="time"]` for mobile-first forms unless a
  named product requirement justifies a custom calendar field.
- Test Escape ordering inside an open modal before declaring the combination supported.

Until that work lands, modal documentation must not promise that every existing date or time panel escapes a
scrolling modal body.

**Escape with an open popover (amended 2026-10-05).** WebKit closes an `auto` popover and its
modal dialog on one Escape; Chromium and Firefox close only the popover. The `Dialog` plumber:

- listens for `keydown` on the document (bubble phase), so Escape is seen when focus
  is stranded on `body`; it acts only while the dialog is open and the target is inside it or is
  `body`/`html`;
- skips when the key is not Escape, the event is `defaultPrevented`, or `isComposing`;
- skips when the dialog contains a nested open dialog, which owns its own Escape; otherwise the
  nested modal would stay open but invisible inside a hidden popover;
- tracks open order with a capture `beforetoggle` listener on the dialog (synchronous, unlike
  `toggle`), falling back to document order for popovers opened before the plumber attached, and
  hides the most recently opened popover that is not `manual` and is still open inside the dialog,
  after preventing default. Document order is wrong for source-nested popovers. Manual popovers
  own their dismissal. `closedby` does not affect this.

Preventing default alone also stops the native popover close, so the plumber must hide it.
Cancelling the dialog's `cancel` event instead fails in WebKit and Firefox. Verified in all three
engines. A bare `<dialog>` without the modal controller is not covered.

## Rails API

Ship the renderer and theme with the JavaScript behavior.

### `sp_modal`

```erb
<%= sp_modal id: "delete-project",
             title: "Delete project?",
             size: :md,
             closed_by: :closerequest do |modal| %>
  <% modal.trigger { "Delete project" } %>

  <% modal.body do %>
    <p>This action cannot be undone.</p>
  <% end %>

  <% modal.footer do %>
    <%= modal.dismiss_button "Cancel", autofocus: true %>
    <%= modal.close_button "Delete", result: "delete", variant: :destructive %>
  <% end %>
<% end %>
```

Proposed options:

| Option           | Default                       | Notes                                                    |
| ---------------- | ----------------------------- | -------------------------------------------------------- |
| `id:`            | required                      | Stable dialog ID and ARIA relationship prefix            |
| `title:`         | required unless `aria_label:` | Visible accessible name                                  |
| `aria_label:`    | `nil`                         | Name for intentionally titleless dialogs                 |
| `size:`          | `:md`                         | Theme token, not raw Tailwind class                      |
| `closed_by:`     | `:closerequest`               | `:any`, `:closerequest`, or `:none`                      |
| `kind:`          | `:dialog`                     | `:dialog` or explicitly supported alert-dialog treatment |
| `**html_options` | —                             | Forwarded to the outer controller wrapper                |

Blank IDs, missing accessible names, and unsupported `closed_by:` or `kind:` values raise
`ArgumentError`. Visual theme options such as `size:` use the theme's warning and fallback path.

The yielded builder owns the trigger and dialog under one `modal` controller scope, matching
the existing `sp_popover` composition. Builder methods are `trigger`, `header`, `body`,
`footer`, `dismiss_button`, and `close_button`. The trigger is optional for dialogs opened by
application code. The body is the only default scrolling region.

`modal.trigger` has the same two block forms as `sp_popover`:

- a zero-arity block renders the packaged button; and
- a one-arity block receives the complete attributes for a caller-rendered trigger.

The trigger authors `commandfor`/`command="show-modal"` for no-JavaScript enhancement and a
`modal#open` Stimulus action fallback. The controller action prevents the native command's
default activation, so a cancellable `modal:before-open` cannot be bypassed by both mechanisms
running for the same click. It does not use `aria-expanded`.

`modal.header` adds content beside the generated visible title; it does not replace the title or
its accessible-name relationship. A titleless dialog using `aria_label:` may use the header for
other visible content.

### `sp_modal_turbo` and `sp_modal_link_to`

`sp_modal_turbo` renders the layout-level Turbo modal. `sp_modal_link_to` targets the Turbo modal
on web and emits a normal navigational link for Hotwire Native. Direct URL behavior remains
the caller's Rails action and template responsibility.

Successful state-changing submissions should redirect according to Turbo's normal form contract;
HTTP 303 is the recommended redirect status when the request method is not GET.

`sp_modal_turbo` requires `id:` as the stable frame ID and accepts `size: :md`,
`closed_by: :closerequest`, `close_on_success: true`, and `aria_label: nil`. The link requires
`modal_id:` and uses that same frame ID.

## Tailwind theme

Add a Modal theme module and corresponding schema keys for:

- wrapper/surface;
- backdrop;
- header;
- title;
- body;
- footer;
- size tokens;
- full-screen mobile modifiers.

Do not place semantic structure in CSS. Do not require consumers to copy a long raw utility list.
The Rails renderer requests named theme keys, following the existing theme architecture.

Global animation CSS contains only rules that cannot be expressed cleanly through resolved
utility classes, including discrete top-layer transitions and `@starting-style`.

## Accessibility contract

- Native `<dialog>` opened with `showModal()` supplies modal semantics and background inertness.
- Every dialog has an accessible name.
- Initial focus is intentionally selected for packaged confirmation variants.
- Escape remains available unless the product deliberately selects `closedby="none"`.
- Every dialog contains a visible close, cancel, or completion control.
- Focus restoration is native-first with the narrow stranded-focus fallback; removed-invoker
  workflow focus is application-defined.
- No redundant generic open/close live announcement.
- Validation and status messages live inside the active dialog.
- `aria-expanded` is not placed on an ordinary modal trigger.
- `aria-hidden` is never applied to the dialog's ancestors or background as a native-modal shim.

Update `ARIA.md` to remove the current announcement requirement and describe dismissal versus
explicit completion.

## Testing

### Unit tests (`stimulus-plumbers`)

- Missing or non-dialog target produces one clear error and no exception.
- Target connect/disconnect attaches and removes every listener.
- `open`, `dismiss`, and `close` call the correct native methods.
- `returnValue` resets before reopen.
- `modal:before-open` and `modal:before-dismiss` cancellation is honored.
- `modal:closed` includes the normalized result and fires exactly once.
- `closedby` fallback covers all three policies.
- Pointer fallback requires matching pointerdown/pointerup outside the surface.
- Disconnect and `turbo:before-cache` leave no controller-owned state behind.
- Close-then-immediate-open is serialized correctly.

jsdom tests may mock native methods only for adapter logic. They are not evidence of native dialog
behavior.

### Browser tests

Run behavioral Playwright coverage in Chromium desktop/mobile, Firefox, and WebKit for the
core modal, Turbo modal, and directly navigable form routes:

- focus placement with and without `autofocus`;
- focus restoration;
- Escape and backdrop behavior for every `closedby` policy;
- `method="dialog"` result propagation;
- external `.close()` observation;
- repeated modal open and non-modal/open conflict;
- page scroll and scroll chaining;
- Turbo Frame render, target replacement, HTTP 422, success, clear, and cache restoration;
- centered desktop and full-screen mobile presentation;
- a 320 CSS-pixel viewport (400% reflow equivalent) and reduced motion.

### Manual/device gates

Before release:

| Environment                 | Required verification                                                        |
| --------------------------- | ---------------------------------------------------------------------------- |
| VoiceOver + Safari on macOS | name, initial focus, Escape, restore, validation messages                    |
| NVDA + Firefox on Windows   | same contract                                                                |
| iOS Safari, real device     | keyboard scroll-into-view, footer reachability, safe areas, root scroll lock |
| Hotwire Native iOS          | modal route, form validation, success dismissal, gesture policy              |
| Hotwire Native Android      | modal destination, Back behavior, validation, success dismissal              |

Pixel emulation is useful for layout snapshots but does not satisfy the iOS keyboard gate.

### Release gates

- Run the repository's Linux snapshot-update workflow after the modal fixtures are final, review
  the generated desktop/mobile closed/open baselines, and commit them before merge.
- Ensure the release-generated changelogs prominently label the modal API change as breaking and
  include the migration section's before/after markup.

## Packaging and documentation

Ship in one coordinated release:

- JS controller and `Dialog` plumber.
- Rails `sp_modal`, trigger, Turbo modal, and modal-link helpers.
- Tailwind schema and theme module.
- Updated JS, Rails, plumber, accessibility, and migration documentation.
- Inline confirmation, local form, remote Turbo form, and Hotwire Native route examples.
- Unit, cross-browser, Rails integration, and accessibility tests.

The Rails README must no longer describe Modal as “JS only” once this release ships.

## Migration

Old custom markup:

```html
<div data-controller="modal">
  <div data-modal-target="overlay" hidden>
    <div data-modal-target="modal" role="dialog" aria-modal="true">...</div>
  </div>
</div>
```

New markup:

```html
<div data-controller="modal">
  <button data-action="modal#open">Open</button>
  <dialog data-modal-target="dialog" aria-labelledby="example-title">
    ...
  </dialog>
</div>
```

Migration requirements:

- Change the dialog target name from `modal` to `dialog`.
- Replace the custom element and overlay wrapper with `<dialog>`.
- Remove authored `role="dialog"`, `aria-modal`, body-lock code, and focus-trap code.
- Replace close buttons according to intent: `dismiss` for cancellation, `close` or
  `method="dialog"` for completion.
- Replace announcement values/listeners with meaningful in-dialog status regions where needed.
- Move remote loading to a Turbo modal or keep it as full-page navigation.

Because custom overlays are removed and the target/API changes, release this as an explicitly
documented breaking change. If the package does not use major versions before 1.0, the changelog
must still label it prominently and provide before/after markup.

## Implementation order

1. Implement and browser-test the `Dialog` plumber.
2. Rewrite `modal_controller` and its unit tests.
3. Update `ARIA.md` and JS documentation.
4. Add Rails renderer/helper tests.
5. Add Tailwind theme and cross-browser snapshots.
6. Add Turbo modal integration and cache tests.
7. Add Hotwire Native documentation and complete device gates.
8. Implement the other redesigns against this boundary and the
   [modernization roadmap](./2026-09-11-component-modernization-roadmap.md).

The modal core may merge before the remote Turbo modal only if the Rails helper, base theme, docs,
and migration guide ship with it. Date and time panel modernization is never a blocker for the modal core.
