# QR Code Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `qr_code` Rails component (`sp_qr_code`) that renders an inline, dependency-free SVG QR code via the `rqrcode` gem, in two modes: static (server-only, no JS) and refreshable (wraps the SVG with a `qr-code` Stimulus controller that schedules a timer from `expires_at`, fetches a replacement fragment on expiry, and swaps it in).

**Architecture:** `StimulusPlumbers::Components::QrCode < Plumber::Base` builds one `<rect>` per dark QR module from `RQRCode::QRCode#modules` (fixed error-correction level `:m`, fixed 4-module quiet zone), sets `fill="currentColor"` on the outer `<svg>` (module color inherits via CSS, same idea as `icon.rb`'s `stroke="currentColor"`), and validates `label:` (hard-required) and `expires_at:`/`refresh_url:` (must be given together) via `ArgumentError`. In refreshable mode it wraps the SVG in a `<div data-controller="qr-code">` with `content`/`status` targets; the paired `qr_code_controller.js` (JS package) uses the existing `Requestor` utility (already used by `combobox_dropdown_controller.js`) to schedule the expiry timer and fetch the replacement fragment, extracting the new `<svg>` from the response and reading its `data-expires-at` attribute to reschedule — no client-side QR generation ever happens.

**Tech Stack:** `rqrcode` gem (SVG module data, Reed-Solomon error correction), Rails `Plumber::Base`/`ActionView` tag helpers, Stimulus (`@hotwired/stimulus`), the existing `Requestor` fetch/timer utility, Vitest (JS unit tests), Minitest (Ruby unit tests), Capybara + Cuprite + axe-core (accessibility tests).

## Global Constraints

- Follow WCAG 2.1 Level AA (see root `ARIA.md`).
- **Doc Update Rule** (root `CLAUDE.md`): when changing component API, update `docs/component/*.md` and any `CLAUDE.md` sections referencing it in the same change. No cross-doc duplication — JS controller API (values/targets/actions/dispatches) lives only in `stimulus-plumbers/docs/component/qr-code.md`; Rails helper options live only in `stimulus-plumbers-rails/docs/component/qr_code.md`; the Rails doc links to the JS doc rather than repeating it; ARIA/WCAG patterns live only in root `ARIA.md`.
- When adding a new exported controller to `stimulus-plumbers/src/index.js`, add a row to the Controllers table in `stimulus-plumbers/README.md` and create `docs/component/qr-code.md` in the same commit. Export name in `src/index.js` must match the name used in the README setup snippet and Controllers table.
- When adding a new Rails helper (`sp_*`), add a row to the Components table in `stimulus-plumbers-rails/README.md` and create `docs/component/qr_code.md` in the same commit.
- Error-correction level, module size, and quiet-zone margin are fixed defaults for v1 — not exposed as options. No configurable logo-overlay. No client-side QR encoding, ever — the refreshable variant always fetches server-rendered HTML.
- Tailwind theme **class values** (the actual Tailwind utility strings for `qr_code`/`qr_code_status`) are out of scope for this plan — same precedent as the sibling `status-primitives` plan. The Rails component still calls `theme.resolve(:qr_code)` / `theme.resolve(:qr_code_status)` so the extension point exists, and the theme **schema** keys are registered (needed for `Base#resolve`'s arg-validation path), but no `stimulus-plumbers-tailwind` file is touched.
- JS: run `npm test`, `npm run lint`, `npm run format:check` synchronously from `stimulus-plumbers/`, never backgrounded.
- Rails: run single test files with `bundle exec ruby -Itest -Ilib <path>` synchronously from `stimulus-plumbers-rails/`; run the full suite with `rake test:unit`, `rake test:accessibility`, `rake rubocop`.

### Resolved design ambiguity (read before Task 4)

The spec says the `content` target is "Swapped via `innerHTML` on refresh — server re-renders the whole fragment (new SVG + new `expires_at`)" and that the controller reschedules "by reading the freshly-swapped markup's `expires_at` data attribute (**the controller element itself is not replaced**, only its `content` target)". If the `refresh_url:` response were the *entire* `sp_qr_code` wrapper (outer `data-controller="qr-code"` div + content + status), swapping it into `contentTarget.innerHTML` would nest a second, independent `qr-code` controller instance inside the first on every single refresh — an ever-deepening DOM and a real duplicate-timer bug, which contradicts "the controller element itself is not replaced" (that sentence only makes sense if the *same* controller instance keeps running indefinitely).

Resolution: the component always attaches a plain (non-Stimulus) `data-expires-at="<iso8601>"` HTML attribute directly on the `<svg>` element whenever `expires_at:` is given (this happens in both the outer wrapper's inner SVG at initial render, and in whatever the `refresh_url:` endpoint renders). The `refresh_url:` endpoint's contract is simply "call `sp_qr_code` again with new `data:`/`expires_at:`" (same helper, no special fragment-only mode) — its response may contain the full wrapper markup, but the controller only ever extracts the first `<svg>` from that response (via a detached `<template>` + `querySelector('svg')`), sets `contentTarget.innerHTML` to that SVG's `outerHTML`, and reads `svg.dataset.expiresAt` to reschedule. The response's own outer wrapper div (if any) is parsed and discarded — never inserted into the live DOM. This keeps exactly one `qr-code` controller instance alive for the lifetime of the element, matches every literal clue in the spec, and needs no client-side QR generation.

---

## Task 1: Add `rqrcode` gem dependency

**Files:**
- Modify: `stimulus-plumbers-rails/stimulus_plumbers.gemspec`

**Interfaces:**
- Consumes: nothing.
- Produces: `rqrcode` gem available to `require "rqrcode"` in Task 2's `qr_code.rb`.

Steps:

- [ ] Add the dependency to `stimulus-plumbers-rails/stimulus_plumbers.gemspec`, after `spec.add_dependency "actionview", ">= 6.1", "< 8.2"`:

```ruby
  spec.add_dependency "actionview", ">= 6.1", "< 8.2"
  spec.add_dependency "rqrcode", "~> 3.0"
```

- [ ] Run `cd stimulus-plumbers-rails && bundle install` — verify it resolves and `Gemfile.lock` picks up `rqrcode` (and its `rqrcode_core`/`chunky_png` dependencies).
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/stimulus_plumbers.gemspec stimulus-plumbers-rails/Gemfile.lock
git commit -m "$(cat <<'EOF'
chore: add rqrcode dependency for the upcoming qr_code component

Reed-Solomon error correction and matrix layout are well-defined, easy-to-get
subtly-wrong algorithms — use a maintained gem instead of hand-rolling one.
EOF
)"
```

---

## Task 2: Static SVG rendering (regression-pinned) + theme keys

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb`

**Interfaces:**
- Consumes: `Plumber::Base#merge_html_options`/`theme.resolve`, `RQRCode::QRCode.new(data, level:).modules` (2D array of booleans, `modules.size` = module count per side).
- Produces: `StimulusPlumbers::Components::QrCode#render(data:, label:, size: 200, expires_at: nil, refresh_url: nil, **html_options)` returning an `ActiveSupport::SafeBuffer` `<svg>` string for the static case. Theme keys `qr_code`, `qr_code_status`. Consumed by Task 3 (validation + refreshable wrapping, same file/method) and Task 5 (helper).

Steps:

- [ ] Add the `QR_CODE` schema block to `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`, after `LAYOUT` and before `TIMELINE`:

```ruby
      QR_CODE = {
        qr_code:        {}.freeze,
        qr_code_status: {}.freeze
      }.freeze
```

- [ ] Add `**Schema::QR_CODE,` to the `SCHEMA` hash in `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb` (after `**Schema::LINK,`):

```ruby
      SCHEMA = {
        **Schema::LIST,
        **Schema::ORDERED_LIST,
        **Schema::AVATAR,
        **Schema::BUTTON,
        **Schema::CALENDAR,
        **Schema::CARD,
        **Schema::COMBOBOX,
        **Schema::FORM,
        **Schema::ICON,
        **Schema::INPUT_GROUP,
        **Schema::LAYOUT,
        **Schema::LINK,
        **Schema::QR_CODE,
        **Schema::TIMELINE
      }.freeze
```

- [ ] Write the failing unit test `stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb`. The fixed input `"SP-QR-TEST"` at error-correction level `:m` deterministically produces a 21x21 module grid with exactly 220 dark modules (verified directly against the `rqrcode` gem before writing this plan) — this pins the regression test:

```ruby
# frozen_string_literal: true

require "test_helper"

class QrCodeComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::QrCode.new(self)
  end

  def test_renders_svg_element
    assert_includes renderer.render(data: "SP-QR-TEST", label: "Test QR code"), "<svg"
  end

  def test_renders_role_img_and_aria_label
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code"))

    assert_css doc, "svg[role='img'][aria-label='Test QR code']"
  end

  def test_dark_module_count_is_pinned_for_known_input
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code"))

    assert_equal 220, doc.css("svg rect").length
  end

  def test_view_box_scales_to_module_count_plus_quiet_zone
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code"))

    # 21 modules + 4-module quiet zone on each side = 29
    assert_equal "0 0 29 29", doc.at_css("svg")["viewBox"]
  end

  def test_first_module_rect_is_offset_by_the_quiet_zone
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code"))

    assert_css doc, "svg rect[x='4'][y='4']"
  end

  def test_default_size_sets_width_and_height
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code"))

    assert_equal "200", doc.at_css("svg")["width"]
    assert_equal "200", doc.at_css("svg")["height"]
  end

  def test_custom_size
    doc = parse_html(renderer.render(data: "SP-QR-TEST", label: "Test QR code", size: 320))

    assert_equal "320", doc.at_css("svg")["width"]
    assert_equal "320", doc.at_css("svg")["height"]
  end

  def test_merges_custom_html_options
    assert_includes renderer.render(data: "SP-QR-TEST", label: "Test QR code", class: "my-qr"), "my-qr"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/components/qr_code_test.rb` — verify it fails (class doesn't exist).
- [ ] Write `stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb` (static-render half only for now — `expires_at:`/`refresh_url:` accepted but not yet validated or wrapped; Task 3 fills that in):

```ruby
# frozen_string_literal: true

require "rqrcode"

module StimulusPlumbers
  module Components
    class QrCode < Plumber::Base
      ERROR_CORRECTION_LEVEL = :m
      QUIET_ZONE_MODULES     = 4

      def render(data:, label:, size: 200, expires_at: nil, refresh_url: nil, **html_options)
        build_svg(data, label: label, size: size, expires_at: expires_at, html_options: html_options)
      end

      private

      def build_svg(data, label:, size:, expires_at:, html_options:)
        qr             = RQRCode::QRCode.new(data, level: ERROR_CORRECTION_LEVEL)
        module_count   = qr.modules.size
        dimension      = module_count + (QUIET_ZONE_MODULES * 2)
        expires_attrs  = expires_at.present? ? { data: { expires_at: normalized_expires_at(expires_at) } } : {}

        svg_attrs = merge_html_options(
          theme.resolve(:qr_code),
          html_options,
          expires_attrs,
          {
            role:    "img",
            aria:    { label: label },
            viewBox: "0 0 #{dimension} #{dimension}",
            width:   size,
            height:  size,
            xmlns:   "http://www.w3.org/2000/svg",
            fill:    "currentColor"
          }
        )

        template.content_tag(:svg, **svg_attrs) do
          template.safe_join(module_rects(qr, offset: QUIET_ZONE_MODULES))
        end
      end

      def module_rects(qr, offset:)
        dark_rects = []
        qr.modules.each_with_index do |row, y|
          row.each_with_index do |dark, x|
            next unless dark

            dark_rects << template.content_tag(:rect, nil, x: x + offset, y: y + offset, width: 1, height: 1)
          end
        end
        dark_rects
      end

      def normalized_expires_at(expires_at)
        expires_at.respond_to?(:iso8601) ? expires_at.iso8601 : expires_at.to_s
      end
    end
  end
end
```

- [ ] Require it in `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, after the popover requires:

```ruby
require_relative "stimulus_plumbers/components/popover/panel"
require_relative "stimulus_plumbers/components/qr_code"
```

- [ ] Run the test again: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/components/qr_code_test.rb` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb
git commit -m "$(cat <<'EOF'
feat: render qr_code as an inline SVG via rqrcode

One <rect> per dark module, fixed level-M error correction and a 4-module
quiet zone; fill inherits currentColor the same way icon.rb's stroke does.
EOF
)"
```

---

## Task 3: `label:`/`expires_at:`+`refresh_url:` validation and the refreshable wrapper

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb`

**Interfaces:**
- Consumes: Task 2's `build_svg`/`normalized_expires_at`.
- Produces: `#render` now raises `ArgumentError` for a missing `label:` or a lone `expires_at:`/`refresh_url:`; when both are present, returns a `<div data-controller="qr-code" data-qr-code-expires-at-value=... data-qr-code-refresh-url-value=...>` wrapping a `content` target div (holding the SVG) and a `status` target `<p aria-live="polite">`. Consumed by Task 4 (JS controller reads `data-qr-code-*-value` + the SVG's `data-expires-at`) and Task 6 (accessibility test).

Steps:

- [ ] Add the failing tests to `stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb` (append inside the existing class, before the final `end`):

```ruby
  def test_missing_label_raises_argument_error
    assert_raises(ArgumentError) { renderer.render(data: "SP-QR-TEST", label: nil) }
  end

  def test_blank_label_raises_argument_error
    assert_raises(ArgumentError) { renderer.render(data: "SP-QR-TEST", label: "") }
  end

  def test_expires_at_without_refresh_url_raises_argument_error
    assert_raises(ArgumentError) do
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current)
    end
  end

  def test_refresh_url_without_expires_at_raises_argument_error
    assert_raises(ArgumentError) do
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", refresh_url: "/refresh")
    end
  end

  def test_refreshable_wraps_svg_in_controller_div
    doc = parse_html(
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current, refresh_url: "/refresh")
    )

    assert_css doc, "div[data-controller='qr-code']"
    assert_css doc, "div[data-controller='qr-code'] svg"
  end

  def test_refreshable_sets_expires_at_and_refresh_url_values
    expires_at = Time.utc(2026, 1, 1, 0, 0, 0)
    doc = parse_html(
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: expires_at, refresh_url: "/refresh")
    )
    wrapper = doc.at_css("div[data-controller='qr-code']")

    assert_equal expires_at.iso8601, wrapper["data-qr-code-expires-at-value"]
    assert_equal "/refresh", wrapper["data-qr-code-refresh-url-value"]
  end

  def test_refreshable_content_target_wraps_the_svg
    doc = parse_html(
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current, refresh_url: "/refresh")
    )

    assert_css doc, "div[data-qr-code-target='content'] svg"
  end

  def test_refreshable_svg_carries_plain_expires_at_data_attribute
    expires_at = Time.utc(2026, 1, 1, 0, 0, 0)
    doc = parse_html(
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: expires_at, refresh_url: "/refresh")
    )

    assert_equal expires_at.iso8601, doc.at_css("svg")["data-expires-at"]
  end

  def test_refreshable_status_target_is_a_live_region
    doc = parse_html(
      renderer.render(data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current, refresh_url: "/refresh")
    )

    assert_css doc, "p[data-qr-code-target='status'][aria-live='polite']"
  end

  def test_refreshable_forwards_html_options_to_outer_wrapper
    doc = parse_html(
      renderer.render(
        data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current, refresh_url: "/refresh", id: "my-qr"
      )
    )

    assert_css doc, "div#my-qr[data-controller='qr-code']"
  end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/components/qr_code_test.rb` — verify the new tests fail (no validation, no wrapper yet).
- [ ] Rewrite `stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb` in full:

```ruby
# frozen_string_literal: true

require "rqrcode"

module StimulusPlumbers
  module Components
    class QrCode < Plumber::Base
      ERROR_CORRECTION_LEVEL = :m
      QUIET_ZONE_MODULES     = 4
      STIMULUS_CONTROLLER    = "qr-code"

      def render(data:, label:, size: 200, expires_at: nil, refresh_url: nil, **html_options)
        validate_options!(label, expires_at, refresh_url)
        refreshable = expires_at.present? && refresh_url.present?

        svg = build_svg(
          data, label: label, size: size, expires_at: expires_at, html_options: refreshable ? {} : html_options
        )
        return svg unless refreshable

        wrap_refreshable(svg, expires_at: expires_at, refresh_url: refresh_url, html_options: html_options)
      end

      private

      def validate_options!(label, expires_at, refresh_url)
        raise ArgumentError, "label: is required — a QR code has no visible text substitute" if label.blank?
        return if expires_at.present? == refresh_url.present?

        raise ArgumentError, "expires_at: and refresh_url: must both be present or both be absent"
      end

      def build_svg(data, label:, size:, expires_at:, html_options:)
        qr             = RQRCode::QRCode.new(data, level: ERROR_CORRECTION_LEVEL)
        module_count   = qr.modules.size
        dimension      = module_count + (QUIET_ZONE_MODULES * 2)
        expires_attrs  = expires_at.present? ? { data: { expires_at: normalized_expires_at(expires_at) } } : {}

        svg_attrs = merge_html_options(
          theme.resolve(:qr_code),
          html_options,
          expires_attrs,
          {
            role:    "img",
            aria:    { label: label },
            viewBox: "0 0 #{dimension} #{dimension}",
            width:   size,
            height:  size,
            xmlns:   "http://www.w3.org/2000/svg",
            fill:    "currentColor"
          }
        )

        template.content_tag(:svg, **svg_attrs) do
          template.safe_join(module_rects(qr, offset: QUIET_ZONE_MODULES))
        end
      end

      def module_rects(qr, offset:)
        dark_rects = []
        qr.modules.each_with_index do |row, y|
          row.each_with_index do |dark, x|
            next unless dark

            dark_rects << template.content_tag(:rect, nil, x: x + offset, y: y + offset, width: 1, height: 1)
          end
        end
        dark_rects
      end

      def wrap_refreshable(svg, expires_at:, refresh_url:, html_options:)
        data = {
          controller:                STIMULUS_CONTROLLER,
          qr_code_expires_at_value:  normalized_expires_at(expires_at),
          qr_code_refresh_url_value: refresh_url
        }
        wrapper_attrs = merge_html_options(html_options, { data: data })

        template.content_tag(:div, **wrapper_attrs) do
          template.safe_join(
            [
              template.content_tag(:div, svg, data: { qr_code_target: "content" }),
              template.content_tag(
                :p, "",
                **merge_html_options(theme.resolve(:qr_code_status), { aria: { live: "polite" }, data: { qr_code_target: "status" } })
              )
            ]
          )
        end
      end

      def normalized_expires_at(expires_at)
        expires_at.respond_to?(:iso8601) ? expires_at.iso8601 : expires_at.to_s
      end
    end
  end
end
```

- [ ] Run the test again: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/components/qr_code_test.rb` — verify all tests pass.
- [ ] Run rubocop: `cd stimulus-plumbers-rails && rake rubocop` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/qr_code.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/qr_code_test.rb
git commit -m "$(cat <<'EOF'
feat: validate qr_code label/expiry options and wrap the refreshable variant

label: is a hard ArgumentError (no visible substitute exists for a QR code).
expires_at:/refresh_url: must be given together. When both are present, the
SVG is wrapped in a qr-code controller div with content/status targets.
EOF
)"
```

---

## Task 4: `sp_qr_code` Rails helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/qr_code_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/helpers/qr_code_helper_test.rb`

**Interfaces:**
- Consumes: `StimulusPlumbers::Components::QrCode#render` (Tasks 2–3).
- Produces: `sp_qr_code(data:, label:, **kwargs)` helper, mixed into `StimulusPlumbers::Helpers`. Consumed by Task 6's sandbox views.

Steps:

- [ ] Write the failing test `stimulus-plumbers-rails/test/stimulus_plumbers/helpers/qr_code_helper_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class QrCodeHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::QrCodeHelper

  def test_renders_svg_element
    assert_includes sp_qr_code(data: "SP-QR-TEST", label: "Test QR code"), "<svg"
  end

  def test_missing_label_raises_argument_error
    assert_raises(ArgumentError) { sp_qr_code(data: "SP-QR-TEST", label: nil) }
  end

  def test_forwards_expires_at_and_refresh_url
    doc = parse_html(
      sp_qr_code(data: "SP-QR-TEST", label: "Test QR code", expires_at: Time.current, refresh_url: "/refresh")
    )

    assert_css doc, "div[data-controller='qr-code']"
  end

  def test_merges_custom_class
    assert_includes sp_qr_code(data: "SP-QR-TEST", label: "Test QR code", class: "my-qr"), "my-qr"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/helpers/qr_code_helper_test.rb` — verify it fails (helper module doesn't exist).
- [ ] Create `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/qr_code_helper.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module QrCodeHelper
      def sp_qr_code(data:, label:, **kwargs)
        Components::QrCode.new(self).render(data: data, label: label, **kwargs)
      end
    end
  end
end
```

- [ ] Wire it into `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb` — add `require_relative "helpers/qr_code_helper"` (after `require_relative "helpers/popover_helper"`) and `include QrCodeHelper` (after `include PopoverHelper`):

```ruby
require_relative "helpers/popover_helper"
require_relative "helpers/qr_code_helper"
require_relative "helpers/timeline_helper"

module StimulusPlumbers
  module Helpers
    include PlumberHelper
    include IconHelper
    include ListHelper
    include OrderedListHelper
    include AvatarHelper
    include ButtonHelper
    include CalendarHelper
    include CalendarTurboHelper
    include CardHelper
    include ComboboxHelper
    include DividerHelper
    include LinkHelper
    include PopoverHelper
    include QrCodeHelper
    include TimelineHelper
  end
end
```

- [ ] Run the test again: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/stimulus_plumbers/helpers/qr_code_helper_test.rb` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/qr_code_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/helpers/qr_code_helper_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_qr_code Rails helper
EOF
)"
```

---

## Task 5: `qr-code` Stimulus controller — timer scheduling + `disconnect`

**Files:**
- Create: `stimulus-plumbers/src/controllers/qr_code_controller.js`
- Modify: `stimulus-plumbers/src/index.js`
- Modify: `stimulus-plumbers/README.md`
- Test: `stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js`

**Interfaces:**
- Consumes: `Requestor` (`stimulus-plumbers/src/requestor.js`) — already used by `combobox_dropdown_controller.js` for `.schedule(fn, delay)`/`.cancel()`.
- Produces: default-exported `QrCodeController` with `static targets = ['content', 'status']`, `static values = { expiresAt: String, refreshUrl: String, refreshing: { type: Boolean, default: false } }`, methods `connect()`, `disconnect()`, `scheduleExpiry()`. Consumed by Task 6 (`refresh()`/`applyRefresh()` added on top of this file) and Task 7 (accessibility test drives it via a real browser).

Steps:

- [ ] Write the failing test file `stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js` (timer-scheduling and disconnect cases only — refresh cases are added in Task 6):

```js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import QrCodeController from '../../../src/controllers/qr_code_controller'

describe('QrCodeController', () => {
  let application

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="qr-code"]'),
      'qr-code'
    )

  beforeEach(() => {
    application = Application.start()
    application.register('qr-code', QrCodeController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
    vi.restoreAllMocks()
  })

  describe('scheduleExpiry on connect', () => {
    beforeEach(async () => {
      vi.useFakeTimers({ toFake: ['Date'] })
      vi.setSystemTime(new Date('2026-01-01T00:00:00.000Z'))
      document.body.innerHTML = `
        <div data-controller="qr-code"
             data-qr-code-expires-at-value="2026-01-01T00:00:05.000Z"
             data-qr-code-refresh-url-value="/refresh">
          <div data-qr-code-target="content"><svg></svg></div>
          <p data-qr-code-target="status" aria-live="polite"></p>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))

      const ctrl = getController()
      ctrl.disconnect() // cancels the real timer connect() just scheduled via the real Requestor
      ctrl._requestor = { schedule: vi.fn(), request: vi.fn(), cancel: vi.fn() }
      ctrl.scheduleExpiry()
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('schedules the timer for the exact remaining delay', () => {
      expect(getController()._requestor.schedule).toHaveBeenCalledWith(expect.any(Function), 5000)
    })
  })

  describe('scheduleExpiry when expiresAt is already past', () => {
    beforeEach(async () => {
      vi.useFakeTimers({ toFake: ['Date'] })
      // Connect with a far-future expiresAt so connect()'s own real-Requestor schedule() call
      // gets a harmless multi-decade delay that can never fire during the test run. The
      // "already past" value is set explicitly below, right before the call under test.
      vi.setSystemTime(new Date('2026-01-01T00:00:05.000Z'))
      document.body.innerHTML = `
        <div data-controller="qr-code"
             data-qr-code-expires-at-value="2099-01-01T00:00:00.000Z"
             data-qr-code-refresh-url-value="/refresh">
          <div data-qr-code-target="content"><svg></svg></div>
          <p data-qr-code-target="status" aria-live="polite"></p>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))

      const ctrl = getController()
      ctrl.disconnect() // cancels the real timer connect() just scheduled via the real Requestor
      ctrl._requestor = { schedule: vi.fn(), request: vi.fn(), cancel: vi.fn() }
      ctrl.expiresAtValue = '2026-01-01T00:00:00.000Z' // 5s before the faked "now"
      ctrl.scheduleExpiry()
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('schedules the timer with a delay clamped to 0 (fires immediately)', () => {
      expect(getController()._requestor.schedule).toHaveBeenCalledWith(expect.any(Function), 0)
    })
  })

  describe('disconnect', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="qr-code"
             data-qr-code-expires-at-value="2099-01-01T00:00:00.000Z"
             data-qr-code-refresh-url-value="/refresh">
          <div data-qr-code-target="content"><svg></svg></div>
          <p data-qr-code-target="status" aria-live="polite"></p>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('cancels the pending requestor timer', () => {
      const ctrl = getController()
      const cancelSpy = vi.spyOn(ctrl._requestor, 'cancel')
      ctrl.disconnect()
      expect(cancelSpy).toHaveBeenCalledOnce()
    })
  })
})
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- qr_code_controller` — verify it fails (module doesn't exist).
- [ ] Write `stimulus-plumbers/src/controllers/qr_code_controller.js`:

```js
import { Controller } from '@hotwired/stimulus';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['content', 'status'];
  static values = {
    expiresAt: String,
    refreshUrl: String,
    refreshing: { type: Boolean, default: false },
  };

  initialize() {
    this._requestor = new Requestor();
  }

  connect() {
    this.scheduleExpiry();
  }

  disconnect() {
    this._requestor.cancel();
  }

  scheduleExpiry() {
    const delay = Math.max(0, new Date(this.expiresAtValue).getTime() - Date.now());
    this._requestor.schedule(() => this.expired(), delay);
  }

  expired() {
    this.dispatch('expired');
  }
}
```

- [ ] Run the test again: `cd stimulus-plumbers && npm test -- qr_code_controller` — verify it passes.
- [ ] Export it from `stimulus-plumbers/src/index.js`, alphabetically between `PopoverController` and `ReorderableController`:

```js
export { default as PopoverController } from './controllers/popover_controller.js';
export { default as QrCodeController } from './controllers/qr_code_controller.js';
export { default as ReorderableController } from './controllers/reorderable_controller.js';
```

- [ ] Add `QrCodeController` to the Setup snippet and Controllers table in `stimulus-plumbers/README.md`. In the import list (after `PopoverController,`):

```javascript
  PopoverController,
  QrCodeController,
  ReorderableController,
```

  In the `application.register(...)` list (after the `popover` line):

```javascript
application.register('popover',                  PopoverController)
application.register('qr-code',                  QrCodeController)
application.register('reorderable',              ReorderableController)
```

  In the Controllers table (after the `popover` row):

```markdown
| `qr-code` | Schedules an expiry timer and swaps in a refreshed QR code fragment | [docs/component/qr-code.md](docs/component/qr-code.md) |
```

- [ ] Run `cd stimulus-plumbers && npm run lint` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/controllers/qr_code_controller.js \
        stimulus-plumbers/src/index.js \
        stimulus-plumbers/README.md \
        stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js
git commit -m "$(cat <<'EOF'
feat: add qr-code controller — expiry timer scheduling

Schedules a single setTimeout (via the existing Requestor utility) from
expiresAtValue on connect; an already-past deadline clamps to a 0ms delay
so it fires on the next tick. disconnect() cancels the pending timer.
EOF
)"
```

---

## Task 6: `qr-code` controller — `refresh()` (fetch success/failure, no retry)

**Files:**
- Modify: `stimulus-plumbers/src/controllers/qr_code_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js`

**Interfaces:**
- Consumes: Task 5's `scheduleExpiry()`/`this._requestor`.
- Produces: `refresh()` (fetches `refreshUrlValue`, on success swaps `contentTarget.innerHTML` with the extracted `<svg>`'s `outerHTML`, sets `statusTarget.textContent`, dispatches `qr-code:refreshed`, reschedules via the new SVG's `data-expires-at`; on failure dispatches `qr-code:refresh-failed` and does not retry), wired to fire from `expired()`. Consumed by Task 7 (accessibility test exercises this against a real endpoint).

Steps:

- [ ] Add the failing tests to `stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js` (append inside the top-level `describe`, before the closing `})`):

```js
  describe('refresh', () => {
    const flushPromises = () => new Promise((r) => setTimeout(r, 0))
    let mockRequestor

    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="qr-code"
             data-qr-code-expires-at-value="2099-01-01T00:00:00.000Z"
             data-qr-code-refresh-url-value="/refresh">
          <div data-qr-code-target="content"><svg><rect x="1" y="1" width="1" height="1"></rect></svg></div>
          <p data-qr-code-target="status" aria-live="polite"></p>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))

      // expiresAt is decades out so connect()'s own real-Requestor schedule() call never
      // fires during the test run; only the manual getController().refresh() call below exercises the mock.
      mockRequestor = { schedule: vi.fn(), request: vi.fn(), cancel: vi.fn() }
      getController()._requestor = mockRequestor
    })

    it('sets refreshingValue to true while the fetch is in flight', () => {
      mockRequestor.request.mockReturnValue(new Promise(() => {}))
      getController().refresh()
      expect(getController().refreshingValue).toBe(true)
    })

    it('replaces the content target with the new svg on success', async () => {
      const html =
        '<div data-controller="qr-code"><div data-qr-code-target="content">' +
        '<svg data-expires-at="2026-01-01T01:00:00.000Z"><rect x="2" y="2" width="1" height="1"></rect></svg>' +
        '</div><p data-qr-code-target="status"></p></div>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })

      getController().refresh()
      await flushPromises()

      const svg = document.querySelector('[data-qr-code-target="content"] svg')
      expect(svg.getAttribute('data-expires-at')).toBe('2026-01-01T01:00:00.000Z')
      expect(svg.querySelector('rect').getAttribute('x')).toBe('2')
    })

    it('does not insert a nested qr-code controller from the response wrapper', async () => {
      const html =
        '<div data-controller="qr-code"><div data-qr-code-target="content">' +
        '<svg data-expires-at="2026-01-01T01:00:00.000Z"></svg>' +
        '</div><p data-qr-code-target="status"></p></div>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })

      getController().refresh()
      await flushPromises()

      expect(document.querySelectorAll('[data-controller="qr-code"]')).toHaveLength(1)
    })

    it('updates the status target text on success', async () => {
      const html = '<svg data-expires-at="2026-01-01T01:00:00.000Z"></svg>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })

      getController().refresh()
      await flushPromises()

      expect(document.querySelector('[data-qr-code-target="status"]').textContent).toBe('QR code refreshed')
    })

    it('reschedules the timer from the new svg data-expires-at attribute', async () => {
      const html = '<svg data-expires-at="2026-01-01T01:00:00.000Z"></svg>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })

      getController().refresh()
      await flushPromises()

      expect(getController().expiresAtValue).toBe('2026-01-01T01:00:00.000Z')
      expect(mockRequestor.schedule).toHaveBeenCalled()
    })

    it('dispatches qr-code:refreshed on success', async () => {
      const html = '<svg data-expires-at="2026-01-01T01:00:00.000Z"></svg>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })
      const handler = vi.fn()
      document.querySelector('[data-controller="qr-code"]').addEventListener('qr-code:refreshed', handler)

      getController().refresh()
      await flushPromises()

      expect(handler).toHaveBeenCalledOnce()
    })

    it('sets refreshingValue back to false after success', async () => {
      const html = '<svg data-expires-at="2026-01-01T01:00:00.000Z"></svg>'
      mockRequestor.request.mockResolvedValue({ text: async () => html })

      getController().refresh()
      await flushPromises()

      expect(getController().refreshingValue).toBe(false)
    })

    it('dispatches qr-code:refresh-failed on fetch failure', async () => {
      mockRequestor.request.mockRejectedValue(new Error('network failure'))
      const handler = vi.fn()
      document.querySelector('[data-controller="qr-code"]').addEventListener('qr-code:refresh-failed', handler)

      getController().refresh()
      await flushPromises()

      expect(handler).toHaveBeenCalledOnce()
    })

    it('sets refreshingValue back to false after a fetch failure', async () => {
      mockRequestor.request.mockRejectedValue(new Error('network failure'))

      getController().refresh()
      await flushPromises()

      expect(getController().refreshingValue).toBe(false)
    })

    it('does not retry after a fetch failure', async () => {
      mockRequestor.request.mockRejectedValue(new Error('network failure'))

      getController().refresh()
      await flushPromises()

      expect(mockRequestor.request).toHaveBeenCalledTimes(1)
    })

    it('does not update the content target on fetch failure', async () => {
      mockRequestor.request.mockRejectedValue(new Error('network failure'))
      const before = document.querySelector('[data-qr-code-target="content"]').innerHTML

      getController().refresh()
      await flushPromises()

      expect(document.querySelector('[data-qr-code-target="content"]').innerHTML).toBe(before)
    })
  })

  describe('expired', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div data-controller="qr-code"
             data-qr-code-expires-at-value="2099-01-01T00:00:00.000Z"
             data-qr-code-refresh-url-value="/refresh">
          <div data-qr-code-target="content"><svg></svg></div>
          <p data-qr-code-target="status" aria-live="polite"></p>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
      // expiresAt is decades out so connect()'s own real-Requestor schedule() call never fires
      // during the test run; only the manual ctrl.expired() call below exercises the behavior.
    })

    it('dispatches qr-code:expired then calls refresh', () => {
      const ctrl = getController()
      const handler = vi.fn()
      document.querySelector('[data-controller="qr-code"]').addEventListener('qr-code:expired', handler)
      const refreshSpy = vi.spyOn(ctrl, 'refresh').mockImplementation(() => {})

      ctrl.expired()

      expect(handler).toHaveBeenCalledOnce()
      expect(refreshSpy).toHaveBeenCalledOnce()
    })
  })
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- qr_code_controller` — verify the new tests fail (`refresh`/`applyRefresh` don't exist yet, `expired()` doesn't call `refresh()`).
- [ ] Rewrite `stimulus-plumbers/src/controllers/qr_code_controller.js` in full:

```js
import { Controller } from '@hotwired/stimulus';
import { Requestor } from '../requestor';

