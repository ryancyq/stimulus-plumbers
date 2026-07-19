# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class CreditCardTest < ActionView::TestCase
  def setup = @form = FormBuilderModel.new

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/checkout") do |f|
      f.field(:card_number, as: :credit_card, **opts)
    end
    parse_html(html)
  end

  def test_wires_credit_card_formatter
    assert_css build_field, "[data-controller='input-formatter'][data-input-formatter-format-value='creditCard']"
  end

  def test_renders_one_cell_per_group
    doc = build_field

    assert_equal 4, doc.css("[data-input-formatter-target='cell']").length
    assert_css doc, "[data-input-formatter-groups-value='[4,4,4,4]']"
  end

  def separators_in(doc)
    cells = doc.css("[data-input-formatter-target='cell']")
    cells[0].parent.children.reject { |node| node["data-input-formatter-target"] == "cell" }
  end

  def test_cell_borders_carry_the_grouping_without_a_separator_character
    assert_empty separators_in(build_field)
  end

  def test_renders_separators_between_cells_only
    separators = separators_in(build_field(separator: "-"))

    assert_equal 3, separators.length
    separators.each do |separator|
      assert_equal "true", separator["aria-hidden"]
      assert_equal "-", separator.text
    end
  end

  def test_separator_character_is_configurable
    separators = separators_in(build_field(separator: "/"))

    assert_equal 3, separators.length
    separators.each { |separator| assert_equal "/", separator.text }
  end

  def test_cells_wrapper_has_a_valid_class_attribute
    wrapper = build_field.at_css("[data-input-formatter-target='cell']").parent

    refute wrapper.key?("classes")
  end

  def test_uses_credit_card_browser_defaults
    input = build_field.at_css("input[type='text']")

    assert_equal "cc-number", input["autocomplete"]
    assert_equal "numeric", input["inputmode"]
    assert_equal "16", input["maxlength"]
  end

  def test_supports_nonstandard_card_grouping
    doc = build_field(groups: [4, 4, 4, 4, 3])

    assert_equal 5, doc.css("[data-input-formatter-target='cell']").length
    assert_equal "19", doc.at_css("input[type='text']")["maxlength"]
    assert_css doc, "[data-input-formatter-groups-value='[4,4,4,4,3]']"
  end

  def test_renders_label_and_error_state
    @form.errors.add(:card_number, "is invalid")
    doc = build_field

    assert_css doc, "label[for='sign_in_form_card_number']"
    assert_css doc, "p[role='alert']"
    assert_equal "true", doc.at_css("input[type='text']")["aria-invalid"]
  end

  def test_label_is_associated_with_the_input
    doc = build_field

    assert_equal doc.at_css("label")["for"], doc.at_css("input[type='text']")["id"]
  end

  def test_hint_and_error_are_associated_with_the_input
    @form.errors.add(:card_number, "is invalid")
    described_by = build_field(hint: "16 digits on the front").at_css("input[type='text']")["aria-describedby"]

    assert_includes described_by, "sign_in_form_card_number_hint"
    assert_includes described_by, "sign_in_form_card_number_error"
  end

  def test_rejects_floating_labels
    assert_raises(ArgumentError, "floating labels are not supported for credit card fields") { build_field(floating: :outlined) }
  end
end
