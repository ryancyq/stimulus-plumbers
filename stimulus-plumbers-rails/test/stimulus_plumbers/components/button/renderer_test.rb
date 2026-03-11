# frozen_string_literal: true

require "test_helper"

class ButtonRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Button::Renderer.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # button
  def test_button_renders_button_element
    html = renderer.button("Click me")

    assert_includes html, "<button"
    assert_includes html, "Click me"
  end

  def test_button_renders_type_button
    html = renderer.button("Click me")

    assert_includes html, 'type="button"'
  end

  def test_button_renders_link_when_url_given
    html = renderer.button("Go", url: "/dashboard")

    assert_includes html, "<a"
    assert_includes html, 'href="/dashboard"'
  end

  def test_button_renders_external_link_with_target_blank
    html = renderer.button("External", url: "https://example.com", external: true)

    assert_includes html, 'target="_blank"'
  end

  def test_button_does_not_add_target_blank_for_internal_links
    html = renderer.button("Internal", url: "/path")

    refute_includes html, "target"
  end

  def test_button_accepts_block_content
    html = renderer.button { "Block content" }

    assert_includes html, "Block content"
  end

  def test_button_merges_custom_class
    html = renderer.button("Click", class: "my-class")

    assert_includes html, "my-class"
  end

  def test_button_passes_html_options
    html = renderer.button("Click", id: "my-btn")

    assert_includes html, 'id="my-btn"'
  end

  # group
  def test_group_renders_div
    html = renderer.group { renderer.button("One") }

    assert_includes html, "<div"
    assert_includes html, "One"
  end

  def test_group_merges_custom_class
    html = renderer.group(class: "custom") { "" }

    assert_includes html, "custom"
  end
end
