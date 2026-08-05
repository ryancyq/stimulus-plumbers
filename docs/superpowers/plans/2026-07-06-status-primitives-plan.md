# Status Primitives (Progress, Indicator, Checklist) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `progress` Stimulus controller + `progress_bar`/`progress_ring`/`meter` Rails components, extract a new `indicator` presentational component from the existing `timeline_item_indicator*` code (refactoring `timeline` to consume it), and extend the existing `list_item` component/controller with a `checked:` checklist state.

**Architecture:** Three independent additions sharing existing conventions: (1) `progress_controller.js` is a value-driven Stimulus controller (mirrors `input_formatter_controller.js`'s event-adapter/value-callback shape) paired with three thin Rails renderers (`ProgressBar`, `ProgressRing`, `Meter` < `Plumber::Base`) that emit its data-attributes; (2) `Indicator` is a new presentational `Plumber::Base` component (no controller) that `Timeline::Event` delegates to internally, with no change to `Timeline`'s public API; (3) a new `list-item` Stimulus controller plus a `checked:`/`interactive:` render-option extension to the existing `StimulusPlumbers::Components::List::Item`.

**Tech Stack:** Stimulus (`@hotwired/stimulus`), Vitest (JS unit tests), Rails `Plumber::Base`/`Plumber::Slots` component pattern, Minitest (Ruby unit tests), Capybara + axe-core (accessibility tests), Nokogiri (`parse_html`/`assert_css` helpers).

## Global Constraints

- Follow WCAG 2.1 Level AA (see `ARIA.md`).
- **Doc Update Rule** (root `CLAUDE.md`): when changing component API, update `docs/component/*.md` and any `CLAUDE.md` sections referencing it in the same change. No cross-doc duplication — JS controller API lives only in `stimulus-plumbers/docs/component/<name>.md`; Rails helper options live only in `stimulus-plumbers-rails/docs/component/<name>.md`; other docs link, they don't repeat.
- When adding a new exported controller/utility to `stimulus-plumbers/src/index.js`, add a row to the Controllers/Utilities table in `stimulus-plumbers/README.md` and create `docs/component/<name>.md` in the same commit.
- When adding a new Rails helper (`sp_*`), add a row to the Components table in `stimulus-plumbers-rails/README.md` and create `docs/component/<name>.md` in the same commit.
- Export name in `src/index.js` must match the name used in the README setup snippet and Controllers table.
- Component unit tests assert HTML structure and ARIA — not CSS classes (those belong in `stimulus-plumbers-tailwind`).
- Never use `I18n.t(...)` in tests — assert literal English strings.
- Sandbox icon names must be generic (`check`, `square`), never heroicon-specific compound names.
- Tailwind theme class values for all new keys introduced here are explicitly **out of scope** — components render via `Base` theme's no-op defaults only.
- JS: run `npm test`, `npm run lint`, `npm run format:check` synchronously from `stimulus-plumbers/`, never backgrounded.
- Rails: run `rake test:unit`, `rake test:accessibility`, `rake rubocop` synchronously from `stimulus-plumbers-rails/`, never backgrounded.
---

## Part 1: Progress controller + Rails components

### Task 1: `progress` controller — bar variant

**Files:**
- Create: `stimulus-plumbers/src/controllers/progress_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/progress_controller.test.js`

**Interfaces:**
- Consumes: nothing (new controller).
- Produces: `ProgressController` default export with `static values = { variant, value, min, max, optimum, low, high, indeterminate }`, `static targets = ['fill', 'meter']`, method `setValue(value)`, value callback `valueValueChanged(value)`, dispatches `progress:changed` with `{ value, min, max }`. These are consumed by Tasks 2–3 (ring/meter variants) and Task 5 (Rails `ProgressBar` renderer emits these data-attributes).

Steps:

- [ ] Write the failing test file (bar variant only for now):

```js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ProgressController from '../../../src/controllers/progress_controller'

describe('ProgressController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('progress', ProgressController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="progress"]'),
      'progress'
    )

  describe('bar variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress"
             data-progress-value-value="30" data-progress-min-value="0" data-progress-max-value="100">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('sets aria-valuenow/valuemin/valuemax on connect', () => {
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.getAttribute('aria-valuenow')).toBe('30')
      expect(el.getAttribute('aria-valuemin')).toBe('0')
      expect(el.getAttribute('aria-valuemax')).toBe('100')
    })

    it('sets the fill target width to match the percent', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      expect(fill.style.width).toBe('30%')
    })

    it('setValue(value) clamps to max and updates the fill', () => {
      getController().setValue(150)
      const el = document.querySelector('[data-controller="progress"]')
      const fill = document.querySelector('[data-progress-target="fill"]')
      expect(el.getAttribute('aria-valuenow')).toBe('100')
      expect(fill.style.width).toBe('100%')
    })

    it('setValue(value) clamps to min', () => {
      getController().setValue(-20)
      expect(document.querySelector('[data-controller="progress"]').getAttribute('aria-valuenow')).toBe('0')
    })

    it('setValue(value) dispatches progress:changed with { value, min, max }', () => {
      const el = document.querySelector('[data-controller="progress"]')
      const spy = vi.fn()
      el.addEventListener('progress:changed', spy)
      getController().setValue(75)
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ value: 75, min: 0, max: 100 })
    })

    it('direct attribute edits recalculate fill via valueValueChanged', async () => {
      const el = document.querySelector('[data-controller="progress"]')
      el.setAttribute('data-progress-value-value', '60')
      await new Promise((resolve) => setTimeout(resolve, 10))
      expect(document.querySelector('[data-progress-target="fill"]').style.width).toBe('60%')
    })
  })

  describe('indeterminate bar', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true">
          <div data-progress-target="fill"></div>
        </div>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('omits aria-valuenow', () => {
      expect(document.querySelector('[data-controller="progress"]').hasAttribute('aria-valuenow')).toBe(false)
    })

    it('adds the indeterminate animation class', () => {
      expect(
        document.querySelector('[data-controller="progress"]').classList.contains('sp-progress-indeterminate')
      ).toBe(true)
    })
  })
})
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- progress_controller` — verify it fails (module doesn't exist).
- [ ] Write the minimal implementation:

```js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['fill', 'meter'];
  static values = {
    variant: { type: String, default: 'bar' },
    value: { type: Number, default: 0 },
    min: { type: Number, default: 0 },
    max: { type: Number, default: 100 },
    optimum: Number,
    low: Number,
    high: Number,
    indeterminate: { type: Boolean, default: false },
  };

  connect() {
    if (this.variantValue === 'ring' && this.hasFillTarget) this.setCircumference(this.fillTarget);
    this.render();
  }

  setValue(value) {
    this.valueValue = this.clamp(value);
    this.dispatch('changed', { detail: { value: this.valueValue, min: this.minValue, max: this.maxValue } });
  }

  valueValueChanged() {
    this.render();
  }

  clamp(value) {
    return Math.min(this.maxValue, Math.max(this.minValue, value));
  }

  render() {
    if (this.variantValue === 'meter') {
      this.renderMeter();
      return;
    }

    const percent = this.percent();
    if (this.variantValue === 'ring') this.renderRing(percent);
    else this.renderBar(percent);

    this.element.setAttribute('aria-valuemin', this.minValue);
    this.element.setAttribute('aria-valuemax', this.maxValue);
    if (this.indeterminateValue) this.element.removeAttribute('aria-valuenow');
    else this.element.setAttribute('aria-valuenow', this.valueValue);
    this.element.classList.toggle('sp-progress-indeterminate', this.indeterminateValue);
  }

  percent() {
    const range = this.maxValue - this.minValue;
    return range <= 0 ? 0 : ((this.valueValue - this.minValue) / range) * 100;
  }

  renderBar(percent) {
    if (this.hasFillTarget) this.fillTarget.style.width = `${percent}%`;
  }

  renderRing(percent) {
    if (!this.hasFillTarget) return;
    if (this.circumference == null) this.setCircumference(this.fillTarget);
    this.fillTarget.style.strokeDasharray = `${this.circumference}`;
    this.fillTarget.style.strokeDashoffset = `${this.circumference * (1 - percent / 100)}`;
  }

  setCircumference(circle) {
    const r = parseFloat(circle.getAttribute('r'));
    this.circumference = 2 * Math.PI * r;
  }

  renderMeter() {
    if (!this.hasMeterTarget) return;
    const meter = this.meterTarget;
    meter.value = this.valueValue;
    meter.min = this.minValue;
    meter.max = this.maxValue;
    if (this.hasLowValue) meter.low = this.lowValue;
    if (this.hasHighValue) meter.high = this.highValue;
    if (this.hasOptimumValue) meter.optimum = this.optimumValue;
  }
}
```

- [ ] Run the test again: `cd stimulus-plumbers && npm test -- progress_controller` — verify the bar-variant and indeterminate describe blocks pass.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/controllers/progress_controller.js stimulus-plumbers/tests/unit/controllers/progress_controller.test.js
git commit -m "$(cat <<'EOF'
feat: add progress controller (bar variant)

Value-driven Stimulus controller for the upcoming progress_bar/progress_ring/meter
Rails components. Bar variant: setValue() clamps to [min,max] and dispatches
progress:changed; valueValueChanged recalculates the fill width; indeterminate
suppresses aria-valuenow and toggles a CSS animation hook class.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 2: `progress` controller — ring variant

**Files:**
- Modify: `stimulus-plumbers/tests/unit/controllers/progress_controller.test.js` (append `describe('ring variant', ...)`)

**Interfaces:**
- Consumes: `renderRing`/`setCircumference` from Task 1 (already implemented — this task is test-only, verifying behavior that Task 1's implementation already provides).
- Produces: nothing new — confirms `stroke-dasharray`/`stroke-dashoffset` contract for Task 6 (Rails `ProgressRing` renderer).

Steps:

- [ ] Add the ring-variant test block inside the existing `describe('ProgressController', ...)`, after the `bar variant` block:

```js
  describe('ring variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <svg role="progressbar" data-controller="progress" data-progress-variant-value="ring"
             data-progress-value-value="25" data-progress-min-value="0" data-progress-max-value="100">
          <circle data-progress-target="fill" r="40"></circle>
        </svg>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('computes stroke-dasharray from the circle r attribute at connect', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      const expected = 2 * Math.PI * 40
      expect(parseFloat(fill.style.strokeDasharray)).toBeCloseTo(expected, 2)
    })

    it('computes stroke-dashoffset for the given percent', () => {
      const fill = document.querySelector('[data-progress-target="fill"]')
      const circumference = 2 * Math.PI * 40
      const expected = circumference * (1 - 0.25)
      expect(parseFloat(fill.style.strokeDashoffset)).toBeCloseTo(expected, 2)
    })

    it('recalculates stroke-dashoffset on setValue', () => {
      getController().setValue(50)
      const fill = document.querySelector('[data-progress-target="fill"]')
      const circumference = 2 * Math.PI * 40
      const expected = circumference * (1 - 0.5)
      expect(parseFloat(fill.style.strokeDashoffset)).toBeCloseTo(expected, 2)
    })

    it('still sets aria-valuenow/valuemin/valuemax like the bar variant', () => {
      const el = document.querySelector('[data-controller="progress"]')
      expect(el.getAttribute('aria-valuenow')).toBe('25')
      expect(el.getAttribute('aria-valuemin')).toBe('0')
      expect(el.getAttribute('aria-valuemax')).toBe('100')
    })
  })
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- progress_controller` — verify it fails first if you temporarily comment out `renderRing`'s body (sanity-check the test actually exercises the code), then restore and verify it passes against Task 1's implementation.
- [ ] Commit:

```bash
git add stimulus-plumbers/tests/unit/controllers/progress_controller.test.js
git commit -m "$(cat <<'EOF'
test: cover progress controller ring variant

Confirms stroke-dasharray/stroke-dashoffset are computed from the circle's r
attribute at connect (not hardcoded) and recalculated on setValue().

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 3: `progress` controller — meter variant

**Files:**
- Modify: `stimulus-plumbers/tests/unit/controllers/progress_controller.test.js` (append `describe('meter variant', ...)`)

**Interfaces:**
- Consumes: `renderMeter` from Task 1.
- Produces: confirms the meter attribute-sync contract for Task 7 (Rails `Meter` renderer).

Steps:

- [ ] Add the meter-variant test block:

```js
  describe('meter variant', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <meter data-controller="progress" data-progress-variant-value="meter" data-progress-target="meter"
               data-progress-value-value="40" data-progress-min-value="0" data-progress-max-value="100"
               data-progress-low-value="20" data-progress-high-value="80" data-progress-optimum-value="50"></meter>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('syncs value/min/max/low/high/optimum onto the native meter', () => {
      const meter = document.querySelector('[data-controller="progress"]')
      expect(meter.value).toBe(40)
      expect(meter.min).toBe(0)
      expect(meter.max).toBe(100)
      expect(meter.low).toBe(20)
      expect(meter.high).toBe(80)
      expect(meter.optimum).toBe(50)
    })

    it('does not set role=progressbar aria attrs', () => {
      const meter = document.querySelector('[data-controller="progress"]')
      expect(meter.hasAttribute('aria-valuenow')).toBe(false)
    })

    it('setValue updates the native meter value', () => {
      getController().setValue(70)
      expect(document.querySelector('[data-controller="progress"]').value).toBe(70)
    })
  })
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- progress_controller` — verify all describe blocks (bar, ring, meter, indeterminate) pass.
- [ ] Run full JS suite + lint: `cd stimulus-plumbers && npm test && npm run lint && npm run format:check` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers/tests/unit/controllers/progress_controller.test.js
git commit -m "$(cat <<'EOF'
test: cover progress controller meter variant

Confirms the meter variant syncs value/min/max/low/high/optimum directly onto
the native <meter> element instead of computing a fill percentage.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 4: export `progress` controller + JS docs/README

**Files:**
- Modify: `stimulus-plumbers/src/index.js`
- Create: `stimulus-plumbers/docs/component/progress.md`
- Modify: `stimulus-plumbers/README.md`

**Interfaces:**
- Consumes: `ProgressController` from Task 1.
- Produces: `ProgressController` export used by consumers; no code interface for later tasks (doc/export only).

Steps:

- [ ] Add the export alphabetically between `PopoverController` and `ReorderableController` in `stimulus-plumbers/src/index.js`:

```js
export { default as PopoverController } from './controllers/popover_controller.js';
export { default as ProgressController } from './controllers/progress_controller.js';
export { default as ReorderableController } from './controllers/reorderable_controller.js';
```

- [ ] Create `stimulus-plumbers/docs/component/progress.md`:

```markdown
# Progress

Value-driven progress indicator supporting three render variants: a linear bar, an SVG ring, and a native `<meter>`.

## Stimulus Identifier

`progress`

## Targets

| Name    | Element                        | Purpose                                                                             |
| ------- | ------------------------------- | ------------------------------------------------------------------------------------ |
| `fill`  | `<div>` (bar) / `<circle>` (ring) | Element whose `width` (bar) or `stroke-dasharray`/`stroke-dashoffset` (ring) is set |
| `meter` | `<meter>`                       | Present only for `variant: "meter"` — native element, attributes synced directly    |

## Values

| Name            | Type    | Default | Purpose                                                                 |
| ---------------- | ------- | ------- | ------------------------------------------------------------------------ |
| `variant`        | String  | `"bar"` | `"bar"` \| `"ring"` \| `"meter"`                                        |
| `value`          | Number  | `0`     | Current value                                                           |
| `min`            | Number  | `0`     | Range minimum                                                           |
| `max`            | Number  | `100`   | Range maximum                                                           |
| `optimum`        | Number  | —       | Meter-only; maps to native `<meter optimum>`                           |
| `low`            | Number  | —       | Meter-only; maps to native `<meter low>`                                |
| `high`           | Number  | —       | Meter-only; maps to native `<meter high>`                               |
| `indeterminate`  | Boolean | `false` | Suppresses `aria-valuenow`; toggles the `sp-progress-indeterminate` class |

## Methods

| Method                    | Wired via              | Purpose                                                                                  |
| -------------------------- | ----------------------- | ------------------------------------------------------------------------------------------ |
| `setValue(value)`         | —                       | Programmatic API — clamps to `[min, max]`, updates `valueValue`, dispatches `progress:changed` |
| `valueValueChanged(value)` | Stimulus value callback | Recalculates fill/meter attrs whenever `value` changes (covers `setValue()` and direct attribute edits) |

## Dispatches

| Event              | Detail                    | When                                    |
| -------------------- | --------------------------- | ------------------------------------------ |
| `progress:changed` | `{ value, min, max }`     | After `setValue()` updates the value    |

## Example HTML

```html
<!-- Bar -->
<div role="progressbar" data-controller="progress"
     data-progress-value-value="30" data-progress-min-value="0" data-progress-max-value="100">
  <div data-progress-target="fill"></div>
</div>

<!-- Ring -->
<svg role="progressbar" data-controller="progress" data-progress-variant-value="ring"
     data-progress-value-value="25" data-progress-max-value="100">
  <circle data-progress-target="fill" r="40"></circle>
</svg>

<!-- Meter -->
<meter data-controller="progress" data-progress-variant-value="meter" data-progress-target="meter"
       data-progress-value-value="40" data-progress-min-value="0" data-progress-max-value="100"></meter>

<!-- Indeterminate -->
<div role="progressbar" data-controller="progress" data-progress-indeterminate-value="true">
  <div data-progress-target="fill"></div>
</div>
```
```

- [ ] Add a Controllers table row to `stimulus-plumbers/README.md`, between `popover` and `reorderable`:

```markdown
| `progress` | Value-driven progress bar/ring/meter | [docs/component/progress.md](docs/component/progress.md) |
```

- [ ] Verify docs formatting: `cd stimulus-plumbers && npm run format:docs:check`.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/index.js stimulus-plumbers/docs/component/progress.md stimulus-plumbers/README.md
git commit -m "$(cat <<'EOF'
docs: export progress controller and document it

Adds ProgressController to the package's public export list and documents its
Stimulus API, matching the doc-per-export convention.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 5: Rails `progress_bar` component + helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_bar.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb` (new file)
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_bar_test.rb`

**Interfaces:**
- Consumes: theme key schema pattern (`Ranges::BOOL`), `Plumber::Base#merge_html_options`/`theme.resolve`.
- Produces: `StimulusPlumbers::Components::ProgressBar#render(value:, min: 0, max: 100, indeterminate: false, **kwargs)`; helper `sp_progress_bar(value:, max: 100, **kwargs)`. Theme keys `progress_bar`, `progress_bar_fill`. Consumed by Task 8 (sandbox/a11y test) and Task 4's controller data-attributes (already fixed).

Steps:

- [ ] Add the `PROGRESS` schema block to `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`, after `LAYOUT` and before `TIMELINE`:

```ruby
      PROGRESS = {
        progress_bar:        {}.freeze,
        progress_bar_fill:   {}.freeze,
        progress_ring:       {}.freeze,
        progress_ring_track: {}.freeze,
        progress_ring_fill:  {}.freeze,
        meter:               {}.freeze
      }.freeze
```

- [ ] Add `**Schema::PROGRESS,` to the `SCHEMA` hash in `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb` (after `**Schema::LINK,`):

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
        **Schema::PROGRESS,
        **Schema::TIMELINE
      }.freeze
```

- [ ] Write the failing unit test `stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_bar_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class ProgressBarTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ProgressBar.new(self)
  end

  def test_renders_progressbar_role
    assert_css parse_html(renderer.render(value: 30)), "div[role='progressbar']"
  end

  def test_renders_aria_value_attrs
    doc = parse_html(renderer.render(value: 30, max: 100))

    assert_css doc, "div[aria-valuenow='30']"
    assert_css doc, "div[aria-valuemin='0']"
    assert_css doc, "div[aria-valuemax='100']"
  end

  def test_renders_fill_target
    assert_css parse_html(renderer.render(value: 30)), "div[data-progress-target='fill']"
  end

  def test_wires_progress_controller_and_values
    doc = parse_html(renderer.render(value: 30, min: 0, max: 100))

    assert_css doc, "div[data-controller='progress']"
    assert_css doc, "div[data-progress-variant-value='bar']"
    assert_css doc, "div[data-progress-value-value='30']"
    assert_css doc, "div[data-progress-min-value='0']"
    assert_css doc, "div[data-progress-max-value='100']"
  end

  def test_indeterminate_omits_aria_valuenow
    doc = parse_html(renderer.render(value: 0, indeterminate: true))

    assert_no_css doc, "div[aria-valuenow]"
    assert_css doc, "div[data-progress-indeterminate-value='true']"
  end

  def test_merges_custom_html_options
    assert_css parse_html(renderer.render(value: 30, id: "my-progress")), "div#my-progress"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/progress_bar_test.rb` — verify it fails (class doesn't exist).
- [ ] Write `stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_bar.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressBar < Plumber::Base
      def render(value:, min: 0, max: 100, indeterminate: false, **kwargs)
        aria = { valuemin: min, valuemax: max }
        aria[:valuenow] = value unless indeterminate

        stimulus = {
          data: {
            controller:                    "progress",
            "progress-variant-value":      "bar",
            "progress-value-value":        value,
            "progress-min-value":          min,
            "progress-max-value":          max,
            "progress-indeterminate-value": indeterminate
          }
        }

        html_options = merge_html_options(theme.resolve(:progress_bar), kwargs, stimulus, { role: "progressbar", aria: aria })
        fill = template.content_tag(
          :div, nil,
          **merge_html_options(theme.resolve(:progress_bar_fill), { data: { "progress-target": "fill" } })
        )
        template.content_tag(:div, fill, **html_options)
      end
    end
  end
end
```

- [ ] Create `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ProgressHelper
      def sp_progress_bar(value:, max: 100, **kwargs)
        Components::ProgressBar.new(self).render(value: value, max: max, **kwargs)
      end
    end
  end
end
```

- [ ] Wire it into `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb` — add `require_relative "helpers/progress_helper"` (after `require_relative "helpers/popover_helper"`) and `include ProgressHelper` (after `include PopoverHelper`):

```ruby
require_relative "helpers/popover_helper"
require_relative "helpers/progress_helper"
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
    include ProgressHelper
    include TimelineHelper
  end
end
```

- [ ] Require the new component in `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, after the popover requires:

```ruby
require_relative "stimulus_plumbers/components/popover/panel"
require_relative "stimulus_plumbers/components/progress_bar"
```

- [ ] Run the test: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/progress_bar_test.rb` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_bar.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_bar_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_progress_bar Rails helper

Thin renderer emitting the progress controller's bar-variant data-attributes
plus role=progressbar/aria-value* — pairs with progress_controller.js.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 6: Rails `progress_ring` component + helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_ring.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_ring_test.rb`

**Interfaces:**
- Consumes: `PROGRESS` schema keys from Task 5.
- Produces: `StimulusPlumbers::Components::ProgressRing#render(value:, max: 100, radius: 20, min: 0, indeterminate: false, **kwargs)`; helper `sp_progress_ring(value:, max: 100, radius: 20, **kwargs)`.

Steps:

- [ ] Write the failing test `stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_ring_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class ProgressRingTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ProgressRing.new(self)
  end

  def test_renders_svg_with_progressbar_role
    assert_css parse_html(renderer.render(value: 25)), "svg[role='progressbar']"
  end

  def test_renders_track_and_fill_circles
    doc = parse_html(renderer.render(value: 25))

    assert_equal 2, doc.css("circle").size
    assert_css doc, "circle[data-progress-target='fill']"
  end

  def test_fill_circle_has_dasharray_matching_circumference
    doc = parse_html(renderer.render(value: 25, radius: 40))

    circumference = 2 * Math.PI * 40
    fill = doc.at_css("circle[data-progress-target='fill']")

    assert_in_delta circumference, fill["stroke-dasharray"].to_f, 0.01
  end

  def test_circles_use_given_radius
    doc = parse_html(renderer.render(value: 25, radius: 40))

    assert_equal 2, doc.css("circle[r='40']").size
  end

  def test_wires_progress_controller_ring_variant
    doc = parse_html(renderer.render(value: 25))

    assert_css doc, "svg[data-controller='progress']"
    assert_css doc, "svg[data-progress-variant-value='ring']"
    assert_css doc, "svg[data-progress-value-value='25']"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/progress_ring_test.rb` — verify failure.
- [ ] Write `stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_ring.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressRing < Plumber::Base
      def render(value:, max: 100, radius: 20, min: 0, indeterminate: false, **kwargs)
        aria = { valuemin: min, valuemax: max }
        aria[:valuenow] = value unless indeterminate

        stimulus = {
          data: {
            controller:                    "progress",
            "progress-variant-value":      "ring",
            "progress-value-value":        value,
            "progress-min-value":          min,
            "progress-max-value":          max,
            "progress-indeterminate-value": indeterminate
          }
        }

        svg_options   = merge_html_options(theme.resolve(:progress_ring), kwargs, stimulus, { role: "progressbar", aria: aria })
        circumference = 2 * Math.PI * radius
        track         = template.content_tag(:circle, nil, r: radius, **merge_html_options(theme.resolve(:progress_ring_track)))
        fill          = template.content_tag(
          :circle, nil,
          r: radius, "stroke-dasharray": circumference,
          **merge_html_options(theme.resolve(:progress_ring_fill), { data: { "progress-target": "fill" } })
        )

        template.content_tag(:svg, template.safe_join([track, fill]), **svg_options)
      end
    end
  end
end
```

- [ ] Add `sp_progress_ring` to `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb`:

```ruby
      def sp_progress_ring(value:, max: 100, radius: 20, **kwargs)
        Components::ProgressRing.new(self).render(value: value, max: max, radius: radius, **kwargs)
      end
```

- [ ] Require the new component in `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, after `progress_bar`:

```ruby
require_relative "stimulus_plumbers/components/progress_bar"
require_relative "stimulus_plumbers/components/progress_ring"
```

- [ ] Run the test: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/progress_ring_test.rb` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_ring.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/progress_ring_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_progress_ring Rails helper

Renders an SVG ring (track + fill circle) wired to the progress controller's
ring variant; radius drives both circles and the fill's initial dasharray.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 7: Rails `meter` component + helper

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/meter.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/meter_test.rb`

**Interfaces:**
- Consumes: `PROGRESS` schema `meter` key from Task 5.
- Produces: `StimulusPlumbers::Components::Meter#render(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)`; helper `sp_meter(...)`.

Steps:

- [ ] Write the failing test `stimulus-plumbers-rails/test/stimulus_plumbers/components/meter_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class MeterTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Meter.new(self)
  end

  def test_renders_meter_element
    assert_css parse_html(renderer.render(value: 40)), "meter"
  end

  def test_sets_native_value_min_max_attrs
    doc = parse_html(renderer.render(value: 40, min: 0, max: 100))

    assert_css doc, "meter[value='40']"
    assert_css doc, "meter[min='0']"
    assert_css doc, "meter[max='100']"
  end

  def test_sets_low_high_optimum_when_given
    doc = parse_html(renderer.render(value: 40, low: 20, high: 80, optimum: 50))

    assert_css doc, "meter[low='20']"
    assert_css doc, "meter[high='80']"
    assert_css doc, "meter[optimum='50']"
  end

  def test_omits_low_high_optimum_when_not_given
    doc = parse_html(renderer.render(value: 40))

    assert_no_css doc, "meter[low]"
    assert_no_css doc, "meter[high]"
    assert_no_css doc, "meter[optimum]"
  end

  def test_wires_progress_controller_meter_variant
    doc = parse_html(renderer.render(value: 40))

    assert_css doc, "meter[data-controller='progress']"
    assert_css doc, "meter[data-progress-variant-value='meter']"
    assert_css doc, "meter[data-progress-target='meter']"
  end

  def test_has_no_progressbar_role
    assert_no_css parse_html(renderer.render(value: 40)), "meter[role='progressbar']"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/meter_test.rb` — verify failure.
- [ ] Write `stimulus-plumbers-rails/lib/stimulus_plumbers/components/meter.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Meter < Plumber::Base
      def render(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        data = {
          controller:               "progress",
          "progress-target":        "meter",
          "progress-variant-value": "meter",
          "progress-value-value":   value,
          "progress-min-value":     min,
          "progress-max-value":     max
        }
        data["progress-low-value"]     = low if low
        data["progress-high-value"]    = high if high
        data["progress-optimum-value"] = optimum if optimum

        attrs        = { value: value, min: min, max: max, low: low, high: high, optimum: optimum }.compact
        html_options = merge_html_options(theme.resolve(:meter), kwargs, { data: data }, attrs)
        template.content_tag(:meter, nil, **html_options)
      end
    end
  end
end
```

- [ ] Add `sp_meter` to `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb`:

```ruby
      def sp_meter(value:, min: 0, max: 100, low: nil, high: nil, optimum: nil, **kwargs)
        Components::Meter.new(self).render(value: value, min: min, max: max, low: low, high: high, optimum: optimum, **kwargs)
      end
```

- [ ] Require the new component in `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, after `progress_ring`:

```ruby
require_relative "stimulus_plumbers/components/progress_ring"
require_relative "stimulus_plumbers/components/meter"
```

- [ ] Run the test: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/meter_test.rb` — verify it passes.
- [ ] Run full Rails unit suite + rubocop: `cd stimulus-plumbers-rails && rake test:unit && rake rubocop` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/meter.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/progress_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/meter_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_meter Rails helper

Renders a native <meter> wired to the progress controller's meter variant —
no ARIA role needed since <meter> has native semantics.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 8: Progress — sandbox view, accessibility tests, README + docs

**Files:**
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/progress.html.erb`
- Modify: `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`
- Create: `stimulus-plumbers-rails/test/accessibility/components/progress_accessibility_test.rb`
- Create: `stimulus-plumbers-rails/docs/component/progress.md`
- Modify: `stimulus-plumbers-rails/README.md`

**Interfaces:**
- Consumes: `sp_progress_bar`/`sp_progress_ring`/`sp_meter` helpers from Tasks 5–7.
- Produces: nothing for later tasks — this is the acceptance/documentation task for Part 1.

Steps:

- [ ] Add `get :progress` to `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`:

```ruby
scope "/display", controller: "components" do
  get :list
  get :ordered_list
  get :avatar
  get :icon
  get :timeline
  get :progress
end
```

- [ ] Add `def progress; end` to `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`, after `def timeline; end`.

- [ ] Create `stimulus-plumbers-rails/test/sandbox/app/views/components/progress.html.erb`:

```erb
<h1>Progress components</h1>

<div id="progress-bar">
  <%= sp_progress_bar(value: 30, max: 100, aria: { label: "Upload progress" }) %>
</div>

<div id="progress-bar-indeterminate">
  <%= sp_progress_bar(value: 0, indeterminate: true, aria: { label: "Loading" }) %>
</div>

<div id="progress-ring">
  <%= sp_progress_ring(value: 60, max: 100, radius: 40, aria: { label: "Storage used" }) %>
</div>

<div id="progress-meter">
  <%= sp_meter(value: 6, min: 0, max: 10, low: 3, high: 8, optimum: 9, aria: { label: "Disk usage" }) %>
</div>
```

- [ ] Write the failing accessibility test `stimulus-plumbers-rails/test/accessibility/components/progress_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProgressAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/progress"
  end

  def test_progress_bar_passes_wcag
    assert_accessible context: "#progress-bar"
  end

  def test_indeterminate_progress_bar_passes_wcag
    assert_accessible context: "#progress-bar-indeterminate"
  end

  def test_progress_ring_passes_wcag
    assert_accessible context: "#progress-ring"
  end

  def test_meter_passes_wcag
    assert_accessible context: "#progress-meter"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/accessibility/components/progress_accessibility_test.rb` — verify it fails first (route/view don't exist) then passes once the view/route are in place, then re-run to confirm all four pass with no axe violations.
- [ ] Create `stimulus-plumbers-rails/docs/component/progress.md`:

```markdown
# Progress

Rails helpers for rendering the `progress` Stimulus controller's three variants. See [stimulus-plumbers's docs/component/progress.md](../../../stimulus-plumbers/docs/component/progress.md) for the controller's Values/Targets/Methods/Dispatches.

