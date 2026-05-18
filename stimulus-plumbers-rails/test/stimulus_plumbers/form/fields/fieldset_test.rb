# frozen_string_literal: true

require "test_helper"
require_relative "../form_field_model"

class FieldsetTest < ActionView::TestCase
  def setup
    @form = FormFieldModel.new
  end

  def component(**opts)
    StimulusPlumbers::Form::Field.new(
      object:    @form,
      attribute: :email,
      input_id:  "sign_in_form_email",
      **opts
    )
  end

  def render_inputs(field, inputs = "<input>", **fieldset_opts)
    parse_html(StimulusPlumbers::Form::Fields::Fieldset.new(view).render(field, inputs, **fieldset_opts))
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_fieldset
    assert_css render_inputs(component), "fieldset"
  end

  def test_renders_legend_with_label_text
    doc = render_inputs(component(label: "Notifications"))

    assert_includes doc.at_css("legend").text, "Notifications"
  end

  def test_renders_inputs_inside_fieldset
    doc = render_inputs(component, "<input type='radio'>")

    assert_css doc, "fieldset input[type='radio']"
  end

  # ── legend required mark ───────────────────────────────────────────────────

  def test_renders_required_mark_in_legend
    doc = render_inputs(component(required: true))

    assert_css doc, "legend span[aria-hidden='true']"
    assert_includes doc.at_css("legend span[aria-hidden='true']").text, "*"
  end

  def test_no_required_mark_without_required
    doc = render_inputs(component)

    assert_nil doc.at_css("legend span[aria-hidden='true']")
  end

  # ── hidden legend ──────────────────────────────────────────────────────────

  def test_renders_legend_when_label_visibility_exclusive
    doc = render_inputs(component(label_visibility: :exclusive))

    assert_css doc, "legend"
  end

  # ── fieldset opts passthrough ──────────────────────────────────────────────

  def test_fieldset_opts_applied_to_fieldset_element
    doc = render_inputs(component, "<input>", "aria-describedby": "some_hint", "aria-invalid": "true")

    fieldset = doc.at_css("fieldset")

    assert_equal "some_hint", fieldset["aria-describedby"]
    assert_equal "true",      fieldset["aria-invalid"]
  end

  # ── hint ──────────────────────────────────────────────────────────────────

  def test_renders_hint_outside_fieldset
    doc = render_inputs(component(details: "Pick one"))

    assert_css doc, "#sign_in_form_email_hint"
    assert_nil doc.at_css("fieldset #sign_in_form_email_hint")
  end

  # ── error ─────────────────────────────────────────────────────────────────

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
