# frozen_string_literal: true

require "test_helper"

class CalendarNavigatorTest < ActionView::TestCase
  def navigator
    StimulusPlumbers::Components::Calendar::Navigator.new(self)
  end

  # navigator
  def test_navigator_renders_button
    html = navigator.navigator

    assert_includes html, "<button"
  end

  def test_navigator_passes_data_attributes
    html = navigator.navigator(data: { "calendar-month-target" => "previous" })

    assert_includes html, 'data-calendar-month-target="previous"'
  end

  def test_navigator_merges_custom_class
    html = navigator.navigator(class: "nav-btn")

    assert_includes html, "nav-btn"
  end

  def test_navigator_renders_icon_inside_button
    html = navigator.navigator(icon_options: { name: "arrow-left" })

    assert_includes html, "<svg"
  end

  def test_navigator_renders_fallback_span_for_unknown_icon
    html = navigator.navigator(icon_options: { name: "unknown-icon" })

    assert_includes html, "<span"
  end

  # icon
  def test_icon_renders_svg_for_known_name
    html = navigator.icon(name: "arrow-left")

    assert_includes html, "<svg"
  end

  def test_icon_renders_span_for_unknown_name
    html = navigator.icon(name: "unknown")

    assert_includes html, "<span"
  end
end
