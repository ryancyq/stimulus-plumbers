# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class PasswordTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_native(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.password_field(:password, **opts)
    end
    parse_html(html)
  end

  def build_field(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:password, as: :password, **opts)
    end
    parse_html(html)
  end

  def test_renders_password_input
    assert_css build_native, "input[type='password']"
  end

  def test_does_not_render_input_group_wrapper
    assert_no_css build_native, "[data-controller='input-revealable']"
  end

  def test_does_not_render_toggle_button
    assert_no_css build_native, "button[data-input-revealable-target='toggle']"
  end

  def test_revealable_option_does_not_leak_into_html_attributes
    assert_nil build_native(revealable: false).at_css("input[type='password']")["revealable"]
  end

  def test_reveal_renders_input_group_with_stimulus_controller
    assert_css build_native(revealable: true), "[data-controller='input-revealable']"
  end

  def test_reveal_input_has_stimulus_target
    assert_css build_native(revealable: true), "input[data-input-revealable-target='input']"
  end

  def test_reveal_renders_toggle_button
    assert_css build_native(revealable: true), "button[data-input-revealable-target='toggle']"
  end

  def test_reveal_toggle_button_has_action
    assert_css build_native(revealable: true), "button[data-action='click->input-revealable#toggle']"
  end

  def test_reveal_toggle_button_has_aria_label
    assert_css build_native(revealable: true), "button[aria-label='Show password']"
  end

  def test_reveal_toggle_button_has_no_aria_pressed_attribute
    assert_nil build_native(revealable: true).at_css("button[data-input-revealable-target='toggle']")["aria-pressed"]
  end

  def test_reveal_toggle_button_renders_reveal_and_conceal_icons
    button = build_native(revealable: true).at_css("button[data-input-revealable-target='toggle']")
    icon_html = parse_html(button.to_html)

    assert_css icon_html, "[data-input-revealable-target='revealIcon'][aria-hidden='true']"
    assert_css icon_html, "[data-input-revealable-target='concealIcon'][aria-hidden='true'][hidden]"
    assert_no_css icon_html, "[data-input-revealable-target='revealIcon'][hidden]"
  end

  def test_reveal_input_group_has_toggle_label_values
    group = build_native(revealable: true).at_css("[data-controller='input-revealable']")

    assert_equal "Show password", group["data-input-revealable-reveal-label-value"]
    assert_equal "Hide password", group["data-input-revealable-conceal-label-value"]
  end

  def test_reveal_toggle_button_type_is_button
    assert_css build_native(revealable: true), "button[type='button']"
  end

  def test_reveal_input_is_inside_input_group
    group = build_native(revealable: true).at_css("[data-controller='input-revealable']")

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "input[type='password']"
  end

  def test_reveal_button_is_inside_input_group
    group = build_native(revealable: true).at_css("[data-controller='input-revealable']")

    assert_not_nil group
    assert_css Nokogiri::HTML.fragment(group.to_html), "button"
  end

  def test_defaults_autocomplete_to_current_password
    input = build_native.at_css("input[type='password']")

    assert_equal "current-password", input["autocomplete"]
  end

  def test_forwards_explicit_autocomplete_to_input
    input = build_native(autocomplete: "new-password").at_css("input[type='password']")

    assert_equal "new-password", input["autocomplete"]
  end

  def test_emits_off_autocomplete_verbatim
    input = build_native(revealable: true, autocomplete: "off").at_css("input[type='password']")

    assert_equal "off", input["autocomplete"]
  end

  def test_field_defaults_autocomplete_to_current_password
    input = build_field.at_css("input[type='password']")

    assert_equal "current-password", input["autocomplete"]
  end

  def test_field_forwards_explicit_autocomplete_to_input
    input = build_field(revealable: true, autocomplete: "new-password").at_css("input[type='password']")

    assert_equal "new-password", input["autocomplete"]
  end

  def test_forwards_data_attributes_to_input
    assert_equal "validator",
                 build_native(data: { controller: "validator" }).at_css("input[type='password']")["data-controller"]
  end

  def test_renders_label
    assert_css build_field, "label[for='sign_in_form_password']"
  end

  def test_reveal_still_renders_label
    assert_css build_field(revealable: true), "label[for='sign_in_form_password']"
  end

  def test_renders_error_message
    @form.errors.add(:password, "is too short")

    assert_css build_field, "p[role='alert']"
  end

  def test_reveal_renders_error_message
    @form.errors.add(:password, "is too short")

    assert_css build_field(revealable: true), "p[role='alert']"
  end

  def test_reveal_input_has_aria_invalid_on_error
    @form.errors.add(:password, "is too short")

    assert_equal "true", build_field(revealable: true).at_css("input[type='password']")["aria-invalid"]
  end

  def test_required_renders_required_attribute
    assert_equal "required", build_field(required: true).at_css("input[type='password']")["required"]
  end

  def test_reveal_required_renders_required_attribute
    assert_equal "required", build_field(revealable: true, required: true).at_css("input[type='password']")["required"]
  end

  def test_label_option_sets_label_text
    assert_includes build_field(label: "Secret").text, "Secret"
  end

  def test_renders_hint
    assert_css build_field(hint: "Min 8 characters"), "#sign_in_form_password_hint"
  end

  def test_reveal_renders_hint
    assert_css build_field(revealable: true, hint: "Min 8 characters"), "#sign_in_form_password_hint"
  end

  def test_hide_label_keeps_label_in_dom
    assert_css build_field(hide_label: true), "label[for='sign_in_form_password']"
  end
end
