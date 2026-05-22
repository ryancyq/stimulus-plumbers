# frozen_string_literal: true

require "test_helper"

class ButtonHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::ButtonHelper

  # ── button ────────────────────────────────────────────────────────────────

  def test_renders_button_by_default
    doc = parse_html(sp_button("Click me"))

    assert_css doc, "button"
    assert_includes doc.text, "Click me"
  end

  def test_renders_with_type_button
    assert_css parse_html(sp_button("Click me")), "button[type='button']"
  end

  def test_renders_as_link_when_url_given
    doc = parse_html(sp_button("Go", url: "/dashboard"))

    assert_css doc, "a[href='/dashboard']"
    assert_includes doc.text, "Go"
  end

  def test_renders_external_link_with_target_blank
    assert_css parse_html(sp_button("External", url: "https://example.com", external: true)),
               "a[target='_blank']"
  end

  def test_does_not_add_target_blank_for_internal_links
    assert_no_css parse_html(sp_button("Internal", url: "/path")), "a[target]"
  end

  def test_accepts_block_content
    assert_includes parse_html(sp_button { "Block content" }).text, "Block content"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_button("Click", class: "my-class")), ".my-class"
  end

  def test_passes_html_options
    doc = parse_html(sp_button("Click", id: "my-btn", data: { testid: "btn" }))

    assert_css doc, "#my-btn"
    assert_css doc, "[data-testid='btn']"
  end

  # ── group ─────────────────────────────────────────────────────────────────

  def test_button_group_renders_div
    doc = parse_html(sp_button_group { sp_button("One") })

    assert_css doc, "div"
    assert_includes doc.text, "One"
  end

  # ── badge ──────────────────────────────────────────────────────────────────

  def test_badge_dot_wraps_button_in_relative_span
    doc = parse_html(sp_button("Notify", badge: true))

    assert_css doc, "span.relative"
  end

  def test_badge_count_renders_number
    doc = parse_html(sp_button("Notify", badge: 5))
    badge_span = doc.css("span[aria-hidden='true']").first

    assert_equal "5", badge_span.text.strip
  end

  def test_badge_omitted_does_not_wrap_button
    assert_no_css parse_html(sp_button("Click")), "span.relative"
  end
end
