# frozen_string_literal: true

require "test_helper"

class ButtonTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Button.new(self)
  end

  def test_button_renders_button_element
    doc = parse_html(renderer.render("Click me"))

    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_button_renders_type_button
    assert_css parse_html(renderer.render("Click me")), "button[type='button']"
  end

  def test_button_renders_link_when_url_given
    assert_css parse_html(renderer.render("Go", url: "/dashboard")), "a[href='/dashboard']"
  end

  def test_button_renders_link_with_target_blank
    assert_css parse_html(renderer.render("External", url: "https://example.com", target: "_blank")),
               "a[target='_blank']"
  end

  def test_button_link_target_blank_adds_trailing_icon
    doc = parse_html(renderer.render("External", url: "https://example.com", target: "_blank"))
    a = doc.at_css("a")

    assert_css doc, "a[target='_blank'] span"
    assert_operator a.to_html.index("External"), :<, a.to_html.index("<span")
  end

  def test_button_link_target_blank_does_not_override_explicit_icon_trailing
    doc = parse_html(
      renderer.render(
        "External",
        url:           "https://example.com",
        target:        "_blank",
        icon_trailing: "arrow-right"
      )
    )

    assert_css doc, "a[target='_blank'] span"
    assert_equal 1, doc.css("a span").length
  end

  def test_button_link_internal_does_not_add_trailing_icon
    doc = parse_html(renderer.render("Internal", url: "/path"))

    assert_no_css doc, "a span"
  end

  def test_button_omits_target_when_not_given
    assert_no_css parse_html(renderer.render("Internal", url: "/path")), "a[target]"
  end

  def test_button_accepts_block_content
    assert_includes parse_html(renderer.render { "Block content" }).text, "Block content"
  end

  def test_button_merges_custom_class
    assert_css parse_html(renderer.render("Click", class: "my-class")), ".my-class"
  end

  def test_button_passes_html_options
    assert_css parse_html(renderer.render("Click", id: "my-btn")), "#my-btn"
  end

  def test_icon_leading_renders_before_content
    doc = parse_html(renderer.render("Save", icon_leading: :check))

    assert_operator doc.to_html.index("<span"), :<, doc.to_html.index("Save")
  end

  def test_icon_trailing_renders_after_content
    doc = parse_html(renderer.render("Next", icon_trailing: :arrow))

    assert_operator doc.to_html.index("Next"), :<, doc.to_html.index("<span")
  end

  def test_icon_only_button_has_no_text_content
    doc = parse_html(renderer.render(icon_leading: :x))

    assert_css doc, "span"
    assert_equal "", doc.at_css("button").text.strip
  end

  def test_icon_leading_as_callable
    doc = parse_html(renderer.render("Click", icon_leading: -> { "<span>★</span>".html_safe }))

    assert_includes doc.to_html, "★"
  end

  def test_icon_trailing_as_callable
    doc = parse_html(renderer.render("Click", icon_trailing: -> { "<span>→</span>".html_safe }))

    assert_includes doc.to_html, "→"
  end

  def test_no_icon_renders_content_only
    doc = parse_html(renderer.render("Plain"))

    assert_no_css doc, "span"
    assert_css doc, "button"
  end

  def test_button_renders_with_type_option
    assert_css parse_html(renderer.render("Click", type: :secondary)), "button"
  end

  def test_button_renders_with_variant_option
    assert_css parse_html(renderer.render("Click", variant: :outline)), "button"
  end

  def test_button_renders_with_size_option
    assert_css parse_html(renderer.render("Click", size: :sm)), "button"
  end

  def test_link_renders_with_variant_option
    assert_css parse_html(renderer.render("Go", url: "/path", variant: :outline)), "a[href='/path']"
  end

  def test_link_renders_with_size_option
    assert_css parse_html(renderer.render("Go", url: "/path", size: :lg)), "a[href='/path']"
  end

  def test_group_renders_role_group
    assert_css parse_html(renderer.group { "buttons" }), "div[role='group']"
  end
end
