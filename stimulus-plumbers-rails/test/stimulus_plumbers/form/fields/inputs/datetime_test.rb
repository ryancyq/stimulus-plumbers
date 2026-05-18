# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class DatetimeTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_date_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.date_field(:birthday, **opts)
    end
    parse_html(html)
  end

  def build_time_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.time_field(:meeting_time, **opts)
    end
    parse_html(html)
  end

  # ── date_field (combobox) ─────────────────────────────────────────────────

  def test_date_renders_label
    assert_css build_date_field, "label[for='sign_in_form_birthday']"
  end

  def test_date_renders_combobox_trigger
    assert_css build_date_field, "input[role='combobox']"
  end

  def test_date_renders_hidden_value_input
    assert_css build_date_field, "input[type='hidden'][name='sign_in_form[birthday]']"
  end

  def test_date_renders_calendar_popover
    assert_css build_date_field, "[role='dialog']"
  end

  def test_date_combobox_has_input_format_type_value
    assert_css build_date_field, "[data-input-format-type-value='date']"
  end

  def test_date_renders_custom_label_text
    assert_includes build_date_field(label: "Date of Birth").text, "Date of Birth"
  end

  def test_date_renders_details_hint
    assert_css build_date_field(details: "Select your birthday"), "#sign_in_form_birthday_hint"
  end

  def test_date_renders_error_message
    @form.errors.add(:birthday, "is invalid")

    assert_css build_date_field, "p[role='alert']"
    assert_includes build_date_field.text, "is invalid"
  end

  def test_date_html_native_option_does_not_leak_into_attributes
    assert_nil build_date_field(html_native: false).at_css("input[role='combobox']")["html_native"]
  end

  # ── date_field html_native: true ──────────────────────────────────────────

  def test_date_html_native_renders_native_date_input
    assert_css build_date_field(html_native: true), "input[type='date']"
  end

  def test_date_html_native_does_not_render_combobox_trigger
    assert_no_css build_date_field(html_native: true), "input[role='combobox']"
  end

  def test_date_html_native_renders_label
    assert_css build_date_field(html_native: true), "label[for='sign_in_form_birthday']"
  end

  def test_date_html_native_renders_error_message
    @form.errors.add(:birthday, "is invalid")

    assert_css build_date_field(html_native: true), "p[role='alert']"
  end

  # ── time_field (combobox) ─────────────────────────────────────────────────

  def test_time_renders_label
    assert_css build_time_field, "label[for='sign_in_form_meeting_time']"
  end

  def test_time_renders_combobox_trigger
    assert_css build_time_field, "input[role='combobox']"
  end

  def test_time_renders_hidden_value_input
    assert_css build_time_field, "input[type='hidden'][name='sign_in_form[meeting_time]']"
  end

  def test_time_renders_dialog_popover
    assert_css build_time_field, "[role='dialog']"
  end

  def test_time_combobox_has_input_format_type_value
    assert_css build_time_field, "[data-input-format-type-value='time']"
  end

  def test_time_renders_custom_label_text
    assert_includes build_time_field(label: "Meeting time").text, "Meeting time"
  end

  def test_time_renders_details_hint
    assert_css build_time_field(details: "Use 24-hour format"), "#sign_in_form_meeting_time_hint"
  end

  def test_time_renders_error_message
    @form.errors.add(:meeting_time, "is invalid")

    assert_css build_time_field, "p[role='alert']"
    assert_includes build_time_field.text, "is invalid"
  end

  def test_time_pre_selects_drums_from_model_value
    @form.define_singleton_method(:meeting_time) { "14:30" }

    assert_css build_time_field, "ul[aria-label='Hour']   li[data-value='2'][aria-selected='true']"
    assert_css build_time_field, "ul[aria-label='Minute'] li[data-value='30'][aria-selected='true']"
    assert_css build_time_field, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
  end

  def test_time_html_native_option_does_not_leak_into_attributes
    assert_nil build_time_field(html_native: false).at_css("input[role='combobox']")["html_native"]
  end

  # ── time_field html_native: true ──────────────────────────────────────────

  def test_time_html_native_renders_native_time_input
    assert_css build_time_field(html_native: true), "input[type='time']"
  end

  def test_time_html_native_does_not_render_combobox_trigger
    assert_no_css build_time_field(html_native: true), "input[role='combobox']"
  end

  def test_time_html_native_renders_label
    assert_css build_time_field(html_native: true), "label[for='sign_in_form_meeting_time']"
  end

  def test_time_html_native_renders_error_message
    @form.errors.add(:meeting_time, "is invalid")

    assert_css build_time_field(html_native: true), "p[role='alert']"
  end
end
