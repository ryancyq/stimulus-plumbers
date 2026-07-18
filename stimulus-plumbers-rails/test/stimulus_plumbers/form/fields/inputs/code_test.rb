# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class CodeTest < ActionView::TestCase
  def setup = @form = FormBuilderModel.new

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:verification_code, as: :code, length: 6, **opts)
    end
    parse_html(html)
  end

  def test_renders_label_and_accessible_input
    doc = build_field

    assert_css doc, "label[for='sign_in_form_verification_code']"
    assert_css doc, "input[type='text'][name='sign_in_form[verification_code]']"
  end

  def test_wires_input_formatter_for_code
    doc = build_field

    assert_css doc, "[data-controller='input-formatter'][data-input-formatter-format-value='code']"
    wrapper = doc.at_css("[data-controller='input-formatter']")

    assert_equal '{"charset":"digits","length":6}', wrapper["data-input-formatter-options-value"]
  end

  def test_renders_one_cell_per_code_character
    assert_equal 6, build_field.css("[data-input-formatter-target='cell']").length
  end

  def test_cells_wrapper_has_a_valid_class_attribute
    wrapper = build_field.at_css("[data-input-formatter-target='cell']").parent

    refute wrapper.key?("classes")
  end

  def test_input_has_otp_defaults
    input = build_field.at_css("input[type='text']")

    assert_equal "one-time-code", input["autocomplete"]
    assert_equal "numeric", input["inputmode"]
    assert_equal "6", input["maxlength"]
  end

  def test_input_wires_format_and_caret_actions
    input = build_field.at_css("input[type='text']")

    assert_includes input["data-action"], "input->input-formatter#onInput"
    assert_includes input["data-action"], "focus->input-formatter#onFocus"
    assert_includes input["data-action"], "blur->input-formatter#onBlur"
  end

  def test_groups_are_passed_to_the_controller
    assert_css build_field(groups: [3, 3]), "[data-input-formatter-groups-value='[3,3]']"
  end

  def test_alphanumeric_code_does_not_force_numeric_inputmode
    assert_nil build_field(charset: :alphanumeric).at_css("input[type='text']")["inputmode"]
  end

  def test_forwards_custom_input_attributes
    input = build_field(autocomplete: "off", inputmode: "text", data: { controller: "validator" }).at_css("input[type='text']")

    assert_equal "off", input["autocomplete"]
    assert_equal "text", input["inputmode"]
    assert_includes input["data-controller"], "validator"
  end

  def test_renders_error_state
    @form.errors.add(:verification_code, "is invalid")
    doc = build_field

    assert_css doc, "p[role='alert']"
    assert_equal "true", doc.at_css("input[type='text']")["aria-invalid"]
  end

  def test_rejects_groups_that_do_not_match_length
    assert_raises(ArgumentError, "groups must add up to length") { build_field(groups: [4, 4]) }
  end

  def test_rejects_floating_labels
    assert_raises(ArgumentError, "floating labels are not supported for code fields") { build_field(floating: :outlined) }
  end
end
