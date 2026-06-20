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

  def test_filled_with_error_passes_wcag
    assert_accessible context: "#floating-label-filled-error"
  end

  def test_filled_revealable_passes_wcag
    assert_accessible context: "#floating-label-filled-revealable"
  end

  def test_filled_revealable_revealed_passes_wcag
    find("#floating-label-filled-revealable button[aria-label='Show password']").click

    assert_accessible context: "#floating-label-filled-revealable"
  end
end
