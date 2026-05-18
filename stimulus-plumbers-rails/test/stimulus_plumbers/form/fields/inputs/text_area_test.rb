# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class TextAreaTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.text_area(:email, **opts)
    end
    parse_html(html)
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_textarea_element
    assert_css build_field, "textarea"
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_renders_textarea_with_correct_name
    assert_css build_field, "textarea[name='sign_in_form[email]']"
  end

  # ── hint ──────────────────────────────────────────────────────────────────

  def test_renders_hint_when_details_given
    assert_css build_field(details: "Enter your message"), "#sign_in_form_email_hint"
  end

  # ── error state ───────────────────────────────────────────────────────────

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

  # ── required ──────────────────────────────────────────────────────────────

  def test_required_sets_required_attribute
    textarea = build_field(required: true).at_css("textarea")

    assert_equal "required", textarea["required"]
  end

  def test_required_sets_aria_required
    textarea = build_field(required: true).at_css("textarea")

    assert_equal "true", textarea["aria-required"]
  end

  # ── label option ──────────────────────────────────────────────────────────

  def test_label_option_overrides_label_text
    assert_includes build_field(label: "Your message").text, "Your message"
  end
end
