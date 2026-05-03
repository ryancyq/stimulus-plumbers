# frozen_string_literal: true

require "test_helper"

class ComboboxAutocompleteHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PlumberHelper
  include StimulusPlumbers::Helpers::ComboboxHelper

  def build_combobox_autocomplete(record = nil, attribute = nil, **opts)
    parse_html(sp_combobox_autocomplete(record, attribute, **opts))
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox_autocomplete

    assert_css doc, "[data-controller='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox_autocomplete

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_not_readonly
    doc     = build_combobox_autocomplete
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_not trigger.key?("readonly"), "Expected trigger to not be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = build_combobox_autocomplete

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_trigger_has_aria_autocomplete_list
    doc = build_combobox_autocomplete

    assert_css doc, "input[aria-autocomplete='list']"
  end

  def test_renders_listbox_popover
    doc = build_combobox_autocomplete

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc = build_combobox_autocomplete
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_is_empty_by_default
    doc = build_combobox_autocomplete
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert_equal "", popover.inner_html.strip
  end

  def test_renders_initial_options_when_provided
    options = [%w[London london], %w[Paris paris]]
    doc     = build_combobox_autocomplete(options: options)

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  def test_option_with_description_renders_two_spans
    options = [["London", "london", { description: "United Kingdom" }]]
    doc     = build_combobox_autocomplete(options: options)
    option  = doc.at_css("li[role='option'][data-value='london']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "London",         spans[0].text
    assert_equal "United Kingdom", spans[1].text
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox_autocomplete
    trigger = doc.at_css("input[role='combobox']")
    popover   = doc.at_css("[role='listbox']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── name / value resolution ───────────────────────────────────────────────

  def test_name_derived_from_record_and_attribute
    record = TestRecord.new
    record.define_singleton_method(:city) { nil }
    doc = build_combobox_autocomplete(record, :city)

    assert_css doc, "input[type='hidden'][name='test_record[city]']"
  end

  def test_name_from_explicit_name_option
    doc = build_combobox_autocomplete(name: "filter[query]")

    assert_css doc, "input[type='hidden'][name='filter[query]']"
  end

  def test_value_from_explicit_option
    doc = build_combobox_autocomplete(name: "filter[query]", value: "london")

    assert_css doc, "input[type='hidden'][value='london']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = build_combobox_autocomplete(class: "my-autocomplete")

    assert_css doc, "[data-controller='input-combobox'].my-autocomplete"
  end

  # ── stable / random ids ───────────────────────────────────────────────────

  def test_stable_ids_from_record_and_attribute
    html1 = sp_combobox_autocomplete(TestRecord.new, :city, name: "test_record[city]", value: "")
    html2 = sp_combobox_autocomplete(TestRecord.new, :city, name: "test_record[city]", value: "")

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_equal popover_id1, popover_id2
  end

  def test_random_ids_without_record
    html1 = sp_combobox_autocomplete(name: "field1")
    html2 = sp_combobox_autocomplete(name: "field2")

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end
end
