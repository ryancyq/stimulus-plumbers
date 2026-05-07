# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :date, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:birthday)

    assert_css doc, "label[for='sign_in_form_birthday']"
  end

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox(:birthday)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox(:birthday)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_renders_trigger_input_with_aria_expanded_false
    doc = build_combobox(:birthday)

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_trigger_has_haspopup_dialog
    doc = build_combobox(:birthday)

    assert_css doc, "input[aria-haspopup='dialog']"
  end

  def test_trigger_is_readonly
    doc     = build_combobox(:birthday)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_renders_hidden_value_input
    doc = build_combobox(:birthday)

    assert_css doc, "input[type='hidden'][name='sign_in_form[birthday]']"
  end

  def test_renders_dialog_popover
    doc = build_combobox(:birthday)

    assert_css doc, "[role='dialog']"
  end

  def test_popover_is_hidden_by_default
    doc = build_combobox(:birthday)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_has_accessible_label
    doc = build_combobox(:birthday)
    popover = doc.at_css("[role='dialog']")

    assert_not_nil popover
    assert_not_nil popover["aria-label"], "Expected popover to have aria-label"
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox(:birthday)
    trigger = doc.at_css("input[role='combobox']")
    popover   = doc.at_css("[role='dialog']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  def test_renders_navigation_inside_popup
    doc = build_combobox(:birthday)

    assert_css doc, "[role='dialog'] nav"
  end

  def test_renders_calendar_month_inside_popup
    doc = build_combobox(:birthday)

    assert_css doc, "[role='dialog'] [data-controller~='calendar-month']"
  end

  # ── cross-wiring ──────────────────────────────────────────────────────────

  def test_trigger_input_is_input_format_target
    doc     = build_combobox(:birthday)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_includes trigger["data-input-format-target"].to_s, "input"
  end

  def test_hidden_input_is_input_combobox_value_target
    doc    = build_combobox(:birthday)
    hidden = doc.at_css("input[type='hidden'][name='sign_in_form[birthday]']")

    assert_not_nil hidden
    assert_includes hidden["data-input-combobox-target"].to_s, "value"
  end

  # ── error state ──────────────────────────────────────────────────────────

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:birthday, "is invalid")
    doc = build_combobox(:birthday)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end

  # ── label options ─────────────────────────────────────────────────────────

  def test_renders_custom_label_text
    doc = build_combobox(:birthday, label: "Date of Birth")

    assert_includes doc.text, "Date of Birth"
  end

  def test_renders_details_hint
    doc = build_combobox(:birthday, details: "Select your birthday")

    assert_css doc, "#sign_in_form_birthday_hint"
  end

  # ── unsupported type ──────────────────────────────────────────────────────

  def test_raises_for_unsupported_type
    assert_raises(ArgumentError) do
      view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
        f.combobox_field(:birthday, type: :unknown)
      end
    end
  end
end
