# frozen_string_literal: true

require "test_helper"

class ListItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::List::Item.new(self)
  end

  def test_renders_li_with_button
    doc = parse_html(renderer.render("Click me"))

    assert_css doc, "li"
    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_renders_button_type
    assert_css parse_html(renderer.render("Click me")), "button[type='button']"
  end

  def test_renders_link_when_url_given
    assert_css parse_html(renderer.render("Home", url: "/")), "a[href='/']"
  end

  def test_renders_link_with_target_blank
    assert_css parse_html(renderer.render("External", url: "https://example.com", target: "_blank")),
               "a[target='_blank']"
  end

  def test_item_renders_title_from_fast_path
    doc = parse_html(renderer.render("Dashboard"))

    assert_css doc, "li button span"
    assert_includes doc.text, "Dashboard"
  end

  def test_item_block_title_overwrites_fast_path
    doc = parse_html(renderer.render("First") { |item| item.with_title("Second") })

    assert_includes doc.text, "Second"
    refute_includes doc.text, "First"
  end

  def test_item_renders_description
    doc = parse_html(
      renderer.render do |item|
        item.with_title("Title")
        item.with_description("Subtitle")
      end
    )

    assert_includes doc.text, "Subtitle"
  end

  def test_item_omits_text_group_when_no_title_or_description
    doc = parse_html(renderer.render { |item| item.with_icon_leading("home") })

    assert_no_css doc, "span span"
  end

  def test_item_renders_icon_leading
    doc = parse_html(
      renderer.render do |item|
        item.with_title("T")
        item.with_icon_leading("home")
      end
    )

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_item_renders_icon_trailing
    doc = parse_html(
      renderer.render do |item|
        item.with_title("T")
        item.with_icon_trailing("chevron-right")
      end
    )

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_icon_trailing_auto_set_for_external_links
    doc = parse_html(renderer.render("External", url: "https://example.com", target: "_blank"))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_item_merges_custom_class
    assert_css parse_html(renderer.render("Action", class: "custom")), ".custom"
  end
end
