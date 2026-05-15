# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ComboboxAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag_with_all_comboboxes_closed
    visit "/components/combobox"

    assert_accessible
  end

  def test_passes_wcag_with_date_picker_open
    visit "/components/combobox"
    find("input[aria-label='Birthday']").click

    assert_accessible
  end

  def test_passes_wcag_with_time_picker_open
    visit "/components/combobox"
    find("input[aria-label='Meeting Time']").click

    assert_accessible
  end

  def test_passes_wcag_with_dropdown_open
    visit "/components/combobox"
    find("input[aria-label='Country']").click

    assert_accessible
  end

  def test_passes_wcag_with_autocomplete_open
    visit "/components/combobox"
    find("input[aria-label='City']").click

    assert_accessible
  end
end
