# frozen_string_literal: true

require "test_helper"

class PopoverHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PopoverHelper

  # ── rendering ─────────────────────────────────────────────────────────────

  def test_renders_div
    assert_css parse_html(sp_popover { |_p| nil }), "div"
  end

  def test_wraps_content_in_template_by_default
    assert_css parse_html(sp_popover { |p| p.content { "body" } }), "template"
  end

  def test_no_template_when_not_interactive
    assert_no_css parse_html(sp_popover(interactive: false) { |p| p.content { "body" } }), "template"
  end

  def test_renders_activator
    assert_includes parse_html(sp_popover { |p| p.activator { "trigger" } }).text, "trigger"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_popover(class: "dropdown") { |_p| nil }), ".dropdown"
  end
end
