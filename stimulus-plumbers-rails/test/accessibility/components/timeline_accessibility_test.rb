# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class TimelineAccessibilityTest < ApplicationAccessibilityTestCase
  def setup
    super
    visit "/components/display/timeline"
  end

  def test_static_timeline_passes_wcag
    assert_accessible context: "#timeline-static"
  end

  def test_interactive_timeline_passes_wcag_in_closed_state
    assert_accessible context: "#timeline-interactive"
  end

  def test_interactive_timeline_passes_wcag_in_open_state
    within("#timeline-interactive") { first("button[aria-expanded]").click }

    assert_accessible context: "#timeline-interactive"
  end

  def test_horizontal_timeline_passes_wcag
    assert_accessible context: "#timeline-horizontal"
  end

  def test_grouped_timeline_passes_wcag
    assert_accessible context: "#timeline-grouped"
  end

  def test_grouped_horizontal_timeline_passes_wcag
    assert_accessible context: "#timeline-grouped-horizontal"
  end

  def test_interactive_timeline_date_format_fills_time_elements
    within("#timeline-interactive") do
      datetimes = all("time[datetime]").map { |el| el["datetime"] }

      assert_predicate datetimes, :any?, "expected <time datetime> elements"
      datetimes.each do |datetime|
        assert_selector "time[datetime='#{datetime}']",
                        text: %r{\S+},
                        wait: Capybara.default_max_wait_time
      end
    end
  end
end
