# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProfileAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/showcase/profile"
  end

  def test_passes_wcag
    assert_accessible context: "#profile"
  end

  def test_passes_wcag_with_popover_open
    click_button "More options"

    assert_accessible context: "#profile"
  end

  def test_passes_wcag_with_datepicker_open
    find("input[aria-label='Date']").click

    assert_accessible context: "#profile"
  end
end