export default class extends Controller {
  static targets = ['content', 'status'];
  static values = {
    expiresAt: String,
    refreshUrl: String,
    refreshing: { type: Boolean, default: false },
  };

  initialize() {
    this._requestor = new Requestor();
  }

  connect() {
    this.scheduleExpiry();
  }

  disconnect() {
    this._requestor.cancel();
  }

  scheduleExpiry() {
    const delay = Math.max(0, new Date(this.expiresAtValue).getTime() - Date.now());
    this._requestor.schedule(() => this.expired(), delay);
  }

  expired() {
    this.dispatch('expired');
    this.refresh();
  }

  refresh() {
    this.refreshingValue = true;
    this._requestor
      .request(this.refreshUrlValue)
      .then((res) => res.text())
      .then((html) => this.applyRefresh(html))
      .catch(() => {
        this.dispatch('refresh-failed');
      })
      .finally(() => {
        this.refreshingValue = false;
      });
  }

  applyRefresh(html) {
    const wrapper = document.createElement('template');
    wrapper.innerHTML = html.trim();
    const svg = wrapper.content.querySelector('svg');
    if (!svg) return;

    this.contentTarget.innerHTML = svg.outerHTML;
    if (this.hasStatusTarget) this.statusTarget.textContent = 'QR code refreshed';
    if (svg.dataset.expiresAt) {
      this.expiresAtValue = svg.dataset.expiresAt;
      this.scheduleExpiry();
    }
    this.dispatch('refreshed');
  }
}
```

- [ ] Run the test again: `cd stimulus-plumbers && npm test -- qr_code_controller` — verify all tests pass.
- [ ] Run `cd stimulus-plumbers && npm run lint && npm run format:check` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/controllers/qr_code_controller.js \
        stimulus-plumbers/tests/unit/controllers/qr_code_controller.test.js
git commit -m "$(cat <<'EOF'
feat: add qr-code controller refresh — fetch, swap, reschedule

On expiry, fetches refreshUrlValue, extracts the response's <svg> into a
detached template (discarding any wrapper the endpoint's sp_qr_code render
produced, so a second qr-code controller is never nested into the DOM),
swaps it into the content target, updates the status live region, and
reschedules the timer from the new svg's data-expires-at. Fetch failures
dispatch qr-code:refresh-failed with no automatic retry.
EOF
)"
```