## Helpers

### `sp_progress_bar`

```erb
<%= sp_progress_bar(value: 30, max: 100, aria: { label: "Upload progress" }) %>
```

| Option           | Default | Description                                          |
| ---------------- | ------- | ------------------------------------------------------ |
| `value:`         | —       | Required. Current value                              |
| `min:`           | `0`     | Range minimum                                        |
| `max:`           | `100`   | Range maximum                                        |
| `indeterminate:` | `false` | Omits `aria-valuenow`; adds the indeterminate hook class |
| `**html_options` | —       | Forwarded to the outer `<div role="progressbar">`     |

### `sp_progress_ring`

```erb
<%= sp_progress_ring(value: 60, max: 100, radius: 40, aria: { label: "Storage used" }) %>
```

| Option           | Default | Description                                             |
| ---------------- | ------- | --------------------------------------------------------- |
| `value:`         | —       | Required. Current value                                 |
| `max:`           | `100`   | Range maximum                                           |
| `radius:`        | `20`    | SVG circle radius — also drives the initial circumference |
| `**html_options` | —       | Forwarded to the outer `<svg role="progressbar">`        |

### `sp_meter`

```erb
<%= sp_meter(value: 6, min: 0, max: 10, low: 3, high: 8, optimum: 9, aria: { label: "Disk usage" }) %>
```

