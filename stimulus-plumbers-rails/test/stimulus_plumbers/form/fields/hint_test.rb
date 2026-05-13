# frozen_string_literal: true

require "test_helper"

class FormFieldsHintTest < ActionView::TestCase
  def hint(**kwargs)
    StimulusPlumbers::Form::Fields::Hint.new(self).render(**kwargs)
  end

  def test_renders_paragraph
    assert_includes hint(text: "Helper text", id: "field_hint"), "<p"
  end

  def test_renders_text
    assert_includes hint(text: "Helper text", id: "field_hint"), "Helper text"
  end

  def test_sets_id_attribute
    assert_css parse_html(hint(text: "Helper text", id: "field_hint")), "p#field_hint"
  end
end
