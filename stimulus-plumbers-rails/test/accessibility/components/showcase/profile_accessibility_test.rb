# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ProfileAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/showcase/profile"
  end

  def test_passes_wcag
    assert_accessible context: "#profile-default"
  end

  def test_passes_wcag_with_popover_open
    click_button "More options"

    assert_selector "#profile-default :popover-open"
    assert_accessible context: "#profile-default"
  end

  def test_passes_wcag_with_date_combobox_open
    find("input[aria-label='Date']").click

    assert_selector "#profile-default input[aria-label='Date'][aria-expanded='true']"
    assert_accessible context: "#profile-default"
  end
end