| Option           | Default | Description                                  |
| ---------------- | ------- | ----------------------------------------------- |
| `value:`         | —       | Required. Current value                      |
| `min:`           | `0`     | Range minimum                                |
| `max:`           | `100`   | Range maximum                                |
| `low:`           | `nil`   | Native `<meter low>` — omitted when not given |
| `high:`          | `nil`   | Native `<meter high>` — omitted when not given |
| `optimum:`       | `nil`   | Native `<meter optimum>` — omitted when not given |
| `**html_options` | —       | Forwarded to the `<meter>`                    |

## Known limitation

`<meter>` styling relies on `::-webkit-meter-*`/`::-moz-meter-*` pseudo-elements — cross-browser visual consistency is limited; this is a native-element tradeoff, not a bug.
```

- [ ] Add a Components table row to `stimulus-plumbers-rails/README.md`, after the `Popover` row:

```markdown
| Progress | `sp_progress_bar`, `sp_progress_ring`, `sp_meter` | [docs/component/progress.md](docs/component/progress.md) |
```

- [ ] Run `cd stimulus-plumbers-rails && rake test:accessibility` (progress test only, or full suite) and `npm run format:docs:check` from the repo root's `stimulus-plumbers` package (docs formatting applies to all `*/docs/**/*.md` per root CLAUDE.md) — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/test/sandbox/app/views/components/progress.html.erb \
        stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb \
        stimulus-plumbers-rails/test/sandbox/config/routes/display.rb \
        stimulus-plumbers-rails/test/accessibility/components/progress_accessibility_test.rb \
        stimulus-plumbers-rails/docs/component/progress.md \
        stimulus-plumbers-rails/README.md
git commit -m "$(cat <<'EOF'
test: add progress accessibility coverage and docs

Sandbox page exercising all three variants (plus indeterminate), axe-core
coverage for each, and the Rails helper doc page.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Part 2: Indicator (extracted from `timeline_item_indicator*`)

### Task 9: `indicator` Rails component

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/indicator.rb`
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/indicator_helper.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/indicator_test.rb`

**Interfaces:**
- Consumes: `Button::Ranges::VARIANT` (existing semantic color token list: `primary secondary tertiary success destructive warning info`) as the `color:` validator — reused rather than duplicated, per the spec's "maps to existing semantic color tokens" requirement.
- Produces: `StimulusPlumbers::Components::Indicator#render(variant: :dot, color:, pulse: false, **kwargs, &block)`; helper `sp_indicator(variant: :dot, color:, pulse: false, **kwargs, &block)`. Theme keys `indicator`, `indicator_pulse`. Consumed by Task 11 (timeline refactor) and Task 10 (a11y tests).