---

## Task 7: Sandbox wiring + Rails accessibility tests

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`
- Modify: `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code.html.erb`
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code_refresh.html.erb`
- Create: `stimulus-plumbers-rails/test/accessibility/components/qr_code_accessibility_test.rb`

**Interfaces:**
- Consumes: `sp_qr_code` (Task 4), the JS `qr-code` controller bundle (Tasks 5–6) as loaded by the sandbox's asset pipeline (same mechanism every other `*_accessibility_test.rb` already relies on).
- Produces: `/components/display/qr_code` (static + refreshable demo) and `/components/display/qr_code_refresh` (fragment endpoint) sandbox routes; `QrCodeAccessibilityTest` asserting no axe violations for both variants and asserting the `status` live region's text after a real expire→refresh cycle.

Steps:

- [ ] Add two routes to `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`, after `get :timeline`:

```ruby
scope "/display", controller: "components" do
  get :list
  get :ordered_list
  get :avatar
  get :icon
  get :timeline
  get :qr_code
  get :qr_code_refresh
end
```

- [ ] Add two actions to `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`, after `def timeline; end`:

```ruby
  def qr_code
    @expires_at = 2.seconds.from_now
  end

  def qr_code_refresh
    render layout: false
  end
```

- [ ] Create `stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code.html.erb`:

