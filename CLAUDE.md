# Stimulus Plumbers

## Project Overview

A library of accessible Stimulus controllers that follow WCAG 2.1+ standards. This package provides semantically correct, keyboard-navigable UI components built on the Hotwire Stimulus framework.

## Folder Structure

```
stimulus-plumbers/         # npm: @stimulus-plumbers/controllers
stimulus-plumbers-rails/   # Ruby gem: stimulus-plumbers
stimulus-plumbers-tailwind/ # Ruby gem: stimulus_plumbers_tailwind
stimulus-plumbers-mcp/     # Ruby gem: stimulus_plumbers_mcp — MCP server exposing API schema + docs to LLM IDEs
bin/                       # Repo scripts
```

## Design Principle
- Follow WCAG 2.1 Level AA (see [ARIA.md](ARIA.md) for the full criteria table and component ARIA patterns)

## Release
- `bin/release <version>` — build + commit + publish all four packages (npm, rails, tailwind, mcp)
- `bin/release <version> --dry-run` — build only, no git, no publish
- `bin/release <version> --only npm|rails|tailwind|mcp` — release a single package
- CI (`release.yml`) calls `bin/release <version> --no-git --only <pkg>` per package

## CI
- Never put `${{ … }}` inside a workflow `run:`; pass it through `env:` and reference the shell variable (`"$VAR"`)

## Docs
- `npm run format:docs` / `format:docs:check` — prettier over all `*/docs/**/*.md`

## Doc Update Rule
- When changing component API (targets, values, options, HTML structure), update `docs/component/*.md` and any CLAUDE.md sections that reference it in the same change.
- Keep docs concise — one-line bullets, minimal prose. If a sentence restates what the code makes obvious, cut it.
- **Folder Structure trees** in CLAUDE.md list directories with their naming rule (`<identifier>_controller.js`, `<name>.rb` + `<name>/`), plus entry points and the config files whose role the name doesn't make obvious — never per-component, per-helper, or per-test files, so adding one never stales the tree. A tree's naming rule may restate a Convention section's file naming; nothing else in a tree repeats another CLAUDE.md section. Every listed path exists in git or is commented as gitignored; when a directory is added, moved, or removed, update the tree in the same commit.
- **`docs/*` never mentions tests** — no test file names, paths, or coverage notes. Docs describe the API for consumers; test info belongs in CLAUDE.md. State a requirement as a rule ("must be paired with an accessible name"), not as "enforced by X test".
- **No cross-doc duplication.** Each fact lives in exactly one place; other docs link to it instead of repeating it.
  - JS controller API (targets, values, actions, events) → `stimulus-plumbers/docs/component/<name>.md` only. Rails and Tailwind docs link there.
  - Rails helper options → `stimulus-plumbers-rails/docs/component/<name>.md` only.
  - ARIA/WCAG patterns → `ARIA.md` only. Component docs do not restate ARIA rules.
  - Plumber factory API → `stimulus-plumbers/docs/plumber/<name>.md` only. Controller docs reference the plumber doc, not inline it.
- When adding a new exported controller or utility to `stimulus-plumbers/src/index.js`, add a row to the Controllers or Utilities table in `stimulus-plumbers/README.md` and create `docs/component/<name>.md` or `docs/utility/<name>.md` in the same commit.
- When adding a new Rails helper (`sp_*`), add a row to the Components table in `stimulus-plumbers-rails/README.md` and create `docs/component/<name>.md` in the same commit. Never reference a doc file in any README unless that file already exists.
- When removing a component or helper, remove its README table row, doc file, and any cross-references in ARIA.md in the same commit.
- Export name in `src/index.js` must match the name used in the README setup snippet and the Controllers table — verify with `grep` before writing docs.

## Testing

Every behaviour has exactly one owning layer — the first layer below that can observe it. The one sanctioned overlap: a user-facing interaction keeps its logic branches in a controller test and one keyboard/focus happy path in a Rails a11y test.

