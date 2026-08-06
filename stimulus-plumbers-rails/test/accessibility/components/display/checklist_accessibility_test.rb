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
    within("#checklist-default") { check("Buy milk", allow_label_click: true) }

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

    assert_accessible context: "#checklist-select-all"
  end

  def test_clicking_master_with_mixed_state_checks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: true)
      assert_field("Walk the dog", checked: true)
    end
  end

  def test_clicking_master_with_all_checked_unchecks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)
      uncheck("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: false)
      assert_field("Walk the dog", checked: false)
    end
  end

  def test_clicking_master_twice_unchecks_all_interactive_items
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)
      uncheck("Select all", allow_label_click: true)

      assert_field("Buy milk", checked: false)
      assert_field("Walk the dog", checked: false)
    end
  end

  def test_checking_all_items_individually_checks_the_master
    within("#checklist-select-all") do
      check("Walk the dog", allow_label_click: true)

      assert_field("Select all", checked: true)
    end
  end

  def test_readonly_item_unaffected_by_select_all
    within("#checklist-select-all") do
      check("Select all", allow_label_click: true)

      assert_field("Archived (read-only)", checked: false, disabled: true)
    end
  end

  def test_master_toggles_via_space_key
    within("#checklist-select-all") do
      # Cuprite's send_keys click-to-focuses before sending the key, which on a real
      # <input type="checkbox"> double-toggles (click flips it, then Space flips it back)
      # and nets out to no visible change. An explicit .click first establishes focus (and
      # checked state) so the subsequent Space keypress is the toggle under test.
      field = find_field("Select all")
      field.click
      field.send_keys(:space)

      assert_field("Buy milk", checked: true)
      assert_field("Walk the dog", checked: true)
    end
  end
end
