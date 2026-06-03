# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ComboboxAccessibilityTest < ApplicationAccessibilityTestCase
  def test_passes_wcag_with_all_comboboxes_closed
    visit "/components/combobox"

    assert_accessible context: "#combobox"
  end

  def test_passes_wcag_with_date_picker_open
    visit "/components/combobox"
    find("input[aria-label='Birthday']").click

    assert_accessible context: "#combobox-date"
  end

  def test_passes_wcag_with_time_picker_open
    visit "/components/combobox"
    find("input[aria-label='Meeting Time']").click

    assert_accessible context: "#combobox-time"
  end

  def test_passes_wcag_with_dropdown_open
    visit "/components/combobox"
    find("input[aria-label='Country']").click

    assert_accessible context: "#combobox-dropdown"
  end

  def test_passes_wcag_with_typeahead_open
    visit "/components/combobox"
    find("input[aria-label='City']").click

    assert_accessible context: "#combobox-typeahead"
  end

  def test_passes_wcag_with_date_picker_error
    visit "/components/combobox"

    assert_accessible context: "#combobox-date-error"
  end

  def test_passes_wcag_with_date_picker_error_open
    visit "/components/combobox"
    find("#combobox-date-error input[role='combobox']").click

    assert_accessible context: "#combobox-date-error"
  end

  def test_passes_wcag_with_time_picker_error
    visit "/components/combobox"

    assert_accessible context: "#combobox-time-error"
  end

  def test_passes_wcag_with_time_picker_error_open
    visit "/components/combobox"
    find("#combobox-time-error input[role='combobox']").click

    assert_accessible context: "#combobox-time-error"
  end

  def test_passes_wcag_with_dropdown_error
    visit "/components/combobox"

    assert_accessible context: "#combobox-dropdown-error"
  end

  def test_passes_wcag_with_dropdown_error_open
    visit "/components/combobox"
    find("#combobox-dropdown-error input[role='combobox']").click

    assert_accessible context: "#combobox-dropdown-error"
  end

  def test_passes_wcag_with_typeahead_error
    visit "/components/combobox"

    assert_accessible context: "#combobox-typeahead-error"
  end
end
