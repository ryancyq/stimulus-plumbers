# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class IndicatorAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/indicator"
  end

  def test_labeled_dot_passes_wcag
    assert_accessible context: "#indicator-dot"
  end

  def test_labeled_pulse_passes_wcag
    assert_accessible context: "#indicator-pulse"
  end

  def test_labeled_badge_passes_wcag
    assert_accessible context: "#indicator-badge"
  end

  def test_indicator_without_a_label_fails_wcag
    violations = axe_violations("#indicator-unpaired")

    assert_equal ["role-img-alt"], violations.pluck("id")
  end
end
