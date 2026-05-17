# frozen_string_literal: true

require "test_helper"

class FormFieldsLabelTest < ActionView::TestCase
  def label(**kwargs)
    StimulusPlumbers::Form::Fields::Label.new(self).render(**kwargs)
  end

  def test_renders_label_element
    assert_css parse_html(label(text: "Email", for_id: "user_email")), "label[for='user_email']"
  end

  def test_renders_text
    assert_includes label(text: "Email", for_id: "user_email"), "Email"
  end

  def test_omits_required_mark_by_default
    refute_includes label(text: "Email", for_id: "user_email"), "*"
  end

  def test_renders_required_mark_when_required
    doc = parse_html(label(text: "Email", for_id: "user_email", required: true))

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.text, "*"
  end
end
