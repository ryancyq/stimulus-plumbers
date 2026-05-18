# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class FileFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.file_field(:email, **opts)
    end
    parse_html(html)
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_file_input
    assert_css build_field, "input[type='file']"
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  # ── hint ──────────────────────────────────────────────────────────────────

  def test_renders_hint_when_details_given
    assert_css build_field(details: "Accepted formats: PDF, PNG"), "#sign_in_form_email_hint"
  end

  # ── error state ───────────────────────────────────────────────────────────

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

  # ── required ──────────────────────────────────────────────────────────────

  def test_required_sets_required_attribute
    input = build_field(required: true).at_css("input[type='file']")

    assert_equal "required", input["required"]
  end

  def test_required_sets_aria_required
    input = build_field(required: true).at_css("input[type='file']")

    assert_equal "true", input["aria-required"]
  end

  def test_not_required_omits_required_attribute
    input = build_field.at_css("input[type='file']")

    assert_nil input["required"]
  end

  def test_not_required_omits_aria_required
    input = build_field.at_css("input[type='file']")

    assert_nil input["aria-required"]
  end
end
