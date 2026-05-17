# frozen_string_literal: true

require "test_helper"

class IconComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Icon.new(self)
  end

  def render_icon(name:, **kwargs)
    renderer.render(name: name, **kwargs)
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
