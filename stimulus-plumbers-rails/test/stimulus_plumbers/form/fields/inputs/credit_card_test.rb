# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class CreditCardTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/checkout") do |f|
      f.field(:card_number, as: :credit_card, **opts)
    end
    parse_html(html)
  end

  def card_input(doc)
    doc.at_css("input[type='text']")
  end

  def test_the_visible_input_carries_the_credit_card_formatter
    input = card_input(build_field)

    assert_equal "input-formatter", input["data-controller"]
    assert_equal "input", input["data-input-formatter-target"]
    assert_equal "creditCard", input["data-input-formatter-format-value"]
  end

  def test_input_reformats_on_input_and_form_reset
    actions = card_input(build_field)["data-action"].split

    assert_includes actions, "input->input-formatter#onInput"
    assert_includes actions, "form:reset->input-formatter#onFormReset"
  end

  def test_leaves_grouping_and_separator_to_the_formatter_by_default
    assert_equal "{}", card_input(build_field)["data-input-formatter-options-value"]
  end

  def test_passes_groups_and_separator_to_the_formatter
    input = card_input(build_field(groups: [4, 4, 4, 4, 3], separator: "-"))

    assert_equal(
      { "groups" => [4, 4, 4, 4, 3], "separator" => "-" },
      JSON.parse(input["data-input-formatter-options-value"])
    )
  end

  def test_uses_credit_card_browser_defaults
    input = card_input(build_field)

    assert_equal "cc-number", input["autocomplete"]
    assert_equal "numeric", input["inputmode"]
  end

  def test_has_no_maxlength_so_a_paste_reaches_the_formatter_whole
    refute card_input(build_field).key?("maxlength")
  end

  def test_rejects_groups_that_are_not_positive_integers
    assert_raises(ArgumentError, "groups must be an array of positive integers") { build_field(groups: [4, 0]) }
  end

  def test_renders_label_and_error_state
    @form.errors.add(:card_number, "is invalid")
    doc = build_field

    assert_css doc, "label[for='sign_in_form_card_number']"
    assert_css doc, "p[role='alert']"
    assert_equal "true", card_input(doc)["aria-invalid"]
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

  def test_floating_filled_renders_input_before_label
    html = build_field(floating: :filled).to_html

    assert_operator html.index("<input"), :<, html.index("<label")
  end

  def test_floating_outlined_renders_input_before_label
    html = build_field(floating: :outlined).to_html

    assert_operator html.index("<input"), :<, html.index("<label")
  end

  def test_floating_standard_renders_input_before_label
    html = build_field(floating: :standard).to_html

    assert_operator html.index("<input"), :<, html.index("<label")
  end
end
