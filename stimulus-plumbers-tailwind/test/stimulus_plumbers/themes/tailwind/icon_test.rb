# frozen_string_literal: true

require "test_helper"

class TailwindThemeIconTest < ActionView::TestCase
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
    StimulusPlumbers.config.theme.use(:tailwind)
  end

  def teardown
    StimulusPlumbers.config.theme.use(StimulusPlumbers::Themes::Base.new)
  end

  def renderer
    StimulusPlumbers::Components::Icon.new(self)
  end

  def render_icon(name:, **kwargs)
    renderer.render(name: name, **kwargs)
  end

  # ── theme icon definitions ────────────────────────────────────────────────

  def test_theme_provides_arrow_left_icon
    assert @theme.icons.key?("arrow-left")
  end

  def test_theme_provides_arrow_right_icon
    assert @theme.icons.key?("arrow-right")
  end

  def test_icon_range_matches_icons_keys
    assert_equal @theme.icons.keys, @theme.icon_range
  end

  # ── svg rendering ─────────────────────────────────────────────────────────

  def test_renders_svg_for_known_icon
    assert_includes render_icon(name: "arrow-left"), "<svg"
  end

  def test_renders_path_with_d_attribute
    assert_css parse_html(render_icon(name: "arrow-left")), "svg path[d]"
  end

  def test_svg_has_viewbox_attribute
    assert_includes render_icon(name: "arrow-left"), 'viewBox="0 0 24 24"'
  end

  def test_svg_has_stroke_width_attribute
    assert_css parse_html(render_icon(name: "arrow-left")), "svg[stroke-width='1.5']"
  end

  def test_svg_path_has_stroke_linecap
    assert_css parse_html(render_icon(name: "arrow-left")), "path[stroke-linecap='round']"
  end

  def test_svg_path_has_stroke_linejoin
    assert_css parse_html(render_icon(name: "arrow-left")), "path[stroke-linejoin='round']"
  end

  def test_svg_has_fill_none
    assert_css parse_html(render_icon(name: "arrow-left")), "svg[fill='none']"
  end

  def test_svg_has_stroke_current_color
    assert_css parse_html(render_icon(name: "arrow-left")), "svg[stroke='currentColor']"
  end

  def test_merges_custom_class
    assert_includes render_icon(name: "arrow-left", class: "my-icon"), "my-icon"
  end

  def test_passes_html_options
    assert_includes render_icon(name: "arrow-left", "aria-hidden": "true"), 'aria-hidden="true"'
  end
end
