# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class SelectTest < ActionView::TestCase
  SIMPLE_OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze

  Country   = Struct.new(:code, :name)
  Continent = Struct.new(:continent_name, :countries)

  def setup
    @form = FormBuilderModel.new
  end

  # ── native select helpers ─────────────────────────────────────────────────

  def build_native_select(attribute, choices = [], **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.select(attribute, choices, **opts)
    end
    parse_html(html)
  end

  def build_native_collection_select(attribute, collection, value_method, text_method, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_select(attribute, collection, value_method, text_method, **opts)
    end
    parse_html(html)
  end

  def build_native_grouped(attribute, collection, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.grouped_collection_select(attribute, collection, :countries, :continent_name, :code, :name, **opts)
    end
    parse_html(html)
  end

  # ── combobox select helpers ───────────────────────────────────────────────

  def build_combobox_select(attribute, choices = [], **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(attribute, as: :select, choices: choices, **opts)
    end
    parse_html(html)
  end

  def build_collection_combobox(attribute, collection, value_method, text_method, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_field(
        attribute,
        as:           :collection_select,
        collection:   collection,
        value_method: value_method,
        text_method:  text_method,
        **opts
      )
    end
    parse_html(html)
  end

  def build_grouped_combobox(attribute, collection, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_field(
        attribute,
        as:                 :grouped_collection_select,
        collection:         collection,
        value_method:       :code,
        text_method:        :name,
        group_method:       :countries,
        group_label_method: :continent_name,
        **opts
      )
    end
    parse_html(html)
  end

  # ── native select ─────────────────────────────────────────────────────────

  def test_native_select_renders_select_tag
    assert_css build_native_select(:country, SIMPLE_OPTIONS), "select[name='sign_in_form[country]']"
  end

  def test_native_select_does_not_render_combobox_trigger
    assert_no_css build_native_select(:country, []), "input[role='combobox']"
  end

  # ── f.field(as: :select) — combobox dropdown ──────────────────────────────

  def test_select_renders_label
    assert_css build_combobox_select(:country), "label[for='sign_in_form_country']"
  end

  def test_select_label_has_id
    assert_css build_combobox_select(:country), "label[id='sign_in_form_country_label']"
  end

  def test_select_listbox_has_aria_labelledby_referencing_label
    assert_css build_combobox_select(:country), "ul[role='listbox'][aria-labelledby='sign_in_form_country_label']"
  end

  def test_select_renders_hidden_value_input
    assert_css build_combobox_select(:country), "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_select_renders_combobox_trigger
    assert_css build_combobox_select(:country), "input[role='combobox'][aria-haspopup='listbox']"
  end

  def test_select_trigger_is_readonly
    assert build_combobox_select(:country).at_css("input[role='combobox']").key?("readonly"),
           "Expected trigger to be readonly"
  end

  def test_select_renders_listbox_popover
    assert_css build_combobox_select(:country), "ul[role='listbox']"
  end

  def test_select_renders_options
    doc = build_combobox_select(:country, SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='us']"
    assert_css doc, "li[role='option'][data-value='ca']"
  end

  def test_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "ca" }
    doc = build_combobox_select(:country, SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_select_renders_custom_label_text
    assert_includes build_combobox_select(:country, [], label: "Country of residence").text, "Country of residence"
  end

  def test_select_renders_details_hint
    assert_css build_combobox_select(:country, [], hint: "Select your country"), "#sign_in_form_country_hint"
  end

  def test_select_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_combobox_select(:country), "p[role='alert']"
    assert_includes build_combobox_select(:country).text, "is invalid"
  end

  def test_select_with_include_blank_renders_blank_option
    doc = build_combobox_select(:country, SIMPLE_OPTIONS, include_blank: true)

    assert_css doc, "li[role='option'][data-value='']"
  end

  def test_select_with_include_blank_string_uses_it_as_label
    doc    = build_combobox_select(:country, SIMPLE_OPTIONS, include_blank: "Choose...")
    option = doc.at_css("li[role='option'][data-value='']")

    assert_not_nil option
    assert_includes option.text, "Choose..."
  end

  def test_select_with_prompt_renders_disabled_first_option
    doc = build_combobox_select(:country, SIMPLE_OPTIONS, prompt: "Select a country")

    assert_css doc, "li[role='option'][data-value=''][aria-disabled='true']"
    assert_includes doc.at_css("li[role='option'][data-value='']").text, "Select a country"
  end

  def test_select_explicit_selected_overrides_model_value
    @form.define_singleton_method(:country) { "us" }
    doc = build_combobox_select(:country, SIMPLE_OPTIONS, selected: "ca")

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  # ── native collection_select ──────────────────────────────────────────────

  def test_native_collection_select_renders_select_tag
    countries = [Country.new("us", "United States")]

    assert_css build_native_collection_select(:country, countries, :code, :name),
               "select[name='sign_in_form[country]']"
  end

  def test_native_collection_select_does_not_render_combobox_trigger
    assert_no_css build_native_collection_select(:country, [], :code, :name), "input[role='combobox']"
  end

  # ── f.collection_field(as: :collection_select) — combobox dropdown ────────

  def test_collection_select_renders_label
    assert_css build_collection_combobox(:country, [], :code, :name), "label[for='sign_in_form_country']"
  end

  def test_collection_select_renders_hidden_value_input
    assert_css build_collection_combobox(:country, [], :code, :name),
               "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_collection_select_renders_options_from_collection
    countries = [Country.new("us", "United States"), Country.new("ca", "Canada")]
    doc       = build_collection_combobox(:country, countries, :code, :name)

    assert_css doc, "li[role='option'][data-value='us']"
    assert_css doc, "li[role='option'][data-value='ca']"
  end

  def test_collection_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "ca" }
    countries = [Country.new("us", "United States"), Country.new("ca", "Canada")]
    doc       = build_collection_combobox(:country, countries, :code, :name)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_collection_select_renders_error_message
    @form.errors.add(:country, "must be selected")

    assert_css build_collection_combobox(:country, [], :code, :name), "p[role='alert']"
  end

  # ── grouped_collection_select ─────────────────────────────────────────────

  CONTINENTS = [
    Continent.new("Europe",   [Country.new("fr", "France"), Country.new("de", "Germany")]),
    Continent.new("Americas", [Country.new("us", "United States"), Country.new("ca", "Canada")])
  ].freeze

  # ── native grouped_collection_select ─────────────────────────────────────

  def test_native_grouped_collection_select_renders_select_tag
    assert_css build_native_grouped(:country, CONTINENTS), "select[name='sign_in_form[country]']"
  end

  def test_native_grouped_collection_select_does_not_render_combobox_trigger
    assert_no_css build_native_grouped(:country, CONTINENTS), "input[role='combobox']"
  end

  # ── f.collection_field(as: :grouped_collection_select) — combobox ─────────

  def test_grouped_collection_select_renders_label
    assert_css build_grouped_combobox(:country, CONTINENTS), "label[for='sign_in_form_country']"
  end

  def test_grouped_collection_select_renders_combobox_trigger
    assert_css build_grouped_combobox(:country, CONTINENTS), "input[role='combobox'][aria-haspopup='listbox']"
  end

  def test_grouped_collection_select_renders_listbox
    assert_css build_grouped_combobox(:country, CONTINENTS), "ul[role='listbox']"
  end

  def test_grouped_collection_select_renders_option_groups
    doc = build_grouped_combobox(:country, CONTINENTS)

    assert_css doc, "li[role='group'][aria-label='Europe']"
    assert_css doc, "li[role='group'][aria-label='Americas']"
  end

  def test_grouped_collection_select_renders_options_within_groups
    doc = build_grouped_combobox(:country, CONTINENTS)

    assert_css doc, "li[role='group'][aria-label='Europe'] li[role='option'][data-value='fr']"
    assert_css doc, "li[role='group'][aria-label='Europe'] li[role='option'][data-value='de']"
    assert_css doc, "li[role='group'][aria-label='Americas'] li[role='option'][data-value='us']"
    assert_css doc, "li[role='group'][aria-label='Americas'] li[role='option'][data-value='ca']"
  end

  def test_grouped_collection_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "de" }
    doc = build_grouped_combobox(:country, CONTINENTS)

    assert_css doc, "li[role='option'][data-value='de'][aria-selected='true']"
  end

  def test_grouped_collection_select_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_grouped_combobox(:country, CONTINENTS), "p[role='alert']"
  end

  # ── time_zone_select ──────────────────────────────────────────────────────

  def build_time_zone_select(attribute, priority_zones = nil, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.time_zone_select(attribute, priority_zones, **opts)
    end
    parse_html(html)
  end

  def test_time_zone_select_renders_select_tag
    assert_css build_time_zone_select(:timezone), "select[name='sign_in_form[timezone]']"
  end

  def test_time_zone_select_does_not_render_combobox_trigger
    assert_no_css build_time_zone_select(:timezone), "input[role='combobox']"
  end

  # ── weekday_select ────────────────────────────────────────────────────────

  if ActionView.version >= Gem::Version.new("7.1")
    def build_weekday_select(attribute, **opts)
      html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
        f.weekday_select(attribute, **opts)
      end
      parse_html(html)
    end

    def test_weekday_select_renders_select_tag
      assert_css build_weekday_select(:weekday), "select[name='sign_in_form[weekday]']"
    end

    def test_weekday_select_does_not_render_combobox_trigger
      assert_no_css build_weekday_select(:weekday), "input[role='combobox']"
    end
  end
end
