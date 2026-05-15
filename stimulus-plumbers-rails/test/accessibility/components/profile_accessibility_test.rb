# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ProfileAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag
    visit "/components/profile"

    assert_accessible
  end

  def test_passes_wcag_with_popover_open
    visit "/components/profile"
    click_button "More options"

    assert_accessible
  end

  def test_passes_wcag_with_datepicker_open
    visit "/components/profile"
    find("input[aria-label='Date']").click

    assert_accessible
  end

  def test_passes_wcag_after_datepicker_navigates_to_previous_month
    visit "/components/profile"

    find("input[aria-label='Date']").click
    find("button[aria-label='Previous Month']").click

    assert_accessible
  end

  def test_passes_wcag_after_datepicker_navigates_to_next_month
    visit "/components/profile"

    find("input[aria-label='Date']").click
    find("button[aria-label='Next Month']").click

    assert_accessible
  end
end
