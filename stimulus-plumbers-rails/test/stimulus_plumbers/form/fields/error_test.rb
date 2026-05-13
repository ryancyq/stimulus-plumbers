# frozen_string_literal: true

require "test_helper"

class FormFieldsErrorTest < ActionView::TestCase
  def error(**kwargs)
    StimulusPlumbers::Form::Fields::Error.new(self).render(**kwargs)
  end

  def test_renders_alert_paragraph
    doc = parse_html(error(message: "is invalid", id: "field_error"))

    assert_css doc, "p[role='alert']#field_error"
    assert_includes doc.text, "is invalid"
  end
end
