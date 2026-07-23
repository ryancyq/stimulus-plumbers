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
    assert_css doc, "div[data-progress-current-value='30']"
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

  def test_segmented_renders_one_slot_per_segment_each_with_a_fill
    doc = parse_html(renderer.render_segmented(value: 6, segments: 5, max: 10))

    assert_equal 5, doc.css("div[aria-hidden='true']").size
    assert_equal 5, doc.css("div[data-progress-target='fill']").size
  end

  def test_segmented_wires_segmented_variant_and_default_discrete_mode
    doc = parse_html(renderer.render_segmented(value: 6, segments: 5, max: 10))

    assert_css doc, "div[role='progressbar'][data-progress-variant-value='segmented']"
    assert_css doc, "div[data-progress-segment-mode-value='discrete']"
    assert_css doc, "div[aria-valuenow='6'][aria-valuemax='10']"
  end

  def test_segmented_forwards_continuous_mode
    doc = parse_html(renderer.render_segmented(value: 6, segments: 5, max: 10, mode: :continuous))

    assert_css doc, "div[data-progress-segment-mode-value='continuous']"
  end

  def test_segmented_indeterminate_omits_aria_valuenow
    doc = parse_html(renderer.render_segmented(value: 0, segments: 5, indeterminate: true))

    assert_no_css doc, "div[aria-valuenow]"
    assert_css doc, "div[data-progress-indeterminate-value='true']"
  end

  def test_segmented_without_ramp_leaves_fills_uncolored
    doc = parse_html(renderer.render_segmented(value: 6, segments: 5, max: 10))

    assert_no_css doc, "[data-intent]"
  end

  def test_strength_ramp_colors_each_slot_from_danger_to_success
    doc = parse_html(renderer.render_segmented(value: 4, segments: 5, max: 5, ramp: :strength))

    intents = doc.css("[data-progress-target='fill']").map { |el| el["data-intent"] }

    assert_equal %w[danger warning warning success success], intents
  end
end
