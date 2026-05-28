# frozen_string_literal: true

require "test_helper"

class PopoverComponentTest < ActionView::TestCase
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

  # ── render: outer wrapper ─────────────────────────────────────────────────

  def test_renders_outer_div
    assert_css parse_html(renderer.render { |_p| nil }), "div"
  end

  def test_wrapper_has_stimulus_controller
    assert_css parse_html(renderer.render { |_p| nil }), "[data-controller~='popover']"
  end

  def test_merges_custom_class
    assert_css parse_html(renderer.render(class: "dropdown") { |_p| nil }), ".dropdown"
  end

  def test_passes_html_options
    doc = parse_html(renderer.render(id: "my-popover") { |_p| nil })

    assert_css doc, "#my-popover"
    assert_css doc, "[data-controller~='popover']"
  end

  # ── render: trigger + panel ───────────────────────────────────────────────

  def test_renders_default_trigger_button
    assert_css parse_html(renderer.render { |p| p.trigger { "Open" } }), "button"
  end

  def test_renders_trigger_content
    assert_includes parse_html(renderer.render { |p| p.trigger { "Open" } }).text, "Open"
  end

  def test_renders_panel_content
    assert_includes parse_html(renderer.render { |p| p.panel { "Popover body" } }).text, "Popover body"
  end

  def test_trigger_appears_before_panel
    html = renderer.render do |p|
      p.trigger { "trigger" }
      p.panel   { "body" }
    end

    assert_operator html.index("trigger"), :<, html.index("body")
  end

  def test_trigger_with_block_yields_attrs
    received = nil
    renderer.render do |p|
      p.trigger do |attrs|
        received = attrs
        "custom"
      end
    end

    assert_not_nil received
    assert_includes received, :panel_id
    assert_includes received[:aria], :haspopup
  end

  # ── build: no wrapper ─────────────────────────────────────────────────────

  def test_build_returns_trigger_and_panel_without_wrapper
    html = renderer.build do |p|
      p.trigger { "Open" }
      p.panel   { "Content" }
    end

    assert_includes html, "Open"
    assert_includes html, "Content"
    refute_includes html, "data-controller=\"popover\""
  end
end
