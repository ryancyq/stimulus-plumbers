# frozen_string_literal: true

require "test_helper"

class IconComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Icon.new(self)
  end

  def render_icon(name:, **kwargs)
    renderer.render(name: name, **kwargs)
  end

  # ── known icon ────────────────────────────────────────────────────────────

  def test_renders_svg_for_known_icon
    assert_includes render_icon(name: "arrow-left"), "<svg"
  end

  def test_renders_path_with_d_attribute
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "svg path[d]"
  end

  def test_svg_has_viewbox_attribute
    assert_includes render_icon(name: "arrow-left"), 'viewBox="0 0 24 24"'
  end

  def test_svg_has_stroke_width_attribute
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "svg[stroke-width='1.5']"
  end

  def test_svg_path_has_stroke_linecap
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "path[stroke-linecap='round']"
  end

  def test_svg_path_has_stroke_linejoin
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "path[stroke-linejoin='round']"
  end

  def test_svg_has_fill_none
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "svg[fill='none']"
  end

  def test_svg_has_stroke_current_color
    html = parse_html(render_icon(name: "arrow-left"))

    assert_css html, "svg[stroke='currentColor']"
  end

  def test_merges_custom_class
    html = render_icon(name: "arrow-left", class: "my-icon")

    assert_includes html, "my-icon"
  end

  def test_passes_html_options
    html = render_icon(name: "arrow-left", "aria-hidden": "true")

    assert_includes html, 'aria-hidden="true"'
  end

  # ── unknown icon ──────────────────────────────────────────────────────────

  def test_renders_span_for_unknown_icon
    html = render_icon(name: "nonexistent")

    assert_includes html, "<span"
    refute_includes html, "<svg"
  end

  def test_span_fallback_applies_html_options
    html = render_icon(name: "nonexistent", class: "placeholder")

    assert_includes html, "placeholder"
  end
end
