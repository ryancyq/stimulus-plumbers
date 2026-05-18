# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class PopoverAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag_with_popover_closed
    visit "/components/popover"

    assert_accessible
  end

  def test_passes_wcag_with_popover_open
    visit "/components/popover"
    click_button "Open menu"

    assert_accessible
  end
end
