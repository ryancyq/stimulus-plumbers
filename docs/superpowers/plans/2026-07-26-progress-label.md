# Progress labelling Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** An on-screen value readout on the progress bar (`format:`), a form-field path
(`f.field(as: :progress)`) that supplies the visible name via the existing label machinery, and
`<input type="range">` adopting the bar's track/fill visuals (Tasks 7–8).

**Architecture:** Two independent concerns — the *name* comes from the form field's label via
`aria-labelledby`; the *value readout* is an `aria-hidden` span centered over the track, driven by
a new `format` Stimulus value. `sp_progress_bar`'s no-readout output is unchanged byte for byte.
Spec: `docs/superpowers/specs/2026-07-26-progress-label-design.md`.

**Tech Stack:** Stimulus + Vitest (`stimulus-plumbers/`), Rails + minitest (`stimulus-plumbers-rails/`),
Tailwind v4 + minitest + Playwright (`stimulus-plumbers-tailwind/`).

## Global Constraints

- Run each package's checks synchronously from that package's directory; never background or tail.
  - `stimulus-plumbers/`: `npm test`, `npm run lint`, `npm run format:check`
  - `stimulus-plumbers-rails/`: `rake test:unit`, `rake test:accessibility`, `rake rubocop`
  - `stimulus-plumbers-tailwind/`: `rake test:unit`, `rake rubocop`, `node --run test:snapshots`
- **Never run `node --run test:snapshots:update`** — the user does this (tailwind CLAUDE.md).
- Import statements inside `src/` must not end with `.js`.
- Tests assert semantic tokens and observable outcomes, never CSS mechanism or spacing magic
  numbers (repo CLAUDE.md "Test use cases, not implementation").
- Never use `I18n.t(...)` in tests — assert the English literal.
- Sandbox models: one model per use case, never a grab-bag fixture. A view may only bind
  attributes its backing model declares.
- Task ordering matters: Task 1 (JS) defines the DOM contract every later task renders against.
  Tasks 7–8 (range) are independent of 1–6 and come after — range keeps a normal `<label for>` and
  never touches the non-labelable branch.

---

### Task 1: `format` value + `value` target on the progress controller

**Files:**
- Modify: `stimulus-plumbers/src/accessibility/aria.js`, `stimulus-plumbers/src/controllers/progress_controller.js`
- Test: `stimulus-plumbers/tests/unit/accessibility/aria.test.js` (append), `stimulus-plumbers/tests/unit/controllers/progress_controller.test.js` (append)

**Interfaces:**
- Consumes: nothing new.
- Produces: `setValueText(element, value)` from `aria.js`; controller target `value`, controller
  value `format` (String, default `''`). Tasks 2 and 3 render markup against this contract.

- [ ] **Step 1: Write the failing tests**

Append to `tests/unit/accessibility/aria.test.js` — mirror the existing `setValueNow` describe
block, including its null-clears-the-attribute case:

```js
describe('setValueText', () => {
  it('sets aria-valuetext', () => {
    const el = document.createElement('div')
    setValueText(el, '45 / 100')
    expect(el.getAttribute('aria-valuetext')).toBe('45 / 100')
  })

  it('removes aria-valuetext when null', () => {
    const el = document.createElement('div')
    el.setAttribute('aria-valuetext', '45 / 100')
    setValueText(el, null)
    expect(el.hasAttribute('aria-valuetext')).toBe(false)
  })
})
```

Append to `tests/unit/controllers/progress_controller.test.js`, reusing the file's existing
fixture/mount helper:

```js
describe('value readout', () => {
  it('renders the percentage when format is percent', async () => {
    // bar at 45/100 with a value target
    expect(valueTarget.textContent).toBe('45%')
  })

  it('renders the raw value when format is value', async () => {
    expect(valueTarget.textContent).toBe('45')
  })

  it('renders value and max when format is value_max', async () => {
    expect(valueTarget.textContent).toBe('45 / 100')
  })

  it('updates the readout when setValue is called', async () => {
    controller.setValue(80)
    expect(valueTarget.textContent).toBe('80%')
  })

  it('leaves aria-valuetext unset for percent', async () => {
    expect(element.hasAttribute('aria-valuetext')).toBe(false)
  })

  it('sets aria-valuetext for value_max', async () => {
    expect(element.getAttribute('aria-valuetext')).toBe('45 / 100')
  })

  it('clears the readout and aria-valuetext while indeterminate', async () => {
    expect(valueTarget.textContent).toBe('')
    expect(element.hasAttribute('aria-valuetext')).toBe(false)
  })

  it('renders nothing extra when no value target is present', async () => {
    // existing bar markup, unchanged — no throw, fill width still set
    expect(fillTarget.style.width).toBe('45%')
  })
})

// Normative formatting — these must match the Ruby cases in Task 2 exactly.
describe('readout formatting', () => {
  it('accounts for a non-zero minimum', async () => {
    // value 15, min 10, max 20
    expect(valueTarget.textContent).toBe('50%')
  })

  it('rounds to a whole number', async () => {
    // value 1, max 3
    expect(valueTarget.textContent).toBe('33%')
  })

  it('is zero percent when the range is empty', async () => {
    // value 5, min 5, max 5 — no NaN, no division by zero
    expect(valueTarget.textContent).toBe('0%')
  })

  // Must use an initially out-of-range attribute, NOT setValue() — setValue already clamps,
  // so a setValue-based test passes even when percent()/formattedValue() read the raw value.
  it('clamps a value that arrives out of range in the markup', async () => {
    // data-progress-current-value="150" data-progress-max-value="100"
    expect(valueTarget.textContent).toBe('100%')
    expect(fillTarget.style.width).toBe('100%')
    expect(element.getAttribute('aria-valuenow')).toBe('100')
  })

  it('clamps a value below the minimum', async () => {
    // data-progress-current-value="-10" data-progress-min-value="0"
    expect(valueTarget.textContent).toBe('0%')
    expect(fillTarget.style.width).toBe('0%')
    expect(element.getAttribute('aria-valuenow')).toBe('0')
  })

  it('renders integral values without a decimal point', async () => {
    // value 45.0, max 100.0, format value_max
    expect(valueTarget.textContent).toBe('45 / 100')
  })
})
```

