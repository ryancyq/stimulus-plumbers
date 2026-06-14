# Gem Rename: snake_case → dashed-case (full Ruby convention)

> Analysis + plan for renaming the three Ruby gems from snake_case to dashed-case,
> adopting the full Ruby naming convention (dash → `::` namespace, `/` require path).
> Scope decision: **full convention**; published-gem policy: **new name going forward only**
> (no deprecation/yank of existing `stimulus_plumbers` / `stimulus_plumbers_tailwind`).

## Current state

| Gem (`spec.name`) | Dir | Published on rubygems.org? |
|---|---|---|
| `stimulus_plumbers` | `stimulus-plumbers-rails/` | yes (HTTP 200) |
| `stimulus_plumbers_tailwind` | `stimulus-plumbers-tailwind/` | yes (HTTP 200) |
| `stimulus_plumbers_mcp` | `stimulus-plumbers-mcp/` | no (run-from-clone) |

`stimulus-plumbers` (dashed) is currently free (404). The npm package is already dashed
(`@stimulus-plumbers/controllers`) → out of scope.

**Published-gem reality:** RubyGems has no rename. `stimulus_plumbers` and `stimulus-plumbers`
are different gems; the old names stay published forever. Per the chosen policy we simply rename
in-repo and the next release publishes under the new names — no deprecation notice.

## Target naming (full convention)

| Gem | `spec.name` | Require path | Root namespace | lib dir |
|---|---|---|---|---|
| rails | `stimulus-plumbers` | `stimulus/plumbers` | `Stimulus::Plumbers` | `lib/stimulus/plumbers/` |
| tailwind | `stimulus-plumbers-tailwind` | `stimulus/plumbers/tailwind` | `Stimulus::Plumbers::Tailwind` + `Stimulus::Plumbers::Themes::Tailwind` | `lib/stimulus/plumbers/` |
| mcp | `stimulus-plumbers-mcp` | `stimulus/plumbers/mcp` | `Stimulus::Plumbers::Mcp` + `Stimulus::Plumbers::MCP` | `lib/stimulus/plumbers/` |

## Risk analysis — grounded in the actual code

### Looks scary but verified safe

- **`Dispatcher#build`'s `safe_constantize` (`plumber/dispatcher.rb:20`)** — the only string→class
  path. The renderer tables that feed it (`form/fields/renderer.rb`) hold **symbols**
  (`:render_text_input`), never namespace-qualified strings, so the dispatcher always hits the
  `Symbol`/`MethodCall` branch. No `"StimulusPlumbers::…"` literal is ever constantized.
  **Not a rename hazard.**
- **`ComponentControllerMap` reflection (`loaders/component_controller_map.rb:29,33`)** — uses
  `klass.name.demodulize.underscore` and `value.name.start_with?("#{mod.name}::")`. Both read the
  runtime module name → self-adjust to any namespace depth. Output keys (`:button`, …) unchanged
  → **the MCP/LLM-facing contract stays stable.**
- **Bundler auto-require gotcha disappears at this scope.** A dashed `spec.name` makes Bundler
  auto-`require "stimulus/plumbers"`. Under full convention the entry file *is*
  `lib/stimulus/plumbers.rb`, so sibling `path:` gems and consumers work with no explicit
  `require:`. (This is the upside of full convention vs. name-only.)

### What actually bites

1. **Three-token collision in find/replace (highest footgun).** A naive global
   `StimulusPlumbers → Stimulus::Plumbers` corrupts `StimulusPlumbersTailwind` →
   `Stimulus::PlumbersTailwind` and `StimulusPlumbersMcp` → `Stimulus::PlumbersMcp`. Replace
   **longest-first**:
   1. `StimulusPlumbersTailwind` → `Stimulus::Plumbers::Tailwind`
   2. `StimulusPlumbersMcp` → `Stimulus::Plumbers::Mcp`
   3. `StimulusPlumbers` → `Stimulus::Plumbers`

   142 lib files reference the namespace.

2. **Physical asset/dir paths do NOT move with the namespace — a separate, consumer-breaking
   decision.** Independent of the Ruby module:
   - `app/assets/javascripts/stimulus-plumbers/` (dashed — JS bundle)
   - `app/assets/stylesheets/stimulus_plumbers/` (snake)
   - `engine.rb:13` precompile literal `stimulus_plumbers/tokens.css`
   - `engine.rb:9` `autoload_paths << ".../stimulus-plumbers"`

   Consumers reference these in `stylesheet_link_tag`/importmap pins. The Ruby rename does **not**
   require touching them; leaving them as-is avoids breaking layouts. **Decision, not a mechanical
   edit.** (MCP `stimulus_manifest` reads `../stimulus-plumbers/dist/...` — already dashed →
   untouched.)

