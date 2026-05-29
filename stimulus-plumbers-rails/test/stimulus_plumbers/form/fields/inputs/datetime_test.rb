# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class DatetimeTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  # native ActionView helpers — theme classes only, no wrapper
  def build_native_date(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.date_field(:birthday, **opts)
    end
    parse_html(html)
  end

  def build_native_time(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.time_field(:meeting_time, **opts)
    end
    parse_html(html)
  end

  # f.field — full wrapper: label + combobox + hint + error
  def build_date_combobox(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:birthday, as: :date, **opts)
    end
    parse_html(html)
  end

  def build_time_combobox(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:meeting_time, as: :time, **opts)
    end
    parse_html(html)
  end

  # ── date_field native ─────────────────────────────────────────────────────

  def test_date_native_renders_date_input
    assert_css build_native_date, "input[type='date']"
  end

  def test_date_native_does_not_render_combobox_trigger
    assert_no_css build_native_date, "input[role='combobox']"
  end

  # ── f.field(as: :date) — combobox ────────────────────────────────────────

  def test_date_renders_label
    assert_css build_date_combobox, "label[for='sign_in_form_birthday']"
  end

  def test_date_label_has_id
    assert_css build_date_combobox, "label[id='sign_in_form_birthday_label']"
  end

  def test_date_dialog_has_aria_labelledby_referencing_label
    assert_css build_date_combobox, "[role='dialog'][aria-labelledby='sign_in_form_birthday_label']"
  end

  def test_date_renders_combobox_trigger
    assert_css build_date_combobox, "input[role='combobox']"
  end

  def test_date_renders_hidden_value_input
    assert_css build_date_combobox, "input[type='hidden'][name='sign_in_form[birthday]']"
  end

  def test_date_renders_calendar_popover
    assert_css build_date_combobox, "[role='dialog']"
  end

  def test_date_combobox_has_input_formatter_format_value
    assert_css build_date_combobox, "[data-input-formatter-format-value='date']"
  end

  def test_date_renders_custom_label_text
    assert_includes build_date_combobox(label: "Date of Birth").text, "Date of Birth"
  end

  def test_date_renders_details_hint
    assert_css build_date_combobox(hint: "Select your birthday"), "#sign_in_form_birthday_hint"
  end

  def test_date_renders_error_message
    @form.errors.add(:birthday, "is invalid")

    assert_css build_date_combobox, "p[role='alert']"
    assert_includes build_date_combobox.text, "is invalid"
  end

  def test_date_pre_populates_hidden_input_from_model_value
    @form.define_singleton_method(:birthday) { "2000-06-15" }

    assert_equal "2000-06-15",
                 build_date_combobox.at_css("input[type='hidden'][name='sign_in_form[birthday]']")["value"]
  end

  def test_date_sets_combobox_value_data_from_model_value
    @form.define_singleton_method(:birthday) { "2000-06-15" }

    assert_css build_date_combobox, "[data-input-combobox-value-value='2000-06-15']"
  end

  def test_date_renders_error_message_with_error_override
    assert_includes build_date_combobox(error: "Invalid date").text, "Invalid date"
  end

  def test_date_calendar_outlet_wired_to_calendar_element
    doc             = build_date_combobox
    date_controller = doc.at_css("[data-controller~='combobox-date']")
    calendar        = doc.at_css("[data-controller~='calendar-month']")

    assert_equal "##{calendar["id"]}", date_controller["data-combobox-date-calendar-month-outlet"]
  end

  # ── time_field native ─────────────────────────────────────────────────────

  def test_time_native_renders_time_input
    assert_css build_native_time, "input[type='time']"
  end

  def test_time_native_does_not_render_combobox_trigger
    assert_no_css build_native_time, "input[role='combobox']"
  end

  # ── f.field(as: :time) — combobox ────────────────────────────────────────

  def test_time_renders_label
    assert_css build_time_combobox, "label[for='sign_in_form_meeting_time']"
  end

  def test_time_label_has_id
    assert_css build_time_combobox, "label[id='sign_in_form_meeting_time_label']"
  end

  def test_time_dialog_has_aria_labelledby_referencing_label
    assert_css build_time_combobox, "[role='dialog'][aria-labelledby='sign_in_form_meeting_time_label']"
  end

  def test_time_renders_combobox_trigger
    assert_css build_time_combobox, "input[role='combobox']"
  end

  def test_time_renders_hidden_value_input
    assert_css build_time_combobox, "input[type='hidden'][name='sign_in_form[meeting_time]']"
  end

  def test_time_renders_dialog_popover
    assert_css build_time_combobox, "[role='dialog']"
  end

  def test_time_combobox_has_input_formatter_format_value
    assert_css build_time_combobox, "[data-input-formatter-format-value='time']"
  end

  def test_time_renders_custom_label_text
    assert_includes build_time_combobox(label: "Meeting time").text, "Meeting time"
  end

  def test_time_renders_details_hint
    assert_css build_time_combobox(hint: "Use 24-hour format"), "#sign_in_form_meeting_time_hint"
  end

  def test_time_renders_error_message
    @form.errors.add(:meeting_time, "is invalid")

    assert_css build_time_combobox, "p[role='alert']"
    assert_includes build_time_combobox.text, "is invalid"
  end

  def test_time_pre_selects_drums_from_model_value
    @form.define_singleton_method(:meeting_time) { "14:30" }

    assert_css build_time_combobox, "ul[aria-label='Hour']   li[data-value='2'][aria-selected='true']"
    assert_css build_time_combobox, "ul[aria-label='Minute'] li[data-value='30'][aria-selected='true']"
    assert_css build_time_combobox, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
  end

  def test_time_format_h24_renders_two_drums
    doc = build_time_combobox(format: :h24)

    assert_equal 2, doc.css("ul[role='listbox']").length
    assert_no_css doc, "ul[aria-label='Period']"
  end

  def test_time_step_15_reduces_minute_options
    doc = build_time_combobox(step: 15)

    assert_equal 4, doc.css("ul[aria-label='Minute'] li").length
  end

  def test_time_renders_error_message_with_error_override
    assert_includes build_time_combobox(error: "Invalid time").text, "Invalid time"
  end
end
