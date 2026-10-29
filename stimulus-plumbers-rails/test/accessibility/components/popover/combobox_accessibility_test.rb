# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class ComboboxAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/popover/combobox"
  end

  def test_passes_wcag_with_all_comboboxes_closed
    assert_sections_accessible
  end

  def test_passes_wcag_with_combobox_date_open
    find("input[aria-label='Birthday']").click

    assert_selector "#combobox-date [role='combobox'][aria-expanded='true']"
    assert_accessible context: "#combobox-date"
  end

  def test_passes_wcag_with_combobox_time_open
    find("input[aria-label='Meeting Time']").click

    assert_selector "#combobox-time [role='combobox'][aria-expanded='true']"
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

    assert_selector "#combobox-date-error [role='combobox'][aria-expanded='true']"
    assert_accessible context: "#combobox-date-error"
  end

  def test_passes_wcag_with_combobox_time_error
    assert_accessible context: "#combobox-time-error"
  end

  def test_passes_wcag_with_combobox_time_error_open
    find("#combobox-time-error input[role='combobox']").click

    assert_selector "#combobox-time-error [role='combobox'][aria-expanded='true']"
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
    open_combobox "#combobox-preselected"

    assert_accessible context: "#combobox-preselected"
  end

  def test_passes_wcag_with_dropdown_disabled_option_open
    open_combobox "#combobox-disabled-option"

    assert_accessible context: "#combobox-disabled-option"
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

  def test_enter_selects_the_active_option_and_keeps_focus
    open_combobox "#combobox-dropdown"
    press :down, :enter

    assert_selected "#combobox-dropdown", "Australia", "au"
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_clicking_an_option_selects_it_and_keeps_focus
    open_combobox "#combobox-dropdown"
    find("#combobox-dropdown [role='option']", text: "Canada").click

    assert_selected "#combobox-dropdown", "Canada", "ca"
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_escape_closes_without_selecting
    open_combobox "#combobox-dropdown"
    press :down, :escape

    assert_selected "#combobox-dropdown", "", ""
    assert_focused "#combobox-dropdown [role='combobox']"
  end

  def test_tab_selects_the_active_option_and_moves_on
    open_combobox "#combobox-dropdown"
    press :down, :tab

    assert_selected "#combobox-dropdown", "Australia", "au"
    assert_focused "#combobox-typeahead [role='combobox']"
  end

  def test_clicking_outside_closes_without_selecting
    open_combobox "#combobox-dropdown"
    press :down
    # The page heading is outside every combobox.
    find("h1").click

    assert_selected "#combobox-dropdown", "", ""
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

  def test_passes_wcag_with_selected_date_open
    find("#deadline").click

    assert_selector "#deadline_popover:popover-open"
    assert_accessible context: "#combobox-date-selected"
  end

  def test_tab_closes_a_date_panel_and_opens_the_next_with_focus_kept
    find("#birthday").click
    press :tab

    assert_selector "#birthday[aria-expanded='false']"
    assert_selector "#deadline[aria-expanded='true']"
    assert_focused "#deadline"
  end

  def test_arrow_down_moves_focus_to_the_selected_date
    find("#deadline").click
    press :down

    assert_equal "2024-02-15", evaluate_script("document.activeElement.dataset.date")
  end

  def test_selecting_a_date_fills_the_field_and_returns_focus
    find("#deadline").click
    press :down, :right, :enter

    assert_selector "#deadline[aria-expanded='false']"
    assert_equal "February 16, 2024", find("#deadline").value
    assert_equal "2024-02-16", find("input[name='deadline']", visible: :hidden).value
    assert_focused "#deadline"
  end

  def test_clicking_the_icon_opens_the_panel_from_the_input
    # The unthemed icon has no box, so the click is dispatched.
    find("#deadline + [aria-hidden='true']", visible: :all).trigger(:click)

    assert_selector "#deadline[aria-expanded='true']"
    assert_focused "#deadline"
  end

  def test_tab_out_of_the_calendar_closes_the_panel
    find("#deadline").click
    press :down, :tab

    assert_selector "#deadline[aria-expanded='false']"
    refute evaluate_script("document.querySelector('#combobox-date-selected').contains(document.activeElement)")
  end

  def test_page_down_shows_the_next_month_inside_the_open_panel
    find("#deadline").click
    press :down, :page_down

    assert_selector "#deadline_popover h2", text: "March 2024"
    assert_equal "2024-03-15", evaluate_script("document.activeElement.dataset.date")
    assert_selector "#deadline[aria-expanded='true']"
  end

  def test_escape_from_the_calendar_closes_without_changing_the_date
    find("#deadline").click
    press :down, :right, :escape

    assert_selector "#deadline[aria-expanded='false']"
    assert_equal "2024-02-15", find("input[name='deadline']", visible: :hidden).value
    assert_focused "#deadline"
  end

  def test_a_date_combobox_in_a_modal_opens_on_arrow_down_not_on_focus
    click_button "Plan a trip"
    find("#departure").execute_script("this.focus()")

    assert_selector "#departure[aria-expanded='false']"
    press :down

    assert_selector "#departure[aria-expanded='true']"
    assert_accessible context: "#combobox-date-modal"
  end

  def test_arrow_down_moves_focus_to_the_selected_hour
    find("#standup").click
    press :down

    assert_equal "Hour", evaluate_script("document.activeElement.getAttribute('aria-label')")
    assert_selector "#standup_popover [aria-label='Hour'][aria-activedescendant='standup_hour_2']"
    assert_accessible context: "#combobox-time-selected"
  end

  def test_each_column_selection_updates_the_time_with_the_panel_open
    find("#standup").click
    press :down, :down

    assert_equal "15:30", find("input[name='standup']", visible: :hidden).value
    assert_match(%r{\A3:30[[:space:]]PM\z}, find("#standup").value)
    assert_selector "#standup[aria-expanded='true']"
  end

  def test_clicking_an_option_updates_the_time
    find("#standup").click
    # Dispatches the click: unthemed columns extend past the viewport.
    find("#standup_popover [aria-label='Minute'] [role='option']", text: "45").trigger(:click)

    assert_equal "14:45", find("input[name='standup']", visible: :hidden).value
  end

  def test_enter_closes_the_panel_and_keeps_the_time
    find("#standup").click
    press :down, :tab, :down, :enter

    assert_selector "#standup[aria-expanded='false']"
    assert_equal "14:31", find("input[name='standup']", visible: :hidden).value
    assert_focused "#standup"
  end

  def test_escape_restores_the_time_from_opening
    find("#standup").click
    press :down, :down, :escape

    assert_selector "#standup[aria-expanded='false']"
    assert_equal "14:30", find("input[name='standup']", visible: :hidden).value
    assert_focused "#standup"
  end

  def test_tab_out_of_the_columns_closes_the_panel_and_keeps_the_time
    find("#standup").click
    press :down, :down, :tab, :tab, :tab

    assert_selector "#standup[aria-expanded='false']"
    assert_equal "15:30", find("input[name='standup']", visible: :hidden).value
  end

  def test_escape_in_a_modal_restores_the_time_and_keeps_the_modal_open
    click_button "Book a call"
    find("#call").execute_script("this.focus()")
    press :down, :down, :escape

    assert_selector "#call[aria-expanded='false']"
    assert_equal "09:00", find("input[name='call']", visible: :hidden).value
    assert_selector "#combobox-time-dialog[open]"
    assert_accessible context: "#combobox-time-modal"
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

  def assert_active_option(section, label)
    option = find("#{section} [role='option'][aria-selected='true']", text: label)

    assert_selector "#{section} [role='combobox'][aria-expanded='true'][aria-activedescendant='#{option[:id]}']"
  end

  def assert_selected(section, label, value)
    assert_selector "#{section} [role='combobox'][aria-expanded='false']"
    assert_equal label, find("#{section} [role='combobox']").text
    assert_equal value, find("#{section} [data-combobox-target='input']", visible: :hidden).value
  end

  def assert_focused(selector)
    assert_equal find(selector)[:id], evaluate_script("document.activeElement.id")
  end
end
