# frozen_string_literal: true

require "test_helper"
require_relative "../form/form_builder_model"

class CustomThemeIntegrationTest < ActionView::TestCase
  CustomTheme = Class.new(StimulusPlumbers::Themes::Base) do
    private

    def form_label_classes(hidden: false, **)
      { classes: hidden ? "sr-only label" : "label" }
    end

    def form_group_classes(layout: :stacked, **)
      { classes: layout == :inline ? "field-row" : "field" }
    end
  end

  def setup
    @form           = FormBuilderModel.new
    @original_theme = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(CustomTheme.new)
  end

  def teardown
    StimulusPlumbers.config.theme.use(@original_theme)
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.text_field(:email, **opts)
    end
    parse_html(html)
  end

  def test_custom_form_label_classes_applied_to_label
    assert_css build_field, "label.label"
  end

  def test_custom_form_group_classes_applied_to_wrapper
    assert_css build_field, "div.field"
  end

  def test_custom_form_label_hidden_classes_applied_when_hide_label
    assert_css build_field(hide_label: true), "label.sr-only.label"
  end

  def test_custom_form_group_inline_classes_applied_for_inline_layout
    assert_css build_field(layout: :inline), "div.field-row"
  end
end