Steps:

- [ ] Add the `INDICATOR` schema block to `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`, after `ICON` and before `INPUT_GROUP`:

```ruby
      INDICATOR = {
        indicator:       {
          variant: { default: :dot,  validate: %i[dot pulse badge] },
          color:   { default: nil,   validate: Button::Ranges::VARIANT },
          pulse:   { default: false, validate: Ranges::BOOL }
        }.freeze,
        indicator_pulse: {}.freeze
      }.freeze
```

- [ ] Add `**Schema::INDICATOR,` to `SCHEMA` in `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb` (after `**Schema::ICON,`):

```ruby
        **Schema::ICON,
        **Schema::INDICATOR,
        **Schema::INPUT_GROUP,
```

- [ ] Write the failing unit test `stimulus-plumbers-rails/test/stimulus_plumbers/components/indicator_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class IndicatorTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Indicator.new(self)
  end

  def test_renders_a_span
    assert_css parse_html(renderer.render(color: :success)), "span"
  end

  def test_dot_variant_is_empty_by_default
    doc = parse_html(renderer.render(variant: :dot, color: :success))

    assert_equal "", doc.css("span").first.text.strip
  end

  def test_badge_variant_renders_provided_content
    doc = parse_html(renderer.render(variant: :badge, color: :primary) { "5" })

    assert_includes doc.text, "5"
  end

  def test_pulse_true_adds_a_second_ring_element
    doc = parse_html(renderer.render(color: :warning, pulse: true))

    assert_equal 2, doc.css("span").size
  end

  def test_pulse_false_renders_only_the_dot
    doc = parse_html(renderer.render(color: :warning, pulse: false))

    assert_equal 1, doc.css("span").size
  end

  def test_pulse_ring_is_aria_hidden
    doc = parse_html(renderer.render(color: :warning, pulse: true))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_merges_custom_html_options
    assert_css parse_html(renderer.render(color: :success, id: "my-indicator")), "span#my-indicator"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/indicator_test.rb` — verify failure.
