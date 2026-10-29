# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class FloatingLabelAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/form/floating_label"
  end

  def test_every_section_passes_wcag
    assert_sections_accessible
  end

  def test_filled_revealable_revealed_passes_wcag
    find("#floating-filled-revealable button[aria-label='Show password']").click

    assert_selector "#floating-filled-revealable input[type='text']"
    assert_accessible context: "#floating-filled-revealable"
  end
end
