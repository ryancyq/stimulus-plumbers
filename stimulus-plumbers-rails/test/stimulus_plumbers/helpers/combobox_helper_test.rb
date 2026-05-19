# frozen_string_literal: true

require "test_helper"

class ComboboxHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ComboboxHelper

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = parse_html(sp_combobox_date)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = parse_html(sp_combobox_date)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_renders_trigger_input_with_aria_expanded_false
    doc = parse_html(sp_combobox_date)

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_trigger_has_haspopup_dialog
    doc = parse_html(sp_combobox_date)

    assert_css doc, "input[aria-haspopup='dialog']"
  end

  def test_trigger_is_readonly
    doc     = parse_html(sp_combobox_date)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_renders_dialog_popover
    doc = parse_html(sp_combobox_date)

    assert_css doc, "[role='dialog']"
  end

  def test_popover_is_hidden_by_default
    doc     = parse_html(sp_combobox_date)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_has_accessible_label
    doc     = parse_html(sp_combobox_date)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert_not_nil popover["aria-label"], "Expected popover to have aria-label"
  end

  def test_renders_hidden_value_input
    doc = parse_html(sp_combobox_date)

    assert_css doc, "input[type='hidden']"
  end

  def test_renders_navigation_inside_popup
    doc = parse_html(sp_combobox_date)

    assert_css doc, "[role='dialog'] nav"
  end

  def test_renders_calendar_month_inside_popup
    doc = parse_html(sp_combobox_date)

    assert_css doc, "[role='dialog'] [data-controller~='calendar-month']"
  end

  # ── aria linkage ──────────────────────────────────────────────────────────

  def test_trigger_aria_controls_matches_popover_id
    doc     = parse_html(sp_combobox_date)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[role='dialog']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── cross-wiring ──────────────────────────────────────────────────────────

  def test_trigger_input_is_input_format_target
    doc     = parse_html(sp_combobox_date)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_includes trigger["data-input-format-target"].to_s, "input"
  end

  def test_hidden_input_is_input_combobox_value_target
    doc    = parse_html(sp_combobox_date)
    hidden = doc.at_css("input[type='hidden']")

    assert_not_nil hidden
    assert_includes hidden["data-input-combobox-target"].to_s, "value"
  end

  # ── ids ───────────────────────────────────────────────────────────────────

  def test_generates_unique_id_per_render
    html1 = sp_combobox_date
    html2 = sp_combobox_date

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end

  # ── value ─────────────────────────────────────────────────────────────────

  def test_no_name_attribute_on_hidden_input
    doc    = parse_html(sp_combobox_date)
    hidden = doc.at_css("input[type='hidden']")

    assert_not_nil hidden
    assert_nil hidden["name"]
  end

  def test_value_from_explicit_value_option
    doc = parse_html(sp_combobox_date(value: "2024-03-15"))

    assert_css doc, "input[type='hidden'][value='2024-03-15']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = parse_html(sp_combobox_date(class: "my-combobox"))

    assert_css doc, "[data-controller~='input-combobox'].my-combobox"
  end

  # ── outlet wiring ─────────────────────────────────────────────────────────

  def test_calendar_outlet_wired_to_calendar_element
    doc             = parse_html(sp_combobox_date)
    date_controller = doc.at_css("[data-controller~='combobox-date']")
    calendar        = doc.at_css("[data-controller~='calendar-month']")

    assert_equal "##{calendar["id"]}", date_controller["data-combobox-date-calendar-month-outlet"]
  end
end
