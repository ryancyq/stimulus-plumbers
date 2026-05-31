# frozen_string_literal: true

require "test_helper"
require_relative "../form_field_model"

class FieldsetTest < ActionView::TestCase
  def setup
    @form = FormFieldModel.new
  end

  def component(**opts)
    StimulusPlumbers::Form::Field.new(view, **opts)
  end

  def render_inputs(field, inputs = "<input>")
    parse_html(
      StimulusPlumbers::Form::Fields::Fieldset.new(view).render(
        @form, :email, "sign_in_form_email", field
      ) { inputs.html_safe }
    )
  end

  def test_renders_fieldset
    assert_css render_inputs(component), "fieldset"
  end

  def test_renders_legend_with_label_text
    doc = render_inputs(component(label: "Notifications"))

    assert_includes doc.at_css("legend").text, "Notifications"
  end

  def test_renders_legend_with_humanized_attribute_when_no_label
    doc = render_inputs(component)

    assert_includes doc.at_css("legend").text, "Email"
  end

  def test_renders_inputs_inside_fieldset
    doc = render_inputs(component, "<input type='radio'>")

    assert_css doc, "fieldset input[type='radio']"
  end

  def test_renders_required_mark_in_legend
    doc = render_inputs(component(required: true))

    assert_css doc, "legend span[aria-hidden='true']"
    assert_includes doc.at_css("legend span[aria-hidden='true']").text, "*"
  end

  def test_no_required_mark_without_required
    doc = render_inputs(component)

    assert_nil doc.at_css("legend span[aria-hidden='true']")
  end

  def test_renders_legend_when_hide_label
    doc = render_inputs(component(hide_label: true))

    assert_css doc, "legend"
  end

  def test_fieldset_has_aria_invalid_when_error
    @form.errors.add(:email, "is invalid")
    doc = render_inputs(component)

    assert_equal "true", doc.at_css("fieldset")["aria-invalid"]
  end

  def test_fieldset_has_aria_describedby_when_hint_present
    doc = render_inputs(component(hint: "Pick one"))

    assert_equal "sign_in_form_email_hint", doc.at_css("fieldset")["aria-describedby"]
  end

  def test_fieldset_does_not_set_aria_required
    doc = render_inputs(component(required: true))

    assert_nil doc.at_css("fieldset")["aria-required"]
  end

  def test_renders_hint_outside_fieldset
    doc = render_inputs(component(hint: "Pick one"))

    assert_css doc, "#sign_in_form_email_hint"
    assert_nil doc.at_css("fieldset #sign_in_form_email_hint")
  end

  def test_renders_error_outside_fieldset
    @form.errors.add(:email, "is invalid")
    doc = render_inputs(component)

    assert_css doc, "p[role='alert']"
    assert_nil doc.at_css("fieldset p[role='alert']")
  end

  def test_single_error_element_has_base_id
    @form.errors.add(:email, "is invalid")
    doc = render_inputs(component)

    assert_css doc, "p[id='sign_in_form_email_error'][role='alert']"
  end

  def test_multiple_error_elements_have_suffixed_ids
    @form.errors.add(:email, "is invalid")
    @form.errors.add(:email, "is too long")
    doc = render_inputs(component)

    assert_css doc, "p[id='sign_in_form_email_error_1'][role='alert']"
    assert_css doc, "p[id='sign_in_form_email_error_2'][role='alert']"
    assert_nil doc.at_css("p[id='sign_in_form_email_error']")
  end
end
