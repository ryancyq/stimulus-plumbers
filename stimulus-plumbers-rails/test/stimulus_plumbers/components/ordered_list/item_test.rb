# frozen_string_literal: true

require "test_helper"

class OrderedListItemTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::OrderedList::Item.new(self)
  end

  def test_raises_without_id
    assert_raises(ArgumentError) { renderer.render("Row") }
  end

  def test_raises_when_html_options_given_without_url
    assert_raises(ArgumentError) { renderer.render("Row", id: "row-1", class: "custom") }
  end

  def test_renders_li_with_item_target_and_id
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_css doc, "li#row-1[data-reorderable-target~='item']"
  end

  def test_default_handle_is_item_wired_on_li
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_css doc, "li[data-reorderable-target~='handle']"
    assert_css doc, "li[data-action*='reorderable#onPointerDown']"
  end

  def test_handle_leading_wires_leading_span_not_li
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :leading))

    assert_no_css doc, "li[data-reorderable-target~='handle']"
    assert_css    doc, "span[data-reorderable-target='handle']"
  end

  def test_handle_trailing_wires_trailing_span_not_li
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :trailing))

    assert_no_css doc, "li[data-reorderable-target~='handle']"
    assert_css    doc, "span[data-reorderable-target='handle']"
  end

  def test_handle_leading_uses_custom_icon_when_icon_leading_set
    with_icon_theme do
      doc = parse_html(
        renderer.render("Row", id: "row-1", handle: :leading) { |slots| slots.with_icon_leading(:star) }
      )

      assert_css doc, "span[data-reorderable-target='handle'] svg"
    end
  end

  def test_icon_positions_are_siblings_of_link_not_nested_inside
    doc = parse_html(
      renderer.render("Row", id: "row-1", url: "/x", handle: :leading) { |slots| slots.with_icon_leading(:star) }
    )

    assert_css doc, "li > span[data-reorderable-target='handle'] + a"
  end

  def test_trigger_target_present_when_url_given
    doc = parse_html(renderer.render("Row", id: "row-1", url: "/x"))

    assert_css doc, "a[data-reorderable-target='trigger'][href='/x']"
  end

  def test_no_wrapper_or_trigger_target_without_url
    doc = parse_html(renderer.render("Row", id: "row-1"))

    assert_no_css doc, "a"
    assert_no_css doc, "button"
    assert_includes doc.text, "Row"
  end

  def test_title_and_description_render_inside_link
    doc = parse_html(
      renderer.render(id: "row-1", url: "/x") do |slots|
        slots.with_title("Title")
        slots.with_description("Description")
      end
    )

    assert_css doc, "a span"
    assert_includes doc.text, "Title"
    assert_includes doc.text, "Description"
  end

  def test_no_icon_span_rendered_when_position_unused_and_not_handle
    doc = parse_html(renderer.render("Row", id: "row-1", handle: :leading))

    assert_css doc, "li > *:nth-child(1)[data-reorderable-target='handle']"
    # trailing position: no icon_trailing set and it's not the handle — nothing rendered there
    assert_equal 2, parse_html(renderer.render("Row", id: "row-1", handle: :leading)).css("li > *").size
  end
end
