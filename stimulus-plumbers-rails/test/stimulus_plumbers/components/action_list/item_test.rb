# frozen_string_literal: true

require "test_helper"

class ActionListItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ActionList::Item.new(self)
  end

  def test_renders_li_wrapping_button_by_default
    doc = parse_html(renderer.render("Click me"))

    assert_css doc, "li"
    assert_css doc, "li > button"
    assert_includes doc.text, "Click me"
  end

  def test_button_has_type_button
    assert_css parse_html(renderer.render("Click me")), "button[type='button']"
  end

  def test_renders_link_when_url_given
    assert_css parse_html(renderer.render("Home", url: "/")), "li > a[href='/']"
  end

  def test_external_link_has_target_blank
    doc = parse_html(renderer.render("External", url: "https://example.com", external: true))

    assert_css doc, "a[target='_blank']"
  end

  def test_internal_link_omits_target_blank
    assert_no_css parse_html(renderer.render("Internal", url: "/path")), "a[target]"
  end

  def test_accepts_block_content
    assert_includes parse_html(renderer.render { "Block content" }).text, "Block content"
  end

  def test_merges_custom_class_onto_inner_element
    assert_css parse_html(renderer.render("Action", class: "active")), ".active"
  end

  def test_passes_html_options_to_inner_element
    assert_css parse_html(renderer.render("Action", id: "my-item")), "#my-item"
  end
end
