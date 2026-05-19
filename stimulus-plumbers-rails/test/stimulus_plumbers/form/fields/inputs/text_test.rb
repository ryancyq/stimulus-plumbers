# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class TextTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(method, attribute = :email, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.public_send(method, attribute, **opts)
    end
    parse_html(html)
  end

  # ── shared field chrome (tested once via email_field) ─────────────────────

  def test_renders_label
    assert_css build_field(:email_field), "label[for='sign_in_form_email']"
  end

  def test_label_option_sets_label_text
    assert_includes build_field(:email_field, label: "E-mail").text, "E-mail"
  end

  def test_renders_hint_when_details_option_given
    assert_css build_field(:email_field, hint: "We'll never share your email"), "#sign_in_form_email_hint"
  end

  def test_aria_describedby_references_hint_id
    doc = build_field(:email_field, hint: "We'll never share your email")

    assert_includes doc.at_css("input[type='email']")["aria-describedby"].to_s, "sign_in_form_email_hint"
  end

  def test_renders_error_message
    @form.errors.add(:email, "is invalid")

    assert_css build_field(:email_field), "p[role='alert']"
    assert_includes build_field(:email_field).text, "is invalid"
  end

  def test_has_aria_invalid_on_error
    @form.errors.add(:email, "is invalid")

    assert_equal "true", build_field(:email_field).at_css("input[type='email']")["aria-invalid"]
  end

  def test_has_aria_describedby_referencing_error_id
    @form.errors.add(:email, "is invalid")

    assert_includes build_field(:email_field).at_css("input[type='email']")["aria-describedby"].to_s,
                    "sign_in_form_email_error"
  end

  def test_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "has already been taken")
    doc = build_field(:email_field)

    described_by = doc.at_css("input[type='email']")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_email_error_1"
    assert_includes described_by, "sign_in_form_email_error_2"
  end

  def test_multiple_error_elements_have_matching_ids
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "has already been taken")
    doc = build_field(:email_field)

    assert_css doc, "#sign_in_form_email_error_1"
    assert_css doc, "#sign_in_form_email_error_2"
  end

  def test_required_sets_required_attribute
    input = build_field(:email_field, required: true).at_css("input[type='email']")

    assert_equal "required", input["required"]
  end

  def test_required_sets_aria_required_attribute
    input = build_field(:email_field, required: true).at_css("input[type='email']")

    assert_equal "true", input["aria-required"]
  end

  def test_required_renders_mark_in_label
    doc = build_field(:email_field, required: true)

    assert_css doc, "label span[aria-hidden='true']"
  end

  # ── html option forwarding ─────────────────────────────────────────────

  def test_forwards_placeholder_to_input
    input = build_field(:email_field, placeholder: "you@example.com").at_css("input[type='email']")

    assert_equal "you@example.com", input["placeholder"]
  end

  def test_forwards_autocomplete_to_input
    assert_equal "email", build_field(:email_field, autocomplete: "email").at_css("input[type='email']")["autocomplete"]
  end

  def test_forwards_class_to_input
    assert_includes build_field(:email_field, class: "custom").at_css("input[type='email']")["class"].to_s, "custom"
  end

  def test_forwards_data_attributes_to_input
    input = build_field(:email_field, data: { controller: "my-ctrl" }).at_css("input[type='email']")

    assert_equal "my-ctrl", input["data-controller"]
  end

  def test_number_field_forwards_min
    assert_equal "0", build_field(:number_field, :age, min: 0).at_css("input[type='number']")["min"]
  end

  def test_number_field_forwards_max
    assert_equal "120", build_field(:number_field, :age, max: 120).at_css("input[type='number']")["max"]
  end

  def test_number_field_forwards_step
    assert_equal "5", build_field(:number_field, :age, step: 5).at_css("input[type='number']")["step"]
  end

  def test_range_field_forwards_min_and_max
    input = build_field(:range_field, :age, min: 1, max: 100).at_css("input[type='range']")

    assert_equal "1",   input["min"]
    assert_equal "100", input["max"]
  end

  # ── hide_label ────────────────────────────────────────────────────────────

  def test_hide_label_keeps_label_in_dom
    assert_css build_field(:email_field, hide_label: true), "label[for='sign_in_form_email']"
  end

  # ── error override ────────────────────────────────────────────────────────

  def test_error_override_renders_error_message
    assert_includes build_field(:email_field, error: "Something went wrong").text, "Something went wrong"
  end

  def test_error_override_sets_aria_invalid
    assert_equal "true", build_field(:email_field, error: "bad").at_css("input[type='email']")["aria-invalid"]
  end

  # ── text_field ────────────────────────────────────────────────────────────

  def test_text_field_renders_text_input
    assert_css build_field(:text_field), "input[type='text']"
  end

  # ── email_field ───────────────────────────────────────────────────────────

  def test_email_field_renders_email_input
    assert_css build_field(:email_field), "input[type='email']"
  end

  # ── url_field ─────────────────────────────────────────────────────────────

  def test_url_field_renders_url_input
    assert_css build_field(:url_field), "input[type='url']"
  end

  # ── telephone_field ───────────────────────────────────────────────────────

  def test_telephone_field_renders_tel_input
    assert_css build_field(:telephone_field), "input[type='tel']"
  end

  # ── number_field ──────────────────────────────────────────────────────────

  def test_number_field_renders_number_input
    assert_css build_field(:number_field), "input[type='number']"
  end

  # ── range_field ───────────────────────────────────────────────────────────

  def test_range_field_renders_range_input
    assert_css build_field(:range_field), "input[type='range']"
  end

  # ── color_field ───────────────────────────────────────────────────────────

  def test_color_field_renders_color_input
    assert_css build_field(:color_field), "input[type='color']"
  end

  # ── month_field ───────────────────────────────────────────────────────────

  def test_month_field_renders_month_input
    assert_css build_field(:month_field), "input[type='month']"
  end

  # ── week_field ────────────────────────────────────────────────────────────

  def test_week_field_renders_week_input
    assert_css build_field(:week_field), "input[type='week']"
  end

  # ── datetime_local_field ──────────────────────────────────────────────────

  def test_datetime_local_field_renders_datetime_local_input
    assert_css build_field(:datetime_local_field), "input[type='datetime-local']"
  end
end
