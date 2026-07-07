# Stimulus Plumbers

## Project Overview

A library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/         # npm: @stimulus-plumbers/controllers
stimulus-plumbers-rails/   # Ruby gem: stimulus-plumbers
stimulus-plumbers-tailwind/ # Ruby gem: stimulus_plumbers_tailwind
stimulus-plumbers-mcp/     # Ruby gem: stimulus_plumbers_mcp — MCP server exposing API schema + docs to LLM IDEs
```

## Design Principle
- Follow WCAG 2.1 Level AA (see [ARIA.md](ARIA.md) for the full criteria table and component ARIA patterns)

## Release
- `bin/release <version>` — build + commit + publish all four packages (npm, rails, tailwind, mcp)
- `bin/release <version> --dry-run` — build only, no git, no publish
- `bin/release <version> --only npm|rails|tailwind|mcp` — release a single package
- CI (`release.yml`) calls `bin/release <version> --no-git --only <pkg>` per package

## Docs
- `npm run format:docs` / `format:docs:check` — prettier over all `*/docs/**/*.md`

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
- **Visual snapshot tests** using Playwright (`node --run test:snapshots` in `stimulus-plumbers-tailwind/`)
- read html output from test output first during a11y violation analysis
- **Test use cases, not implementation** — test names describe visual or behavioral outcomes; assertions target semantic tokens and observable effects, not specific CSS utilities or layout mechanisms. Bad: `test_track_uses_border_s`, `assert ms-6`. Good: `test_indicator_is_in_flow_not_absolute`, `assert bg-(--sp-color-primary)`.
