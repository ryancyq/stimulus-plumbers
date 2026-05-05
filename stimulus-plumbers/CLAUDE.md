# Stimulus Plumbers

## Folder Structure

```
stimulus-plumbers/
├── src/
│   ├── controllers/                 # Stimulus controllers
│   │   ├── *_controller.js
│   ├── plumbers/                    # Core plumber utilities
│   │   ├── plumber/                 # Base plumber classes
│   │   │   ├── index.js
│   │   │   └── support.js
│   │   └── *.js
│   ├── aria.js                      # ARIA utilities
│   ├── focus.js                     # Focus management
│   ├── keyboard.js                  # Keyboard event handlers
│   └── index.js                     # Main entry point
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
- import statement should not ends with .js
- **Unit tests** using Vitest
- **Lint tests** (eslint)

## Controller / Plumber Design Principles

> See `docs/compomnent/*.md` for HTML structure, Stimulus Controller + Action Wiring.
