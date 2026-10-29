# frozen_string_literal: true

require "test_helper"

class ComboboxHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ComboboxHelper

  class DateTest < ComboboxHelperTest
    def test_renders_combobox_wrapper_with_stimulus_controller
      assert_css parse_html(sp_combobox_date), "[data-controller~='input-combobox']"
    end

    def test_renders_trigger_input_with_combobox_role
      assert_css parse_html(sp_combobox_date), "input[type='text'][role='combobox']"
    end

    def test_renders_trigger_input_with_aria_expanded_false
      assert_css parse_html(sp_combobox_date), "input[aria-expanded='false']"
    end

    def test_trigger_has_haspopup_dialog
      assert_css parse_html(sp_combobox_date), "input[aria-haspopup='dialog']"
    end

    def test_trigger_is_readonly
      trigger = parse_html(sp_combobox_date).at_css("input[role='combobox']")

      assert_not_nil trigger
      assert trigger.key?("readonly"), "Expected trigger to be readonly"
    end

    def test_renders_dialog_popover
      assert_css parse_html(sp_combobox_date), "[role='dialog']"
    end

    def test_panel_is_a_native_auto_popover
      popover = parse_html(sp_combobox_date).at_css("[role='dialog']")

      assert_not_nil popover
      assert_equal "auto", popover["popover"]
    end

    def test_popover_has_accessible_label
      popover = parse_html(sp_combobox_date).at_css("[role='dialog']")

      assert_not_nil popover
      assert_not_nil popover["aria-label"]
    end

    def test_renders_hidden_value_input
      assert_css parse_html(sp_combobox_date), "input[type='hidden']"
    end

    def test_renders_navigation_inside_popup
      assert_css parse_html(sp_combobox_date), "[role='dialog'] nav"
    end

    def test_renders_calendar_month_inside_popup
      assert_css parse_html(sp_combobox_date), "[role='dialog'] [data-controller~='calendar-month']"
    end

    def test_trigger_aria_controls_matches_popover_id
      doc     = parse_html(sp_combobox_date)
      trigger = doc.at_css("input[role='combobox']")
      popover = doc.at_css("[role='dialog']")

      assert_not_nil trigger
      assert_not_nil popover
      assert_equal popover["id"], trigger["aria-controls"]
    end

    def test_trigger_input_is_input_formatter_target
      trigger = parse_html(sp_combobox_date).at_css("input[role='combobox']")

      assert_not_nil trigger
      assert_includes trigger["data-input-formatter-target"].to_s, "input"
    end

    def test_hidden_input_is_input_combobox_input_target
      hidden = parse_html(sp_combobox_date).at_css("input[type='hidden']")

      assert_not_nil hidden
      assert_includes hidden["data-input-combobox-target"].to_s, "input"
    end

    def test_calendar_outlet_wired_to_calendar_element
      doc             = parse_html(sp_combobox_date)
      date_controller = doc.at_css("[data-controller~='combobox-date']")
      calendar        = doc.at_css("[data-controller~='calendar-month']")

      assert_equal "##{calendar["id"]}", date_controller["data-combobox-date-calendar-month-outlet"]
    end

    def test_generates_unique_id_per_render
      popover_id1 = sp_combobox_date[%r{aria-controls="([^"]+)"}, 1]
      popover_id2 = sp_combobox_date[%r{aria-controls="([^"]+)"}, 1]

      assert_not_nil popover_id1
      assert_not_equal popover_id1, popover_id2
    end

    def test_no_name_attribute_on_hidden_input
      hidden = parse_html(sp_combobox_date).at_css("input[type='hidden']")

      assert_not_nil hidden
      assert_nil hidden["name"]
    end

    def test_value_from_explicit_value_option
      assert_css parse_html(sp_combobox_date(value: "2024-03-15")), "input[type='hidden'][value='2024-03-15']"
    end

    def test_forwards_html_options_to_wrapper
      assert_css parse_html(sp_combobox_date(class: "my-combobox")), "[data-controller~='input-combobox'].my-combobox"
    end

    def test_label_sets_trigger_aria_label
      assert_css parse_html(sp_combobox_date(label: "Pick a date")), "input[aria-label='Pick a date']"
    end
  end

  class DropdownTest < ComboboxHelperTest
    OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze

    def test_renders_a_select_only_combobox
      doc = parse_html(sp_combobox_dropdown(options: OPTIONS))

      assert_css doc, "[data-controller='combobox'][data-combobox-mode-value='select_only']"
      assert_css doc, "button[role='combobox']"
    end

    def test_names_the_hidden_input_and_shows_the_selected_label
      doc = parse_html(sp_combobox_dropdown(name: "country", options: OPTIONS, value: "ca"))

      assert_css doc, "input[type='hidden'][name='country'][value='ca']"
      assert_equal "Canada", doc.at_css("button[role='combobox']").text
    end

    def test_label_names_the_control
      assert_css parse_html(sp_combobox_dropdown(label: "Country")), "button[aria-label='Country']"
    end

    def test_close_on_select_value
      assert_css parse_html(sp_combobox_dropdown(close_on_select: false)), "[data-combobox-close-on-select-value='false']"
    end

    def test_does_not_accept_a_value_policy
      assert_raises(ArgumentError) { sp_combobox_dropdown(value_policy: :freeform) }
    end

    def test_generates_unique_ids_per_render
      first  = parse_html(sp_combobox_dropdown).at_css("[role='combobox']")["aria-controls"]
      second = parse_html(sp_combobox_dropdown).at_css("[role='combobox']")["aria-controls"]

      assert_not_equal first, second
    end

    def test_forwards_html_options_to_the_container
      assert_css parse_html(sp_combobox_dropdown(class: "my-combobox")), "[data-controller='combobox'].my-combobox"
    end
  end

  class TypeaheadTest < ComboboxHelperTest
    def test_renders_an_editable_combobox
      doc = parse_html(sp_combobox_typeahead(options: [%w[Canada ca]]))

      assert_css doc, "[data-controller='combobox'][data-combobox-mode-value='editable']"
      assert_css doc, "input[type='text'][role='combobox']"
    end

    def test_value_policy_value
      assert_css parse_html(sp_combobox_typeahead(value_policy: :freeform)),
                 "[data-combobox-value-policy-value='freeform']"
    end

    def test_label_names_the_control
      assert_css parse_html(sp_combobox_typeahead(label: "City")), "input[aria-label='City']"
    end
  end

  class TimeTest < ComboboxHelperTest
    def test_renders_combobox_wrapper_with_stimulus_controller
      assert_css parse_html(sp_combobox_time), "[data-controller~='input-combobox']"
    end

    def test_renders_trigger_input_with_combobox_role
      assert_css parse_html(sp_combobox_time), "input[type='text'][role='combobox']"
    end

    def test_trigger_is_readonly
      trigger = parse_html(sp_combobox_time).at_css("input[role='combobox']")

      assert_not_nil trigger
      assert trigger.key?("readonly"), "Expected trigger to be readonly"
    end

    def test_trigger_has_haspopup_dialog
      assert_css parse_html(sp_combobox_time), "input[aria-haspopup='dialog']"
    end

    def test_renders_dialog_popover
      assert_css parse_html(sp_combobox_time), "[role='dialog']"
    end

    def test_panel_is_a_native_auto_popover
      popover = parse_html(sp_combobox_time).at_css("[role='dialog']")

      assert_not_nil popover
      assert_equal "auto", popover["popover"]
    end

    def test_trigger_aria_expanded_false
      assert_css parse_html(sp_combobox_time), "input[aria-expanded='false']"
    end

    def test_trigger_aria_controls_matches_popover_id
      doc     = parse_html(sp_combobox_time)
      trigger = doc.at_css("input[role='combobox']")
      popover = doc.at_css("[role='dialog']")

      assert_not_nil trigger
      assert_not_nil popover
      assert_equal popover["id"], trigger["aria-controls"]
    end

    def test_popover_has_accessible_label
      assert_not_nil parse_html(sp_combobox_time).at_css("[role='dialog']")["aria-label"]
    end

    def test_time_controller_on_popover
      assert_css parse_html(sp_combobox_time), "[role='dialog'][data-controller='combobox-time']"
    end

    def test_renders_hour_minute_period_drums_by_default
      doc = parse_html(sp_combobox_time)

      assert_css doc, "ul[role='listbox'][aria-label='Hour']"
      assert_css doc, "ul[role='listbox'][aria-label='Minute']"
      assert_css doc, "ul[role='listbox'][aria-label='Period']"
    end

    def test_drums_are_keyboard_focusable
      doc = parse_html(sp_combobox_time)

      assert_css doc, "ul[role='listbox'][aria-label='Hour'][tabindex='0']"
      assert_css doc, "ul[role='listbox'][aria-label='Minute'][tabindex='0']"
      assert_css doc, "ul[role='listbox'][aria-label='Period'][tabindex='0']"
    end

    def test_h24_format_omits_period_drum
      doc = parse_html(sp_combobox_time(format: :h24))

      assert_css    doc, "ul[aria-label='Hour']"
      assert_no_css doc, "ul[aria-label='Period']"
    end

    def test_h24_hour_drum_has_24_options
      assert_equal 24, parse_html(sp_combobox_time(format: :h24)).css("ul[aria-label='Hour'] li[role='option']").length
    end

    def test_minute_step_reduces_option_count
      assert_equal 4, parse_html(sp_combobox_time(step: 15)).css("ul[aria-label='Minute'] li[role='option']").length
    end

    def test_minute_step_items_are_correct
      values = parse_html(sp_combobox_time(step: 15)).css("ul[aria-label='Minute'] li[role='option']").map do |li|
        li["data-value"]
      end

      assert_equal %w[00 15 30 45], values
    end

    def test_h12_hour_drum_has_12_options
      assert_equal 12, parse_html(sp_combobox_time).css("ul[aria-label='Hour'] li[role='option']").length
    end

    def test_twelve_hour_drum_values_range_from_one_to_twelve
      values = parse_html(sp_combobox_time).css("ul[aria-label='Hour'] li[role='option']").map { |li| li["data-value"] }

      assert_includes values, "1"
      assert_includes values, "12"
    end

    def test_minute_drum_has_60_options_by_default
      assert_equal 60, parse_html(sp_combobox_time).css("ul[aria-label='Minute'] li[role='option']").length
    end

    def test_period_drum_has_am_and_pm_options
      doc = parse_html(sp_combobox_time)

      assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='AM']"
      assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='PM']"
    end

    def test_pre_selects_from_value
      doc = parse_html(sp_combobox_time(value: "14:30"))

      assert_css doc, "ul[aria-label='Hour']   li[data-value='2'][aria-selected='true']"
      assert_css doc, "ul[aria-label='Minute'] li[data-value='30'][aria-selected='true']"
      assert_css doc, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
    end

    def test_midnight_selects_12_am
      doc = parse_html(sp_combobox_time(value: "00:00"))

      assert_css doc, "ul[aria-label='Hour']   li[data-value='12'][aria-selected='true']"
      assert_css doc, "ul[aria-label='Period'] li[data-value='AM'][aria-selected='true']"
    end

    def test_noon_selects_12_pm
      doc = parse_html(sp_combobox_time(value: "12:00"))

      assert_css doc, "ul[aria-label='Hour']   li[data-value='12'][aria-selected='true']"
      assert_css doc, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
    end

    def test_pre_selects_period_am_for_morning_value
      assert_css parse_html(sp_combobox_time(value: "09:00")), "ul[aria-label='Period'] li[data-value='AM'][aria-selected='true']"
    end

    def test_no_preselection_without_value
      doc = parse_html(sp_combobox_time)

      assert_no_css doc, "ul[aria-label='Hour']   li[aria-selected='true']"
      assert_no_css doc, "ul[aria-label='Minute'] li[aria-selected='true']"
      assert_no_css doc, "ul[aria-label='Period'] li[aria-selected='true']"
    end

    def test_value_in_hidden_input
      assert_css parse_html(sp_combobox_time(value: "09:00")), "input[type='hidden'][value='09:00']"
    end

    def test_forwards_html_options_to_wrapper
      assert_css parse_html(sp_combobox_time(class: "my-timepicker")),
                 "[data-controller~='input-combobox'].my-timepicker"
    end

    def test_generates_unique_id_per_render
      popover_id1 = sp_combobox_time[%r{aria-controls="([^"]+)"}, 1]
      popover_id2 = sp_combobox_time[%r{aria-controls="([^"]+)"}, 1]

      assert_not_nil popover_id1
      assert_not_equal popover_id1, popover_id2
    end
  end
end
