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
end
