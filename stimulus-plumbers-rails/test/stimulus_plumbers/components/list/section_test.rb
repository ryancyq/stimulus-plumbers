# frozen_string_literal: true

require "test_helper"

class ListSectionTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::List::Section.new(self)
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

  def test_renders_description_when_given
    doc = parse_html(renderer.render(description: "Main navigation") { "" })

    assert_includes doc.text, "Main navigation"
  end

  def test_inner_ul_has_aria_label_when_title_given
    assert_css parse_html(renderer.render(title: "Settings") { "" }), "ul[aria-label='Settings']"
  end

  def test_inner_ul_has_no_aria_label_when_no_title
    assert_no_css parse_html(renderer.render { "" }), "ul[aria-label]"
  end

  def test_renders_title_and_description_together
    doc = parse_html(renderer.render(title: "Nav", description: "Main navigation") { "" })

    assert_includes doc.text, "Nav"
    assert_includes doc.text, "Main navigation"
  end

  def test_renders_block_content_inside_ul
    doc = parse_html(renderer.render { "<li>item</li>".html_safe })

    assert_css doc, "ul > li"
  end

  def test_passes_html_options_to_li
    assert_css parse_html(renderer.render(class: "custom") { "" }), "li.custom"
  end

  def test_renders_semantic_heading_when_heading_level_set
    r = StimulusPlumbers::Components::List::Section.new(self, heading_level: 3)
    doc = parse_html(r.render(title: "Navigation") { "" })

    assert_css    doc, "h3"
    assert_no_css doc, "span[aria-hidden]"
    assert_includes doc.text, "Navigation"
  end

  def test_semantic_heading_has_no_aria_hidden
    r = StimulusPlumbers::Components::List::Section.new(self, heading_level: 2)
    doc = parse_html(r.render(title: "Section") { "" })

    assert_no_css doc, "h2[aria-hidden]"
    assert_no_css doc, "[aria-hidden='true']"
  end

  def test_heading_clamped_at_h6
    r = StimulusPlumbers::Components::List::Section.new(self, heading_level: 6)
    doc = parse_html(r.render(title: "Section") { "" })

    assert_css doc, "h6"
  end

  def test_deeply_nested_heading_clamped_at_h6
    r = StimulusPlumbers::Components::List::Section.new(self, heading_level: 5)
    doc = parse_html(r.render(title: "Parent") { |s| s.section(title: "Child") { "" } })

    assert_css doc, "h5"
    assert_css doc, "h6"
  end

  def test_section_yields_self_to_block
    yielded = nil
    renderer.render do |s|
      yielded = s
      ""
    end

    assert_instance_of StimulusPlumbers::Components::List::Section, yielded
  end

  def test_section_item_renders_inside_ul
    doc = parse_html(renderer.render { |s| s.item("Leaf") })

    assert_css doc, "ul > li"
    assert_includes doc.text, "Leaf"
  end

  def test_nested_section_renders_inside_ul
    doc = parse_html(renderer.render(title: "Parent") { |s| s.section(title: "Child") { "" } })

    assert_css doc, "li > ul > li > ul"
    assert_includes doc.text, "Child"
  end

  def test_nested_section_increments_heading_level
    r = StimulusPlumbers::Components::List::Section.new(self, heading_level: 2)
    doc = parse_html(r.render(title: "Parent") { |s| s.section(title: "Child") { "" } })

    assert_css    doc, "h2"
    assert_css    doc, "h3"
    assert_no_css doc, "h4"
  end
end
