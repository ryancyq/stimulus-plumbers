# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxDropdownFieldTest < ActionView::TestCase
  SIMPLE_OPTIONS = [["United States", "us"], ["Canada", "ca"]].freeze
  GROUPED_OPTIONS = [
    { label: "Americas", options: [["United States", "us"], ["Canada", "ca"]] },
    { label: "Europe",   options: [["United Kingdom", "gb"]] }
  ].freeze
  OPTIONS_WITH_DESCRIPTION = [
    ["United States", "us", { description: "North America" }],
    ["Canada",        "ca", { description: "North America" }]
  ].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, options: [], **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :dropdown, options: options, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox(:country)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox(:country)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_readonly
    doc     = build_combobox(:country)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert trigger.key?("readonly"), "Expected trigger to be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = build_combobox(:country)

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_trigger_aria_expanded_false
    doc = build_combobox(:country)

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_renders_hidden_value_input
    doc = build_combobox(:country)

    assert_css doc, "input[type='hidden'][name='sign_in_form[country]']"
  end

  def test_renders_listbox_popover
    doc = build_combobox(:country)

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc     = build_combobox(:country)
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox(:country)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── options ────────────────────────────────────────────────────────────────

  def test_renders_options_as_listbox_items
    doc = build_combobox(:country, options: SIMPLE_OPTIONS)

    assert_css doc, "[role='listbox'] li[role='option']"
  end

  def test_renders_correct_number_of_options
    doc     = build_combobox(:country, options: SIMPLE_OPTIONS)
    options = doc.css("li[role='option']")

    assert_equal SIMPLE_OPTIONS.length, options.length
  end

  def test_option_carries_data_value
    doc    = build_combobox(:country, options: SIMPLE_OPTIONS)
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_equal "United States", option.text.strip
  end

  def test_unselected_options_have_aria_selected_false
    doc     = build_combobox(:country, options: SIMPLE_OPTIONS)
    options = doc.css("li[role='option'][aria-selected='false']")

    assert_equal SIMPLE_OPTIONS.length, options.length
  end

  def test_selected_option_has_aria_selected_true
    @form.define_singleton_method(:country) { "ca" }
    doc = build_combobox(:country, options: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_disabled_option_has_aria_disabled_true
    options = [["Disabled", "x", { disabled: true }], %w[Enabled y]]
    doc     = build_combobox(:country, options: options)

    assert_css doc, "li[role='option'][data-value='x'][aria-disabled='true']"
    assert_no_css doc, "li[role='option'][data-value='y'][aria-disabled]"
  end

  # ── description ───────────────────────────────────────────────────────────

  def test_option_with_description_renders_two_spans
    doc    = build_combobox(:country, options: OPTIONS_WITH_DESCRIPTION)
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "United States", spans[0].text
    assert_equal "North America", spans[1].text
  end

  def test_option_without_description_renders_plain_text
    doc    = build_combobox(:country, options: SIMPLE_OPTIONS)
    option = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_empty option.css("span")
  end

  def test_hash_option_with_description
    options = [{ label: "United States", value: "us", description: "North America" }]
    doc     = build_combobox(:country, options: options)
    option  = doc.at_css("li[role='option'][data-value='us']")

    assert_not_nil option
    assert_equal 2, option.css("span").length
  end

  # ── grouping ──────────────────────────────────────────────────────────────

  def test_renders_groups_with_group_role
    doc = build_combobox(:country, options: GROUPED_OPTIONS)

    assert_css doc, "li[role='group']"
  end

  def test_group_has_aria_label
    doc   = build_combobox(:country, options: GROUPED_OPTIONS)
    group = doc.at_css("li[role='group'][aria-label='Americas']")

    assert_not_nil group
  end

  def test_group_renders_options_inside_nested_list
    doc = build_combobox(:country, options: GROUPED_OPTIONS)

    assert_css doc, "li[role='group'] ul li[role='option']"
  end

  def test_group_label_is_aria_hidden_for_screen_readers
    doc  = build_combobox(:country, options: GROUPED_OPTIONS)
    span = doc.at_css("li[role='group'] span[aria-hidden='true']")

    assert_not_nil span
    assert_includes span.text, "Americas"
  end

  def test_total_options_count_across_groups
    doc     = build_combobox(:country, options: GROUPED_OPTIONS)
    options = doc.css("li[role='option']")

    expected = GROUPED_OPTIONS.sum { |g| g[:options].length }

    assert_equal expected, options.length
  end

  # ── label / error ─────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:country)

    assert_css doc, "label[for='sign_in_form_country']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:country, "is invalid")
    doc = build_combobox(:country)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
