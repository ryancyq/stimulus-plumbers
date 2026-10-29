# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class SearchTest < ActionView::TestCase
  SIMPLE_OPTIONS = [%w[London london], %w[Paris paris]].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_native(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.search_field(:email, **opts)
    end
    parse_html(html)
  end

  # f.field(as: :search) — full wrapper: label + combobox + hint + error
  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:email, as: :search, **opts)
    end
    parse_html(html)
  end

  def test_native_renders_search_input
    assert_css build_native, "input[type='search']"
  end

  def test_native_does_not_render_combobox_trigger
    assert_no_css build_native, "input[role='combobox']"
  end

  def test_native_does_not_render_hidden_value_input
    assert_no_css build_native, "input[type='hidden'][name='sign_in_form[email]']"
  end

  def test_native_clearable_renders_input_clearable_controller_wrapper
    assert_css build_native(clearable: true), "[data-controller='input-clearable']"
  end

  def test_native_clearable_input_has_input_clearable_target
    assert_css build_native(clearable: true), "input[type='search'][data-input-clearable-target='input']"
  end

  def test_native_clearable_renders_clear_button
    assert_css build_native(clearable: true),
               "button[data-input-clearable-target='clear'][data-action='click->input-clearable#clear']"
  end

  def test_native_clearable_does_not_render_combobox
    assert_no_css build_native(clearable: true), "input[role='combobox']"
  end

  def test_native_without_clearable_does_not_add_input_clearable_target
    assert_nil build_native.at_css("input[type='search']")["data-input-clearable-target"]
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_label_has_id
    assert_css build_field, "label[id='sign_in_form_email_label']"
  end

  def test_listbox_has_aria_labelledby_referencing_label
    assert_css build_field, "ul[role='listbox'][aria-labelledby='sign_in_form_email_label']"
  end

  def test_renders_hidden_value_input
    assert_css build_field, "input[type='hidden'][name='sign_in_form[email]']"
  end

  def test_renders_an_editable_freeform_combobox
    doc = build_field

    assert_css doc, "[data-combobox-mode-value='editable'][data-combobox-value-policy-value='freeform']"
    assert_css doc, "input#sign_in_form_email[role='combobox']"
  end

  def test_renders_listbox_popover
    assert_css build_field, "ul[role='listbox']"
  end

  def test_has_input_action_for_filtering
    assert_css build_field, "input[role='combobox'][data-action*='input->combobox#onInput']"
  end

  def test_renders_initial_choices
    doc = build_field(choices: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  def test_clearable_keeps_caller_controllers_on_the_root
    root = build_field(clearable: true, data: { controller: "analytics", testid: "q" }).at_css("[data-testid='q']")

    assert_equal %w[analytics combobox input-clearable], root["data-controller"].split.sort
  end

  def test_value_policy_can_be_restricted
    assert_css build_field(value_policy: :restricted), "[data-combobox-value-policy-value='restricted']"
  end

  def test_source_reaches_the_combobox
    doc = build_field(source: "/cities", param: :term)

    assert_css doc, "[data-controller='combobox combobox-turbo'][data-combobox-turbo-src-value='/cities']"
    assert_css doc, "turbo-frame[data-combobox-turbo-target='frame']"
  end

  def test_match_and_min_length_reach_the_combobox
    doc = build_field(match: :contains, min_length: 2)

    assert_css doc, "[data-controller~='combobox'][data-combobox-match-value='contains'][data-combobox-min-length-value='2']"
    assert_no_css doc, "[match], [min_length]"
  end

  def test_renders_custom_label_text
    assert_includes build_field(label: "Search users").text, "Search users"
  end

  def test_renders_details_hint
    assert_css build_field(hint: "Start typing to filter"), "#sign_in_form_email_hint"
  end

  def test_renders_error_message
    @form.errors.add(:email, "is blank")

    assert_css build_field, "p[role='alert']"
    assert_includes build_field.text, "is blank"
  end

  def test_combobox_has_aria_invalid_on_error
    @form.errors.add(:email, "is blank")

    assert_equal "true", build_field.at_css("input[role='combobox']")["aria-invalid"]
  end

  def test_clearable_puts_input_clearable_on_the_combobox_root
    assert_css build_field(clearable: true), "[data-controller~='combobox'][data-controller~='input-clearable']"
  end

  def test_clearable_trigger_has_input_clearable_target
    assert_css build_field(clearable: true),
               "input[role='combobox'][data-input-clearable-target='input']"
  end

  def test_clearable_renders_clear_button
    assert_css build_field(clearable: true),
               "button[data-input-clearable-target='clear'][data-action='click->input-clearable#clear']"
  end

  def test_clearable_clear_button_type_is_button
    assert_css build_field(clearable: true), "button[type='button'][data-input-clearable-target='clear']"
  end

  def test_clearable_clear_button_has_aria_label
    assert_css build_field(clearable: true), "button[aria-label='Clear search']"
  end

  def test_clearable_clear_button_is_initially_hidden
    doc    = build_field(clearable: true)
    button = doc.at_css("button[data-input-clearable-target='clear']")

    assert button.key?("hidden"), "Expected clear button to have hidden attribute"
  end

  def test_clearable_clear_button_contains_icon
    assert_css build_field(clearable: true), "button[data-input-clearable-target='clear'] span"
  end

  def test_clearable_clear_button_sits_beside_the_control
    assert_css build_field(clearable: true), "input[role='combobox'] ~ button[data-input-clearable-target='clear']"
  end

  def test_without_clearable_does_not_render_clear_button
    assert_no_css build_field, "button[data-input-clearable-target='clear']"
  end

  def test_without_clearable_trigger_has_no_input_clearable_target
    assert_nil build_field.at_css("input[role='combobox']")["data-input-clearable-target"]
  end

  def test_clearable_option_does_not_leak_into_html_attributes
    assert_nil build_field(clearable: true).at_css("[clearable]")
  end

  def test_model_value_sets_hidden_input_value
    @form.define_singleton_method(:email) { "hello@example.com" }

    assert_equal "hello@example.com",
                 build_field.at_css("input[type='hidden'][name='sign_in_form[email]']")["value"]
  end

  def test_model_value_shows_as_the_freeform_text
    @form.define_singleton_method(:email) { "hello@example.com" }

    assert_equal "hello@example.com", build_field.at_css("input[role='combobox']")["value"]
  end
end
