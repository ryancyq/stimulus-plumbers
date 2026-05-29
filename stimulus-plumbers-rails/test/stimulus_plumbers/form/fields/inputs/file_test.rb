# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class FileFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  # native ActionView helper — theme classes only, no label/hint/error wrapper
  def build_native(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.file_field(:email, **opts)
    end
    parse_html(html)
  end

  # f.field — full wrapper: label + input + hint + error
  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:email, as: :file, **opts)
    end
    parse_html(html)
  end

  # ── native file input ──────────────────────────────────────────────────────

  def test_renders_file_input
    assert_css build_native, "input[type='file']"
  end

  def test_forwards_accept_to_input
    assert_equal "image/*", build_native(accept: "image/*").at_css("input[type='file']")["accept"]
  end

  def test_forwards_multiple_to_input
    assert build_native(multiple: true).at_css("input[type='file']").key?("multiple"), "Expected multiple attribute"
  end

  def test_forwards_data_attributes_to_input
    assert_equal "uploader",
                 build_native(data: { controller: "uploader" }).at_css("input[type='file']")["data-controller"]
  end

  # ── f.field(as: :file) — label + input + hint + error ───────────────────

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_renders_hint_when_details_given
    assert_css build_field(hint: "Accepted formats: PDF, PNG"), "#sign_in_form_email_hint"
  end

  def test_renders_error_message
    @form.errors.add(:email, "is required")

    assert_css build_field, "p[role='alert']"
  end

  def test_has_aria_invalid_on_error
    @form.errors.add(:email, "is required")

    assert_equal "true", build_field.at_css("input[type='file']")["aria-invalid"]
  end

  def test_has_aria_describedby_pointing_to_error_id
    @form.errors.add(:email, "is required")

    assert_includes build_field.at_css("input[type='file']")["aria-describedby"].to_s,
                    "sign_in_form_email_error"
  end

  def test_required_sets_required_attribute
    assert_equal "required", build_field(required: true).at_css("input[type='file']")["required"]
  end

  def test_required_sets_aria_required
    assert_equal "true", build_field(required: true).at_css("input[type='file']")["aria-required"]
  end

  def test_not_required_omits_required_attribute
    assert_nil build_field.at_css("input[type='file']")["required"]
  end

  def test_not_required_omits_aria_required
    assert_nil build_field.at_css("input[type='file']")["aria-required"]
  end

  def test_label_option_overrides_label_text
    assert_includes build_field(label: "Upload file").text, "Upload file"
  end
end
