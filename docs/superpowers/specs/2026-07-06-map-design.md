# Map component design (foundation: display, markers, click-to-coordinates)

## Scope

Third of four Flowbite-inspired sub-projects (see `2026-07-06-status-primitives-design.md`, `2026-07-06-qr-code-design.md` for the first two). Covers a provider-agnostic `map` component/controller with adapter implementations for four providers (OpenStreetMap, Google Maps, Baidu Maps, Naver Map), supporting display, markers with popups, and click-to-coordinates.

**Explicitly deferred to future specs:** geocoding (address ↔ coordinates) and routing/directions with transit-mode selection (bus/train/car/ferry/walk/bicycle). These vary far more per-provider than display/markers do (OSM has no built-in routing at all — would require a separate service like OSRM/GraphHopper), and deserve dedicated design attention rather than being folded into the foundation. Settings/Profile composition remains a separate future brainstorm.

## Provider adapter contract

The `map` controller is provider-agnostic. Each provider is a small adapter module implementing:

```js
Map.registerProvider('osm', {
  load(options): Promise<void>,          // injects/loads the SDK script once; cached per provider+key/url so multiple maps on one page don't double-inject
  init(viewportEl, { center, zoom }): instance,
  addMarker(instance, { lat, lng, popupContent }): markerHandle,
  onClick(instance, callback): void,     // callback({ lat, lng })
  destroy(instance): void,
});
```

Built-in adapters: `osm` (Leaflet + OSM tiles, no key required), `google`, `baidu`, `naver`. `Map.registerProvider` is public API (mirrors `Formatter.register` in `input-formatter`) so apps can add a 5th provider without forking the library.

## Controller

### Values

| Value | Type | Description |
| --- | --- | --- |
| `provider` | String | `"osm"` \| `"google"` \| `"baidu"` \| `"naver"` \| any registered custom name |
| `apiKey` | String | Passed to the adapter's `load()`; irrelevant for `osm` |
| `scriptUrl` | String (optional) | Overrides the adapter's default SDK URL entirely. Supports a server-side proxy scenario (a proxy that appends the key server-side and forwards to the provider, avoiding a client-visible key) — the adapter loads whatever URL it's given instead of constructing one from `apiKey` |
| `center` | Object `{lat, lng}` | Initial center |
| `zoom` | Number | Initial zoom level |

### Targets

| Target | Element | Description |
| --- | --- | --- |
| `viewport` | `<div>` | Where the provider's SDK mounts its canvas/DOM |
| `marker` | `<template data-lat data-lng>` | One per marker; `innerHTML` is arbitrary popup content (address, link, etc.), read at connect and passed to `addMarker` |
| `fallback` | `<a href="...">` | Always server-rendered; hidden once the controller initializes successfully |

### Lifecycle

- `connect()` — resolves the adapter for `providerValue` from the registry, calls `load({ apiKey, scriptUrl })`, then `init(viewportTarget, { center, zoom })`. For each `marker` target, parses `data-lat`/`data-lng`/`innerHTML` and calls `addMarker`. Wires `onClick` to dispatch `map:clicked`. Hides the `fallback` target. Dispatches `map:ready`.
- On any failure in that chain (script load error, adapter throws): `fallback` stays visible, dispatches `map:load-failed`. **No automatic retry** — same failure-handling precedent as the QR code component's `refresh()`; the app can listen for the event and offer its own retry.
- `disconnect()` — calls `destroy(instance)`, preventing leaked SDK instances/listeners across Turbo navigations.

### Dispatches

`map:ready` · `map:clicked` (`{ lat, lng }`) · `map:load-failed`

## Fallback link

Always server-rendered as a real `<a href="...">` pointing at the map's center on the provider's public map URL (e.g. `https://www.google.com/maps?q=lat,lng`) — works with JS disabled, blocked third-party scripts, or missing/invalid keys. This is the one piece of markup guaranteed usable without any SDK loading successfully, and the accessible escape hatch given the known limitation below.

## Rails helper

```ruby
sp_map(provider: :osm, center: { lat:, lng: }, zoom: 12, api_key: nil, script_url: nil, height: "400px") do |m|
  m.marker(lat:, lng:) { "Our office<br><a href=...>Directions</a>" }
end
```

`api_key:`/`script_url:` are both optional passthroughs to the corresponding data-values. The component doesn't validate or require either — a proxy setup may need neither if the proxy itself injects auth server-side and `script_url:` just points at it.

## Theme keys

| Key | Element |
| --- | --- |
| `map` | outer container |
| `map_viewport` | inner div hosting the SDK |
| `map_fallback_link` | the `<a>` fallback |

## Known limitation

Third-party map SDKs — Google/Baidu/Naver's canvas-rendered widgets especially — have historically poor built-in accessibility; keyboard nav and screen reader support inside the widget is largely outside this library's control. The fallback link is the accessible escape hatch. This is documented explicitly in the component doc rather than implying full WCAG compliance for the map interior.

## Testing

- Per-adapter unit tests (`tests/unit/adapters/map/{osm,google,baidu,naver}.test.js`), mocking each provider's global (`window.L`, `window.google`, `window.BMap`, `window.naver`): `load()` dedupes concurrent script injection; `init`/`addMarker`/`onClick`/`destroy` are called with the correct shapes.
- `tests/unit/controllers/map_controller.test.js` (using a stub registered adapter, no real SDK): `fallback` hidden on success / shown on `map:load-failed`; `marker` `<template>` targets parsed into correct `addMarker` calls; click dispatches `map:clicked`; `disconnect()` calls `destroy`.
- `test/stimulus_plumbers/components/map_test.rb`: HTML structure (container/viewport/fallback/marker templates), `api_key:`/`script_url:` independently settable and both optional.
- `test/accessibility/components/map_test.rb`: fallback link has an accessible name; container doesn't break axe structurally (interior SDK a11y is out of scope per the Known Limitation above).

## Docs

New `stimulus-plumbers/docs/component/map.md` (controller values/targets/actions/dispatches/adapter contract) and `stimulus-plumbers-rails/docs/component/map.md` (Rails helper options, linking to the JS doc rather than repeating it, per no-cross-doc-duplication rule). README Components/Controllers table rows in both gems.

## Out of scope

- Geocoding (address ↔ coordinates) — future spec.
- Routing/directions and transit-mode selection — future spec; each provider's routing API differs far more than display/markers, and OSM requires a separate routing service entirely.
- Custom marker icons, clustering.
- The server-side proxy implementation itself — app-owned; this component only supports pointing at one via `script_url:`.
- Settings/Profile composition — separate future brainstorm.
