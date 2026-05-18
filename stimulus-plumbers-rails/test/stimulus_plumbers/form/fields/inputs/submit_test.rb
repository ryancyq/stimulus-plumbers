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

  # ── submit ────────────────────────────────────────────────────────────────

  def test_submit_renders_submit_input_with_given_value
    doc = build_form { |f| f.submit "Save" }

    assert_css doc, "input[type='submit'][value='Save']"
  end

  def test_submit_uses_default_value_when_omitted
    doc = build_form(&:submit)

    assert_css doc, "input[type='submit']"
    refute_empty doc.at_css("input[type='submit']")["value"].to_s
  end

  def test_submit_with_default_variant_does_not_raise
    doc = build_form { |f| f.submit "Save", variant: :default }

    assert_css doc, "input[type='submit']"
  end

  def test_submit_variant_is_not_rendered_as_html_attribute
    doc = build_form { |f| f.submit "Save", variant: :default }

    assert_nil doc.at_css("input[type='submit']")["variant"]
  end

  def test_submit_forwards_extra_html_options
    doc = build_form { |f| f.submit "Save", class: "btn" }

    assert_includes doc.at_css("input[type='submit']")["class"].to_s, "btn"
  end

  def test_submit_renders_no_label
    doc = build_form { |f| f.submit "Save" }

    assert_no_css doc, "label"
  end

  def test_submit_renders_no_wrapper_div
    doc = build_form { |f| f.submit "Save" }

    assert_no_css doc, "div"
  end
end
