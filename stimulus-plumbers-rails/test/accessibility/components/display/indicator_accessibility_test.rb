# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class IndicatorAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/indicator"
  end

  def test_indicator_paired_with_a_label_passes_wcag
    %w[#indicator-dot #indicator-pulse #indicator-badge].each { |section| assert_accessible context: section }
  end

  def test_indicator_without_a_label_fails_wcag
    violations = axe_violations("#indicator-unpaired")

    assert_equal ["role-img-alt"], violations.pluck("id")
  end
end