```erb
<h1>QR code components</h1>

<div id="qr-code-static">
  <%= sp_qr_code(data: "https://example.com", label: "Example QR code") %>
</div>

<div id="qr-code-refreshable">
  <%= sp_qr_code(
    data: "https://example.com/session",
    label: "Session QR code",
    expires_at: @expires_at,
    refresh_url: qr_code_refresh_path
  ) %>
</div>
```

- [ ] Create `stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code_refresh.html.erb` — the endpoint just re-renders `sp_qr_code` with new data and a further-out expiry, matching the "app's only obligation" contract from the design spec:

```erb
<%= sp_qr_code(
  data: "https://example.com/session-refreshed",
  label: "Session QR code",
  expires_at: 1.hour.from_now,
  refresh_url: qr_code_refresh_path
) %>
```

- [ ] Write the failing accessibility test `stimulus-plumbers-rails/test/accessibility/components/qr_code_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class QrCodeAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/qr_code"
  end

  def test_static_variant_passes_wcag
    assert_accessible context: "#qr-code-static"
  end

  def test_refreshable_variant_passes_wcag_before_expiry
    assert_accessible context: "#qr-code-refreshable"
  end

  def test_status_live_region_announces_refresh_after_expiry
    assert_equal "", find("#qr-code-refreshable [data-qr-code-target='status']", visible: :all).text(:all)

    assert_selector(
      "#qr-code-refreshable [data-qr-code-target='status']", text: "QR code refreshed", visible: :all, wait: 5
    )
  end

  def test_refreshable_variant_passes_wcag_after_refresh
    assert_selector(
      "#qr-code-refreshable [data-qr-code-target='status']", text: "QR code refreshed", visible: :all, wait: 5
    )

    assert_accessible context: "#qr-code-refreshable"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bundle exec ruby -Itest -Ilib test/accessibility/components/qr_code_accessibility_test.rb` — verify it fails first (route/view/controller don't exist yet), then re-run once the sandbox files above are in place and confirm all four pass with no axe violations and the live-region text changes within the 5s wait.
- [ ] Run rubocop: `cd stimulus-plumbers-rails && rake rubocop` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/test/sandbox/config/routes/display.rb \
        stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb \
        stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code.html.erb \
        stimulus-plumbers-rails/test/sandbox/app/views/components/qr_code_refresh.html.erb \
        stimulus-plumbers-rails/test/accessibility/components/qr_code_accessibility_test.rb
git commit -m "$(cat <<'EOF'
test: add qr_code accessibility coverage for static and refreshable variants

Refreshable sandbox demo expires after 2s and refreshes against a real
endpoint, exercising the full expire -> fetch -> swap -> announce cycle in
a real browser (Cuprite), not just mocked JS unit tests.
EOF
)"
```

---

## Task 8: Docs — Rails component doc, JS component doc, both READMEs, ARIA.md

**Files:**
- Create: `stimulus-plumbers-rails/docs/component/qr_code.md`
- Create: `stimulus-plumbers/docs/component/qr-code.md`
- Modify: `stimulus-plumbers-rails/README.md`
- Modify: `ARIA.md`

**Interfaces:**
- Consumes: the finished component/controller from Tasks 2–6 (documents their actual, verified behavior — no aspirational API).
- Produces: no code interfaces — documentation only.

Steps:

- [ ] Create `stimulus-plumbers-rails/docs/component/qr_code.md`:

```markdown
# QR Code

