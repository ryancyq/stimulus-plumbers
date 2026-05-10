# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class SearchFieldTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.search_field(:email, **opts)
    end
    parse_html(html)
  end

  def input_group_for(doc)
    doc.at_css("button[aria-label='Clear search']")&.parent
  end

  # ── default (no clearable) ────────────────────────────────────────────────

  def test_renders_search_input
    assert_css build_field, "input[type='search']"
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_email']"
  end

  def test_does_not_render_clear_button
    assert_no_css build_field, "button[aria-label='Clear search']"
  end

  def test_clearable_option_does_not_leak_into_html_attributes
    doc   = build_field(clearable: false)
    input = doc.at_css("input[type='search']")

    assert_nil input["clearable"]
  end

  def test_applies_form_input_theme_classes
    theme = StimulusPlumbers.config.theme
    doc   = build_field
    input = doc.at_css("input[type='search']")

    assert_includes input["class"].to_s, theme.resolve(:form_input).fetch(:classes, "").split.first
  end

  # ── clearable: true ───────────────────────────────────────────────────────

  def test_clearable_renders_input_group_wrapper
    doc   = build_field(clearable: true)
    group = input_group_for(doc)
    theme = StimulusPlumbers.config.theme

    theme.resolve(:form_input_group).fetch(:classes, "").split.each do |cls|
      assert_includes group["class"].to_s, cls
    end
  end

  def test_clearable_renders_clear_button
    assert_css build_field(clearable: true), "button[aria-label='Clear search']"
  end

  def test_clearable_clear_button_type_is_button
    assert_css build_field(clearable: true), "button[type='button']"
  end

  def test_clearable_input_is_inside_input_group
    doc   = build_field(clearable: true)
    group = input_group_for(doc)

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "input[type='search']"
  end

  def test_clearable_button_is_inside_input_group
    doc   = build_field(clearable: true)
    group = input_group_for(doc)

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "button[aria-label='Clear search']"
  end

  def test_clearable_still_renders_label
    assert_css build_field(clearable: true), "label[for='sign_in_form_email']"
  end

  # ── error state ───────────────────────────────────────────────────────────

  def test_error_renders_error_message
    @form.errors.add(:email, "is blank")

    assert_css build_field, "p[role='alert']"
  end

  def test_clearable_error_renders_error_message
    @form.errors.add(:email, "is blank")

    assert_css build_field(clearable: true), "p[role='alert']"
  end

  def test_clearable_input_group_applies_error_border_on_error
    @form.errors.add(:email, "is blank")
    theme     = StimulusPlumbers.config.theme
    error_cls = theme.resolve(:form_input_group, error: true).fetch(:classes, "")
    doc       = build_field(clearable: true)
    group     = input_group_for(doc)

    error_cls.split.each { |cls| assert_includes group["class"].to_s, cls }
  end

  def test_clearable_input_has_aria_invalid_on_error
    @form.errors.add(:email, "is blank")
    doc   = build_field(clearable: true)
    input = doc.at_css("input[type='search']")

    assert_equal "true", input["aria-invalid"]
  end

  # ── standard field options pass through ───────────────────────────────────

  def test_required_renders_required_attribute
    doc   = build_field(required: true)
    input = doc.at_css("input[type='search']")

    assert_equal "required", input["required"]
  end

  def test_clearable_required_renders_required_attribute
    doc   = build_field(clearable: true, required: true)
    input = doc.at_css("input[type='search']")

    assert_equal "required", input["required"]
  end

  def test_label_option_sets_label_text
    doc = build_field(label: "Search users")

    assert_includes doc.text, "Search users"
  end
end
