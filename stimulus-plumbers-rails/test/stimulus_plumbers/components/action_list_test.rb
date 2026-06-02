# frozen_string_literal: true

require "test_helper"

class ActionListComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ActionList.new(self)
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

  def test_section_renders_li_with_ul
    doc = parse_html(renderer.section { "" })

    assert_css doc, "li"
    assert_css doc, "ul"
  end

  def test_section_renders_title_in_span
    doc = parse_html(renderer.section(title: "Navigation") { "" })

    assert_css doc, "span"
    assert_includes doc.text, "Navigation"
  end

  def test_section_omits_title_span_when_no_title
    assert_no_css parse_html(renderer.section { "" }), "span[aria-hidden]"
  end

  def test_section_renders_block_inside_ul
    doc = parse_html(renderer.section { renderer.item("Action") })

    assert_css doc, "ul"
    assert_includes doc.text, "Action"
  end

  def test_section_does_not_set_role_none_on_li
    assert_no_css parse_html(renderer.section { "" }), "li[role='none']"
  end

  def test_section_inner_ul_has_aria_label_when_title_given
    assert_css parse_html(renderer.section(title: "Navigation") { "" }), "ul[aria-label='Navigation']"
  end

  def test_section_inner_ul_has_no_role_group
    assert_no_css parse_html(renderer.section { "" }), "[role='group']"
  end

  def test_item_renders_li_with_button
    doc = parse_html(renderer.item("Click me"))

    assert_css doc, "li"
    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_item_renders_button_type
    assert_css parse_html(renderer.item("Click me")), "button[type='button']"
  end

  def test_item_renders_link_when_url_given
    assert_css parse_html(renderer.item("Home", url: "/")), "a[href='/']"
  end

  def test_item_renders_link_with_target_blank
    assert_css parse_html(renderer.item("External", url: "https://example.com", target: "_blank")),
               "a[target='_blank']"
  end

  def test_item_does_not_add_target_blank_for_internal_links
    assert_no_css parse_html(renderer.item("Internal", url: "/path")), "a[target]"
  end

  def test_item_accepts_block_content
    assert_includes parse_html(renderer.item { "Block content" }).text, "Block content"
  end

  def test_item_merges_custom_class
    assert_css parse_html(renderer.item("Action", class: "custom")), ".custom"
  end
end