- [ ] **Step 2: Run tests to verify they fail**

Run from `stimulus-plumbers/`: `npm test -- tests/unit/accessibility/aria.test.js tests/unit/controllers/progress_controller.test.js`
Expected: FAIL — `setValueText is not a function`, `textContent` empty.

- [ ] **Step 3: Implement**

In `src/accessibility/aria.js`, after `setValueNow` (line 123). It must mirror `setValueNow`'s
remove-on-null form, **not** delegate straight to `setAriaState` — `setAriaState` calls
`value.toString()` (`aria.js:47`) and throws on null:

```js
/**
 * Set aria-valuetext, or remove it when value is null/undefined (e.g. indeterminate progress)
 */
export const setValueText = (element, value) =>
  value == null ? element.removeAttribute('aria-valuetext') : setAriaState(element, 'aria-valuetext', value);
```

In `src/controllers/progress_controller.js` — `FORMATS` mirrors `ProgressBar::FORMATS` in Task 2:

```js
import { setValueMin, setValueMax, setValueNow, setValueText } from '../accessibility/aria';

const FORMATS = ['percent', 'value', 'value_max'];

  static targets = ['fill', 'meter', 'value'];
  static values = {
    // …existing…
    format: { type: String, default: '' },
  };
```

In `render()`, inside the shared `ring`/`bar`/`segmented` branch, after the `setValueNow` line:

```js
        this.renderValueText();
```

Add the two methods after `percent()`:

Clamping is global, per the spec — `currentValue` can arrive out of range from the initial
attribute, not just from `setValue()`. Change `percent()` to read the clamped value:

```js
  percent() {
    const range = this.maxValue - this.minValue;
    return range <= 0 ? 0 : ((this.clamp(this.currentValue) - this.minValue) / range) * 100;
  }
```

and in `render()`, write the clamped value to `aria-valuenow` (currently raw — an `aria-valuenow`
outside `[valuemin, valuemax]` is invalid):

```js
        setValueNow(this.element, this.indeterminateValue ? null : this.clamp(this.currentValue));
```

That single change also fixes `renderBar` and `renderSegmented`, which both consume `percent()`.

```js
  // Mirrors the server-rendered initial text; keep the cases in sync with ProgressBar#value_text.
  // Integral floats render without a decimal point so 45.0 matches Ruby's "45".
  formattedValue() {
    const n = this.clamp(this.currentValue);
    switch (this.formatValue) {
      case 'percent':
        return `${Math.round(this.percent())}%`;
      case 'value':
        return `${n}`;
      case 'value_max':
        return `${n} / ${this.maxValue}`;
      default:
        return '';
    }
  }

  // `percent` leaves aria-valuetext unset — AT already announces aria-valuenow as a percentage.
  // Unknown formats are rejected server-side; here they only reach us from hand-written markup,
  // so bail rather than blanking whatever text the author rendered.
  renderValueText() {
    if (!this.hasValueTarget || !FORMATS.includes(this.formatValue)) return;
    const text = this.indeterminateValue ? '' : this.formattedValue();
    this.valueTarget.textContent = text;
    if (this.formatValue === 'percent') return;
    setValueText(this.element, text || null);
  }
```

- [ ] **Step 4: Run tests and lint**

Run: `npm test`, then `npm run lint && npm run format:check`.
Expected: PASS, including the pre-existing progress tests untouched.

- [ ] **Step 5: Commit**

```bash
git add src/accessibility/aria.js src/controllers/progress_controller.js tests/unit/accessibility/aria.test.js tests/unit/controllers/progress_controller.test.js
git commit -m "feat: progress value readout via format value"
```

---

### Task 2: `format:` on `sp_progress_bar`

**Files:**
- Modify: `stimulus-plumbers-rails/lib/stimulus_plumbers/components/progress_bar.rb`,
  `lib/stimulus_plumbers/helpers/progress_helper.rb`, `lib/stimulus_plumbers/themes/schema.rb`
- Test: `test/stimulus_plumbers/components/progress_bar_test.rb` (append)

**Interfaces:**
- Consumes: the Task 1 DOM contract (`data-progress-target="value"`, `data-progress-format-value`).
- Produces: `sp_progress_bar(format:)`; theme keys `progress_bar_value` (new) and `progress_bar`
  gaining `labelled:`. Task 4 styles them; Task 3 calls the same component.

- [ ] **Step 1: Write the failing tests**

Append to `test/stimulus_plumbers/components/progress_bar_test.rb`, following the file's existing
`assert_css` / `doc` helpers:

