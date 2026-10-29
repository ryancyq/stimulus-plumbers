# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class SingleCheckboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/single_checkbox"
  end

  def test_default_passes_wcag
    assert_accessible context: "#single-checkbox-default"
  end

  def test_hint_passes_wcag
    assert_accessible context: "#single-checkbox-hint"
  end

  def test_error_passes_wcag
    assert_accessible context: "#single-checkbox-error"
  end

  def test_required_passes_wcag
    assert_accessible context: "#single-checkbox-required"
  end
end