Rails helper for rendering an inline SVG QR code via the `rqrcode` gem, either static or with a client-side expiry/refresh cycle. See [stimulus-plumbers's docs/component/qr-code.md](../../../stimulus-plumbers/docs/component/qr-code.md) for the `qr-code` controller's Values/Targets/Dispatches.

## Helper

### `sp_qr_code`

```erb
<%# Static — no JS at all %>
<%= sp_qr_code(data: "https://example.com", label: "Example QR code") %>

<%# Refreshable — wraps the SVG with the qr-code controller %>
<%= sp_qr_code(
  data: session_qr_data,
  label: "Session QR code",
  expires_at: session_qr_expires_at,
  refresh_url: session_qr_refresh_path
) %>
```

| Option           | Default    | Description                                                                                     |
| ---------------- | ---------- | ------------------------------------------------------------------------------------------------- |
| `data:`          | (required) | String to encode                                                                                 |
| `label:`         | (required) | `aria-label` — raises `ArgumentError` if missing. Unlike Indicator's legend, this is a hard error: a QR code has no possible visible text substitute |
| `size:`          | `200`      | Rendered `width`/`height` in px; `viewBox` scales to the module count                            |
| `expires_at:`    | `nil`      | When present with `refresh_url:`, renders the refreshable variant                                |
| `refresh_url:`   | `nil`      | Endpoint returning a fresh `sp_qr_code` fragment; required together with `expires_at:`, raises `ArgumentError` if only one of the pair is given |
| `**html_options` | —          | Forwarded to the outer element (the `<svg>` when static, the wrapper `<div>` when refreshable)   |

Error-correction level (fixed at `M`), module size, and quiet-zone margin (fixed at the QR spec's 4-module minimum) are not configurable in v1.

### Refresh endpoint contract

`refresh_url:` is entirely your own endpoint. Its only obligation is to render `sp_qr_code` again with new `data:`/`expires_at:` (same `refresh_url:`). The controller extracts the response's `<svg>` element itself — it does not care what else the response contains, so returning the endpoint's normal `sp_qr_code` output (which includes an outer wrapper div) is fine.

---

## Rendered HTML Structure

### Static

```html
<svg role="img" aria-label="Example QR code" viewBox="0 0 29 29" width="200" height="200" fill="currentColor">
  <rect x="4" y="4" width="1" height="1" />
  <!-- one rect per dark module -->
</svg>
```

### Refreshable

```html
<div data-controller="qr-code"
     data-qr-code-expires-at-value="2026-07-08T12:00:00Z"
     data-qr-code-refresh-url-value="/session/qr/refresh">
  <div data-qr-code-target="content">
    <svg role="img" aria-label="Session QR code" data-expires-at="2026-07-08T12:00:00Z" ...>
      <!-- module rects -->
    </svg>
  </div>
  <p data-qr-code-target="status" aria-live="polite"></p>
</div>
```

---

## ARIA

- The `<svg>` always carries `role="img"` and `aria-label`, sourced from `label:`.
- The refreshable variant's `status` `<p aria-live="polite">` is announced by assistive tech on every refresh — see [ARIA.md's QR Code pattern](../../../ARIA.md) for why the visual swap alone isn't sufficient (WCAG 4.1.3).
```

- [ ] Create `stimulus-plumbers/docs/component/qr-code.md`:

```markdown
# QR Code

Schedules an expiry timer from a server-supplied deadline and fetches a replacement fragment when it fires — no client-side QR generation ever happens. Paired with the Rails `sp_qr_code` helper's refreshable variant (see [stimulus-plumbers-rails's docs/component/qr_code.md](../../../stimulus-plumbers-rails/docs/component/qr_code.md)).

