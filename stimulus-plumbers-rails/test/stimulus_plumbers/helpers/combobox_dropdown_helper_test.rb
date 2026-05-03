# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper
  include StimulusPlumbers::Helpers::ComboboxHelper

  SIMPLE_OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze
  GROUPED_OPTIONS = [
    { label: "Americas", options: [["United States", "us"], ["Canada", "ca"]] },
    { label: "Europe",   options: [["United Kingdom", "gb"]] }
  ].freeze
  OPTIONS_WITH_DESCRIPTION = [
    ["United States", "us", { description: "North America" }],
    ["Canada",        "ca", { description: "North America" }]
  ].freeze

  def build_combobox_dropdown(record = nil, attribute = nil, **opts)
    parse_html(sp_combobox_dropdown(record, attribute, **opts))
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox_dropdown

    assert_css doc, "[data-controller='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox_dropdown

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_readonly
    doc     = build_combobox_dropdown
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = build_combobox_dropdown

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_renders_listbox_popover
    doc = build_combobox_dropdown

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc = build_combobox_dropdown
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox_dropdown
    trigger = doc.at_css("input[role='combobox']")
    popover   = doc.at_css("[role='listbox']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── options ────────────────────────────────────────────────────────────────

  def test_renders_options
    doc = build_combobox_dropdown(options: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option']"
  end

  def test_renders_correct_option_count
    doc     = build_combobox_dropdown(options: SIMPLE_OPTIONS)
    options = doc.css("li[role='option']")

    assert_equal SIMPLE_OPTIONS.length, options.length
  end

  def test_selected_option_from_value
    doc = build_combobox_dropdown(options: SIMPLE_OPTIONS, value: "ca")

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  # ── description ───────────────────────────────────────────────────────────

  def test_option_with_description_renders_label_and_description_spans
    doc    = build_combobox_dropdown(options: OPTIONS_WITH_DESCRIPTION)
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "United States", spans[0].text
    assert_equal "North America", spans[1].text
  end

  def test_option_without_description_renders_plain_text
    doc    = build_combobox_dropdown(options: SIMPLE_OPTIONS)
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_empty option.css("span")
  end

  # ── grouping ──────────────────────────────────────────────────────────────

  def test_renders_groups
    doc = build_combobox_dropdown(options: GROUPED_OPTIONS)

    assert_css doc, "li[role='group'][aria-label='Americas']"
    assert_css doc, "li[role='group'][aria-label='Europe']"
  end

  def test_options_inside_groups
    doc = build_combobox_dropdown(options: GROUPED_OPTIONS)

    assert_css doc, "li[role='group'] ul li[role='option']"
  end

  # ── name / value resolution ───────────────────────────────────────────────

  def test_name_derived_from_record_and_attribute
    record = TestRecord.new
    record.define_singleton_method(:country) { nil }
    doc = build_combobox_dropdown(record, :country)

    assert_css doc, "input[type='hidden'][name='test_record[country]']"
  end

  def test_name_from_explicit_name_option
    doc = build_combobox_dropdown(name: "filter[country]")

    assert_css doc, "input[type='hidden'][name='filter[country]']"
  end

  def test_value_from_explicit_option
    doc = build_combobox_dropdown(name: "filter[country]", value: "us", options: SIMPLE_OPTIONS)

    assert_css doc, "input[type='hidden'][value='us']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='true']"
  end

  def test_value_from_record_attribute
    record = TestRecord.new
    record.define_singleton_method(:country) { "ca" }
    doc = build_combobox_dropdown(record, :country, options: SIMPLE_OPTIONS)

    assert_css doc, "input[type='hidden'][value='ca']"
    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = build_combobox_dropdown(class: "my-dropdown")

    assert_css doc, "[data-controller='input-combobox'].my-dropdown"
  end

  # ── stable / random ids ───────────────────────────────────────────────────

  def test_stable_ids_from_record_and_attribute
    html1 = sp_combobox_dropdown(TestRecord.new, :country, name: "test_record[country]", value: "")
    html2 = sp_combobox_dropdown(TestRecord.new, :country, name: "test_record[country]", value: "")

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_equal popover_id1, popover_id2
  end

  def test_random_ids_without_record
    html1 = sp_combobox_dropdown(name: "field1")
    html2 = sp_combobox_dropdown(name: "field2")

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end
end