- [ ] Write `stimulus-plumbers-rails/lib/stimulus_plumbers/components/indicator.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Indicator < Plumber::Base
      def render(variant: :dot, color:, pulse: false, **kwargs, &block)
        content      = block_given? ? template.capture(&block) : nil
        html_options = merge_html_options(theme.resolve(:indicator, variant: variant, color: color, pulse: pulse), kwargs)
        dot          = template.content_tag(:span, content, **html_options)

        return dot unless pulse

        pulse_ring = template.content_tag(
          :span, nil,
          **merge_html_options(theme.resolve(:indicator_pulse), { aria: { hidden: "true" } })
        )
        template.safe_join([pulse_ring, dot])
      end
    end
  end
end
```

- [ ] Create `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/indicator_helper.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module IndicatorHelper
      def sp_indicator(variant: :dot, color:, pulse: false, **kwargs, &block)
        Components::Indicator.new(self).render(variant: variant, color: color, pulse: pulse, **kwargs, &block)
      end
    end
  end
end
```

- [ ] Wire it into `stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb` — add `require_relative "helpers/indicator_helper"` (after `require_relative "helpers/icon_helper"`) and `include IndicatorHelper` (after `include IconHelper`):

```ruby
require_relative "helpers/icon_helper"
require_relative "helpers/indicator_helper"
require_relative "helpers/list_helper"
```

```ruby
    include PlumberHelper
    include IconHelper
    include IndicatorHelper
    include ListHelper
```

- [ ] Require the new component in `stimulus-plumbers-rails/lib/stimulus_plumbers.rb`, right after `require_relative "stimulus_plumbers/components/icon"`:

```ruby
require_relative "stimulus_plumbers/components/icon"
require_relative "stimulus_plumbers/components/indicator"
require_relative "stimulus_plumbers/components/avatar"
```

- [ ] Run the test: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/indicator_test.rb` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/indicator.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers/indicator_helper.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/helpers.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/base.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/indicator_test.rb
git commit -m "$(cat <<'EOF'
feat: add sp_indicator presentational component

New dot/pulse/badge status marker, no controller. color: reuses the existing
Button::Ranges::VARIANT semantic token list rather than a new range.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 10: Indicator — sandbox view, accessibility tests (incl. missing-label regression guard)

**Files:**
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/components/indicator.html.erb`
- Modify: `stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb`
- Modify: `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb`
- Create: `stimulus-plumbers-rails/test/accessibility/components/indicator_accessibility_test.rb`

**Interfaces:**
- Consumes: `sp_indicator` from Task 9.
- Produces: nothing for later tasks — acceptance test for the "must be paired with an accessible name" rule.

Steps:

- [ ] Add `get :indicator` to `stimulus-plumbers-rails/test/sandbox/config/routes/display.rb` (after `get :progress`), and `def indicator; end` to `components_controller.rb` (after `def progress; end`).

- [ ] Create `stimulus-plumbers-rails/test/sandbox/app/views/components/indicator.html.erb`:

```erb
<h1>Indicator components</h1>

<div id="indicator-paired">
  <%# ── Correct usage: paired with a visible/sr-only label ──────────────── %>
  <span>
    <%= sp_indicator(color: :success) %>
    <span class="sr-only">Online</span>
  </span>

  <span>
    <%= sp_indicator(variant: :pulse, color: :destructive, pulse: true) %>
    <span class="sr-only">Live</span>
  </span>

  <span>
    <%= sp_indicator(variant: :badge, color: :primary) { "5" } %>
    <span class="sr-only">5 unread notifications</span>
  </span>
</div>

<div id="indicator-unpaired">
  <%# ── Regression guard: no accessible name — axe must flag this ───────── %>
  <%= sp_indicator(color: :success) %>
</div>
```

- [ ] Write the failing accessibility test `stimulus-plumbers-rails/test/accessibility/components/indicator_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class IndicatorAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/indicator"
  end

  def test_indicator_paired_with_a_label_passes_wcag
    assert_accessible context: "#indicator-paired"
  end

  def test_indicator_without_a_label_fails_wcag
    violations = page.evaluate_async_script(<<~JS, "#indicator-unpaired")
      var context = arguments[0];
      var done = arguments[arguments.length - 1];
      axe.run(context, function(err, results) {
        done(err ? [] : results.violations);
      });
    JS

    assert_predicate violations, :any?, "expected an axe violation for an unlabeled indicator"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/accessibility/components/indicator_accessibility_test.rb` — verify it fails first (route/view missing), then implement the route/view/component wiring, then verify both tests pass (the second test asserts axe *does* flag the unpaired indicator — this is the regression guard, not a bug to fix).
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/test/sandbox/app/views/components/indicator.html.erb \
        stimulus-plumbers-rails/test/sandbox/app/controllers/components_controller.rb \
        stimulus-plumbers-rails/test/sandbox/config/routes/display.rb \
        stimulus-plumbers-rails/test/accessibility/components/indicator_accessibility_test.rb
git commit -m "$(cat <<'EOF'
test: add indicator accessibility coverage

Includes a regression guard confirming axe flags an indicator with no
accessible name, since the component itself can't enforce a label.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 11: `timeline` refactor to use `sp_indicator` internally

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/timeline/event.rb`

**Interfaces:**
- Consumes: `StimulusPlumbers::Components::Indicator` from Task 9.
- Produces: no public API change — `Timeline`/`Timeline::Event`/`Timeline::Event::Slots` signatures are untouched.

Steps:

- [ ] Run the existing timeline test suite first to establish the baseline: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/helpers/timeline_helper_test.rb test/accessibility/components/timeline_accessibility_test.rb` — verify it currently passes (this is the "before" snapshot).
- [ ] In `stimulus-plumbers-rails/lib/stimulus_plumbers/components/timeline/event.rb`, replace `render_indicator_content` (the outer `render_indicator` wrapper `<div>` stays untouched — only the inner dot/icon content changes):

