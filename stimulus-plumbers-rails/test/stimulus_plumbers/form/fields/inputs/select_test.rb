# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class SelectTest < ActionView::TestCase
  SIMPLE_OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze

  Country = Struct.new(:code, :name)

  def setup
    @form = FormBuilderModel.new
  end

  def build_select(attribute, choices = nil, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.select(attribute, choices, **opts)
    end
    parse_html(html)
  end

  def build_collection_select(attribute, collection, value_method, text_method, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_select(attribute, collection, value_method, text_method, **opts)
    end
    parse_html(html)
  end

  # ── select ────────────────────────────────────────────────────────────────

  def test_select_renders_label
    assert_css build_select(:country), "label[for='sign_in_form_country']"
  end

  def test_select_renders_hidden_value_input
    assert_css build_select(:country), "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_select_renders_combobox_trigger
    assert_css build_select(:country), "input[role='combobox'][aria-haspopup='listbox']"
  end

  def test_select_trigger_is_readonly
    assert build_select(:country).at_css("input[role='combobox']").key?("readonly"), "Expected trigger to be readonly"
  end

  def test_select_renders_listbox_popover
    assert_css build_select(:country), "ul[role='listbox']"
  end

  def test_select_renders_options
    doc = build_select(:country, SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='us']"
    assert_css doc, "li[role='option'][data-value='ca']"
  end

  def test_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "ca" }
    doc = build_select(:country, SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_select_renders_custom_label_text
    assert_includes build_select(:country, nil, label: "Country of residence").text, "Country of residence"
  end

  def test_select_renders_details_hint
    assert_css build_select(:country, nil, details: "Select your country"), "#sign_in_form_country_hint"
  end

  def test_select_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_select(:country), "p[role='alert']"
    assert_includes build_select(:country).text, "is invalid"
  end

  # ── select html_native: true ──────────────────────────────────────────────

  def test_select_html_native_renders_select_tag
    assert_css build_select(:country, SIMPLE_OPTIONS, html_native: true), "select[name='sign_in_form[country]']"
  end

  def test_select_html_native_does_not_render_combobox_trigger
    assert_no_css build_select(:country, [], html_native: true), "input[role='combobox']"
  end

  def test_select_html_native_renders_label
    assert_css build_select(:country, [], html_native: true), "label[for='sign_in_form_country']"
  end

  def test_select_html_native_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_select(:country, [], html_native: true), "p[role='alert']"
  end

  def test_select_html_native_option_does_not_leak_into_attributes
    assert_nil build_select(:country, [], html_native: true).at_css("[html_native]")
  end

  # ── collection_select ─────────────────────────────────────────────────────

  def test_collection_select_renders_label
    assert_css build_collection_select(:country, [], :code, :name), "label[for='sign_in_form_country']"
  end

  def test_collection_select_renders_hidden_value_input
    assert_css build_collection_select(:country, [], :code, :name),
               "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_collection_select_renders_options_from_collection
    countries = [Country.new("us", "United States"), Country.new("ca", "Canada")]
    doc       = build_collection_select(:country, countries, :code, :name)

    assert_css doc, "li[role='option'][data-value='us']"
    assert_css doc, "li[role='option'][data-value='ca']"
  end

  def test_collection_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "ca" }
    countries = [Country.new("us", "United States"), Country.new("ca", "Canada")]
    doc       = build_collection_select(:country, countries, :code, :name)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_collection_select_renders_error_message
    @form.errors.add(:country, "must be selected")

    assert_css build_collection_select(:country, [], :code, :name), "p[role='alert']"
  end

  # ── collection_select html_native: true ───────────────────────────────────

  def test_collection_select_html_native_renders_select_tag
    countries = [Country.new("us", "United States")]

    assert_css build_collection_select(:country, countries, :code, :name, html_native: true),
               "select[name='sign_in_form[country]']"
  end

  def test_collection_select_html_native_does_not_render_combobox_trigger
    assert_no_css build_collection_select(:country, [], :code, :name, html_native: true), "input[role='combobox']"
  end
end
