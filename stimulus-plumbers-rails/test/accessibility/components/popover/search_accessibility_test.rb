# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class SearchAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover/search"
  end

  def test_passes_wcag_with_empty_input
    assert_accessible context: "#search-default"
  end

  def test_passes_wcag_with_populated_input
    within("#search-default") { fill_in "Search", with: "hello" }

    assert_accessible context: "#search-default"
  end

  def test_passes_wcag_with_error
    assert_accessible context: "#search-error"
  end

  def test_clear_button_hidden_when_input_is_empty
    within("#search-default") do
      assert_selector "button[aria-label='Clear search']", visible: :hidden
    end
  end

  def test_clear_button_visible_when_input_has_value
    within("#search-default") { fill_in "Search", with: "hello" }

    within("#search-default") do
      assert_selector "button[aria-label='Clear search']"
    end
  end

  def test_clear_button_hidden_again_after_input_cleared_by_typing
    within("#search-default") do
      fill_in "Search", with: "hello"
      field = find("input[role='combobox']")
      "hello".length.times { field.send_keys(:backspace) }

      assert_selector "button[aria-label='Clear search']", visible: :hidden
    end
  end

  def test_clicking_clear_empties_the_input
    within("#search-default") { fill_in "Search", with: "hello" }
    within("#search-default") { find("button[aria-label='Clear search']").click }

    within("#search-default") { assert_field "Search", with: "" }
  end

  def test_clicking_clear_hides_the_clear_button
    within("#search-default") { fill_in "Search", with: "hello" }
    within("#search-default") { find("button[aria-label='Clear search']").click }

    within("#search-default") do
      assert_selector "button[aria-label='Clear search']", visible: :hidden
    end
  end

  def test_focus_returns_to_input_after_clear
    within("#search-default") { fill_in "Search", with: "hello" }
    within("#search-default") { find("button[aria-label='Clear search']").click }

    input_id = find("#search-default input[role='combobox']")[:id]

    assert_equal input_id, evaluate_script("document.activeElement.id")
  end
end
