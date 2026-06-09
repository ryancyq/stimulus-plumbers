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
    with_icon_theme do
      doc = parse_html(renderer.render("Save", icon_leading: :check))

      assert_operator doc.to_html.index("<svg"), :<, doc.to_html.index("Save")
    end
  end

  def test_icon_trailing_renders_after_content
    with_icon_theme do
      doc = parse_html(renderer.render("Next", icon_trailing: :arrow))

      assert_operator doc.to_html.index("Next"), :<, doc.to_html.index("<svg")
    end
  end

  def test_icon_only_button_has_no_text_content
    with_icon_theme do
      doc = parse_html(renderer.render(icon_leading: :x))

      assert_css doc, "svg[aria-hidden='true']"
      assert_equal "", doc.at_css("button").text.strip
    end
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
    with_icon_theme do
      doc = parse_html(renderer.render("Plain"))

      assert_no_css doc, "svg[aria-hidden='true']"
      assert_css doc, "button"
    end
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
end
