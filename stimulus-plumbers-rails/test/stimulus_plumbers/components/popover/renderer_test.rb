# frozen_string_literal: true

require "test_helper"

class PopoverRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Popover.new(self)
  end

  # ── attr_readers ──────────────────────────────────────────────────────────

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  # ── rendering ─────────────────────────────────────────────────────────────

  def test_renders_outer_div
    assert_css parse_html(renderer.render { |_p| nil }), "div"
  end

  def test_renders_activator_content
    assert_includes parse_html(renderer.render { |p| p.activator { "Open" } }).text, "Open"
  end

  def test_renders_content
    assert_includes parse_html(renderer.render { |p| p.content { "Popover body" } }).text, "Popover body"
  end

  def test_wraps_content_in_template_when_interactive
    assert_css parse_html(renderer.render(interactive: true) { |p| p.content { "Hidden" } }), "template"
  end

  def test_does_not_wrap_content_in_template_when_not_interactive
    doc = parse_html(renderer.render(interactive: false) { |p| p.content { "Visible" } })

    assert_includes doc.text, "Visible"
    assert_no_css   doc, "template"
  end

  def test_activator_appears_before_content
    html = renderer.render do |p|
      p.activator { "trigger" }
      p.content   { "body" }
    end

    assert_operator html.index("trigger"), :<, html.index("body")
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_merges_custom_class
    assert_css parse_html(renderer.render(class: "dropdown") { |_p| nil }), ".dropdown"
  end

  def test_passes_html_options
    doc = parse_html(renderer.render(id: "my-popover", data: { controller: "popover" }) { |_p| nil })

    assert_css doc, "#my-popover"
    assert_css doc, "[data-controller='popover']"
  end
end
