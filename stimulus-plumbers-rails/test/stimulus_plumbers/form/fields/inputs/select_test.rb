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

  def test_select_label_has_id
    assert_css build_select(:country), "label[id='sign_in_form_country_label']"
  end

  def test_select_listbox_has_aria_labelledby_referencing_label
    assert_css build_select(:country), "ul[role='listbox'][aria-labelledby='sign_in_form_country_label']"
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
    assert_css build_select(:country, nil, hint: "Select your country"), "#sign_in_form_country_hint"
  end

  def test_select_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_select(:country), "p[role='alert']"
    assert_includes build_select(:country).text, "is invalid"
  end

  def test_select_with_include_blank_renders_blank_option
    doc = build_select(:country, SIMPLE_OPTIONS, include_blank: true)

    assert_css doc, "li[role='option'][data-value='']"
  end

  def test_select_with_include_blank_string_uses_it_as_label
    doc = build_select(:country, SIMPLE_OPTIONS, include_blank: "Choose...")

    option = doc.at_css("li[role='option'][data-value='']")

    assert_not_nil option
    assert_includes option.text, "Choose..."
  end

  def test_select_with_prompt_renders_disabled_first_option
    doc = build_select(:country, SIMPLE_OPTIONS, prompt: "Select a country")

    assert_css doc, "li[role='option'][data-value=''][aria-disabled='true']"
    assert_includes doc.at_css("li[role='option'][data-value='']").text, "Select a country"
  end

  def test_select_explicit_selected_overrides_model_value
    @form.define_singleton_method(:country) { "us" }
    doc = build_select(:country, SIMPLE_OPTIONS, selected: "ca")

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
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

  # ── grouped_collection_select ─────────────────────────────────────────────

  CONTINENTS = [
    Continent.new("Europe",   [Country.new("fr", "France"), Country.new("de", "Germany")]),
    Continent.new("Americas", [Country.new("us", "United States"), Country.new("ca", "Canada")])
  ].freeze

  def build_grouped_collection_select(attribute, collection, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.grouped_collection_select(attribute, collection, :countries, :continent_name, :code, :name, **opts)
    end
    parse_html(html)
  end

  def test_grouped_collection_select_renders_label
    assert_css build_grouped_collection_select(:country, CONTINENTS), "label[for='sign_in_form_country']"
  end

  def test_grouped_collection_select_renders_combobox_trigger
    assert_css build_grouped_collection_select(:country, CONTINENTS), "input[role='combobox'][aria-haspopup='listbox']"
  end

  def test_grouped_collection_select_renders_listbox
    assert_css build_grouped_collection_select(:country, CONTINENTS), "ul[role='listbox']"
  end

  def test_grouped_collection_select_renders_option_groups
    doc = build_grouped_collection_select(:country, CONTINENTS)

    assert_css doc, "li[role='group'][aria-label='Europe']"
    assert_css doc, "li[role='group'][aria-label='Americas']"
  end

  def test_grouped_collection_select_renders_options_within_groups
    doc = build_grouped_collection_select(:country, CONTINENTS)

    assert_css doc, "li[role='group'][aria-label='Europe'] li[role='option'][data-value='fr']"
    assert_css doc, "li[role='group'][aria-label='Europe'] li[role='option'][data-value='de']"
    assert_css doc, "li[role='group'][aria-label='Americas'] li[role='option'][data-value='us']"
    assert_css doc, "li[role='group'][aria-label='Americas'] li[role='option'][data-value='ca']"
  end

  def test_grouped_collection_select_pre_selects_from_model_value
    @form.define_singleton_method(:country) { "de" }
    doc = build_grouped_collection_select(:country, CONTINENTS)

    assert_css doc, "li[role='option'][data-value='de'][aria-selected='true']"
  end

  def test_grouped_collection_select_renders_error_message
    @form.errors.add(:country, "is invalid")

    assert_css build_grouped_collection_select(:country, CONTINENTS), "p[role='alert']"
  end

  def test_grouped_collection_select_html_native_renders_select_tag
    assert_css build_grouped_collection_select(:country, CONTINENTS, html_native: true),
               "select[name='sign_in_form[country]']"
  end

  def test_grouped_collection_select_html_native_does_not_render_combobox_trigger
    assert_no_css build_grouped_collection_select(:country, CONTINENTS, html_native: true),
                  "input[role='combobox']"
  end

  # ── time_zone_select ──────────────────────────────────────────────────────

  def build_time_zone_select(attribute, priority_zones = nil, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.time_zone_select(attribute, priority_zones, **opts)
    end
    parse_html(html)
  end

  def test_time_zone_select_renders_label
    assert_css build_time_zone_select(:timezone), "label[for='sign_in_form_timezone']"
  end

  def test_time_zone_select_renders_combobox_trigger
    assert_css build_time_zone_select(:timezone), "input[role='combobox'][aria-haspopup='listbox']"
  end

  def test_time_zone_select_renders_listbox_with_zone_options
    doc = build_time_zone_select(:timezone)

    assert_css doc, "ul[role='listbox']"
    assert_predicate doc.css("li[role='option']"), :any?, "Expected zone options to be rendered"
  end

  def test_time_zone_select_pre_selects_from_model_value
    @form.define_singleton_method(:timezone) { "Eastern Time (US & Canada)" }
    doc = build_time_zone_select(:timezone)

    assert_css doc, "li[role='option'][data-value='Eastern Time (US & Canada)'][aria-selected='true']"
  end

  def test_time_zone_select_with_priority_zones_renders_two_groups
    priority = [ActiveSupport::TimeZone["Hawaii"], ActiveSupport::TimeZone["Alaska"]]
    doc      = build_time_zone_select(:timezone, priority)

    assert_operator doc.css("li[role='group']").size, :>=, 2, "Expected at least two option groups"
  end

  def test_time_zone_select_with_regexp_priority_zones_renders_matching_group
    doc = build_time_zone_select(:timezone, %r{Hawaii})

    groups = doc.css("li[role='group']")

    assert_operator groups.size, :>=, 2

    priority_group = groups[0]

    assert_css priority_group, "li[role='option'][data-value='Hawaii']"
  end

  def test_time_zone_select_with_priority_zones_excludes_them_from_remaining
    priority = [ActiveSupport::TimeZone["Hawaii"]]
    doc      = build_time_zone_select(:timezone, priority)

    groups = doc.css("li[role='group']")

    assert_equal 2, groups.size

    priority_group   = groups[0]
    remaining_group  = groups[1]
    hawaii_value     = "Hawaii"

    assert_css priority_group, "li[role='option'][data-value='#{hawaii_value}']"
    assert_nil remaining_group.at_css("li[role='option'][data-value='#{hawaii_value}']")
  end

  def test_time_zone_select_renders_error_message
    @form.errors.add(:timezone, "is invalid")

    assert_css build_time_zone_select(:timezone), "p[role='alert']"
  end

  def test_time_zone_select_html_native_renders_select_tag
    assert_css build_time_zone_select(:timezone, nil, html_native: true),
               "select[name='sign_in_form[timezone]']"
  end

  def test_time_zone_select_html_native_does_not_render_combobox_trigger
    assert_no_css build_time_zone_select(:timezone, nil, html_native: true), "input[role='combobox']"
  end

  # ── weekday_select ────────────────────────────────────────────────────────

  if ActionView.version >= Gem::Version.new("7.1")
    def build_weekday_select(attribute, **opts)
      html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
        f.weekday_select(attribute, **opts)
      end
      parse_html(html)
    end

    def test_weekday_select_renders_label
      assert_css build_weekday_select(:weekday), "label[for='sign_in_form_weekday']"
    end

    def test_weekday_select_renders_combobox_trigger
      assert_css build_weekday_select(:weekday), "input[role='combobox'][aria-haspopup='listbox']"
    end

    def test_weekday_select_renders_seven_day_options
      doc = build_weekday_select(:weekday)

      assert_equal 7, doc.css("li[role='option']").size
    end

    def test_weekday_select_day_names_as_values_by_default
      doc = build_weekday_select(:weekday)

      assert_css doc, "li[role='option'][data-value='Sunday']"
      assert_css doc, "li[role='option'][data-value='Monday']"
    end

    def test_weekday_select_index_as_value
      doc = build_weekday_select(:weekday, index_as_value: true)

      assert_css doc, "li[role='option'][data-value='0']"
      assert_css doc, "li[role='option'][data-value='1']"
    end

    def test_weekday_select_pre_selects_from_model_value
      @form.define_singleton_method(:weekday) { "Wednesday" }
      doc = build_weekday_select(:weekday)

      assert_css doc, "li[role='option'][data-value='Wednesday'][aria-selected='true']"
    end

    def test_weekday_select_renders_error_message
      @form.errors.add(:weekday, "is invalid")

      assert_css build_weekday_select(:weekday), "p[role='alert']"
    end

    def test_weekday_select_html_native_renders_select_tag
      assert_css build_weekday_select(:weekday, html_native: true),
                 "select[name='sign_in_form[weekday]']"
    end

    def test_weekday_select_html_native_does_not_render_combobox_trigger
      assert_no_css build_weekday_select(:weekday, html_native: true), "input[role='combobox']"
    end

    def test_weekday_select_abbr_day_names_as_values
      doc = build_weekday_select(:weekday, day_format: :abbr_day_names)

      assert_css doc, "li[role='option'][data-value='Sun']"
      assert_css doc, "li[role='option'][data-value='Mon']"
    end

    def test_weekday_select_beginning_of_week_monday_starts_week_at_monday
      doc     = build_weekday_select(:weekday, beginning_of_week: :monday)
      options = doc.css("li[role='option']")

      assert_equal "Monday", options.first["data-value"]
      assert_equal "Sunday", options.last["data-value"]
    end
  end
end
