# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class SearchTest < ActionView::TestCase
  SIMPLE_OPTIONS = [%w[London london], %w[Paris paris]].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.search_field(:email, **opts)
    end
    parse_html(html)
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_renders_hidden_value_input
    assert_css build_field, "input[type='hidden'][name='sign_in_form[email]']"
  end

  def test_renders_combobox_trigger
    assert_css build_field, "input[role='combobox']"
  end

  def test_trigger_is_not_readonly
    assert_not build_field.at_css("input[role='combobox']").key?("readonly"), "Expected trigger to not be readonly"
  end

  def test_trigger_has_haspopup_listbox
    assert_css build_field, "input[aria-haspopup='listbox']"
  end

  def test_renders_listbox_popover
    assert_css build_field, "ul[role='listbox']"
  end

  def test_has_input_action_for_filtering
    assert_css build_field, "[data-action*='input->input-combobox#onInput']"
  end

  # ── options ───────────────────────────────────────────────────────────────

  def test_renders_initial_options
    doc = build_field(options: SIMPLE_OPTIONS)

    assert_css doc, "li[role='option'][data-value='london']"
    assert_css doc, "li[role='option'][data-value='paris']"
  end

  # ── url (server-side filtering) ───────────────────────────────────────────

  def test_url_sets_combobox_dropdown_url_value
    assert_css build_field(url: "/cities"), "[data-combobox-dropdown-url-value='/cities']"
  end

  def test_url_option_does_not_leak_into_html_attributes
    assert_nil build_field(url: "/cities").at_css("[url]")
  end

  # ── field options ─────────────────────────────────────────────────────────

  def test_renders_custom_label_text
    assert_includes build_field(label: "Search users").text, "Search users"
  end

  def test_renders_details_hint
    assert_css build_field(details: "Start typing to filter"), "#sign_in_form_email_hint"
  end

  # ── error state ───────────────────────────────────────────────────────────

  def test_renders_error_message
    @form.errors.add(:email, "is blank")

    assert_css build_field, "p[role='alert']"
    assert_includes build_field.text, "is blank"
  end

  def test_combobox_has_aria_invalid_on_error
    @form.errors.add(:email, "is blank")

    assert_equal "true", build_field.at_css("[data-controller~='input-combobox']")["aria-invalid"]
  end

  # ── clearable: true ───────────────────────────────────────────────────────

  def test_clearable_renders_input_search_controller_wrapper
    assert_css build_field(clearable: true), "[data-controller='input-search']"
  end

  def test_clearable_combobox_is_inside_input_search_wrapper
    doc     = build_field(clearable: true)
    wrapper = doc.at_css("[data-controller='input-search']")

    assert_not_nil wrapper.at_css("[data-controller~='input-combobox']")
  end

  def test_clearable_trigger_has_input_search_target
    assert_css build_field(clearable: true),
               "input[role='combobox'][data-input-search-target='input']"
  end

  def test_clearable_renders_clear_button
    assert_css build_field(clearable: true),
               "button[data-input-search-target='clear'][data-action='click->input-search#clear']"
  end

  def test_clearable_clear_button_type_is_button
    assert_css build_field(clearable: true), "button[type='button'][data-input-search-target='clear']"
  end

  def test_clearable_clear_button_has_aria_label
    assert_css build_field(clearable: true), "button[aria-label='Clear search']"
  end

  def test_clearable_clear_button_is_initially_hidden
    doc    = build_field(clearable: true)
    button = doc.at_css("button[data-input-search-target='clear']")

    assert button.key?("hidden"), "Expected clear button to have hidden attribute"
  end

  def test_clearable_clear_button_is_inside_input_search_wrapper
    doc     = build_field(clearable: true)
    wrapper = doc.at_css("[data-controller='input-search']")

    assert_not_nil wrapper.at_css("button[data-input-search-target='clear']")
  end

  def test_without_clearable_does_not_render_input_search_controller
    assert_no_css build_field, "[data-controller='input-search']"
  end

  def test_without_clearable_trigger_has_no_input_search_target
    assert_nil build_field.at_css("input[role='combobox']")["data-input-search-target"]
  end

  def test_clearable_option_does_not_leak_into_html_attributes
    assert_nil build_field(clearable: true).at_css("[clearable]")
  end

  def test_clearable_still_renders_label
    assert_css build_field(clearable: true), "label[for='sign_in_form_email']"
  end

  def test_clearable_still_renders_error_message
    @form.errors.add(:email, "is blank")

    assert_css build_field(clearable: true), "p[role='alert']"
  end

  def test_clearable_still_renders_hidden_value_input
    assert_css build_field(clearable: true), "input[type='hidden'][name='sign_in_form[email]']"
  end
end
