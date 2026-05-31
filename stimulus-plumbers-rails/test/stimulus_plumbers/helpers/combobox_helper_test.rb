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

    def test_popover_is_hidden_by_default
      popover = parse_html(sp_combobox_date).at_css("[role='dialog']")

      assert_not_nil popover
      assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
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
    SIMPLE_OPTIONS          = [["United States", "us"], ["Canada", "ca"]].freeze
    GROUPED_OPTIONS         = [
      { label: "Americas", options: [["United States", "us"], ["Canada", "ca"]] },
      { label: "Europe",   options: [["United Kingdom", "gb"]] }
    ].freeze
    OPTIONS_WITH_DESCRIPTION = [
      ["United States", "us", { description: "North America" }],
      ["Canada",        "ca", { description: "North America" }]
    ].freeze

    def test_renders_combobox_wrapper_with_stimulus_controller
      assert_css parse_html(sp_combobox_dropdown), "[data-controller~='input-combobox']"
    end

    def test_renders_trigger_input_with_combobox_role
      assert_css parse_html(sp_combobox_dropdown), "input[type='text'][role='combobox']"
    end

    def test_trigger_is_readonly
      trigger = parse_html(sp_combobox_dropdown).at_css("input[role='combobox']")

      assert_not_nil trigger
      assert trigger.key?("readonly"), "Expected trigger to be readonly"
    end

    def test_trigger_has_haspopup_listbox
      assert_css parse_html(sp_combobox_dropdown), "input[aria-haspopup='listbox']"
    end

    def test_renders_listbox_popover
      assert_css parse_html(sp_combobox_dropdown), "ul[role='listbox']"
    end

    def test_popover_is_hidden_by_default
      popover = parse_html(sp_combobox_dropdown).at_css("[data-popover-target='panel']")

      assert_not_nil popover
      assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
    end

    def test_trigger_aria_expanded_false
      assert_css parse_html(sp_combobox_dropdown), "input[aria-expanded='false']"
    end

    def test_trigger_aria_controls_matches_popover_id
      doc     = parse_html(sp_combobox_dropdown)
      trigger = doc.at_css("input[role='combobox']")
      popover = doc.at_css("[data-popover-target='panel']")

      assert_not_nil trigger
      assert_not_nil popover
      assert_equal popover["id"], trigger["aria-controls"]
    end

    def test_renders_options
      assert_css parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS)), "li[role='option']"
    end

    def test_renders_correct_option_count
      options = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS)).css("li[role='option']")

      assert_equal SIMPLE_OPTIONS.length, options.length
    end

    def test_selected_option_from_value
      doc = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS, value: "ca"))

      assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
      assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
    end

    def test_option_with_description_renders_label_and_description_spans
      option = parse_html(sp_combobox_dropdown(options: OPTIONS_WITH_DESCRIPTION)).at_css("li[role='option'][data-value='us']")

      assert_not_nil option
      spans = option.css("span")

      assert_equal 2, spans.length
      assert_equal "United States", spans[0].text
      assert_equal "North America", spans[1].text
    end

    def test_option_without_description_renders_plain_text
      option = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS)).at_css("li[role='option'][data-value='us']")

      assert_not_nil option
      assert_empty option.css("span")
    end

    def test_disabled_option_has_aria_disabled_true
      options = [["Disabled", "x", { disabled: true }], %w[Enabled y]]
      doc     = parse_html(sp_combobox_dropdown(options: options))

      assert_css doc, "li[role='option'][data-value='x'][aria-disabled='true']"
      assert_no_css doc, "li[role='option'][data-value='y'][aria-disabled]"
    end

    def test_hash_option_renders_label_and_value
      assert_css parse_html(sp_combobox_dropdown(options: [{ label: "United States", value: "us" }])),
                 "li[role='option'][data-value='us']"
    end

    def test_hash_option_with_description_renders_two_spans
      option = parse_html(
        sp_combobox_dropdown(options: [{ label: "United States", value: "us", description: "North America" }])
      ).at_css("li[role='option'][data-value='us']")

      assert_not_nil option
      assert_equal 2, option.css("span").length
    end

    def test_renders_groups
      doc = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS))

      assert_css doc, "li[role='group'][aria-label='Americas']"
      assert_css doc, "li[role='group'][aria-label='Europe']"
    end

    def test_options_inside_groups
      assert_css parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS)), "li[role='group'] ul li[role='option']"
    end

    def test_group_label_span_is_aria_hidden
      span = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS)).at_css("li[role='group'] span[aria-hidden='true']")

      assert_not_nil span
      assert_includes span.text, "Americas"
    end

    def test_total_option_count_across_groups
      options  = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS)).css("li[role='option']")
      expected = GROUPED_OPTIONS.sum { |g| g[:options].length }

      assert_equal expected, options.length
    end

    def test_value_from_explicit_option
      doc = parse_html(sp_combobox_dropdown(value: "us", options: SIMPLE_OPTIONS))

      assert_css doc, "input[type='hidden'][value='us']"
      assert_css doc, "li[role='option'][data-value='us'][aria-selected='true']"
    end

    def test_forwards_html_options_to_wrapper
      assert_css parse_html(sp_combobox_dropdown(class: "my-dropdown")),
                 "[data-controller~='input-combobox'].my-dropdown"
    end

    def test_generates_unique_id_per_render
      popover_id1 = sp_combobox_dropdown[%r{aria-controls="([^"]+)"}, 1]
      popover_id2 = sp_combobox_dropdown[%r{aria-controls="([^"]+)"}, 1]

      assert_not_nil popover_id1
      assert_not_equal popover_id1, popover_id2
    end
  end

  class TypeaheadTest < ComboboxHelperTest
    def test_renders_combobox_wrapper_with_stimulus_controller
      assert_css parse_html(sp_combobox_typeahead), "[data-controller~='input-combobox']"
    end

    def test_renders_trigger_input_with_combobox_role
      assert_css parse_html(sp_combobox_typeahead), "input[type='text'][role='combobox']"
    end

    def test_trigger_is_not_readonly
      trigger = parse_html(sp_combobox_typeahead).at_css("input[role='combobox']")

      assert_not_nil trigger
      assert_not trigger.key?("readonly"), "Expected trigger to not be readonly"
    end

    def test_trigger_has_haspopup_listbox
      assert_css parse_html(sp_combobox_typeahead), "input[aria-haspopup='listbox']"
    end

    def test_trigger_has_aria_autocomplete_list
      assert_css parse_html(sp_combobox_typeahead), "input[aria-autocomplete='list']"
    end

    def test_renders_listbox_popover
      assert_css parse_html(sp_combobox_typeahead), "ul[role='listbox']"
    end

    def test_popover_is_hidden_by_default
      popover = parse_html(sp_combobox_typeahead).at_css("[data-popover-target='panel']")

      assert_not_nil popover
      assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
    end

    def test_popover_has_no_options_by_default
      assert_no_css parse_html(sp_combobox_typeahead), "[role='listbox'] li[role='option']"
    end

    def test_renders_loading_indicator
      assert_css parse_html(sp_combobox_typeahead), "[role='status'][hidden][data-combobox-dropdown-target='loading']"
    end

    def test_renders_empty_state_element
      assert_css parse_html(sp_combobox_typeahead), "[role='status'][hidden]"
    end

    def test_trigger_aria_expanded_false
      assert_css parse_html(sp_combobox_typeahead), "input[aria-expanded='false']"
    end

    def test_renders_initial_options_when_provided
      doc = parse_html(sp_combobox_typeahead(options: [%w[London london], %w[Paris paris]]))

      assert_css doc, "li[role='option'][data-value='london']"
      assert_css doc, "li[role='option'][data-value='paris']"
    end

    def test_option_with_description_renders_two_spans
      options = [["London", "london", { description: "United Kingdom" }]]
      option  = parse_html(sp_combobox_typeahead(options: options)).at_css("li[role='option'][data-value='london']")

      assert_not_nil option
      spans = option.css("span")

      assert_equal 2, spans.length
      assert_equal "London",         spans[0].text
      assert_equal "United Kingdom", spans[1].text
    end

    def test_trigger_aria_controls_matches_listbox_id
      doc     = parse_html(sp_combobox_typeahead)
      trigger = doc.at_css("input[role='combobox']")
      listbox = doc.at_css("ul[role='listbox']")

      assert_not_nil trigger
      assert_not_nil listbox
      assert_equal listbox["id"], trigger["aria-controls"]
    end

    def test_value_from_explicit_option
      assert_css parse_html(sp_combobox_typeahead(value: "london")), "input[type='hidden'][value='london']"
    end

    def test_forwards_html_options_to_wrapper
      assert_css parse_html(sp_combobox_typeahead(class: "my-typeahead")),
                 "[data-controller~='input-combobox'].my-typeahead"
    end

    def test_generates_unique_id_per_render
      popover_id1 = sp_combobox_typeahead[%r{aria-controls="([^"]+)"}, 1]
      popover_id2 = sp_combobox_typeahead[%r{aria-controls="([^"]+)"}, 1]

      assert_not_nil popover_id1
      assert_not_equal popover_id1, popover_id2
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

    def test_popover_is_hidden_by_default
      popover = parse_html(sp_combobox_time).at_css("[role='dialog']")

      assert_not_nil popover
      assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
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