```ruby
  def test_no_readout_by_default
    doc = parse(render_bar(value: 45))
    assert_css doc, "[role=progressbar] [data-progress-target=fill]"
    refute_css doc, "[data-progress-target=value]"
    refute_css doc, "[data-progress-format-value]"
  end

  def test_percent_readout_is_server_rendered
    doc = parse(render_bar(value: 45, format: :percent))
    assert_equal "45%", doc.at_css("[data-progress-target=value]").text
  end

  def test_value_max_readout_is_server_rendered
    doc = parse(render_bar(value: 45, format: :value_max))
    assert_equal "45 / 100", doc.at_css("[data-progress-target=value]").text
  end

  def test_readout_is_hidden_from_assistive_technology
    doc = parse(render_bar(value: 45, format: :percent))
    assert_equal "true", doc.at_css("[data-progress-target=value]")["aria-hidden"]
  end

  def test_percent_format_does_not_set_valuetext
    doc = parse(render_bar(value: 45, format: :percent))
    assert_nil doc.at_css("[role=progressbar]")["aria-valuetext"]
  end

  def test_value_max_format_sets_valuetext
    doc = parse(render_bar(value: 45, format: :value_max))
    assert_equal "45 / 100", doc.at_css("[role=progressbar]")["aria-valuetext"]
  end

  def test_indeterminate_suppresses_readout_and_valuetext
    doc = parse(render_bar(value: 45, format: :value_max, indeterminate: true))
    assert_equal "", doc.at_css("[data-progress-target=value]").text
    assert_nil doc.at_css("[role=progressbar]")["aria-valuetext"]
  end

  def test_format_is_passed_to_the_controller
    doc = parse(render_bar(value: 45, format: :percent))
    assert_equal "percent", doc.at_css("[role=progressbar]")["data-progress-format-value"]
  end

  def test_format_with_segments_raises
    error = assert_raises(ArgumentError) { render_segmented(value: 4, segments: 5, format: :percent) }
    assert_match(/format/, error.message)
  end

  # Normative percent rules — these must match the JS cases in Task 1 exactly.
  def test_percent_accounts_for_a_non_zero_minimum
    doc = parse(render_bar(value: 15, min: 10, max: 20, format: :percent))
    assert_equal "50%", doc.at_css("[data-progress-target=value]").text
  end

  def test_percent_rounds_to_a_whole_number
    doc = parse(render_bar(value: 1, max: 3, format: :percent))
    assert_equal "33%", doc.at_css("[data-progress-target=value]").text
  end

  def test_percent_is_zero_when_the_range_is_empty
    doc = parse(render_bar(value: 5, min: 5, max: 5, format: :percent))
    assert_equal "0%", doc.at_css("[data-progress-target=value]").text
  end

  # Clamping is global — every output uses the clamped value, not just the readout.
  def test_out_of_range_value_is_clamped_everywhere
    doc = parse(render_bar(value: 150, max: 100, format: :percent))
    bar = doc.at_css("[role=progressbar]")
    assert_equal "100%", doc.at_css("[data-progress-target=value]").text
    assert_equal "100", bar["aria-valuenow"]
    assert_equal "100", bar["data-progress-current-value"]
  end

  def test_value_below_minimum_is_clamped
    doc = parse(render_bar(value: -10, min: 0, format: :percent))
    bar = doc.at_css("[role=progressbar]")
    assert_equal "0%", doc.at_css("[data-progress-target=value]").text
    assert_equal "0", bar["aria-valuenow"]
  end

  def test_unknown_format_raises
    error = assert_raises(ArgumentError) { render_bar(value: 45, format: :other) }
    assert_match(/unknown format/, error.message)
  end

  def test_false_format_raises_rather_than_rendering_a_partial_readout
    assert_raises(ArgumentError) { render_bar(value: 45, format: false) }
  end

  def test_integral_floats_render_without_a_decimal_point
    doc = parse(render_bar(value: 45.0, max: 100.0, format: :value_max))
    assert_equal "45 / 100", doc.at_css("[data-progress-target=value]").text
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run from `stimulus-plumbers-rails/`: `rake test:unit TEST=test/stimulus_plumbers/components/progress_bar_test.rb`
Expected: FAIL — unknown keyword `:format`.

- [ ] **Step 3: Implement**

`lib/stimulus_plumbers/themes/schema.rb`, in the progress block (~line 259):

```ruby
        progress_bar:       { labelled: { default: false, validate: Ranges::BOOL } }.freeze,
        progress_bar_value: {}.freeze,
```

`components/progress_bar.rb` — `render_bar` gains `format:`, and the readout renders as a sibling
of the fill:

```ruby
      FORMATS = %i[percent value value_max].freeze

      # Clamp once — the clamped value is the only one that reaches aria-valuenow, the fill,
      # the readout, and data-progress-current-value. Presence is `.nil?`, never truthiness.
      def render_bar(value:, min: 0, max: 100, indeterminate: false, format: nil, **kwargs)
        validate_format!(format)
        current = clamp(value, min, max)
        text    = value_text(format, current, min, max) unless indeterminate
        html_options = merge_html_options(
          theme.resolve(:progress_bar, labelled: !format.nil?),
          kwargs,
          progress_stimulus_data(
            value: current, min: min, max: max, variant: "bar",
            "progress-indeterminate-value": indeterminate,
            **(format.nil? ? {} : { "progress-format-value": format })
          ),
          { role: "progressbar", aria: progress_aria(value: current, min: min, max: max, indeterminate: indeterminate, text: text, format: format) }
        )
        body = format.nil? ? render_fill : template.safe_join([render_fill, render_value(text)])
        template.content_tag(:div, body, **html_options)
      end

      def validate_format!(format)
        return if format.nil? || FORMATS.include?(format.to_sym)

        raise ArgumentError, "unknown format: #{format.inspect} (expected one of #{FORMATS.join(', ')})"
      end

      # aria-hidden: the value reaches AT via aria-valuenow/aria-valuetext, not this span.
      def render_value(text)
        template.content_tag(
          :span, text,
          **merge_html_options(
            theme.resolve(:progress_bar_value),
            { data: { "progress-target": "value" }, aria: { hidden: true } }
          )
        )
      end

      # Normative — keep in sync with the progress controller's formattedValue().
      # See the spec's "Normative formatting" section; every rule here has a paired JS test.
      # `current` is already clamped by the caller.
      def value_text(format, current, min, max)
        case format&.to_sym
        when :percent   then "#{percent(current, min, max).round}%"
        when :value     then integral(current).to_s
        when :value_max then "#{integral(current)} / #{integral(max)}"
        end
      end

      def clamp(value, min, max)
        [[value, min].max, max].min
      end

      def percent(clamped, min, max)
        range = max - min
        range <= 0 ? 0 : (clamped - min).fdiv(range) * 100
      end

      # 45.0 must render as "45", not "45.0" — JS has no Float/Integer distinction.
      def integral(number)
        number % 1 == 0 ? number.to_i : number
      end
