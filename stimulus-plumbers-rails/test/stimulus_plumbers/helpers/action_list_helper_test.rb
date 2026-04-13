# frozen_string_literal: true

require "test_helper"

class ActionListHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ActionListHelper

  def test_renders_container_div
    html = sp_action_list { "" }

    assert_includes html, "<div"
  end

  def test_renders_section_with_ul
    html = sp_action_list_section { "" }

    assert_includes html, "<ul"
  end

  def test_renders_section_title
    html = sp_action_list_section(title: "Navigation") { "" }

    assert_includes html, "<p"
    assert_includes html, "Navigation"
  end

  def test_renders_no_title_when_absent
    html = sp_action_list_section { "" }

    refute_includes html, "<p"
  end

  def test_item_renders_button_by_default
    html = sp_action_list_item("Click me")

    assert_includes html, "<li"
    assert_includes html, "<button"
    assert_includes html, "Click me"
  end

  def test_item_renders_link_with_url
    html = sp_action_list_item("Home", url: "/")

    assert_includes html, "<a"
    assert_includes html, 'href="/"'
  end

  def test_item_renders_external_link
    html = sp_action_list_item("External", url: "https://example.com", external: true)

    assert_includes html, 'target="_blank"'
  end

  def test_item_accepts_block_content
    html = sp_action_list_item { "Block item" }

    assert_includes html, "Block item"
  end

  def test_item_merges_custom_class
    html = sp_action_list_item("Action", class: "custom")

    assert_includes html, "custom"
  end

  def test_composition
    html = sp_action_list do
      sp_action_list_section(title: "Nav") do
        sp_action_list_item("Home", url: "/")
      end
    end

    assert_includes html, "Nav"
    assert_includes html, 'href="/"'
    assert_includes html, "<ul"
    assert_includes html, "<li"
  end
end
