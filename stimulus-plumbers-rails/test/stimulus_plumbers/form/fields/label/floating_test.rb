# frozen_string_literal: true

require "test_helper"

class FormFieldsLabelFloatingTest < ActionView::TestCase
  DEFAULT_INPUT = -> { "<input type='text'>".html_safe }

  def floating_label(**kwargs, &block)
    block ||= DEFAULT_INPUT
    StimulusPlumbers::Form::Fields::Label::Floating.new(self).render(**kwargs, &block)
  end

  INPUT_ID = "user_email"
  LABEL_ID = "user_email_label"
  FLOATING = :filled

  DEFAULT_ARGS = { text: "Email", for_id: INPUT_ID, id: LABEL_ID, floating: FLOATING, required: false, error: false }.freeze

  def test_renders_wrapper_div
    assert_css parse_html(floating_label(**DEFAULT_ARGS)), "div"
  end

  def test_input_rendered_before_label
    doc      = parse_html(floating_label(**DEFAULT_ARGS))
    children = doc.at_css("div").children.reject { |n| n.text? && n.text.strip.empty? }

    assert_equal "input", children[0].name
    assert_equal "label", children[1].name
  end

  def test_label_has_for_attribute
    assert_css parse_html(floating_label(**DEFAULT_ARGS)), "label[for='#{INPUT_ID}']"
  end

  def test_label_has_id_attribute
    assert_css parse_html(floating_label(**DEFAULT_ARGS)), "label[id='#{LABEL_ID}']"
  end

  def test_renders_label_text
    assert_includes floating_label(**DEFAULT_ARGS), "Email"
  end

  def test_omits_required_mark_by_default
    refute_includes floating_label(**DEFAULT_ARGS), "*"
  end

  def test_renders_required_mark_when_required
    doc = parse_html(
      floating_label(
        text:     "Email",
        for_id:   INPUT_ID,
        id:       LABEL_ID,
        floating: FLOATING,
        required: true,
        error:    false
      )
    )

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.text, "*"
  end

  def test_block_content_is_captured
    html = floating_label(text: "Email", for_id: INPUT_ID, id: LABEL_ID, floating: FLOATING, required: false, error: false) do
      "<input type='email' id='#{INPUT_ID}'>".html_safe
    end

    assert_css parse_html(html), "input[type='email'][id='#{INPUT_ID}']"
  end
end