```

`render_segmented` gains the guard from the spec, before any rendering, and clamps the same way:

```ruby
        raise ArgumentError, "format: is not supported with segments:" unless format.nil?
```

with `format: nil` added to its signature purely so the guard can catch it rather than letting it
fall through `**kwargs` into an HTML attribute.

In `components/progress/shared.rb`, `progress_aria` gains the valuetext branch:

```ruby
        def progress_aria(value:, min:, max:, indeterminate: false, text: nil, format: nil)
          aria = { valuemin: min, valuemax: max }
          aria[:valuenow]  = value unless indeterminate
          # `percent` is omitted deliberately — AT announces aria-valuenow as a percentage itself.
          aria[:valuetext] = text if text && format&.to_sym != :percent
          aria
        end
```

`helpers/progress_helper.rb` — add `format: nil` to `sp_progress_bar` and forward it.

- [ ] **Step 4: Run tests and rubocop**

Run: `rake test:unit`, then `rake rubocop`.
Expected: PASS — including the existing progress tests, which must be untouched (the no-`format:`
output is unchanged).

- [ ] **Step 5: Commit**

```bash
git add lib/stimulus_plumbers/components/progress_bar.rb lib/stimulus_plumbers/components/progress/shared.rb lib/stimulus_plumbers/helpers/progress_helper.rb lib/stimulus_plumbers/themes/schema.rb test/stimulus_plumbers/components/progress_bar_test.rb
git commit -m "feat: format option on sp_progress_bar"
```

---

### Task 3: `f.field(as: :progress)`

**Files:**
- Create: `stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/progress.rb`
- Modify: `lib/stimulus_plumbers/form/field.rb`, `form/fields/renderer.rb`, `form/builder.rb`,
  `lib/stimulus_plumbers/themes/schema.rb`
- Test: `test/stimulus_plumbers/form/fields/progress_test.rb` (new),
  `test/stimulus_plumbers/form/field_test.rb` (append — non-control label branch)

**Interfaces:**
- Consumes: `Components::ProgressBar` from Task 2.
- Produces: `f.field(attribute, as: :progress, format:, segments:, max:)`; theme key
  `form_field_input_progress`.

- [ ] **Step 1: Write the failing tests**

Create `test/stimulus_plumbers/form/fields/progress_test.rb`, following `FormFields*Test` naming.
Unit tests use the `TestRecord` fixture (the one-model-per-use-case rule applies to
`test/sandbox`, not here) — add `completion` and `profile_strength` accessors to it, and take the
id prefix from whatever object name the surrounding form tests already use. The snippets below
assume `test_record_*`; adjust to match.

```ruby
  def test_label_is_not_a_label_element
    doc = parse(field(:completion, as: :progress))
    refute_css doc, "label[for]"
  end

  def test_progressbar_is_named_by_the_field_label
    doc = parse(field(:completion, as: :progress))
    label = doc.at_css("span#test_record_completion_label")
    assert_equal "Completion", label.text
    assert_equal "test_record_completion_label", doc.at_css("[role=progressbar]")["aria-labelledby"]
  end

  def test_value_comes_from_the_model_attribute
    doc = parse(field(:completion, as: :progress))   # user.completion == 45
    assert_equal "45", doc.at_css("[role=progressbar]")["aria-valuenow"]
  end

  def test_format_renders_the_readout
    doc = parse(field(:completion, as: :progress, format: :percent))
    assert_equal "45%", doc.at_css("[data-progress-target=value]").text
  end

  def test_segments_render_the_segmented_variant
    doc = parse(field(:profile_strength, as: :progress, segments: 5, max: 5))
    assert_equal "segmented", doc.at_css("[role=progressbar]")["data-progress-variant-value"]
    assert_equal 5, doc.css("[data-progress-target=fill]").length
  end

  def test_hint_is_described_by_the_progressbar
    doc = parse(field(:completion, as: :progress, hint: "Since last sync"))
    assert_equal "test_record_completion_hint", doc.at_css("[role=progressbar]")["aria-describedby"]
  end

  # Control-only attributes are meaningless on a read-only progressbar.
  def test_required_does_not_reach_the_progressbar
    doc = parse(field(:completion, as: :progress, required: true))
    bar = doc.at_css("[role=progressbar]")
    assert_nil bar["required"]
    assert_nil bar["aria-required"]
  end

  def test_errors_are_described_not_marked_invalid
    doc = parse(field(:completion, as: :progress, error: "Sync failed"))
    bar = doc.at_css("[role=progressbar]")
    assert_nil bar["aria-invalid"]
    assert_includes doc.text, "Sync failed"
    assert_includes bar["aria-describedby"].to_s, "test_record_completion_error"
  end

  def test_format_with_segments_raises_in_the_form_path
    assert_raises(ArgumentError) { field(:profile_strength, as: :progress, segments: 5, format: :percent) }
  end

  def test_floating_is_ignored_for_a_non_control_field
    doc = parse(field(:completion, as: :progress, floating: :floating_outlined))
    assert_css doc, "span#test_record_completion_label"
    refute_css doc, "[placeholder]"
  end
