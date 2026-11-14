# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

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

  def test_segmented_progress_passes_wcag
    assert_accessible context: "#progress-segmented"
  end

  def test_segmented_strength_ramp_passes_wcag
    assert_accessible context: "#progress-segmented-ramp"
  end

  def test_segmented_indeterminate_with_3_segments_passes_wcag
    assert_accessible context: "#progress-segmented-indeterminate-3"
  end

  def test_segmented_indeterminate_passes_wcag
    assert_accessible context: "#progress-segmented-indeterminate"
  end

  def test_segmented_indeterminate_with_10_segments_passes_wcag
    assert_accessible context: "#progress-segmented-indeterminate-10"
  end

  def test_progress_ring_passes_wcag
    assert_accessible context: "#progress-ring"
  end

  def test_large_progress_ring_passes_wcag
    assert_accessible context: "#progress-ring-lg"
  end

  def test_indeterminate_progress_ring_passes_wcag
    assert_accessible context: "#progress-ring-indeterminate"
  end

  def test_meter_passes_wcag
    assert_accessible context: "#progress-meter"
  end

  def test_bar_with_percent_readout_passes_wcag
    assert_accessible context: "#progress-bar-percent"
  end

  def test_bar_with_value_max_readout_passes_wcag
    assert_accessible context: "#progress-bar-value-max"
  end

  def test_bar_with_readout_at_a_low_value_passes_wcag
    assert_accessible context: "#progress-bar-percent-low"
  end

  def test_bar_with_readout_at_the_maximum_passes_wcag
    assert_accessible context: "#progress-bar-percent-full"
  end

  def test_bar_with_readout_crossing_the_fill_passes_wcag
    assert_accessible context: "#progress-bar-percent-crossing"
  end

  def test_bar_with_readout_beside_the_track_passes_wcag
    assert_accessible context: "#progress-bar-readout-outside"
  end
end
