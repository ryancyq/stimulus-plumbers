# Stimulus Plumbers

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── index.js                     # Package entry: every export
│   ├── accessibility/               # Accessibility utilities (see Guidelines)
│   ├── controllers/                 # <identifier>_controller.js — one Stimulus controller each
│   │   └── combobox/                # <base>.js — mirrors of abstract Combobox::* Rails bases
│   ├── date/                        # Date-only core: { year, month, day }, never an instant
│   ├── datetime/                    # Date-time core: { date, time } on the wall clock, never an instant
│   ├── time/                        # Time-of-day core: { hour, minute }, never an instant
│   ├── plumbers/                    # <name>.js — one plumber each; index.js exports their attach functions
│   │   ├── formatters/              # Input formatter strategies
│   │   └── plumber/                 # Plumber base classes and shared helpers
│   └── *.js                         # Standalone utilities (e.g. requestor.js)
├── tests/                           # Layers in root CLAUDE.md "Testing"
│   ├── unit/                        # <src path>.test.js; a src/<core>/index.js is <core>/<core>.test.js; scripts/ tests sit at the unit/ root
│   ├── fixtures/                    # JSON fixtures shared with the Rails tests
│   ├── support/                     # Shared test helpers and jsdom shims (see Guidelines)
│   └── setup.js                     # jsdom defaults and per-test teardown (root CLAUDE.md "Testing")
├── scripts/                         # Build scripts
└── docs/                            # component/, plumber/, utility/, accessibility/ — one <name>.md each; guide.md
```

> See [README.md](README.md) for installation, controller usage examples, and developer setup.
> See [docs/guide.md](docs/guide.md) for the plain-JS / non-Rails usage guide (source of truth for `stimulus-plumbers-mcp`'s `guide://controller`).

## Guidelines
- **native HTML5 first** - only use controllers when native elements have limitations
- import statements should not end with .js
- **Unit tests** using Vitest (`npm test`) — plumber and controller layers in root CLAUDE.md "Testing", which also covers the `tests/support/stimulus.js` helpers; new jsdom shims go in `tests/support`.
- **Lint tests** (`npm run lint`, `npm run format:check`) — cover `src/` and `tests/`; run synchronously from this package's directory; never background or tail
- **Accessibility helpers** — use `RovingTabIndex.activate()` / `ActiveDescendant` / `focusFirst` from `src/accessibility/` instead of writing raw keyboard or focus logic in controllers. See `docs/accessibility/design.md` for the full contract and the calendar exception.

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Controllers in this package are responsible for keyboard navigation, focus management, and dynamic ARIA state.

## Controller / Plumber Design Principles

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.

- **Naming** — controller helpers are `_`-prefixed methods (the manifest skips them), not `#private` members; an unprefixed `onX` names only a `data-action` adapter, never a helper function.
- **Shared base** — a controller extends a class only where its Rails component does; an abstract Rails base has a JS base at the matching path (`Combobox::Temporal` → `controllers/combobox/temporal.js`); the manifest merges what it passes on. Other shared logic is a helper in `plumbers/plumber/` that keeps nothing (a listener it adds takes the caller's `{ signal }`), or a plumber.
- **Listener cleanup** — group listeners that share a lifetime (connection, open state, target) under one `AbortController` and abort it when the lifetime ends; some controllers pair `addEventListener`/`removeEventListener`.
- **Form reset** — keep a form value in a control the browser restores, never in a snapshot; redraw through a `form:reset` action on the control you draw from (`src/form.js` dispatches it).
- **Plumber disposal** — a plumber that holds listeners, observers, timers, requests, or DOM state owns them and exposes an idempotent `disconnect()`; it never takes an owner's `signal` or wraps controller methods. The controller keeps the instance and calls `disconnect()` in its own `disconnect()`; for a target-scoped plumber, also in `xTargetDisconnected` (same element only) and before replacing it in `xTargetConnected`. Target callbacks run before `connect()` and after `disconnect()`, so never use `this.connection` in them.
- **`onX(event)` adapts, `x(value)` computes** — a `data-action` names only an `onX(event)` adapter or a method that takes no arguments; plain verbs are the programmatic API and never take the event. Name the adapter's first parameter `event`: the manifest reads it to tell an adapter from a method taking a value, and the Rails contract test rejects a `data-action` naming the latter.
