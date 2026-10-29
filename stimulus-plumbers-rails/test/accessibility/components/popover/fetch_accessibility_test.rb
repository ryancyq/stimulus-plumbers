# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class PopoverFetchAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover/fetch"
  end

  def test_passes_wcag_closed
    assert_sections_accessible
  end

  def test_loads_the_region_when_the_panel_opens
    click_button "Account"

    assert_selector "#popover-fetch [role='region'] a", text: "Profile"
    assert_no_selector "#account-menu[aria-busy]"
    assert_equal "", find("#popover-fetch [role='status']", visible: :all).text
    assert_accessible context: "#popover-fetch"
  end

  def test_a_failed_load_reports_it_in_the_status
    click_button "Billing"

    assert_selector "#popover-fetch-error [role='status']", text: "Content could not be loaded"
    assert_accessible context: "#popover-fetch-error"
  end
end
