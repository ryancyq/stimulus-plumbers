# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CollectionCheckboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/collection_checkbox"
  end

  def test_default_inline_passes_wcag
    assert_accessible context: "#collection-checkbox-default-inline"
  end

  def test_default_stacked_passes_wcag
    assert_accessible context: "#collection-checkbox-default-stacked"
  end

  def test_button_inline_passes_wcag
    assert_accessible context: "#collection-checkbox-button-inline"
  end

  def test_button_stacked_passes_wcag
    assert_accessible context: "#collection-checkbox-button-stacked"
  end

  def test_card_inline_passes_wcag
    assert_accessible context: "#collection-checkbox-card-inline"
  end

  def test_card_stacked_passes_wcag
    assert_accessible context: "#collection-checkbox-card-stacked"
  end

  def test_error_passes_wcag
    assert_accessible context: "#collection-checkbox-error"
  end
end
