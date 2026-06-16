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
- Keep docs concise — one-line bullets, minimal prose. If a sentence restates what the code makes obvious, cut it.
- **No cross-doc duplication.** Each fact lives in exactly one place; other docs link to it instead of repeating it.
  - JS controller API (targets, values, actions, events) → `stimulus-plumbers/docs/component/<name>.md` only. Rails and Tailwind docs link there.
  - Rails helper options → `stimulus-plumbers-rails/docs/component/<name>.md` only.
  - ARIA/WCAG patterns → `ARIA.md` only. Component docs do not restate ARIA rules.
  - Plumber factory API → `stimulus-plumbers/docs/plumber/<name>.md` only. Controller docs reference the plumber doc, not inline it.
- When adding a new exported controller or utility to `stimulus-plumbers/src/index.js`, add a row to the Controllers or Utilities table in `stimulus-plumbers/README.md` and create `docs/component/<name>.md` or `docs/utility/<name>.md` in the same commit.
- When adding a new Rails helper (`sp_*`), add a row to the Components table in `stimulus-plumbers-rails/README.md` and create `docs/component/<name>.md` in the same commit. Never reference a doc file in any README unless that file already exists.
- When removing a component or helper, remove its README table row, doc file, and any cross-references in ARIA.md in the same commit.
- Export name in `src/index.js` must match the name used in the README setup snippet and the Controllers table — verify with `grep` before writing docs.

## Testing Guideline
- **Keyboard navigation tests** (Tab, Enter, Space, Escape, Arrows)
- **Focus management tests** (focus traps, restoration)
- **ARIA attribute tests** (roles, labels, states)
- **Visual snapshot tests** using Playwright (`npm run test:snapshots` in `stimulus-plumbers-tailwind/`)
- read html output from test output first during a11y violation analysis

## WCAG / ARIA Reference
See [ARIA.md](ARIA.md) for the full WCAG 2.1 AA criteria table and component-specific ARIA patterns.
