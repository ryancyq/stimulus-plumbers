# frozen_string_literal: true

require "test_helper"

class IconComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Icon.new(self)
  end

  def render_icon(name:, **kwargs)
    renderer.render(name: name, **kwargs)
  end

  def icon_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def icons
        { "check" => { elements: [{ tag: :path, d: "M1 2" }] } }
      end

      private

      def icon_classes(**)
        { classes: "size-6" }
      end
    end.new
  end

  def test_renders_svg_for_known_icon
    StimulusPlumbers.config.theme.stub(:current, icon_theme) do
      assert_includes render_icon(name: "check"), "<svg"
    end
  end

  def test_svg_contains_path_element
    StimulusPlumbers.config.theme.stub(:current, icon_theme) do
      assert_includes render_icon(name: "check"), "<path"
    end
  end

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
