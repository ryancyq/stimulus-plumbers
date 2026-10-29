# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class PopoverAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover"
  end

  def test_default_passes_wcag_closed
    assert_accessible context: "#popover-default"
  end

  def test_details_passes_wcag_closed
    assert_accessible context: "#popover-details"
  end

  def test_help_passes_wcag_closed
    assert_accessible context: "#popover-help"
  end

  def test_behavior_passes_wcag_closed
    assert_accessible context: "#popover-behavior"
  end

  def test_nested_passes_wcag_closed
    assert_accessible context: "#popover-nested"
  end

  def test_positioning_passes_wcag_closed
    assert_accessible context: "#popover-positioning"
  end

  def test_passes_wcag_with_named_region_open
    click_button "Open menu"

    assert_selector "#popover-default :popover-open"
    assert_accessible context: "#popover-default"
  end

  def test_passes_wcag_with_unnamed_structural_content_open
    click_button "Open details"

    assert_selector "#popover-details :popover-open"
    assert_accessible context: "#popover-details"
  end

  def test_passes_wcag_with_named_help_open
    click_button "Open help"

    assert_selector "#popover-help :popover-open"
    assert_accessible context: "#popover-help"
  end
end
