# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class ChoiceTest < ActionView::TestCase
  Role = Struct.new(:id, :name)

  ROLES = [
    Role.new("admin", "Admin"),
    Role.new("editor", "Editor")
  ].freeze

  def setup
    @form = FormBuilderModel.new
  end

  def build_check_box(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.check_box(:remember_me, **opts)
    end
    parse_html(html)
  end

  def build_radio_button(tag_value = "admin", **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.radio_button(:role, tag_value, **opts)
    end
    parse_html(html)
  end

  # ── check_box ─────────────────────────────────────────────────────────────

  def test_check_box_renders_input
    assert_css build_check_box, "input[type='checkbox']"
  end

  def test_check_box_renders_label
    assert_css build_check_box, "label[for='sign_in_form_remember_me']"
  end

  def test_check_box_has_aria_invalid_on_error
    @form.errors.add(:remember_me, "must be accepted")

    assert_equal "true", build_check_box.at_css("input[type='checkbox']")["aria-invalid"]
  end

  def test_check_box_has_aria_describedby_on_error
    @form.errors.add(:remember_me, "must be accepted")

    assert_includes build_check_box.at_css("input[type='checkbox']")["aria-describedby"].to_s,
                    "sign_in_form_remember_me_error"
  end

  def test_check_box_required_sets_required_and_aria_required
    doc   = build_check_box(required: true)
    input = doc.at_css("input[type='checkbox']")

    assert_equal "required", input["required"]
    assert_equal "true", input["aria-required"]
  end

  # ── radio_button ──────────────────────────────────────────────────────────

  def test_radio_button_renders_input
    assert_css build_radio_button, "input[type='radio']"
  end

  def test_radio_button_renders_label
    assert_css build_radio_button, "label[for='sign_in_form_role_admin']"
  end

  def test_radio_button_has_aria_invalid_on_error
    @form.errors.add(:role, "is not included in the list")

    assert_equal "true", build_radio_button.at_css("input[type='radio']")["aria-invalid"]
  end

  def test_radio_button_has_aria_describedby_on_error
    @form.errors.add(:role, "is not included in the list")

    assert_includes build_radio_button.at_css("input[type='radio']")["aria-describedby"].to_s,
                    "sign_in_form_role_admin_error"
  end
end