## Stimulus Identifier

`qr-code`

## Targets

| Name      | Element                                          | Purpose                                                                                     |
| --------- | ------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `content` | `<div>` wrapping the `<svg>`                      | Its `innerHTML` is replaced with the freshly-fetched `<svg>` on every refresh                |
| `status`  | Visually-hidden `<p aria-live="polite">`          | Text set to `"QR code refreshed"` after a successful refresh, so screen reader users perceive the swap (WCAG 4.1.3) |

## Values

| Name          | Type    | Purpose                                                                                       |
| ------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `expiresAt`   | String  | ISO 8601 deadline; `scheduleExpiry()` computes `expiresAt - now` on `connect()` (clamped to `>= 0`) to schedule a single timer — no polling |
| `refreshUrl`  | String  | Endpoint to fetch the replacement fragment from                                              |
| `refreshing`  | Boolean | Reflected as `data-qr-code-refreshing-value` while a refresh fetch is in flight — style off of this for a dimmed/spinner overlay |

## Methods / Lifecycle

- `connect()` — calls `scheduleExpiry()`
- `disconnect()` — cancels the pending timer via the shared `Requestor` utility ([docs/utility/requestor.md](../utility/requestor.md))
- `scheduleExpiry()` — schedules `expired()` to fire after `expiresAtValue - Date.now()` ms, clamped to `0` (an already-past deadline fires on the next tick)
- `expired()` — dispatches `qr-code:expired`, then calls `refresh()`
- `refresh()` — sets `refreshingValue = true`, fetches `refreshUrlValue`; on success calls `applyRefresh(html)`; on failure dispatches `qr-code:refresh-failed` (**no automatic retry** — avoids an unbounded retry loop against a persistently failing endpoint; listen for the event to offer your own retry affordance); either way, sets `refreshingValue = false`
- `applyRefresh(html)` — parses the response into a detached `<template>`, extracts its first `<svg>` (discarding anything else the response contains, including a nested `data-controller="qr-code"` wrapper if `refresh_url:` simply re-rendered `sp_qr_code`), sets `contentTarget.innerHTML` to that SVG's `outerHTML`, sets the `status` target's text, reschedules the timer by reading the new SVG's plain `data-expires-at` attribute into `expiresAtValue`, then dispatches `qr-code:refreshed`

