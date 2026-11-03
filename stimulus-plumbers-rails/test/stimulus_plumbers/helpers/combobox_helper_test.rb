# frozen_string_literal: true

require "test_helper"

class ComboboxHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ComboboxHelper

  class DateTest < ComboboxHelperTest
    def test_renders_a_date_combobox
      doc = parse_html(sp_combobox_date(name: "birthday", label: "Birthday", value: "2026-09-15"))

      assert_css doc, "[data-controller~='combobox-date']"
      assert_css doc, "input[role='combobox'][aria-label='Birthday']"
      assert_css doc, "input[type='hidden'][name='birthday'][value='2026-09-15']"
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
    def test_renders_a_time_combobox
      doc = parse_html(sp_combobox_time(name: "meeting", label: "Meeting", value: "14:30"))

      assert_css doc, "[data-controller~='combobox-time']"
      assert_css doc, "input[role='combobox'][aria-label='Meeting']"
      assert_css doc, "input[type='hidden'][name='meeting'][value='14:30']"
    end
  end

  class DatetimeTest < ComboboxHelperTest
    def test_renders_a_datetime_combobox
      doc = parse_html(sp_combobox_datetime(name: "booking", label: "Booking", value: "2026-11-03T22:00"))

      assert_css doc, "[data-controller~='combobox-datetime']"
      assert_css doc, "input[role='combobox'][aria-label='Booking']"
      assert_css doc, "input[type='hidden'][name='booking'][value='2026-11-03T22:00']"
    end
  end
end