```

Append to `test/stimulus_plumbers/form/field_test.rb`:

```ruby
  def test_control_fields_still_render_a_label_for_attribute
    doc = parse(field(:name, as: :text))
    assert_equal "user_name", doc.at_css("label")["for"]
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `rake test:unit TEST=test/stimulus_plumbers/form/fields/progress_test.rb`
Expected: FAIL — `unknown field type: :progress`.

- [ ] **Step 3: Implement**

`form/fields/renderer.rb` — add to `FIELD`:

```ruby
          progress:       :render_progress,
```

`form/field.rb`:

```ruby
      # `for` is only valid against a labelable element (button, input, meter, output,
      # progress, select, textarea) — a div with role=progressbar is not one.
      NON_LABELABLE_TYPES = %i[progress].freeze
```

Add `labelable: true` to `initialize` (not in `OPTIONS` — it is set by the builder, not the
caller), store it, and branch the three places that assume a labelable input:

```ruby
      def render(object, attribute, input_id:, &block)
        @label ||= attribute.to_s.humanize
        # Floating needs a real input with a placeholder — non-labelable fields take the default path.
        case @labelable ? @floating : nil
        when *StimulusPlumbers::Themes::Schema::Form::Floating::Ranges::TYPE
          render_floating_field(object, attribute, input_id, &block)
        else
          render_default_field(object, attribute, input_id, &block)
        end
      end

      def field_label(input_id)
        Fields::Label.new(@template).render(
          text:     @label,
          for_id:   (input_id if @labelable),
          id:       self.class.label_id(input_id),
          required: @required,
          hidden:   @hide_label,
          tag:      @labelable ? :label : :span
        )
      end
```

and in `build_aria` / `build_html_options` (override in `Field`, or extend `Base` with the same
guard) — a read-only progressbar takes the name but none of the control-only attributes:

```ruby
      def build_aria(object, attribute, input_id)
        return super if @labelable

        # aria-invalid/aria-required are unsupported on role=progressbar; `required` on a div is
        # invalid HTML. Errors still describe the field — see the spec's suppression table.
        {
          describedby: described_by(object, attribute, input_id),
          labelledby:  self.class.label_id(input_id)
        }.compact
      end

      def build_html_options(input_id, aria)
        return super if @labelable

        { id: input_id, aria: aria }
      end
```

`described_by` already folds error ids in, so error messages keep describing the field without
`aria-invalid`. `render_errors` still runs — the message is rendered, only the invalid *state* is
dropped.

`form/builder.rb` — in `render_field`:

```ruby
        field = Field.new(@template, labelable: !Field::NON_LABELABLE_TYPES.include?(as), **field_opts)
```

and add `require_relative "fields/inputs/progress"` plus `include Fields::Inputs::Progress`.

Create `form/fields/inputs/progress.rb`, mirroring `inputs/file.rb`'s signature exactly:

```ruby
module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Progress
          private

          # A progressbar is not a form control — it submits nothing and reads its value
          # from the model attribute.
          def render_progress(attribute, html_opts, opts, error, floating: nil, segments: nil, format: nil, **kwargs)
            raise ArgumentError, "format: is not supported with segments:" if format && segments

            html_options = merge_html_options(
              theme.resolve(:form_field_input_progress),
              opts,
              html_opts,
              kwargs
            )
            value = @object.public_send(attribute)
            component = Components::ProgressBar.new(@template)
            if segments
              component.render_segmented(value: value, segments: segments, **html_options)
            else
              component.render(value: value, format: format, **html_options)
            end
          end
        end
      end
    end
  end
end
```

`themes/schema.rb` — beside `form_field_input_combobox` (~line 182):

```ruby
        form_field_input_progress: {}.freeze,
```

- [ ] **Step 4: Run tests and rubocop**

Run: `rake test:unit`, then `rake rubocop`.
Expected: PASS. The whole existing form suite must stay green — `labelable:` defaults to `true`,
so every other field type is unaffected.

- [ ] **Step 5: Commit**

```bash
git add lib/stimulus_plumbers/form lib/stimulus_plumbers/themes/schema.rb test/stimulus_plumbers/form
git commit -m "feat: progress form field type"
```

---

### Task 4: Tailwind theming

**Files:**
- Modify: `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/progress.rb`,
  `lib/stimulus_plumbers/themes/tailwind/form/input.rb`
- Test: `test/stimulus_plumbers/themes/tailwind/progress_test.rb` (append),
  `test/stimulus_plumbers/themes/tailwind/form/input_test.rb` (append)

**Interfaces:**
- Consumes: theme keys from Tasks 2 and 3.
- Produces: styling only. Task 5 screenshots it.

- [ ] **Step 1: Write the failing tests**

Per the tailwind coverage rule, `labelled:` needs both a positive and a negative case, and test
names must describe the visual outcome, not the CSS mechanism:

