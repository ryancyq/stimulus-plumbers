# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CalendarStimulusAccessibilityTest < ApplicationAccessibilityTestCase
  # Each test covers a unique JS-rendered HTML configuration verified by axe.

  def test_passes_wcag_with_default_month
    visit "/components/calendar_stimulus"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_for_28_cell_grid
    # Feb 2026: no padding rows (month=1 is Feb in JS 0-indexed)
    visit "/components/calendar_stimulus?year=2026&month=1"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_for_35_cell_grid
    # Apr 2026: 5-week month (month=3 is Apr in JS 0-indexed)
    visit "/components/calendar_stimulus?year=2026&month=3"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_for_42_cell_grid
    # Jul 2023: 6-week month (month=6 is Jul in JS 0-indexed)
    visit "/components/calendar_stimulus?year=2023&month=6"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_selected_day
    visit "/components/calendar_stimulus?year=2026&month=3"
    find("#calendar [role='gridcell']", text: "15").click

    assert_accessible context: "#calendar"
  end
end
