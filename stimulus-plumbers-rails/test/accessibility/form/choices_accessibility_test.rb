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
end
