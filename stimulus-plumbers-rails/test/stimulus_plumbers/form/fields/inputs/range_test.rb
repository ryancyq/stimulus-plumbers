# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

# A range is a real form control, unlike the progress field — it keeps a native
# <label for>, and the controller must never write aria-value* over the native
# slider semantics.
class FormFieldsRangeTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
    @form.volume = 45
  end

  def build_native(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.range_field(:volume, **opts)
    end
    parse_html(html)
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:volume, as: :range, min: 0, max: 100, **opts)
    end
    parse_html(html)
  end

  def test_range_field_renders_range_input
    assert_css build_native, "input[type='range']"
  end

  def test_range_field_forwards_min_and_max
    input = build_native(min: 1, max: 100).at_css("input[type='range']")

    assert_equal "1",   input["min"]
    assert_equal "100", input["max"]
  end

  # A bare range has no readout or gradient to drive, so it needs no controller.
  def test_native_range_field_is_not_wired_to_the_controller
    assert_nil build_native.at_css("input[type='range']")["data-controller"]
  end

  # A range is a labelable element, so it keeps a real <label for> in both hide_label states.
  def test_hidden_label_keeps_the_native_association
    doc = build_field(hide_label: true)

    assert_equal "sign_in_form_volume", doc.at_css("label")["for"]
    assert_equal "Volume", doc.at_css("label").text.strip
    assert_nil doc.at_css("input[type='range']")["aria-labelledby"]
  end

  def test_required_keeps_control_attributes_and_marker
    doc = build_field(required: true)

    assert_equal "required", doc.at_css("input[type='range']")["required"]
    assert_equal "true", doc.at_css("input[type='range']")["aria-required"]
    assert_css doc, "label span[aria-hidden='true']"
  end

  def test_hint_and_error_are_described_by_the_input
    @form.errors.add(:volume, "is too loud")
    described = build_field(hint: "Drag to adjust").at_css("input[type='range']")["aria-describedby"].to_s

    assert_includes described, "sign_in_form_volume_hint"
    assert_includes described, "sign_in_form_volume_error"
  end

  def test_keeps_a_native_label_association
    doc = build_field

    assert_equal "sign_in_form_volume", doc.at_css("label")["for"]
    assert_nil doc.at_css("[aria-labelledby]")
  end

  def test_leaves_slider_semantics_to_the_native_input
    input = build_field.at_css("input[type='range']")

    assert_nil input["aria-valuenow"]
    assert_nil input["aria-valuemin"]
    assert_nil input["aria-valuemax"]
    assert_nil input["role"]
  end

  def test_without_a_readout_hosts_the_controller_on_the_input
    doc = build_field

    assert_equal "progress", doc.at_css("input[type='range']")["data-controller"]
    assert_nil doc.at_css("[data-progress-target='value']")
  end

  def test_readout_is_contained_by_the_controller_element
    host = build_field(format: :percent).at_css("[data-controller='progress']")

    assert host.at_css("[data-progress-target='value']"), "value target must be inside the controller"
    assert host.at_css("input[type='range'][data-progress-target='input']")
  end

  def test_readout_is_hidden_from_assistive_technology
    readout = build_field(format: :percent).at_css("[data-progress-target='value']")

    assert_equal "true", readout["aria-hidden"]
    assert_equal "45%", readout.text
  end

  def test_readout_renders_server_side_for_each_format
    assert_equal "45",       build_field(format: :value).at_css("[data-progress-target='value']").text
    assert_equal "45 / 100", build_field(format: :value_max).at_css("[data-progress-target='value']").text
  end

  # The input carries the track gradient, so the property has to land there, not on the wrapper.
  def test_fill_percentage_is_server_rendered_on_the_input
    doc = build_field(format: :percent)

    assert_match(%r{--sp-progress-percent:\s*45}, doc.at_css("input[type='range']")["style"])
    refute_match(%r{--sp-progress-percent}, doc.at_css("[data-controller='progress']")["style"].to_s)
  end

  def test_fill_percentage_scales_against_a_non_zero_minimum
    @form.volume = 30

    assert_match(%r{--sp-progress-percent:\s*50}, build_field(min: 20, max: 40).at_css("input[type='range']")["style"])
  end

  def test_rejects_an_unknown_format
    assert_raises(ArgumentError) { build_field(format: :bogus) }
  end

  # A step: 0.1 range holds 45.5 — truncating would paint a 45 fill under a 45.5 thumb.
  def test_fractional_values_are_not_truncated
    @form.volume = 45.5
    doc = build_field(format: :value, step: 0.1)

    assert_equal "45.5", doc.at_css("[data-progress-target='value']").text
    assert_match(%r{--sp-progress-percent:\s*45.5}, doc.at_css("input[type='range']")["style"])
  end

  def test_a_string_attribute_value_is_coerced
    @form.volume = "45.5"

    assert_equal "45.5", build_field(format: :value).at_css("[data-progress-target='value']").text
  end

  def test_a_blank_attribute_value_falls_back_to_the_minimum
    @form.volume = nil

    assert_equal "20", build_field(min: 20, max: 40, format: :value).at_css("[data-progress-target='value']").text
  end
end
