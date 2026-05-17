# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxAutocompleteFieldTest < ActionView::TestCase
  SIMPLE_OPTIONS = [%w[London london], %w[Paris paris]].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :autocomplete, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:city)

    assert_css doc, "label[for='sign_in_form_city']"
  end

  def test_renders_hidden_value_input_with_model_name
    doc = build_combobox(:city)

    assert_css doc, "input[type='hidden'][name='sign_in_form[city]']"
  end

  def test_trigger_is_not_readonly
    doc     = build_combobox(:city)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_not trigger.key?("readonly"), "Expected trigger to not be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = build_combobox(:city)

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_renders_listbox_popover
    doc = build_combobox(:city)

    assert_css doc, "ul[role='listbox']"
  end

  # ── label options ─────────────────────────────────────────────────────────

  def test_renders_custom_label_text
    doc = build_combobox(:city, label: "City of residence")

    assert_includes doc.text, "City of residence"
  end

  def test_renders_details_hint
    doc = build_combobox(:city, details: "Start typing to filter cities")

    assert_css doc, "#sign_in_form_city_hint"
  end

  # ── options ────────────────────────────────────────────────────────────────

  def test_renders_initial_options_when_provided
    doc = build_combobox(:city, options: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  # ── error state ──────────────────────────────────────────────────────────

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:city, "is invalid")
    doc = build_combobox(:city)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
