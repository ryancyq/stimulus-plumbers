# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxDropdownFieldTest < ActionView::TestCase
  SIMPLE_OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :dropdown, **opts)
    end
    parse_html(html)
  end

  def test_renders_label
    doc = build_combobox(:country)

    assert_css doc, "label[for='sign_in_form_country']"
  end

  def test_renders_hidden_value_input_with_model_name
    doc = build_combobox(:country)

    assert_css doc, "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_pre_selects_option_from_model_value
    @form.define_singleton_method(:country) { "ca" }
    doc = build_combobox(:country, options: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:country, "is invalid")
    doc = build_combobox(:country)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
