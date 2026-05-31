# frozen_string_literal: true

require "test_helper"
require_relative "form_builder_model"

class BuilderTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

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

  def test_email_field_renders_input
    doc = build_field(:email_field, :email)

    assert_css doc, "input[type='email'][name='sign_in_form[email]']"
    assert_no_css doc, "label"
  end

  def test_hidden_field_renders_without_field_wrapper
    doc = build_field(:hidden_field, :email)

    assert_css doc, "input[type='hidden']"
    assert_no_css doc, "label"
  end

  def test_field_text_renders_label_and_input
    doc = build_field(:field, :email, as: :text)

    assert_css doc, "label[for='sign_in_form_email']"
    assert_css doc, "input[type='text'][name='sign_in_form[email]']"
  end

  def test_field_email_renders_email_input
    doc = build_field(:field, :email, as: :email)

    assert_css doc, "input[type='email'][name='sign_in_form[email]']"
  end

  def test_field_text_area_renders_textarea
    doc = build_field(:field, :email, as: :text_area)

    assert_css doc, "textarea[name='sign_in_form[email]']"
  end

  def test_field_raises_for_unknown_type
    assert_raises ArgumentError do
      build_field(:field, :email, as: :unknown_type)
    end
  end

  def test_field_renders_hint
    doc = build_field(:field, :email, as: :text, hint: "Enter your email")

    assert_includes doc.text, "Enter your email"
  end

  def test_field_text_renders_error_override
    doc = build_field(:field, :email, as: :text, error: "Something went wrong")

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "Something went wrong"
  end

  def test_field_text_hide_label_keeps_label_in_dom
    doc = build_field(:field, :email, as: :text, hide_label: true)

    assert_css doc, "label[for='sign_in_form_email']"
  end

  def test_single_check_box_renders_explicit_label_and_input
    doc = build_field(:choice, :newsletter, as: :check_box)

    assert_css doc, "label[for='sign_in_form_newsletter']"
    assert_css doc, "input[type='checkbox'][name='sign_in_form[newsletter]']"
    assert_no_css doc, "label input[type='checkbox']"
  end

  def test_single_check_box_renders_hint
    doc = build_field(:choice, :newsletter, as: :check_box, hint: "Optional")

    assert_includes doc.text, "Optional"
  end

  def test_single_check_box_renders_error_override
    doc = build_field(:choice, :newsletter, as: :check_box, error: "Must be accepted")

    assert_css doc, "p[role='alert']"
    assert_includes doc.text, "Must be accepted"
  end

  def test_collection_field_raises_for_unknown_type
    assert_raises ArgumentError do
      build_field(:collection_field, :role, as: :unknown_type, collection: [], value_method: :id, text_method: :name)
    end
  end

  def test_collection_field_raises_for_choice_type
    assert_raises ArgumentError do
      build_field(:collection_field, :role, as: :radio, collection: [], value_method: :first, text_method: :last)
    end
  end

  def test_choice_radio_renders_fieldset_with_options
    collection = [%w[admin Admin], %w[user User]]
    doc = build_field(
      :choice,
      :role,
      as:           :radio,
      label:        "Role",
      collection:   collection,
      value_method: :first,
      text_method:  :last
    )

    assert_css doc, "fieldset"
    assert_css doc, "legend"
    assert_css doc, "input[type='radio'][value='admin']"
    assert_css doc, "input[type='radio'][value='user']"
  end

  def test_choice_check_box_renders_fieldset_with_options
    collection = [%w[ruby Ruby], %w[rails Rails]]
    doc = build_field(
      :choice,
      :interests,
      as:           :check_box,
      label:        "Interests",
      collection:   collection,
      value_method: :first,
      text_method:  :last
    )

    assert_css doc, "fieldset"
    assert_css doc, "input[type='checkbox'][value='ruby']"
    assert_css doc, "input[type='checkbox'][value='rails']"
  end

  def test_choice_raises_for_unknown_type
    assert_raises ArgumentError do
      build_field(:choice, :role, as: :unknown_type, collection: [], value_method: :id, text_method: :name)
    end
  end

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

  def test_fields_for_nested_text_field_renders_input
    doc = build_form do |f|
      f.fields_for(:address, NestedAddress.new) { |af| af.text_field(:street) }
    end

    assert_css doc, "input[type='text']"
    assert_no_css doc, "label"
  end
end