```ruby
  def test_bar_is_taller_when_a_readout_is_present
    assert_includes resolve(:progress_bar, labelled: true)[:classes], "h-5"
    refute_includes resolve(:progress_bar, labelled: false)[:classes], "h-5"
  end

  def test_readout_sits_over_the_full_track_not_inside_the_fill
    classes = resolve(:progress_bar_value)[:classes]
    assert_includes classes, "absolute"
    assert_includes classes, "inset-0"
  end

  def test_readout_text_is_legible_against_both_track_and_fill
    classes = resolve(:progress_bar_value)[:classes]
    assert_includes classes, "text-(--sp-color-foreground)"
    assert_includes classes, "mix-blend-difference"
  end

  def test_progress_in_a_form_field_spans_the_field_width
    assert_includes resolve(:form_field_input_progress)[:classes], "w-full"
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run from `stimulus-plumbers-tailwind/`: `rake test:unit`
Expected: FAIL — unknown theme key / unexpected argument `labelled:`.

- [ ] **Step 3: Implement**

In `tailwind/progress.rb`:

```ruby
        # Readout is centered over the whole track, so the track needs room for text.
        BAR_LABELLED = %w[h-5].freeze

        # Centered over the track, not inside the fill — legible at any value.
        # mix-blend-difference keeps it readable where the fill edge crosses the text.
        BAR_VALUE = %w[
          absolute inset-0 flex items-center justify-center
          text-xs font-medium leading-none
          text-(--sp-color-foreground) mix-blend-difference
        ].freeze
```

`BAR` keeps `relative` (already present) and drops its fixed `h-2` into the unlabelled branch:

```ruby
        def progress_bar_classes(labelled: false)
          { classes: klasses(*BAR, *(labelled ? BAR_LABELLED : %w[h-2])) }
        end

        def progress_bar_value_classes
          { classes: klasses(*BAR_VALUE) }
        end
```

In `tailwind/form/input.rb`, beside the combobox input resolver:

```ruby
        def form_field_input_progress_classes
          { classes: klasses("w-full") }
        end
```

- [ ] **Step 4: Run tests and rubocop**

Run: `rake test:unit`, then `rake rubocop`.
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/stimulus_plumbers/themes/tailwind test/stimulus_plumbers/themes/tailwind
git commit -m "feat: tailwind styling for progress readout and form field"
```

---

### Task 5: Sandboxes, a11y tests, snapshots

**Files:**
- Modify: `stimulus-plumbers-rails/test/sandbox/app/views/components/progress.html.erb`,
  `test/accessibility/components/progress_accessibility_test.rb`
- Create: `stimulus-plumbers-rails/test/sandbox/app/views/form/progress.html.erb` (+ route),
  matching a11y test
- Modify: `stimulus-plumbers-tailwind/test/sandbox/app/views/components/progress.html.erb`,
  `test/snapshots/progress.spec.js`; add the matching form sandbox page + spec

**Interfaces:** Consumes everything above. Produces coverage only.

- [ ] **Step 1: Add sandbox sections**

Both gems, component page — three new sections. Tailwind sections follow the four sandbox rules
(unique `{component}-{usecase}` id, opening `<h2>`, inner `sb-row`/`sb-col`, no nested sections):

```erb
<section id="progress-bar-percent" class="sb-section">
  <h2>Bar — percent readout</h2>
  <div class="sb-row">
    <%= sp_progress_bar(value: 45, format: :percent, aria: { label: "Upload progress" }) %>
  </div>
</section>

<section id="progress-bar-value-max" class="sb-section">
  <h2>Bar — value / max readout</h2>
  <div class="sb-row">
    <%= sp_progress_bar(value: 45, max: 100, format: :value_max, aria: { label: "Upload progress" }) %>
  </div>
</section>

<section id="progress-bar-percent-low" class="sb-section">
  <h2>Bar — percent readout at 4% (clipping check)</h2>
  <div class="sb-row">
    <%= sp_progress_bar(value: 4, format: :percent, aria: { label: "Upload progress" }) %>
  </div>
</section>
```

Form page (both gems), wrapped in `<div id="form-progress">` per the a11y wrapper convention.
Per the sandbox-models rule (one model per use case, never a grab-bag fixture), add a new
`Onboarding` model with `completion` and `profile_strength` — do not extend an unrelated model:

```ruby
# test/sandbox/app/models/onboarding.rb
class Onboarding
  include ActiveModel::Model

  attr_accessor :completion, :profile_strength
end
```

```erb
<%= sp_form_with(model: @onboarding) do |f| %>
  <%= f.field(:completion, as: :progress, format: :percent) %>
  <%= f.field(:completion, as: :progress, format: :percent, hint: "Since last sync") %>
  <%= f.field(:profile_strength, as: :progress, segments: 5, max: 5) %>
<% end %>
```

Mirror the model into the tailwind sandbox, and add the `/form/progress` route in both.

The low-value section is the one that proves the centering decision — it is the case Flowbite's
inside-the-fill markup clips.

- [ ] **Step 2: Add a11y tests**

In `stimulus-plumbers-rails/`, scoped per the convention:

```ruby
  def test_progress_bar_with_readout_is_accessible
    visit "/components/progress"
    assert_accessible context: "#progress-bar-percent"
  end

  def test_progress_form_field_is_accessible
    visit "/form/progress"
    assert_accessible context: "#form-progress"
  end
```

Run: `rake test:accessibility`. Expected: PASS. If axe reports a violation, read the HTML from the
test output first (repo CLAUDE.md).

- [ ] **Step 3: Add snapshot specs**

Append to `test/snapshots/progress.spec.js`, scoping every locator to its section id per the
snapshot convention, with filenames `{usecase}-{state}.png`:
`percent.png`, `value-max.png`, `percent-low.png`, `form-percent.png`, `form-segmented.png`.

