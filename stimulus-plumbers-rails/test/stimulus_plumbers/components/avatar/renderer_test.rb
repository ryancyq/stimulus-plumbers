# frozen_string_literal: true

require "test_helper"

class AvatarRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Avatar.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # rendering
  def test_renders_span_with_role_img
    html = renderer.render

    assert_includes html, "<span"
    assert_includes html, 'role="img"'
  end

  def test_renders_aria_label_when_name_given
    html = renderer.render(name: "John Doe")

    assert_includes html, 'aria-label="John Doe"'
  end

  def test_omits_aria_label_when_no_name
    html = renderer.render(initials: "JD")

    refute_includes html, "aria-label"
  end

  def test_renders_img_tag_when_url_given
    html = renderer.render(name: "John", url: "/avatar.jpg")

    assert_includes html, "<img"
    assert_includes html, "/avatar.jpg"
  end

  def test_img_alt_uses_name
    html = renderer.render(name: "John", url: "/avatar.jpg")

    assert_includes html, "John&#39;s avatar"
  end

  def test_renders_initials_svg_when_initials_given
    html = renderer.render(initials: "JD")

    assert_includes html, "<svg"
    assert_includes html, "JD"
  end

  def test_upcases_initials
    html = renderer.render(initials: "jd")

    assert_includes html, "JD"
  end

  def test_renders_fallback_svg_when_no_content
    html = renderer.render

    assert_includes html, "<svg"
    assert_includes html, "<path"
  end

  def test_renders_custom_block_content
    html = renderer.render { "custom" }

    assert_includes html, "custom"
  end

  def test_merges_custom_class
    html = renderer.render(class: "my-class")

    assert_includes html, "my-class"
  end

  def test_passes_html_options
    html = renderer.render(id: "my-avatar")

    assert_includes html, 'id="my-avatar"'
  end

  # color logic — stub theme with a known color range, independent of any concrete theme

  def stub_theme_with_colors(colors)
    Class.new(StimulusPlumbers::Themes::Base) do
      define_method(:avatar_color_range) { colors.values }
      define_method(:avatar_colors) { colors }
    end.new
  end

  def with_stub_theme(theme)
    original = StimulusPlumbers.config.theme
    StimulusPlumbers.config.theme = theme
    yield
  ensure
    StimulusPlumbers.config.theme = original
  end

  def test_derives_color_from_name
    stub = stub_theme_with_colors(red: "text-red", blue: "text-blue")
    with_stub_theme(stub) do
      html = renderer.render(name: "Test User")

      assert(stub.avatar_color_range.any? { |c| html.include?(c) })
    end
  end

  def test_applies_explicit_color
    stub = stub_theme_with_colors(red: "text-red", blue: "text-blue")
    with_stub_theme(stub) do
      html = renderer.render(color: :red)

      assert_includes html, "text-red"
    end
  end

  def test_does_not_apply_color_when_url_given
    theme  = StimulusPlumbers.config.theme
    html   = renderer.render(name: "John", url: "/avatar.jpg")
    colors = theme.avatar_color_range

    assert(colors.none? { |c| html.include?(c) })
  end

  def test_does_not_apply_color_when_block_given
    theme  = StimulusPlumbers.config.theme
    html   = renderer.render(name: "John") { "custom" }
    colors = theme.avatar_color_range

    assert(colors.none? { |c| html.include?(c) })
  end
end
