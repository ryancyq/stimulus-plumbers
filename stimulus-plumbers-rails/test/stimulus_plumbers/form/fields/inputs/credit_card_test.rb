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

  def test_renders_one_cell_per_group_with_dash_separators
    doc = build_field

    assert_equal 4, doc.css("[data-input-formatter-target='cell']").length
    assert_css doc, "[data-input-formatter-groups-value='[4,4,4,4]']"
  end

  def test_renders_separators_between_cells_only
    doc = build_field
    cells = doc.css("[data-input-formatter-target='cell']")
    separators = cells[0].parent.children.reject { |node| node["data-input-formatter-target"] == "cell" }

    assert_equal 3, separators.length
    separators.each do |separator|
      assert_equal "true", separator["aria-hidden"]
      assert_equal "-", separator.text
    end
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

  def test_rejects_floating_labels
    assert_raises(ArgumentError, "floating labels are not supported for credit card fields") { build_field(floating: :outlined) }
  end
end
