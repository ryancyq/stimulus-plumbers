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
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── formatters/              # Input formatter strategies
│   │   │   └── *.js
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── config.js
│   │   │   ├── date.js
│   │   │   ├── geometry.js
│   │   │   ├── index.js
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
│   │   ├── plumbers/
│   │   │   ├── formatters/
│   │   │   │   └── *.test.js
│   │   │   ├── plumber/
│   │   │   │   └── *.test.js
│   │   │   └── *.test.js
│   │   └── *.test.js
│   └── setup.js
├── eslint.config.js
├── package.json
├── vite.config.js
├── .prettierrc.json
├── .gitignore
└── README.md
```

> See [README.md](README.md) for installation, controller usage examples, and developer setup.

## Guidelines
- **native HTML5 first** - only use controllers when native elements have limitations
- import statements should not end with .js
- **Unit tests** using Vitest
- **Lint tests** (eslint)
- **Accessibility helpers** — use `RovingTabIndex.activate()` / `ListboxNavigation` / `FocusTrap` from `src/accessibility/` instead of writing raw keyboard or focus logic in controllers. See `docs/accessibility/design.md` for the full contract.

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Controllers in this package are responsible for keyboard navigation, focus management, and dynamic ARIA state.

## Controller / Plumber Design Principles

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Ensure examples provided are tested.