```ruby
        def render_indicator_content(type:, icon_name:)
          if type == :icon && icon_name
            icon = Components::Icon.new(template).render(
              name:    icon_name,
              classes: theme.resolve(:timeline_item_indicator_icon_slot).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
            Components::Indicator.new(template).render(variant: :dot, color: :primary) { icon }
          else
            Components::Indicator.new(template).render(variant: :dot, color: :primary)
          end
        end
```

  This removes the direct `template.content_tag(:span, nil, **merge_html_options(theme.resolve(:timeline_item_indicator_dot)))` call — the `timeline_item_indicator_dot` theme key is no longer resolved by this method. Leave the `timeline_item_indicator_dot` schema entry in `schema.rb` declared as-is (do not delete it) — removing an existing schema key is out of scope for this refactor; flag it in the PR description as now-unused so the tailwind theme owner can decide whether to keep or retire it.

- [ ] Run the full pre-existing timeline suite again: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/helpers/timeline_helper_test.rb test/accessibility/components/timeline_accessibility_test.rb` — verify every test still passes unmodified (this is the acceptance check per spec; no new test file is added in this task).
- [ ] Run rubocop: `cd stimulus-plumbers-rails && rake rubocop` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/timeline/event.rb
git commit -m "$(cat <<'EOF'
refactor: implement timeline indicator dot/icon via sp_indicator

De-duplicates timeline_item_indicator_dot construction (and the icon-wrapping
case) through the new Indicator component. No public API change to
Timeline/Timeline::Event; existing timeline test suite passes unmodified.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 12: Indicator — README rows + docs (JS has none; Rails only, plus legend doc pattern)

**Files:**
- Create: `stimulus-plumbers-rails/docs/component/indicator.md`
- Modify: `stimulus-plumbers-rails/README.md`

**Interfaces:**
- Consumes: `sp_indicator` from Task 9.
- Produces: nothing for later tasks (Part 2's documentation task). Note: `Indicator` has no Stimulus controller, so there is no `stimulus-plumbers/docs/component/*.md` entry or JS README row for it.

Steps:

- [ ] Create `stimulus-plumbers-rails/docs/component/indicator.md`:

```markdown
# Indicator

Presentational status marker — a colored dot, an animated "pulse" ring, or a numeric badge. No Stimulus controller.

## Helper

### `sp_indicator`

```erb
<%# Dot — must be paired with an accessible name %>
<span>
  <%= sp_indicator(color: :success) %>
  <span class="sr-only">Online</span>
</span>

<%# Pulse %>
<span>
  <%= sp_indicator(variant: :pulse, color: :destructive, pulse: true) %>
  <span class="sr-only">Live</span>
</span>

<%# Badge %>
<span>
  <%= sp_indicator(variant: :badge, color: :primary) { "5" } %>
  <span class="sr-only">5 unread notifications</span>
</span>
```

| Option           | Default | Description                                                                    |
| ---------------- | ------- | ---------------------------------------------------------------------------- |
| `variant:`       | `:dot`  | `:dot` \| `:pulse` \| `:badge` — `:badge` renders the given block as content |
| `color:`         | —       | Required. Semantic color token — same set as `Button`'s `variant:`          |
| `pulse:`         | `false` | Adds an animated ring element (`prefers-reduced-motion` suppresses the animation) |
| `**html_options` | —       | Forwarded to the dot `<span>`                                                |

**Every indicator must be paired with an accessible name** — a visible label or `aria-label`/adjacent `sr-only` text. The component itself renders no text and cannot know the right label; this is enforced by an accessibility test (see `test/accessibility/components/indicator_accessibility_test.rb`), not by the component.

## Legend pattern

To explain what each indicator color means (e.g. a status legend), pair indicators with visible text inside a list — do not rely on color alone:

```erb
<%= sp_list do |list| %>
  <%= list.item do |item| %>
    <% item.with_icon_leading { sp_indicator(color: :success) } %>
    <% item.with_title("Online") %>
  <% end %>
  <%= list.item do |item| %>
    <% item.with_icon_leading { sp_indicator(color: :warning) } %>
    <% item.with_title("Away") %>
  <% end %>
<% end %>
```
```

- [ ] Add a Components table row to `stimulus-plumbers-rails/README.md`, after the `Icon` row:

```markdown
| Icon | `sp_icon` | [docs/component/icon.md](docs/component/icon.md) |
| Indicator | `sp_indicator` | [docs/component/indicator.md](docs/component/indicator.md) |
```

- [ ] Run `npm run format:docs:check` from `stimulus-plumbers/` (applies repo-wide to `*/docs/**/*.md`) — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/docs/component/indicator.md stimulus-plumbers-rails/README.md
git commit -m "$(cat <<'EOF'
docs: document sp_indicator and the list-legend usage pattern

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Part 3: Checklist (`list_item` `checked:` extension)

### Task 13: `list-item` Stimulus controller

**Files:**
- Create: `stimulus-plumbers/src/controllers/list_item_controller.js`
- Test: `stimulus-plumbers/tests/unit/controllers/list_item_controller.test.js`

**Interfaces:**
- Consumes: nothing (new controller).
- Produces: `ListItemController` default export, `static targets = ['checkbox', 'content']`, `static values = { checked: Boolean }`, method `toggle()`, value callback `checkedValueChanged(checked)`, dispatches `list-item:toggled` with `{ checked }`. Consumed by Task 15 (Rails `List::Item` wires these data-attributes).

Steps:

- [ ] Write the failing test file:

```js
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { Application } from '@hotwired/stimulus'
import ListItemController from '../../../src/controllers/list_item_controller'

describe('ListItemController', () => {
  let application

  beforeEach(() => {
    application = Application.start()
    application.register('list-item', ListItemController)
  })

  afterEach(() => {
    application.stop()
    document.body.innerHTML = ''
  })

  const getController = () =>
    application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="list-item"]'),
      'list-item'
    )

  describe('toggle()', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <button data-controller="list-item" data-action="click->list-item#toggle"
                data-list-item-checked-value="false">
          <span data-list-item-target="checkbox"></span>
          <span data-list-item-target="content"></span>
        </button>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('flips checkedValue from false to true', () => {
      getController().toggle()
      expect(getController().checkedValue).toBe(true)
    })

    it('flips checkedValue back to false on a second toggle', () => {
      getController().toggle()
      getController().toggle()
      expect(getController().checkedValue).toBe(false)
    })

    it('dispatches list-item:toggled with the new checked state', () => {
      const el = document.querySelector('[data-controller="list-item"]')
      const spy = vi.fn()
      el.addEventListener('list-item:toggled', spy)
      getController().toggle()
      expect(spy).toHaveBeenCalledTimes(1)
      expect(spy.mock.calls[0][0].detail).toEqual({ checked: true })
    })
  })

  describe('checkedValueChanged (programmatic / external set)', () => {
    beforeEach(async () => {
      document.body.innerHTML = `
        <button data-controller="list-item" data-list-item-checked-value="false">
          <span data-list-item-target="checkbox"></span>
          <span data-list-item-target="content"></span>
        </button>
      `
      await new Promise((resolve) => setTimeout(resolve, 10))
    })

    it('sets aria-pressed to match the value on connect', () => {
      expect(document.querySelector('[data-controller="list-item"]').getAttribute('aria-pressed')).toBe('false')
    })

    it('updates aria-pressed and target datasets when the attribute is set directly, without calling toggle()', async () => {
      const el = document.querySelector('[data-controller="list-item"]')
      el.setAttribute('data-list-item-checked-value', 'true')
      await new Promise((resolve) => setTimeout(resolve, 10))

      expect(el.getAttribute('aria-pressed')).toBe('true')
      expect(document.querySelector('[data-list-item-target="checkbox"]').dataset.checked).toBe('true')
      expect(document.querySelector('[data-list-item-target="content"]').dataset.checked).toBe('true')
    })
  })
})
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- list_item_controller` — verify it fails (module doesn't exist).
- [ ] Write the minimal implementation `stimulus-plumbers/src/controllers/list_item_controller.js`:

```js
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['checkbox', 'content'];
  static values = {
    checked: { type: Boolean, default: false },
  };

  toggle() {
    this.checkedValue = !this.checkedValue;
    this.dispatch('toggled', { detail: { checked: this.checkedValue } });
  }

  checkedValueChanged(checked) {
    this.element.setAttribute('aria-pressed', checked);
    if (this.hasCheckboxTarget) this.checkboxTarget.dataset.checked = checked;
    if (this.hasContentTarget) this.contentTarget.dataset.checked = checked;
  }
}
```

- [ ] Run it: `cd stimulus-plumbers && npm test -- list_item_controller` — verify it passes.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/controllers/list_item_controller.js \
        stimulus-plumbers/tests/unit/controllers/list_item_controller.test.js
git commit -m "$(cat <<'EOF'
feat: add list-item controller for checklist toggling

toggle() flips checkedValue and dispatches list-item:toggled; checkedValueChanged
updates aria-pressed and target datasets, covering both the click path and an
external controller setting the attribute directly.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 14: export `list-item` controller + JS docs/README

**Files:**
- Modify: `stimulus-plumbers/src/index.js`
- Create: `stimulus-plumbers/docs/component/list-item.md`
- Modify: `stimulus-plumbers/README.md`

**Interfaces:**
- Consumes: `ListItemController` from Task 13.
- Produces: `ListItemController` export.

Steps:

- [ ] Add the export alphabetically in `stimulus-plumbers/src/index.js`, between `InputClearableController` and `ModalController`:

```js
export { default as InputClearableController } from './controllers/input_clearable_controller.js';
export { default as ListItemController } from './controllers/list_item_controller.js';
export { default as ModalController } from './controllers/modal_controller.js';
```

- [ ] Create `stimulus-plumbers/docs/component/list-item.md`:

```markdown
# List Item (checklist toggle)

