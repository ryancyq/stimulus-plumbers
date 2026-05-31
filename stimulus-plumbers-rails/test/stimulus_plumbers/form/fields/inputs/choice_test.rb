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

  def build_field_check_box(**opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:remember_me, as: :check_box, **opts)
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

  def build_choice(as:, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.choice(:role, as: as, collection: ROLES, value_method: :id, text_method: :name, **opts)
    end
    parse_html(html)
  end

  def test_check_box_renders_input
    assert_css build_check_box, "input[type='checkbox']"
  end

  def test_check_box_forwards_data_attributes
    assert_equal "toggle", build_check_box(data: { controller: "toggle" }).at_css("input[type='checkbox']")["data-controller"]
  end

  def test_check_box_forwards_custom_checked_value
    doc = build_check_box(checked_value: "yes", unchecked_value: "no")

    assert_css doc, "input[type='checkbox'][value='yes']"
  end

  def test_radio_button_renders_input
    assert_css build_radio_button, "input[type='radio']"
  end

  def test_radio_button_forwards_data_attributes
    input = build_radio_button("admin", data: { controller: "selector" }).at_css("input[type='radio']")

    assert_equal "selector", input["data-controller"]
  end

  def test_field_check_box_renders_input
    assert_css build_field_check_box, "input[type='checkbox']"
  end

  def test_field_check_box_renders_explicit_label
    doc = build_field_check_box
    label = doc.at_css("label")

    assert_not_nil label
    assert_equal "sign_in_form_remember_me", label["for"]
  end

  def test_field_check_box_label_does_not_wrap_input
    assert_no_css build_field_check_box, "label input[type='checkbox']"
  end

  def test_field_check_box_has_aria_invalid_on_error
    @form.errors.add(:remember_me, "must be accepted")

    assert_equal "true", build_field_check_box.at_css("input[type='checkbox']")["aria-invalid"]
  end

  def test_field_check_box_has_aria_describedby_on_error
    @form.errors.add(:remember_me, "must be accepted")

    assert_includes build_field_check_box.at_css("input[type='checkbox']")["aria-describedby"].to_s,
                    "sign_in_form_remember_me_error"
  end

  def test_field_check_box_required_sets_required_and_aria_required
    doc   = build_field_check_box(required: true)
    input = doc.at_css("input[type='checkbox']")

    assert_equal "required", input["required"]
    assert_equal "true", input["aria-required"]
  end

  def test_field_check_box_renders_hint
    assert_css build_field_check_box(hint: "You must accept"), "#sign_in_form_remember_me_hint"
  end

  def test_field_check_box_hint_adds_aria_describedby
    doc = build_field_check_box(hint: "You must accept")

    assert_includes doc.at_css("input[type='checkbox']")["aria-describedby"].to_s,
                    "sign_in_form_remember_me_hint"
  end

  def test_field_check_box_forwards_checked_value
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.field(:remember_me, as: :check_box, checked_value: "yes", unchecked_value: "no")
    end
    doc = parse_html(html)

    assert_css doc, "input[type='checkbox'][value='yes']"
  end

  def test_collection_radio_buttons_renders_inputs
    assert_css build_collection_radio_buttons, "input[type='radio']"
  end

  def test_collection_radio_buttons_renders_explicit_labels
    doc = build_collection_radio_buttons

    assert_css doc, "label[for]"
    assert_no_css doc, "label input[type='radio']"
  end

  def test_collection_check_boxes_renders_inputs
    assert_css build_collection_check_boxes, "input[type='checkbox']"
  end

  def test_collection_check_boxes_renders_explicit_labels
    doc = build_collection_check_boxes

    assert_css doc, "label[for]"
    assert_no_css doc, "label input[type='checkbox']"
  end

  def test_choice_radio_renders_fieldset
    assert_css build_choice(as: :radio), "fieldset"
  end

  def test_choice_radio_renders_legend
    assert_css build_choice(as: :radio), "fieldset legend"
    assert_includes build_choice(as: :radio).at_css("legend").text, "Role"
  end

  def test_choice_radio_renders_inputs_inside_fieldset
    assert_css build_choice(as: :radio), "fieldset input[type='radio']"
  end

  def test_choice_radio_renders_explicit_labels
    doc = build_choice(as: :radio)

    assert_css doc, "fieldset label[for]"
    assert_no_css doc, "fieldset label input[type='radio']"
  end

  def test_choice_radio_renders_custom_legend_text
    assert_includes build_choice(as: :radio, label: "User Role").at_css("legend").text, "User Role"
  end

  def test_choice_radio_renders_hint
    assert_css build_choice(as: :radio, hint: "Choose a role"), "#sign_in_form_role_hint"
  end

  def test_choice_radio_renders_error_message
    @form.errors.add(:role, "must be selected")

    assert_css build_choice(as: :radio), "p[role='alert']"
    assert_includes build_choice(as: :radio).text, "must be selected"
  end

  def test_choice_radio_has_aria_invalid_on_fieldset_when_error
    @form.errors.add(:role, "must be selected")

    assert_equal "true", build_choice(as: :radio).at_css("fieldset")["aria-invalid"]
  end

  def test_choice_radio_has_aria_describedby_on_fieldset_when_error
    @form.errors.add(:role, "must be selected")

    assert_includes build_choice(as: :radio).at_css("fieldset")["aria-describedby"].to_s,
                    "sign_in_form_role_error"
  end

  def test_choice_radio_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:role, "must be selected")
    @form.errors.add(:role, "is not included in the list")
    doc          = build_choice(as: :radio)
    described_by = doc.at_css("fieldset")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_role_error_1"
    assert_includes described_by, "sign_in_form_role_error_2"
  end

  def test_choice_radio_multiple_error_elements_have_matching_ids
    @form.errors.add(:role, "must be selected")
    @form.errors.add(:role, "is not included in the list")
    doc = build_choice(as: :radio)

    assert_css doc, "#sign_in_form_role_error_1"
    assert_css doc, "#sign_in_form_role_error_2"
  end

  def test_choice_radio_has_aria_describedby_on_fieldset_when_hint
    doc = build_choice(as: :radio, hint: "Choose a role")

    assert_includes doc.at_css("fieldset")["aria-describedby"].to_s, "sign_in_form_role_hint"
  end

  def test_choice_radio_required_does_not_set_aria_required_on_fieldset
    doc = build_choice(as: :radio, required: true)

    assert_nil doc.at_css("fieldset")["aria-required"]
  end

  def test_choice_radio_required_sets_aria_required_on_inputs
    doc = build_choice(as: :radio, required: true)

    doc.css("input[type='radio']").each do |input|
      assert_equal "true", input["aria-required"]
    end
  end

  def test_choice_radio_required_renders_mark_in_legend
    doc = build_choice(as: :radio, required: true)

    assert_css doc, "legend span[aria-hidden='true']"
  end

  def test_choice_check_box_renders_fieldset
    assert_css build_choice(as: :check_box), "fieldset"
  end

  def test_choice_check_box_renders_legend
    assert_css build_choice(as: :check_box), "fieldset legend"
    assert_includes build_choice(as: :check_box).at_css("legend").text, "Role"
  end

  def test_choice_check_box_renders_inputs_inside_fieldset
    assert_css build_choice(as: :check_box), "fieldset input[type='checkbox']"
  end

  def test_choice_check_box_renders_explicit_labels
    doc = build_choice(as: :check_box)

    assert_css doc, "fieldset label[for]"
    assert_no_css doc, "fieldset label input[type='checkbox']"
  end

  def test_choice_check_box_renders_custom_legend_text
    assert_includes build_choice(as: :check_box, label: "Permissions").at_css("legend").text, "Permissions"
  end

  def test_choice_check_box_renders_hint
    assert_css build_choice(as: :check_box, hint: "Select all that apply"), "#sign_in_form_role_hint"
  end

  def test_choice_check_box_renders_error_message
    @form.errors.add(:role, "is invalid")

    assert_css build_choice(as: :check_box), "p[role='alert']"
    assert_includes build_choice(as: :check_box).text, "is invalid"
  end

  def test_choice_check_box_has_aria_invalid_on_fieldset_when_error
    @form.errors.add(:role, "is invalid")

    assert_equal "true", build_choice(as: :check_box).at_css("fieldset")["aria-invalid"]
  end

  def test_choice_check_box_has_aria_describedby_on_fieldset_when_error
    @form.errors.add(:role, "is invalid")

    assert_includes build_choice(as: :check_box).at_css("fieldset")["aria-describedby"].to_s,
                    "sign_in_form_role_error"
  end

  def test_choice_check_box_aria_describedby_references_all_error_ids_for_multiple_errors
    @form.errors.add(:role, "is invalid")
    @form.errors.add(:role, "must be selected")
    doc          = build_choice(as: :check_box)
    described_by = doc.at_css("fieldset")["aria-describedby"].to_s

    assert_includes described_by, "sign_in_form_role_error_1"
    assert_includes described_by, "sign_in_form_role_error_2"
  end

  def test_choice_check_box_multiple_error_elements_have_matching_ids
    @form.errors.add(:role, "is invalid")
    @form.errors.add(:role, "must be selected")
    doc = build_choice(as: :check_box)

    assert_css doc, "#sign_in_form_role_error_1"
    assert_css doc, "#sign_in_form_role_error_2"
  end

  def test_choice_check_box_has_aria_describedby_on_fieldset_when_hint
    doc = build_choice(as: :check_box, hint: "Select all that apply")

    assert_includes doc.at_css("fieldset")["aria-describedby"].to_s, "sign_in_form_role_hint"
  end

  def test_choice_check_box_required_does_not_set_aria_required_on_fieldset
    doc = build_choice(as: :check_box, required: true)

    assert_nil doc.at_css("fieldset")["aria-required"]
  end

  def test_choice_check_box_required_sets_aria_required_on_inputs
    doc = build_choice(as: :check_box, required: true)

    doc.css("input[type='checkbox']").each do |input|
      assert_equal "true", input["aria-required"]
    end
  end

  def test_choice_check_box_required_renders_mark_in_legend
    doc = build_choice(as: :check_box, required: true)

    assert_css doc, "legend span[aria-hidden='true']"
  end
end