| Layer | Location | Owns | Never asserts |
|---|---|---|---|
| Plumber unit — Vitest on jsdom | `stimulus-plumbers/tests/unit/{plumbers,accessibility,date}/`, `stimulus-plumbers/tests/unit/{requestor,researcher}.test.js` | Plumber and helper contracts: return values, dispatched events, invoked callbacks, idempotent `disconnect()` | Controller wiring, private fields, listener registration |
| Controller unit — Vitest on jsdom | `stimulus-plumbers/tests/unit/controllers/<identifier>_controller.test.js` | Stimulus lifecycle behaviour: actions, target/value callbacks, keyboard handling, the ARIA state a controller writes, dispatched events, Turbo cache/morph handling, no effect after disconnect | Engine-computed layout, the top layer, pointer capture, accessible-name computation, CSS |
| Rails unit — Minitest | `stimulus-plumbers-rails/test/stimulus_plumbers/` | Rendered HTML structure and ARIA, every option branch, I18n defaults | Theme CSS classes (only a caller's own `class:` passthrough, or a stub theme's classes), JS behaviour |
| Rails a11y — Capybara + Cuprite + axe-core | `stimulus-plumbers-rails/test/accessibility/<url>_accessibility_test.rb` | WCAG 2.1 AA per page and state (axe), plus one keyboard/focus happy path per user interaction | Logic edge cases, styling |
| Contract | `stimulus-plumbers-rails/test/stimulus_plumbers/stimulus_contract_test.rb`, `stimulus-plumbers-rails/test/tasks/`, `stimulus-plumbers/tests/unit/build-controllers-manifest.test.js` | Ruby wiring ↔ JS controller manifest: identifiers, targets, values, wired actions ("`onX(event)` adapts, `x(value)` computes" in `stimulus-plumbers/CLAUDE.md`), dispatched events | Behaviour |
| Tailwind theme unit — Minitest | `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/` | Design tokens each resolver branch adds: semantic colours, typography, size-variant dimensions, outcome refutes | Spacing numbers, layout mechanism unless it is all a branch adds, refutes of removed classes |
| Playwright browser | `stimulus-plumbers-tailwind/test/browser/<url>.spec.js` | Engine-native behaviour jsdom cannot model: native `<dialog>`, the Popover API and top layer, CSS anchor positioning, pointer and touch input, cross-engine focus | Screenshots; anything a layer above can observe |
| Playwright snapshot | `stimulus-plumbers-tailwind/test/snapshots/<url>.spec.js` | Pixels and computed styles of the Tailwind theme | Attributes, text content, values, focus, counts |
| Generator and task — Minitest | `stimulus-plumbers-{rails,tailwind}/test/generators/`, `stimulus-plumbers-{rails,tailwind}/test/stimulus_plumbers/tasks_test.rb`, `stimulus-plumbers-rails/test/stimulus_plumbers/{engine_test.rb,generators/}`, `stimulus-plumbers-tailwind/test/stimulus_plumbers/tailwind/` | Files a generator or rake task writes or skips, the warnings it prints, and what the engine registers and hooks into | Component rendering |
| MCP — Minitest | `stimulus-plumbers-mcp/test/` | Loader output and the server round trip | Rendering |

- **Outcomes, not implementation** — names state what the user or caller observes; assertions target observable effects and semantic tokens, never listener spies, private fields, CSS spacing, or a removed class. Bad: `test_track_uses_border_s`, `assert ms-6`. Good: `test_indicator_is_in_flow_not_absolute`, `assert bg-(--sp-color-primary)`.
- **No real-timer sleeps or polling** — Vitest waits with `flush()` / `advance()` (`stimulus-plumbers/tests/support/stimulus.js`) and fake timers, never `vi.waitFor`, `vi.waitUntil`, or `expect.poll`; Capybara and Playwright use their auto-waiting assertions.
- **Every test disposes what it creates** — `stimulus-plumbers/tests/setup.js` stops each application from `startApplication()`, disconnects every window observer, and disconnects every plumber a test passes to `autoDisconnect()`; a test that constructs any plumber other than a window observer, with `disconnect()`, wraps it in `autoDisconnect()`.
- **Paths mirror the URL** a test visits (`/components/display/avatar` → `…/components/display/avatar…`); a file named after its own directory is that directory's index page (`modal/modal` → `/components/modal`).
- **One sandbox app** — `stimulus-plumbers-rails/test/sandbox` backs Rails a11y tests and, through the Tailwind sandbox's layout, every Playwright spec; its conventions are in `stimulus-plumbers-rails/CLAUDE.md`.
- **Enforcement** — the Vitest ESLint rules, the manifest test, and the Rails contract test.
- Read the HTML output first when analysing an a11y violation.
