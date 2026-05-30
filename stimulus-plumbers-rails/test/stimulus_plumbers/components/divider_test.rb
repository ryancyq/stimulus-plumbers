# frozen_string_literal: true

require "test_helper"

class DividerComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Divider.new(self)
  end

  def test_renders_hr_element
    assert_includes renderer.render, "<hr"
  end

  def test_merges_custom_html_options
    assert_includes renderer.render(class: "my-divider"), "my-divider"
  end

  def test_labeled_renders_div_with_role_separator
    doc = parse_html(renderer.render("or"))

    assert_css doc, "div[role='separator']"
  end

  def test_labeled_renders_two_hr_elements
    doc = parse_html(renderer.render("or"))

    assert_equal 2, doc.css("hr").length
  end

  def test_labeled_renders_span_with_label_text
    doc = parse_html(renderer.render("or"))

    assert_css doc, "span"
    assert_includes doc.at_css("span").text, "or"
  end

  def test_labeled_does_not_render_bare_hr
    doc = parse_html(renderer.render("or"))

    assert_no_css doc, "hr:only-child"
    assert_css doc, "div[role='separator']"
  end

  def test_nil_label_renders_hr_inside_wrapper
    doc = parse_html(renderer.render(nil))

    assert_css doc, "div[role='separator'] hr"
    assert_no_css doc, "span"
  end

  def test_blank_label_renders_hr_inside_wrapper
    doc = parse_html(renderer.render(""))

    assert_css doc, "div[role='separator'] hr"
    assert_no_css doc, "span"
  end
end
