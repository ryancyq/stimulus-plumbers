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

  def build_check_box(checked_value: "1", unchecked_value: "0", **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.check_box(:remember_me, opts, checked_value, unchecked_value)
    end
    parse_html(html)
  end

  def build_radio_button(tag_value = "admin", **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.radio_button(:role, tag_value, **opts)
    end
    parse_html(html)
  end

  def build_collection_radio_buttons(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_radio_buttons(:role, ROLES, :id, :name, **opts)
    end
    parse_html(html)
  end

  def build_collection_check_boxes(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.collection_check_boxes(:role, ROLES, :id, :name, **opts)
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

  def test_check_box_renders_hint
    assert_css build_check_box(hint: "You must accept"), "#sign_in_form_remember_me_hint"
  end

  def test_check_box_forwards_data_attributes
    assert_equal "toggle", build_check_box(data: { controller: "toggle" }).at_css("input[type='checkbox']")["data-controller"]
  end

  def test_check_box_forwards_custom_checked_value
    doc = build_check_box(checked_value: "yes", unchecked_value: "no")

    assert_css doc, "input[type='checkbox'][value='yes']"
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

  def test_radio_button_renders_hint
    assert_css build_radio_button("admin", hint: "Select your role"), "#sign_in_form_role_admin_hint"
  end

  def test_radio_button_forwards_data_attributes
    input = build_radio_button("admin", data: { controller: "selector" }).at_css("input[type='radio']")

    assert_equal "selector", input["data-controller"]
  end

  # ── collection_radio_buttons ──────────────────────────────────────────────

  def test_collection_radio_buttons_renders_fieldset
    assert_css build_collection_radio_buttons, "fieldset"
  end

  def test_collection_radio_buttons_renders_legend
    assert_css build_collection_radio_buttons, "fieldset legend"
    assert_includes build_collection_radio_buttons.at_css("legend").text, "Role"
  end

  def test_collection_radio_buttons_renders_inputs_inside_fieldset
    assert_css build_collection_radio_buttons, "fieldset input[type='radio']"
  end

  def test_collection_radio_buttons_renders_custom_legend_text
    assert_includes build_collection_radio_buttons(label: "User Role").at_css("legend").text, "User Role"
  end

  def test_collection_radio_buttons_renders_details_hint
    assert_css build_collection_radio_buttons(hint: "Choose a role"), "#sign_in_form_role_hint"
  end

  def test_collection_radio_buttons_renders_error_message
    @form.errors.add(:role, "must be selected")

    assert_css build_collection_radio_buttons, "p[role='alert']"
    assert_includes build_collection_radio_buttons.text, "must be selected"
  end

  def test_collection_radio_buttons_has_aria_invalid_on_fieldset_when_error
    @form.errors.add(:role, "must be selected")

    assert_equal "true", build_collection_radio_buttons.at_css("fieldset")["aria-invalid"]
  end

  def test_collection_radio_buttons_has_aria_describedby_on_fieldset_when_error
    @form.errors.add(:role, "must be selected")

    assert_includes build_collection_radio_buttons.at_css("fieldset")["aria-describedby"].to_s,
                    "sign_in_form_role_error"
  end

  def test_collection_radio_buttons_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:role, "must be selected")
    @form.errors.add(:role, "is not included in the list")
    doc = build_collection_radio_buttons

    described_by = doc.at_css("fieldset")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_role_error_1"
    assert_includes described_by, "sign_in_form_role_error_2"
  end

  def test_collection_radio_buttons_multiple_error_elements_have_matching_ids
    @form.errors.add(:role, "must be selected")
    @form.errors.add(:role, "is not included in the list")
    doc = build_collection_radio_buttons

    assert_css doc, "#sign_in_form_role_error_1"
    assert_css doc, "#sign_in_form_role_error_2"
  end

  def test_collection_radio_buttons_has_aria_describedby_on_fieldset_when_hint
    doc = build_collection_radio_buttons(hint: "Choose a role")

    assert_includes doc.at_css("fieldset")["aria-describedby"].to_s, "sign_in_form_role_hint"
  end

  def test_collection_radio_buttons_required_sets_aria_required_on_fieldset
    doc = build_collection_radio_buttons(required: true)

    assert_equal "true", doc.at_css("fieldset")["aria-required"]
  end

  def test_collection_radio_buttons_required_renders_mark_in_legend
    doc = build_collection_radio_buttons(required: true)

    assert_css doc, "legend span[aria-hidden='true']"
  end

  # ── collection_check_boxes ────────────────────────────────────────────────

  def test_collection_check_boxes_renders_fieldset
    assert_css build_collection_check_boxes, "fieldset"
  end

  def test_collection_check_boxes_renders_legend
    assert_css build_collection_check_boxes, "fieldset legend"
    assert_includes build_collection_check_boxes.at_css("legend").text, "Role"
  end

  def test_collection_check_boxes_renders_inputs_inside_fieldset
    assert_css build_collection_check_boxes, "fieldset input[type='checkbox']"
  end

  def test_collection_check_boxes_renders_custom_legend_text
    assert_includes build_collection_check_boxes(label: "Permissions").at_css("legend").text, "Permissions"
  end

  def test_collection_check_boxes_renders_details_hint
    assert_css build_collection_check_boxes(hint: "Select all that apply"), "#sign_in_form_role_hint"
  end

  def test_collection_check_boxes_renders_error_message
    @form.errors.add(:role, "is invalid")

    assert_css build_collection_check_boxes, "p[role='alert']"
    assert_includes build_collection_check_boxes.text, "is invalid"
  end

  def test_collection_check_boxes_has_aria_invalid_on_fieldset_when_error
    @form.errors.add(:role, "is invalid")

    assert_equal "true", build_collection_check_boxes.at_css("fieldset")["aria-invalid"]
  end

  def test_collection_check_boxes_has_aria_describedby_on_fieldset_when_error
    @form.errors.add(:role, "is invalid")

    assert_includes build_collection_check_boxes.at_css("fieldset")["aria-describedby"].to_s,
                    "sign_in_form_role_error"
  end

  def test_collection_check_boxes_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:role, "is invalid")
    @form.errors.add(:role, "must be selected")
    doc = build_collection_check_boxes

    described_by = doc.at_css("fieldset")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_role_error_1"
    assert_includes described_by, "sign_in_form_role_error_2"
  end

  def test_collection_check_boxes_multiple_error_elements_have_matching_ids
    @form.errors.add(:role, "is invalid")
    @form.errors.add(:role, "must be selected")
    doc = build_collection_check_boxes

    assert_css doc, "#sign_in_form_role_error_1"
    assert_css doc, "#sign_in_form_role_error_2"
  end

  def test_collection_check_boxes_has_aria_describedby_on_fieldset_when_hint
    doc = build_collection_check_boxes(hint: "Select all that apply")

    assert_includes doc.at_css("fieldset")["aria-describedby"].to_s, "sign_in_form_role_hint"
  end

  def test_collection_check_boxes_required_sets_aria_required_on_fieldset
    doc = build_collection_check_boxes(required: true)

    assert_equal "true", doc.at_css("fieldset")["aria-required"]
  end

  def test_collection_check_boxes_required_renders_mark_in_legend
    doc = build_collection_check_boxes(required: true)

    assert_css doc, "legend span[aria-hidden='true']"
  end
end
