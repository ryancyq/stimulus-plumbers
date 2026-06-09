# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Avatar.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  def test_renders_span_with_role_img
    assert_css parse_html(renderer.render), "span[role='img']"
  end

  def test_renders_aria_label_when_name_given
    assert_css parse_html(renderer.render(name: "John Doe")), "[aria-label='John Doe']"
  end

  def test_omits_aria_label_when_no_name
    assert_no_css parse_html(renderer.render(initials: "JD")), "[aria-label]"
  end

  def test_renders_img_tag_when_url_given
    assert_css parse_html(renderer.render(name: "John", url: "/avatar.jpg")), "img[src='/avatar.jpg']"
  end

  def test_img_alt_uses_name
    doc = parse_html(renderer.render(name: "John", url: "/avatar.jpg"))

    assert_equal "John's avatar", doc.at_css("img")["alt"]
  end

  def test_renders_initials_svg_when_initials_given
    doc = parse_html(renderer.render(initials: "JD"))

    assert_css doc, "svg"
    assert_includes doc.text, "JD"
  end

  def test_upcases_initials
    assert_includes parse_html(renderer.render(initials: "jd")).text, "JD"
  end

  def test_renders_fallback_svg_when_no_content
    assert_css parse_html(renderer.render), "svg path"
  end

  def test_renders_custom_block_content
    assert_includes parse_html(renderer.render { "custom" }).text, "custom"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render(class: "my-class")), ".my-class"
  end

  def test_passes_html_options
    assert_css parse_html(renderer.render(id: "my-avatar")), "#my-avatar"
  end

  def stub_theme_with_variants(variants)
    Class.new(StimulusPlumbers::Themes::Base) do
      define_method(:avatar_variant_range) { variants.values }
      define_method(:avatar_variants) { variants }
    end.new
  end

  def with_stub_theme(theme)
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(theme)
    yield
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def test_derives_variant_from_name
    stub = stub_theme_with_variants(red: "text-red", blue: "text-blue")
    with_stub_theme(stub) do
      html = renderer.render(name: "Test User")

      assert(stub.avatar_variant_range.any? { |c| html.include?(c) })
    end
  end

  def test_applies_explicit_variant
    stub = stub_theme_with_variants(red: "text-red", blue: "text-blue")
    with_stub_theme(stub) do
      doc = parse_html(renderer.render(variant: :red))

      assert_css doc, ".text-red"
    end
  end

  def test_does_not_apply_variant_when_url_given
    theme  = StimulusPlumbers.config.theme.current
    html   = renderer.render(name: "John", url: "/avatar.jpg")

    assert(theme.avatar_variant_range.none? { |c| html.include?(c) })
  end

  def test_does_not_apply_variant_when_block_given
    theme  = StimulusPlumbers.config.theme.current
    html   = renderer.render(name: "John") { "custom" }

    assert(theme.avatar_variant_range.none? { |c| html.include?(c) })
  end
end
