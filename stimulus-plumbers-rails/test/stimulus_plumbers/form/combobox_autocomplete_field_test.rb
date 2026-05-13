# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxAutocompleteFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :autocomplete, **opts)
    end
    parse_html(html)
  end

  def test_renders_label
    doc = build_combobox(:city)

    assert_css doc, "label[for='sign_in_form_city']"
  end

  def test_renders_hidden_value_input_with_model_name
    doc = build_combobox(:city)

    assert_css doc, "input[type='hidden'][name='sign_in_form[city]']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:city, "is invalid")
    doc = build_combobox(:city)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
