# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ChoicesAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/choices"
  end

  def test_single_checkbox_passes_wcag
    assert_accessible context: "#single-checkbox"
  end

  def test_collection_checkbox_passes_wcag
    assert_accessible context: "#collection-checkbox"
  end

  def test_collection_radio_passes_wcag
    assert_accessible context: "#collection-radio"
  end

  def test_single_checkbox_with_error_passes_wcag
    assert_accessible context: "#single-checkbox-error"
  end

  def test_single_checkbox_required_passes_wcag
    assert_accessible context: "#single-checkbox-required"
  end

  def test_collection_checkbox_with_error_passes_wcag
    assert_accessible context: "#collection-checkbox-error"
  end

  def test_collection_radio_with_error_passes_wcag
    assert_accessible context: "#collection-radio-error"
  end
end
