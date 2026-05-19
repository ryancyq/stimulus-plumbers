# frozen_string_literal: true

require "test_helper"

class ActionListRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ActionList.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  # list
  def test_list_renders_ul
    html = renderer.render { "" }

    assert_includes html, "<ul"
  end

  def test_list_has_role_list_by_default
    html = renderer.render { "" }

    assert_includes html, 'role="list"'
  end

  def test_list_role_can_be_overridden
    html = renderer.render(role: "menu") { "" }

    assert_includes html, 'role="menu"'
    refute_includes html, 'role="list"'
  end

  def test_list_merges_custom_class
    html = renderer.render(class: "custom") { "" }

    assert_includes html, "custom"
  end

  def test_list_passes_html_options
    html = renderer.render(id: "nav", data: { controller: "list" }) { "" }

    assert_includes html, 'id="nav"'
    assert_includes html, 'data-controller="list"'
  end

  # section
  def test_section_renders_li_with_ul
    html = renderer.section { "" }

    assert_includes html, "<li"
    assert_includes html, "<ul"
  end

  def test_section_renders_title_in_span
    html = renderer.section(title: "Navigation") { "" }

    assert_includes html, "<span"
    assert_includes html, "Navigation"
  end

  def test_section_omits_title_span_when_no_title
    html = renderer.section { "" }

    refute_includes html, "aria-hidden"
  end

  def test_section_renders_block_inside_ul
    html = renderer.section { renderer.item("Action") }

    assert_includes html, "<ul"
    assert_includes html, "Action"
  end

  def test_section_does_not_set_role_none_on_li
    html = renderer.section { "" }

    refute_includes html, 'role="none"'
  end

  def test_section_inner_ul_has_aria_label_when_title_given
    html = renderer.section(title: "Navigation") { "" }

    assert_includes html, 'aria-label="Navigation"'
  end

  def test_section_inner_ul_has_no_role_group
    html = renderer.section { "" }

    refute_includes html, 'role="group"'
  end

  # item
  def test_item_renders_li_with_button
    html = renderer.item("Click me")

    assert_includes html, "<li"
    assert_includes html, "<button"
    assert_includes html, "Click me"
  end

  def test_item_renders_button_type
    html = renderer.item("Click me")

    assert_includes html, 'type="button"'
  end

  def test_item_renders_link_when_url_given
    html = renderer.item("Home", url: "/")

    assert_includes html, "<a"
    assert_includes html, 'href="/"'
  end

  def test_item_renders_external_link_with_target_blank
    html = renderer.item("External", url: "https://example.com", external: true)

    assert_includes html, 'target="_blank"'
  end

  def test_item_does_not_add_target_blank_for_internal_links
    html = renderer.item("Internal", url: "/path")

    refute_includes html, "target"
  end

  def test_item_accepts_block_content
    html = renderer.item { "Block content" }

    assert_includes html, "Block content"
  end

  def test_item_merges_custom_class
    html = renderer.item("Action", class: "custom")

    assert_includes html, "custom"
  end
end
