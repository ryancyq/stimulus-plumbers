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

  def test_renders_label
    doc = build_combobox(:meeting_time)

    assert_css doc, "label[for='sign_in_form_meeting_time']"
  end

  def test_renders_hidden_value_input_with_model_name
    doc = build_combobox(:meeting_time)

    assert_css doc, "input[type='hidden'][name='sign_in_form[meeting_time]']"
  end

  def test_hidden_input_is_value_target
    doc    = build_combobox(:meeting_time)
    hidden = doc.at_css("input[type='hidden'][name='sign_in_form[meeting_time]']")

    assert_not_nil hidden
    assert_includes hidden["data-input-combobox-target"].to_s, "value"
  end

  def test_trigger_is_input_format_target
    doc     = build_combobox(:meeting_time)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_includes trigger["data-input-format-target"].to_s, "input"
  end

  def test_pre_selects_drums_from_model_value
    @form.define_singleton_method(:meeting_time) { "14:30" }
    doc = build_combobox(:meeting_time)

    assert_css doc, "ul[aria-label='Hour']   li[data-value='2'][aria-selected='true']"
    assert_css doc, "ul[aria-label='Minute'] li[data-value='30'][aria-selected='true']"
    assert_css doc, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:meeting_time, "is invalid")
    doc = build_combobox(:meeting_time)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
