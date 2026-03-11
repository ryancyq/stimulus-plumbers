# frozen_string_literal: true

require "test_helper"

class PopoverRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Popover::Renderer.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # rendering
  def test_renders_outer_div
    html = renderer.popover { |_p| nil }

    assert_includes html, "<div"
  end

  def test_renders_activator_content
    html = renderer.popover do |p|
      p.activator { "Open" }
    end

    assert_includes html, "Open"
  end

  def test_renders_content
    html = renderer.popover do |p|
      p.content { "Popover body" }
    end

    assert_includes html, "Popover body"
  end

  def test_wraps_content_in_template_when_interactive
    html = renderer.popover(interactive: true) do |p|
      p.content { "Hidden" }
    end

    assert_includes html, "<template"
  end

  def test_does_not_wrap_content_in_template_when_not_interactive
    html = renderer.popover(interactive: false) do |p|
      p.content { "Visible" }
    end

    assert_includes html, "Visible"
    refute_includes html, "<template"
  end

  def test_activator_appears_before_content
    html = renderer.popover do |p|
      p.activator { "trigger" }
      p.content   { "body" }
    end

    assert_operator html.index("trigger"), :<, html.index("body")
  end

  def test_merges_custom_class
    html = renderer.popover(class: "dropdown") { |_p| nil }

    assert_includes html, "dropdown"
  end

  def test_passes_html_options
    html = renderer.popover(id: "my-popover", data: { controller: "popover" }) { |_p| nil }

    assert_includes html, 'id="my-popover"'
    assert_includes html, 'data-controller="popover"'
  end
end
