# frozen_string_literal: true

require "test_helper"

class CardSectionTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Card::Section.new(self)
  end

  def test_renders_div
    doc = parse_html(renderer.render { "Content" })

    assert_css doc, "div"
    assert_includes doc.text, "Content"
  end

  def test_renders_title_as_h3_by_default
    doc = parse_html(renderer.render(title: "Section One") { "" })

    assert_css doc, "h3"
    assert_includes doc.text, "Section One"
  end

  def test_omits_heading_when_no_title
    assert_no_css parse_html(renderer.render { "" }), "h3"
  end

  def test_custom_title_tag
    doc = parse_html(renderer.render(title: "Section One", title_tag: :h4) { "" })

    assert_css    doc, "h4"
    assert_no_css doc, "h3"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render(class: "bordered") { "" }), ".bordered"
  end

  def test_passes_html_options
    assert_css parse_html(renderer.render(id: "my-section") { "" }), "#my-section"
  end
end
