# Stimulus Plumbers

## Project Overview

A library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/         # npm: @stimulus-plumbers/controllers
├── src/                   # core library
├── tests/                 # test cases
├── */
├── package.json           # package manager
├── CLAUDE.md
└── README.md
stimulus-plumbers-rails/   # Ruby gem: stimulus-plumbers
├── lib/                   # core library
├── test/                  # test cases (unit, accessibility)
├── */
├── Gemfile                # package manager
├── CLAUDE.md
└── README.md
stimulus-plumbers-tailwind/ # Ruby gem: stimulus_plumbers_tailwind
├── lib/                   # theme library
├── test/                  # test cases (unit, snapshots)
├── */
├── Gemfile                # package manager
├── package.json           # Tailwind CLI + Playwright
├── CLAUDE.md
└── README.md
stimulus-plumbers-mcp/     # Ruby gem: stimulus_plumbers_mcp — MCP server exposing API schema + docs to LLM IDEs
├── lib/                   # core library
├── test/                  # test cases
├── */
├── Gemfile                # package manager
└── *.gemspec
```

## Design Principle
- Follow WCAG 2.1 Level AA standards and work with screen readers

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
- Keep docs concise — match the style of existing entries (one-line bullets, minimal prose).

## Testing Guideline
- **Keyboard navigation tests** (Tab, Enter, Space, Escape, Arrows)
- **Focus management tests** (focus traps, restoration)
- **ARIA attribute tests** (roles, labels, states)
- **Visual snapshot tests** using Playwright (`npm run test:snapshots` in `stimulus-plumbers-tailwind/`)
- read html output from test output first during a11y violation analysis

## WCAG / ARIA Reference
See [ARIA.md](ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns.
