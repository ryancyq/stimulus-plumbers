# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class FormFieldsTextAreaTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_native(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.text_area(:email, **opts)
    end
    parse_html(html)
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:email, as: :text_area, **opts)
    end
    parse_html(html)
  end

  def test_renders_textarea_element
    assert_css build_native, "textarea"
  end

  def test_renders_textarea_with_correct_name
    assert_css build_native, "textarea[name='sign_in_form[email]']"
  end

  def test_forwards_rows_to_textarea
    assert_equal "6", build_native(rows: 6).at_css("textarea")["rows"]
  end

  def test_forwards_cols_to_textarea
    assert_equal "40", build_native(cols: 40).at_css("textarea")["cols"]
  end

  def test_forwards_placeholder_to_textarea
    assert_equal "Write here", build_native(placeholder: "Write here").at_css("textarea")["placeholder"]
  end

  def test_forwards_data_attributes_to_textarea
    assert_equal "autogrow", build_native(data: { controller: "autogrow" }).at_css("textarea")["data-controller"]
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_renders_hint_when_details_given
    assert_css build_field(hint: "Enter your message"), "#sign_in_form_email_hint"
  end

  def test_aria_describedby_references_hint_id
    assert_includes build_field(hint: "Enter your message").at_css("textarea")["aria-describedby"].to_s,
                    "sign_in_form_email_hint"
  end

  def test_renders_error_message
    @form.errors.add(:email, "is too short")

    assert_css build_field, "p[role='alert']"
  end

  def test_has_aria_invalid_on_error
    @form.errors.add(:email, "is too short")

    assert_equal "true", build_field.at_css("textarea")["aria-invalid"]
  end

  def test_has_aria_describedby_pointing_to_error_id
    @form.errors.add(:email, "is too short")

    assert_includes build_field.at_css("textarea")["aria-describedby"].to_s,
                    "sign_in_form_email_error"
  end

  def test_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:email, "is too short")
    @form.errors.add(:email, "has already been taken")
    described_by = build_field.at_css("textarea")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_email_error_1"
    assert_includes described_by, "sign_in_form_email_error_2"
  end

  def test_multiple_error_elements_have_matching_ids
    @form.errors.add(:email, "is too short")
    @form.errors.add(:email, "has already been taken")
    doc = build_field

    assert_css doc, "#sign_in_form_email_error_1"
    assert_css doc, "#sign_in_form_email_error_2"
  end

  def test_required_sets_required_attribute
    assert_equal "required", build_field(required: true).at_css("textarea")["required"]
  end

  def test_not_required_omits_required_attribute
    assert_nil build_field.at_css("textarea")["required"]
  end

  def test_not_required_omits_aria_required
    assert_nil build_field.at_css("textarea")["aria-required"]
  end

  def test_required_sets_aria_required
    assert_equal "true", build_field(required: true).at_css("textarea")["aria-required"]
  end

  def test_required_renders_mark_in_label
    assert_css build_field(required: true), "label span[aria-hidden='true']"
  end

  def test_label_option_overrides_label_text
    assert_includes build_field(label: "Your message").text, "Your message"
  end

  def test_hide_label_keeps_label_in_dom
    assert_css build_field(hide_label: true), "label[for='sign_in_form_email']"
  end

  def test_error_override_renders_error_message
    assert_includes build_field(error: "Too short").text, "Too short"
  end

  def test_error_override_sets_aria_invalid
    assert_equal "true", build_field(error: "bad").at_css("textarea")["aria-invalid"]
  end

  def test_floating_variant_renders_input_before_label
    doc = build_field(variant: :floating_filled)

    assert_operator doc.to_html.index("<textarea"), :<, doc.to_html.index("<label")
  end

  def test_aria_describedby_references_hint_and_error_ids
    @form.errors.add(:email, "is too short")
    doc          = build_field(hint: "Enter your message")
    described_by = doc.at_css("textarea")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_email_hint"
    assert_includes described_by, "sign_in_form_email_error"
  end
end
