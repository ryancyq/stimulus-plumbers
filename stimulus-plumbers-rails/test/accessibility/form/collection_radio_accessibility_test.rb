# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CollectionRadioAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/collection_radio"
  end

  def test_default_inline_passes_wcag
    assert_accessible context: "#collection-radio-default-inline"
  end

  def test_default_stacked_passes_wcag
    assert_accessible context: "#collection-radio-default-stacked"
  end

  def test_button_inline_passes_wcag
    assert_accessible context: "#collection-radio-button-inline"
  end

  def test_button_stacked_passes_wcag
    assert_accessible context: "#collection-radio-button-stacked"
  end

  def test_card_inline_passes_wcag
    assert_accessible context: "#collection-radio-card-inline"
  end

  def test_card_stacked_passes_wcag
    assert_accessible context: "#collection-radio-card-stacked"
  end

  def test_error_passes_wcag
    assert_accessible context: "#collection-radio-error"
  end

  def test_card_variants_passes_wcag
    assert_accessible context: "#collection-radio-card-variants"
  end
end
