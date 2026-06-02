# frozen_string_literal: true

require "test_helper"

class LinkHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::LinkHelper

  def test_renders_anchor_element
    assert_css parse_html(sp_link("Visit", url: "/about")), "a[href='/about']"
  end

  def test_renders_content
    assert_includes parse_html(sp_link("Visit", url: "/about")).text, "Visit"
  end

  def test_renders_link_with_target_blank
    assert_css parse_html(sp_link("Out", url: "https://example.com", target: "_blank")),
               "a[target='_blank']"
  end

  def test_omits_target_when_not_given
    assert_no_css parse_html(sp_link("In", url: "/path")), "a[target]"
  end

  def test_accepts_block_content
    assert_includes parse_html(sp_link(url: "/") { "Block" }).text, "Block"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_link("Link", url: "/", class: "my-link")), ".my-link"
  end

  def test_passes_html_options
    doc = parse_html(sp_link("Link", url: "/", id: "nav-link", data: { testid: "lnk" }))

    assert_css doc, "#nav-link"
    assert_css doc, "[data-testid='lnk']"
  end

  def test_icon_trailing_renders_after_content
    doc = parse_html(sp_link("Read their stories", url: "/", icon_trailing: :arrow))

    assert_operator doc.to_html.index("Read their stories"), :<, doc.to_html.index("<span")
  end

  def test_icon_leading_renders_before_content
    doc = parse_html(sp_link("Read more", url: "/", icon_leading: :arrow))

    assert_operator doc.to_html.index("<span"), :<, doc.to_html.index("Read more")
  end
end
