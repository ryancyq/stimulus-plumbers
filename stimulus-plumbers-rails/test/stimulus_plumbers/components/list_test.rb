# frozen_string_literal: true

require "test_helper"

class ListComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::List.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  def test_list_renders_ul
    assert_css parse_html(renderer.render { "" }), "ul"
  end

  def test_list_has_role_list_by_default
    assert_css parse_html(renderer.render { "" }), "ul[role='list']"
  end

  def test_list_role_can_be_overridden
    doc = parse_html(renderer.render(role: "menu") { "" })

    assert_css    doc, "ul[role='menu']"
    assert_no_css doc, "ul[role='list']"
  end

  def test_list_merges_custom_class
    assert_css parse_html(renderer.render(class: "custom") { "" }), ".custom"
  end

  def test_list_passes_html_options
    doc = parse_html(renderer.render(id: "nav", data: { controller: "list" }) { "" })

    assert_css doc, "#nav"
    assert_css doc, "[data-controller='list']"
  end

  def test_section_renders_title_as_heading_when_heading_level_set
    doc = parse_html(
      renderer.render(heading_level: 2) do |list|
        list.section(title: "Navigation") { "" }
      end
    )

    assert_css    doc, "h2"
    assert_no_css doc, "span[aria-hidden]"
    assert_includes doc.text, "Navigation"
  end

  def test_sections_without_heading_level_produce_no_headings
    doc = parse_html(
      renderer.render do |list|
        list.section(title: "Navigation") { "" }
      end
    )

    assert_no_css doc, "h2"
    assert_no_css doc, "h3"
  end

  def test_item_convenience_method_delegates_to_list_item
    doc = parse_html(renderer.item("Click me"))

    assert_css doc, "li"
    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_section_yields_self_enabling_scoped_items
    doc = parse_html(
      renderer.render do |list|
        list.section { |s| s.item("Scoped") }
      end
    )

    assert_includes doc.text, "Scoped"
    assert_css doc, "ul > li > ul > li"
  end

  def test_section_yields_self_enabling_nested_sections
    doc = parse_html(
      renderer.render(heading_level: 2) do |list|
        list.section(title: "Parent") do |s|
          s.section(title: "Child") { "" }
        end
      end
    )

    assert_css doc, "h2"
    assert_css doc, "h3"
    assert_includes doc.text, "Parent"
    assert_includes doc.text, "Child"
  end
end
