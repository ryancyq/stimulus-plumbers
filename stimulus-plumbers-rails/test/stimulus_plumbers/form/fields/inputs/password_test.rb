# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class PasswordTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.password_field(:password, **opts)
    end
    parse_html(html)
  end

  # ── default (no reveal) ───────────────────────────────────────────────────

  def test_renders_password_input
    assert_css build_field, "input[type='password']"
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_password']"
  end

  def test_does_not_render_input_group_wrapper
    assert_no_css build_field, "[data-controller='input-format']"
  end

  def test_does_not_render_toggle_button
    assert_no_css build_field, "button[data-input-format-target='toggle']"
  end

  def test_reveal_option_does_not_leak_into_html_attributes
    assert_nil build_field(reveal: false).at_css("input[type='password']")["reveal"]
  end

  # ── reveal: true ──────────────────────────────────────────────────────────

  def test_reveal_renders_input_group_with_stimulus_controller
    assert_css build_field(reveal: true), "[data-controller='input-format']"
  end

  def test_reveal_input_group_has_password_type_value
    assert_css build_field(reveal: true), "[data-input-format-type-value='password']"
  end

  def test_reveal_input_has_stimulus_target
    assert_css build_field(reveal: true), "input[data-input-format-target='input']"
  end

  def test_reveal_renders_toggle_button
    assert_css build_field(reveal: true), "button[data-input-format-target='toggle']"
  end

  def test_reveal_toggle_button_has_action
    assert_css build_field(reveal: true), "button[data-action='click->input-format#toggle']"
  end

  def test_reveal_toggle_button_has_aria_label
    assert_css build_field(reveal: true), "button[aria-label='Show password']"
  end

  def test_reveal_toggle_button_has_aria_pressed_false
    assert_css build_field(reveal: true), "button[aria-pressed='false']"
  end

  def test_reveal_toggle_button_type_is_button
    assert_css build_field(reveal: true), "button[type='button']"
  end

  def test_reveal_input_is_inside_input_group
    group = build_field(reveal: true).at_css("[data-controller='input-format']")

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "input[type='password']"
  end

  def test_reveal_button_is_inside_input_group
    group = build_field(reveal: true).at_css("[data-controller='input-format']")

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "button"
  end

  def test_reveal_still_renders_label
    assert_css build_field(reveal: true), "label[for='sign_in_form_password']"
  end

  # ── error state ───────────────────────────────────────────────────────────

  def test_renders_error_message
    @form.errors.add(:password, "is too short")

    assert_css build_field, "p[role='alert']"
  end

  def test_reveal_renders_error_message
    @form.errors.add(:password, "is too short")

    assert_css build_field(reveal: true), "p[role='alert']"
  end

  def test_reveal_input_has_aria_invalid_on_error
    @form.errors.add(:password, "is too short")

    assert_equal "true", build_field(reveal: true).at_css("input[type='password']")["aria-invalid"]
  end

  # ── field options ─────────────────────────────────────────────────────────

  def test_required_renders_required_attribute
    assert_equal "required", build_field(required: true).at_css("input[type='password']")["required"]
  end

  def test_reveal_required_renders_required_attribute
    assert_equal "required", build_field(reveal: true, required: true).at_css("input[type='password']")["required"]
  end

  def test_label_option_sets_label_text
    assert_includes build_field(label: "Secret").text, "Secret"
  end
end
