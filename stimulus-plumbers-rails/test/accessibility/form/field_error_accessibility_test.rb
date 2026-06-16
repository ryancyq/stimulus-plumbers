# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FieldErrorAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/field_error"
  end

  def test_required_field_passes_wcag
    assert_accessible context: "#field-error-required"
  end

  def test_field_with_hint_passes_wcag
    assert_accessible context: "#field-error-hint"
  end

  def test_error_from_model_passes_wcag
    assert_accessible context: "#field-error-model"
  end

  def test_error_override_passes_wcag
    assert_accessible context: "#field-error-override"
  end

  def test_visually_hidden_label_passes_wcag
    assert_accessible context: "#field-error-hidden-label"
  end

  def test_textarea_with_error_passes_wcag
    assert_accessible context: "#field-error-textarea"
  end

  def test_select_with_error_passes_wcag
    assert_accessible context: "#field-error-select"
  end

  def test_checkbox_with_error_passes_wcag
    assert_accessible context: "#field-error-checkbox"
  end

  def test_file_with_error_passes_wcag
    assert_accessible context: "#field-error-file"
  end
end
