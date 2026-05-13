# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownHelperTest < ActionView::TestCase
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

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = parse_html(sp_combobox_dropdown)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = parse_html(sp_combobox_dropdown)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_readonly
    doc     = parse_html(sp_combobox_dropdown)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = parse_html(sp_combobox_dropdown)

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_renders_listbox_popover
    doc = parse_html(sp_combobox_dropdown)

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc     = parse_html(sp_combobox_dropdown)
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = parse_html(sp_combobox_dropdown)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── options ────────────────────────────────────────────────────────────────

  def test_renders_options
    doc = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS))

    assert_css doc, "li[role='option']"
  end

  def test_renders_correct_option_count
    doc     = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS))
    options = doc.css("li[role='option']")

    assert_equal SIMPLE_OPTIONS.length, options.length
  end

  def test_selected_option_from_value
    doc = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS, value: "ca"))

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  # ── description ───────────────────────────────────────────────────────────

  def test_option_with_description_renders_label_and_description_spans
    doc    = parse_html(sp_combobox_dropdown(options: OPTIONS_WITH_DESCRIPTION))
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "United States", spans[0].text
    assert_equal "North America", spans[1].text
  end

  def test_option_without_description_renders_plain_text
    doc    = parse_html(sp_combobox_dropdown(options: SIMPLE_OPTIONS))
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_empty option.css("span")
  end

  # ── disabled ──────────────────────────────────────────────────────────────

  def test_disabled_option_has_aria_disabled_true
    options = [["Disabled", "x", { disabled: true }], %w[Enabled y]]
    doc     = parse_html(sp_combobox_dropdown(options: options))

    assert_css doc, "li[role='option'][data-value='x'][aria-disabled='true']"
    assert_no_css doc, "li[role='option'][data-value='y'][aria-disabled]"
  end

  # ── hash options ──────────────────────────────────────────────────────────

  def test_hash_option_renders_label_and_value
    options = [{ label: "United States", value: "us" }]
    doc     = parse_html(sp_combobox_dropdown(options: options))

    assert_css doc, "li[role='option'][data-value='us']"
  end

  def test_hash_option_with_description_renders_two_spans
    options = [{ label: "United States", value: "us", description: "North America" }]
    doc     = parse_html(sp_combobox_dropdown(options: options))
    option  = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_equal 2, option.css("span").length
  end

  # ── grouping ──────────────────────────────────────────────────────────────

  def test_renders_groups
    doc = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS))

    assert_css doc, "li[role='group'][aria-label='Americas']"
    assert_css doc, "li[role='group'][aria-label='Europe']"
  end

  def test_options_inside_groups
    doc = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS))

    assert_css doc, "li[role='group'] ul li[role='option']"
  end

  def test_group_label_span_is_aria_hidden
    doc  = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS))
    span = doc.at_css("li[role='group'] span[aria-hidden='true']")

    assert_not_nil span
    assert_includes span.text, "Americas"
  end

  def test_total_option_count_across_groups
    doc     = parse_html(sp_combobox_dropdown(options: GROUPED_OPTIONS))
    options = doc.css("li[role='option']")
    expected = GROUPED_OPTIONS.sum { |g| g[:options].length }

    assert_equal expected, options.length
  end

  # ── aria ──────────────────────────────────────────────────────────────────

  def test_trigger_aria_expanded_false
    doc = parse_html(sp_combobox_dropdown)

    assert_css doc, "input[aria-expanded='false']"
  end

  # ── value ─────────────────────────────────────────────────────────────────

  def test_value_from_explicit_option
    doc = parse_html(sp_combobox_dropdown(value: "us", options: SIMPLE_OPTIONS))

    assert_css doc, "input[type='hidden'][value='us']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='true']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = parse_html(sp_combobox_dropdown(class: "my-dropdown"))

    assert_css doc, "[data-controller~='input-combobox'].my-dropdown"
  end

  # ── ids ───────────────────────────────────────────────────────────────────

  def test_generates_unique_id_per_render
    html1 = sp_combobox_dropdown
    html2 = sp_combobox_dropdown

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end
end