- [ ] **Step 4: Verify**

Run from `stimulus-plumbers-tailwind/`: `node --run test:snapshots`.
Expected: the new specs fail on missing baselines. **Stop there and hand off** — the user runs
`test:snapshots:update`. All pre-existing baselines must still pass; a diff on an existing
progress screenshot means Task 4 changed the unlabelled bar and must be fixed.

- [ ] **Step 5: Commit**

```bash
git add test/
git commit -m "test: progress readout and form field coverage"
```

---

### Task 6: Docs

Per the repo doc rule these land in the *same change* as the implementation — do not defer.
No cross-doc duplication: each fact lives in exactly one place.

- [ ] **Step 1: Update each doc at its owning location**

- `stimulus-plumbers/docs/component/progress.md` — `value` row in Targets; `format` row in Values;
  note that `aria-valuetext` is set for `value`/`value_max` only; add a readout example to the
  Example HTML block.
- `stimulus-plumbers-rails/docs/component/progress.md` — `format:` row in the `sp_progress_bar`
  option table. Link to the JS doc for controller API; do not restate it.
- `stimulus-plumbers-rails/docs/component/form.md` — `progress` in the field-type list, with
  `format:`/`segments:`/`max:` and a one-line note that it is a non-control field named via
  `aria-labelledby`.
- `ARIA.md` — progress pattern: name via `aria-labelledby`, value via
  `aria-valuenow`/`aria-valuetext`, readout `aria-hidden`. This is the only place the ARIA rule is
  stated.
- `stimulus-plumbers-rails/README.md` — no new row (no new `sp_*` helper); verify the existing
  progress row still reads correctly.

- [ ] **Step 2: Verify**

Run from the repo root: `npm run format:docs:check`.
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add stimulus-plumbers/docs stimulus-plumbers-rails/docs ARIA.md
git commit -m "docs: progress readout and form field"
```

---

---

### Task 7: `<input type="range">` adopts the bar's visuals

**Files:**
- Modify: `stimulus-plumbers/src/controllers/progress_controller.js`,
  `stimulus-plumbers-rails/lib/stimulus_plumbers/form/fields/inputs/text.rb`,
  `lib/stimulus_plumbers/themes/schema.rb`,
  `stimulus-plumbers-tailwind/lib/stimulus_plumbers/themes/tailwind/form/input.rb`
- Test: `stimulus-plumbers/tests/unit/controllers/progress_controller.test.js` (append),
  `stimulus-plumbers-rails/test/stimulus_plumbers/form/fields/inputs/text_test.rb` (append),
  `stimulus-plumbers-tailwind/test/stimulus_plumbers/themes/tailwind/form/input_test.rb` (append)

**Interfaces:**
- Consumes: `Progress::BAR` color tokens from Task 4; the `value` target from Task 1.
- Produces: `form_field_input_range` theme key; a `range` variant on the progress controller.
- **API is unchanged** — `f.field(as: :range)` and `f.range_field` already exist
  (`form/fields/inputs/text.rb:17`). No new helper. Range is a form control, not a
  `sp_progress_*` component.

**Why this task exists:** range currently has no theme entry at all, so it inherits
`form_field_input`'s text-input classes (border, padding, background) on a range input. This is a
pre-existing defect, not just new styling.

- [ ] **Step 1: Write the failing tests**

Controller — the range branch must **not** write ARIA (the native input owns its own slider
semantics):

```js
describe('range variant', () => {
  it('sets the fill percentage custom property on connect', async () => {
    expect(element.style.getPropertyValue('--sp-progress-percent')).toBe('45')
  })

  it('updates the custom property on input', async () => {
    input.value = '80'
    input.dispatchEvent(new Event('input'))
    expect(element.style.getPropertyValue('--sp-progress-percent')).toBe('80')
  })

  it('does not write aria-value attributes onto a native range', async () => {
    expect(element.hasAttribute('aria-valuenow')).toBe(false)
    expect(element.hasAttribute('aria-valuemin')).toBe(false)
    expect(element.hasAttribute('aria-valuetext')).toBe(false)
  })

  it('updates the readout when present', async () => {
    input.value = '80'
    input.dispatchEvent(new Event('input'))
    expect(valueTarget.textContent).toBe('80%')
  })
})
```

Rails — range keeps an ordinary `<label for>`; it must never take the non-labelable branch. The
readout wrapper appears **only** with `format:`, and the controller must contain the `value`
target (a Stimulus target has to be a descendant of its controller element):

```ruby
  def test_range_field_keeps_a_native_label_association
    doc = parse(field(:volume, as: :range))
    assert_equal "test_record_volume", doc.at_css("label")["for"]
    refute_css doc, "[aria-labelledby]"
  end

  def test_range_without_a_readout_hosts_the_controller_on_the_input
    doc = parse(field(:volume, as: :range))
    assert_equal "progress", doc.at_css("input[type=range]")["data-controller"]
    refute_css doc, "[data-progress-target=value]"
  end

  def test_readout_is_contained_by_the_controller_element
    doc = parse(field(:volume, as: :range, format: :percent))
    host = doc.at_css("[data-controller=progress]")
    assert host.at_css("[data-progress-target=value]"), "value target must be inside the controller"
    assert host.at_css("input[type=range][data-progress-target=input]")
  end

  def test_readout_is_hidden_from_assistive_technology
    doc = parse(field(:volume, as: :range, format: :percent))
    assert_equal "true", doc.at_css("[data-progress-target=value]")["aria-hidden"]
  end

  def test_fill_percentage_is_server_rendered_on_the_input
    doc = parse(field(:volume, as: :range, format: :percent))
    assert_match(/--sp-progress-percent:\s*45/, doc.at_css("input[type=range]")["style"])
    refute_match(/--sp-progress-percent/, doc.at_css("[data-controller=progress]")["style"].to_s)
  end
