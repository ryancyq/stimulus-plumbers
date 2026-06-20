# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class TimelineAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/timeline"
  end

  def test_static_timeline_passes_wcag
    assert_accessible context: "#timeline-static"
  end

  def test_interactive_timeline_passes_wcag_in_closed_state
    assert_accessible context: "#timeline-interactive"
  end

  def test_interactive_timeline_passes_wcag_in_open_state
    within("#timeline-interactive") { find("button[aria-expanded]").click }
    assert_accessible context: "#timeline-interactive"
  end
end
