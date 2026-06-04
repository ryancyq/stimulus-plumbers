# frozen_string_literal: true

require "test_helper"

class LinkComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Link.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_renders_anchor_element
    assert_css parse_html(renderer.render("Visit", url: "/about")), "a"
  end

  def test_renders_with_href
    assert_css parse_html(renderer.render("Visit", url: "/about")), "a[href='/about']"
  end

  def test_renders_content
    assert_includes parse_html(renderer.render("Visit", url: "/about")).text, "Visit"
  end

  def test_renders_link_with_target_blank
    assert_css parse_html(renderer.render("Out", url: "https://example.com", target: "_blank")),
               "a[target='_blank']"
  end

  def test_omits_target_when_not_given
    assert_no_css parse_html(renderer.render("In", url: "/path")), "a[target]"
  end

  def test_accepts_explicit_target
    assert_css parse_html(renderer.render("Out", url: "/path", target: "_top")),
               "a[target='_top']"
  end

  def test_accepts_block_content
    assert_includes parse_html(renderer.render(url: "/") { "Block" }).text, "Block"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render("Link", url: "/", class: "my-link")), ".my-link"
  end

  def test_passes_html_options
    assert_css parse_html(renderer.render("Link", url: "/", id: "nav-link")), "#nav-link"
  end

  def test_icon_leading_renders_before_content
    with_icon_theme do
      doc = parse_html(renderer.render("Read more", url: "/", icon_leading: :arrow))

      assert_operator doc.to_html.index("<svg"), :<, doc.to_html.index("Read more")
    end
  end

  def test_icon_trailing_renders_after_content
    with_icon_theme do
      doc = parse_html(renderer.render("Read more", url: "/", icon_trailing: :arrow))

      assert_operator doc.to_html.index("Read more"), :<, doc.to_html.index("<svg")
    end
  end

  def test_icon_leading_as_callable
    doc = parse_html(renderer.render("Link", url: "/", icon_leading: -> { "<span>←</span>".html_safe }))

    assert_includes doc.to_html, "←"
  end

  def test_icon_trailing_as_callable
    doc = parse_html(renderer.render("Read their stories", url: "/", icon_trailing: -> { "<span>→</span>".html_safe }))

    assert_includes doc.to_html, "→"
  end

  def test_no_icon_renders_content_only
    doc = parse_html(renderer.render("Plain", url: "/"))

    assert_no_css doc, "svg[aria-hidden='true']"
    assert_css doc, "a"
  end
end
