# frozen_string_literal: true

require "test_helper"

class FormFieldsInputGroupTest < ActionView::TestCase
  def input_group(...)
    StimulusPlumbers::Form::Fields::InputGroup.new(self).render(...)
  end

  def test_renders_div_wrapper
    html = input_group { "<input>".html_safe }

    assert_includes html, "<div"
  end

  def test_renders_input_inside_wrapper
    doc = parse_html(input_group { "<input type='text'>".html_safe })

    assert_css doc, "div input[type='text']"
  end

  def test_renders_trailing_inside_wrapper
    doc = parse_html(input_group(trailing: "<button>X</button>".html_safe) { "<input>".html_safe })

    assert_css doc, "div button"
  end

  def test_trailing_as_lambda
    doc = parse_html(input_group(trailing: -> { "<button>X</button>".html_safe }) { "<input>".html_safe })

    assert_css doc, "div button"
  end

  def test_renders_leading_inside_wrapper
    doc = parse_html(input_group(leading: "<span>$</span>".html_safe) { "<input>".html_safe })

    assert_css doc, "div span"
  end

  def test_leading_as_lambda
    doc = parse_html(input_group(leading: -> { "<span>$</span>".html_safe }) { "<input>".html_safe })

    assert_css doc, "div span"
  end

  def test_leading_appears_before_input
    doc = parse_html(input_group(leading: "<span>$</span>".html_safe) { "<input>".html_safe })

    children = doc.at_css("div").children.select(&:element?)

    assert_equal "span", children[0].name
    assert_equal "input", children[1].name
  end

  def test_trailing_appears_after_input
    doc = parse_html(input_group(trailing: "<button>X</button>".html_safe) { "<input>".html_safe })

    children = doc.at_css("div").children.select(&:element?)

    assert_equal "input", children[0].name
    assert_equal "button", children[1].name
  end

  def test_leading_and_trailing_together
    doc = parse_html(
      input_group(
        leading:  "<span>$</span>".html_safe,
        trailing: "<button>X</button>".html_safe
      ) { "<input>".html_safe }
    )

    names = doc.at_css("div").children.select(&:element?).map(&:name)

    assert_equal %w[span input button], names
  end

  def test_passes_extra_html_attributes_to_wrapper
    doc = parse_html(input_group("data-controller": "foo") { "<input>".html_safe })

    assert_css doc, "div[data-controller='foo']"
  end
end