3. **Manual `require_relative` web, not Zeitwerk.** The rails entry alone has ~60
   `require_relative "stimulus_plumbers/…"` lines; every gem's per-file requires plus cross-gem
   `require "stimulus_plumbers"` / `require "stimulus_plumbers_tailwind"` must change to
   `stimulus/plumbers…`. The three entry files also move (`lib/stimulus_plumbers.rb` →
   `lib/stimulus/plumbers.rb`). Deterministic and boot-test-caught, but high-volume — one missed
   path = `LoadError`.

4. **Rails engine namespace (`engine.rb`).** `isolate_namespace StimulusPlumbers` →
   `Stimulus::Plumbers` requires a top-level `module Stimulus` to exist first.
   **Domain-specific collision risk:** the `stimulus-rails` gem also defines top-level
   `module Stimulus`, which a consumer app almost certainly loads. Ruby reopens modules so
   `Stimulus::Plumbers` + `Stimulus::Engine` coexist, but this needs an explicit boot check (load
   order, no constant clash). **The one risk not clearable by static reading** — needs a real boot
   in the sandbox app with `stimulus-rails` present.

5. **LLM-facing MCP doc strings carry the namespace literally** — `guide_loader.rb:13`,
   `theme_loader.rb:9,35,53` embed `StimulusPlumbers::Form::Builder` /
   `StimulusPlumbers::Themes::Base` in markdown. Caught by the string replace, but the MCP
   **dogfooding run** (per mcp CLAUDE.md) must be redone so generated guidance teaches the new
   constant.

6. **CI/release plumbing.** `release.yml` push globs `pkg/stimulus_plumbers-$VERSION*.gem` and
   committed file path `lib/stimulus_plumbers/version.rb`; `bin/bump-version` likely seds the
   version path. cliff.toml tag prefixes are directory-based (`stimulus-plumbers-rails/`) →
   unchanged.

## Plan

### Phase 0 — Decide asset-path policy (blocking)

Confirm whether `app/assets/.../stimulus_plumbers/`, the `tokens.css` precompile path, and JS
controller registration paths stay as-is (**recommended** — avoids breaking consumer layouts) or
also get renamed. The phases below assume **assets stay**.

### Phase 1 — rails gem (`stimulus-plumbers`)

1. `git mv lib/stimulus_plumbers.rb lib/stimulus/plumbers.rb`; `git mv lib/stimulus_plumbers
   lib/stimulus/plumbers`; same for `test/stimulus_plumbers` → `test/stimulus/plumbers`.
2. Add `module Stimulus; end` shim (or `module Stimulus; module Plumbers; …`).
3. Three-token replace (longest-first) across `lib/`, `test/`, `app/`, `config/`.
4. Rewrite require paths `stimulus_plumbers/` → `stimulus/plumbers/` (entry + per-file).
5. Gemspec: `spec.name = "stimulus-plumbers"`, rename file to `stimulus-plumbers.gemspec`, fix
   `require_relative "lib/stimulus/plumbers/version"` + `Stimulus::Plumbers::VERSION`.
6. `engine.rb`: `isolate_namespace Stimulus::Plumbers`; leave asset literals per Phase 0.
7. Verify: `rake test:unit` + `rake test:accessibility` (boots sandbox with stimulus-rails →
   clears risk #4) + `rubocop`.

### Phase 2 — tailwind gem

Same mechanics; `StimulusPlumbersTailwind` → `Stimulus::Plumbers::Tailwind`; cross-gem
`require "stimulus_plumbers"` → `require "stimulus/plumbers"`; gemspec name +
`add_dependency "stimulus-plumbers"`; Gemfile `gem "stimulus-plumbers", path:`. Verify unit +
snapshot tests.

### Phase 3 — mcp gem

Same; `StimulusPlumbersMcp` → `Stimulus::Plumbers::Mcp`; both cross-gem requires; gemspec name +
both `add_dependency`s dashed; Gemfile path lines. Then **re-run the dogfooding** harness
(`bin/mcp-query`) + `rake test` (incl. accuracy + integration).

### Phase 4 — repo-level

- Root `README.md` table + badges (`gem/v/stimulus_plumbers` → `stimulus-plumbers`), each gem
  README install line.
- `release.yml`: job names, push globs, committed version paths.
- Sibling `path:` names in all three Gemfiles; delete stale `Gemfile.lock`s (per the release.yml
  comment).
- CLAUDE.md folder-structure blocks referencing `lib/stimulus_plumbers/`.

### Verification gate (success criteria)

All three gems' full test suites green; sandbox boots with `stimulus-rails` loaded; `gem build`
succeeds for each new name; an MCP dogfood run produces correct `Stimulus::Plumbers::…` guidance.

## Open decisions

- **Phase 0 asset paths** — recommend keeping asset paths as-is so consumers don't break.
- **`stimulus-rails` top-level `Stimulus` collision** — the one risk needing an actual boot to
  confirm, not static analysis.