## Dispatches

| Event                     | When                                                          |
| --------------------------- | ---------------------------------------------------------------- |
| `qr-code:expired`         | The scheduled timer fires, before the refresh fetch starts    |
| `qr-code:refreshed`       | The content swap completes successfully                       |
| `qr-code:refresh-failed`  | The refresh fetch fails (network error or non-2xx response)   |

## Notes

- Persistence/generation of the new QR data is entirely the app's responsibility — same precedent as `reorderable`, which dispatches an event and leaves persistence to the app.
- Server push (Turbo Stream/ActionCable) for expiry not tied to a fixed TTL is out of scope — the client timer covers the fixed-TTL use case; a push-based variant would be a future extension.
```

- [ ] Add a Components table row to `stimulus-plumbers-rails/README.md`, after the `Popover` row:

```markdown
| QR Code | `sp_qr_code` | [docs/component/qr_code.md](docs/component/qr_code.md) |
```

- [ ] Add a `#### QR Code (`qr_code_controller`)` subsection to `ARIA.md`'s "Component-Specific Patterns (APG)" section, after the `#### Reorderable` subsection:

```markdown
#### QR Code (`qr_code_controller`)
- Static variant: `<svg role="img" aria-label="...">` — no additional ARIA needed, the label is the accessible name
- Refreshable variant: a visually-hidden `status` `<p aria-live="polite">` sibling announces `"QR code refreshed"` on every refresh (WCAG 4.1.3) — the visual SVG swap alone would not be perceived by screen reader users
- No focus movement on refresh — the swap is out-of-band background behavior, not a user-initiated action that should steal focus
```

