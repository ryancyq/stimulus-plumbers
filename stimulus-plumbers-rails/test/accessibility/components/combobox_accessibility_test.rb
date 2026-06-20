# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class ComboboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/combobox"
  end

  def test_passes_wcag_with_all_comboboxes_closed
    assert_accessible context: "#combobox"
  end

  def test_passes_wcag_with_combobox_date_open
    find("input[aria-label='Birthday']").click

    assert_accessible context: "#combobox-date"
  end

  def test_passes_wcag_with_time_picker_open
    find("input[aria-label='Meeting Time']").click

    assert_accessible context: "#combobox-time"
  end

  def test_passes_wcag_with_dropdown_open
    find("#combobox-dropdown input[aria-label='Country']").click

    assert_accessible context: "#combobox-dropdown"
  end

  def test_passes_wcag_with_typeahead_open
    find("input[aria-label='City']").click

    assert_accessible context: "#combobox-typeahead"
  end

  def test_passes_wcag_with_combobox_date_error
    assert_accessible context: "#combobox-date-error"
  end

  def test_passes_wcag_with_combobox_date_error_open
    find("#combobox-date-error input[role='combobox']").click

    assert_accessible context: "#combobox-date-error"
  end

  def test_passes_wcag_with_time_picker_error
    assert_accessible context: "#combobox-time-error"
  end

  def test_passes_wcag_with_time_picker_error_open
    find("#combobox-time-error input[role='combobox']").click

    assert_accessible context: "#combobox-time-error"
  end

  def test_passes_wcag_with_dropdown_error
    assert_accessible context: "#combobox-dropdown-error"
  end

  def test_passes_wcag_with_dropdown_error_open
    find("#combobox-dropdown-error input[role='combobox']").click

    assert_accessible context: "#combobox-dropdown-error"
  end

  def test_passes_wcag_with_typeahead_error
    assert_accessible context: "#combobox-typeahead-error"
  end

  def test_passes_wcag_with_typeahead_error_open
    find("#combobox-typeahead-error input[role='combobox']").click

    assert_accessible context: "#combobox-typeahead-error"
  end

  def test_passes_wcag_with_dropdown_pre_selected_open
    find("#combobox-dropdown-selected input[role='combobox']").click

    assert_accessible context: "#combobox-dropdown-selected"
  end

  def test_passes_wcag_with_dropdown_disabled_option_open
    find("#combobox-dropdown-disabled input[role='combobox']").click

    assert_accessible context: "#combobox-dropdown-disabled"
  end
end
