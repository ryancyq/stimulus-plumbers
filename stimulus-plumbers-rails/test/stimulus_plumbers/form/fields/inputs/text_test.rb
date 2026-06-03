# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class FormFieldsTextTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_native(method, attribute = :email, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.public_send(method, attribute, **opts)
    end
    parse_html(html)
  end

  def build_field(attribute = :email, as:, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(attribute, as: as, **opts)
    end
    parse_html(html)
  end

  def test_renders_label
    assert_css build_field(as: :email), "label[for='sign_in_form_email']"
  end

  def test_label_option_sets_label_text
    assert_includes build_field(as: :email, label: "E-mail").text, "E-mail"
  end

  def test_renders_hint_when_details_given
    assert_css build_field(as: :email, hint: "We'll never share your email"), "#sign_in_form_email_hint"
  end

  def test_aria_describedby_references_hint_id
    doc = build_field(as: :email, hint: "We'll never share your email")

    assert_includes doc.at_css("input[type='email']")["aria-describedby"].to_s, "sign_in_form_email_hint"
  end

  def test_renders_error_message
    @form.errors.add(:email, "is invalid")

    assert_css build_field(as: :email), "p[role='alert']"
    assert_includes build_field(as: :email).text, "is invalid"
  end

  def test_has_aria_invalid_on_error
    @form.errors.add(:email, "is invalid")

    assert_equal "true", build_field(as: :email).at_css("input[type='email']")["aria-invalid"]
  end

  def test_has_aria_describedby_pointing_to_error_id
    @form.errors.add(:email, "is invalid")

    assert_includes build_field(as: :email).at_css("input[type='email']")["aria-describedby"].to_s,
                    "sign_in_form_email_error"
  end

  def test_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "has already been taken")
    doc          = build_field(as: :email)
    described_by = doc.at_css("input[type='email']")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_email_error_1"
    assert_includes described_by, "sign_in_form_email_error_2"
  end

  def test_multiple_error_elements_have_matching_ids
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "has already been taken")
    doc = build_field(as: :email)

    assert_css doc, "#sign_in_form_email_error_1"
    assert_css doc, "#sign_in_form_email_error_2"
  end

  def test_required_sets_required_attribute
    input = build_field(as: :email, required: true).at_css("input[type='email']")

    assert_equal "required", input["required"]
  end

  def test_not_required_omits_required_attribute
    assert_nil build_field(as: :email).at_css("input[type='email']")["required"]
  end

  def test_not_required_omits_aria_required
    assert_nil build_field(as: :email).at_css("input[type='email']")["aria-required"]
  end

  def test_required_sets_aria_required
    input = build_field(as: :email, required: true).at_css("input[type='email']")

    assert_equal "true", input["aria-required"]
  end

  def test_required_renders_mark_in_label
    assert_css build_field(as: :email, required: true), "label span[aria-hidden='true']"
  end

  def test_hide_label_keeps_label_in_dom
    assert_css build_field(as: :email, hide_label: true), "label[for='sign_in_form_email']"
  end

  def test_error_override_renders_error_message
    assert_includes build_field(as: :email, error: "Something went wrong").text, "Something went wrong"
  end

  def test_error_override_sets_aria_invalid
    assert_equal "true", build_field(as: :email, error: "bad").at_css("input[type='email']")["aria-invalid"]
  end

  def test_forwards_placeholder_to_input
    input = build_native(:email_field, :email, placeholder: "you@example.com").at_css("input[type='email']")

    assert_equal "you@example.com", input["placeholder"]
  end

  def test_forwards_autocomplete_to_input
    assert_equal "email",
                 build_native(:email_field, :email, autocomplete: "email").at_css("input[type='email']")["autocomplete"]
  end

  def test_forwards_class_to_input
    assert_includes build_native(:email_field, :email, class: "custom").at_css("input[type='email']")["class"].to_s,
                    "custom"
  end

  def test_forwards_data_attributes_to_input
    input = build_native(:email_field, :email, data: { controller: "my-ctrl" }).at_css("input[type='email']")

    assert_equal "my-ctrl", input["data-controller"]
  end

  def test_number_field_forwards_min
    assert_equal "0", build_native(:number_field, :age, min: 0).at_css("input[type='number']")["min"]
  end

  def test_number_field_forwards_max
    assert_equal "120", build_native(:number_field, :age, max: 120).at_css("input[type='number']")["max"]
  end

  def test_number_field_forwards_step
    assert_equal "5", build_native(:number_field, :age, step: 5).at_css("input[type='number']")["step"]
  end

  def test_range_field_forwards_min_and_max
    input = build_native(:range_field, :age, min: 1, max: 100).at_css("input[type='range']")

    assert_equal "1",   input["min"]
    assert_equal "100", input["max"]
  end

  def test_text_field_renders_text_input
    assert_css build_native(:text_field), "input[type='text']"
  end

  def test_email_field_renders_email_input
    assert_css build_native(:email_field), "input[type='email']"
  end

  def test_url_field_renders_url_input
    assert_css build_native(:url_field), "input[type='url']"
  end

  def test_telephone_field_renders_tel_input
    assert_css build_native(:telephone_field), "input[type='tel']"
  end

  def test_number_field_renders_number_input
    assert_css build_native(:number_field), "input[type='number']"
  end

  def test_range_field_renders_range_input
    assert_css build_native(:range_field), "input[type='range']"
  end

  def test_color_field_renders_color_input
    assert_css build_native(:color_field), "input[type='color']"
  end

  def test_month_field_renders_month_input
    assert_css build_native(:month_field), "input[type='month']"
  end

  def test_week_field_renders_week_input
    assert_css build_native(:week_field), "input[type='week']"
  end

  def test_datetime_local_field_renders_datetime_local_input
    assert_css build_native(:datetime_local_field), "input[type='datetime-local']"
  end

  def test_floating_filled_variant_renders_input_before_label
    doc = build_field(as: :text, variant: :floating_filled)

    assert_operator doc.to_html.index("<input"), :<, doc.to_html.index("<label")
  end

  def test_floating_outlined_variant_renders_input_before_label
    doc = build_field(as: :text, variant: :floating_outlined)

    assert_operator doc.to_html.index("<input"), :<, doc.to_html.index("<label")
  end

  def test_floating_standard_variant_renders_input_before_label
    doc = build_field(as: :text, variant: :floating_standard)

    assert_operator doc.to_html.index("<input"), :<, doc.to_html.index("<label")
  end

  def test_aria_describedby_references_hint_and_error_ids
    @form.errors.add(:email, "is invalid")
    doc          = build_field(as: :email, hint: "We'll never share your email")
    described_by = doc.at_css("input[type='email']")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_email_hint"
    assert_includes described_by, "sign_in_form_email_error"
  end
end
