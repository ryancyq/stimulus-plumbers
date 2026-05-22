# frozen_string_literal: true

require "test_helper"

class ActionListSectionTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ActionList::Section.new(self)
  end

  def test_renders_li_wrapping_ul
    doc = parse_html(renderer.render { "" })

    assert_css doc, "li"
    assert_css doc, "li > ul"
  end

  def test_renders_title_span_when_title_given
    doc = parse_html(renderer.render(title: "Navigation") { "" })

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.text, "Navigation"
  end

  def test_omits_title_span_when_no_title
    assert_no_css parse_html(renderer.render { "" }), "span[aria-hidden]"
  end

  def test_inner_ul_has_aria_label_when_title_given
    assert_css parse_html(renderer.render(title: "Settings") { "" }), "ul[aria-label='Settings']"
  end

  def test_inner_ul_has_no_aria_label_when_no_title
    assert_no_css parse_html(renderer.render { "" }), "ul[aria-label]"
  end

  def test_renders_block_content_inside_ul
    doc = parse_html(renderer.render { "<li>item</li>".html_safe })

    assert_css doc, "ul > li"
  end

  def test_passes_html_options_to_li
    assert_css parse_html(renderer.render(class: "custom") { "" }), "li.custom"
  end
end
