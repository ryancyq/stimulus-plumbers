# frozen_string_literal: true

require "test_helper"

class AvatarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::AvatarHelper

  def test_renders_span_with_role_img
    assert_css parse_html(sp_avatar), "span[role='img']"
  end

  def test_renders_aria_label_when_name_given
    assert_css parse_html(sp_avatar(name: "Jane")), "[aria-label='Jane']"
  end

  def test_renders_img_when_url_given
    assert_css parse_html(sp_avatar(url: "/photo.jpg")), "img[src='/photo.jpg']"
  end

  def test_renders_initials_svg
    doc = parse_html(sp_avatar(initials: "AB"))

    assert_css doc, "svg"
    assert_includes doc.text, "AB"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_avatar(class: "custom")), ".custom"
  end
end
