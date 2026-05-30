# frozen_string_literal: true

require "test_helper"
require_relative "form_field_model"

class FieldTest < Minitest::Test
  INPUT_ID = "sign_in_form_email"

  def setup
    @form = FormFieldModel.new
  end

  def component(**kwargs)
    StimulusPlumbers::Form::Field.new(nil, **kwargs)
  end

  def test_no_error_without_model_errors
    refute component.error?(@form, :email)
  end

  def test_error_when_model_has_errors
    @form.errors.add(:email, "is invalid")

    assert component.error?(@form, :email)
  end

  def test_error_when_error_override_is_set
    assert component(error: "Something went wrong").error?(@form, :email)
  end

  def test_error_prefers_override_over_model_errors
    @form.errors.add(:email, "is invalid")

    assert component(error: "Custom error").error?(@form, :email)
  end

  def test_described_by_is_nil_with_no_hint_or_errors
    assert_nil component.described_by(@form, :email, INPUT_ID)
  end

  def test_described_by_includes_hint_id_when_hint_present
    assert_includes component(hint: "Hint text").described_by(@form, :email, INPUT_ID), "#{INPUT_ID}_hint"
  end

  def test_described_by_includes_error_id_when_errors_present
    @form.errors.add(:email, "is invalid")

    assert_includes component.described_by(@form, :email, INPUT_ID), "#{INPUT_ID}_error"
  end

  def test_described_by_includes_both_ids_when_hint_and_errors_present
    @form.errors.add(:email, "is invalid")
    c = component(hint: "Hint text")

    assert_includes c.described_by(@form, :email, INPUT_ID), "#{INPUT_ID}_hint"
    assert_includes c.described_by(@form, :email, INPUT_ID), "#{INPUT_ID}_error"
  end

  def test_described_by_includes_all_error_ids_for_multiple_errors
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "is too long")

    db = component.described_by(@form, :email, INPUT_ID)

    assert_includes db, "#{INPUT_ID}_error_1"
    assert_includes db, "#{INPUT_ID}_error_2"
  end

  def test_described_by_includes_hint_and_all_error_ids_for_multiple_errors
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "is too long")
    c = component(hint: "Hint text")
    db = c.described_by(@form, :email, INPUT_ID)

    assert_includes db, "#{INPUT_ID}_hint"
    assert_includes db, "#{INPUT_ID}_error_1"
    assert_includes db, "#{INPUT_ID}_error_2"
  end

  def test_label_id_returns_input_id_with_label_suffix
    assert_equal "#{INPUT_ID}_label", StimulusPlumbers::Form::Field.label_id(INPUT_ID)
  end

  def test_label_is_nil_without_explicit_label
    assert_nil component.label
  end

  def test_label_accepts_custom_value
    assert_equal "Email address", component(label: "Email address").label
  end

  def test_label_not_hidden_by_default
    refute_predicate component, :label_hidden?
  end

  def test_label_hidden_when_hide_label_is_true
    assert_predicate component(hide_label: true), :label_hidden?
  end

  def test_default_layout_is_stacked
    assert_equal :stacked, component.layout
  end

  def test_layout_is_inline_when_set
    assert_equal :inline, component(layout: :inline).layout
  end

  def test_not_required_by_default
    refute_predicate component, :required
  end

  def test_required_when_set
    assert_predicate component(required: true), :required
  end
end
