# frozen_string_literal: true

require "test_helper"
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
    parse_html(html)
  end

  def build_form(&block)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session", &block)
    parse_html(html)
  end

  # ── builder integration ───────────────────────────────────────────────────

  def test_email_field_renders_label_and_input
    doc = build_field(:email_field, :email)

    assert_css doc, "label[for='sign_in_form_email']"
    assert_css doc, "input[type='email'][name='sign_in_form[email]']"
  end

  def test_field_renders_error_override
    doc = build_field(:email_field, :email, error: "Something went wrong")

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "Something went wrong"
  end

  def test_hidden_field_renders_without_field_wrapper
    doc = build_field(:hidden_field, :email)

    assert_css doc, "input[type='hidden']"
    assert_no_css doc, "label"
  end

  def test_hide_label_keeps_label_in_dom
    doc = build_field(:email_field, :email, hide_label: true)

    assert_css doc, "label[for='sign_in_form_email']"
  end

  # ── fields_for ────────────────────────────────────────────────────────────

  NestedAddress = Struct.new(:street) do
    def errors
      ActiveModel::Errors.new(self)
    end

    def self_and_descendants_from_active_record
      [self]
    end

    def self.human_attribute_name(attr, _opts = {})
      attr.to_s.humanize
    end
  end

  def test_fields_for_uses_sp_builder
    builder_class = nil
    build_form do |f|
      f.fields_for(:address, NestedAddress.new) { |af| builder_class = af.class }
      ""
    end

    assert_equal StimulusPlumbers::Form::Builder, builder_class
  end

  def test_fields_for_nested_text_field_renders_label
    doc = build_form do |f|
      f.fields_for(:address, NestedAddress.new) { |af| af.text_field(:street) }
    end

    assert_css doc, "label"
    assert_css doc, "input[type='text']"
  end
end