Optional interactive behavior for a checklist-style list item: toggles a checked state and keeps `aria-pressed` / target dataset attributes in sync. Only wired when the Rails `list_item` helper is rendered with `interactive: true` and `checked:` set — see [stimulus-plumbers-rails's docs/component/list.md](../../../stimulus-plumbers-rails/docs/component/list.md) for the render options.

## Stimulus Identifier

`list-item`

## Targets

| Name       | Element                            | Purpose                                              |
| ---------- | ------------------------------------ | ------------------------------------------------------ |
| `checkbox` | Leading checkbox-glyph `<span>`     | Gets `dataset.checked` synced on every state change  |
| `content`  | Title/description wrapper `<span>` | Gets `dataset.checked` synced (strikethrough styling hook) |

## Values

| Name      | Type    | Default | Purpose                    |
| --------- | ------- | ------- | ----------------------------- |
| `checked` | Boolean | `false` | Current checklist state    |

## Actions

| Name     | Purpose                                                          |
| -------- | ------------------------------------------------------------------ |
| `toggle` | Flips `checkedValue` and dispatches `list-item:toggled`          |

## Dispatches

| Event               | Detail             | When                      |
| ---------------------- | -------------------- | ---------------------------- |
| `list-item:toggled`  | `{ checked }`      | After `toggle()` flips the value |

## Example HTML

```html
<button data-controller="list-item" data-action="click->list-item#toggle" data-list-item-checked-value="false">
  <span data-list-item-target="checkbox"></span>
  <span data-list-item-target="content">Buy milk</span>
</button>
```
```

- [ ] Add a Controllers table row to `stimulus-plumbers/README.md`, between `input-clearable` and `modal`:

```markdown
| `list-item` | Checklist item toggle (checked state, strikethrough hook) | [docs/component/list-item.md](docs/component/list-item.md) |
```

- [ ] Run `cd stimulus-plumbers && npm run format:docs:check` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers/src/index.js stimulus-plumbers/docs/component/list-item.md stimulus-plumbers/README.md
git commit -m "$(cat <<'EOF'
docs: export list-item controller and document it

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 15: Rails `List::Item` `checked:`/`interactive:` extension

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb`
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`
- Test: `stimulus-plumbers-rails/test/stimulus_plumbers/components/list/item_test.rb` (extend existing file)

**Interfaces:**
- Consumes: `list-item` controller data-attribute contract from Task 13 (`data-list-item-checked-value`, `data-action="click->list-item#toggle"`, `data-list-item-target="checkbox"|"content"`).
- Produces: `StimulusPlumbers::Components::List::Item#render(content = nil, checked: nil, interactive: false, **kwargs, &block)` — `checked: nil` (default) is unchanged plain-item behavior; `checked: true`/`false` renders the checkbox glyph and wires the controller. Theme key `list_item_checkbox`; `list_item_title`/`list_item_description` gain a `checked:` theme arg.

Steps:

- [ ] Add the `checked:` arg to `list_item_title`/`list_item_description` and the new `list_item_checkbox` key in the `LIST` schema block of `stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb`:

```ruby
      LIST = {
        list:                     {}.freeze,
        list_section:             {}.freeze,
        list_section_title:       {}.freeze,
        list_section_description: {}.freeze,
        list_item:                {}.freeze,
        list_item_icon:           {}.freeze,
        list_item_checkbox:       { checked: { default: false, validate: Ranges::BOOL } }.freeze,
        list_item_content:        {}.freeze,
        list_item_title:          { checked: { default: false, validate: Ranges::BOOL } }.freeze,
        list_item_description:    { checked: { default: false, validate: Ranges::BOOL } }.freeze
      }.freeze
```

- [ ] Write the failing tests — append to `stimulus-plumbers-rails/test/stimulus_plumbers/components/list/item_test.rb` (the file already exists; add these methods at the end, before the final `end`):

```ruby
  def test_checked_true_renders_checkbox_glyph
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_checked_false_renders_checkbox_glyph
    doc = parse_html(renderer.render("Buy milk", checked: false))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_checked_nil_omits_checkbox_glyph_and_controller
    doc = parse_html(renderer.render("Buy milk", checked: nil))

    assert_no_css doc, "[data-controller='list-item']"
  end

  def test_checked_wires_list_item_controller_and_value
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "[data-controller='list-item']"
    assert_css doc, "[data-list-item-checked-value='true']"
  end

  def test_interactive_wires_the_click_action
    doc = parse_html(renderer.render("Buy milk", checked: false, interactive: true))

    assert_css doc, "[data-action='click->list-item#toggle']"
  end

  def test_non_interactive_checklist_omits_the_click_action
    doc = parse_html(renderer.render("Buy milk", checked: false, interactive: false))

    assert_css doc, "[data-controller='list-item']"
    assert_no_css doc, "[data-action]"
  end

  def test_checkbox_and_content_carry_list_item_targets
    doc = parse_html(renderer.render("Buy milk", checked: true))

    assert_css doc, "[data-list-item-target='checkbox']"
    assert_css doc, "[data-list-item-target='content']"
  end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/list/item_test.rb` — verify the new tests fail.
- [ ] Modify `stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb`:

```ruby
# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class List
      class Item < Plumber::Base
        def render(content = nil, checked: nil, interactive: false, **kwargs, &block)
          slots = List::Item::Slots.new(template)
          slots.with_title(content) if content
          slots.with_icon_trailing("external-link") if kwargs[:url].present? && kwargs[:target] == "_blank"
          yield slots if block_given?

          @checked     = checked
          @interactive = interactive

          template.content_tag(:li) do
            build(**kwargs) do |attrs|
              render_link_or_button(**attrs) { render_item_slots(slots) }
            end
          end
        end

        def build(**kwargs, &block)
          html_options = merge_html_options(theme.resolve(:list_item), kwargs, checklist_stimulus_data)
          template.capture(html_options, &block)
        end

        private

        def checklist_stimulus_data
          return {} if @checked.nil?

          data = { controller: "list-item", "list-item-checked-value": @checked }
          data[:action] = "click->list-item#toggle" if @interactive
          { data: data }
        end

        def render_link_or_button(url: nil, target: nil, active: false, **html_options, &block)
          if url.present?
            aria = active ? { aria: { current: "page" } } : {}
            template.content_tag(:a, href: url, target: target, **merge_html_options(html_options, aria)) do
              template.capture(&block)
            end
          else
            aria = active ? { aria: { current: true } } : {}
            template.content_tag(:button, type: "button", **merge_html_options(html_options, aria)) do
              template.capture(&block)
            end
          end
        end

        def render_icon_slot(slots, name)
          slots.resolve(name) do |value|
            next value unless Components::Icon.icon_name?(value)

            Components::Icon.new(template).render(
              name:    value,
              classes: theme.resolve(:list_item_icon).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
        end

        def render_checkbox_glyph
          return if @checked.nil?

          icon_name = @checked ? "check" : "square"
          Components::Icon.new(template).render(
            name:    icon_name,
            classes: theme.resolve(:list_item_checkbox, checked: @checked).fetch(:classes, ""),
            aria:    { hidden: "true" },
            data:    { "list-item-target": "checkbox" }
          )
        end

        def render_title_slot(slots)
          slots.resolve(:title) do |v|
            template.content_tag(:span, v, **merge_html_options(theme.resolve(:list_item_title, checked: @checked == true)))
          end
        end

        def render_description_slot(slots)
          slots.resolve(:description) do |v|
            template.content_tag(
              :span, v,
              **merge_html_options(theme.resolve(:list_item_description, checked: @checked == true))
            )
          end
        end

        def render_content_slot(slots)
          title       = render_title_slot(slots)
          description = render_description_slot(slots)
          return unless title || description

          content_data = @checked.nil? ? {} : { data: { "list-item-target": "content" } }
          template.content_tag(:span, **merge_html_options(theme.resolve(:list_item_content), content_data)) do
            template.safe_join([title, description])
          end
        end

        def render_item_slots(slots)
          checkbox      = render_checkbox_glyph
          icon_leading  = render_icon_slot(slots, :icon_leading)
          icon_trailing = render_icon_slot(slots, :icon_trailing)
          content       = render_content_slot(slots)

          template.safe_join([checkbox, icon_leading, content, icon_trailing])
        end
      end
    end
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/stimulus_plumbers/components/list/item_test.rb` — verify all tests (existing + new) pass.
- [ ] Run rubocop: `cd stimulus-plumbers-rails && rake rubocop` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/lib/stimulus_plumbers/components/list/item.rb \
        stimulus-plumbers-rails/lib/stimulus_plumbers/themes/schema.rb \
        stimulus-plumbers-rails/test/stimulus_plumbers/components/list/item_test.rb
git commit -m "$(cat <<'EOF'
feat: add checked:/interactive: options to List::Item

checked: nil (default) is unchanged; true/false renders a checkbox glyph
leading the content and wires the new list-item controller's checked value.
interactive: true additionally wires click->list-item#toggle — read-only
checklists omit the data-action entirely, matching Timeline's opt-in precedent.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 16: Checklist — sandbox view + accessibility test

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/app/views/components/list.html.erb`
- Create: `stimulus-plumbers-rails/test/accessibility/components/list_accessibility_test.rb`

**Interfaces:**
- Consumes: `checked:`/`interactive:` options from Task 15; existing `get :list` route (no route change needed — `list.html.erb` already renders at `/components/display/list`).
- Produces: nothing for later tasks.

Steps:

- [ ] Append a new `<div id="list-checklist">` section to `stimulus-plumbers-rails/test/sandbox/app/views/components/list.html.erb` (after the existing `list-with-icons` section):

```erb
<div id="list-checklist">
  <%# Checklist — mix of checked/unchecked/read-only items %>
  <%= sp_list do |list| %>
    <%= list.item("Buy milk", checked: true, interactive: true) %>
    <%= list.item("Walk the dog", checked: false, interactive: true) %>
    <%= list.item("Read-only summary item", checked: true) %>
  <% end %>
</div>
```

- [ ] Write the failing accessibility test `stimulus-plumbers-rails/test/accessibility/components/list_accessibility_test.rb`:

```ruby
# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ListAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/list"
  end

  def test_checklist_passes_wcag
    assert_accessible context: "#list-checklist"
  end
end
```

- [ ] Run it: `cd stimulus-plumbers-rails && bin/rails test test/accessibility/components/list_accessibility_test.rb` — verify it fails first (section missing) then passes once the sandbox view is updated, with no axe violations.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/test/sandbox/app/views/components/list.html.erb \
        stimulus-plumbers-rails/test/accessibility/components/list_accessibility_test.rb
git commit -m "$(cat <<'EOF'
test: add checklist accessibility coverage

Sandbox section mixing checked/unchecked/read-only checklist items.

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

### Task 17: Checklist docs (Rails `list.md` update)

**Files:**
- Modify: `stimulus-plumbers-rails/docs/component/list.md`

**Interfaces:**
- Consumes: `checked:`/`interactive:` options from Task 15, `list-item` controller doc from Task 14.
- Produces: nothing for later tasks — final documentation task for Part 3.

Steps:

- [ ] Add a new subsection to `stimulus-plumbers-rails/docs/component/list.md`, right after the `### list.item(...)` options table and before `### Item slot methods`:

```markdown
### Checklist items (`checked:`/`interactive:`)

```erb
<%= sp_list do |list| %>
  <%= list.item("Buy milk", checked: true, interactive: true) %>
  <%= list.item("Walk the dog", checked: false, interactive: true) %>
  <%= list.item("Read-only summary item", checked: true) %>
<% end %>
```

| Option         | Default | Description                                                                                   |
| -------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `checked:`     | `nil`   | `nil` = plain list item (unchanged). `true`/`false` renders a leading checkbox glyph and wires the `list-item` controller's checked value |
| `interactive:` | `false` | When `checked:` is set, additionally wires `click->list-item#toggle` — omit for a read-only checklist display |

See [stimulus-plumbers's docs/component/list-item.md](../../../stimulus-plumbers/docs/component/list-item.md) for the controller's Targets/Values/Actions/Dispatches.
```

- [ ] Run `cd stimulus-plumbers && npm run format:docs:check` — verify clean.
- [ ] Commit:

```bash
git add stimulus-plumbers-rails/docs/component/list.md
git commit -m "$(cat <<'EOF'
docs: document List::Item checked:/interactive: options

Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
EOF
)"
```

---

## Self-Review

### 1. Spec coverage

| Spec section | Task(s) |
| --- | --- |
| Progress: Values/Targets/Methods/Dispatches, bar/ring/meter/indeterminate rendering | Tasks 1–3 |
| Progress: Rails helpers (`sp_progress_bar`/`sp_progress_ring`/`sp_meter`), theme keys | Tasks 5–7 |
| Progress: unit tests, component tests, accessibility tests | Tasks 1–3, 5–7, 8 |
| Progress: JS export + docs + README | Task 4 |
| Progress: Rails docs + README + known `<meter>` pseudo-element limitation | Task 8 |
| Indicator: design (dot/pulse/badge), color token reuse, no built-in text | Task 9 |
| Indicator: "must be paired with an accessible name" + regression guard test | Task 10 |
| Indicator: legend doc pattern | Task 12 |
| Indicator: `timeline` refactor, no public API change, existing tests pass unmodified | Task 11 |
| Indicator: theme keys, unit + accessibility tests | Tasks 9–10 |
| Checklist: `checked:` render option, checkbox glyph, strikethrough | Task 15 |
| Checklist: `list-item` controller (`toggle`, `checkedValueChanged`, dispatch) | Task 13 |
| Checklist: `interactive:` opt-in precedent (click action wired only when passed) | Task 15 |
| Checklist: theme key `list_item_checkbox` | Task 15 |
| Checklist: unit tests (Rails + JS), accessibility test | Tasks 13, 15, 16 |
| Checklist: JS export + docs, Rails docs update | Tasks 14, 17 |
| Out of scope items (password-complexity, currency/password formats, counter-badge formatting, Tailwind theme values) | Not implemented — confirmed absent from all tasks above |

No gaps found — every spec subsection maps to at least one task, and the "Out of scope" list is respected (no task touches `input-formatter`, adds numeric formatting, or writes Tailwind theme classes).

One deliberate, documented deviation from the spec's literal wording: filenames for accessibility tests use this repo's existing `*_accessibility_test.rb` suffix convention (matching `timeline_accessibility_test.rb`, `ordered_list_accessibility_test.rb`, etc.) rather than the spec's shorthand `progress_test.rb`/`indicator_test.rb`/`list_test.rb`, since no accessibility test in the repo omits that suffix. Unit/component test filenames (`progress_bar_test.rb`, `indicator_test.rb`, `list/item_test.rb`) match the spec exactly, since those do follow the repo's existing unsuffixed convention.

### 2. Placeholder scan

Searched for "TBD", "similar to Task", "add appropriate", and bare references to undefined types — none found. Every task step contains complete, runnable code (controller implementations, Rails component classes, full test files, exact schema/README/doc diffs). The one spot that could look like a placeholder — Task 11's note about the now-unused `timeline_item_indicator_dot` schema key — is not a TODO; it's an explicit instruction to leave existing code alone (per CLAUDE.md's "don't remove pre-existing dead code unless asked"), not a deferred implementation step.

### 3. Type consistency

- `progress` controller: `setValue(value)` / `valueValueChanged(value)` / targets `fill`, `meter` / values `variant, value, min, max, optimum, low, high, indeterminate` — used identically across Tasks 1–3 (JS), and the exact same data-attribute names (`data-progress-variant-value`, `data-progress-value-value`, `data-progress-min-value`, `data-progress-max-value`, `data-progress-low-value`, `data-progress-high-value`, `data-progress-optimum-value`, `data-progress-indeterminate-value`, `data-progress-target="fill"|"meter"`) are emitted by Tasks 5–7's Rails renderers and asserted by Task 8's accessibility fixtures.
- `progress:changed` detail shape `{ value, min, max }` — declared in Task 1, documented identically in Task 4's doc.
- `Indicator#render(variant:, color:, pulse:, **kwargs, &block)` — signature used identically in Task 9 (component + helper), Task 10 (sandbox usage), Task 11 (timeline refactor call sites), Task 12 (doc examples).
- `list-item` controller: `toggle()` / `checkedValueChanged(checked)` / targets `checkbox`, `content` / value `checked` — used identically in Task 13 (JS), Task 14 (doc), Task 15 (Rails renderer emits `data-list-item-target="checkbox"|"content"`, `data-list-item-checked-value`, `data-action="click->list-item#toggle"`), Task 16 (sandbox usage).
- `List::Item#render(content = nil, checked: nil, interactive: false, **kwargs, &block)` — signature consistent across Task 15 (implementation + tests), Task 16 (sandbox), Task 17 (docs).

No naming or signature drift found between tasks.
