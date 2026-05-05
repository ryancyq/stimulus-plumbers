# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxTimeFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :time, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox(:meeting_time)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox(:meeting_time)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_readonly
    doc     = build_combobox(:meeting_time)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_trigger_has_haspopup_dialog
    doc = build_combobox(:meeting_time)

    assert_css doc, "input[aria-haspopup='dialog']"
  end

  def test_trigger_aria_expanded_false
    doc = build_combobox(:meeting_time)

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_renders_hidden_value_input
    doc = build_combobox(:meeting_time)

    assert_css doc, "input[type='hidden'][name='sign_in_form[meeting_time]']"
  end

  def test_trigger_input_is_input_format_target
    doc     = build_combobox(:meeting_time)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_includes trigger["data-input-format-target"].to_s, "input"
  end

  def test_hidden_input_is_input_combobox_value_target
    doc    = build_combobox(:meeting_time)
    hidden = doc.at_css("input[type='hidden'][name='sign_in_form[meeting_time]']")

    assert_not_nil hidden
    assert_includes hidden["data-input-combobox-target"].to_s, "value"
  end

  def test_renders_dialog_popover
    doc = build_combobox(:meeting_time)

    assert_css doc, "[role='dialog']"
  end

  def test_popover_is_hidden_by_default
    doc = build_combobox(:meeting_time)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_has_accessible_label
    doc = build_combobox(:meeting_time)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover["aria-label"]
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox(:meeting_time)
    trigger = doc.at_css("input[role='combobox']")
    popover   = doc.at_css("[role='dialog']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── drums ──────────────────────────────────────────────────────────────────

  def test_renders_timepicker_controller_inside_popup
    doc = build_combobox(:meeting_time)

    assert_css doc, "[role='dialog'] [data-controller='combobox-time']"
  end

  def test_renders_hour_drum
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[role='listbox'][aria-label='Hour']"
  end

  def test_renders_minute_drum
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[role='listbox'][aria-label='Minute']"
  end

  def test_renders_period_drum_for_h12_default
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[role='listbox'][aria-label='Period']"
  end

  def test_h12_hour_drum_has_twelve_options
    doc   = build_combobox(:meeting_time)
    items = doc.css("ul[aria-label='Hour'] li[role='option']")

    assert_equal 12, items.length
  end

  def test_hour_drum_ranges_from_1_to_12_in_h12_format
    doc   = build_combobox(:meeting_time)
    items = doc.css("ul[aria-label='Hour'] li[role='option']")

    values = items.map { |li| li["data-value"] }

    assert_includes values, "1"
    assert_includes values, "12"
  end

  def test_minute_drum_has_sixty_options_by_default
    doc   = build_combobox(:meeting_time)
    items = doc.css("ul[aria-label='Minute'] li[role='option']")

    assert_equal 60, items.length
  end

  def test_period_drum_has_am_and_pm
    doc  = build_combobox(:meeting_time)
    drum = doc.at_css("ul[aria-label='Period']")

    assert_not_nil drum
    assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='AM']"
    assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='PM']"
  end

  # ── pre-selection from value ───────────────────────────────────────────────

  def test_pre_selects_hour_from_value
    @form.define_singleton_method(:meeting_time) { "14:30" }
    doc = build_combobox(:meeting_time)

    # 14:00 → h12 hour = 2
    assert_css doc, "ul[aria-label='Hour'] li[role='option'][data-value='2'][aria-selected='true']"
  end

  def test_pre_selects_minute_from_value
    @form.define_singleton_method(:meeting_time) { "14:30" }
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[aria-label='Minute'] li[role='option'][data-value='30'][aria-selected='true']"
  end

  def test_pre_selects_period_pm_from_afternoon_value
    @form.define_singleton_method(:meeting_time) { "14:30" }
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='PM'][aria-selected='true']"
    assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='AM'][aria-selected='false']"
  end

  def test_pre_selects_period_am_from_morning_value
    @form.define_singleton_method(:meeting_time) { "09:00" }
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[aria-label='Period'] li[role='option'][data-value='AM'][aria-selected='true']"
  end

  def test_no_pre_selection_without_value
    doc = build_combobox(:meeting_time)

    assert_no_css doc, "ul[aria-label='Hour'] li[aria-selected='true']"
    assert_no_css doc, "ul[aria-label='Minute'] li[aria-selected='true']"
    assert_no_css doc, "ul[aria-label='Period'] li[aria-selected='true']"
  end

  # ── label / error ─────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:meeting_time)

    assert_css doc, "label[for='sign_in_form_meeting_time']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:meeting_time, "is invalid")
    doc = build_combobox(:meeting_time)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
