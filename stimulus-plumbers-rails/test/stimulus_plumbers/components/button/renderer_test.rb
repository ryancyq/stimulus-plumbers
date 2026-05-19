# frozen_string_literal: true

require "test_helper"

class ButtonRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Button.new(self)
  end

  # ── attr_readers ──────────────────────────────────────────────────────────

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  # ── button ────────────────────────────────────────────────────────────────

  def test_button_renders_button_element
    doc = parse_html(renderer.render("Click me"))

    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_button_renders_type_button
    assert_css parse_html(renderer.render("Click me")), "button[type='button']"
  end

  def test_button_renders_link_when_url_given
    assert_css parse_html(renderer.render("Go", url: "/dashboard")), "a[href='/dashboard']"
  end

  def test_button_renders_external_link_with_target_blank
    assert_css parse_html(renderer.render("External", url: "https://example.com", external: true)),
               "a[target='_blank']"
  end

  def test_button_does_not_add_target_blank_for_internal_links
    assert_no_css parse_html(renderer.render("Internal", url: "/path")), "a[target]"
  end

  def test_button_accepts_block_content
    assert_includes parse_html(renderer.render { "Block content" }).text, "Block content"
  end

  def test_button_merges_custom_class
    assert_css parse_html(renderer.render("Click", class: "my-class")), ".my-class"
  end

  def test_button_passes_html_options
    assert_css parse_html(renderer.render("Click", id: "my-btn")), "#my-btn"
  end

  # ── group ─────────────────────────────────────────────────────────────────

  def test_group_renders_div
    doc = parse_html(renderer.group { renderer.render("One") })

    assert_css doc, "div"
    assert_includes doc.text, "One"
  end

  def test_group_merges_custom_class
    assert_css parse_html(renderer.group(class: "custom") { "" }), ".custom"
  end
end
