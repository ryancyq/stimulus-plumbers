# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class SearchAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/search"
  end

  # ── WCAG / axe ────────────────────────────────────────────────────────────

  def test_passes_wcag_with_empty_input
    assert_accessible
  end

  def test_passes_wcag_with_populated_input
    fill_in "Search", with: "hello"

    assert_accessible
  end

  # ── clear button visibility ───────────────────────────────────────────────

  def test_clear_button_hidden_when_input_is_empty
    assert_selector "button[aria-label='Clear search']", visible: :hidden
  end

  def test_clear_button_visible_when_input_has_value
    fill_in "Search", with: "hello"

    assert_selector "button[aria-label='Clear search']"
  end

  def test_clear_button_hidden_again_after_input_cleared_by_typing
    fill_in "Search", with: "hello"
    field = find("input[type='search']")
    "hello".length.times { field.send_keys(:backspace) }

    assert_selector "button[aria-label='Clear search']", visible: :hidden
  end

  # ── clear action ──────────────────────────────────────────────────────────

  def test_clicking_clear_empties_the_input
    fill_in "Search", with: "hello"
    find("button[aria-label='Clear search']").click

    assert_field "Search", with: ""
  end

  def test_clicking_clear_hides_the_clear_button
    fill_in "Search", with: "hello"
    find("button[aria-label='Clear search']").click

    assert_selector "button[aria-label='Clear search']", visible: :hidden
  end

  def test_focus_returns_to_input_after_clear
    fill_in "Search", with: "hello"
    find("button[aria-label='Clear search']").click

    input_id = find("input[type='search']")[:id]

    assert_equal input_id, evaluate_script("document.activeElement.id")
  end
end
