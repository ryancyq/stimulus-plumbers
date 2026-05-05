# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class ComboboxAutocompleteFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_combobox(attribute, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.combobox_field(attribute, type: :autocomplete, **opts)
    end
    parse_html(html)
  end

  # ── structure ──────────────────────────────────────────────────────────────

  def test_renders_combobox_wrapper_with_stimulus_controller
    doc = build_combobox(:city)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_renders_trigger_input_with_combobox_role
    doc = build_combobox(:city)

    assert_css doc, "input[type='text'][role='combobox']"
  end

  def test_trigger_is_not_readonly
    doc     = build_combobox(:city)
    trigger = doc.at_css("input[role='combobox']")

    assert_not_nil trigger
    assert_not trigger.key?("readonly"), "Expected trigger to not be readonly"
  end

  def test_trigger_has_haspopup_listbox
    doc = build_combobox(:city)

    assert_css doc, "input[aria-haspopup='listbox']"
  end

  def test_trigger_has_aria_autocomplete_list
    doc = build_combobox(:city)

    assert_css doc, "input[aria-autocomplete='list']"
  end

  def test_trigger_aria_expanded_false
    doc = build_combobox(:city)

    assert_css doc, "input[aria-expanded='false']"
  end

  def test_renders_hidden_value_input
    doc = build_combobox(:city)

    assert_css doc, "input[type='hidden'][name='sign_in_form[city]']"
  end

  def test_renders_listbox_popover
    doc = build_combobox(:city)

    assert_css doc, "ul[role='listbox']"
  end

  def test_popover_is_hidden_by_default
    doc     = build_combobox(:city)
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil popover
    assert popover.key?("hidden"), "Expected popover to have the hidden attribute"
  end

  def test_popover_is_empty_by_default
    doc = build_combobox(:city)
    popover = doc.at_css("[role='listbox']")

    assert_not_nil popover
    assert_equal "", popover.inner_html.strip
  end

  def test_renders_loading_indicator
    doc = build_combobox(:city)

    assert_css doc, "[aria-live='polite'][hidden]"
  end

  def test_renders_empty_state_element
    doc = build_combobox(:city)

    assert_css doc, "[role='status'][hidden]"
  end

  def test_renders_initial_options_when_provided
    options = [%w[London london], %w[Paris paris]]
    doc     = build_combobox(:city, options: options)

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  def test_option_with_description_renders_two_spans
    options = [["London", "london", { description: "United Kingdom" }]]
    doc     = build_combobox(:city, options: options)
    option  = doc.at_css("li[role='option'][data-value='london']")

    assert_not_nil option
    spans = option.css("span")

    assert_equal 2, spans.length
    assert_equal "London",         spans[0].text
    assert_equal "United Kingdom", spans[1].text
  end

  def test_trigger_aria_controls_matches_popover_id
    doc     = build_combobox(:city)
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[data-input-combobox-target='popover']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal popover["id"], trigger["aria-controls"]
  end

  # ── label / error ─────────────────────────────────────────────────────────

  def test_renders_label
    doc = build_combobox(:city)

    assert_css doc, "label[for='sign_in_form_city']"
  end

  def test_renders_error_message_when_model_has_errors
    @form.errors.add(:city, "is invalid")
    doc = build_combobox(:city)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end
end
