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
