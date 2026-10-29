# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ChecklistAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/checklist"
  end

  def test_default_checklist_passes_wcag
    assert_accessible context: "#checklist-default"
  end

  def test_checklist_with_description_passes_wcag
    assert_accessible context: "#checklist-with-description"
  end

  def test_read_only_checklist_passes_wcag
    assert_accessible context: "#checklist-read-only"
  end

  def test_checklist_passes_wcag_after_toggling_an_item
    within("#checklist-default") do
      check("Walk the dog", allow_label_click: true)

      assert_checked_field "Walk the dog"
    end
    assert_accessible context: "#checklist-default"
  end

  def test_select_all_checklist_passes_wcag_with_mixed_state
    within("#checklist-select-all") do
      assert_field("Select all", checked: false)
    end

    assert_accessible context: "#checklist-select-all"
  end

  def test_select_all_checklist_passes_wcag_after_click
    within("#checklist-select-all") { check("Select all", allow_label_click: true) }

    within("#checklist-select-all") { assert_checked_field "Walk the dog" }
    assert_accessible context: "#checklist-select-all"
  end

  def test_master_toggles_via_space_key
    within("#checklist-select-all") do
      # Cuprite 0.17 send_keys clicks the element first and 0.20 does not; Ferrum types into the focused element only.
      find_field("Select all").execute_script("this.focus()")
      page.driver.browser.keyboard.type(:space)

      assert_field("Buy milk", checked: true)
      assert_field("Walk the dog", checked: true)
    end
  end
end
