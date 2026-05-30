# frozen_string_literal: true

require "test_helper"

class ActionListHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ActionListHelper

  def test_renders_container_ul
    assert_css parse_html(sp_action_list { "" }), "ul"
  end

  def test_renders_section_with_ul
    assert_css parse_html(sp_action_list_section { "" }), "ul"
  end

  def test_renders_section_title
    doc = parse_html(sp_action_list_section(title: "Navigation") { "" })

    assert_css doc, "span"
    assert_includes doc.text, "Navigation"
  end

  def test_renders_no_title_span_when_absent
    assert_no_css parse_html(sp_action_list_section { "" }), "span[aria-hidden]"
  end

  def test_item_renders_button_by_default
    doc = parse_html(sp_action_list_item("Click me"))

    assert_css doc, "li"
    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_item_renders_link_with_url
    assert_css parse_html(sp_action_list_item("Home", url: "/")), "a[href='/']"
  end

  def test_item_renders_external_link
    assert_css parse_html(sp_action_list_item("External", url: "https://example.com", external: true)),
               "a[target='_blank']"
  end

  def test_item_accepts_block_content
    assert_includes parse_html(sp_action_list_item { "Block item" }).text, "Block item"
  end

  def test_item_merges_custom_class
    assert_css parse_html(sp_action_list_item("Action", class: "custom")), ".custom"
  end

  def test_composition
    doc = parse_html(
      sp_action_list do
        sp_action_list_section(title: "Nav") do
          sp_action_list_item("Home", url: "/")
        end
      end
    )

    assert_css doc, "ul"
    assert_css doc, "li"
    assert_css doc, "a[href='/']"
    assert_includes doc.text, "Nav"
  end
end