- [ ] Run `cd stimulus-plumbers && npm run format:docs:check` from the repo root — verify clean (fix formatting with `npm run format:docs` if not).
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/docs/component/qr_code.md \
        stimulus-plumbers/docs/component/qr-code.md \
        stimulus-plumbers-rails/README.md \
        ARIA.md
git commit -m "$(cat <<'EOF'
docs: document sp_qr_code helper and qr-code controller

Rails doc covers helper options/HTML structure/refresh contract; JS doc
covers controller values/targets/methods/dispatches. Rails doc links to
the JS doc instead of repeating it, per the no-cross-doc-duplication rule.
EOF
)"
```

---

## Final verification

- [ ] `cd stimulus-plumbers-rails && rake test:unit && rake test:accessibility && rake rubocop` — all clean.
- [ ] `cd stimulus-plumbers && npm test && npm run lint && npm run format:check` — all clean.
- [ ] `npm run format:docs:check` (from repo root) — clean.

## Self-Review

### 1. Spec coverage

- Gem dependency (`rqrcode`) → Task 1.
- SVG rendering, quiet zone, `currentColor` fill via `theme.resolve(:qr_code)` → Task 2.
- `label:` hard-required `ArgumentError`; `expires_at:`/`refresh_url:` must be given together → Task 3.
- `sp_qr_code(data:, label:, size:, expires_at:, refresh_url:, **html_options)` helper → Task 4.
- Controller values (`expiresAt`/`refreshUrl`/`refreshing`), `connect()` timer scheduling incl. already-past case, `disconnect()` clearing the timer → Task 5.
- `refresh()` fetch-and-swap, `status` live region update, `qr-code:refreshed`/`qr-code:refresh-failed` dispatch, no automatic retry → Task 6.
- Accessibility: static sandbox + refreshable expired→refreshed transition asserting live-region text change → Task 7.
- Docs (both component docs, no cross-doc duplication, both README rows, ARIA.md) → Task 8.
- Regression-pinned known-input test (module count/pattern) → Task 2, verified directly against the installed `rqrcode` gem before writing the test (see "Resolved design ambiguity" note above Task 4 for the one spec ambiguity found and how it was resolved).

No gaps found beyond the one documented ambiguity (refresh fragment shape), which is called out explicitly rather than silently guessed at.

### 2. Placeholder scan

Every step contains complete, runnable code (full method bodies, full test assertions, exact commands with expected output). No `TBD`, no "add appropriate error handling," no "similar to Task N" without the code repeated in place.

### 3. Type consistency

- `sp_qr_code(data:, label:, size: 200, expires_at: nil, refresh_url: nil, **html_options)` — signature is identical everywhere it's called (Tasks 2-4, 7, 8 doc examples).
- `expiresAtValue`/`refreshUrlValue`/`refreshingValue` (Stimulus value casing) used consistently across Tasks 5-6 and the JS doc in Task 8.
- `qr-code:expired` / `qr-code:refreshed` / `qr-code:refresh-failed` dispatch names match between controller code (Tasks 5-6), their tests, and the doc (Task 8).
- Target names `content`/`status` match between the Rails-rendered markup (Task 3), the controller (Tasks 5-6), and the doc.

### Bugs caught and fixed during this review

Three JS controller test blocks (Tasks 5-6) initially let `connect()`'s real, unmocked timer scheduling race against later mock/timer setup — risking a dangling real timeout or an unmocked `fetch()` firing mid-suite. Fixed by using far-future `expiresAt` fixtures (or an explicit `ctrl.disconnect()` before swapping in mocks) so the real auto-scheduled timer can never fire during the test run.
