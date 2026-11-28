# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class CodeTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

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

  def test_label_is_associated_with_the_input
    doc = build_field

    assert_equal doc.at_css("label")["for"], doc.at_css("input[type='text']")["id"]
  end

  def test_hint_and_error_are_associated_with_the_input
    @form.errors.add(:verification_code, "is invalid")
    described_by = build_field(hint: "Check your email").at_css("input[type='text']")["aria-describedby"]

    assert_includes described_by, "sign_in_form_verification_code_hint"
    assert_includes described_by, "sign_in_form_verification_code_error"
  end

  def container(doc)
    doc.at_css("[data-controller='input-formatter input-code']")
  end

  def cells(doc)
    doc.css("[data-input-code-target='cell']")
  end

  def test_wires_the_code_formatter_and_the_cells
    field = container(build_field)

    assert_equal "code", field["data-input-formatter-format-value"]
    assert_equal '{"charset":"digits","length":6}', field["data-input-formatter-options-value"]
  end

  def test_cells_redraw_after_every_format
    assert_equal "input-formatter:formatted->input-code#draw", container(build_field)["data-action"]
  end

  def test_renders_one_cell_per_code_character
    assert_equal 6, cells(build_field).length
  end

  def test_cells_wrapper_has_a_valid_class_attribute
    wrapper = cells(build_field).first.parent

    refute wrapper.key?("classes")
  end

  def test_input_has_otp_defaults
    input = build_field.at_css("input[type='text']")

    assert_equal "one-time-code", input["autocomplete"]
    assert_equal "numeric", input["inputmode"]
  end

  def test_has_no_maxlength_so_a_paste_reaches_the_formatter_whole
    refute build_field.at_css("input[type='text']").key?("maxlength")
  end

  def test_input_is_the_target_of_both_controllers
    input = build_field.at_css("input[type='text']")

    assert_equal "input", input["data-input-formatter-target"]
    assert_equal "input", input["data-input-code-target"]
  end

  def test_input_formats_on_input_and_redraws_the_cells_on_caret_moves
    actions = build_field.at_css("input[type='text']")["data-action"].split

    assert_includes actions, "input->input-formatter#onInput"
    assert_includes actions, "beforeinput->input-formatter#onBeforeinput"
    %w[focus blur select selectionchange keyup].each { |event| assert_includes actions, "#{event}->input-code#draw" }
  end

  def test_input_reformats_on_form_reset
    assert_includes build_field.at_css("input[type='text']")["data-action"], "form:reset->input-formatter#onFormReset"
  end

  def test_the_last_cell_of_each_group_but_the_final_one_marks_the_gap
    marks = cells(build_field(groups: [2, 2, 2])).map { |cell| cell.key?("data-group-end") }

    assert_equal [false, true, false, true, false, false], marks
  end

  def separators_in(doc)
    cells(doc)[0].parent.children.reject { |node| node["data-input-code-target"] == "cell" }
  end

  def test_code_renders_no_separators_by_default
    assert_empty separators_in(build_field(groups: [3, 3]))
  end

  def test_opting_into_a_separator_marks_the_group_breaks
    doc = build_field(groups: [3, 3], separator: "-")
    separator = separators_in(doc).first

    assert_equal 6, cells(doc).length
    assert_equal "-", separator.text
    assert_equal "true", separator["aria-hidden"]
  end

  def test_a_separator_replaces_the_gap
    marks = cells(build_field(groups: [3, 3], separator: "-")).map { |cell| cell.key?("data-group-end") }

    assert_equal [false] * 6, marks
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
