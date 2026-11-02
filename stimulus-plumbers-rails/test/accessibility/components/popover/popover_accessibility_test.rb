# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class PopoverAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover"
  end

  def test_passes_wcag_with_popover_closed
    assert_accessible context: "#popover"
  end

  def test_passes_wcag_with_named_region_open
    click_button "Open menu"

    assert_accessible context: "#popover"
  end

  def test_passes_wcag_with_unnamed_structural_content_open
    click_button "Open details"

    assert_accessible context: "#popover"
  end

  def test_passes_wcag_with_named_help_open
    click_button "Open help"

    assert_accessible context: "#popover"
  end
end
