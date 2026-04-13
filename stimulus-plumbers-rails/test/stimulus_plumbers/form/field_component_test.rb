# frozen_string_literal: true

require "test_helper"
require_relative "form_field_model"

class FieldComponentTest < Minitest::Test
  def setup
    @form = FormFieldModel.new
  end

  def component(attribute: :email, **kwargs)
    StimulusPlumbers::Form::FieldComponent.new(object: @form, attribute: attribute, **kwargs)
  end

  # ── errors ────────────────────────────────────────────────────────────────

  def test_errors_empty_with_no_model_errors
    assert_empty component(attribute: :email).errors
  end

  def test_errors_returns_model_errors
    @form.errors.add(:email, "is invalid")

    assert_includes component(attribute: :email).errors, "is invalid"
  end

  def test_errors_returns_override_as_array
    assert_equal ["Custom error"], component(attribute: :email, error: "Custom error").errors
  end

  def test_errors_prefers_override_over_model_errors
    @form.errors.add(:email, "is invalid")

    assert_equal ["Custom error"], component(attribute: :email, error: "Custom error").errors
  end

  # ── error? ────────────────────────────────────────────────────────────────

  def test_no_error_with_no_errors
    refute_predicate component(attribute: :email), :error?
  end

  def test_error_when_model_has_errors
    @form.errors.add(:email, "is invalid")

    assert_predicate component(attribute: :email), :error?
  end

  def test_error_when_error_override_is_set
    assert_predicate component(attribute: :email, error: "Something went wrong"), :error?
  end

  # ── ID helpers ─────────────────────────────────────────────────────────────

  def test_input_id_reflects_object_and_attribute
    assert_equal "sign_in_form_email", component(attribute: :email).input_id
  end

  def test_hint_id_is_derived_from_input_id
    assert_equal "sign_in_form_email_hint", component(attribute: :email).hint_id
  end

  def test_error_id_is_derived_from_input_id
    assert_equal "sign_in_form_email_error", component(attribute: :email).error_id
  end

  # ── described_by ──────────────────────────────────────────────────────────

  def test_described_by_is_nil_with_no_details_or_errors
    assert_nil component(attribute: :email).described_by
  end

  def test_described_by_includes_hint_id_when_details_present
    assert_includes component(attribute: :email, details: "Hint text").described_by, "sign_in_form_email_hint"
  end

  def test_described_by_includes_error_id_when_errors_present
    @form.errors.add(:email, "is invalid")

    assert_includes component(attribute: :email).described_by, "sign_in_form_email_error"
  end

  def test_described_by_includes_both_ids_when_details_and_errors_present
    @form.errors.add(:email, "is invalid")
    c = component(attribute: :email, details: "Hint text")

    assert_includes c.described_by, "sign_in_form_email_hint"
    assert_includes c.described_by, "sign_in_form_email_error"
  end

  # ── label_text ────────────────────────────────────────────────────────────

  def test_label_text_defaults_to_humanized_attribute
    assert_equal "Email", component(attribute: :email).label_text
  end

  def test_label_text_accepts_custom_value
    assert_equal "Email address", component(attribute: :email, label: "Email address").label_text
  end

  # ── label_hidden? ─────────────────────────────────────────────────────────

  def test_label_not_hidden_by_default
    refute_predicate component(attribute: :email), :label_hidden?
  end

  def test_label_hidden_when_visibility_is_exclusive
    assert_predicate component(attribute: :email, label_visibility: :exclusive), :label_hidden?
  end

  def test_label_not_hidden_when_visibility_is_visible
    refute_predicate component(attribute: :email, label_visibility: :visible), :label_hidden?
  end

  # ── layout ────────────────────────────────────────────────────────────────

  def test_default_layout_is_stacked
    assert_equal :stacked, component(attribute: :email).layout
  end

  def test_inline_layout_is_accepted
    assert_equal :inline, component(attribute: :email, layout: :inline).layout
  end
end
