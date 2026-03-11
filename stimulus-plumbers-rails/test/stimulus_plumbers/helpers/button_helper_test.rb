# frozen_string_literal: true

require "test_helper"

class ButtonHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ButtonHelper

  def test_renders_button_by_default
    html = sp_button("Click me")

    assert_includes html, "<button"
    assert_includes html, "Click me"
  end

  def test_renders_with_type_button
    html = sp_button("Click me")

    assert_includes html, 'type="button"'
  end

  def test_renders_as_link_when_url_given
    html = sp_button("Go", url: "/dashboard")

    assert_includes html, "<a"
    assert_includes html, 'href="/dashboard"'
    assert_includes html, "Go"
  end

  def test_renders_external_link_with_target_blank
    html = sp_button("External", url: "https://example.com", external: true)

    assert_includes html, 'target="_blank"'
  end

  def test_does_not_add_target_blank_for_internal_links
    html = sp_button("Internal", url: "/path")

    refute_includes html, "target"
  end

  def test_accepts_block_content
    html = sp_button { "Block content" }

    assert_includes html, "Block content"
  end

  def test_merges_custom_class
    html = sp_button("Click", class: "my-class")

    assert_includes html, "my-class"
  end

  def test_passes_html_options
    html = sp_button("Click", id: "my-btn", data: { testid: "btn" })

    assert_includes html, 'id="my-btn"'
    assert_includes html, 'data-testid="btn"'
  end

  def test_button_group_renders_div
    html = sp_button_group { sp_button("One") }

    assert_includes html, "<div"
    assert_includes html, "One"
  end
end
