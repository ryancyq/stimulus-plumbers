# frozen_string_literal: true

require "test_helper"
require "nokogiri"
require_relative "form_builder_model"

class BuilderTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  # ── Helpers ────────────────────────────────────────────────────────────────

  def build_field(method_name, attribute, *args, **opts)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session") do |f|
      f.public_send(method_name, attribute, *args, **opts)
    end
    Nokogiri::HTML.fragment(html)
  end

  def build_form(&block)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session", &block)
    Nokogiri::HTML.fragment(html)
  end

  def assert_css(doc, selector, msg = nil)
    assert_predicate doc.css(selector), :any?, msg || "Expected to find #{selector.inspect}"
  end

  def refute_css(doc, selector, msg = nil)
    assert_predicate doc.css(selector), :none?, msg || "Expected not to find #{selector.inspect}"
  end

  # ── FieldComponent integration ─────────────────────────────────────────────

  def test_field_renders_label_associated_to_input
    doc = build_field(:email_field, :email)

    assert_css doc, "label[for='sign_in_form_email']"
    assert_css doc, "input[type='email'][name='sign_in_form[email]']"
  end

  def test_field_renders_custom_label_text
    doc = build_field(:email_field, :email, label: "Email address")

    assert_includes doc.text, "Email address"
  end

  def test_field_renders_details_hint
    doc = build_field(:email_field, :email, details: "We'll never share your email.")

    assert_css doc, "#sign_in_form_email_hint"
    assert_includes doc.text, "We'll never share your email."
  end

  def test_field_renders_required_indicator
    doc = build_field(:email_field, :email, required: true)

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.css("span[aria-hidden='true']").text, "*"
  end

  def test_field_renders_model_error
    @form.errors.add(:email, "is invalid")
    doc = build_field(:email_field, :email)

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "is invalid"
  end

  def test_field_renders_error_override
    doc = build_field(:email_field, :email, error: "Something went wrong")

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "Something went wrong"
  end

  def test_hidden_field_renders_without_field_wrapper
    doc = build_field(:hidden_field, :email)

    assert_css doc, "input[type='hidden']"
    refute_css doc, "label"
  end

  # ── password_field reveal ─────────────────────────────────────────────────

  def test_password_reveal_renders_actor_wrapper
    doc = build_field(:password_field, :password, reveal: true)

    assert_css doc, "[data-controller='password-reveal']"
  end

  def test_password_reveal_renders_toggle_button
    doc = build_field(:password_field, :password, reveal: true)

    assert_css doc, "button[data-action='click->password-reveal#toggle']"
  end

  def test_password_reveal_wires_input_target
    doc = build_field(:password_field, :password, reveal: true)

    assert_css doc, "input[data-password-reveal-target='input']"
  end

  def test_password_without_reveal_renders_plain_input
    doc = build_field(:password_field, :password)

    assert_css doc, "input[type='password']"
    refute_css doc, "[data-controller='password-reveal']"
  end

  # ── text_area auto-resize ─────────────────────────────────────────────────

  def test_text_area_wires_auto_resize_controller
    doc = build_field(:text_area, :email)

    textarea = doc.at_css("textarea")

    refute_nil textarea
    assert_includes textarea["data-controller"].to_s, "auto-resize"
  end

  # ── aria-describedby ──────────────────────────────────────────────────────

  def test_input_has_aria_describedby_for_hint
    doc = build_field(:email_field, :email, details: "Hint text")

    input = doc.at_css("input[type='email']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_email_hint"
  end

  def test_input_has_aria_describedby_for_error
    @form.errors.add(:email, "is invalid")
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_includes input["aria-describedby"].to_s, "sign_in_form_email_error"
  end

  def test_input_has_no_aria_describedby_without_hint_or_error
    doc = build_field(:email_field, :email)

    input = doc.at_css("input[type='email']")

    assert_nil input["aria-describedby"]
  end

  # ── label_visibility ──────────────────────────────────────────────────────

  def test_exclusive_label_visibility_adds_sr_only
    doc = build_field(:email_field, :email, label_visibility: :exclusive)

    assert_css doc, "label.sr-only"
  end

  # ── extract_options ───────────────────────────────────────────────────────

  def test_extract_options_separates_custom_keys
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})

    custom, rails = builder.send(:extract_options, { label: "Email", required: true, class: "custom", id: "my-id" })

    assert_equal({ label: "Email", required: true }, custom)
    assert_equal({ class: "custom", id: "my-id" }, rails)
  end

  def test_extract_options_leaves_rails_options_intact
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})

    custom, rails = builder.send(:extract_options, { autocomplete: "email", placeholder: "you@example.com" })

    assert_empty custom
    assert_equal({ autocomplete: "email", placeholder: "you@example.com" }, rails)
  end

  # ── apply_stimulus! ───────────────────────────────────────────────────────

  def test_apply_stimulus_adds_controller
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    opts = {}
    builder.send(:apply_stimulus!, opts, controller: "auto-resize")

    assert_equal "auto-resize", opts[:data][:controller]
  end

  def test_apply_stimulus_space_joins_multiple_controllers
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    opts = { data: { controller: "existing" } }
    builder.send(:apply_stimulus!, opts, controller: "new-one")

    assert_equal "existing new-one", opts[:data][:controller]
  end

  def test_apply_stimulus_adds_values
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    opts = {}
    builder.send(:apply_stimulus!, opts, controller: "char-count", values: { max: 100 })

    assert_equal 100, opts[:data][:"char-count-max-value"]
  end

  # ── build_field / error? ──────────────────────────────────────────────────

  def test_build_field_has_no_error_without_errors
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    field   = builder.send(:build_field, :email, {})

    refute_predicate field, :error?
  end

  def test_build_field_has_error_when_model_has_errors
    @form.errors.add(:email, "is invalid")
    builder = StimulusPlumbers::Form::Builder.new("sign_in_form", @form, view, {})
    field   = builder.send(:build_field, :email, {})

    assert_predicate field, :error?
  end
end
