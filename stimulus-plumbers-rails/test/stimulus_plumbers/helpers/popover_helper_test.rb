# frozen_string_literal: true

require "test_helper"

class PopoverHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::PopoverHelper

  def test_renders_div
    assert_css parse_html(sp_popover { |_p| nil }), "div"
  end

  def test_wrapper_has_stimulus_controller
    assert_css parse_html(sp_popover { |_p| nil }), "[data-controller~='popover']"
  end

  def test_renders_trigger
    assert_includes parse_html(sp_popover { |p| p.trigger { "trigger" } }).text, "trigger"
  end

  def test_renders_panel_content
    assert_includes parse_html(sp_popover { |p| p.panel { "body" } }).text, "body"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_popover(class: "dropdown") { |_p| nil }), ".dropdown"
  end
end