```

Tailwind — visual outcome, not mechanism:

```ruby
  def test_range_track_uses_the_same_colors_as_the_progress_bar
    classes = resolve(:form_field_input_range)[:classes]
    assert_includes classes, "bg-(--sp-color-muted)"
    assert_includes classes, "accent-(--sp-color-primary)"
  end

  def test_range_does_not_inherit_text_input_chrome
    classes = resolve(:form_field_input_range)[:classes]
    refute_includes classes, "px-3"
    refute_includes classes, "border"
  end
```

- [ ] **Step 2: Run tests to verify they fail**

Run each package's unit suite. Expected: FAIL — unknown theme key, no `range` variant.

- [ ] **Step 3: Implement**

Controller — add `input` to `static targets`, and a `range` case in the `render()` switch that
returns *before* the shared `setValueMin/Max/Now` block:

```js
  // Native range owns its own slider semantics — never write aria-value* here.
  // WebKit has no filled-track pseudo-element, so the fill is a gradient driven by this property;
  // it must land on the element carrying the track background, i.e. the input itself.
  renderRange() {
    const track = this.hasInputTarget ? this.inputTarget : this.element;
    if (this.hasInputTarget) this.currentValue = Number(this.inputTarget.value);
    track.style.setProperty('--sp-progress-percent', `${this.percent()}`);
    this.renderValueText();
  }
```

Rails — `render_range_input` resolves `form_field_input_range` instead of the generic
`form_field_input`. Two shapes, per the spec's Rendered markup section:

- **no `format:`** — controller data and the custom property go directly on the `<input>`; no
  wrapper is emitted, so the no-readout output stays a bare input.
- **with `format:`** — a wrapper local to the input row hosts the controller and contains the
  input (`data-progress-target="input"`) plus the readout span. `Fields::Group` still owns the
  field root; the label still points at the input via `for=`.

In both shapes the renderer sets `style="--sp-progress-percent: N"` **on the `<input>`**, never on
the wrapper — the input carries the track gradient, and server-rendering it avoids an empty fill
on first paint. `N` uses the same normative percent calculation as Task 2.

Schema gains `form_field_input_range: {}` and `form_field_input_range_group: {}`.

Tailwind — `form_field_input_range_classes` with `appearance-none`, the shared color tokens, and
the vendor pseudo-element rules (`[&::-webkit-slider-runnable-track]`,
`[&::-webkit-slider-thumb]`, `[&::-moz-range-track]`, `[&::-moz-range-thumb]`), with the track
background a `linear-gradient` reading `--sp-progress-percent`.

- [ ] **Step 4: Verify**

`npm test` + lint in `stimulus-plumbers/`; `rake test:unit` + `rake rubocop` in both gems.

- [ ] **Step 5: Commit**

```bash
git commit -m "feat: range input adopts progress bar visuals"
```

---

### Task 8: Range coverage

**Files:** sandbox views + models in both gems, `test/accessibility/form/`, `test/snapshots/`

- [ ] **Step 1: Sandbox**

Add `volume` to the existing `Preferences` model (a volume slider is a preference — this is the
right use-case model, no new one needed). Add a range section to the form sandbox in both gems,
following the four sandbox rules:

```erb
<section id="range-volume" class="sb-section">
  <h2>Range — volume with percent readout</h2>
  <div class="sb-col">
    <%= f.field(:volume, as: :range, format: :percent, min: 0, max: 100) %>
  </div>
</section>
```

Cover at least: default, with readout, disabled, and at both extremes (0 and max) — the gradient
fill is the thing most likely to break at the boundaries.

- [ ] **Step 2: a11y test**

```ruby
  def test_range_field_is_accessible
    visit "/form/preferences"
    assert_accessible context: "#range-volume"
  end
```

- [ ] **Step 3: Snapshots**

Add specs scoped to `#range-volume`; baselines `volume.png`, `volume-min.png`, `volume-max.png`,
`volume-disabled.png`. Run `node --run test:snapshots`, expect new-baseline failures, then **stop
and hand off** — the user runs the update.

- [ ] **Step 4: Docs**

Add a range row to `stimulus-plumbers-rails/docs/component/form.md` noting `format:` support and
the cross-browser caveat. Run `npm run format:docs:check`.

- [ ] **Step 5: Commit**

```bash
git commit -m "test: range field coverage"
```

---

## Success criteria

- `sp_progress_bar(value: 45)` output is byte-identical to before this change.
- `sp_progress_bar(value: 45, format: :percent)` renders `45%` server-side, readable at 4% and
  95%, `aria-hidden`, with no `aria-valuetext`.
- `f.field(:completion, as: :progress)` renders a `<span>` label (no `for=`) and a progressbar
  named by it via `aria-labelledby`, with no `aria-invalid` and no `<label for>` pointing at a
  non-labelable element.
- `f.field(:volume, as: :range)` renders a native range input with the bar's track/fill colors, an
  ordinary `<label for>`, no `aria-*` written by the controller, and no text-input chrome.
- All three packages green: `npm test`/`lint`/`format:check`, `rake test:unit`/`test:accessibility`/
  `rubocop` in both gems, `node --run test:snapshots` clean except the new baselines.

## Deferred

Ring and meter readouts; a standalone caption-row wrapper; caller-supplied format callbacks; a
div-based `role="slider"` component; a readout that tracks the range thumb.
