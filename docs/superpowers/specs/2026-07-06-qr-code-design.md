# QR code component design

## Scope

Second of four Flowbite-inspired sub-projects (see `2026-07-06-status-primitives-design.md` for the first). Covers a new `qr_code` component with two modes: static (server-known data, no JS) and expiring/refreshable (server-known TTL, client-side timer + fetch-and-swap on expiry). Maps and Settings/Profile composition remain separate future brainstorms.

## Dependency

Add `rqrcode` gem dependency to `stimulus-plumbers-rails.gemspec` for QR encoding (Reed-Solomon error correction, matrix layout) — not hand-rolled, consistent with using a maintained library for a well-defined, easy-to-get-subtly-wrong algorithm rather than vendoring one.

## Rendering

`lib/stimulus_plumbers/components/qr_code.rb` — builds an inline `<svg role="img" aria-label="...">` with one `<rect>` per dark module (fixed quiet-zone margin per QR spec minimum), fill color via the theme token (`currentColor`, resolved through `theme.resolve(:qr_code)` same as `icon.rb`), not raw hex from the gem.

```ruby
sp_qr_code(data:, label:, size: 200, expires_at: nil, refresh_url: nil, **html_options)
```

| Option | Default | Description |
| --- | --- | --- |
| `data:` | — required | String to encode |
| `label:` | — **required** | `aria-label` — enforced as a hard `ArgumentError` if missing (unlike Indicator's legend, which is guidance-only): a QR code has no possible visible text substitute, so there's no scenario where omitting it is correct |
| `size:` | `200` | Rendered `width`/`height` in px; `viewBox` scales to module count |
| `expires_at:` | `nil` | When present (with `refresh_url:`), renders the refreshable variant (see below) |
| `refresh_url:` | `nil` | Endpoint returning a fresh `qr_code` fragment; required together with `expires_at:` |
| `**html_options` | — | Forwarded to outer element |

Error-correction level, module size, and quiet-zone margin are fixed defaults, not exposed as options in v1.

## Static variant (no `expires_at:`/`refresh_url:`)

Pure server-rendered SVG, no controller, no JS at all.

## Refreshable variant (`expires_at:` + `refresh_url:` both present)

Wires a `qr-code` Stimulus controller wrapping the SVG.

### Values

| Value | Type | Description |
| --- | --- | --- |
| `expiresAt` | String (ISO 8601) | Deadline; controller computes `expiresAt - now` at connect to schedule a `setTimeout` — no polling |
| `refreshUrl` | String | Endpoint to fetch the replacement fragment from |
| `refreshing` | Boolean | Reflected as `data-qr-code-refreshing-value` for CSS (e.g. dimmed/spinner overlay while fetching) |

### Targets

| Target | Element | Description |
| --- | --- | --- |
| `content` | `<div>` wrapping the `<svg>` | Swapped via `innerHTML` on refresh — server re-renders the whole fragment (new SVG + new `expires_at`), so no client-side QR generation logic is ever needed |
| `status` | visually-hidden `<p aria-live="polite">` | Text updated on refresh (e.g. "QR code refreshed") — the visual swap alone would not be perceived by screen reader users without this |

### Methods / lifecycle

- `connect()` — schedules the timer from `expiresAtValue`; if already past (page loaded after expiry), fires immediately
- `disconnect()` — clears the pending timer, preventing a leaked timeout after element removal
- `refresh()` — sets `refreshingValue = true`; `fetch(refreshUrlValue)`; on success, replaces `content` target's `innerHTML` with the response, updates `status` text, dispatches `qr-code:refreshed`, and re-schedules the timer by reading the freshly-swapped markup's `expires_at` data attribute (the controller element itself is not replaced, only its `content`)
- On fetch failure: dispatches `qr-code:refresh-failed`, `refreshingValue = false`, **no automatic retry** — avoids an unbounded retry loop against a persistently failing endpoint; the app can listen for the event and present its own retry affordance

### Dispatches

`qr-code:expired` (timer fires, before fetch starts) · `qr-code:refreshed` (swap complete) · `qr-code:refresh-failed`

### Server contract

`refresh_url:` is entirely the app's own endpoint. Its only obligation is returning a freshly-rendered `sp_qr_code` fragment (new `data:`, new `expires_at:`). The component makes no assumption about how the app decides the new data or authenticates the request — same precedent as `reorderable`, which dispatches an event and leaves persistence to the app.

## Theme keys

| Key | Element |
| --- | --- |
| `qr_code` | outer `<svg>` (module fill inherits `currentColor`) |
| `qr_code_status` | visually-hidden live-region `<p>` (refreshable variant only) |

## Testing

- `test/stimulus_plumbers/components/qr_code_test.rb` — fixed known input string → asserts exact module count/pattern (regression-pin), missing `label:` raises `ArgumentError`, `expires_at:` without `refresh_url:` (or vice versa) raises `ArgumentError`.
- `tests/unit/controllers/qr_code_controller.test.js` — timer scheduling from `expiresAtValue` including already-past case; `refresh()` swaps content and dispatches `qr-code:refreshed`; fetch failure dispatches `qr-code:refresh-failed` without retrying; `disconnect()` clears the pending timer.
- `test/accessibility/components/qr_code_test.rb` — static variant: sandbox view, `assert_accessible`. Refreshable variant: expired → refreshed transition, asserting the `status` live-region text changes.

## Docs

New `stimulus-plumbers-rails/docs/component/qr_code.md` (Rails helper options + refreshable HTML structure) and `stimulus-plumbers/docs/component/qr-code.md` (controller values/targets/actions/dispatches, per no-cross-doc-duplication rule) — Rails doc links to the JS doc rather than repeating it. README Components table row.

## Out of scope

- Configurable error-correction level, module size, quiet-zone margin, raw hex color overrides.
- Logo-overlay variant.
- Client-side QR encoding of any kind — even the refreshable variant always fetches server-rendered HTML, never re-encodes in the browser.
- Server push (Turbo Stream/ActionCable) for expiry not tied to a fixed TTL — the fixed-TTL client timer covers the stated use case; a push-based variant is a future extension if a use case needs early invalidation.
- Maps, Settings/Profile composition — separate future brainstorms.
