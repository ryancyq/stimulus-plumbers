# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ComboboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover/combobox"
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
    open_combobox "#combobox-dropdown"

    assert_accessible context: "#combobox-dropdown"
  end

  def test_passes_wcag_with_dropdown_active_option
    open_combobox "#combobox-dropdown"
    find("#combobox-dropdown [role='combobox']").send_keys(:down)

    assert_selector "#combobox-dropdown [role='combobox'][aria-activedescendant]"
    assert_selector "#combobox-dropdown [role='option'][aria-selected='true']", count: 1
    assert_accessible context: "#combobox-dropdown"
  end

  def test_passes_wcag_with_typeahead_open
    open_combobox "#combobox-typeahead"

    assert_accessible context: "#combobox-typeahead"
  end

  def test_passes_wcag_with_typeahead_no_results
    find("#combobox-typeahead [role='combobox']").set("zzz")

    assert_selector "#combobox-typeahead [role='combobox'][aria-expanded='true']"
    assert_selector "#combobox-typeahead [role='status']", text: "No results"
    assert_accessible context: "#combobox-typeahead"
  end

  def test_passes_wcag_with_remote_typeahead_results
    find("#combobox-typeahead-remote [role='combobox']").set("Se")

    assert_selector "#combobox-typeahead-remote [role='option']", count: 2
    assert_selector "#combobox-typeahead-remote [role='status']", exact_text: ""
    assert_accessible context: "#combobox-typeahead-remote"
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
    open_combobox "#combobox-dropdown-error"

    assert_accessible context: "#combobox-dropdown-error"
  end

  def test_passes_wcag_with_typeahead_error
    assert_accessible context: "#combobox-typeahead-error"
  end

  def test_passes_wcag_with_typeahead_error_open
    open_combobox "#combobox-typeahead-error"

    assert_accessible context: "#combobox-typeahead-error"
  end

  def test_passes_wcag_with_dropdown_pre_selected_open
    open_combobox "#combobox-dropdown-selected"

    assert_accessible context: "#combobox-dropdown-selected"
  end

  def test_passes_wcag_with_dropdown_disabled_option_open
    open_combobox "#combobox-dropdown-disabled"

    assert_accessible context: "#combobox-dropdown-disabled"
  end

  def test_passes_wcag_with_grouped_dropdown_open
    open_combobox "#combobox-dropdown-grouped"

    assert_accessible context: "#combobox-dropdown-grouped"
  end

  def test_passes_wcag_with_combobox_in_modal_open
    click_button "Choose shipping country"
    open_combobox "#combobox-modal"

    assert_accessible context: "#combobox-modal"
  end

  def test_arrow_down_opens_a_closed_dropdown_on_the_first_option
    close_with_focus "#combobox-dropdown"
    press :down

    assert_active_option "#combobox-dropdown", "Australia"
  end

  def test_arrow_up_opens_a_closed_dropdown_on_the_last_option
    close_with_focus "#combobox-dropdown"
    press :up

    assert_active_option "#combobox-dropdown", "United States"
  end

  def test_a_second_click_closes_a_dropdown
    open_combobox "#combobox-dropdown"
    find("#combobox-dropdown [role='combobox']").click

    assert_selector "#combobox-dropdown [role='combobox'][aria-expanded='false']"
  end

  def test_a_second_click_keeps_a_typeahead_open
    open_combobox "#combobox-typeahead"
    find("#combobox-typeahead [role='combobox']").click

    assert_selector "#combobox-typeahead [role='combobox'][aria-expanded='true']"
  end

  def test_enter_commits_the_active_option_and_keeps_focus
    open_combobox "#combobox-dropdown"
    press :down, :enter

    assert_committed "#combobox-dropdown", "Australia", "au"
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_clicking_an_option_commits_it_and_keeps_focus
    open_combobox "#combobox-dropdown"
    find("#combobox-dropdown [role='option']", text: "Canada").click

    assert_committed "#combobox-dropdown", "Canada", "ca"
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_escape_closes_without_committing
    open_combobox "#combobox-dropdown"
    press :down, :escape

    assert_committed "#combobox-dropdown", "", ""
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_tab_commits_the_active_option_and_moves_on
    open_combobox "#combobox-dropdown"
    press :down, :tab

    assert_committed "#combobox-dropdown", "Australia", "au"
    assert_focused "#combobox-typeahead [role='combobox']"
  end

  def test_clicking_outside_closes_without_committing
    open_combobox "#combobox-dropdown"
    press :down
    # The page heading is outside every combobox.
    find("h1").click

    assert_committed "#combobox-dropdown", "", ""
  end

  def test_focus_leaving_closes_the_panel
    open_combobox "#combobox-typeahead"
    find("#combobox-typeahead-remote [role='combobox']").execute_script("this.focus()")

    assert_selector "#combobox-typeahead [role='combobox'][aria-expanded='false']"
  end

  def test_typing_filters_the_options_and_keeps_focus
    find("#combobox-typeahead [role='combobox']").send_keys("Se")

    assert_selector "#combobox-typeahead [role='option']", count: 1, text: "Seoul"
    assert_focused "#combobox-typeahead [role='combobox']"
  end

  def test_remote_results_keep_focus
    find("#combobox-typeahead-remote [role='combobox']").send_keys("Se")

    assert_selector "#combobox-typeahead-remote [role='option']", count: 2
    assert_focused "#combobox-typeahead-remote [role='combobox']"
  end

  def test_escape_in_a_modal_closes_only_the_panel
    click_button "Choose shipping country"
    open_combobox "#combobox-modal"
    press :escape

    assert_selector "#combobox-modal [role='combobox'][aria-expanded='false']"
    assert_selector "#combobox-dialog[open]"
  end

  private

  def open_combobox(section)
    find("#{section} [role='combobox']").click

    assert_selector "#{section} [role='combobox'][aria-expanded='true']"
    assert_selector "#{section} [role='listbox']", visible: true
  end

  def close_with_focus(section)
    open_combobox section
    press :escape

    assert_selector "#{section} [role='combobox'][aria-expanded='false']"
  end

  # Types into the focused element; Cuprite's send_keys clicks it first.
  def press(*keys)
    page.driver.browser.keyboard.type(*keys)
  end

  def assert_active_option(section, label)
    option = find("#{section} [role='option'][aria-selected='true']", text: label)

    assert_selector "#{section} [role='combobox'][aria-expanded='true'][aria-activedescendant='#{option[:id]}']"
  end

  def assert_committed(section, label, value)
    assert_selector "#{section} [role='combobox'][aria-expanded='false']"
    assert_equal label, find("#{section} [role='combobox']").text
    assert_equal value, find("#{section} [data-combobox-target='input']", visible: :hidden).value
  end

  def assert_focused(selector)
    assert_equal find(selector)[:id], evaluate_script("document.activeElement.id")
  end
end
