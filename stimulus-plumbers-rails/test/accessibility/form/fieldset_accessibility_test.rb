# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FieldsetAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/fieldset"
  end

  def test_radio_passes_wcag
    assert_accessible context: "#fieldset-radio"
  end

  def test_radio_with_error_passes_wcag
    assert_accessible context: "#fieldset-radio-error"
  end

  def test_radio_required_passes_wcag
    assert_accessible context: "#fieldset-radio-required"
  end

  def test_radio_with_hint_passes_wcag
    assert_accessible context: "#fieldset-radio-hint"
  end

  def test_checkbox_passes_wcag
    assert_accessible context: "#fieldset-checkbox"
  end

  def test_checkbox_with_error_passes_wcag
    assert_accessible context: "#fieldset-checkbox-error"
  end

  def test_checkbox_required_passes_wcag
    assert_accessible context: "#fieldset-checkbox-required"
  end

  def test_checkbox_with_hint_passes_wcag
    assert_accessible context: "#fieldset-checkbox-hint"
  end
end
