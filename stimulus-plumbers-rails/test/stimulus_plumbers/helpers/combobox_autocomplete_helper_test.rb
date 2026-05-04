# frozen_string_literal: true

require "test_helper"

class ComboboxAutocompleteHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ComboboxHelper

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = parse_html(sp_combobox_autocomplete)

    assert_css doc, "[data-controller='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = parse_html(sp_combobox_autocomplete)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_not_readonly
    doc     = parse_html(sp_combobox_autocomplete)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_not trigger.key?("readonly"), "Expected trigger to not be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = parse_html(sp_combobox_autocomplete)

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_trigger_has_aria_autocomplete_list
    doc = parse_html(sp_combobox_autocomplete)

    assert_css doc, "input[aria-autocomplete='list']"
  end

  def test_renders_listbox_popover
    doc = parse_html(sp_combobox_autocomplete)

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc     = parse_html(sp_combobox_autocomplete)
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_is_empty_by_default
    doc     = parse_html(sp_combobox_autocomplete)
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert_equal "", popover.inner_html.strip
  end

  def test_renders_initial_options_when_provided
    options = [%w[London london], %w[Paris paris]]
    doc     = parse_html(sp_combobox_autocomplete(options: options))

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  def test_option_with_description_renders_two_spans
    options = [["London", "london", { description: "United Kingdom" }]]
    doc     = parse_html(sp_combobox_autocomplete(options: options))
    option  = doc.at_css("li[role='option'][data-value='london']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "London",         spans[0].text
    assert_equal "United Kingdom", spans[1].text
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = parse_html(sp_combobox_autocomplete)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[role='listbox']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── value ─────────────────────────────────────────────────────────────────

  def test_value_from_explicit_option
    doc = parse_html(sp_combobox_autocomplete(value: "london"))

    assert_css doc, "input[type='hidden'][value='london']"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_forwards_html_options_to_wrapper
    doc = parse_html(sp_combobox_autocomplete(class: "my-autocomplete"))

    assert_css doc, "[data-controller='input-combobox'].my-autocomplete"
  end

  # ── ids ───────────────────────────────────────────────────────────────────

  def test_generates_unique_id_per_render
    html1 = sp_combobox_autocomplete
    html2 = sp_combobox_autocomplete

    popover_id1 = html1[%r{aria-controls="([^"]+)"}, 1]
    popover_id2 = html2[%r{aria-controls="([^"]+)"}, 1]

    assert_not_nil popover_id1
    assert_not_equal popover_id1, popover_id2
  end
end
