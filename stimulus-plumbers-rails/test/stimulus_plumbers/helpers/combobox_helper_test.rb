# frozen_string_literal: true

require "test_helper"

class ComboboxHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper
  include StimulusPlumbers::Helpers::ComboboxHelper

  def build_combobox_date(record = nil, attribute = nil, **opts)
    parse_html(sp_combobox_date(record, attribute, **opts))
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox_date

    assert_css doc, "[data-controller='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox_date

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_renders_trigger_input_with_aria_expanded_false
    doc = build_combobox_date

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_renders_popup_dialog
    doc = build_combobox_date

    assert_css doc, "[role='dialog']"
  end

  def test_popup_is_hidden_by_default
    doc = build_combobox_date
    popup = doc.at_css("[role='dialog']")

    assert_not_nil popup
    assert popup.key?("hidden"), "Expected popup to have the hidden attribute"
  end

  def test_popup_has_accessible_label
    doc = build_combobox_date
    popup = doc.at_css("[role='dialog']")

    assert_not_nil popup
    assert_not_nil popup["aria-label"], "Expected popup to have aria-label"
  end

  def test_renders_hidden_value_input
    doc = build_combobox_date

    assert_css doc, "input[type='hidden']"
  end

  def test_renders_navigation_inside_popup
    doc = build_combobox_date

    assert_css doc, "[role='dialog'] nav"
  end

  def test_renders_calendar_month_inside_popup
    doc = build_combobox_date

    assert_css doc, "[role='dialog'] [data-controller~='calendar-month']"
  end

  # ── aria linkage ──────────────────────────────────────────────────────────

  def test_trigger_aria_controls_matches_popup_id
    doc = build_combobox_date
    trigger = doc.at_css("input[role='combobox']")
    popup   = doc.at_css("[role='dialog']")

    assert_not_nil trigger
    assert_not_nil popup
    assert_equal popup["id"], trigger["aria-controls"]
  end

  # ── cross-wiring ──────────────────────────────────────────────────────────

  def test_trigger_input_is_input_datepicker_display_target
    doc     = build_combobox_date
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_includes trigger["data-input-datepicker-target"].to_s, "display"
  end

  def test_hidden_input_is_input_datepicker_input_target
    doc    = build_combobox_date
    hidden = doc.at_css("input[type='hidden']")

    assert_not_nil hidden
    assert_includes hidden["data-input-datepicker-target"].to_s, "input"
  end

  # ── ids ───────────────────────────────────────────────────────────────────

  def test_stable_ids_from_record_and_attribute
    html1 = sp_combobox_date(TestRecord.new, :start_date, name: "test_record[start_date]", value: "")
    html2 = sp_combobox_date(TestRecord.new, :start_date, name: "test_record[start_date]", value: "")

    popup_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popup_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popup_id1
    assert_equal popup_id1, popup_id2
  end

  def test_random_ids_without_record
    html1 = sp_combobox_date(name: "field1")
    html2 = sp_combobox_date(name: "field2")

    popup_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popup_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popup_id1
    assert_not_equal popup_id1, popup_id2
  end

  # ── name / value resolution ───────────────────────────────────────────────

  def test_name_derived_from_record_and_attribute
    record = TestRecord.new
    record.define_singleton_method(:birthday) { nil }
    doc = build_combobox_date(record, :birthday)

    assert_css doc, "input[type='hidden'][name='test_record[birthday]']"
  end

  def test_name_from_explicit_name_option
    doc = build_combobox_date(name: "filter[date]")

    assert_css doc, "input[type='hidden'][name='filter[date]']"
  end

  def test_value_from_explicit_value_option
    doc = build_combobox_date(name: "filter[date]", value: "2024-03-15")

    assert_css doc, "input[type='hidden'][value='2024-03-15']"
  end

  def test_value_from_record_attribute
    record = TestRecord.new
    record.define_singleton_method(:birthday) { "2024-01-01" }
    doc = build_combobox_date(record, :birthday)

    assert_css doc, "input[type='hidden'][value='2024-01-01']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = build_combobox_date(class: "my-combobox")

    assert_css doc, "[data-controller='input-combobox'].my-combobox"
  end
end
