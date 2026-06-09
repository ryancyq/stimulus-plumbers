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
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── index.js
│   │   │   └── support.js
│   │   └── *.js
│   ├── index.js                     # Main entry point
│   ├── requestor.js                 # HTTP request helper
│   └── researcher.js                # Fuzzy match / filter helper
├── tests/
│   ├── unit/
│   │   ├── controllers/
│   │   │   └── *.test.js
│   │   └── plumbers/
│   │       ├── plumber/
│   │       │   └── *.test.js
│   │       └── *.test.js
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

## WCAG / ARIA Reference
See [ARIA.md](../ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns. Controllers in this package are responsible for keyboard navigation, focus management, and dynamic ARIA state.

## Controller / Plumber Design Principles

> See `docs/component/*.md` for HTML structure, Stimulus Controller + Action Wiring.
> Ensure examples provided are tested.
