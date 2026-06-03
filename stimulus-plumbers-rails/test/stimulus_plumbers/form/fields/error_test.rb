# frozen_string_literal: true

require "test_helper"

class FormFieldsErrorTest < ActionView::TestCase
  def error(**kwargs)
    StimulusPlumbers::Form::Fields::Error.new(self).render(**kwargs)
  end

  def test_renders_alert_paragraph
    assert_css parse_html(error(message: "is invalid", id: "field_error")), "p[role='alert']#field_error"
  end

  def test_renders_message_text
    assert_includes parse_html(error(message: "is invalid", id: "field_error")).text, "is invalid"
  end
end
