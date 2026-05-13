# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class BuilderTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  # ── Helpers ────────────────────────────────────────────────────────────────

  def build_field(method_name, attribute, *args, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.public_send(method_name, attribute, *args, **opts)
    end
    parse_html(html)
  end

  def build_form(&block)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session", &block)
    parse_html(html)
  end

  # ── FieldComponent integration ─────────────────────────────────────────────

  def test_email_field_renders_label_for_input
    doc = build_field(:email_field, :email)

    assert_css doc, "label[for='sign_in_form_email']"
    assert_css doc, "input[type='email'][name='sign_in_form[email]']"
  end

  def test_field_renders_custom_label_text
    doc = build_field(:email_field, :email, label: "Email address")

    assert_includes doc.text, "Email address"
  end

  def test_field_renders_details_hint
    doc = build_field(:email_field, :email, details: "We'll never share your email.")

    assert_css doc, "#sign_in_form_email_hint"
    assert_includes doc.text, "We'll never share your email."
  end

  def test_field_renders_required_indicator
    doc = build_field(:email_field, :email, required: true)

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.css("span[aria-hidden='true']").text, "*"
  end

  def test_field_renders_model_error
    @form.errors.add(:email, "is invalid")
    doc = build_field(:email_field, :email)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end

  def test_field_renders_error_override
    doc = build_field(:email_field, :email, error: "Something went wrong")

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "Something went wrong"
  end

  def test_hidden_field_renders_without_field_wrapper
    doc = build_field(:hidden_field, :email)

    assert_css doc, "input[type='hidden']"
    assert_no_css doc, "label"
  end

  # ── password_field ────────────────────────────────────────────────────────

  def test_password_field_renders_with_label
    doc = build_field(:password_field, :password)

    assert_css doc, "input[type='password']"
    assert_css doc, "label"
  end

  # ── text_area auto-resize ─────────────────────────────────────────────────

  def test_text_area_renders_with_label
    doc = build_field(:text_area, :email)

    assert_css doc, "textarea"
    assert_css doc, "label"
  end

  # ── aria-describedby ──────────────────────────────────────────────────────

  def test_input_has_aria_describedby_for_hint
    doc = build_field(:email_field, :email, details: "Hint text")

    input = doc.at_css("input[type='email']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_email_hint"
  end

  def test_input_has_aria_describedby_for_error
    @form.errors.add(:email, "is invalid")
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_email_error"
  end

  def test_input_has_no_aria_describedby_without_hint_or_error
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_nil input["aria-describedby"]
  end

  # ── aria-invalid ──────────────────────────────────────────────────────────

  def test_input_has_aria_invalid_when_model_has_errors
    @form.errors.add(:email, "is invalid")
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_equal "true", input["aria-invalid"]
  end

  def test_input_has_no_aria_invalid_without_model_errors
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_nil input["aria-invalid"]
  end

  def test_check_box_has_aria_invalid_when_model_has_errors
    @form.errors.add(:remember_me, "must be accepted")
    doc = build_field(:check_box, :remember_me)

    input = doc.at_css("input[type='checkbox']")

    assert_equal "true", input["aria-invalid"]
  end

  def test_check_box_has_aria_describedby_for_error
    @form.errors.add(:remember_me, "must be accepted")
    doc = build_field(:check_box, :remember_me)

    input = doc.at_css("input[type='checkbox']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_remember_me_error"
  end

  def test_radio_button_has_aria_invalid_when_model_has_errors
    @form.errors.add(:role, "is not included in the list")
    doc = build_field(:radio_button, :role, "admin")

    input = doc.at_css("input[type='radio']")

    assert_equal "true", input["aria-invalid"]
  end

  def test_radio_button_has_aria_describedby_for_error
    @form.errors.add(:role, "is not included in the list")
    doc = build_field(:radio_button, :role, "admin")

    input = doc.at_css("input[type='radio']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_role_admin_error"
  end

  # ── required forwarding ───────────────────────────────────────────────────

  def test_required_field_has_required_attribute
    doc = build_field(:email_field, :email, required: true)

    input = doc.at_css("input[type='email']")

    assert_equal "required", input["required"]
  end

  def test_required_field_has_aria_required
    doc = build_field(:email_field, :email, required: true)

    input = doc.at_css("input[type='email']")

    assert_equal "true", input["aria-required"]
  end

  def test_optional_field_omits_required_attributes
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_nil input["required"]
    assert_nil input["aria-required"]
  end

  def test_check_box_required_sets_required_and_aria_required
    doc = build_field(:check_box, :remember_me, required: true)

    input = doc.at_css("input[type='checkbox']")

    assert_equal "required", input["required"]
    assert_equal "true", input["aria-required"]
  end

  # ── label_visibility ──────────────────────────────────────────────────────

  def test_exclusive_label_visibility_keeps_label_in_dom
    doc = build_field(:email_field, :email, label_visibility: :exclusive)

    assert_css doc, "label[for='sign_in_form_email']"
  end

  # ── extract_options ───────────────────────────────────────────────────────

  def test_extract_options_separates_form_field_keys
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})

    rails, form_field = builder.send(:extract_options, { label: "Email", required: true, class: "custom", id: "my-id" })

    assert_equal({ class: "custom", id: "my-id" }, rails)
    assert_equal({ label: "Email", required: true }, form_field)
  end

  def test_extract_options_leaves_rails_options_intact
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})

    rails, form_field = builder.send(:extract_options, { autocomplete: "email", placeholder: "you@example.com" })

    assert_equal({ autocomplete: "email", placeholder: "you@example.com" }, rails)
    assert_empty form_field
  end

  # ── submit ────────────────────────────────────────────────────────────────

  def test_submit_renders_submit_input
    doc = build_form { |f| f.submit "Save" }

    assert_css doc, "input[type='submit'][value='Save']"
  end

  def test_submit_uses_default_value_when_omitted
    doc = build_form(&:submit)

    assert_css doc, "input[type='submit']"
  end

  def test_submit_default_variant_applies_link_classes
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/") { |f| f.submit "Save" }

    assert_includes html, "hover:underline"
  end

  def test_submit_button_variant_applies_button_classes
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/") do |f|
      f.submit "Save", variant: :button
    end

    assert_includes html, "inline-flex"
  end

  # ── build_field / error? ──────────────────────────────────────────────────

  def test_build_field_no_error_without_model_errors
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    field   = builder.send(:build_field, :email, {})

    refute_predicate field, :error?
  end

  def test_build_field_has_error_when_model_has_errors
    @form.errors.add(:email, "is invalid")
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    field   = builder.send(:build_field, :email, {})

    assert_predicate field, :error?
  end
end
