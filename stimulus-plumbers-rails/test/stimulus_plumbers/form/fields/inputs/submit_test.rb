# frozen_string_literal: true

require "test_helper"
require_relative "../../form_builder_model"

class SubmitTest < ActionView::TestCase
  def setup
    @form = FormBuilderModel.new
  end

  def build_form(&block)
    html = view.form_with(model: @form, builder: StimulusPlumbers::Form::Builder, url: "/session", &block)
    parse_html(html)
  end

  def test_submit_renders_button_element_with_given_value
    doc = build_form { |f| f.submit "Save" }

    assert_css doc, "button[type='submit']"
    assert_css doc, "button[type='submit'] > span"
    assert_includes doc.at_css("button[type='submit'] > span").text, "Save"
  end

  def test_submit_uses_default_value_when_omitted
    doc = build_form(&:submit)

    span = doc.at_css("button[type='submit'] > span")

    assert_not_nil span
    refute_empty span.text.strip
  end

  def test_submit_with_default_type_does_not_raise
    doc = build_form { |f| f.submit "Save", type: :default }

    assert_css doc, "button[type='submit']"
  end

  def test_submit_style_type_does_not_override_html_type_attribute
    doc = build_form { |f| f.submit "Save", type: :outline }

    assert_equal "submit", doc.at_css("button[type='submit']")["type"]
  end

  def test_submit_forwards_extra_html_options
    doc = build_form { |f| f.submit "Save", class: "btn" }

    assert_includes doc.at_css("button[type='submit']")["class"].to_s, "btn"
  end

  def test_submit_renders_no_label
    doc = build_form { |f| f.submit "Save" }

    assert_no_css doc, "label"
  end

  def test_submit_renders_no_wrapper_div
    doc = build_form { |f| f.submit "Save" }

    assert_no_css doc, "div"
  end

  def test_submit_accepts_hash_as_first_arg
    doc = build_form { |f| f.submit class: "btn" }

    button = doc.at_css("button[type='submit']")
    span   = doc.at_css("button[type='submit'] > span")

    assert_not_nil button
    assert_includes button["class"].to_s, "btn"
    assert_not_nil span
    refute_empty span.text.strip
  end
end
