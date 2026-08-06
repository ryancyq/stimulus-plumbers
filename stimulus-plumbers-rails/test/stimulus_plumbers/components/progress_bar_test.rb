# frozen_string_literal: true

require "test_helper"

class ProgressBarTest < ActionView::TestCase
  # A theme predating this change: strict signatures that accept no keywords.
  LegacyTheme = Class.new(StimulusPlumbers::Themes::Base) do
    private

    def progress_bar_classes(labelled: false)
      { classes: labelled ? "bar tall" : "bar" }
    end

    def progress_bar_fill_classes
      { classes: "fill" }
    end

    def progress_bar_value_classes
      { classes: "readout" }
    end

    def progress_segment_classes
      { classes: "slot" }
    end
  end

  FillKeyTheme = Class.new(StimulusPlumbers::Themes::Base) do
    private

    def progress_bar_fill_classes
      { classes: "bar-fill" }
    end

    def progress_segment_fill_classes
      { classes: "segment-fill" }
    end
  end

  def renderer
    StimulusPlumbers::Components::ProgressBar.new(self)
  end

  def with_theme(theme)
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(theme)
    yield
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def with_legacy_theme(&block)
    with_theme(LegacyTheme.new, &block)
  end

  def with_fill_key_theme(&block)
    with_theme(FillKeyTheme.new, &block)
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

  def readout(doc)
    doc.at_css("[data-progress-target='value']")
  end

  def test_no_readout_by_default
    doc = parse_html(renderer.render(value: 45))

    assert_no_css doc, "[data-progress-target='value']"
    assert_no_css doc, "[data-progress-format-value]"
  end

  def test_percent_readout_is_server_rendered
    doc = parse_html(renderer.render(value: 45, format: :percent))

    assert_equal "45%", readout(doc).text
    assert_css doc, "div[data-progress-format-value='percent']"
  end

  def test_value_readout_is_server_rendered
    assert_equal "45", readout(parse_html(renderer.render(value: 45, format: :value))).text
  end

  def test_value_max_readout_is_server_rendered
    assert_equal "45 / 100", readout(parse_html(renderer.render(value: 45, format: :value_max))).text
  end

  def test_readout_is_hidden_from_assistive_technology
    assert_equal "true", readout(parse_html(renderer.render(value: 45, format: :percent)))["aria-hidden"]
  end

  def test_percent_format_does_not_set_valuetext
    assert_no_css parse_html(renderer.render(value: 45, format: :percent)), "div[aria-valuetext]"
  end

  def test_value_max_format_sets_valuetext
    assert_css parse_html(renderer.render(value: 45, format: :value_max)), "div[aria-valuetext='45 / 100']"
  end

  def test_indeterminate_suppresses_readout_and_valuetext
    doc = parse_html(renderer.render(value: 45, format: :value_max, indeterminate: true))

    assert_empty readout(doc).text
    assert_no_css doc, "div[aria-valuetext]"
  end

  def test_format_with_segments_raises
    error = assert_raises(ArgumentError) { renderer.render_segmented(value: 4, segments: 5, format: :percent) }

    assert_match(%r{format}, error.message)
  end

  def test_unknown_format_raises
    error = assert_raises(ArgumentError) { renderer.render(value: 45, format: :other) }

    assert_match(%r{unknown format}, error.message)
  end

  def test_false_format_raises_rather_than_rendering_a_partial_readout
    assert_raises(ArgumentError) { renderer.render(value: 45, format: false) }
  end

  def test_percent_accounts_for_a_non_zero_minimum
    assert_equal "50%", readout(parse_html(renderer.render(value: 15, min: 10, max: 20, format: :percent))).text
  end

  def test_percent_rounds_to_a_whole_number
    assert_equal "33%", readout(parse_html(renderer.render(value: 1, max: 3, format: :percent))).text
  end

  def test_percent_is_zero_when_the_range_is_empty
    assert_equal "0%", readout(parse_html(renderer.render(value: 5, min: 5, max: 5, format: :percent))).text
  end

  def test_percent_is_zero_when_max_is_below_min
    assert_equal "0%", readout(parse_html(renderer.render(value: 5, min: 10, max: 0, format: :percent))).text
  end

  def test_string_format_is_accepted
    assert_equal "45%", readout(parse_html(renderer.render(value: 45, format: "percent"))).text
  end

  def test_out_of_range_value_is_clamped_everywhere
    doc = parse_html(renderer.render(value: 150, max: 100, format: :percent))

    assert_equal "100%", readout(doc).text
    assert_css doc, "div[aria-valuenow='100']"
    assert_css doc, "div[data-progress-current-value='100']"
  end

  def test_value_below_minimum_is_clamped
    doc = parse_html(renderer.render(value: -10, min: 0, format: :percent))

    assert_equal "0%", readout(doc).text
    assert_css doc, "div[aria-valuenow='0']"
  end

  def test_integral_floats_render_without_a_decimal_point
    assert_equal "45 / 100", readout(parse_html(renderer.render(value: 45.0, max: 100.0, format: :value_max))).text
  end

  def test_segmented_rejects_a_non_positive_segment_count
    assert_raises(ArgumentError) { renderer.render_segmented(value: 1, segments: 0) }
    assert_raises(ArgumentError) { renderer.render_segmented(value: 1, segments: -1) }
  end

  def test_segmented_rejects_a_non_integer_segment_count
    assert_raises(ArgumentError) { renderer.render_segmented(value: 1, segments: 2.5) }
  end

  def test_inside_readout_shares_the_track_element
    doc  = parse_html(renderer.render(value: 45, format: :percent))
    root = doc.at_css("div[role='progressbar']")

    assert_equal root, readout(doc).parent
    assert_equal root, doc.at_css("[data-progress-target='fill']").parent
  end

  def test_outside_readout_is_a_sibling_of_the_track
    doc  = parse_html(renderer.render(value: 45, format: :percent, readout: :outside))
    root = doc.at_css("div[role='progressbar']")

    assert_equal root, readout(doc).parent
    refute_equal root, doc.at_css("[data-progress-target='fill']").parent
    assert_equal "45%", readout(doc).text
  end

  # Outside the controller element, the readout never updates.
  def test_outside_readout_and_fill_stay_within_the_controller_element
    root = parse_html(renderer.render(value: 45, format: :percent, readout: :outside)).at_css("[data-controller='progress']")

    assert_css root, "[data-progress-target='value']"
    assert_css root, "[data-progress-target='fill']"
  end

  def test_outside_readout_keeps_the_progressbar_aria_on_the_root
    doc = parse_html(renderer.render(value: 45, format: :value_max, readout: :outside))

    assert_css doc, "div[role='progressbar'][aria-valuenow='45'][aria-valuetext='45 / 100']"
    assert_equal "true", readout(doc)["aria-hidden"]
  end

  def test_readout_placement_is_ignored_without_a_format
    doc = parse_html(renderer.render(value: 45, readout: :outside))

    assert_nil readout(doc)
    assert_css doc, "div[role='progressbar'] > [data-progress-target='fill']"
  end

  # Regression: a keyword-less theme method must never be called with a keyword.
  def test_a_legacy_theme_still_styles_every_bar_element
    doc = with_legacy_theme { parse_html(renderer.render(value: 45, format: :percent)) }

    assert_css doc, ".bar"
    assert_css doc, "[data-progress-target='fill'].fill"
    assert_css doc, "[data-progress-target='value'].readout"
  end

  def test_a_legacy_theme_still_styles_an_inside_readout
    doc = with_legacy_theme { parse_html(renderer.render(value: 45, format: :percent, readout: :inside)) }

    assert_css doc, "[data-progress-target='value'].readout"
  end

  def test_a_legacy_theme_renders_a_segmented_bar_without_raising
    doc = with_legacy_theme { parse_html(renderer.render_segmented(value: 4, segments: 2)) }

    assert_css doc, "div[role='progressbar']"
    assert_equal 2, doc.css(".slot").length
  end

  def test_segment_fill_resolves_its_own_theme_key
    doc = with_fill_key_theme { parse_html(renderer.render_segmented(value: 4, segments: 2)) }

    assert_equal 2, doc.css("[data-progress-target='fill'].segment-fill").length
    assert_no_css doc, ".bar-fill"
  end

  def test_bar_fill_keeps_the_bar_theme_key
    doc = with_fill_key_theme { parse_html(renderer.render(value: 45)) }

    assert_css doc, "[data-progress-target='fill'].bar-fill"
    assert_no_css doc, ".segment-fill"
  end

  def test_unknown_readout_raises
    error = assert_raises(ArgumentError) { renderer.render(value: 45, format: :percent, readout: :above) }

    assert_match(%r{readout must be one of}, error.message)
  end
end
