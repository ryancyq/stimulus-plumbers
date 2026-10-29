# Stimulus Plumbers

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── accessibility/               # ARIA, focus, keyboard utilities
│   │   ├── aria.js
│   │   ├── focus.js
│   │   └── keyboard.js
│   ├── controllers/                 # Stimulus controllers
│   │   ├── *_controller.js
│   ├── date/                        # Date-only core: { year, month, day }, never an instant
│   │   └── index.js
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── formatters/              # Input formatter strategies
│   │   │   └── *.js
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── config.js
│   │   │   ├── geometry.js
│   │   │   ├── index.js
│   │   │   ├── morph.js
│   │   │   └── window_observer.js
│   │   └── *.js
│   ├── index.js                     # Main entry point
│   ├── requestor.js                 # HTTP request helper
│   └── researcher.js                # Fuzzy match / filter helper
├── tests/
│   ├── unit/
│   │   ├── accessibility/
│   │   │   └── *.test.js
│   │   ├── controllers/
│   │   │   └── *.test.js
│   │   ├── date/                    # Runs tests/fixtures/date/*.json across timezones
│   │   │   └── *.test.js
│   │   ├── plumbers/
│   │   │   ├── formatters/
│   │   │   │   └── *.test.js
│   │   │   ├── plumber/
│   │   │   │   └── *.test.js
│   │   │   └── *.test.js
│   │   └── *.test.js
│   ├── fixtures/                    # JSON fixtures shared with the Rails tests
│   ├── support/                     # Shared test helpers (native popover shim)
│   └── setup.js
├── eslint.config.js
├── package.json
├── vite.config.js
├── .prettierrc.json
├── .gitignore
└── README.md
```

> See [README.md](README.md) for installation, controller usage examples, and developer setup.
> See [docs/guide.md](docs/guide.md) for the plain-JS / non-Rails usage guide (source of truth for `stimulus-plumbers-mcp`'s `guide://controller`).

## Guidelines
- **native HTML5 first** - only use controllers when native elements have limitations
- import statements should not end with .js
- **Unit tests** using Vitest (`npm test`)
- **Lint tests** (`npm run lint`, `npm run format:check`) — run synchronously from this package's directory; never background or tail
- **Accessibility helpers** — use `RovingTabIndex.activate()` / `ActiveDescendant` / `FocusTrap` from `src/accessibility/` instead of writing raw keyboard or focus logic in controllers. See `docs/accessibility/design.md` for the full contract and the calendar exception.

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Controllers in this package are responsible for keyboard navigation, focus management, and dynamic ARIA state.

## Controller / Plumber Design Principles

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.

- **Naming** — controller helpers are `_`-prefixed methods (the manifest skips them), not `#private` members.
- **Listener cleanup** — group listeners that share a lifetime (connection, open state, target) under one `AbortController` and abort it when the lifetime ends; some controllers pair `addEventListener`/`removeEventListener`. Stateless helpers (e.g. `onMorph`) take `{ signal }`.
- **`onX(event)` adapts, `x(value)` computes** — only `onX` is safe in a `data-action`. Name the first parameter `event`; the Rails contract test rejects wiring to a method taking a value.
