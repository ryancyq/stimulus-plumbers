# frozen_string_literal: true

require_relative "../application_accessibility_test_case"

class CalendarStimulusAccessibilityTest < ApplicationAccessibilityTestCase
  # Each test covers a unique JS-rendered HTML configuration verified by axe.

  def test_passes_wcag_with_default_month
    visit "/components/calendar_stimulus"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_for_28_cell_grid
    # Feb 2026: no padding rows
    visit "/components/calendar_stimulus?year=2026&month=2"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_for_42_cell_grid
    # Jul 2023: 6-week month
    visit "/components/calendar_stimulus?year=2023&month=7"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_other_months_visible
    visit "/components/calendar_stimulus?year=2026&month=4&show_other_months=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_date_range
    # Apr 2026: since/till spans into padding months to cover current + other-month + disabled cell states
    visit "/components/calendar_stimulus?year=2026&month=4&since=2026-03-30&till=2026-04-20"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_date_range_and_other_months_visible
    visit "/components/calendar_stimulus?year=2026&month=4&since=2026-03-30&till=2026-04-20&show_other_months=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_selected_date
    visit "/components/calendar_stimulus?year=2026&month=6"
    find("#calendar [role='gridcell']", text: "15").click

    assert_accessible context: "#calendar"
  end
end
