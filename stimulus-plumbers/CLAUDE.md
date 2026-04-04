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

### Prerequisites

- **Node.js** >= 18.0.0
- **npm** package manager

### CMD

```bash
npm install           # Install dependencies
npm run dev           # Start development server
npm run preview       # Preview production build
npm test              # Run all tests
npm run test:ui       # Run tests with UI
npm run test:coverage # Run tests with coverage report
npm run lint          # Lint code
npm run format:write  # Format code (write changes)
npm run format:check  # Check code formatting (no changes)
npm run build         # Build distribution
```

**Build outputs:**
- `dist/*.es.js` - ES module format
- `dist/*.umd.js` - UMD format for browsers

## Guidelines
- **native HTML5 first** - only use controllers when native elements have limitations
- import statement should not ends with .js
- **Unit tests** using Vitest
- **Lint tests** (eslint)
