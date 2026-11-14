# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class RangeFieldAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/range"
  end

  def test_default_passes_wcag
    assert_accessible context: "#range-field-default"
  end

  def test_percent_readout_passes_wcag
    assert_accessible context: "#range-field-readout"
  end

  def test_disabled_passes_wcag
    assert_accessible context: "#range-field-disabled"
  end

  def test_at_minimum_passes_wcag
    assert_accessible context: "#range-field-min"
  end

  def test_at_maximum_passes_wcag
    assert_accessible context: "#range-field-max"
  end
end
