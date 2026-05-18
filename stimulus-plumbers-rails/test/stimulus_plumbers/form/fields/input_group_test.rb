# frozen_string_literal: true

require "test_helper"

class FormFieldsInputGroupTest < ActionView::TestCase
  def input_group(input_tag, **opts)
    StimulusPlumbers::Form::Fields::InputGroup.new(self).render(input_tag, **opts)
  end

  def test_renders_div_wrapper
    html = input_group("<input>".html_safe, trailing: "".html_safe)

    assert_includes html, "<div"
  end

  def test_renders_input_inside_wrapper
    doc = parse_html(input_group("<input type='text'>".html_safe, trailing: "".html_safe))

    assert_css doc, "div input[type='text']"
  end

  def test_renders_trailing_inside_wrapper
    doc = parse_html(input_group("<input>".html_safe, trailing: "<button>X</button>".html_safe))

    assert_css doc, "div button"
  end

  def test_passes_extra_html_attributes_to_wrapper
    doc = parse_html(input_group("<input>".html_safe, trailing: "".html_safe, "data-controller": "foo"))

    assert_css doc, "div[data-controller='foo']"
  end
end
