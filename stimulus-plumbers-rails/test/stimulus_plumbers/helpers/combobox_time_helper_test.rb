# frozen_string_literal: true

require "test_helper"

class ComboboxTimeHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ComboboxHelper

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = parse_html(sp_combobox_time)

    assert_css doc, "[data-controller='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = parse_html(sp_combobox_time)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_readonly
    doc     = parse_html(sp_combobox_time)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_trigger_has_haspopup_dialog
    doc = parse_html(sp_combobox_time)

    assert_css doc, "input[aria-haspopup='dialog']"
  end

  def test_renders_dialog_popover
    doc = parse_html(sp_combobox_time)

    assert_css doc, "[role='dialog']"
  end

  def test_popover_is_hidden_by_default
    doc     = parse_html(sp_combobox_time)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = parse_html(sp_combobox_time)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[role='dialog']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── drums ──────────────────────────────────────────────────────────────────

  def test_renders_hour_minute_period_drums_by_default
    doc = parse_html(sp_combobox_time)

    assert_css doc, "ul[role='listbox'][aria-label='Hour']"
    assert_css doc, "ul[role='listbox'][aria-label='Minute']"
    assert_css doc, "ul[role='listbox'][aria-label='Period']"
  end

  def test_h24_format_omits_period_drum
    doc = parse_html(sp_combobox_time(format: :h24))

    assert_css doc, "ul[aria-label='Hour']"
    assert_no_css doc, "ul[aria-label='Period']"
  end

  def test_h24_hour_drum_has_24_options
    doc   = parse_html(sp_combobox_time(format: :h24))
    items = doc.css("ul[aria-label='Hour'] li[role='option']")

    assert_equal 24, items.length
  end

  def test_minute_step_reduces_option_count
    doc   = parse_html(sp_combobox_time(step: 15))
    items = doc.css("ul[aria-label='Minute'] li[role='option']")

    assert_equal 4, items.length
  end

  def test_minute_step_items_are_correct
    doc    = parse_html(sp_combobox_time(step: 15))
    values = doc.css("ul[aria-label='Minute'] li[role='option']").map { |li| li["data-value"] }

    assert_equal %w[00 15 30 45], values
  end

  # ── pre-selection ─────────────────────────────────────────────────────────

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

  # ── value ─────────────────────────────────────────────────────────────────

  def test_value_in_hidden_input
    doc = parse_html(sp_combobox_time(value: "09:00"))

    assert_css doc, "input[type='hidden'][value='09:00']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = parse_html(sp_combobox_time(class: "my-timepicker"))

    assert_css doc, "[data-controller='input-combobox'].my-timepicker"
  end

  # ── ids ───────────────────────────────────────────────────────────────────

  def test_generates_unique_id_per_render
    html1 = sp_combobox_time
    html2 = sp_combobox_time

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end
end
