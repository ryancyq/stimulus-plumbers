# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :date, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:birthday)

    assert_css doc, "label[for='sign_in_form_birthday']"
  end

  def test_renders_hidden_value_input
    doc = build_combobox(:birthday)

    assert_css doc, "input[type='hidden'][name='sign_in_form[birthday]']"
  end

  # ── error state ──────────────────────────────────────────────────────────

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:birthday, "is invalid")
    doc = build_combobox(:birthday)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end

  # ── label options ─────────────────────────────────────────────────────────

  def test_renders_custom_label_text
    doc = build_combobox(:birthday, label: "Date of Birth")

    assert_includes doc.text, "Date of Birth"
  end

  def test_renders_details_hint
    doc = build_combobox(:birthday, details: "Select your birthday")

    assert_css doc, "#sign_in_form_birthday_hint"
  end

  # ── unsupported type ──────────────────────────────────────────────────────

  def test_raises_for_unsupported_type
    assert_raises(ArgumentError) do
      view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
        f.combobox_field(:birthday, type: :unknown)
      end
    end
  end
end
