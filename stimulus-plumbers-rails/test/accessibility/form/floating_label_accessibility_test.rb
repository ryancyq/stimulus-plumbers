# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FloatingLabelAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/floating_label"
  end

  def test_filled_optional_passes_wcag
    assert_accessible context: "#floating-filled-optional"
  end

  def test_filled_hint_passes_wcag
    assert_accessible context: "#floating-filled-hint"
  end

  def test_filled_passes_wcag
    assert_accessible context: "#floating-filled"
  end

  def test_filled_error_passes_wcag
    assert_accessible context: "#floating-filled-error"
  end

  def test_outlined_passes_wcag
    assert_accessible context: "#floating-outlined"
  end

  def test_outlined_error_passes_wcag
    assert_accessible context: "#floating-outlined-error"
  end

  def test_outlined_revealable_passes_wcag
    assert_accessible context: "#floating-outlined-revealable"
  end

  def test_filled_revealable_passes_wcag
    assert_accessible context: "#floating-filled-revealable"
  end

  def test_standard_passes_wcag
    assert_accessible context: "#floating-standard"
  end

  def test_standard_error_passes_wcag
    assert_accessible context: "#floating-standard-error"
  end

  def test_filled_revealable_revealed_passes_wcag
    find("#floating-filled-revealable button[aria-label='Show password']").click

    assert_selector "#floating-filled-revealable input[type='text']"
    assert_accessible context: "#floating-filled-revealable"
  end
end
