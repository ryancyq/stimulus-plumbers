# frozen_string_literal: true

require "test_helper"

class AvatarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::AvatarHelper

  def test_renders_span
    html = sp_avatar

    assert_includes html, "<span"
  end

  def test_renders_with_name_aria_label
    html = sp_avatar(name: "Jane")

    assert_includes html, 'aria-label="Jane"'
  end

  def test_renders_img_when_url_given
    html = sp_avatar(url: "/photo.jpg")

    assert_includes html, "<img"
  end

  def test_renders_initials_svg
    html = sp_avatar(initials: "AB")

    assert_includes html, "AB"
  end

  def test_merges_custom_class
    html = sp_avatar(class: "custom")

    assert_includes html, "custom"
  end
end
