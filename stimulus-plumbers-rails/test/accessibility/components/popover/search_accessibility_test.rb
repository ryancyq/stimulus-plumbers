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

    assert_selector "#search-default [data-input-clearable-target='clear']", visible: true
    assert_accessible context: "#search-default"
  end

  def test_passes_wcag_with_error
    assert_accessible context: "#search-error"
  end

  def test_passes_wcag_with_suggestions_open
    find("#search-suggestions [role='combobox']").send_keys("S")

    assert_selector "#search-suggestions [role='combobox'][aria-expanded='true']"
    assert_accessible context: "#search-suggestions"
  end

  def test_escape_closes_suggestions_without_clearing
    find("#search-suggestions [role='combobox']").send_keys("Se", :escape)

    assert_selector "#search-suggestions [role='combobox'][aria-expanded='false']"
    assert_field "City", with: "Se"
  end

  def test_a_second_escape_clears_the_search
    find("#search-suggestions [role='combobox']").send_keys("Se", :escape, :escape)

    assert_field "City", with: ""
  end

  def test_focus_returns_to_input_after_clear
    within("#search-default") { fill_in "Search", with: "hello" }
    within("#search-default") { find("button[aria-label='Clear search']").click }

    input_id = find("#search-default input[role='combobox']")[:id]

    assert_equal input_id, evaluate_script("document.activeElement.id")
  end
end
