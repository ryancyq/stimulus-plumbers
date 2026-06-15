# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FloatingLabelAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/floating_label"
  end

  def test_filled_passes_wcag
    assert_accessible context: "#floating-label-filled"
  end

  def test_filled_optional_passes_wcag
    assert_accessible context: "#floating-label-filled-optional"
  end

  def test_filled_with_hint_passes_wcag
    assert_accessible context: "#floating-label-filled-hint"
  end

  def test_outlined_passes_wcag
    assert_accessible context: "#floating-label-outlined"
  end

  def test_standard_passes_wcag
    assert_accessible context: "#floating-label-standard"
  end

  def test_filled_with_error_passes_wcag
    assert_accessible context: "#floating-label-filled-error"
  end
end
